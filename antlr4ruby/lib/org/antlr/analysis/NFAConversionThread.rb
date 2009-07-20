require "rjava"

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
module Org::Antlr::Analysis
  module NFAConversionThreadImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :Barrier
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :ErrorManager
    }
  end
  
  # Convert all decisions i..j inclusive in a thread
  class NFAConversionThread 
    include_class_members NFAConversionThreadImports
    include Runnable
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :i
    alias_method :attr_i, :i
    undef_method :i
    alias_method :attr_i=, :i=
    undef_method :i=
    
    attr_accessor :j
    alias_method :attr_j, :j
    undef_method :j
    alias_method :attr_j=, :j=
    undef_method :j=
    
    attr_accessor :barrier
    alias_method :attr_barrier, :barrier
    undef_method :barrier
    alias_method :attr_barrier=, :barrier=
    undef_method :barrier=
    
    typesig { [Grammar, Barrier, ::Java::Int, ::Java::Int] }
    def initialize(grammar, barrier, i, j)
      @grammar = nil
      @i = 0
      @j = 0
      @barrier = nil
      @grammar = grammar
      @barrier = barrier
      @i = i
      @j = j
    end
    
    typesig { [] }
    def run
      decision = @i
      while decision <= @j
        decision_start_state = @grammar.get_decision_nfastart_state(decision)
        if (decision_start_state.get_number_of_transitions > 1)
          @grammar.create_lookahead_dfa(decision, true)
        end
        decision += 1
      end
      # now wait for others to finish
      begin
        @barrier.wait_for_release
      rescue InterruptedException => e
        ErrorManager.internal_error("what the hell? DFA interruptus", e)
      end
    end
    
    private
    alias_method :initialize__nfaconversion_thread, :initialize
  end
  
end
