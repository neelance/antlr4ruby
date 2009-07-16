require "rjava"

# 
# [The "BSD licence"]
# Copyright (c) 2005 Terence Parr
# Copyright (c) 2006 Kay Roepke (Objective-C runtime)
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
  module ObjCTargetImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Java::Io, :IOException
    }
  end
  
  class ObjCTarget < ObjCTargetImports.const_get :Target
    include_class_members ObjCTargetImports
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate, String] }
    def gen_recognizer_header_file(tool, generator, grammar, header_file_st, ext_name)
      generator.write(header_file_st, (grammar.attr_name + Grammar.attr_grammar_type_to_file_name_suffix[grammar.attr_type]).to_s + ext_name)
    end
    
    typesig { [CodeGenerator, String] }
    def get_target_char_literal_from_antlrchar_literal(generator, literal)
      if (literal.starts_with("'\\u"))
        literal = "0x" + (literal.substring(3, 7)).to_s
      else
        c = literal.char_at(1) # TJP
        if (c < 32 || c > 127)
          literal = "0x" + (JavaInteger.to_hex_string(c)).to_s
        end
      end
      return literal
    end
    
    typesig { [CodeGenerator, String] }
    # Convert from an ANTLR string literal found in a grammar file to
    # an equivalent string literal in the target language.  For Java, this
    # is the translation 'a\n"' -> "a\n\"".  Expect single quotes
    # around the incoming literal.  Just flip the quotes and replace
    # double quotes with \"
    def get_target_string_literal_from_antlrstring_literal(generator, literal)
      literal = (Utils.replace(literal, "\"", "\\\"")).to_s
      buf = StringBuffer.new(literal)
      buf.set_char_at(0, Character.new(?".ord))
      buf.set_char_at(literal.length - 1, Character.new(?".ord))
      buf.insert(0, Character.new(?@.ord))
      return buf.to_s
    end
    
    typesig { [CodeGenerator, ::Java::Int] }
    # If we have a label, prefix it with the recognizer's name
    def get_token_type_as_target_label(generator, ttype)
      name = generator.attr_grammar.get_token_display_name(ttype)
      # If name is a literal, return the token type instead
      if ((name.char_at(0)).equal?(Character.new(?\'.ord)))
        return String.value_of(ttype)
      end
      return (generator.attr_grammar.attr_name + Grammar.attr_grammar_type_to_file_name_suffix[generator.attr_grammar.attr_type]).to_s + "_" + name
      # return super.getTokenTypeAsTargetLabel(generator, ttype);
      # return this.getTokenTextAndTypeAsTargetLabel(generator, null, ttype);
    end
    
    typesig { [CodeGenerator, String, ::Java::Int] }
    # Target must be able to override the labels used for token types. Sometimes also depends on the token text.
    def get_token_text_and_type_as_target_label(generator, text, token_type)
      name = generator.attr_grammar.get_token_display_name(token_type)
      # If name is a literal, return the token type instead
      if ((name.char_at(0)).equal?(Character.new(?\'.ord)))
        return String.value_of(token_type)
      end
      text_equivalent = (text).nil? ? name : text
      if (text_equivalent.char_at(0) >= Character.new(?0.ord) && text_equivalent.char_at(0) <= Character.new(?9.ord))
        return text_equivalent
      else
        return (generator.attr_grammar.attr_name + Grammar.attr_grammar_type_to_file_name_suffix[generator.attr_grammar.attr_type]).to_s + "_" + text_equivalent
      end
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__obj_ctarget, :initialize
  end
  
end
