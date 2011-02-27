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
module Org::Antlr::Analysis
  module LL1DFAImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Org::Antlr::Misc, :MultiMap
      include_const ::Org::Antlr::Tool, :ANTLRParser
      include_const ::Java::Util, :Iterator
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :Collections
    }
  end
  
  # A special DFA that is exactly LL(1) or LL(1) with backtracking mode
  # predicates to resolve edge set collisions.
  class LL1DFA < LL1DFAImports.const_get :DFA
    include_class_members LL1DFAImports
    
    typesig { [::Java::Int, NFAState, Array.typed(LookaheadSet)] }
    # From list of lookahead sets (one per alt in decision), create
    # an LL(1) DFA.  One edge per set.
    # 
    # s0-{alt1}->:o=>1
    # | \
    # |  -{alt2}->:o=>2
    # |
    # ...
    def initialize(decision_number, decision_start_state, alt_look)
      super()
      s0 = new_state
      self.attr_start_state = s0
      self.attr_nfa = decision_start_state.attr_nfa
      self.attr_n_alts = self.attr_nfa.attr_grammar.get_number_of_alts_for_decision_nfa(decision_start_state)
      self.attr_decision_number = decision_number
      self.attr_decision_nfastart_state = decision_start_state
      init_alt_related_info
      self.attr_unreachable_alts = nil
      alt = 1
      while alt < alt_look.attr_length
        accept_alt_state = new_state
        accept_alt_state.attr_accept_state = true
        set_accept_state(alt, accept_alt_state)
        accept_alt_state.attr_k = 1
        accept_alt_state.attr_cached_uniquely_predicated_alt = alt
        e = get_label_for_set(alt_look[alt].attr_token_type_set)
        s0.add_transition(accept_alt_state, e)
        alt += 1
      end
    end
    
    typesig { [::Java::Int, NFAState, MultiMap] }
    # From a set of edgeset->list-of-alts mappings, create a DFA
    # that uses syn preds for all |list-of-alts|>1.
    def initialize(decision_number, decision_start_state, edge_map)
      super()
      s0 = new_state
      self.attr_start_state = s0
      self.attr_nfa = decision_start_state.attr_nfa
      self.attr_n_alts = self.attr_nfa.attr_grammar.get_number_of_alts_for_decision_nfa(decision_start_state)
      self.attr_decision_number = decision_number
      self.attr_decision_nfastart_state = decision_start_state
      init_alt_related_info
      self.attr_unreachable_alts = nil
      it = edge_map.key_set.iterator
      while it.has_next
        edge = it.next_
        alts = edge_map.get(edge)
        Collections.sort(alts) # make sure alts are attempted in order
        # System.out.println(edge+" -> "+alts);
        s = new_state
        s.attr_k = 1
        e = get_label_for_set(edge)
        s0.add_transition(s, e)
        if ((alts.size).equal?(1))
          s.attr_accept_state = true
          alt = alts.get(0)
          set_accept_state(alt, s)
          s.attr_cached_uniquely_predicated_alt = alt
        else
          # resolve with syntactic predicates.  Add edges from
          # state s that test predicates.
          s.attr_resolved_with_predicates = true
          i = 0
          while i < alts.size
            alt = RJava.cast_to_int(alts.get(i))
            s.attr_cached_uniquely_predicated_alt = NFA::INVALID_ALT_NUMBER
            pred_dfatarget = get_accept_state(alt)
            if ((pred_dfatarget).nil?)
              pred_dfatarget = new_state # create if not there.
              pred_dfatarget.attr_accept_state = true
              pred_dfatarget.attr_cached_uniquely_predicated_alt = alt
              set_accept_state(alt, pred_dfatarget)
            end
            # add a transition to pred target from d
            # 					int walkAlt =
            # 						decisionStartState.translateDisplayAltToWalkAlt(alt);
            # 					NFAState altLeftEdge = nfa.grammar.getNFAStateForAltOfDecision(decisionStartState, walkAlt);
            # 					NFAState altStartState = (NFAState)altLeftEdge.transition[0].target;
            # 					SemanticContext ctx = nfa.grammar.ll1Analyzer.getPredicates(altStartState);
            # 					System.out.println("sem ctx = "+ctx);
            # 					if ( ctx == null ) {
            # 						ctx = new SemanticContext.TruePredicate();
            # 					}
            # 					s.addTransition(predDFATarget, new Label(ctx));
            synpred = get_syn_pred_for_alt(decision_start_state, alt)
            if ((synpred).nil?)
              synpred = SemanticContext::TruePredicate.new
            end
            s.add_transition(pred_dfatarget, PredicateLabel.new(synpred))
            i += 1
          end
        end
      end
      # System.out.println("dfa for preds=\n"+this);
    end
    
    typesig { [IntervalSet] }
    def get_label_for_set(edge_set)
      e = nil
      atom = edge_set.get_single_element
      if (!(atom).equal?(Label::INVALID))
        e = Label.new(atom)
      else
        e = Label.new(edge_set)
      end
      return e
    end
    
    typesig { [NFAState, ::Java::Int] }
    def get_syn_pred_for_alt(decision_start_state, alt)
      walk_alt = decision_start_state.translate_display_alt_to_walk_alt(alt)
      alt_left_edge = self.attr_nfa.attr_grammar.get_nfastate_for_alt_of_decision(decision_start_state, walk_alt)
      alt_start_state = alt_left_edge.attr_transition[0].attr_target
      # System.out.println("alt "+alt+" start state = "+altStartState.stateNumber);
      if (alt_start_state.attr_transition[0].is_semantic_predicate)
        ctx = alt_start_state.attr_transition[0].attr_label.get_semantic_context
        if (ctx.is_syntactic_predicate)
          p = ctx
          if ((p.attr_predicate_ast.get_type).equal?(ANTLRParser::BACKTRACK_SEMPRED))
            # 					System.out.println("syn pred for alt "+walkAlt+" "+
            # 									   ((SemanticContext.Predicate)altStartState.transition[0].label.getSemanticContext()).predicateAST);
            if (ctx.is_syntactic_predicate)
              self.attr_nfa.attr_grammar.syn_pred_used_in_dfa(self, ctx)
            end
            return alt_start_state.attr_transition[0].attr_label.get_semantic_context
          end
        end
      end
      return nil
    end
    
    private
    alias_method :initialize__ll1dfa, :initialize
  end
  
end
