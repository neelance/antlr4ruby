require "rjava"

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
module Org::Antlr::Analysis
  module NFAImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :NFAFactory
    }
  end
  
  # An NFA (collection of NFAStates) constructed from a grammar.  This
  # NFA is one big machine for entire grammar.  Decision points are recorded
  # by the Grammar object so we can, for example, convert to DFA or simulate
  # the NFA (interpret a decision).
  class NFA 
    include_class_members NFAImports
    
    class_module.module_eval {
      const_set_lazy(:INVALID_ALT_NUMBER) { -1 }
      const_attr_reader  :INVALID_ALT_NUMBER
    }
    
    # This NFA represents which grammar?
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    # Which factory created this NFA?
    attr_accessor :factory
    alias_method :attr_factory, :factory
    undef_method :factory
    alias_method :attr_factory=, :factory=
    undef_method :factory=
    
    attr_accessor :complete
    alias_method :attr_complete, :complete
    undef_method :complete
    alias_method :attr_complete=, :complete=
    undef_method :complete=
    
    typesig { [Grammar] }
    def initialize(g)
      @grammar = nil
      @factory = nil
      @complete = false
      @grammar = g
    end
    
    typesig { [] }
    def get_new_nfastate_number
      return @grammar.attr_composite.get_new_nfastate_number
    end
    
    typesig { [NFAState] }
    def add_state(state)
      @grammar.attr_composite.add_state(state)
    end
    
    typesig { [::Java::Int] }
    def get_state(s)
      return @grammar.attr_composite.get_state(s)
    end
    
    typesig { [] }
    def get_factory
      return @factory
    end
    
    typesig { [NFAFactory] }
    def set_factory(factory)
      @factory = factory
    end
    
    private
    alias_method :initialize__nfa, :initialize
  end
  
end
