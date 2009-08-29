require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
module Org::Antlr::Codegen
  module TargetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Java::Io, :IOException
      include_const ::Java::Util, :JavaList
    }
  end
  
  # The code generator for ANTLR can usually be retargeted just by providing
  # a new X.stg file for language X, however, sometimes the files that must
  # be generated vary enough that some X-specific functionality is required.
  # For example, in C, you must generate header files whereas in Java you do not.
  # Other languages may want to keep DFA separate from the main
  # generated recognizer file.
  # 
  # The notion of a Code Generator target abstracts out the creation
  # of the various files.  As new language targets get added to the ANTLR
  # system, this target class may have to be altered to handle more
  # functionality.  Eventually, just about all language generation issues
  # will be expressible in terms of these methods.
  # 
  # If org.antlr.codegen.XTarget class exists, it is used else
  # Target base class is used.  I am using a superclass rather than an
  # interface for this target concept because I can add functionality
  # later without breaking previously written targets (extra interface
  # methods would force adding dummy functions to all code generator
  # target classes).
  class Target 
    include_class_members TargetImports
    
    # For pure strings of Java 16-bit unicode char, how can we display
    # it in the target language as a literal.  Useful for dumping
    # predicates and such that may refer to chars that need to be escaped
    # when represented as strings.  Also, templates need to be escaped so
    # that the target language can hold them as a string.
    # 
    # I have defined (via the constructor) the set of typical escapes,
    # but your Target subclass is free to alter the translated chars or
    # add more definitions.  This is nonstatic so each target can have
    # a different set in memory at same time.
    attr_accessor :target_char_value_escape
    alias_method :attr_target_char_value_escape, :target_char_value_escape
    undef_method :target_char_value_escape
    alias_method :attr_target_char_value_escape=, :target_char_value_escape=
    undef_method :target_char_value_escape=
    
    typesig { [] }
    def initialize
      @target_char_value_escape = Array.typed(String).new(255) { nil }
      @target_char_value_escape[Character.new(?\n.ord)] = "\\n"
      @target_char_value_escape[Character.new(?\r.ord)] = "\\r"
      @target_char_value_escape[Character.new(?\t.ord)] = "\\t"
      @target_char_value_escape[Character.new(?\b.ord)] = "\\b"
      @target_char_value_escape[Character.new(?\f.ord)] = "\\f"
      @target_char_value_escape[Character.new(?\\.ord)] = "\\\\"
      @target_char_value_escape[Character.new(?\'.ord)] = "\\'"
      @target_char_value_escape[Character.new(?".ord)] = "\\\""
    end
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate] }
    def gen_recognizer_file(tool, generator, grammar, output_file_st)
      file_name = generator.get_recognizer_file_name(grammar.attr_name, grammar.attr_type)
      generator.write(output_file_st, file_name)
    end
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate, String] }
    # e.g., ".h"
    def gen_recognizer_header_file(tool, generator, grammar, header_file_st, ext_name)
      # no header file by default
    end
    
    typesig { [CodeGenerator, Grammar] }
    def perform_grammar_analysis(generator, grammar)
      # Build NFAs from the grammar AST
      grammar.build_nfa
      # Create the DFA predictors for each decision
      grammar.create_lookahead_dfas
    end
    
    typesig { [::Java::Int, String] }
    # Is scope in @scope::name {action} valid for this kind of grammar?
    # Targets like C++ may want to allow new scopes like headerfile or
    # some such.  The action names themselves are not policed at the
    # moment so targets can add template actions w/o having to recompile
    # ANTLR.
    def is_valid_action_scope(grammar_type, scope)
      case (grammar_type)
      when Grammar::LEXER
        if ((scope == "lexer"))
          return true
        end
      when Grammar::PARSER
        if ((scope == "parser"))
          return true
        end
      when Grammar::COMBINED
        if ((scope == "parser"))
          return true
        end
        if ((scope == "lexer"))
          return true
        end
      when Grammar::TREE_PARSER
        if ((scope == "treeparser"))
          return true
        end
      end
      return false
    end
    
    typesig { [CodeGenerator, ::Java::Int] }
    # Target must be able to override the labels used for token types
    def get_token_type_as_target_label(generator, ttype)
      name = generator.attr_grammar.get_token_display_name(ttype)
      # If name is a literal, return the token type instead
      if ((name.char_at(0)).equal?(Character.new(?\'.ord)))
        return String.value_of(ttype)
      end
      return name
    end
    
    typesig { [CodeGenerator, String] }
    # Convert from an ANTLR char literal found in a grammar file to
    # an equivalent char literal in the target language.  For most
    # languages, this means leaving 'x' as 'x'.  Actually, we need
    # to escape '\u000A' so that it doesn't get converted to \n by
    # the compiler.  Convert the literal to the char value and then
    # to an appropriate target char literal.
    # 
    # Expect single quotes around the incoming literal.
    def get_target_char_literal_from_antlrchar_literal(generator, literal)
      buf = StringBuffer.new
      buf.append(Character.new(?\'.ord))
      c = Grammar.get_char_value_from_grammar_char_literal(literal)
      if (c < Label::MIN_CHAR_VALUE)
        return ("'".to_u << 0x0000 << "'")
      end
      if (c < @target_char_value_escape.attr_length && !(@target_char_value_escape[c]).nil?)
        buf.append(@target_char_value_escape[c])
      else
        if ((Character::UnicodeBlock.of(RJava.cast_to_char(c))).equal?(Character::UnicodeBlock::BASIC_LATIN) && !Character.is_isocontrol(RJava.cast_to_char(c)))
          # normal char
          buf.append(RJava.cast_to_char(c))
        else
          # must be something unprintable...use \\uXXXX
          # turn on the bit above max "\\uFFFF" value so that we pad with zeros
          # then only take last 4 digits
          hex = JavaInteger.to_hex_string(c | 0x10000).to_upper_case.substring(1, 5)
          buf.append("\\u")
          buf.append(hex)
        end
      end
      buf.append(Character.new(?\'.ord))
      return buf.to_s
    end
    
    typesig { [CodeGenerator, String] }
    # Convert from an ANTLR string literal found in a grammar file to
    # an equivalent string literal in the target language.  For Java, this
    # is the translation 'a\n"' -> "a\n\"".  Expect single quotes
    # around the incoming literal.  Just flip the quotes and replace
    # double quotes with \"
    def get_target_string_literal_from_antlrstring_literal(generator, literal)
      literal = RJava.cast_to_string(Utils.replace(literal, "\\\"", "\"")) # \" to " to normalize
      literal = RJava.cast_to_string(Utils.replace(literal, "\"", "\\\"")) # " to \" to escape all
      buf = StringBuffer.new(literal)
      buf.set_char_at(0, Character.new(?".ord))
      buf.set_char_at(literal.length - 1, Character.new(?".ord))
      return buf.to_s
    end
    
    typesig { [String, ::Java::Boolean] }
    # Given a random string of Java unicode chars, return a new string with
    # optionally appropriate quote characters for target language and possibly
    # with some escaped characters.  For example, if the incoming string has
    # actual newline characters, the output of this method would convert them
    # to the two char sequence \n for Java, C, C++, ...  The new string has
    # double-quotes around it as well.  Example String in memory:
    # 
    # a"[newlinechar]b'c[carriagereturnchar]d[tab]e\f
    # 
    # would be converted to the valid Java s:
    # 
    # "a\"\nb'c\rd\te\\f"
    # 
    # or
    # 
    # a\"\nb'c\rd\te\\f
    # 
    # depending on the quoted arg.
    def get_target_string_literal_from_string(s, quoted)
      if ((s).nil?)
        return nil
      end
      buf = StringBuffer.new
      if (quoted)
        buf.append(Character.new(?".ord))
      end
      i = 0
      while i < s.length
        c = s.char_at(i)
        # don't escape single quotes in strings for java
        if (!(c).equal?(Character.new(?\'.ord)) && c < @target_char_value_escape.attr_length && !(@target_char_value_escape[c]).nil?)
          buf.append(@target_char_value_escape[c])
        else
          buf.append(RJava.cast_to_char(c))
        end
        i += 1
      end
      if (quoted)
        buf.append(Character.new(?".ord))
      end
      return buf.to_s
    end
    
    typesig { [String] }
    def get_target_string_literal_from_string(s)
      return get_target_string_literal_from_string(s, false)
    end
    
    typesig { [::Java::Long] }
    # Convert long to 0xNNNNNNNNNNNNNNNN by default for spitting out
    # with bitsets.  I.e., convert bytes to hex string.
    def get_target64bit_string_from_value(word)
      num_hex_digits = 8 * 2
      buf = StringBuffer.new(num_hex_digits + 2)
      buf.append("0x")
      digits = Long.to_hex_string(word)
      digits = RJava.cast_to_string(digits.to_upper_case)
      padding = num_hex_digits - digits.length
      # pad left with zeros
      i = 1
      while i <= padding
        buf.append(Character.new(?0.ord))
        i += 1
      end
      buf.append(digits)
      return buf.to_s
    end
    
    typesig { [::Java::Int] }
    def encode_int_as_char_escape(v)
      if (v <= 127)
        return "\\" + RJava.cast_to_string(JavaInteger.to_octal_string(v))
      end
      hex = JavaInteger.to_hex_string(v | 0x10000).substring(1, 5)
      return "\\u" + hex
    end
    
    typesig { [CodeGenerator] }
    # Some targets only support ASCII or 8-bit chars/strings.  For example,
    # C++ will probably want to return 0xFF here.
    def get_max_char_value(generator)
      return Label::MAX_CHAR_VALUE
    end
    
    typesig { [JavaList, Antlr::Token] }
    # Give target a chance to do some postprocessing on actions.
    # Python for example will have to fix the indention.
    def post_process_action(chunks, action_token)
      return chunks
    end
    
    private
    alias_method :initialize__target, :initialize
  end
  
end
