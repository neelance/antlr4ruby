require "rjava"

# 
# [The "BSD licence"]
# Copyright (c) 2005-2008 Terence Parr
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
module Org::Antlr::Runtime::Debug
  module TracerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :IntStream
      include_const ::Org::Antlr::Runtime, :TokenStream
    }
  end
  
  # The default tracer mimics the traceParser behavior of ANTLR 2.x.
  # This listens for debugging events from the parser and implies
  # that you cannot debug and trace at the same time.
  class Tracer < TracerImports.const_get :BlankDebugEventListener
    include_class_members TracerImports
    
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    attr_accessor :level
    alias_method :attr_level, :level
    undef_method :level
    alias_method :attr_level=, :level=
    undef_method :level=
    
    typesig { [IntStream] }
    def initialize(input)
      @input = nil
      @level = 0
      super()
      @level = 0
      @input = input
    end
    
    typesig { [String] }
    def enter_rule(rule_name)
      i = 1
      while i <= @level
        System.out.print(" ")
        ((i += 1) - 1)
      end
      System.out.println("> " + rule_name + " lookahead(1)=" + (get_input_symbol(1)).to_s)
      ((@level += 1) - 1)
    end
    
    typesig { [String] }
    def exit_rule(rule_name)
      ((@level -= 1) + 1)
      i = 1
      while i <= @level
        System.out.print(" ")
        ((i += 1) - 1)
      end
      System.out.println("< " + rule_name + " lookahead(1)=" + (get_input_symbol(1)).to_s)
    end
    
    typesig { [::Java::Int] }
    def get_input_symbol(k)
      if (@input.is_a?(TokenStream))
        return (@input)._lt(k)
      end
      return Character.new(RJava.cast_to_char(@input._la(k)))
    end
    
    private
    alias_method :initialize__tracer, :initialize
  end
  
end
