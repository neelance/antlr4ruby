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
module Org::Antlr::Analysis
  module StateImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
    }
  end
  
  # A generic state machine state.
  class State 
    include_class_members StateImports
    
    class_module.module_eval {
      const_set_lazy(:INVALID_STATE_NUMBER) { -1 }
      const_attr_reader  :INVALID_STATE_NUMBER
    }
    
    attr_accessor :state_number
    alias_method :attr_state_number, :state_number
    undef_method :state_number
    alias_method :attr_state_number=, :state_number=
    undef_method :state_number=
    
    # An accept state is an end of rule state for lexers and
    # parser grammar rules.
    attr_accessor :accept_state
    alias_method :attr_accept_state, :accept_state
    undef_method :accept_state
    alias_method :attr_accept_state=, :accept_state=
    undef_method :accept_state=
    
    typesig { [] }
    def get_number_of_transitions
      raise NotImplementedError
    end
    
    typesig { [Transition] }
    def add_transition(e)
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def transition(i)
      raise NotImplementedError
    end
    
    typesig { [] }
    def is_accept_state
      return @accept_state
    end
    
    typesig { [::Java::Boolean] }
    def set_accept_state(accept_state)
      @accept_state = accept_state
    end
    
    typesig { [] }
    def initialize
      @state_number = INVALID_STATE_NUMBER
      @accept_state = false
    end
    
    private
    alias_method :initialize__state, :initialize
  end
  
end
