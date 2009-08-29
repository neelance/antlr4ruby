require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005 Martin Traverso
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
  module RubyTargetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
    }
  end
  
  class RubyTarget < RubyTargetImports.const_get :Target
    include_class_members RubyTargetImports
    
    typesig { [CodeGenerator, String] }
    def get_target_char_literal_from_antlrchar_literal(generator, literal)
      literal = RJava.cast_to_string(literal.substring(1, literal.length - 1))
      result = "?"
      if ((literal == "\\"))
        result += "\\\\"
      else
        if ((literal == " "))
          result += "\\s"
        else
          if (literal.starts_with("\\u"))
            result = "0x" + RJava.cast_to_string(literal.substring(2))
          else
            result += literal
          end
        end
      end
      return result
    end
    
    typesig { [CodeGenerator] }
    def get_max_char_value(generator)
      # we don't support unicode, yet.
      return 0xff
    end
    
    typesig { [CodeGenerator, ::Java::Int] }
    def get_token_type_as_target_label(generator, ttype)
      name = generator.attr_grammar.get_token_display_name(ttype)
      # If name is a literal, return the token type instead
      if ((name.char_at(0)).equal?(Character.new(?\'.ord)))
        return generator.attr_grammar.compute_token_name_from_literal(ttype, name)
      end
      return name
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__ruby_target, :initialize
  end
  
end
