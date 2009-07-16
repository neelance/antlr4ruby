require "rjava"

# 
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
  module ActionScriptTargetImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  class ActionScriptTarget < ActionScriptTargetImports.const_get :Target
    include_class_members ActionScriptTargetImports
    
    typesig { [CodeGenerator, String] }
    def get_target_char_literal_from_antlrchar_literal(generator, literal)
      c = Grammar.get_char_value_from_grammar_char_literal(literal)
      return String.value_of(c)
    end
    
    typesig { [CodeGenerator, ::Java::Int] }
    def get_token_type_as_target_label(generator, ttype)
      # use ints for predefined types;
      # <invalid> <EOR> <DOWN> <UP>
      if (ttype >= 0 && ttype <= 3)
        return String.value_of(ttype)
      end
      name = generator.attr_grammar.get_token_display_name(ttype)
      # If name is a literal, return the token type instead
      if ((name.char_at(0)).equal?(Character.new(?\'.ord)))
        return String.value_of(ttype)
      end
      return name
    end
    
    typesig { [::Java::Int] }
    # 
    # ActionScript doesn't support Unicode String literals that are considered "illegal"
    # or are in the surrogate pair ranges.  For example "/uffff" will not encode properly
    # nor will "/ud800".  To keep things as compact as possible we use the following encoding
    # if the int is below 255, we encode as hex literal
    # If the int is between 255 and 0x7fff we use a single unicode literal with the value
    # If the int is above 0x7fff, we use a unicode literal of 0x80hh, where hh is the high-order
    # bits followed by \xll where ll is the lower order bits of a 16-bit number.
    # 
    # Ideally this should be improved at a future date.  The most optimal way to encode this
    # may be a compressed AMF encoding that is embedded using an Embed tag in ActionScript.
    # 
    # @param v
    # @return
    def encode_int_as_char_escape(v)
      # encode as hex
      if (v <= 255)
        return "\\x" + (JavaInteger.to_hex_string(v | 0x100).substring(1, 3)).to_s
      end
      if (v <= 0x7fff)
        hex = JavaInteger.to_hex_string(v | 0x10000).substring(1, 5)
        return "\\u" + hex
      end
      if (v > 0xffff)
        System.err.println("Warning: character literal out of range for ActionScript target " + (v).to_s)
        return ""
      end
      buf = StringBuffer.new("\\u80")
      buf.append(JavaInteger.to_hex_string((v >> 8) | 0x100).substring(1, 3)) # high - order bits
      buf.append("\\x")
      buf.append(JavaInteger.to_hex_string((v & 0xff) | 0x100).substring(1, 3)) # low -order bits
      return buf.to_s
    end
    
    typesig { [::Java::Long] }
    # Convert long to two 32-bit numbers separted by a comma.
    # ActionScript does not support 64-bit numbers, so we need to break
    # the number into two 32-bit literals to give to the Bit.  A number like
    # 0xHHHHHHHHLLLLLLLL is broken into the following string:
    # "0xLLLLLLLL, 0xHHHHHHHH"
    # Note that the low order bits are first, followed by the high order bits.
    # This is to match how the BitSet constructor works, where the bits are
    # passed in in 32-bit chunks with low-order bits coming first.
    def get_target64bit_string_from_value(word)
      buf = StringBuffer.new(22) # enough for the two "0x", "," and " "
      buf.append("0x")
      write_hex_with_padding(buf, JavaInteger.to_hex_string(RJava.cast_to_int((word & 0xffffffff))))
      buf.append(", 0x")
      write_hex_with_padding(buf, JavaInteger.to_hex_string(RJava.cast_to_int((word >> 32))))
      return buf.to_s
    end
    
    typesig { [StringBuffer, String] }
    def write_hex_with_padding(buf, digits)
      digits = (digits.to_upper_case).to_s
      padding = 8 - digits.length
      # pad left with zeros
      i = 1
      while i <= padding
        buf.append(Character.new(?0.ord))
        ((i += 1) - 1)
      end
      buf.append(digits)
    end
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate, StringTemplate] }
    def choose_where_cyclic_dfas_go(tool, generator, grammar, recognizer_st, cyclic_dfast)
      return recognizer_st
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__action_script_target, :initialize
  end
  
end
