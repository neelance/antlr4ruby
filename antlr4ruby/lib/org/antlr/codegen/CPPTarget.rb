require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
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
  module CPPTargetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateGroup
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr, :Tool
      include_const ::Java::Io, :IOException
    }
  end
  
  class CPPTarget < CPPTargetImports.const_get :Target
    include_class_members CPPTargetImports
    
    typesig { [::Java::Int] }
    def escape_char(c)
      # System.out.println("CPPTarget.escapeChar("+c+")");
      case (c)
      when Character.new(?\n.ord)
        return "\\n"
      when Character.new(?\t.ord)
        return "\\t"
      when Character.new(?\r.ord)
        return "\\r"
      when Character.new(?\\.ord)
        return "\\\\"
      when Character.new(?\'.ord)
        return "\\'"
      when Character.new(?".ord)
        return "\\\""
      else
        if (c < Character.new(?\s.ord) || c > 126)
          if (c > 255)
            s = JavaInteger.to_s(c, 16)
            # put leading zeroes in front of the thing..
            while (s.length < 4)
              s = RJava.cast_to_string(Character.new(?0.ord)) + s
            end
            return "\\u" + s
          else
            return "\\" + RJava.cast_to_string(JavaInteger.to_s(c, 8))
          end
        else
          return String.value_of(RJava.cast_to_char(c))
        end
      end
    end
    
    typesig { [String] }
    # Converts a String into a representation that can be use as a literal
    # when surrounded by double-quotes.
    # 
    # Used for escaping semantic predicate strings for exceptions.
    # 
    # @param s The String to be changed into a literal
    def escape_string(s)
      retval = StringBuffer.new
      i = 0
      while i < s.length
        retval.append(escape_char(s.char_at(i)))
        i += 1
      end
      return retval.to_s
    end
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate, String] }
    def gen_recognizer_header_file(tool, generator, grammar, header_file_st, ext_name)
      templates = generator.get_templates
      generator.write(header_file_st, RJava.cast_to_string(grammar.attr_name) + ext_name)
    end
    
    typesig { [CodeGenerator, String] }
    # Convert from an ANTLR char literal found in a grammar file to
    # an equivalent char literal in the target language.  For Java, this
    # is the identify translation; i.e., '\n' -> '\n'.  Most languages
    # will be able to use this 1-to-1 mapping.  Expect single quotes
    # around the incoming literal.
    # Depending on the charvocabulary the charliteral should be prefixed with a 'L'
    def get_target_char_literal_from_antlrchar_literal(codegen, literal)
      c = Grammar.get_char_value_from_grammar_char_literal(literal)
      prefix = "'"
      if (codegen.attr_grammar.get_max_char_value > 255)
        prefix = "L'"
      else
        if (!((c & 0x80)).equal?(0))
          # if in char mode prevent sign extensions
          return "" + RJava.cast_to_string(c)
        end
      end
      return prefix + RJava.cast_to_string(escape_char(c)) + "'"
    end
    
    typesig { [CodeGenerator, String] }
    # Convert from an ANTLR string literal found in a grammar file to
    # an equivalent string literal in the target language.  For Java, this
    # is the identify translation; i.e., "\"\n" -> "\"\n".  Most languages
    # will be able to use this 1-to-1 mapping.  Expect double quotes
    # around the incoming literal.
    # Depending on the charvocabulary the string should be prefixed with a 'L'
    def get_target_string_literal_from_antlrstring_literal(codegen, literal)
      buf = Grammar.get_unescaped_string_from_grammar_string_literal(literal)
      prefix = "\""
      if (codegen.attr_grammar.get_max_char_value > 255)
        prefix = "L\""
      end
      return prefix + RJava.cast_to_string(escape_string(buf.to_s)) + "\""
    end
    
    typesig { [CodeGenerator] }
    # Character constants get truncated to this value.
    # TODO: This should be derived from the charVocabulary. Depending on it
    # being 255 or 0xFFFF the templates should generate normal character
    # constants or multibyte ones.
    def get_max_char_value(codegen)
      maxval = 255 # codegen.grammar.get????();
      if (maxval <= 255)
        return 255
      else
        return maxval
      end
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__cpptarget, :initialize
  end
  
end
