require "rjava"

# 
# [The "BSD licence"]
# Copyright (c) 2007 Ronald Blaschke
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
  module Perl5TargetImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Tool, :AttributeScope
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :RuleLabelScope
    }
  end
  
  class Perl5Target < Perl5TargetImports.const_get :Target
    include_class_members Perl5TargetImports
    
    typesig { [] }
    def initialize
      super()
      AttributeScope.attr_token_scope.add_attribute("self", nil)
      RuleLabelScope.attr_predefined_lexer_rule_properties_scope.add_attribute("self", nil)
    end
    
    typesig { [CodeGenerator, String] }
    def get_target_char_literal_from_antlrchar_literal(generator, literal)
      buf = StringBuffer.new(10)
      c = Grammar.get_char_value_from_grammar_char_literal(literal)
      if (c < Label::MIN_CHAR_VALUE)
        buf.append("\\x{0000}")
      else
        if (c < self.attr_target_char_value_escape.attr_length && !(self.attr_target_char_value_escape[c]).nil?)
          buf.append(self.attr_target_char_value_escape[c])
        else
          if ((Character::UnicodeBlock.of(RJava.cast_to_char(c))).equal?(Character::UnicodeBlock::BASIC_LATIN) && !Character.is_isocontrol(RJava.cast_to_char(c)))
            # normal char
            buf.append(RJava.cast_to_char(c))
          else
            # must be something unprintable...use \\uXXXX
            # turn on the bit above max "\\uFFFF" value so that we pad with zeros
            # then only take last 4 digits
            hex = JavaInteger.to_hex_string(c | 0x10000).to_upper_case.substring(1, 5)
            buf.append("\\x{")
            buf.append(hex)
            buf.append("}")
          end
        end
      end
      if ((buf.index_of("\\")).equal?(-1))
        # no need for interpolation, use single quotes
        buf.insert(0, Character.new(?\'.ord))
        buf.append(Character.new(?\'.ord))
      else
        # need string interpolation
        buf.insert(0, Character.new(?\".ord))
        buf.append(Character.new(?\".ord))
      end
      return buf.to_s
    end
    
    private
    alias_method :initialize__perl5target, :initialize
  end
  
end
