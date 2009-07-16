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
  module DFAOptimizerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Java::Util, :HashSet
      include_const ::Java::Util, :JavaSet
    }
  end
  
  # Walk DFA states, unlinking the nfa configs and whatever else I
  # can to reduce memory footprint.
  # protected void unlinkUnneededStateData(DFAState d) {
  # Integer sI = Utils.integer(d.stateNumber);
  # if ( visited.contains(sI) ) {
  # return; // already visited
  # }
  # visited.add(sI);
  # d.nfaConfigurations = null;
  # for (int i = 0; i < d.getNumberOfTransitions(); i++) {
  # Transition edge = (Transition) d.transition(i);
  # DFAState edgeTarget = ((DFAState)edge.target);
  # unlinkUnneededStateData(edgeTarget);
  # }
  # }
  # 
  # A module to perform optimizations on DFAs.
  # 
  # I could more easily (and more quickly) do some optimizations (such as
  # PRUNE_EBNF_EXIT_BRANCHES) during DFA construction, but then it
  # messes up the determinism checking.  For example, it looks like
  # loop exit branches are unreachable if you prune exit branches
  # during DFA construction and before determinism checks.
  # 
  # In general, ANTLR's NFA->DFA->codegen pipeline seems very robust
  # to me which I attribute to a uniform and consistent set of data
  # structures.  Regardless of what I want to "say"/implement, I do so
  # within the confines of, for example, a DFA.  The code generator
  # can then just generate code--it doesn't have to do much thinking.
  # Putting optimizations in the code gen code really starts to make
  # it a spagetti factory (uh oh, now I'm hungry!).  The pipeline is
  # very testable; each stage has well defined input/output pairs.
  # 
  # ### Optimization: PRUNE_EBNF_EXIT_BRANCHES
  # 
  # There is no need to test EBNF block exit branches.  Not only is it
  # an unneeded computation, but counter-intuitively, you actually get
  # better errors. You can report an error at the missing or extra
  # token rather than as soon as you've figured out you will fail.
  # 
  # Imagine optional block "( DOT CLASS )? SEMI".  ANTLR generates:
  # 
  # int alt=0;
  # if ( input.LA(1)==DOT ) {
  # alt=1;
  # }
  # else if ( input.LA(1)==SEMI ) {
  # alt=2;
  # }
  # 
  # Clearly, since Parser.match() will ultimately find the error, we
  # do not want to report an error nor do we want to bother testing
  # lookahead against what follows the (...)?  We want to generate
  # simply "should I enter the subrule?":
  # 
  # int alt=2;
  # if ( input.LA(1)==DOT ) {
  # alt=1;
  # }
  # 
  # NOTE 1. Greedy loops cannot be optimized in this way.  For example,
  # "(greedy=false:'x'|.)* '\n'".  You specifically need the exit branch
  # to tell you when to terminate the loop as the same input actually
  # predicts one of the alts (i.e., staying in the loop).
  # 
  # NOTE 2.  I do not optimize cyclic DFAs at the moment as it doesn't
  # seem to work. ;)  I'll have to investigate later to see what work I
  # can do on cyclic DFAs to make them have fewer edges.  Might have
  # something to do with the EOT token.
  # 
  # ### PRUNE_SUPERFLUOUS_EOT_EDGES
  # 
  # When a token is a subset of another such as the following rules, ANTLR
  # quietly assumes the first token to resolve the ambiguity.
  # 
  # EQ			: '=' ;
  # ASSIGNOP	: '=' | '+=' ;
  # 
  # It can yield states that have only a single edge on EOT to an accept
  # state.  This is a waste and messes up my code generation. ;)  If
  # Tokens rule DFA goes
  # 
  # s0 -'='-> s3 -EOT-> s5 (accept)
  # 
  # then s5 should be pruned and s3 should be made an accept.  Do NOT do this
  # for keyword versus ID as the state with EOT edge emanating from it will
  # also have another edge.
  # 
  # ### Optimization: COLLAPSE_ALL_INCIDENT_EDGES
  # 
  # Done during DFA construction.  See method addTransition() in
  # NFAToDFAConverter.
  # 
  # ### Optimization: MERGE_STOP_STATES
  # 
  # Done during DFA construction.  See addDFAState() in NFAToDFAConverter.
  class DFAOptimizer 
    include_class_members DFAOptimizerImports
    
    class_module.module_eval {
      
      def prune_ebnf_exit_branches
        defined?(@@prune_ebnf_exit_branches) ? @@prune_ebnf_exit_branches : @@prune_ebnf_exit_branches= true
      end
      alias_method :attr_prune_ebnf_exit_branches, :prune_ebnf_exit_branches
      
      def prune_ebnf_exit_branches=(value)
        @@prune_ebnf_exit_branches = value
      end
      alias_method :attr_prune_ebnf_exit_branches=, :prune_ebnf_exit_branches=
      
      
      def prune_tokens_rule_superfluous_eot_edges
        defined?(@@prune_tokens_rule_superfluous_eot_edges) ? @@prune_tokens_rule_superfluous_eot_edges : @@prune_tokens_rule_superfluous_eot_edges= true
      end
      alias_method :attr_prune_tokens_rule_superfluous_eot_edges, :prune_tokens_rule_superfluous_eot_edges
      
      def prune_tokens_rule_superfluous_eot_edges=(value)
        @@prune_tokens_rule_superfluous_eot_edges = value
      end
      alias_method :attr_prune_tokens_rule_superfluous_eot_edges=, :prune_tokens_rule_superfluous_eot_edges=
      
      
      def collapse_all_parallel_edges
        defined?(@@collapse_all_parallel_edges) ? @@collapse_all_parallel_edges : @@collapse_all_parallel_edges= true
      end
      alias_method :attr_collapse_all_parallel_edges, :collapse_all_parallel_edges
      
      def collapse_all_parallel_edges=(value)
        @@collapse_all_parallel_edges = value
      end
      alias_method :attr_collapse_all_parallel_edges=, :collapse_all_parallel_edges=
      
      
      def merge_stop_states
        defined?(@@merge_stop_states) ? @@merge_stop_states : @@merge_stop_states= true
      end
      alias_method :attr_merge_stop_states, :merge_stop_states
      
      def merge_stop_states=(value)
        @@merge_stop_states = value
      end
      alias_method :attr_merge_stop_states=, :merge_stop_states=
    }
    
    # Used by DFA state machine generator to avoid infinite recursion
    # resulting from cycles int the DFA.  This is a set of int state #s.
    # This is a side-effect of calling optimize; can't clear after use
    # because code gen needs it.
    attr_accessor :visited
    alias_method :attr_visited, :visited
    undef_method :visited
    alias_method :attr_visited=, :visited=
    undef_method :visited=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    typesig { [Grammar] }
    def initialize(grammar)
      @visited = HashSet.new
      @grammar = nil
      @grammar = grammar
    end
    
    typesig { [] }
    def optimize
      # optimize each DFA in this grammar
      decision_number = 1
      while decision_number <= @grammar.get_number_of_decisions
        dfa = @grammar.get_lookahead_dfa(decision_number)
        optimize(dfa)
        ((decision_number += 1) - 1)
      end
    end
    
    typesig { [DFA] }
    def optimize(dfa)
      if ((dfa).nil?)
        return # nothing to do
      end
      # 
      # System.out.println("Optimize DFA "+dfa.decisionNFAStartState.decisionNumber+
      # " num states="+dfa.getNumberOfStates());
      # 
      # long start = System.currentTimeMillis();
      if (self.attr_prune_ebnf_exit_branches && dfa.can_inline_decision)
        @visited.clear
        decision_type = dfa.get_nfadecision_start_state.attr_decision_state_type
        if (dfa.is_greedy && ((decision_type).equal?(NFAState::OPTIONAL_BLOCK_START) || (decision_type).equal?(NFAState::LOOPBACK)))
          optimize_exit_branches(dfa.attr_start_state)
        end
      end
      # If the Tokens rule has syntactically ambiguous rules, try to prune
      if (self.attr_prune_tokens_rule_superfluous_eot_edges && dfa.is_tokens_rule_decision && dfa.attr_probe.attr_state_to_syntactically_ambiguous_tokens_rule_alts_map.size > 0)
        @visited.clear
        optimize_eotbranches(dfa.attr_start_state)
      end
      # ack...code gen needs this, cannot optimize
      # visited.clear();
      # unlinkUnneededStateData(dfa.startState);
      # 
      # long stop = System.currentTimeMillis();
      # System.out.println("minimized in "+(int)(stop-start)+" ms");
    end
    
    typesig { [DFAState] }
    def optimize_exit_branches(d)
      s_i = Utils.integer(d.attr_state_number)
      if (@visited.contains(s_i))
        return # already visited
      end
      @visited.add(s_i)
      n_alts = d.attr_dfa.get_number_of_alts
      i = 0
      while i < d.get_number_of_transitions
        edge = d.transition(i)
        edge_target = (edge.attr_target)
        # 
        # System.out.println(d.stateNumber+"-"+
        # edge.label.toString(d.dfa.nfa.grammar)+"->"+
        # edgeTarget.stateNumber);
        # 
        # if target is an accept state and that alt is the exit alt
        if (edge_target.is_accept_state && (edge_target.get_uniquely_predicted_alt).equal?(n_alts))
          # 
          # System.out.println("ignoring transition "+i+" to max alt "+
          # d.dfa.getNumberOfAlts());
          d.remove_transition(i)
          ((i -= 1) + 1) # back up one so that i++ of loop iteration stays within bounds
        end
        optimize_exit_branches(edge_target)
        ((i += 1) - 1)
      end
    end
    
    typesig { [DFAState] }
    def optimize_eotbranches(d)
      s_i = Utils.integer(d.attr_state_number)
      if (@visited.contains(s_i))
        return # already visited
      end
      @visited.add(s_i)
      i = 0
      while i < d.get_number_of_transitions
        edge = d.transition(i)
        edge_target = (edge.attr_target)
        # 
        # System.out.println(d.stateNumber+"-"+
        # edge.label.toString(d.dfa.nfa.grammar)+"->"+
        # edgeTarget.stateNumber);
        # 
        # if only one edge coming out, it is EOT, and target is accept prune
        if (self.attr_prune_tokens_rule_superfluous_eot_edges && edge_target.is_accept_state && (d.get_number_of_transitions).equal?(1) && edge.attr_label.is_atom && (edge.attr_label.get_atom).equal?(Label::EOT))
          # System.out.println("state "+d+" can be pruned");
          # remove the superfluous EOT edge
          d.remove_transition(i)
          d.set_accept_state(true) # make it an accept state
          # force it to uniquely predict the originally predicted state
          d.attr_cached_uniquely_predicated_alt = edge_target.get_uniquely_predicted_alt
          ((i -= 1) + 1) # back up one so that i++ of loop iteration stays within bounds
        end
        optimize_eotbranches(edge_target)
        ((i += 1) - 1)
      end
    end
    
    private
    alias_method :initialize__dfaoptimizer, :initialize
  end
  
end
