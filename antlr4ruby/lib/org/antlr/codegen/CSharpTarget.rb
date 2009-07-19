require "rjava"

# [The "BSD licence"]
# Copyright (c) 2006 Kunle Odutola
# Copyright (c) 2005 Terence Parr
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
  module CSharpTargetImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  class CSharpTarget < CSharpTargetImports.const_get :Target
    include_class_members CSharpTargetImports
    
    typesig { [Tool, CodeGenerator, Grammar, StringTemplate, StringTemplate] }
    def choose_where_cyclic_dfas_go(tool, generator, grammar, recognizer_st, cyclic_dfast)
      return recognizer_st
    end
    
    typesig { [::Java::Int] }
    def encode_int_as_char_escape(v)
      if (v <= 127)
        hex1 = JavaInteger.to_hex_string(v | 0x10000).substring(3, 5)
        return "\\x" + hex1
      end
      hex = JavaInteger.to_hex_string(v | 0x10000).substring(1, 5)
      return "\\u" + hex
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__csharp_target, :initialize
  end
  
end
