require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2008 Terence Parr
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
module Org::Antlr::Runtime
  module NoViableAltExceptionImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  class NoViableAltException < NoViableAltExceptionImports.const_get :RecognitionException
    include_class_members NoViableAltExceptionImports
    
    attr_accessor :grammar_decision_description
    alias_method :attr_grammar_decision_description, :grammar_decision_description
    undef_method :grammar_decision_description
    alias_method :attr_grammar_decision_description=, :grammar_decision_description=
    undef_method :grammar_decision_description=
    
    attr_accessor :decision_number
    alias_method :attr_decision_number, :decision_number
    undef_method :decision_number
    alias_method :attr_decision_number=, :decision_number=
    undef_method :decision_number=
    
    attr_accessor :state_number
    alias_method :attr_state_number, :state_number
    undef_method :state_number
    alias_method :attr_state_number=, :state_number=
    undef_method :state_number=
    
    typesig { [] }
    # Used for remote debugger deserialization
    def initialize
      @grammar_decision_description = nil
      @decision_number = 0
      @state_number = 0
      super()
    end
    
    typesig { [String, ::Java::Int, ::Java::Int, IntStream] }
    def initialize(grammar_decision_description, decision_number, state_number, input)
      @grammar_decision_description = nil
      @decision_number = 0
      @state_number = 0
      super(input)
      @grammar_decision_description = grammar_decision_description
      @decision_number = decision_number
      @state_number = state_number
    end
    
    typesig { [] }
    def to_s
      if (self.attr_input.is_a?(CharStream))
        return "NoViableAltException('" + RJava.cast_to_string(RJava.cast_to_char(get_unexpected_type)) + "'@[" + @grammar_decision_description + "])"
      else
        return "NoViableAltException(" + RJava.cast_to_string(get_unexpected_type) + "@[" + @grammar_decision_description + "])"
      end
    end
    
    private
    alias_method :initialize__no_viable_alt_exception, :initialize
  end
  
end
