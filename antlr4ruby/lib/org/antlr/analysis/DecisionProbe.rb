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
  module DecisionProbeImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :ErrorManager
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :GrammarAST
      include_const ::Org::Antlr::Tool, :ANTLRParser
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Misc, :MultiMap
      include ::Java::Util
      include_const ::Antlr, :Token
    }
  end
  
  # Collection of information about what is wrong with a decision as
  # discovered while building the DFA predictor.
  # 
  # The information is collected during NFA->DFA conversion and, while
  # some of this is available elsewhere, it is nice to have it all tracked
  # in one spot so a great error message can be easily had.  I also like
  # the fact that this object tracks it all for later perusing to make an
  # excellent error message instead of lots of imprecise on-the-fly warnings
  # (during conversion).
  # 
  # A decision normally only has one problem; e.g., some input sequence
  # can be matched by multiple alternatives.  Unfortunately, some decisions
  # such as
  # 
  # a : ( A | B ) | ( A | B ) | A ;
  # 
  # have multiple problems.  So in general, you should approach a decision
  # as having multiple flaws each one uniquely identified by a DFAState.
  # For example, statesWithSyntacticallyAmbiguousAltsSet tracks the set of
  # all DFAStates where ANTLR has discovered a problem.  Recall that a decision
  # is represented internall with a DFA comprised of multiple states, each of
  # which could potentially have problems.
  # 
  # Because of this, you need to iterate over this list of DFA states.  You'll
  # note that most of the informational methods like
  # getSampleNonDeterministicInputSequence() require a DFAState.  This state
  # will be one of the iterated states from stateToSyntacticallyAmbiguousAltsSet.
  # 
  # This class is not thread safe due to shared use of visited maps etc...
  # Only one thread should really need to access one DecisionProbe anyway.
  class DecisionProbe 
    include_class_members DecisionProbeImports
    
    attr_accessor :dfa
    alias_method :attr_dfa, :dfa
    undef_method :dfa
    alias_method :attr_dfa=, :dfa=
    undef_method :dfa=
    
    # Track all DFA states with nondeterministic alternatives.
    # By reaching the same DFA state, a path through the NFA for some input
    # is able to reach the same NFA state by starting at more than one
    # alternative's left edge.  Though, later, we may find that predicates
    # resolve the issue, but track info anyway.
    # Note that from the DFA state, you can ask for
    # which alts are nondeterministic.
    attr_accessor :states_with_syntactically_ambiguous_alts_set
    alias_method :attr_states_with_syntactically_ambiguous_alts_set, :states_with_syntactically_ambiguous_alts_set
    undef_method :states_with_syntactically_ambiguous_alts_set
    alias_method :attr_states_with_syntactically_ambiguous_alts_set=, :states_with_syntactically_ambiguous_alts_set=
    undef_method :states_with_syntactically_ambiguous_alts_set=
    
    # Track just like stateToSyntacticallyAmbiguousAltsMap, but only
    # for nondeterminisms that arise in the Tokens rule such as keyword vs
    # ID rule.  The state maps to the list of Tokens rule alts that are
    # in conflict.
    attr_accessor :state_to_syntactically_ambiguous_tokens_rule_alts_map
    alias_method :attr_state_to_syntactically_ambiguous_tokens_rule_alts_map, :state_to_syntactically_ambiguous_tokens_rule_alts_map
    undef_method :state_to_syntactically_ambiguous_tokens_rule_alts_map
    alias_method :attr_state_to_syntactically_ambiguous_tokens_rule_alts_map=, :state_to_syntactically_ambiguous_tokens_rule_alts_map=
    undef_method :state_to_syntactically_ambiguous_tokens_rule_alts_map=
    
    # Was a syntactic ambiguity resolved with predicates?  Any DFA
    # state that predicts more than one alternative, must be resolved
    # with predicates or it should be reported to the user.
    attr_accessor :states_resolved_with_semantic_predicates_set
    alias_method :attr_states_resolved_with_semantic_predicates_set, :states_resolved_with_semantic_predicates_set
    undef_method :states_resolved_with_semantic_predicates_set
    alias_method :attr_states_resolved_with_semantic_predicates_set=, :states_resolved_with_semantic_predicates_set=
    undef_method :states_resolved_with_semantic_predicates_set=
    
    # Track the predicates for each alt per DFA state;
    # more than one DFA state might have syntactically ambig alt prediction.
    # Maps DFA state to another map, mapping alt number to a
    # SemanticContext (pred(s) to execute to resolve syntactic ambiguity).
    attr_accessor :state_to_alt_set_with_semantic_predicates_map
    alias_method :attr_state_to_alt_set_with_semantic_predicates_map, :state_to_alt_set_with_semantic_predicates_map
    undef_method :state_to_alt_set_with_semantic_predicates_map
    alias_method :attr_state_to_alt_set_with_semantic_predicates_map=, :state_to_alt_set_with_semantic_predicates_map=
    undef_method :state_to_alt_set_with_semantic_predicates_map=
    
    # Tracks alts insufficiently covered.
    # For example, p1||true gets reduced to true and so leaves
    # whole alt uncovered.  This maps DFA state to the set of alts
    attr_accessor :state_to_incompletely_covered_alts_map
    alias_method :attr_state_to_incompletely_covered_alts_map, :state_to_incompletely_covered_alts_map
    undef_method :state_to_incompletely_covered_alts_map
    alias_method :attr_state_to_incompletely_covered_alts_map=, :state_to_incompletely_covered_alts_map=
    undef_method :state_to_incompletely_covered_alts_map=
    
    # The set of states w/o emanating edges and w/o resolving sem preds.
    attr_accessor :dangling_states
    alias_method :attr_dangling_states, :dangling_states
    undef_method :dangling_states
    alias_method :attr_dangling_states=, :dangling_states=
    undef_method :dangling_states=
    
    # The overall list of alts within the decision that have at least one
    # conflicting input sequence.
    attr_accessor :alts_with_problem
    alias_method :attr_alts_with_problem, :alts_with_problem
    undef_method :alts_with_problem
    alias_method :attr_alts_with_problem=, :alts_with_problem=
    undef_method :alts_with_problem=
    
    # If decision with > 1 alt has recursion in > 1 alt, it's nonregular
    # lookahead.  The decision cannot be made with a DFA.
    # the alts are stored in altsWithProblem.
    attr_accessor :non_llstar_decision
    alias_method :attr_non_llstar_decision, :non_llstar_decision
    undef_method :non_llstar_decision
    alias_method :attr_non_llstar_decision=, :non_llstar_decision=
    undef_method :non_llstar_decision=
    
    # Recursion is limited to a particular depth.  If that limit is exceeded
    # the proposed new NFAConfiguration is recorded for the associated DFA state.
    attr_accessor :state_to_recursion_overflow_configurations_map
    alias_method :attr_state_to_recursion_overflow_configurations_map, :state_to_recursion_overflow_configurations_map
    undef_method :state_to_recursion_overflow_configurations_map
    alias_method :attr_state_to_recursion_overflow_configurations_map=, :state_to_recursion_overflow_configurations_map=
    undef_method :state_to_recursion_overflow_configurations_map=
    
    # 
    # protected Map<Integer, List<NFAConfiguration>> stateToRecursionOverflowConfigurationsMap =
    # new HashMap<Integer, List<NFAConfiguration>>();
    # 
    # Left recursion discovered.  The proposed new NFAConfiguration
    # is recorded for the associated DFA state.
    # protected Map<Integer,List<NFAConfiguration>> stateToLeftRecursiveConfigurationsMap =
    # new HashMap<Integer,List<NFAConfiguration>>();
    # 
    # Did ANTLR have to terminate early on the analysis of this decision?
    attr_accessor :timed_out
    alias_method :attr_timed_out, :timed_out
    undef_method :timed_out
    alias_method :attr_timed_out=, :timed_out=
    undef_method :timed_out=
    
    # Used to find paths through syntactically ambiguous DFA. If we've
    # seen statement number before, what did we learn?
    attr_accessor :state_reachable
    alias_method :attr_state_reachable, :state_reachable
    undef_method :state_reachable
    alias_method :attr_state_reachable=, :state_reachable=
    undef_method :state_reachable=
    
    class_module.module_eval {
      const_set_lazy(:REACHABLE_BUSY) { Utils.integer(-1) }
      const_attr_reader  :REACHABLE_BUSY
      
      const_set_lazy(:REACHABLE_NO) { Utils.integer(0) }
      const_attr_reader  :REACHABLE_NO
      
      const_set_lazy(:REACHABLE_YES) { Utils.integer(1) }
      const_attr_reader  :REACHABLE_YES
    }
    
    # Used while finding a path through an NFA whose edge labels match
    # an input sequence.  Tracks the input position
    # we were at the last time at this node.  If same input position, then
    # we'd have reached same state without consuming input...probably an
    # infinite loop.  Stop.  Set<String>.  The strings look like
    # stateNumber_labelIndex.
    attr_accessor :states_visited_at_input_depth
    alias_method :attr_states_visited_at_input_depth, :states_visited_at_input_depth
    undef_method :states_visited_at_input_depth
    alias_method :attr_states_visited_at_input_depth=, :states_visited_at_input_depth=
    undef_method :states_visited_at_input_depth=
    
    attr_accessor :states_visited_during_sample_sequence
    alias_method :attr_states_visited_during_sample_sequence, :states_visited_during_sample_sequence
    undef_method :states_visited_during_sample_sequence
    alias_method :attr_states_visited_during_sample_sequence=, :states_visited_during_sample_sequence=
    undef_method :states_visited_during_sample_sequence=
    
    class_module.module_eval {
      
      def verbose
        defined?(@@verbose) ? @@verbose : @@verbose= false
      end
      alias_method :attr_verbose, :verbose
      
      def verbose=(value)
        @@verbose = value
      end
      alias_method :attr_verbose=, :verbose=
    }
    
    typesig { [DFA] }
    def initialize(dfa)
      @dfa = nil
      @states_with_syntactically_ambiguous_alts_set = HashSet.new
      @state_to_syntactically_ambiguous_tokens_rule_alts_map = HashMap.new
      @states_resolved_with_semantic_predicates_set = HashSet.new
      @state_to_alt_set_with_semantic_predicates_map = HashMap.new
      @state_to_incompletely_covered_alts_map = HashMap.new
      @dangling_states = HashSet.new
      @alts_with_problem = HashSet.new
      @non_llstar_decision = false
      @state_to_recursion_overflow_configurations_map = MultiMap.new
      @timed_out = false
      @state_reachable = nil
      @states_visited_at_input_depth = nil
      @states_visited_during_sample_sequence = nil
      @dfa = dfa
    end
    
    typesig { [] }
    # I N F O R M A T I O N  A B O U T  D E C I S I O N
    # Return a string like "3:22: ( A {;} | B )" that describes this
    # decision.
    def get_description
      return @dfa.get_nfadecision_start_state.get_description
    end
    
    typesig { [] }
    def is_reduced
      return @dfa.is_reduced
    end
    
    typesig { [] }
    def is_cyclic
      return @dfa.is_cyclic
    end
    
    typesig { [] }
    # If no states are dead-ends, no alts are unreachable, there are
    # no nondeterminisms unresolved by syn preds, all is ok with decision.
    def is_deterministic
      if ((@dangling_states.size).equal?(0) && (@states_with_syntactically_ambiguous_alts_set.size).equal?(0) && (@dfa.get_unreachable_alts.size).equal?(0))
        return true
      end
      if (@states_with_syntactically_ambiguous_alts_set.size > 0)
        it = @states_with_syntactically_ambiguous_alts_set.iterator
        while (it.has_next)
          d = it.next
          if (!@states_resolved_with_semantic_predicates_set.contains(d))
            return false
          end
        end
        # no syntactically ambig alts were left unresolved by predicates
        return true
      end
      return false
    end
    
    typesig { [] }
    # Did the analysis complete it's work?
    def analysis_timed_out
      return @timed_out
    end
    
    typesig { [] }
    # Took too long to analyze a DFA
    def analysis_overflowed
      return @state_to_recursion_overflow_configurations_map.size > 0
    end
    
    typesig { [] }
    # Found recursion in > 1 alt
    def is_non_llstar_decision
      return @non_llstar_decision
    end
    
    typesig { [] }
    # How many states does the DFA predictor have?
    def get_number_of_states
      return @dfa.get_number_of_states
    end
    
    typesig { [] }
    # Get a list of all unreachable alternatives for this decision.  There
    # may be multiple alternatives with ambiguous input sequences, but this
    # is the overall list of unreachable alternatives (either due to
    # conflict resolution or alts w/o accept states).
    def get_unreachable_alts
      return @dfa.get_unreachable_alts
    end
    
    typesig { [] }
    # return set of states w/o emanating edges and w/o resolving sem preds.
    # These states come about because the analysis algorithm had to
    # terminate early to avoid infinite recursion for example (due to
    # left recursion perhaps).
    def get_dangling_states
      return @dangling_states
    end
    
    typesig { [] }
    def get_non_deterministic_alts
      return @alts_with_problem
    end
    
    typesig { [DFAState] }
    # Return the sorted list of alts that conflict within a single state.
    # Note that predicates may resolve the conflict.
    def get_non_deterministic_alts_for_state(target_state)
      nondet_alts = target_state.get_non_deterministic_alts
      if ((nondet_alts).nil?)
        return nil
      end
      sorted = LinkedList.new
      sorted.add_all(nondet_alts)
      Collections.sort(sorted) # make sure it's 1, 2, ...
      return sorted
    end
    
    typesig { [] }
    # Return all DFA states in this DFA that have NFA configurations that
    # conflict.  You must report a problem for each state in this set
    # because each state represents a different input sequence.
    def get_dfastates_with_syntactically_ambiguous_alts
      return @states_with_syntactically_ambiguous_alts_set
    end
    
    typesig { [DFAState] }
    # Which alts were specifically turned off to resolve nondeterminisms?
    # This is different than the unreachable alts.  Disabled doesn't mean that
    # the alternative is totally unreachable necessarily, it just means
    # that for this DFA state, that alt is disabled.  There may be other
    # accept states for that alt that make an alt reachable.
    def get_disabled_alternatives(d)
      return d.get_disabled_alternatives
    end
    
    typesig { [DFAState] }
    # If a recursion overflow is resolve with predicates, then we need
    # to shut off the warning that would be generated.
    def remove_recursive_overflow_state(d)
      state_i = Utils.integer(d.attr_state_number)
      @state_to_recursion_overflow_configurations_map.remove(state_i)
    end
    
    typesig { [DFAState] }
    # Return a List<Label> indicating an input sequence that can be matched
    # from the start state of the DFA to the targetState (which is known
    # to have a problem).
    def get_sample_non_deterministic_input_sequence(target_state)
      dfa_states = get_dfapath_states_to_target(target_state)
      @states_visited_during_sample_sequence = HashSet.new
      labels = ArrayList.new # may access ith element; use array
      if ((@dfa).nil? || (@dfa.attr_start_state).nil?)
        return labels
      end
      get_sample_input_sequence_using_state_set(@dfa.attr_start_state, target_state, dfa_states, labels)
      return labels
    end
    
    typesig { [JavaList] }
    # Given List<Label>, return a String with a useful representation
    # of the associated input string.  One could show something different
    # for lexers and parsers, for example.
    def get_input_sequence_display(labels)
      g = @dfa.attr_nfa.attr_grammar
      buf = StringBuffer.new
      it = labels.iterator
      while it.has_next
        label = it.next
        buf.append(label.to_s(g))
        if (it.has_next && !(g.attr_type).equal?(Grammar::LEXER))
          buf.append(Character.new(?\s.ord))
        end
      end
      return buf.to_s
    end
    
    typesig { [::Java::Int, ::Java::Int, JavaList] }
    # Given an alternative associated with a nondeterministic DFA state,
    # find the path of NFA states associated with the labels sequence.
    # Useful tracing where in the NFA, a single input sequence can be
    # matched.  For different alts, you should get different NFA paths.
    # 
    # The first NFA state for all NFA paths will be the same: the starting
    # NFA state of the first nondeterministic alt.  Imagine (A|B|A|A):
    # 
    # 5->9-A->o
    # |
    # 6->10-B->o
    # |
    # 7->11-A->o
    # |
    # 8->12-A->o
    # 
    # There are 3 nondeterministic alts.  The paths should be:
    # 5 9 ...
    # 5 6 7 11 ...
    # 5 6 7 8 12 ...
    # 
    # The NFA path matching the sample input sequence (labels) is computed
    # using states 9, 11, and 12 rather than 5, 7, 8 because state 5, for
    # example can get to all ambig paths.  Must isolate for each alt (hence,
    # the extra state beginning each alt in my NFA structures).  Here,
    # firstAlt=1.
    def get_nfapath_states_for_alt(first_alt, alt, labels)
      nfa_start = @dfa.get_nfadecision_start_state
      path = LinkedList.new
      # first add all NFA states leading up to altStart state
      a = first_alt
      while a <= alt
        s = @dfa.attr_nfa.attr_grammar.get_nfastate_for_alt_of_decision(nfa_start, a)
        path.add(s)
        ((a += 1) - 1)
      end
      # add first state of actual alt
      alt_start = @dfa.attr_nfa.attr_grammar.get_nfastate_for_alt_of_decision(nfa_start, alt)
      isolated_alt_start = alt_start.attr_transition[0].attr_target
      path.add(isolated_alt_start)
      # add the actual path now
      @states_visited_at_input_depth = HashSet.new
      get_nfapath(isolated_alt_start, 0, labels, path)
      return path
    end
    
    typesig { [DFAState, ::Java::Int] }
    # Each state in the DFA represents a different input sequence for an
    # alt of the decision.  Given a DFA state, what is the semantic
    # predicate context for a particular alt.
    def get_semantic_context_for_alt(d, alt)
      alt_to_pred_map = @state_to_alt_set_with_semantic_predicates_map.get(d)
      if ((alt_to_pred_map).nil?)
        return nil
      end
      return alt_to_pred_map.get(Utils.integer(alt))
    end
    
    typesig { [] }
    # At least one alt refs a sem or syn pred
    def has_predicate
      return @state_to_alt_set_with_semantic_predicates_map.size > 0
    end
    
    typesig { [] }
    def get_nondeterministic_states_resolved_with_semantic_predicate
      return @states_resolved_with_semantic_predicates_set
    end
    
    typesig { [DFAState] }
    # Return a list of alts whose predicate context was insufficient to
    # resolve a nondeterminism for state d.
    def get_incompletely_covered_alts(d)
      return @state_to_incompletely_covered_alts_map.get(d)
    end
    
    typesig { [] }
    def issue_warnings
      # NONREGULAR DUE TO RECURSION > 1 ALTS
      # Issue this before aborted analysis, which might also occur
      # if we take too long to terminate
      if (@non_llstar_decision && !@dfa.get_auto_backtrack_mode)
        ErrorManager.non_llstar_decision(self)
      end
      if (analysis_timed_out)
        # only report early termination errors if !backtracking
        if (!@dfa.get_auto_backtrack_mode)
          ErrorManager.analysis_aborted(self)
        end
        # now just return...if we bailed out, don't spew other messages
        return
      end
      issue_recursion_warnings
      # generate a separate message for each problem state in DFA
      resolved_states = get_nondeterministic_states_resolved_with_semantic_predicate
      problem_states = get_dfastates_with_syntactically_ambiguous_alts
      if (problem_states.size > 0)
        it = problem_states.iterator
        while (it.has_next && !@dfa.attr_nfa.attr_grammar._nfato_dfaconversion_externally_aborted)
          d = it.next
          insufficient_alt_to_locations = get_incompletely_covered_alts(d)
          if (!(insufficient_alt_to_locations).nil? && insufficient_alt_to_locations.size > 0)
            ErrorManager.insufficient_predicates(self, d, insufficient_alt_to_locations)
          end
          # don't report problem if resolved
          if ((resolved_states).nil? || !resolved_states.contains(d))
            # first strip last alt from disableAlts if it's wildcard
            # then don't print error if no more disable alts
            disabled_alts = get_disabled_alternatives(d)
            strip_wild_card_alts(disabled_alts)
            if (disabled_alts.size > 0)
              ErrorManager.nondeterminism(self, d)
            end
          end
        end
      end
      dangling_states = get_dangling_states
      if (dangling_states.size > 0)
        # System.err.println("no emanating edges for states: "+danglingStates);
        it_ = dangling_states.iterator
        while it_.has_next
          d_ = it_.next
          ErrorManager.dangling_state(self, d_)
        end
      end
      if (!@non_llstar_decision)
        unreachable_alts = @dfa.get_unreachable_alts
        if (!(unreachable_alts).nil? && unreachable_alts.size > 0)
          # give different msg if it's an empty Tokens rule from delegate
          is_inherited_tokens_rule = false
          if (@dfa.is_tokens_rule_decision)
            unreachable_alts.each do |altI|
              dec_ast = @dfa.get_decision_astnode
              alt_ast = dec_ast.get_child(alt_i - 1)
              delegated_tokens_alt = alt_ast.get_first_child_with_type(ANTLRParser::DOT)
              if (!(delegated_tokens_alt).nil?)
                is_inherited_tokens_rule = true
                ErrorManager.grammar_warning(ErrorManager::MSG_IMPORTED_TOKENS_RULE_EMPTY, @dfa.attr_nfa.attr_grammar, nil, @dfa.attr_nfa.attr_grammar.attr_name, delegated_tokens_alt.get_first_child.get_text)
              end
            end
          end
          if (is_inherited_tokens_rule)
          else
            ErrorManager.unreachable_alts(self, unreachable_alts)
          end
        end
      end
    end
    
    typesig { [JavaSet] }
    # Get the last disabled alt number and check in the grammar to see
    # if that alt is a simple wildcard.  If so, treat like an else clause
    # and don't emit the error.  Strip out the last alt if it's wildcard.
    def strip_wild_card_alts(disabled_alts)
      sorted_disable_alts = ArrayList.new(disabled_alts)
      Collections.sort(sorted_disable_alts)
      last_alt = sorted_disable_alts.get(sorted_disable_alts.size - 1)
      block_ast = @dfa.attr_nfa.attr_grammar.get_decision_block_ast(@dfa.attr_decision_number)
      # System.out.println("block with error = "+blockAST.toStringTree());
      last_alt_ast = nil
      if ((block_ast.get_child(0).get_type).equal?(ANTLRParser::OPTIONS))
        # if options, skip first child: ( options { ( = greedy false ) )
        last_alt_ast = block_ast.get_child(last_alt.int_value)
      else
        last_alt_ast = block_ast.get_child(last_alt.int_value - 1)
      end
      # System.out.println("last alt is "+lastAltAST.toStringTree());
      # if last alt looks like ( ALT . <end-of-alt> ) then wildcard
      # Avoid looking at optional blocks etc... that have last alt
      # as the EOB:
      # ( BLOCK ( ALT 'else' statement <end-of-alt> ) <end-of-block> )
      if (!(last_alt_ast.get_type).equal?(ANTLRParser::EOB) && (last_alt_ast.get_child(0).get_type).equal?(ANTLRParser::WILDCARD) && (last_alt_ast.get_child(1).get_type).equal?(ANTLRParser::EOA))
        # System.out.println("wildcard");
        disabled_alts.remove(last_alt)
      end
    end
    
    typesig { [] }
    def issue_recursion_warnings
      # RECURSION OVERFLOW
      dfa_states_with_recursion_problems = @state_to_recursion_overflow_configurations_map.key_set
      # now walk truly unique (unaliased) list of dfa states with inf recur
      # Goal: create a map from alt to map<target,List<callsites>>
      # Map<Map<String target, List<NFAState call sites>>
      alt_to_target_to_call_sites_map = HashMap.new
      # track a single problem DFA state for each alt
      alt_to_dfastate = HashMap.new
      # output param
      compute_alt_to_problem_maps(dfa_states_with_recursion_problems, @state_to_recursion_overflow_configurations_map, alt_to_target_to_call_sites_map, alt_to_dfastate) # output param
      # walk each alt with recursion overflow problems and generate error
      alts = alt_to_target_to_call_sites_map.key_set
      sorted_alts = ArrayList.new(alts)
      Collections.sort(sorted_alts)
      alts_it = sorted_alts.iterator
      while alts_it.has_next
        alt_i = alts_it.next
        target_to_call_site_map = alt_to_target_to_call_sites_map.get(alt_i)
        target_rules = target_to_call_site_map.key_set
        call_site_states = target_to_call_site_map.values
        sample_bad_state = alt_to_dfastate.get(alt_i)
        ErrorManager.recursion_overflow(self, sample_bad_state, alt_i.int_value, target_rules, call_site_states)
      end
    end
    
    typesig { [JavaSet, Map, Map, Map] }
    def compute_alt_to_problem_maps(dfa_states_unaliased, configurations_map, alt_to_target_to_call_sites_map, alt_to_dfastate)
      it = dfa_states_unaliased.iterator
      while it.has_next
        state_i = it.next
        # walk this DFA's config list
        configs = configurations_map.get(state_i)
        i = 0
        while i < configs.size
          c = configs.get(i)
          rule_invocation_state = @dfa.attr_nfa.get_state(c.attr_state)
          transition0 = rule_invocation_state.attr_transition[0]
          ref = transition0
          target_rule = (ref.attr_target).attr_enclosing_rule.attr_name
          alt_i = Utils.integer(c.attr_alt)
          target_to_call_site_map = alt_to_target_to_call_sites_map.get(alt_i)
          if ((target_to_call_site_map).nil?)
            target_to_call_site_map = HashMap.new
            alt_to_target_to_call_sites_map.put(alt_i, target_to_call_site_map)
          end
          call_sites = target_to_call_site_map.get(target_rule)
          if ((call_sites).nil?)
            call_sites = HashSet.new
            target_to_call_site_map.put(target_rule, call_sites)
          end
          call_sites.add(rule_invocation_state)
          # track one problem DFA state per alt
          if ((alt_to_dfastate.get(alt_i)).nil?)
            sample_bad_state = @dfa.get_state(state_i.int_value)
            alt_to_dfastate.put(alt_i, sample_bad_state)
          end
          ((i += 1) - 1)
        end
      end
    end
    
    typesig { [JavaSet] }
    def get_unaliased_dfastate_set(dfa_states_with_recursion_problems)
      dfa_states_unaliased = HashSet.new
      it = dfa_states_with_recursion_problems.iterator
      while it.has_next
        state_i = it.next
        d = @dfa.get_state(state_i.int_value)
        dfa_states_unaliased.add(Utils.integer(d.attr_state_number))
      end
      return dfa_states_unaliased
    end
    
    typesig { [DFAState] }
    # T R A C K I N G  M E T H O D S
    # Report the fact that DFA state d is not a state resolved with
    # predicates and yet it has no emanating edges.  Usually this
    # is a result of the closure/reach operations being unable to proceed
    def report_dangling_state(d)
      @dangling_states.add(d)
    end
    
    typesig { [] }
    def report_analysis_timeout
      @timed_out = true
      @dfa.attr_nfa.attr_grammar.attr_set_of_dfawhose_analysis_timed_out.add(@dfa)
    end
    
    typesig { [DFA] }
    # Report that at least 2 alts have recursive constructs.  There is
    # no way to build a DFA so we terminated.
    def report_non_llstar_decision(dfa)
      # 
      # System.out.println("non-LL(*) DFA "+dfa.decisionNumber+", alts: "+
      # dfa.recursiveAltSet.toList());
      @non_llstar_decision = true
      @alts_with_problem.add_all(dfa.attr_recursive_alt_set.to_list)
    end
    
    typesig { [DFAState, NFAConfiguration] }
    def report_recursion_overflow(d, recursion_nfaconfiguration)
      # track the state number rather than the state as d will change
      # out from underneath us; hash wouldn't return any value
      # left-recursion is detected in start state.  Since we can't
      # call resolveNondeterminism() on the start state (it would
      # not look k=1 to get min single token lookahead), we must
      # prevent errors derived from this state.  Avoid start state
      if (d.attr_state_number > 0)
        state_i = Utils.integer(d.attr_state_number)
        @state_to_recursion_overflow_configurations_map.map(state_i, recursion_nfaconfiguration)
      end
    end
    
    typesig { [DFAState, JavaSet] }
    def report_nondeterminism(d, nondeterministic_alts)
      @alts_with_problem.add_all(nondeterministic_alts) # track overall list
      @states_with_syntactically_ambiguous_alts_set.add(d)
      @dfa.attr_nfa.attr_grammar.attr_set_of_nondeterministic_decision_numbers.add(Utils.integer(@dfa.get_decision_number))
    end
    
    typesig { [DFAState, JavaSet] }
    # Currently the analysis reports issues between token definitions, but
    # we don't print out warnings in favor of just picking the first token
    # definition found in the grammar ala lex/flex.
    def report_lexer_rule_nondeterminism(d, nondeterministic_alts)
      @state_to_syntactically_ambiguous_tokens_rule_alts_map.put(d, nondeterministic_alts)
    end
    
    typesig { [DFAState] }
    def report_nondeterminism_resolved_with_semantic_predicate(d)
      # First, prevent a recursion warning on this state due to
      # pred resolution
      if (d.attr_aborted_due_to_recursion_overflow)
        d.attr_dfa.attr_probe.remove_recursive_overflow_state(d)
      end
      @states_resolved_with_semantic_predicates_set.add(d)
      # System.out.println("resolved with pred: "+d);
      @dfa.attr_nfa.attr_grammar.attr_set_of_nondeterministic_decision_numbers_resolved_with_predicates.add(Utils.integer(@dfa.get_decision_number))
    end
    
    typesig { [DFAState, Map] }
    # Report the list of predicates found for each alternative; copy
    # the list because this set gets altered later by the method
    # tryToResolveWithSemanticPredicates() while flagging NFA configurations
    # in d as resolved.
    def report_alt_predicate_context(d, alt_predicate_context)
      copy = HashMap.new
      copy.put_all(alt_predicate_context)
      @state_to_alt_set_with_semantic_predicates_map.put(d, copy)
    end
    
    typesig { [DFAState, Map] }
    def report_incompletely_covered_alts(d, alt_to_locations_reachable_without_predicate)
      @state_to_incompletely_covered_alts_map.put(d, alt_to_locations_reachable_without_predicate)
    end
    
    typesig { [DFAState, DFAState, JavaSet] }
    # S U P P O R T
    # Given a start state and a target state, return true if start can reach
    # target state.  Also, compute the set of DFA states
    # that are on a path from start to target; return in states parameter.
    def reaches_state(start_state, target_state, states)
      if ((start_state).equal?(target_state))
        states.add(target_state)
        # System.out.println("found target DFA state "+targetState.getStateNumber());
        @state_reachable.put(start_state.attr_state_number, REACHABLE_YES)
        return true
      end
      s = start_state
      # avoid infinite loops
      @state_reachable.put(s.attr_state_number, REACHABLE_BUSY)
      # look for a path to targetState among transitions for this state
      # stop when you find the first one; I'm pretty sure there is
      # at most one path to any DFA state with conflicting predictions
      i = 0
      while i < s.get_number_of_transitions
        t = s.transition(i)
        edge_target = t.attr_target
        target_status = @state_reachable.get(edge_target.attr_state_number)
        if ((target_status).equal?(REACHABLE_BUSY))
          # avoid cycles; they say nothing
          ((i += 1) - 1)
          next
        end
        if ((target_status).equal?(REACHABLE_YES))
          # return success!
          @state_reachable.put(s.attr_state_number, REACHABLE_YES)
          return true
        end
        if ((target_status).equal?(REACHABLE_NO))
          # try another transition
          ((i += 1) - 1)
          next
        end
        # if null, target must be REACHABLE_UNKNOWN (i.e., unvisited)
        if (reaches_state(edge_target, target_state, states))
          states.add(s)
          @state_reachable.put(s.attr_state_number, REACHABLE_YES)
          return true
        end
        ((i += 1) - 1)
      end
      @state_reachable.put(s.attr_state_number, REACHABLE_NO)
      return false # no path to targetState found.
    end
    
    typesig { [DFAState] }
    def get_dfapath_states_to_target(target_state)
      dfa_states = HashSet.new
      @state_reachable = HashMap.new
      if ((@dfa).nil? || (@dfa.attr_start_state).nil?)
        return dfa_states
      end
      reaches = reaches_state(@dfa.attr_start_state, target_state, dfa_states)
      return dfa_states
    end
    
    typesig { [State, State, JavaSet, JavaList] }
    # Given a start state and a final state, find a list of edge labels
    # between the two ignoring epsilon.  Limit your scan to a set of states
    # passed in.  This is used to show a sample input sequence that is
    # nondeterministic with respect to this decision.  Return List<Label> as
    # a parameter.  The incoming states set must be all states that lead
    # from startState to targetState and no others so this algorithm doesn't
    # take a path that eventually leads to a state other than targetState.
    # Don't follow loops, leading to short (possibly shortest) path.
    def get_sample_input_sequence_using_state_set(start_state, target_state, states, labels)
      @states_visited_during_sample_sequence.add(start_state.attr_state_number)
      # pick the first edge in states as the one to traverse
      i = 0
      while i < start_state.get_number_of_transitions
        t = start_state.transition(i)
        edge_target = t.attr_target
        if (states.contains(edge_target) && !@states_visited_during_sample_sequence.contains(edge_target.attr_state_number))
          labels.add(t.attr_label) # traverse edge and track label
          if (!(edge_target).equal?(target_state))
            # get more labels if not at target
            get_sample_input_sequence_using_state_set(edge_target, target_state, states, labels)
          end
          # done with this DFA state as we've found a good path to target
          return
        end
        ((i += 1) - 1)
      end
      labels.add(Label.new(Label::EPSILON)) # indicate no input found
      # this happens on a : {p1}? a | A ;
      # ErrorManager.error(ErrorManager.MSG_CANNOT_COMPUTE_SAMPLE_INPUT_SEQ);
    end
    
    typesig { [NFAState, ::Java::Int, JavaList, JavaList] }
    # Given a sample input sequence, you usually would like to know the
    # path taken through the NFA.  Return the list of NFA states visited
    # while matching a list of labels.  This cannot use the usual
    # interpreter, which does a deterministic walk.  We need to be able to
    # take paths that are turned off during nondeterminism resolution. So,
    # just do a depth-first walk traversing edges labeled with the current
    # label.  Return true if a path was found emanating from state s.
    # 
    # starting where?
    # 0..labels.size()-1
    # input sequence
    def get_nfapath(s, label_index, labels, path)
      # output list of NFA states
      # track a visit to state s at input index labelIndex if not seen
      this_state_key = get_state_label_index_key(s.attr_state_number, label_index)
      if (@states_visited_at_input_depth.contains(this_state_key))
        # 
        # System.out.println("### already visited "+s.stateNumber+" previously at index "+
        # labelIndex);
        return false
      end
      @states_visited_at_input_depth.add(this_state_key)
      # 
      # System.out.println("enter state "+s.stateNumber+" visited states: "+
      # statesVisitedAtInputDepth);
      # 
      # pick the first edge whose target is in states and whose
      # label is labels[labelIndex]
      i = 0
      while i < s.get_number_of_transitions
        t = s.attr_transition[i]
        edge_target = t.attr_target
        label = labels.get(label_index)
        # 
        # System.out.println(s.stateNumber+"-"+
        # t.label.toString(dfa.nfa.grammar)+"->"+
        # edgeTarget.stateNumber+" =="+
        # label.toString(dfa.nfa.grammar)+"?");
        if (t.attr_label.is_epsilon || t.attr_label.is_semantic_predicate)
          # nondeterministically backtrack down epsilon edges
          path.add(edge_target)
          found = get_nfapath(edge_target, label_index, labels, path)
          if (found)
            @states_visited_at_input_depth.remove(this_state_key)
            return true # return to "calling" state
          end
          path.remove(path.size - 1) # remove; didn't work out
          ((i += 1) - 1)
          next # look at the next edge
        end
        if (t.attr_label.matches(label))
          path.add(edge_target)
          # 
          # System.out.println("found label "+
          # t.label.toString(dfa.nfa.grammar)+
          # " at state "+s.stateNumber+"; labelIndex="+labelIndex);
          if ((label_index).equal?(labels.size - 1))
            # found last label; done!
            @states_visited_at_input_depth.remove(this_state_key)
            return true
          end
          # otherwise try to match remaining input
          found_ = get_nfapath(edge_target, label_index + 1, labels, path)
          if (found_)
            @states_visited_at_input_depth.remove(this_state_key)
            return true
          end
          # 
          # System.out.println("backtrack; path from "+s.stateNumber+"->"+
          # t.label.toString(dfa.nfa.grammar)+" didn't work");
          path.remove(path.size - 1) # remove; didn't work out
          ((i += 1) - 1)
          next # keep looking for a path for labels
        end
        ((i += 1) - 1)
      end
      # System.out.println("no epsilon or matching edge; removing "+thisStateKey);
      # no edge was found matching label; is ok, some state will have it
      @states_visited_at_input_depth.remove(this_state_key)
      return false
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def get_state_label_index_key(s, i)
      buf = StringBuffer.new
      buf.append(s)
      buf.append(Character.new(?_.ord))
      buf.append(i)
      return buf.to_s
    end
    
    typesig { [::Java::Int] }
    # From an alt number associated with artificial Tokens rule, return
    # the name of the token that is associated with that alt.
    def get_token_name_for_tokens_rule_alt(alt)
      decision_state = @dfa.get_nfadecision_start_state
      alt_state = @dfa.attr_nfa.attr_grammar.get_nfastate_for_alt_of_decision(decision_state, alt)
      decision_left = alt_state.attr_transition[0].attr_target
      rule_call_edge = decision_left.attr_transition[0]
      rule_start_state = rule_call_edge.attr_target
      # System.out.println("alt = "+decisionLeft.getEnclosingRule());
      return rule_start_state.attr_enclosing_rule.attr_name
    end
    
    typesig { [] }
    def reset
      @state_to_recursion_overflow_configurations_map.clear
    end
    
    private
    alias_method :initialize__decision_probe, :initialize
  end
  
end
