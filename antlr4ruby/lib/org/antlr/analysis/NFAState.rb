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
module Org::Antlr::Analysis
  module NFAStateImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :GrammarAST
      include_const ::Org::Antlr::Tool, :Rule
      include_const ::Org::Antlr::Tool, :ErrorManager
    }
  end
  
  # A state within an NFA. At most 2 transitions emanate from any NFA state.
  class NFAState < NFAStateImports.const_get :State
    include_class_members NFAStateImports
    
    class_module.module_eval {
      # I need to distinguish between NFA decision states for (...)* and (...)+
      # during NFA interpretation.
      const_set_lazy(:LOOPBACK) { 1 }
      const_attr_reader  :LOOPBACK
      
      const_set_lazy(:BLOCK_START) { 2 }
      const_attr_reader  :BLOCK_START
      
      const_set_lazy(:OPTIONAL_BLOCK_START) { 3 }
      const_attr_reader  :OPTIONAL_BLOCK_START
      
      const_set_lazy(:BYPASS) { 4 }
      const_attr_reader  :BYPASS
      
      const_set_lazy(:RIGHT_EDGE_OF_BLOCK) { 5 }
      const_attr_reader  :RIGHT_EDGE_OF_BLOCK
      
      const_set_lazy(:MAX_TRANSITIONS) { 2 }
      const_attr_reader  :MAX_TRANSITIONS
    }
    
    # How many transitions; 0, 1, or 2 transitions
    attr_accessor :num_transitions
    alias_method :attr_num_transitions, :num_transitions
    undef_method :num_transitions
    alias_method :attr_num_transitions=, :num_transitions=
    undef_method :num_transitions=
    
    attr_accessor :transition
    alias_method :attr_transition, :transition
    undef_method :transition
    alias_method :attr_transition=, :transition=
    undef_method :transition=
    
    # For o-A->o type NFA tranitions, record the label that leads to this
    # state.  Useful for creating rich error messages when we find
    # insufficiently (with preds) covered states.
    attr_accessor :incident_edge_label
    alias_method :attr_incident_edge_label, :incident_edge_label
    undef_method :incident_edge_label
    alias_method :attr_incident_edge_label=, :incident_edge_label=
    undef_method :incident_edge_label=
    
    # Which NFA are we in?
    attr_accessor :nfa
    alias_method :attr_nfa, :nfa
    undef_method :nfa
    alias_method :attr_nfa=, :nfa=
    undef_method :nfa=
    
    # What's its decision number from 1..n?
    attr_accessor :decision_number
    alias_method :attr_decision_number, :decision_number
    undef_method :decision_number
    alias_method :attr_decision_number=, :decision_number=
    undef_method :decision_number=
    
    # Subrules (...)* and (...)+ have more than one decision point in
    # the NFA created for them.  They both have a loop-exit-or-stay-in
    # decision node (the loop back node).  They both have a normal
    # alternative block decision node at the left edge.  The (...)* is
    # worse as it even has a bypass decision (2 alts: stay in or bypass)
    # node at the extreme left edge.  This is not how they get generated
    # in code as a while-loop or whatever deals nicely with either.  For
    # error messages (where I need to print the nondeterministic alts)
    # and for interpretation, I need to use the single DFA that is created
    # (for efficiency) but interpret the results differently depending
    # on which of the 2 or 3 decision states uses the DFA.  For example,
    # the DFA will always report alt n+1 as the exit branch for n real
    # alts, so I need to translate that depending on the decision state.
    # 
    # If decisionNumber>0 then this var tells you what kind of decision
    # state it is.
    attr_accessor :decision_state_type
    alias_method :attr_decision_state_type, :decision_state_type
    undef_method :decision_state_type
    alias_method :attr_decision_state_type=, :decision_state_type=
    undef_method :decision_state_type=
    
    # What rule do we live in?
    attr_accessor :enclosing_rule
    alias_method :attr_enclosing_rule, :enclosing_rule
    undef_method :enclosing_rule
    alias_method :attr_enclosing_rule=, :enclosing_rule=
    undef_method :enclosing_rule=
    
    # During debugging and for nondeterminism warnings, it's useful
    # to know what relationship this node has to the original grammar.
    # For example, "start of alt 1 of rule a".
    attr_accessor :description
    alias_method :attr_description, :description
    undef_method :description
    alias_method :attr_description=, :description=
    undef_method :description=
    
    # Associate this NFAState with the corresponding GrammarAST node
    # from which this node was created.  This is useful not only for
    # associating the eventual lookahead DFA with the associated
    # Grammar position, but also for providing users with
    # nondeterminism warnings.  Mainly used by decision states to
    # report line:col info.  Could also be used to track line:col
    # for elements such as token refs.
    attr_accessor :associated_astnode
    alias_method :attr_associated_astnode, :associated_astnode
    undef_method :associated_astnode
    alias_method :attr_associated_astnode=, :associated_astnode=
    undef_method :associated_astnode=
    
    # Is this state the sole target of an EOT transition?
    attr_accessor :eottarget_state
    alias_method :attr_eottarget_state, :eottarget_state
    undef_method :eottarget_state
    alias_method :attr_eottarget_state=, :eottarget_state=
    undef_method :eottarget_state=
    
    # Jean Bovet needs in the GUI to know which state pairs correspond
    # to the start/stop of a block.
    attr_accessor :end_of_block_state_number
    alias_method :attr_end_of_block_state_number, :end_of_block_state_number
    undef_method :end_of_block_state_number
    alias_method :attr_end_of_block_state_number=, :end_of_block_state_number=
    undef_method :end_of_block_state_number=
    
    typesig { [NFA] }
    def initialize(nfa)
      @num_transitions = 0
      @transition = nil
      @incident_edge_label = nil
      @nfa = nil
      @decision_number = 0
      @decision_state_type = 0
      @enclosing_rule = nil
      @description = nil
      @associated_astnode = nil
      @eottarget_state = false
      @end_of_block_state_number = 0
      super()
      @num_transitions = 0
      @transition = Array.typed(Transition).new(MAX_TRANSITIONS) { nil }
      @nfa = nil
      @decision_number = 0
      @eottarget_state = false
      @end_of_block_state_number = State::INVALID_STATE_NUMBER
      @nfa = nfa
    end
    
    typesig { [] }
    def get_number_of_transitions
      return @num_transitions
    end
    
    typesig { [Transition] }
    def add_transition(e)
      if ((e).nil?)
        raise IllegalArgumentException.new("You can't add a null transition")
      end
      if (@num_transitions > @transition.attr_length)
        raise IllegalArgumentException.new("You can only have " + (@transition.attr_length).to_s + " transitions")
      end
      if (!(e).nil?)
        @transition[@num_transitions] = e
        ((@num_transitions += 1) - 1)
        # Set the "back pointer" of the target state so that it
        # knows about the label of the incoming edge.
        label = e.attr_label
        if (label.is_atom || label.is_set)
          if (!((e.attr_target).attr_incident_edge_label).nil?)
            ErrorManager.internal_error("Clobbered incident edge")
          end
          (e.attr_target).attr_incident_edge_label = e.attr_label
        end
      end
    end
    
    typesig { [Transition] }
    # Used during optimization to reset a state to have the (single)
    # transition another state has.
    def set_transition0(e)
      if ((e).nil?)
        raise IllegalArgumentException.new("You can't use a solitary null transition")
      end
      @transition[0] = e
      @transition[1] = nil
      @num_transitions = 1
    end
    
    typesig { [::Java::Int] }
    def transition(i)
      return @transition[i]
    end
    
    typesig { [::Java::Int] }
    # The DFA decision for this NFA decision state always has
    # an exit path for loops as n+1 for n alts in the loop.
    # That is really useful for displaying nondeterministic alts
    # and so on, but for walking the NFA to get a sequence of edge
    # labels or for actually parsing, we need to get the real alt
    # number.  The real alt number for exiting a loop is always 1
    # as transition 0 points at the exit branch (we compute DFAs
    # always for loops at the loopback state).
    # 
    # For walking/parsing the loopback state:
    # 1 2 3 display alt (for human consumption)
    # 2 3 1 walk alt
    # 
    # For walking the block start:
    # 1 2 3 display alt
    # 1 2 3
    # 
    # For walking the bypass state of a (...)* loop:
    # 1 2 3 display alt
    # 1 1 2 all block alts map to entering loop exit means take bypass
    # 
    # Non loop EBNF do not need to be translated; they are ignored by
    # this method as decisionStateType==0.
    # 
    # Return same alt if we can't translate.
    def translate_display_alt_to_walk_alt(display_alt)
      nfa_start = self
      if ((@decision_number).equal?(0) || (@decision_state_type).equal?(0))
        return display_alt
      end
      walk_alt = 0
      # find the NFA loopback state associated with this DFA
      # and count number of alts (all alt numbers are computed
      # based upon the loopback's NFA state.
      # 
      # DFA dfa = nfa.grammar.getLookaheadDFA(decisionNumber);
      # if ( dfa==null ) {
      # ErrorManager.internalError("can't get DFA for decision "+decisionNumber);
      # }
      n_alts = @nfa.attr_grammar.get_number_of_alts_for_decision_nfa(nfa_start)
      case (nfa_start.attr_decision_state_type)
      when LOOPBACK
        walk_alt = display_alt % n_alts + 1 # rotate right mod 1..3
      when BLOCK_START, OPTIONAL_BLOCK_START
        walk_alt = display_alt # identity transformation
      when BYPASS
        if ((display_alt).equal?(n_alts))
          walk_alt = 2 # bypass
        else
          walk_alt = 1 # any non exit branch alt predicts entering
        end
      end
      return walk_alt
    end
    
    typesig { [GrammarAST] }
    # Setter/Getters
    # What AST node is associated with this NFAState?  When you
    # set the AST node, I set the node to point back to this NFA state.
    def set_decision_astnode(decision_astnode)
      decision_astnode.set_nfastart_state(self)
      @associated_astnode = decision_astnode
    end
    
    typesig { [] }
    def get_description
      return @description
    end
    
    typesig { [String] }
    def set_description(description)
      @description = description
    end
    
    typesig { [] }
    def get_decision_number
      return @decision_number
    end
    
    typesig { [::Java::Int] }
    def set_decision_number(decision_number)
      @decision_number = decision_number
    end
    
    typesig { [] }
    def is_eottarget_state
      return @eottarget_state
    end
    
    typesig { [::Java::Boolean] }
    def set_eottarget_state(eot)
      @eottarget_state = eot
    end
    
    typesig { [] }
    def is_decision_state
      return @decision_state_type > 0
    end
    
    typesig { [] }
    def to_s
      return String.value_of(self.attr_state_number)
    end
    
    private
    alias_method :initialize__nfastate, :initialize
  end
  
end
