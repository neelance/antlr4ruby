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
  module CTargetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Java::Io, :IOException
      include_const ::Java::Util, :ArrayList
    }
  end
  
  class CTarget < CTargetImports.const_get :Target
    include_class_members CTargetImports
    
    attr_accessor :strings
    alias_method :attr_strings, :strings
    undef_method :strings
    alias_method :attr_strings=, :strings=
    undef_method :strings=
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate] }
    def gen_recognizer_file(tool, generator, grammar, output_file_st)
      # Before we write this, and cause it to generate its string,
      # we need to add all the string literals that we are going to match
      output_file_st.set_attribute("literals", @strings)
      file_name = generator.get_recognizer_file_name(grammar.attr_name, grammar.attr_type)
      System.out.println("Generating " + file_name)
      generator.write(output_file_st, file_name)
    end
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate, String] }
    def gen_recognizer_header_file(tool, generator, grammar, header_file_st, ext_name)
      # Pick up the file name we are generating. This method will return a
      # a file suffixed with .c, so we must substring and add the extName
      # to it as we cannot assign into strings in Java.
      # /
      file_name = generator.get_recognizer_file_name(grammar.attr_name, grammar.attr_type)
      file_name = RJava.cast_to_string(file_name.substring(0, file_name.length - 2)) + ext_name
      System.out.println("Generating " + file_name)
      generator.write(header_file_st, file_name)
    end
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate, StringTemplate] }
    def choose_where_cyclic_dfas_go(tool, generator, grammar, recognizer_st, cyclic_dfast)
      return recognizer_st
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
        if ((scope == "header"))
          return true
        end
        if ((scope == "includes"))
          return true
        end
        if ((scope == "preincludes"))
          return true
        end
        if ((scope == "overrides"))
          return true
        end
      when Grammar::PARSER
        if ((scope == "parser"))
          return true
        end
        if ((scope == "header"))
          return true
        end
        if ((scope == "includes"))
          return true
        end
        if ((scope == "preincludes"))
          return true
        end
        if ((scope == "overrides"))
          return true
        end
      when Grammar::COMBINED
        if ((scope == "parser"))
          return true
        end
        if ((scope == "lexer"))
          return true
        end
        if ((scope == "header"))
          return true
        end
        if ((scope == "includes"))
          return true
        end
        if ((scope == "preincludes"))
          return true
        end
        if ((scope == "overrides"))
          return true
        end
      when Grammar::TREE_PARSER
        if ((scope == "treeparser"))
          return true
        end
        if ((scope == "header"))
          return true
        end
        if ((scope == "includes"))
          return true
        end
        if ((scope == "preincludes"))
          return true
        end
        if ((scope == "overrides"))
          return true
        end
      end
      return false
    end
    
    typesig { [CodeGenerator, String] }
    def get_target_char_literal_from_antlrchar_literal(generator, literal)
      if (literal.starts_with("'\\u"))
        literal = "0x" + RJava.cast_to_string(literal.substring(3, 7))
      else
        c = literal.char_at(1)
        if (c < 32 || c > 127)
          literal = "0x" + RJava.cast_to_string(JavaInteger.to_hex_string(c))
        end
      end
      return literal
    end
    
    typesig { [CodeGenerator, String] }
    # Convert from an ANTLR string literal found in a grammar file to
    # an equivalent string literal in the C target.
    # Because we msut support Unicode character sets and have chosen
    # to have the lexer match UTF32 characters, then we must encode
    # string matches to use 32 bit character arrays. Here then we
    # must produce the C array and cater for the case where the
    # lexer has been eoncded with a string such as "xyz\n", which looks
    # slightly incogrous to me but is not incorrect.
    def get_target_string_literal_from_antlrstring_literal(generator, literal)
      index = 0
      outc = 0
      bytes = nil
      buf = StringBuffer.new
      buf.append("{ ")
      # We need ot lose any escaped characters of the form \x and just
      # replace them with their actual values as well as lose the surrounding
      # quote marks.
      i = 1
      while i < literal.length - 1
        buf.append("0x")
        if ((literal.char_at(i)).equal?(Character.new(?\\.ord)))
          i += 1 # Assume that there is a next character, this will just yield
          # invalid strings if not, which is what the input would be of course - invalid
          case (literal.char_at(i))
          when Character.new(?u.ord), Character.new(?U.ord)
            buf.append(literal.substring(i + 1, i + 5)) # Already a hex string
            i = i + 5 # Move to next string/char/escape
          when Character.new(?n.ord), Character.new(?N.ord)
            buf.append("0A")
          when Character.new(?r.ord), Character.new(?R.ord)
            buf.append("0D")
          when Character.new(?t.ord), Character.new(?T.ord)
            buf.append("09")
          when Character.new(?b.ord), Character.new(?B.ord)
            buf.append("08")
          when Character.new(?f.ord), Character.new(?F.ord)
            buf.append("0C")
          else
            # Anything else is what it is!
            buf.append(JavaInteger.to_hex_string(RJava.cast_to_int(literal.char_at(i))).to_upper_case)
          end
        else
          buf.append(JavaInteger.to_hex_string(RJava.cast_to_int(literal.char_at(i))).to_upper_case)
        end
        buf.append(", ")
        i += 1
      end
      buf.append(" ANTLR3_STRING_TERMINATOR}")
      bytes = RJava.cast_to_string(buf.to_s)
      index = @strings.index_of(bytes)
      if ((index).equal?(-1))
        @strings.add(bytes)
        index = @strings.index_of(bytes)
      end
      strref = "lit_" + RJava.cast_to_string(String.value_of(index + 1))
      return strref
    end
    
    typesig { [] }
    def initialize
      @strings = nil
      super()
      @strings = ArrayList.new
    end
    
    private
    alias_method :initialize__ctarget, :initialize
  end
  
end
