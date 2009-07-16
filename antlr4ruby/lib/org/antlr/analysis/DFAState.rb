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
  module DFAStateImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :IntSet
      include_const ::Org::Antlr::Misc, :MultiMap
      include_const ::Org::Antlr::Misc, :OrderedHashSet
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Tool, :Grammar
      include ::Java::Util
    }
  end
  
  # A DFA state represents a set of possible NFA configurations.
  # As Aho, Sethi, Ullman p. 117 says "The DFA uses its state
  # to keep track of all possible states the NFA can be in after
  # reading each input symbol.  That is to say, after reading
  # input a1a2..an, the DFA is in a state that represents the
  # subset T of the states of the NFA that are reachable from the
  # NFA's start state along some path labeled a1a2..an."
  # In conventional NFA->DFA conversion, therefore, the subset T
  # would be a bitset representing the set of states the
  # NFA could be in.  We need to track the alt predicted by each
  # state as well, however.  More importantly, we need to maintain
  # a stack of states, tracking the closure operations as they
  # jump from rule to rule, emulating rule invocations (method calls).
  # Recall that NFAs do not normally have a stack like a pushdown-machine
  # so I have to add one to simulate the proper lookahead sequences for
  # the underlying LL grammar from which the NFA was derived.
  # 
  # I use a list of NFAConfiguration objects.  An NFAConfiguration
  # is both a state (ala normal conversion) and an NFAContext describing
  # the chain of rules (if any) followed to arrive at that state.  There
  # is also the semantic context, which is the "set" of predicates found
  # on the path to this configuration.
  # 
  # A DFA state may have multiple references to a particular state,
  # but with different NFAContexts (with same or different alts)
  # meaning that state was reached via a different set of rule invocations.
  class DFAState < DFAStateImports.const_get :State
    include_class_members DFAStateImports
    
    class_module.module_eval {
      const_set_lazy(:INITIAL_NUM_TRANSITIONS) { 4 }
      const_attr_reader  :INITIAL_NUM_TRANSITIONS
      
      const_set_lazy(:PREDICTED_ALT_UNSET) { NFA::INVALID_ALT_NUMBER - 1 }
      const_attr_reader  :PREDICTED_ALT_UNSET
    }
    
    # We are part of what DFA?  Use this ref to get access to the
    # context trees for an alt.
    attr_accessor :dfa
    alias_method :attr_dfa, :dfa
    undef_method :dfa
    alias_method :attr_dfa=, :dfa=
    undef_method :dfa=
    
    # Track the transitions emanating from this DFA state.  The List
    # elements are Transition objects.
    attr_accessor :transitions
    alias_method :attr_transitions, :transitions
    undef_method :transitions
    alias_method :attr_transitions=, :transitions=
    undef_method :transitions=
    
    # When doing an acyclic DFA, this is the number of lookahead symbols
    # consumed to reach this state.  This value may be nonzero for most
    # dfa states, but it is only a valid value if the user has specified
    # a max fixed lookahead.
    attr_accessor :k
    alias_method :attr_k, :k
    undef_method :k
    alias_method :attr_k=, :k=
    undef_method :k=
    
    # The NFA->DFA algorithm may terminate leaving some states
    # without a path to an accept state, implying that upon certain
    # input, the decision is not deterministic--no decision about
    # predicting a unique alternative can be made.  Recall that an
    # accept state is one in which a unique alternative is predicted.
    attr_accessor :accept_state_reachable
    alias_method :attr_accept_state_reachable, :accept_state_reachable
    undef_method :accept_state_reachable
    alias_method :attr_accept_state_reachable=, :accept_state_reachable=
    undef_method :accept_state_reachable=
    
    # Rather than recheck every NFA configuration in a DFA state (after
    # resolving) in findNewDFAStatesAndAddDFATransitions just check
    # this boolean.  Saves a linear walk perhaps DFA state creation.
    # Every little bit helps.
    attr_accessor :resolved_with_predicates
    alias_method :attr_resolved_with_predicates, :resolved_with_predicates
    undef_method :resolved_with_predicates
    alias_method :attr_resolved_with_predicates=, :resolved_with_predicates=
    undef_method :resolved_with_predicates=
    
    # If a closure operation finds that we tried to invoke the same
    # rule too many times (stack would grow beyond a threshold), it
    # marks the state has aborted and notifies the DecisionProbe.
    attr_accessor :aborted_due_to_recursion_overflow
    alias_method :attr_aborted_due_to_recursion_overflow, :aborted_due_to_recursion_overflow
    undef_method :aborted_due_to_recursion_overflow
    alias_method :attr_aborted_due_to_recursion_overflow=, :aborted_due_to_recursion_overflow=
    undef_method :aborted_due_to_recursion_overflow=
    
    # If we detect recursion on more than one alt, decision is non-LL(*),
    # but try to isolate it to only those states whose closure operations
    # detect recursion.  There may be other alts that are cool:
    # 
    # a : recur '.'
    # | recur ';'
    # | X Y  // LL(2) decision; don't abort and use k=1 plus backtracking
    # | X Z
    # ;
    # 
    # 12/13/2007: Actually this has caused problems.  If k=*, must terminate
    # and throw out entire DFA; retry with k=1.  Since recursive, do not
    # attempt more closure ops as it may take forever.  Exception thrown
    # now and we simply report the problem.  If synpreds exist, I'll retry
    # with k=1.
    attr_accessor :aborted_due_to_multiple_recursive_alts
    alias_method :attr_aborted_due_to_multiple_recursive_alts, :aborted_due_to_multiple_recursive_alts
    undef_method :aborted_due_to_multiple_recursive_alts
    alias_method :attr_aborted_due_to_multiple_recursive_alts=, :aborted_due_to_multiple_recursive_alts=
    undef_method :aborted_due_to_multiple_recursive_alts=
    
    # Build up the hash code for this state as NFA configurations
    # are added as it's monotonically increasing list of configurations.
    attr_accessor :cached_hash_code
    alias_method :attr_cached_hash_code, :cached_hash_code
    undef_method :cached_hash_code
    alias_method :attr_cached_hash_code=, :cached_hash_code=
    undef_method :cached_hash_code=
    
    attr_accessor :cached_uniquely_predicated_alt
    alias_method :attr_cached_uniquely_predicated_alt, :cached_uniquely_predicated_alt
    undef_method :cached_uniquely_predicated_alt
    alias_method :attr_cached_uniquely_predicated_alt=, :cached_uniquely_predicated_alt=
    undef_method :cached_uniquely_predicated_alt=
    
    attr_accessor :min_alt_in_configurations
    alias_method :attr_min_alt_in_configurations, :min_alt_in_configurations
    undef_method :min_alt_in_configurations
    alias_method :attr_min_alt_in_configurations=, :min_alt_in_configurations=
    undef_method :min_alt_in_configurations=
    
    attr_accessor :at_least_one_configuration_has_apredicate
    alias_method :attr_at_least_one_configuration_has_apredicate, :at_least_one_configuration_has_apredicate
    undef_method :at_least_one_configuration_has_apredicate
    alias_method :attr_at_least_one_configuration_has_apredicate=, :at_least_one_configuration_has_apredicate=
    undef_method :at_least_one_configuration_has_apredicate=
    
    # The set of NFA configurations (state,alt,context) for this DFA state
    attr_accessor :nfa_configurations
    alias_method :attr_nfa_configurations, :nfa_configurations
    undef_method :nfa_configurations
    alias_method :attr_nfa_configurations=, :nfa_configurations=
    undef_method :nfa_configurations=
    
    attr_accessor :configurations_with_labeled_edges
    alias_method :attr_configurations_with_labeled_edges, :configurations_with_labeled_edges
    undef_method :configurations_with_labeled_edges
    alias_method :attr_configurations_with_labeled_edges=, :configurations_with_labeled_edges=
    undef_method :configurations_with_labeled_edges=
    
    # Used to prevent the closure operation from looping to itself and
    # hence looping forever.  Sensitive to the NFA state, the alt, and
    # the stack context.  This just the nfa config set because we want to
    # prevent closures only on states contributed by closure not reach
    # operations.
    # 
    # Two configurations identical including semantic context are
    # considered the same closure computation.  @see NFAToDFAConverter.closureBusy().
    attr_accessor :closure_busy
    alias_method :attr_closure_busy, :closure_busy
    undef_method :closure_busy
    alias_method :attr_closure_busy=, :closure_busy=
    undef_method :closure_busy=
    
    # As this state is constructed (i.e., as NFA states are added), we
    # can easily check for non-epsilon transitions because the only
    # transition that could be a valid label is transition(0).  When we
    # process this node eventually, we'll have to walk all states looking
    # for all possible transitions.  That is of the order: size(label space)
    # times size(nfa states), which can be pretty damn big.  It's better
    # to simply track possible labels.
    attr_accessor :reachable_labels
    alias_method :attr_reachable_labels, :reachable_labels
    undef_method :reachable_labels
    alias_method :attr_reachable_labels=, :reachable_labels=
    undef_method :reachable_labels=
    
    typesig { [DFA] }
    def initialize(dfa)
      @dfa = nil
      @transitions = nil
      @k = 0
      @accept_state_reachable = 0
      @resolved_with_predicates = false
      @aborted_due_to_recursion_overflow = false
      @aborted_due_to_multiple_recursive_alts = false
      @cached_hash_code = 0
      @cached_uniquely_predicated_alt = 0
      @min_alt_in_configurations = 0
      @at_least_one_configuration_has_apredicate = false
      @nfa_configurations = nil
      @configurations_with_labeled_edges = nil
      @closure_busy = nil
      @reachable_labels = nil
      super()
      @transitions = ArrayList.new(INITIAL_NUM_TRANSITIONS)
      @accept_state_reachable = DFA::REACHABLE_UNKNOWN
      @resolved_with_predicates = false
      @aborted_due_to_recursion_overflow = false
      @aborted_due_to_multiple_recursive_alts = false
      @cached_uniquely_predicated_alt = PREDICTED_ALT_UNSET
      @min_alt_in_configurations = JavaInteger::MAX_VALUE
      @at_least_one_configuration_has_apredicate = false
      @nfa_configurations = OrderedHashSet.new
      @configurations_with_labeled_edges = ArrayList.new
      @closure_busy = HashSet.new
      @dfa = dfa
    end
    
    typesig { [] }
    def reset
      # nfaConfigurations = null; // getGatedPredicatesInNFAConfigurations needs
      @configurations_with_labeled_edges = nil
      @closure_busy = nil
      @reachable_labels = nil
    end
    
    typesig { [::Java::Int] }
    def transition(i)
      return @transitions.get(i)
    end
    
    typesig { [] }
    def get_number_of_transitions
      return @transitions.size
    end
    
    typesig { [Transition] }
    def add_transition(t)
      @transitions.add(t)
    end
    
    typesig { [DFAState, Label] }
    # Add a transition from this state to target with label.  Return
    # the transition number from 0..n-1.
    def add_transition(target, label)
      @transitions.add(Transition.new(label, target))
      return @transitions.size - 1
    end
    
    typesig { [::Java::Int] }
    def get_transition(trans)
      return @transitions.get(trans)
    end
    
    typesig { [::Java::Int] }
    def remove_transition(trans)
      @transitions.remove(trans)
    end
    
    typesig { [NFAState, NFAConfiguration] }
    # Add an NFA configuration to this DFA node.  Add uniquely
    # an NFA state/alt/syntactic&semantic context (chain of invoking state(s)
    # and semantic predicate contexts).
    # 
    # I don't see how there could be two configurations with same
    # state|alt|synCtx and different semantic contexts because the
    # semantic contexts are computed along the path to a particular state
    # so those two configurations would have to have the same predicate.
    # Nonetheless, the addition of configurations is unique on all
    # configuration info.  I guess I'm saying that syntactic context
    # implies semantic context as the latter is computed according to the
    # former.
    # 
    # As we add configurations to this DFA state, track the set of all possible
    # transition labels so we can simply walk it later rather than doing a
    # loop over all possible labels in the NFA.
    def add_nfaconfiguration(state, c)
      if (@nfa_configurations.contains(c))
        return
      end
      @nfa_configurations.add(c)
      # track min alt rather than compute later
      if (c.attr_alt < @min_alt_in_configurations)
        @min_alt_in_configurations = c.attr_alt
      end
      if (!(c.attr_semantic_context).equal?(SemanticContext::EMPTY_SEMANTIC_CONTEXT))
        @at_least_one_configuration_has_apredicate = true
      end
      # update hashCode; for some reason using context.hashCode() also
      # makes the GC take like 70% of the CPU and is slow!
      @cached_hash_code += c.attr_state + c.attr_alt
      # update reachableLabels
      # We're adding an NFA state; check to see if it has a non-epsilon edge
      if (!(state.attr_transition[0]).nil?)
        label = state.attr_transition[0].attr_label
        if (!(label.is_epsilon || label.is_semantic_predicate))
          # this NFA state has a non-epsilon edge, track for fast
          # walking later when we do reach on this DFA state we're
          # building.
          @configurations_with_labeled_edges.add(c)
          if ((state.attr_transition[1]).nil?)
            # later we can check this to ignore o-A->o states in closure
            c.attr_single_atom_transition_emanating = true
          end
          add_reachable_label(label)
        end
      end
    end
    
    typesig { [NFAState, ::Java::Int, NFAContext, SemanticContext] }
    def add_nfaconfiguration(state, alt, context, semantic_context)
      c = NFAConfiguration.new(state.attr_state_number, alt, context, semantic_context)
      add_nfaconfiguration(state, c)
      return c
    end
    
    typesig { [Label] }
    # Add label uniquely and disjointly; intersection with
    # another set or int/char forces breaking up the set(s).
    # 
    # Example, if reachable list of labels is [a..z, {k,9}, 0..9],
    # the disjoint list will be [{a..j,l..z}, k, 9, 0..8].
    # 
    # As we add NFA configurations to a DFA state, we might as well track
    # the set of all possible transition labels to make the DFA conversion
    # more efficient.  W/o the reachable labels, we'd need to check the
    # whole vocabulary space (could be 0..\uFFFF)!  The problem is that
    # labels can be sets, which may overlap with int labels or other sets.
    # As we need a deterministic set of transitions from any
    # state in the DFA, we must make the reachable labels set disjoint.
    # This operation amounts to finding the character classes for this
    # DFA state whereas with tools like flex, that need to generate a
    # homogeneous DFA, must compute char classes across all states.
    # We are going to generate DFAs with heterogeneous states so we
    # only care that the set of transitions out of a single state are
    # unique. :)
    # 
    # The idea for adding a new set, t, is to look for overlap with the
    # elements of existing list s.  Upon overlap, replace
    # existing set s[i] with two new disjoint sets, s[i]-t and s[i]&t.
    # (if s[i]-t is nil, don't add).  The remainder is t-s[i], which is
    # what you want to add to the set minus what was already there.  The
    # remainder must then be compared against the i+1..n elements in s
    # looking for another collision.  Each collision results in a smaller
    # and smaller remainder.  Stop when you run out of s elements or
    # remainder goes to nil.  If remainder is non nil when you run out of
    # s elements, then add remainder to the end.
    # 
    # Single element labels are treated as sets to make the code uniform.
    def add_reachable_label(label)
      if ((@reachable_labels).nil?)
        @reachable_labels = OrderedHashSet.new
      end
      # 
      # System.out.println("addReachableLabel to state "+dfa.decisionNumber+"."+stateNumber+": "+label.getSet().toString(dfa.nfa.grammar));
      # System.out.println("start of add to state "+dfa.decisionNumber+"."+stateNumber+": " +
      # "reachableLabels="+reachableLabels.toString());
      if (@reachable_labels.contains(label))
        # exact label present
        return
      end
      t = label.get_set
      remainder = t # remainder starts out as whole set to add
      n = @reachable_labels.size # only look at initial elements
      # walk the existing list looking for the collision
      i = 0
      while i < n
        rl = @reachable_labels.get(i)
        # 
        # System.out.println("comparing ["+i+"]: "+label.toString(dfa.nfa.grammar)+" & "+
        # rl.toString(dfa.nfa.grammar)+"="+
        # intersection.toString(dfa.nfa.grammar));
        if (!Label.intersect(label, rl))
          ((i += 1) - 1)
          next
        end
        # System.out.println(label+" collides with "+rl);
        # For any (s_i, t) with s_i&t!=nil replace with (s_i-t, s_i&t)
        # (ignoring s_i-t if nil; don't put in list)
        # Replace existing s_i with intersection since we
        # know that will always be a non nil character class
        s_i = rl.get_set
        intersection = s_i.and(t)
        @reachable_labels.set(i, Label.new(intersection))
        # Compute s_i-t to see what is in current set and not in incoming
        existing_minus_new_elements = s_i.subtract(t)
        # System.out.println(s_i+"-"+t+"="+existingMinusNewElements);
        if (!existing_minus_new_elements.is_nil)
          # found a new character class, add to the end (doesn't affect
          # outer loop duration due to n computation a priori.
          new_label = Label.new(existing_minus_new_elements)
          @reachable_labels.add(new_label)
        end
        # 
        # System.out.println("after collision, " +
        # "reachableLabels="+reachableLabels.toString());
        # 
        # anything left to add to the reachableLabels?
        remainder = t.subtract(s_i)
        if (remainder.is_nil)
          break # nothing left to add to set.  done!
        end
        t = remainder
        ((i += 1) - 1)
      end
      if (!remainder.is_nil)
        # 
        # System.out.println("before add remainder to state "+dfa.decisionNumber+"."+stateNumber+": " +
        # "reachableLabels="+reachableLabels.toString());
        # System.out.println("remainder state "+dfa.decisionNumber+"."+stateNumber+": "+remainder.toString(dfa.nfa.grammar));
        new_label_ = Label.new(remainder)
        @reachable_labels.add(new_label_)
      end
      # 
      # System.out.println("#END of add to state "+dfa.decisionNumber+"."+stateNumber+": " +
      # "reachableLabels="+reachableLabels.toString());
    end
    
    typesig { [] }
    def get_reachable_labels
      return @reachable_labels
    end
    
    typesig { [OrderedHashSet] }
    def set_nfaconfigurations(configs)
      @nfa_configurations = configs
    end
    
    typesig { [] }
    # A decent hash for a DFA state is the sum of the NFA state/alt pairs.
    # This is used when we add DFAState objects to the DFA.states Map and
    # when we compare DFA states.  Computed in addNFAConfiguration()
    def hash_code
      if ((@cached_hash_code).equal?(0))
        # LL(1) algorithm doesn't use NFA configurations, which
        # dynamically compute hashcode; must have something; use super
        return super
      end
      return @cached_hash_code
    end
    
    typesig { [Object] }
    # Two DFAStates are equal if their NFA configuration sets are the
    # same. This method is used to see if a DFA state already exists.
    # 
    # Because the number of alternatives and number of NFA configurations are
    # finite, there is a finite number of DFA states that can be processed.
    # This is necessary to show that the algorithm terminates.
    # 
    # Cannot test the DFA state numbers here because in DFA.addState we need
    # to know if any other state exists that has this exact set of NFA
    # configurations.  The DFAState state number is irrelevant.
    def equals(o)
      # compare set of NFA configurations in this set with other
      other = o
      return (@nfa_configurations == other.attr_nfa_configurations)
    end
    
    typesig { [] }
    # Walk each configuration and if they are all the same alt, return
    # that alt else return NFA.INVALID_ALT_NUMBER.  Ignore resolved
    # configurations, but don't ignore resolveWithPredicate configs
    # because this state should not be an accept state.  We need to add
    # this to the work list and then have semantic predicate edges
    # emanating from it.
    def get_uniquely_predicted_alt
      if (!(@cached_uniquely_predicated_alt).equal?(PREDICTED_ALT_UNSET))
        return @cached_uniquely_predicated_alt
      end
      alt = NFA::INVALID_ALT_NUMBER
      num_configs = @nfa_configurations.size
      i = 0
      while i < num_configs
        configuration = @nfa_configurations.get(i)
        # ignore anything we resolved; predicates will still result
        # in transitions out of this state, so must count those
        # configurations; i.e., don't ignore resolveWithPredicate configs
        if (configuration.attr_resolved)
          ((i += 1) - 1)
          next
        end
        if ((alt).equal?(NFA::INVALID_ALT_NUMBER))
          alt = configuration.attr_alt # found first nonresolved alt
        else
          if (!(configuration.attr_alt).equal?(alt))
            return NFA::INVALID_ALT_NUMBER
          end
        end
        ((i += 1) - 1)
      end
      @cached_uniquely_predicated_alt = alt
      return alt
    end
    
    typesig { [] }
    # Return the uniquely mentioned alt from the NFA configurations;
    # Ignore the resolved bit etc...  Return INVALID_ALT_NUMBER
    # if there is more than one alt mentioned.
    def get_unique_alt
      alt = NFA::INVALID_ALT_NUMBER
      num_configs = @nfa_configurations.size
      i = 0
      while i < num_configs
        configuration = @nfa_configurations.get(i)
        if ((alt).equal?(NFA::INVALID_ALT_NUMBER))
          alt = configuration.attr_alt # found first alt
        else
          if (!(configuration.attr_alt).equal?(alt))
            return NFA::INVALID_ALT_NUMBER
          end
        end
        ((i += 1) - 1)
      end
      return alt
    end
    
    typesig { [] }
    # When more than one alternative can match the same input, the first
    # alternative is chosen to resolve the conflict.  The other alts
    # are "turned off" by setting the "resolved" flag in the NFA
    # configurations.  Return the set of disabled alternatives.  For
    # 
    # a : A | A | A ;
    # 
    # this method returns {2,3} as disabled.  This does not mean that
    # the alternative is totally unreachable, it just means that for this
    # DFA state, that alt is disabled.  There may be other accept states
    # for that alt.
    def get_disabled_alternatives
      disabled = LinkedHashSet.new
      num_configs = @nfa_configurations.size
      i = 0
      while i < num_configs
        configuration = @nfa_configurations.get(i)
        if (configuration.attr_resolved)
          disabled.add(Utils.integer(configuration.attr_alt))
        end
        ((i += 1) - 1)
      end
      return disabled
    end
    
    typesig { [] }
    def get_non_deterministic_alts
      user_k = @dfa.get_user_max_lookahead
      if (user_k > 0 && (user_k).equal?(@k))
        # if fixed lookahead, then more than 1 alt is a nondeterminism
        # if we have hit the max lookahead
        return get_alt_set
      else
        if (@aborted_due_to_multiple_recursive_alts || @aborted_due_to_recursion_overflow)
          # if we had to abort for non-LL(*) state assume all alts are a problem
          return get_alt_set
        else
          return get_conflicting_alts
        end
      end
    end
    
    typesig { [] }
    # Walk each NFA configuration in this DFA state looking for a conflict
    # where (s|i|ctx) and (s|j|ctx) exist, indicating that state s with
    # context conflicting ctx predicts alts i and j.  Return an Integer set
    # of the alternative numbers that conflict.  Two contexts conflict if
    # they are equal or one is a stack suffix of the other or one is
    # the empty context.
    # 
    # Use a hash table to record the lists of configs for each state
    # as they are encountered.  We need only consider states for which
    # there is more than one configuration.  The configurations' predicted
    # alt must be different or must have different contexts to avoid a
    # conflict.
    # 
    # Don't report conflicts for DFA states that have conflicting Tokens
    # rule NFA states; they will be resolved in favor of the first rule.
    def get_conflicting_alts
      # TODO this is called multiple times: cache result?
      # System.out.println("getNondetAlts for DFA state "+stateNumber);
      nondeterministic_alts = HashSet.new
      # If only 1 NFA conf then no way it can be nondeterministic;
      # save the overhead.  There are many o-a->o NFA transitions
      # and so we save a hash map and iterator creation for each
      # state.
      num_configs = @nfa_configurations.size
      if (num_configs <= 1)
        return nil
      end
      # First get a list of configurations for each state.
      # Most of the time, each state will have one associated configuration.
      state_to_config_list_map = MultiMap.new
      i = 0
      while i < num_configs
        configuration = @nfa_configurations.get(i)
        state_i = Utils.integer(configuration.attr_state)
        state_to_config_list_map.map(state_i, configuration)
        ((i += 1) - 1)
      end
      # potential conflicts are states with > 1 configuration and diff alts
      states = state_to_config_list_map.key_set
      num_potential_conflicts = 0
      it = states.iterator
      while it.has_next
        state_i_ = it.next
        this_state_has_potential_problem = false
        configs_for_state = state_to_config_list_map.get(state_i_)
        alt = 0
        num_configs_for_state = configs_for_state.size
        i_ = 0
        while i_ < num_configs_for_state && num_configs_for_state > 1
          c = configs_for_state.get(i_)
          if ((alt).equal?(0))
            alt = c.attr_alt
          else
            if (!(c.attr_alt).equal?(alt))
              # 
              # System.out.println("potential conflict in state "+stateI+
              # " configs: "+configsForState);
              # 
              # 11/28/2005: don't report closures that pinch back
              # together in Tokens rule.  We want to silently resolve
              # to the first token definition ala lex/flex by ignoring
              # these conflicts.
              # Also this ensures that lexers look for more and more
              # characters (longest match) before resorting to predicates.
              # TestSemanticPredicates.testLexerMatchesLongestThenTestPred()
              # for example would terminate at state s1 and test predicate
              # meaning input "ab" would test preds to decide what to
              # do but it should match rule C w/o testing preds.
              if (!(@dfa.attr_nfa.attr_grammar.attr_type).equal?(Grammar::LEXER) || !(@dfa.attr_decision_nfastart_state.attr_enclosing_rule.attr_name == Grammar::ARTIFICIAL_TOKENS_RULENAME))
                ((num_potential_conflicts += 1) - 1)
                this_state_has_potential_problem = true
              end
            end
          end
          ((i_ += 1) - 1)
        end
        if (!this_state_has_potential_problem)
          # remove NFA state's configurations from
          # further checking; no issues with it
          # (can't remove as it's concurrent modification; set to null)
          state_to_config_list_map.put(state_i_, nil)
        end
      end
      # a fast check for potential issues; most states have none
      if ((num_potential_conflicts).equal?(0))
        return nil
      end
      # we have a potential problem, so now go through config lists again
      # looking for different alts (only states with potential issues
      # are left in the states set).  Now we will check context.
      # For example, the list of configs for NFA state 3 in some DFA
      # state might be:
      # [3|2|[28 18 $], 3|1|[28 $], 3|1, 3|2]
      # I want to create a map from context to alts looking for overlap:
      # [28 18 $] -> 2
      # [28 $] -> 1
      # [$] -> 1,2
      # Indeed a conflict exists as same state 3, same context [$], predicts
      # alts 1 and 2.
      # walk each state with potential conflicting configurations
      it_ = states.iterator
      while it_.has_next
        state_i__ = it_.next
        configs_for_state_ = state_to_config_list_map.get(state_i__)
        # compare each configuration pair s, t to ensure:
        # s.ctx different than t.ctx if s.alt != t.alt
        num_configs_for_state_ = 0
        if (!(configs_for_state_).nil?)
          num_configs_for_state_ = configs_for_state_.size
        end
        i__ = 0
        while i__ < num_configs_for_state_
          s = configs_for_state_.get(i__)
          j = i__ + 1
          while j < num_configs_for_state_
            t = configs_for_state_.get(j)
            # conflicts means s.ctx==t.ctx or s.ctx is a stack
            # suffix of t.ctx or vice versa (if alts differ).
            # Also a conflict if s.ctx or t.ctx is empty
            if (!(s.attr_alt).equal?(t.attr_alt) && s.attr_context.conflicts_with(t.attr_context))
              nondeterministic_alts.add(Utils.integer(s.attr_alt))
              nondeterministic_alts.add(Utils.integer(t.attr_alt))
            end
            ((j += 1) - 1)
          end
          ((i__ += 1) - 1)
        end
      end
      if ((nondeterministic_alts.size).equal?(0))
        return nil
      end
      return nondeterministic_alts
    end
    
    typesig { [] }
    # Get the set of all alts mentioned by all NFA configurations in this
    # DFA state.
    def get_alt_set
      num_configs = @nfa_configurations.size
      alts = HashSet.new
      i = 0
      while i < num_configs
        configuration = @nfa_configurations.get(i)
        alts.add(Utils.integer(configuration.attr_alt))
        ((i += 1) - 1)
      end
      if ((alts.size).equal?(0))
        return nil
      end
      return alts
    end
    
    typesig { [] }
    def get_gated_syntactic_predicates_in_nfaconfigurations
      num_configs = @nfa_configurations.size
      synpreds = HashSet.new
      i = 0
      while i < num_configs
        configuration = @nfa_configurations.get(i)
        gated_pred_expr = configuration.attr_semantic_context.get_gated_predicate_context
        # if this is a manual syn pred (gated and syn pred), add
        if (!(gated_pred_expr).nil? && configuration.attr_semantic_context.is_syntactic_predicate)
          synpreds.add(configuration.attr_semantic_context)
        end
        ((i += 1) - 1)
      end
      if ((synpreds.size).equal?(0))
        return nil
      end
      return synpreds
    end
    
    typesig { [] }
    # For gated productions, we need an OR'd list of all predicates for the
    # target of an edge so we can gate the edge based upon the predicates
    # associated with taking that path (if any).
    # 
    # For syntactic predicates, we only want to generate predicate
    # evaluations as it transitions to an accept state; waste to
    # do it earlier.  So, only add gated preds derived from manually-
    # specified syntactic predicates if this is an accept state.
    # 
    # Also, since configurations w/o gated predicates are like true
    # gated predicates, finding a configuration whose alt has no gated
    # predicate implies we should evaluate the predicate to true. This
    # means the whole edge has to be ungated. Consider:
    # 
    # X : ('a' | {p}?=> 'a')
    # | 'a' 'b'
    # ;
    # 
    # Here, you 'a' gets you from s0 to s1 but you can't test p because
    # plain 'a' is ok.  It's also ok for starting alt 2.  Hence, you can't
    # test p.  Even on the edge going to accept state for alt 1 of X, you
    # can't test p.  You can get to the same place with and w/o the context.
    # Therefore, it is never ok to test p in this situation.
    # 
    # TODO: cache this as it's called a lot; or at least set bit if >1 present in state
    def get_gated_predicates_in_nfaconfigurations
      union_of_predicates_from_all_alts = nil
      num_configs = @nfa_configurations.size
      i = 0
      while i < num_configs
        configuration = @nfa_configurations.get(i)
        gated_pred_expr = configuration.attr_semantic_context.get_gated_predicate_context
        if ((gated_pred_expr).nil?)
          # if we ever find a configuration w/o a gated predicate
          # (even if it's a nongated predicate), we cannot gate
          # the indident edges.
          return nil
        else
          if (self.attr_accept_state || !configuration.attr_semantic_context.is_syntactic_predicate)
            # at this point we have a gated predicate and, due to elseif,
            # we know it's an accept and not a syn pred.  In this case,
            # it's safe to add the gated predicate to the union.  We
            # only want to add syn preds if it's an accept state.  Other
            # gated preds can be used with edges leading to accept states.
            if ((union_of_predicates_from_all_alts).nil?)
              union_of_predicates_from_all_alts = gated_pred_expr
            else
              union_of_predicates_from_all_alts = SemanticContext.or(union_of_predicates_from_all_alts, gated_pred_expr)
            end
          end
        end
        ((i += 1) - 1)
      end
      if (union_of_predicates_from_all_alts.is_a?(SemanticContext::TruePredicate))
        return nil
      end
      return union_of_predicates_from_all_alts
    end
    
    typesig { [] }
    # Is an accept state reachable from this state?
    def get_accept_state_reachable
      return @accept_state_reachable
    end
    
    typesig { [::Java::Int] }
    def set_accept_state_reachable(accept_state_reachable)
      @accept_state_reachable = accept_state_reachable
    end
    
    typesig { [] }
    def is_resolved_with_predicates
      return @resolved_with_predicates
    end
    
    typesig { [] }
    # Print all NFA states plus what alts they predict
    def to_s
      buf = StringBuffer.new
      buf.append((self.attr_state_number).to_s + ":{")
      i = 0
      while i < @nfa_configurations.size
        configuration = @nfa_configurations.get(i)
        if (i > 0)
          buf.append(", ")
        end
        buf.append(configuration)
        ((i += 1) - 1)
      end
      buf.append("}")
      return buf.to_s
    end
    
    typesig { [] }
    def get_lookahead_depth
      return @k
    end
    
    typesig { [::Java::Int] }
    def set_lookahead_depth(k)
      @k = k
      if (k > @dfa.attr_max_k)
        # track max k for entire DFA
        @dfa.attr_max_k = k
      end
    end
    
    private
    alias_method :initialize__dfastate, :initialize
  end
  
end
