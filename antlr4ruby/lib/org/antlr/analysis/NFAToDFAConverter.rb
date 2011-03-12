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
  module NFAToDFAConverterImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :OrderedHashSet
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Tool, :ErrorManager
      include ::Java::Util
      include_const ::Antlr, :Token
    }
  end
  
  # Code that embodies the NFA conversion to DFA. A new object is needed
  # per DFA (also required for thread safety if multiple conversions
  # launched).
  class NFAToDFAConverter 
    include_class_members NFAToDFAConverterImports
    
    # A list of DFA states we still need to process during NFA conversion
    attr_accessor :work
    alias_method :attr_work, :work
    undef_method :work
    alias_method :attr_work=, :work=
    undef_method :work=
    
    # While converting NFA, we must track states that
    # reference other rule's NFAs so we know what to do
    # at the end of a rule.  We need to know what context invoked
    # this rule so we can know where to continue looking for NFA
    # states.  I'm tracking a context tree (record of rule invocation
    # stack trace) for each alternative that could be predicted.
    attr_accessor :context_trees
    alias_method :attr_context_trees, :context_trees
    undef_method :context_trees
    alias_method :attr_context_trees=, :context_trees=
    undef_method :context_trees=
    
    # We are converting which DFA?
    attr_accessor :dfa
    alias_method :attr_dfa, :dfa
    undef_method :dfa
    alias_method :attr_dfa=, :dfa=
    undef_method :dfa=
    
    class_module.module_eval {
      
      def debug
        defined?(@@debug) ? @@debug : @@debug= false
      end
      alias_method :attr_debug, :debug
      
      def debug=(value)
        @@debug = value
      end
      alias_method :attr_debug=, :debug=
      
      # Should ANTLR launch multiple threads to convert NFAs to DFAs?
      # With a 2-CPU box, I note that it's about the same single or
      # multithreaded.  Both CPU meters are going even when single-threaded
      # so I assume the GC is killing us.  Could be the compiler.  When I
      # run java -Xint mode, I get about 15% speed improvement with multiple
      # threads.
      
      def single_threaded_nfa_conversion
        defined?(@@single_threaded_nfa_conversion) ? @@single_threaded_nfa_conversion : @@single_threaded_nfa_conversion= true
      end
      alias_method :attr_single_threaded_nfa_conversion, :single_threaded_nfa_conversion
      
      def single_threaded_nfa_conversion=(value)
        @@single_threaded_nfa_conversion = value
      end
      alias_method :attr_single_threaded_nfa_conversion=, :single_threaded_nfa_conversion=
    }
    
    attr_accessor :computing_start_state
    alias_method :attr_computing_start_state, :computing_start_state
    undef_method :computing_start_state
    alias_method :attr_computing_start_state=, :computing_start_state=
    undef_method :computing_start_state=
    
    typesig { [DFA] }
    def initialize(dfa)
      @work = LinkedList.new
      @context_trees = nil
      @dfa = nil
      @computing_start_state = false
      @dfa = dfa
      n_alts = dfa.get_number_of_alts
      init_context_trees(n_alts)
    end
    
    typesig { [] }
    def convert
      @dfa.attr_conversion_start_time = System.current_time_millis
      # create the DFA start state
      @dfa.attr_start_state = compute_start_state
      # while more DFA states to check, process them
      while (@work.size > 0 && !@dfa.attr_nfa.attr_grammar._nfato_dfaconversion_externally_aborted)
        d = @work.get(0)
        if (@dfa.attr_nfa.attr_grammar.attr_composite.attr_watch_nfaconversion)
          System.out.println("convert DFA state " + RJava.cast_to_string(d.attr_state_number) + " (" + RJava.cast_to_string(d.attr_nfa_configurations.size) + " nfa states)")
        end
        k = @dfa.get_user_max_lookahead
        if (k > 0 && (k).equal?(d.get_lookahead_depth))
          # we've hit max lookahead, make this a stop state
          # System.out.println("stop state @k="+k+" (terminated early)");
          # List<Label> sampleInputLabels = d.dfa.probe.getSampleNonDeterministicInputSequence(d);
          # String input = d.dfa.probe.getInputSequenceDisplay(sampleInputLabels);
          # System.out.println("sample input: "+input);
          resolve_non_determinisms(d)
          # Check to see if we need to add any semantic predicate transitions
          if (d.is_resolved_with_predicates)
            add_predicate_transitions(d)
          else
            d.set_accept_state(true) # must convert to accept state at k
          end
        else
          find_new_dfastates_and_add_dfatransitions(d)
        end
        @work.remove(0) # done with it; remove from work list
      end
      # Find all manual syn preds (gated).  These are not discovered
      # in tryToResolveWithSemanticPredicates because they are implicitly
      # added to every edge by code gen, DOT generation etc...
      @dfa.find_all_gated_syn_preds_used_in_dfaaccept_states
    end
    
    typesig { [] }
    # From this first NFA state of a decision, create a DFA.
    # Walk each alt in decision and compute closure from the start of that
    # rule, making sure that the closure does not include other alts within
    # that same decision.  The idea is to associate a specific alt number
    # with the starting closure so we can trace the alt number for all states
    # derived from this.  At a stop state in the DFA, we can return this alt
    # number, indicating which alt is predicted.
    # 
    # If this DFA is derived from an loop back NFA state, then the first
    # transition is actually the exit branch of the loop.  Rather than make
    # this alternative one, let's make this alt n+1 where n is the number of
    # alts in this block.  This is nice to keep the alts of the block 1..n;
    # helps with error messages.
    # 
    # I handle nongreedy in findNewDFAStatesAndAddDFATransitions
    # when nongreedy and EOT transition.  Make state with EOT emanating
    # from it the accept state.
    def compute_start_state
      alt = @dfa.attr_decision_nfastart_state
      start_state = @dfa.new_state
      @computing_start_state = true
      i = 0
      alt_num = 1
      while (!(alt).nil?)
        # find the set of NFA states reachable without consuming
        # any input symbols for each alt.  Keep adding to same
        # overall closure that will represent the DFA start state,
        # but track the alt number
        initial_context = @context_trees[i]
        # if first alt is derived from loopback/exit branch of loop,
        # make alt=n+1 for n alts instead of 1
        if ((i).equal?(0) && (@dfa.get_nfadecision_start_state.attr_decision_state_type).equal?(NFAState::LOOPBACK))
          num_alts_including_exit_branch = @dfa.attr_nfa.attr_grammar.get_number_of_alts_for_decision_nfa(@dfa.attr_decision_nfastart_state)
          alt_num = num_alts_including_exit_branch
          closure(alt.attr_transition[0].attr_target, alt_num, initial_context, SemanticContext::EMPTY_SEMANTIC_CONTEXT, start_state, true)
          alt_num = 1 # make next alt the first
        else
          closure(alt.attr_transition[0].attr_target, alt_num, initial_context, SemanticContext::EMPTY_SEMANTIC_CONTEXT, start_state, true)
          alt_num += 1
        end
        i += 1
        # move to next alternative
        if ((alt.attr_transition[1]).nil?)
          break
        end
        alt = alt.attr_transition[1].attr_target
      end
      # now DFA start state has the complete closure for the decision
      # but we have tracked which alt is associated with which
      # NFA states.
      @dfa.add_state(start_state) # make sure dfa knows about this state
      @work.add(start_state)
      @computing_start_state = false
      return start_state
    end
    
    typesig { [DFAState] }
    # From this node, add a d--a-->t transition for all
    # labels 'a' where t is a DFA node created
    # from the set of NFA states reachable from any NFA
    # state in DFA state d.
    def find_new_dfastates_and_add_dfatransitions(d)
      # System.out.println("work on DFA state "+d);
      labels = d.get_reachable_labels
      # System.out.println("reachable labels="+labels);
      # System.out.println("|reachable|/|nfaconfigs|="+
      #         labels.size()+"/"+d.getNFAConfigurations().size()+"="+
      #         labels.size()/(float)d.getNFAConfigurations().size());
      # normally EOT is the "default" clause and decisions just
      # choose that last clause when nothing else matches.  DFA conversion
      # continues searching for a unique sequence that predicts the
      # various alts or until it finds EOT.  So this rule
      # 
      # DUH : ('x'|'y')* "xy!";
      # 
      # does not need a greedy indicator.  The following rule works fine too
      # 
      # A : ('x')+ ;
      # 
      # When the follow branch could match what is in the loop, by default,
      # the nondeterminism is resolved in favor of the loop.  You don't
      # get a warning because the only way to get this condition is if
      # the DFA conversion hits the end of the token.  In that case,
      # we're not *sure* what will happen next, but it could be anything.
      # Anyway, EOT is the default case which means it will never be matched
      # as resolution goes to the lowest alt number.  Exit branches are
      # always alt n+1 for n alts in a block.
      # 
      # When a loop is nongreedy and we find an EOT transition, the DFA
      # state should become an accept state, predicting exit of loop.  It's
      # just reversing the resolution of ambiguity.
      # TODO: should this be done in the resolveAmbig method?
      eotlabel = Label.new(Label::EOT)
      contains_eot = !(labels).nil? && labels.contains(eotlabel)
      if (!@dfa.is_greedy && contains_eot)
        convert_to_eotaccept_state(d)
        return # no more work to do on this accept state
      end
      # if in filter mode for lexer, want to match shortest not longest
      # string so if we see an EOT edge emanating from this state, then
      # convert this state to an accept state.  This only counts for
      # The Tokens rule as all other decisions must continue to look for
      # longest match.
      # [Taking back out a few days later on Jan 17, 2006.  This could
      #  be an option for the future, but this was wrong soluion for
      #  filtering.]
      # if ( dfa.nfa.grammar.type==Grammar.LEXER && containsEOT ) {
      #     String filterOption = (String)dfa.nfa.grammar.getOption("filter");
      #     boolean filterMode = filterOption!=null && filterOption.equals("true");
      #     if ( filterMode && d.dfa.isTokensRuleDecision() ) {
      #         DFAState t = reach(d, EOTLabel);
      #         if ( t.getNFAConfigurations().size()>0 ) {
      #             convertToEOTAcceptState(d);
      #             //System.out.println("state "+d+" has EOT target "+t.stateNumber);
      #             return;
      #         }
      #     }
      # }
      number_of_edges_emanating = 0
      target_to_label_map = HashMap.new
      # for each label that could possibly emanate from NFAStates of d
      num_labels = 0
      if (!(labels).nil?)
        num_labels = labels.size
      end
      i = 0
      while i < num_labels
        label = labels.get(i)
        t = reach(d, label)
        if (self.attr_debug)
          System.out.println("DFA state after reach " + RJava.cast_to_string(label) + " " + RJava.cast_to_string(d) + "-" + RJava.cast_to_string(label.to_s(@dfa.attr_nfa.attr_grammar)) + "->" + RJava.cast_to_string(t))
        end
        if ((t).nil?)
          # nothing was reached by label due to conflict resolution
          # EOT also seems to be in here occasionally probably due
          # to an end-of-rule state seeing it even though we'll pop
          # an invoking state off the state; don't bother to conflict
          # as this labels set is a covering approximation only.
          i += 1
          next
        end
        # System.out.println("dfa.k="+dfa.getUserMaxLookahead());
        if ((t.get_unique_alt).equal?(NFA::INVALID_ALT_NUMBER))
          # Only compute closure if a unique alt number is not known.
          # If a unique alternative is mentioned among all NFA
          # configurations then there is no possibility of needing to look
          # beyond this state; also no possibility of a nondeterminism.
          # This optimization May 22, 2006 just dropped -Xint time
          # for analysis of Java grammar from 11.5s to 2s!  Wow.
          closure(t) # add any NFA states reachable via epsilon
        end
        # System.out.println("DFA state after closure "+d+"-"+
        #                    label.toString(dfa.nfa.grammar)+
        #                    "->"+t);
        # add if not in DFA yet and then make d-label->t
        target_state = add_dfastate_to_work_list(t)
        number_of_edges_emanating += add_transition(d, label, target_state, target_to_label_map)
        # lookahead of target must be one larger than d's k
        # We are possibly setting the depth of a pre-existing state
        # that is equal to one we just computed...not sure if that's
        # ok.
        target_state.set_lookahead_depth(d.get_lookahead_depth + 1)
        i += 1
      end
      # System.out.println("DFA after reach / closures:\n"+dfa);
      if (!d.is_resolved_with_predicates && (number_of_edges_emanating).equal?(0))
        # System.out.println("dangling DFA state "+d+"\nAfter reach / closures:\n"+dfa);
        # TODO: can fixed lookahead hit a dangling state case?
        # TODO: yes, with left recursion
        # System.err.println("dangling state alts: "+d.getAltSet());
        @dfa.attr_probe.report_dangling_state(d)
        # turn off all configurations except for those associated with
        # min alt number; somebody has to win else some input will not
        # predict any alt.
        min_alt = resolve_by_picking_min_alt(d, nil)
        # force it to be an accept state
        # don't call convertToAcceptState() which merges stop states.
        # other states point at us; don't want them pointing to dead states
        d.set_accept_state(true) # might be adding new accept state for alt
        @dfa.set_accept_state(min_alt, d)
        # convertToAcceptState(d, minAlt); // force it to be an accept state
      end
      # Check to see if we need to add any semantic predicate transitions
      if (d.is_resolved_with_predicates)
        add_predicate_transitions(d)
      end
    end
    
    class_module.module_eval {
      typesig { [DFAState, Label, DFAState, Map] }
      # Add a transition from state d to targetState with label in normal case.
      # if COLLAPSE_ALL_INCIDENT_EDGES, however, try to merge all edges from
      # d to targetState; this means merging their labels.  Another optimization
      # is to reduce to a single EOT edge any set of edges from d to targetState
      # where there exists an EOT state.  EOT is like the wildcard so don't
      # bother to test any other edges.  Example:
      # 
      # NUM_INT
      #   : '1'..'9' ('0'..'9')* ('l'|'L')?
      #   | '0' ('x'|'X') ('0'..'9'|'a'..'f'|'A'..'F')+ ('l'|'L')?
      #   | '0' ('0'..'7')* ('l'|'L')?
      #   ;
      # 
      # The normal decision to predict alts 1, 2, 3 is:
      # 
      # if ( (input.LA(1)>='1' && input.LA(1)<='9') ) {
      #      alt7=1;
      # }
      # else if ( input.LA(1)=='0' ) {
      #     if ( input.LA(2)=='X'||input.LA(2)=='x' ) {
      #         alt7=2;
      #     }
      #     else if ( (input.LA(2)>='0' && input.LA(2)<='7') ) {
      #          alt7=3;
      #     }
      #     else if ( input.LA(2)=='L'||input.LA(2)=='l' ) {
      #          alt7=3;
      #     }
      #     else {
      #          alt7=3;
      #     }
      # }
      # else error
      # 
      # Clearly, alt 3 is predicted with extra work since it tests 0..7
      # and [lL] before finally realizing that any character is actually
      # ok at k=2.
      # 
      # A better decision is as follows:
      # 
      # if ( (input.LA(1)>='1' && input.LA(1)<='9') ) {
      #     alt7=1;
      # }
      # else if ( input.LA(1)=='0' ) {
      #     if ( input.LA(2)=='X'||input.LA(2)=='x' ) {
      #         alt7=2;
      #     }
      #     else {
      #         alt7=3;
      #     }
      # }
      # 
      # The DFA originally has 3 edges going to the state the predicts alt 3,
      # but upon seeing the EOT edge (the "else"-clause), this method
      # replaces the old merged label (which would have (0..7|l|L)) with EOT.
      # The code generator then leaves alt 3 predicted with a simple else-
      # clause. :)
      # 
      # The only time the EOT optimization makes no sense is in the Tokens
      # rule.  We want EOT to truly mean you have matched an entire token
      # so don't bother actually rewinding to execute that rule unless there
      # are actions in that rule.  For now, since I am not preventing
      # backtracking from Tokens rule, I will simply allow the optimization.
      def add_transition(d, label, target_state, target_to_label_map)
        # System.out.println(d.stateNumber+"-"+label.toString(dfa.nfa.grammar)+"->"+targetState.stateNumber);
        n = 0
        if (DFAOptimizer::COLLAPSE_ALL_PARALLEL_EDGES)
          # track which targets we've hit
          t_i = Utils.integer(target_state.attr_state_number)
          old_transition = target_to_label_map.get(t_i)
          if (!(old_transition).nil?)
            # System.out.println("extra transition to "+tI+" upon "+label.toString(dfa.nfa.grammar));
            # already seen state d to target transition, just add label
            # to old label unless EOT
            if ((label.get_atom).equal?(Label::EOT))
              # merge with EOT means old edge can go away
              old_transition.attr_label = Label.new(Label::EOT)
            else
              # don't add anything to EOT, it's essentially the wildcard
              if (!(old_transition.attr_label.get_atom).equal?(Label::EOT))
                # ok, not EOT, add in this label to old label
                old_transition.attr_label.add(label)
              end
              # System.out.println("label updated to be "+oldTransition.label.toString(dfa.nfa.grammar));
            end
          else
            # make a transition from d to t upon 'a'
            n = 1
            label = label.clone # clone in case we alter later
            transition_index = d.add_transition(target_state, label)
            trans = d.get_transition(transition_index)
            # track target/transition pairs
            target_to_label_map.put(t_i, trans)
          end
        else
          n = 1
          d.add_transition(target_state, label)
        end
        return n
      end
    }
    
    typesig { [DFAState] }
    # For all NFA states (configurations) merged in d,
    # compute the epsilon closure; that is, find all NFA states reachable
    # from the NFA states in d via purely epsilon transitions.
    def closure(d)
      if (self.attr_debug)
        System.out.println("closure(" + RJava.cast_to_string(d) + ")")
      end
      configs = ArrayList.new
      # Because we are adding to the configurations in closure
      # must clone initial list so we know when to stop doing closure
      configs.add_all(d.attr_nfa_configurations)
      # for each NFA configuration in d (abort if we detect non-LL(*) state)
      num_configs = configs.size
      i = 0
      while i < num_configs
        c = configs.get(i)
        if (c.attr_single_atom_transition_emanating)
          i += 1
          next # ignore NFA states w/o epsilon transitions
        end
        # System.out.println("go do reach for NFA state "+c.state);
        # figure out reachable NFA states from each of d's nfa states
        # via epsilon transitions.
        # Fill configsInClosure rather than altering d configs inline
        closure(@dfa.attr_nfa.get_state(c.attr_state), c.attr_alt, c.attr_context, c.attr_semantic_context, d, false)
        i += 1
      end
      # System.out.println("after closure d="+d);
      d.attr_closure_busy = nil # wack all that memory used during closure
    end
    
    typesig { [NFAState, ::Java::Int, NFAContext, SemanticContext, DFAState, ::Java::Boolean] }
    # Where can we get from NFA state p traversing only epsilon transitions?
    # Add new NFA states + context to DFA state d.  Also add semantic
    # predicates to semantic context if collectPredicates is set.  We only
    # collect predicates at hoisting depth 0, meaning before any token/char
    # have been recognized.  This corresponds, during analysis, to the
    # initial DFA start state construction closure() invocation.
    # 
    # There are four cases of interest (the last being the usual transition):
    # 
    #  1. Traverse an edge that takes us to the start state of another
    #     rule, r.  We must push this state so that if the DFA
    #     conversion hits the end of rule r, then it knows to continue
    #     the conversion at state following state that "invoked" r. By
    #     construction, there is a single transition emanating from a rule
    #     ref node.
    # 
    #  2. Reach an NFA state associated with the end of a rule, r, in the
    #     grammar from which it was built.  We must add an implicit (i.e.,
    #     don't actually add an epsilon transition) epsilon transition
    #     from r's end state to the NFA state following the NFA state
    #     that transitioned to rule r's start state.  Because there are
    #     many states that could reach r, the context for a rule invocation
    #     is part of a call tree not a simple stack.  When we fall off end
    #     of rule, "pop" a state off the call tree and add that state's
    #     "following" node to d's NFA configuration list.  The context
    #     for this new addition will be the new "stack top" in the call tree.
    # 
    #  3. Like case 2, we reach an NFA state associated with the end of a
    #     rule, r, in the grammar from which NFA was built.  In this case,
    #     however, we realize that during this NFA->DFA conversion, no state
    #     invoked the current rule's NFA.  There is no choice but to add
    #     all NFA states that follow references to r's start state.  This is
    #     analogous to computing the FOLLOW(r) in the LL(k) world.  By
    #     construction, even rule stop state has a chain of nodes emanating
    #     from it that points to every possible following node.  This case
    #     is conveniently handled then by the 4th case.
    # 
    #  4. Normal case.  If p can reach another NFA state q, then add
    #     q to d's configuration list, copying p's context for q's context.
    #     If there is a semantic predicate on the transition, then AND it
    #     with any existing semantic context.
    # 
    #  Current state p is always added to d's configuration list as it's part
    #  of the closure as well.
    # 
    # When is a closure operation in a cycle condition?  While it is
    # very possible to have the same NFA state mentioned twice
    # within the same DFA state, there are two situations that
    # would lead to nontermination of closure operation:
    # 
    # o   Whenever closure reaches a configuration where the same state
    #     with same or a suffix context already exists.  This catches
    #     the IF-THEN-ELSE tail recursion cycle and things like
    # 
    #     a : A a | B ;
    # 
    #     the context will be $ (empty stack).
    # 
    #     We have to check
    #     larger context stacks because of (...)+ loops.  For
    #     example, the context of a (...)+ can be nonempty if the
    #     surrounding rule is invoked by another rule:
    # 
    #     a : b A | X ;
    #     b : (B|)+ ;  // nondeterministic by the way
    # 
    #     The context of the (B|)+ loop is "invoked from item
    #     a : . b A ;" and then the empty alt of the loop can reach back
    #     to itself.  The context stack will have one "return
    #     address" element and so we must check for same state, same
    #     context for arbitrary context stacks.
    # 
    #     Idea: If we've seen this configuration before during closure, stop.
    #     We also need to avoid reaching same state with conflicting context.
    #     Ultimately analysis would stop and we'd find the conflict, but we
    #     should stop the computation.  Previously I only checked for
    #     exact config.  Need to check for same state, suffix context
    #        not just exact context.
    # 
    # o   Whenever closure reaches a configuration where state p
    #     is present in its own context stack.  This means that
    #     p is a rule invocation state and the target rule has
    #     been called before.  NFAContext.MAX_RECURSIVE_INVOCATIONS
    #     (See the comment there also) determines how many times
    #     it's possible to recurse; clearly we cannot recurse forever.
    #     Some grammars such as the following actually require at
    #     least one recursive call to correctly compute the lookahead:
    # 
    #     a : L ID R
    #       | b
    #       ;
    #     b : ID
    #       | L a R
    #       ;
    # 
    #     Input L ID R is ambiguous but to figure this out, ANTLR
    #     needs to go a->b->a->b to find the L ID sequence.
    # 
    #     Do not allow closure to add a configuration that would
    #     allow too much recursion.
    # 
    #     This case also catches infinite left recursion.
    def closure(p, alt, context, semantic_context, d, collect_predicates)
      if (self.attr_debug)
        System.out.println("closure at " + RJava.cast_to_string(p.attr_enclosing_rule.attr_name) + " state " + RJava.cast_to_string(p.attr_state_number) + "|" + RJava.cast_to_string(alt) + " filling DFA state " + RJava.cast_to_string(d.attr_state_number) + " with context " + RJava.cast_to_string(context))
      end
      if (DFA::MAX_TIME_PER_DFA_CREATION > 0 && System.current_time_millis - d.attr_dfa.attr_conversion_start_time >= DFA::MAX_TIME_PER_DFA_CREATION)
        # bail way out; we've blown up somehow
        raise AnalysisTimeoutException.new(d.attr_dfa)
      end
      proposed_nfaconfiguration = NFAConfiguration.new(p.attr_state_number, alt, context, semantic_context)
      # Avoid infinite recursion
      if (closure_is_busy(d, proposed_nfaconfiguration))
        if (self.attr_debug)
          System.out.println("avoid visiting exact closure computation NFA config: " + RJava.cast_to_string(proposed_nfaconfiguration) + " in " + RJava.cast_to_string(p.attr_enclosing_rule.attr_name))
          System.out.println("state is " + RJava.cast_to_string(d.attr_dfa.attr_decision_number) + "." + RJava.cast_to_string(d.attr_state_number))
        end
        return
      end
      # set closure to be busy for this NFA configuration
      d.attr_closure_busy.add(proposed_nfaconfiguration)
      # p itself is always in closure
      d.add_nfaconfiguration(p, proposed_nfaconfiguration)
      # Case 1: are we a reference to another rule?
      transition0 = p.attr_transition[0]
      if (transition0.is_a?(RuleClosureTransition))
        depth = context.recursion_depth_emanating_from_state(p.attr_state_number)
        # Detect recursion by more than a single alt, which indicates
        # that the decision's lookahead language is non-regular; terminate
        if ((depth).equal?(1) && (d.attr_dfa.get_user_max_lookahead).equal?(0))
          # k=* only
          d.attr_dfa.attr_recursive_alt_set.add(alt) # indicate that this alt is recursive
          if (d.attr_dfa.attr_recursive_alt_set.size > 1)
            # System.out.println("recursive alts: "+d.dfa.recursiveAltSet.toString());
            d.attr_aborted_due_to_multiple_recursive_alts = true
            raise NonLLStarDecisionException.new(d.attr_dfa)
          end
          # System.out.println("alt "+alt+" in rule "+p.enclosingRule+" dec "+d.dfa.decisionNumber+
          #     " ctx: "+context);
          # System.out.println("d="+d);
        end
        # Detect an attempt to recurse too high
        # if this context has hit the max recursions for p.stateNumber,
        # don't allow it to enter p.stateNumber again
        if (depth >= NFAContext::MAX_SAME_RULE_INVOCATIONS_PER_NFA_CONFIG_STACK)
          # System.out.println("OVF state "+d);
          # System.out.println("proposed "+proposedNFAConfiguration);
          d.attr_aborted_due_to_recursion_overflow = true
          d.attr_dfa.attr_probe.report_recursion_overflow(d, proposed_nfaconfiguration)
          if (self.attr_debug)
            System.out.println("analysis overflow in closure(" + RJava.cast_to_string(d.attr_state_number) + ")")
          end
          return
        end
        # otherwise, it's cool to (re)enter target of this rule ref
        ref = transition0
        # first create a new context and push onto call tree,
        # recording the fact that we are invoking a rule and
        # from which state (case 2 below will get the following state
        # via the RuleClosureTransition emanating from the invoking state
        # pushed on the stack).
        # Reset the context to reflect the fact we invoked rule
        new_context = NFAContext.new(context, p)
        # System.out.println("invoking rule "+ref.rule.name);
        # System.out.println(" context="+context);
        # traverse epsilon edge to new rule
        rule_target = ref.attr_target
        closure(rule_target, alt, new_context, semantic_context, d, collect_predicates)
        # Case 2: end of rule state, context (i.e., an invoker) exists
      else
        if (p.is_accept_state && !(context.attr_parent).nil?)
          which_state_invoked_rule = context.attr_invoking_state
          edge_to_rule = which_state_invoked_rule.attr_transition[0]
          continue_state = edge_to_rule.attr_follow_state
          new_context = context.attr_parent # "pop" invoking state
          closure(continue_state, alt, new_context, semantic_context, d, collect_predicates)
          # Case 3: end of rule state, nobody invoked this rule (no context)
          #    Fall thru to be handled by case 4 automagically.
          # Case 4: ordinary NFA->DFA conversion case: simple epsilon transition
        else
          # recurse down any epsilon transitions
          if (!(transition0).nil? && transition0.is_epsilon)
            collect_predicates_after_action = collect_predicates
            if (transition0.is_action && collect_predicates)
              collect_predicates_after_action = false
              # if ( computingStartState ) {
              #     System.out.println("found action during prediction closure "+((ActionLabel)transition0.label).actionAST.token);
              # }
            end
            closure(transition0.attr_target, alt, context, semantic_context, d, collect_predicates_after_action)
          else
            if (!(transition0).nil? && transition0.is_semantic_predicate)
              if (@computing_start_state)
                if (collect_predicates)
                  # only indicate we can see a predicate if we're collecting preds;
                  # Could be computing start state & seen an action before this.
                  @dfa.attr_predicate_visible = true
                else
                  # this state has a pred, but we can't see it.
                  @dfa.attr_has_predicate_blocked_by_action = true
                  # System.out.println("found pred during prediction but blocked by action found previously");
                end
              end
              # continue closure here too, but add the sem pred to ctx
              new_semantic_context = semantic_context
              if (collect_predicates)
                # AND the previous semantic context with new pred
                label_context = transition0.attr_label.get_semantic_context
                # do not hoist syn preds from other rules; only get if in
                # starting state's rule (i.e., context is empty)
                walk_alt = @dfa.attr_decision_nfastart_state.translate_display_alt_to_walk_alt(alt)
                alt_left_edge = @dfa.attr_nfa.attr_grammar.get_nfastate_for_alt_of_decision(@dfa.attr_decision_nfastart_state, walk_alt)
                # System.out.println("state "+p.stateNumber+" alt "+alt+" walkAlt "+walkAlt+" trans to "+transition0.target);
                # System.out.println("DFA start state "+dfa.decisionNFAStartState.stateNumber);
                # System.out.println("alt left edge "+altLeftEdge.stateNumber+
                #     ", epsilon target "+
                #     altLeftEdge.transition(0).target.stateNumber);
                if (!label_context.is_syntactic_predicate || (p).equal?(alt_left_edge.attr_transition[0].attr_target))
                  # System.out.println("&"+labelContext+" enclosingRule="+p.enclosingRule);
                  new_semantic_context = SemanticContext.and_(semantic_context, label_context)
                end
              end
              closure(transition0.attr_target, alt, context, new_semantic_context, d, collect_predicates)
            end
          end
          transition1 = p.attr_transition[1]
          if (!(transition1).nil? && transition1.is_epsilon)
            closure(transition1.attr_target, alt, context, semantic_context, d, collect_predicates)
          end
        end
      end
      # don't remove "busy" flag as we want to prevent all
      # references to same config of state|alt|ctx|semCtx even
      # if resulting from another NFA state
    end
    
    class_module.module_eval {
      typesig { [DFAState, NFAConfiguration] }
      # A closure operation should abort if that computation has already
      # been done or a computation with a conflicting context has already
      # been done.  If proposed NFA config's state and alt are the same
      # there is potentially a problem.  If the stack context is identical
      # then clearly the exact same computation is proposed.  If a context
      # is a suffix of the other, then again the computation is in an
      # identical context.  ?$ and ??$ are considered the same stack.
      # We could walk configurations linearly doing the comparison instead
      # of a set for exact matches but it's much slower because you can't
      # do a Set lookup.  I use exact match as ANTLR
      # always detect the conflict later when checking for context suffixes...
      # I check for left-recursive stuff and terminate before analysis to
      # avoid need to do this more expensive computation.
      # 
      # 12-31-2007: I had to use the loop again rather than simple
      # closureBusy.contains(proposedNFAConfiguration) lookup.  The
      # semantic context should not be considered when determining if
      # a closure operation is busy.  I saw a FOLLOW closure operation
      # spin until time out because the predicate context kept increasing
      # in size even though it's same boolean value.  This seems faster also
      # because I'm not doing String.equals on the preds all the time.
      # 
      # 05-05-2008: Hmm...well, i think it was a mistake to remove the sem
      # ctx check below...adding back in.  Coincides with report of ANTLR
      # getting super slow: http://www.antlr.org:8888/browse/ANTLR-235
      # This could be because it doesn't properly compute then resolve
      # a predicate expression.  Seems to fix unit test:
      # TestSemanticPredicates.testSemanticContextPreventsEarlyTerminationOfClosure()
      # Changing back to Set from List.  Changed a large grammar from 8 minutes
      # to 11 seconds.  Cool.  Closing ANTLR-235.
      def closure_is_busy(d, proposed_nfaconfiguration)
        return d.attr_closure_busy.contains(proposed_nfaconfiguration)
        # int numConfigs = d.closureBusy.size();
        # // Check epsilon cycle (same state, same alt, same context)
        # for (int i = 0; i < numConfigs; i++) {
        #     NFAConfiguration c = (NFAConfiguration) d.closureBusy.get(i);
        #     if ( proposedNFAConfiguration.state==c.state &&
        #          proposedNFAConfiguration.alt==c.alt &&
        #          proposedNFAConfiguration.semanticContext.equals(c.semanticContext) &&
        #          proposedNFAConfiguration.context.suffix(c.context) )
        #     {
        #         return true;
        #     }
        # }
        # return false;
      end
    }
    
    typesig { [DFAState, Label] }
    # Given the set of NFA states in DFA state d, find all NFA states
    # reachable traversing label arcs.  By definition, there can be
    # only one DFA state reachable by an atom from DFA state d so we must
    # find and merge all NFA states reachable via label.  Return a new
    # DFAState that has all of those NFA states with their context (i.e.,
    # which alt do they predict and where to return to if they fall off
    # end of a rule).
    # 
    # Because we cannot jump to another rule nor fall off the end of a rule
    # via a non-epsilon transition, NFA states reachable from d have the
    # same configuration as the NFA state in d.  So if NFA state 7 in d's
    # configurations can reach NFA state 13 then 13 will be added to the
    # new DFAState (labelDFATarget) with the same configuration as state
    # 7 had.
    # 
    # This method does not see EOT transitions off the end of token rule
    # accept states if the rule was invoked by somebody.
    def reach(d, label)
      # System.out.println("reach "+label.toString(dfa.nfa.grammar)+" from "+d.stateNumber);
      label_dfatarget = @dfa.new_state
      # for each NFA state in d with a labeled edge,
      # add in target states for label
      # System.out.println("size(d.state="+d.stateNumber+")="+d.nfaConfigurations.size());
      # System.out.println("size(labeled edge states)="+d.configurationsWithLabeledEdges.size());
      configs = d.attr_configurations_with_labeled_edges
      num_configs = configs.size
      i = 0
      while i < num_configs
        c = configs.get(i)
        if (c.attr_resolved || c.attr_resolve_with_predicate)
          i += 1
          next # the conflict resolver indicates we must leave alone
        end
        p = @dfa.attr_nfa.get_state(c.attr_state)
        # by design of the grammar->NFA conversion, only transition 0
        # may have a non-epsilon edge.
        edge = p.attr_transition[0]
        if ((edge).nil? || !c.attr_single_atom_transition_emanating)
          i += 1
          next
        end
        edge_label = edge.attr_label
        # SPECIAL CASE
        # if it's an EOT transition on end of lexer rule, but context
        # stack is not empty, then don't see the EOT; the closure
        # will have added in the proper states following the reference
        # to this rule in the invoking rule.  In other words, if
        # somebody called this rule, don't see the EOT emanating from
        # this accept state.
        if (!(c.attr_context.attr_parent).nil? && (edge_label.attr_label).equal?(Label::EOT))
          i += 1
          next
        end
        # Labels not unique at this point (not until addReachableLabels)
        # so try simple int label match before general set intersection
        # System.out.println("comparing "+edgeLabel+" with "+label);
        if (Label.intersect(label, edge_label))
          # found a transition with label;
          # add NFA target to (potentially) new DFA state
          new_c = label_dfatarget.add_nfaconfiguration(edge.attr_target, c.attr_alt, c.attr_context, c.attr_semantic_context)
        end
        i += 1
      end
      if ((label_dfatarget.attr_nfa_configurations.size).equal?(0))
        # kill; it's empty
        @dfa.set_state(label_dfatarget.attr_state_number, nil)
        label_dfatarget = nil
      end
      return label_dfatarget
    end
    
    typesig { [DFAState] }
    # Walk the configurations of this DFA state d looking for the
    # configuration, c, that has a transition on EOT.  State d should
    # be converted to an accept state predicting the c.alt.  Blast
    # d's current configuration set and make it just have config c.
    # 
    # TODO: can there be more than one config with EOT transition?
    # That would mean that two NFA configurations could reach the
    # end of the token with possibly different predicted alts.
    # Seems like that would be rare or impossible.  Perhaps convert
    # this routine to find all such configs and give error if >1.
    def convert_to_eotaccept_state(d)
      eot = Label.new(Label::EOT)
      num_configs = d.attr_nfa_configurations.size
      i = 0
      while i < num_configs
        c = d.attr_nfa_configurations.get(i)
        if (c.attr_resolved || c.attr_resolve_with_predicate)
          i += 1
          next # the conflict resolver indicates we must leave alone
        end
        p = @dfa.attr_nfa.get_state(c.attr_state)
        edge = p.attr_transition[0]
        edge_label = edge.attr_label
        if ((edge_label == eot))
          # System.out.println("config with EOT: "+c);
          d.set_accept_state(true)
          # System.out.println("d goes from "+d);
          d.attr_nfa_configurations.clear
          d.add_nfaconfiguration(p, c.attr_alt, c.attr_context, c.attr_semantic_context)
          # System.out.println("to "+d);
          return # assume only one EOT transition
        end
        i += 1
      end
    end
    
    typesig { [DFAState] }
    # Add a new DFA state to the DFA if not already present.
    # If the DFA state uniquely predicts a single alternative, it
    # becomes a stop state; don't add to work list.  Further, if
    # there exists an NFA state predicted by > 1 different alternatives
    # and with the same syn and sem context, the DFA is nondeterministic for
    # at least one input sequence reaching that NFA state.
    def add_dfastate_to_work_list(d)
      existing_state = @dfa.add_state(d)
      if (!(d).equal?(existing_state))
        # already there...use/return the existing DFA state.
        # But also set the states[d.stateNumber] to the existing
        # DFA state because the closureIsBusy must report
        # infinite recursion on a state before it knows
        # whether or not the state will already be
        # found after closure on it finishes.  It could be
        # referring to a state that will ultimately not make it
        # into the reachable state space and the error
        # reporting must be able to compute the path from
        # start to the error state with infinite recursion
        @dfa.set_state(d.attr_state_number, existing_state)
        return existing_state
      end
      # if not there, then examine new state.
      # resolve syntactic conflicts by choosing a single alt or
      # by using semantic predicates if present.
      resolve_non_determinisms(d)
      # If deterministic, don't add this state; it's an accept state
      # Just return as a valid DFA state
      alt = d.get_uniquely_predicted_alt
      if (!(alt).equal?(NFA::INVALID_ALT_NUMBER))
        # uniquely predicts an alt?
        d = convert_to_accept_state(d, alt)
        # System.out.println("convert to accept; DFA "+d.dfa.decisionNumber+" state "+d.stateNumber+" uniquely predicts alt "+
        #     d.getUniquelyPredictedAlt());
      else
        # unresolved, add to work list to continue NFA conversion
        @work.add(d)
      end
      return d
    end
    
    typesig { [DFAState, ::Java::Int] }
    def convert_to_accept_state(d, alt)
      # only merge stop states if they are deterministic and no
      # recursion problems and only if they have the same gated pred
      # context!
      # Later, the error reporting may want to trace the path from
      # the start state to the nondet state
      if (DFAOptimizer::MERGE_STOP_STATES && (d.get_non_deterministic_alts).nil? && !d.attr_aborted_due_to_recursion_overflow && !d.attr_aborted_due_to_multiple_recursive_alts)
        # check to see if we already have an accept state for this alt
        # [must do this after we resolve nondeterminisms in general]
        accept_state_for_alt = @dfa.get_accept_state(alt)
        if (!(accept_state_for_alt).nil?)
          # we already have an accept state for alt;
          # Are their gate sem pred contexts the same?
          # For now we assume a braindead version: both must not
          # have gated preds or share exactly same single gated pred.
          # The equals() method is only defined on Predicate contexts not
          # OR etc...
          gated_preds = d.get_gated_predicates_in_nfaconfigurations
          existing_state_gated_preds = accept_state_for_alt.get_gated_predicates_in_nfaconfigurations
          if (((gated_preds).nil? && (existing_state_gated_preds).nil?) || ((!(gated_preds).nil? && !(existing_state_gated_preds).nil?) && (gated_preds == existing_state_gated_preds)))
            # make this d.statenumber point at old DFA state
            @dfa.set_state(d.attr_state_number, accept_state_for_alt)
            @dfa.remove_state(d) # remove this state from unique DFA state set
            d = accept_state_for_alt # use old accept state; throw this one out
            return d
          end
          # else consider it a new accept state; fall through.
        end
      end
      d.set_accept_state(true) # new accept state for alt
      @dfa.set_accept_state(alt, d)
      return d
    end
    
    typesig { [DFAState] }
    # If > 1 NFA configurations within this DFA state have identical
    # NFA state and context, but differ in their predicted
    # TODO update for new context suffix stuff 3-9-2005
    # alternative then a single input sequence predicts multiple alts.
    # The NFA decision is therefore syntactically indistinguishable
    # from the left edge upon at least one input sequence.  We may
    # terminate the NFA to DFA conversion for these paths since no
    # paths emanating from those NFA states can possibly separate
    # these conjoined twins once interwined to make things
    # deterministic (unless there are semantic predicates; see below).
    # 
    # Upon a nondeterministic set of NFA configurations, we should
    # report a problem to the grammar designer and resolve the issue
    # by aribitrarily picking the first alternative (this usually
    # ends up producing the most natural behavior).  Pick the lowest
    # alt number and just turn off all NFA configurations
    # associated with the other alts. Rather than remove conflicting
    # NFA configurations, I set the "resolved" bit so that future
    # computations will ignore them.  In this way, we maintain the
    # complete DFA state with all its configurations, but prevent
    # future DFA conversion operations from pursuing undesirable
    # paths.  Remember that we want to terminate DFA conversion as
    # soon as we know the decision is deterministic *or*
    # nondeterministic.
    # 
    # [BTW, I have convinced myself that there can be at most one
    # set of nondeterministic configurations in a DFA state.  Only NFA
    # configurations arising from the same input sequence can appear
    # in a DFA state.  There is no way to have another complete set
    # of nondeterministic NFA configurations without another input
    # sequence, which would reach a different DFA state.  Therefore,
    # the two nondeterministic NFA configuration sets cannot collide
    # in the same DFA state.]
    # 
    # Consider DFA state {(s|1),(s|2),(s|3),(t|3),(v|4)} where (s|a)
    # is state 's' and alternative 'a'.  Here, configuration set
    # {(s|1),(s|2),(s|3)} predicts 3 different alts.  Configurations
    # (s|2) and (s|3) are "resolved", leaving {(s|1),(t|3),(v|4)} as
    # items that must still be considered by the DFA conversion
    # algorithm in DFA.findNewDFAStatesAndAddDFATransitions().
    # 
    # Consider the following grammar where alts 1 and 2 are no
    # problem because of the 2nd lookahead symbol.  Alts 3 and 4 are
    # identical and will therefore reach the rule end NFA state but
    # predicting 2 different alts (no amount of future lookahead
    # will render them deterministic/separable):
    # 
    # a : A B
    #   | A C
    #   | A
    #   | A
    #   ;
    # 
    # Here is a (slightly reduced) NFA of this grammar:
    # 
    # (1)-A->(2)-B->(end)-EOF->(8)
    #  |              ^
    # (2)-A->(3)-C----|
    #  |              ^
    # (4)-A->(5)------|
    #  |              ^
    # (6)-A->(7)------|
    # 
    # where (n) is NFA state n.  To begin DFA conversion, the start
    # state is created:
    # 
    # {(1|1),(2|2),(4|3),(6|4)}
    # 
    # Upon A, all NFA configurations lead to new NFA states yielding
    # new DFA state:
    # 
    # {(2|1),(3|2),(5|3),(7|4),(end|3),(end|4)}
    # 
    # where the configurations with state end in them are added
    # during the epsilon closure operation.  State end predicts both
    # alts 3 and 4.  An error is reported, the latter configuration is
    # flagged as resolved leaving the DFA state as:
    # 
    # {(2|1),(3|2),(5|3),(7|4|resolved),(end|3),(end|4|resolved)}
    # 
    # As NFA configurations are added to a DFA state during its
    # construction, the reachable set of labels is computed.  Here
    # reachable is {B,C,EOF} because there is at least one NFA state
    # in the DFA state that can transition upon those symbols.
    # 
    # The final DFA looks like:
    # 
    # {(1|1),(2|2),(4|3),(6|4)}
    #             |
    #             v
    # {(2|1),(3|2),(5|3),(7|4),(end|3),(end|4)} -B-> (end|1)
    #             |                        |
    #             C                        ----EOF-> (8,3)
    #             |
    #             v
    #          (end|2)
    # 
    # Upon AB, alt 1 is predicted.  Upon AC, alt 2 is predicted.
    # Upon A EOF, alt 3 is predicted.  Alt 4 is not a viable
    # alternative.
    # 
    # The algorithm is essentially to walk all the configurations
    # looking for a conflict of the form (s|i) and (s|j) for i!=j.
    # Use a hash table to track state+context pairs for collisions
    # so that we have O(n) to walk the n configurations looking for
    # a conflict.  Upon every conflict, track the alt number so
    # we have a list of all nondeterministically predicted alts. Also
    # track the minimum alt.  Next go back over the configurations, setting
    # the "resolved" bit for any that have an alt that is a member of
    # the nondeterministic set.  This will effectively remove any alts
    # but the one we want from future consideration.
    # 
    # See resolveWithSemanticPredicates()
    # 
    # AMBIGUOUS TOKENS
    # 
    # With keywords and ID tokens, there is an inherit ambiguity in that
    # "int" can be matched by ID also.  Each lexer rule has an EOT
    # transition emanating from it which is used whenever the end of
    # a rule is reached and another token rule did not invoke it.  EOT
    # is the only thing that can be seen next.  If two rules are identical
    # like "int" and "int" then the 2nd def is unreachable and you'll get
    # a warning.  We prevent a warning though for the keyword/ID issue as
    # ID is still reachable.  This can be a bit weird.  '+' rule then a
    # '+'|'+=' rule will fail to match '+' for the 2nd rule.
    # 
    # If all NFA states in this DFA state are targets of EOT transitions,
    # (and there is more than one state plus no unique alt is predicted)
    # then DFA conversion will leave this state as a dead state as nothing
    # can be reached from this state.  To resolve the ambiguity, just do
    # what flex and friends do: pick the first rule (alt in this case) to
    # win.  This means you should put keywords before the ID rule.
    # If the DFA state has only one NFA state then there is no issue:
    # it uniquely predicts one alt. :)  Problem
    # states will look like this during conversion:
    # 
    # DFA 1:{9|1, 19|2, 14|3, 20|2, 23|2, 24|2, ...}-<EOT>->5:{41|3, 42|2}
    # 
    # Worse, when you have two identical literal rules, you will see 3 alts
    # in the EOT state (one for ID and one each for the identical rules).
    def resolve_non_determinisms(d)
      if (self.attr_debug)
        System.out.println("resolveNonDeterminisms " + RJava.cast_to_string(d.to_s))
      end
      conflicting_lexer_rules = false
      nondeterministic_alts = d.get_non_deterministic_alts
      if (self.attr_debug && !(nondeterministic_alts).nil?)
        System.out.println("nondet alts=" + RJava.cast_to_string(nondeterministic_alts))
      end
      # CHECK FOR AMBIGUOUS EOT (if |allAlts|>1 and EOT state, resolve)
      # grab any config to see if EOT state; any other configs must
      # transition on EOT to get to this DFA state as well so all
      # states in d must be targets of EOT.  These are the end states
      # created in NFAFactory.build_EOFState
      any_config = d.attr_nfa_configurations.get(0)
      any_state = @dfa.attr_nfa.get_state(any_config.attr_state)
      # if d is target of EOT and more than one predicted alt
      # indicate that d is nondeterministic on all alts otherwise
      # it looks like state has no problem
      if (any_state.is_eottarget_state)
        all_alts = d.get_alt_set
        # is more than 1 alt predicted?
        if (!(all_alts).nil? && all_alts.size > 1)
          nondeterministic_alts = all_alts
          # track Tokens rule issues differently than other decisions
          if (d.attr_dfa.is_tokens_rule_decision)
            @dfa.attr_probe.report_lexer_rule_nondeterminism(d, all_alts)
            # System.out.println("Tokens rule DFA state "+d+" nondeterministic");
            conflicting_lexer_rules = true
          end
        end
      end
      # if no problems return unless we aborted work on d to avoid inf recursion
      if (!d.attr_aborted_due_to_recursion_overflow && (nondeterministic_alts).nil?)
        return # no problems, return
      end
      # if we're not a conflicting lexer rule and we didn't abort, report ambig
      # We should get a report for abort so don't give another
      if (!d.attr_aborted_due_to_recursion_overflow && !conflicting_lexer_rules)
        # TODO: with k=x option set, this is called twice for same state
        @dfa.attr_probe.report_nondeterminism(d, nondeterministic_alts)
        # TODO: how to turn off when it's only the FOLLOW that is
        # conflicting.  This used to shut off even alts i,j < n
        # conflict warnings. :(
      end
      # ATTEMPT TO RESOLVE WITH SEMANTIC PREDICATES
      resolved = try_to_resolve_with_semantic_predicates(d, nondeterministic_alts)
      if (resolved)
        if (self.attr_debug)
          System.out.println("resolved DFA state " + RJava.cast_to_string(d.attr_state_number) + " with pred")
        end
        d.attr_resolved_with_predicates = true
        @dfa.attr_probe.report_nondeterminism_resolved_with_semantic_predicate(d)
        return
      end
      # RESOLVE SYNTACTIC CONFLICT BY REMOVING ALL BUT ONE ALT
      resolve_by_choosing_first_alt(d, nondeterministic_alts)
      # System.out.println("state "+d.stateNumber+" resolved to alt "+winningAlt);
    end
    
    typesig { [DFAState, JavaSet] }
    def resolve_by_choosing_first_alt(d, nondeterministic_alts)
      winning_alt = 0
      if (@dfa.is_greedy)
        winning_alt = resolve_by_picking_min_alt(d, nondeterministic_alts)
      else
        # If nongreedy, the exit alt shout win, but only if it's
        # involved in the nondeterminism!
        # System.out.println("resolving exit alt for decision="+
        #     dfa.decisionNumber+" state="+d);
        # System.out.println("nondet="+nondeterministicAlts);
        # System.out.println("exit alt "+exitAlt);
        exit_alt = @dfa.get_number_of_alts
        if (nondeterministic_alts.contains(Utils.integer(exit_alt)))
          # if nongreedy and exit alt is one of those nondeterministic alts
          # predicted, resolve in favor of what follows block
          winning_alt = resolve_by_picking_exit_alt(d, nondeterministic_alts)
        else
          winning_alt = resolve_by_picking_min_alt(d, nondeterministic_alts)
        end
      end
      return winning_alt
    end
    
    typesig { [DFAState, JavaSet] }
    # Turn off all configurations associated with the
    # set of incoming nondeterministic alts except the min alt number.
    # There may be many alts among the configurations but only turn off
    # the ones with problems (other than the min alt of course).
    # 
    # If nondeterministicAlts is null then turn off all configs 'cept those
    # associated with the minimum alt.
    # 
    # Return the min alt found.
    def resolve_by_picking_min_alt(d, nondeterministic_alts)
      min = JavaInteger::MAX_VALUE
      if (!(nondeterministic_alts).nil?)
        min = get_min_alt(nondeterministic_alts)
      else
        min = d.attr_min_alt_in_configurations
      end
      turn_off_other_alts(d, min, nondeterministic_alts)
      return min
    end
    
    typesig { [DFAState, JavaSet] }
    # Resolve state d by choosing exit alt, which is same value as the
    # number of alternatives.  Return that exit alt.
    def resolve_by_picking_exit_alt(d, nondeterministic_alts)
      exit_alt = @dfa.get_number_of_alts
      turn_off_other_alts(d, exit_alt, nondeterministic_alts)
      return exit_alt
    end
    
    class_module.module_eval {
      typesig { [DFAState, ::Java::Int, JavaSet] }
      # turn off all states associated with alts other than the good one
      # (as long as they are one of the nondeterministic ones)
      def turn_off_other_alts(d, min, nondeterministic_alts)
        num_configs = d.attr_nfa_configurations.size
        i = 0
        while i < num_configs
          configuration = d.attr_nfa_configurations.get(i)
          if (!(configuration.attr_alt).equal?(min))
            if ((nondeterministic_alts).nil? || nondeterministic_alts.contains(Utils.integer(configuration.attr_alt)))
              configuration.attr_resolved = true
            end
          end
          i += 1
        end
      end
      
      typesig { [JavaSet] }
      def get_min_alt(nondeterministic_alts)
        min = JavaInteger::MAX_VALUE
        nondeterministic_alts.each do |altI|
          alt = alt_i.int_value
          if (alt < min)
            min = alt
          end
        end
        return min
      end
    }
    
    typesig { [DFAState, JavaSet] }
    # See if a set of nondeterministic alternatives can be disambiguated
    # with the semantic predicate contexts of the alternatives.
    # 
    # Without semantic predicates, syntactic conflicts are resolved
    # by simply choosing the first viable alternative.  In the
    # presence of semantic predicates, you can resolve the issue by
    # evaluating boolean expressions at run time.  During analysis,
    # this amounts to suppressing grammar error messages to the
    # developer.  NFA configurations are always marked as "to be
    # resolved with predicates" so that
    # DFA.findNewDFAStatesAndAddDFATransitions() will know to ignore
    # these configurations and add predicate transitions to the DFA
    # after adding token/char labels.
    # 
    # During analysis, we can simply make sure that for n
    # ambiguously predicted alternatives there are at least n-1
    # unique predicate sets.  The nth alternative can be predicted
    # with "not" the "or" of all other predicates.  NFA configurations without
    # predicates are assumed to have the default predicate of
    # "true" from a user point of view.  When true is combined via || with
    # another predicate, the predicate is a tautology and must be removed
    # from consideration for disambiguation:
    # 
    # a : b | B ; // hoisting p1||true out of rule b, yields no predicate
    # b : {p1}? B | B ;
    # 
    # This is done down in getPredicatesPerNonDeterministicAlt().
    def try_to_resolve_with_semantic_predicates(d, nondeterministic_alts)
      alt_to_pred_map = get_predicates_per_non_deterministic_alt(d, nondeterministic_alts)
      if ((alt_to_pred_map.size).equal?(0))
        return false
      end
      # System.out.println("nondeterministic alts with predicates: "+altToPredMap);
      @dfa.attr_probe.report_alt_predicate_context(d, alt_to_pred_map)
      if (nondeterministic_alts.size - alt_to_pred_map.size > 1)
        # too few predicates to resolve; just return
        # TODO: actually do we need to gen error here?
        return false
      end
      # Handle case where 1 predicate is missing
      # Case 1. Semantic predicates
      # If the missing pred is on nth alt, !(union of other preds)==true
      # so we can avoid that computation.  If naked alt is ith, then must
      # test it with !(union) since semantic predicated alts are order
      # independent
      # Case 2: Syntactic predicates
      # The naked alt is always assumed to be true as the order of
      # alts is the order of precedence.  The naked alt will be a tautology
      # anyway as it's !(union of other preds).  This implies
      # that there is no such thing as noviable alt for synpred edges
      # emanating from a DFA state.
      if ((alt_to_pred_map.size).equal?(nondeterministic_alts.size - 1))
        # if there are n-1 predicates for n nondeterministic alts, can fix
        nd_set = Org::Antlr::Misc::BitSet.of(nondeterministic_alts)
        pred_set = Org::Antlr::Misc::BitSet.of(alt_to_pred_map)
        naked_alt = nd_set.subtract(pred_set).get_single_element
        naked_alt_pred = nil
        if ((naked_alt).equal?(max(nondeterministic_alts)))
          # the naked alt is the last nondet alt and will be the default clause
          naked_alt_pred = SemanticContext::TruePredicate.new
        else
          # pretend naked alternative is covered with !(union other preds)
          # unless it's a synpred since those have precedence same
          # as alt order
          union_of_predicates_from_all_alts = get_union_of_predicates(alt_to_pred_map)
          # System.out.println("all predicates "+unionOfPredicatesFromAllAlts);
          if (union_of_predicates_from_all_alts.is_syntactic_predicate)
            naked_alt_pred = SemanticContext::TruePredicate.new
          else
            naked_alt_pred = SemanticContext.not_(union_of_predicates_from_all_alts)
          end
        end
        # System.out.println("covering naked alt="+nakedAlt+" with "+nakedAltPred);
        alt_to_pred_map.put(Utils.integer(naked_alt), naked_alt_pred)
        # set all config with alt=nakedAlt to have the computed predicate
        num_configs = d.attr_nfa_configurations.size
        i = 0
        while i < num_configs
          configuration = d.attr_nfa_configurations.get(i)
          if ((configuration.attr_alt).equal?(naked_alt))
            configuration.attr_semantic_context = naked_alt_pred
          end
          i += 1
        end
      end
      if ((alt_to_pred_map.size).equal?(nondeterministic_alts.size))
        # RESOLVE CONFLICT by picking one NFA configuration for each alt
        # and setting its resolvedWithPredicate flag
        # First, prevent a recursion warning on this state due to
        # pred resolution
        if (d.attr_aborted_due_to_recursion_overflow)
          d.attr_dfa.attr_probe.remove_recursive_overflow_state(d)
        end
        num_configs = d.attr_nfa_configurations.size
        i = 0
        while i < num_configs
          configuration = d.attr_nfa_configurations.get(i)
          sem_ctx = alt_to_pred_map.get(Utils.integer(configuration.attr_alt))
          if (!(sem_ctx).nil?)
            # resolve (first found) with pred
            # and remove alt from problem list
            configuration.attr_resolve_with_predicate = true
            configuration.attr_semantic_context = sem_ctx # reset to combined
            alt_to_pred_map.remove(Utils.integer(configuration.attr_alt))
            # notify grammar that we've used the preds contained in semCtx
            if (sem_ctx.is_syntactic_predicate)
              @dfa.attr_nfa.attr_grammar.syn_pred_used_in_dfa(@dfa, sem_ctx)
            end
          else
            if (nondeterministic_alts.contains(Utils.integer(configuration.attr_alt)))
              # resolve all configurations for nondeterministic alts
              # for which there is no predicate context by turning it off
              configuration.attr_resolved = true
            end
          end
          i += 1
        end
        return true
      end
      return false # couldn't fix the problem with predicates
    end
    
    typesig { [DFAState, JavaSet] }
    # Return a mapping from nondeterministc alt to combined list of predicates.
    # If both (s|i|semCtx1) and (t|i|semCtx2) exist, then the proper predicate
    # for alt i is semCtx1||semCtx2 because you have arrived at this single
    # DFA state via two NFA paths, both of which have semantic predicates.
    # We ignore deterministic alts because syntax alone is sufficient
    # to predict those.  Do not include their predicates.
    # 
    # Alts with no predicate are assumed to have {true}? pred.
    # 
    # When combining via || with "true", all predicates are removed from
    # consideration since the expression will always be true and hence
    # not tell us how to resolve anything.  So, if any NFA configuration
    # in this DFA state does not have a semantic context, the alt cannot
    # be resolved with a predicate.
    # 
    # If nonnull, incidentEdgeLabel tells us what NFA transition label
    # we did a reach on to compute state d.  d may have insufficient
    # preds, so we really want this for the error message.
    def get_predicates_per_non_deterministic_alt(d, nondeterministic_alts)
      # map alt to combined SemanticContext
      alt_to_predicate_context_map = HashMap.new
      # init the alt to predicate set map
      alt_to_set_of_contexts_map = HashMap.new
      it = nondeterministic_alts.iterator
      while it.has_next
        alt_i = it.next_
        alt_to_set_of_contexts_map.put(alt_i, HashSet.new)
      end
      # List<Label> sampleInputLabels = d.dfa.probe.getSampleNonDeterministicInputSequence(d);
      # String input = d.dfa.probe.getInputSequenceDisplay(sampleInputLabels);
      # System.out.println("sample input: "+input);
      # for each configuration, create a unique set of predicates
      # Also, track the alts with at least one uncovered configuration
      # (one w/o a predicate); tracks tautologies like p1||true
      alt_to_locations_reachable_without_predicate = HashMap.new
      nondet_alts_with_uncovered_configuration = HashSet.new
      # System.out.println("configs="+d.nfaConfigurations);
      # System.out.println("configs with preds?"+d.atLeastOneConfigurationHasAPredicate);
      # System.out.println("configs with preds="+d.configurationsWithPredicateEdges);
      num_configs = d.attr_nfa_configurations.size
      i = 0
      while i < num_configs
        configuration = d.attr_nfa_configurations.get(i)
        alt_i = Utils.integer(configuration.attr_alt)
        # if alt is nondeterministic, combine its predicates
        if (nondeterministic_alts.contains(alt_i))
          # if there is a predicate for this NFA configuration, OR in
          if (!(configuration.attr_semantic_context).equal?(SemanticContext::EMPTY_SEMANTIC_CONTEXT))
            pred_set = alt_to_set_of_contexts_map.get(alt_i)
            pred_set.add(configuration.attr_semantic_context)
          else
            # if no predicate, but it's part of nondeterministic alt
            # then at least one path exists not covered by a predicate.
            # must remove predicate for this alt; track incomplete alts
            nondet_alts_with_uncovered_configuration.add(alt_i)
            # NFAState s = dfa.nfa.getState(configuration.state);
            # System.out.println("###\ndec "+dfa.decisionNumber+" alt "+configuration.alt+
            #                    " enclosing rule for nfa state not covered "+
            #                    s.enclosingRule);
            # if ( s.associatedASTNode!=null ) {
            #     System.out.println("token="+s.associatedASTNode.token);
            # }
            # System.out.println("nfa state="+s);
            # 
            # if ( s.incidentEdgeLabel!=null && Label.intersect(incidentEdgeLabel, s.incidentEdgeLabel) ) {
            #     Set<Token> locations = altToLocationsReachableWithoutPredicate.get(altI);
            #     if ( locations==null ) {
            #         locations = new HashSet<Token>();
            #         altToLocationsReachableWithoutPredicate.put(altI, locations);
            #     }
            #     locations.add(s.associatedASTNode.token);
            # }
          end
        end
        i += 1
      end
      # For each alt, OR together all unique predicates associated with
      # all configurations
      # Also, track the list of incompletely covered alts: those alts
      # with at least 1 predicate and at least one configuration w/o a
      # predicate. We want this in order to report to the decision probe.
      incompletely_covered_alts = ArrayList.new
      it_ = nondeterministic_alts.iterator
      while it_.has_next
        alt_i = it_.next_
        contexts_for_this_alt = alt_to_set_of_contexts_map.get(alt_i)
        if (nondet_alts_with_uncovered_configuration.contains(alt_i))
          # >= 1 config has no ctx
          if (contexts_for_this_alt.size > 0)
            # && at least one pred
            incompletely_covered_alts.add(alt_i) # this alt incompleted covered
          end
          next # don't include at least 1 config has no ctx
        end
        combined_context = nil
        itr_set = contexts_for_this_alt.iterator
        while itr_set.has_next
          ctx = itr_set.next_
          combined_context = SemanticContext.or_(combined_context, ctx)
        end
        alt_to_predicate_context_map.put(alt_i, combined_context)
      end
      if (incompletely_covered_alts.size > 0)
        # System.out.println("prob in dec "+dfa.decisionNumber+" state="+d);
        # FASerializer serializer = new FASerializer(dfa.nfa.grammar);
        # String result = serializer.serialize(dfa.startState);
        # System.out.println("dfa: "+result);
        # System.out.println("incomplete alts: "+incompletelyCoveredAlts);
        # System.out.println("nondet="+nondeterministicAlts);
        # System.out.println("nondetAltsWithUncoveredConfiguration="+ nondetAltsWithUncoveredConfiguration);
        # System.out.println("altToCtxMap="+altToSetOfContextsMap);
        # System.out.println("altToPredicateContextMap="+altToPredicateContextMap);
        i_ = 0
        while i_ < num_configs
          configuration = d.attr_nfa_configurations.get(i_)
          alt_i = Utils.integer(configuration.attr_alt)
          if (incompletely_covered_alts.contains(alt_i) && (configuration.attr_semantic_context).equal?(SemanticContext::EMPTY_SEMANTIC_CONTEXT))
            s = @dfa.attr_nfa.get_state(configuration.attr_state)
            # System.out.print("nondet config w/o context "+configuration+
            #                  " incident "+(s.incidentEdgeLabel!=null?s.incidentEdgeLabel.toString(dfa.nfa.grammar):null));
            # if ( s.associatedASTNode!=null ) {
            #     System.out.print(" token="+s.associatedASTNode.token);
            # }
            # else System.out.println();
            # We want to report getting to an NFA state with an
            # incoming label, unless it's EOF, w/o a predicate.
            if (!(s.attr_incident_edge_label).nil? && !(s.attr_incident_edge_label.attr_label).equal?(Label::EOF))
              if ((s.attr_associated_astnode).nil? || (s.attr_associated_astnode.attr_token).nil?)
                ErrorManager.internal_error("no AST/token for nonepsilon target w/o predicate")
              else
                locations = alt_to_locations_reachable_without_predicate.get(alt_i)
                if ((locations).nil?)
                  locations = HashSet.new
                  alt_to_locations_reachable_without_predicate.put(alt_i, locations)
                end
                locations.add(s.attr_associated_astnode.attr_token)
              end
            end
          end
          i_ += 1
        end
        @dfa.attr_probe.report_incompletely_covered_alts(d, alt_to_locations_reachable_without_predicate)
      end
      return alt_to_predicate_context_map
    end
    
    class_module.module_eval {
      typesig { [Map] }
      # OR together all predicates from the alts.  Note that the predicate
      # for an alt could itself be a combination of predicates.
      def get_union_of_predicates(alt_to_pred_map)
        iter = nil
        union_of_predicates_from_all_alts = nil
        iter = alt_to_pred_map.values.iterator
        while (iter.has_next)
          sem_ctx = iter.next_
          if ((union_of_predicates_from_all_alts).nil?)
            union_of_predicates_from_all_alts = sem_ctx
          else
            union_of_predicates_from_all_alts = SemanticContext.or_(union_of_predicates_from_all_alts, sem_ctx)
          end
        end
        return union_of_predicates_from_all_alts
      end
    }
    
    typesig { [DFAState] }
    # for each NFA config in d, look for "predicate required" sign set
    # during nondeterminism resolution.
    # 
    # Add the predicate edges sorted by the alternative number; I'm fairly
    # sure that I could walk the configs backwards so they are added to
    # the predDFATarget in the right order, but it's best to make sure.
    # Predicates succeed in the order they are specifed.  Alt i wins
    # over alt i+1 if both predicates are true.
    def add_predicate_transitions(d)
      configs_with_preds = ArrayList.new
      # get a list of all configs with predicates
      num_configs = d.attr_nfa_configurations.size
      i = 0
      while i < num_configs
        c = d.attr_nfa_configurations.get(i)
        if (c.attr_resolve_with_predicate)
          configs_with_preds.add(c)
        end
        i += 1
      end
      Collections.sort(configs_with_preds, # Sort ascending according to alt; alt i has higher precedence than i+1
      Class.new(Comparator.class == Class ? Comparator : Object) do
        local_class_in NFAToDFAConverter
        include_class_members NFAToDFAConverter
        include Comparator if Comparator.class == Module
        
        typesig { [Object, Object] }
        define_method :compare do |a, b|
          ca = a
          cb = b
          if (ca.attr_alt < cb.attr_alt)
            return -1
          else
            if (ca.attr_alt > cb.attr_alt)
              return 1
            end
          end
          return 0
        end
        
        typesig { [Vararg.new(Object)] }
        define_method :initialize do |*args|
          super(*args)
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      pred_configs_sorted_by_alt = configs_with_preds
      # Now, we can add edges emanating from d for these preds in right order
      i_ = 0
      while i_ < pred_configs_sorted_by_alt.size
        c = pred_configs_sorted_by_alt.get(i_)
        pred_dfatarget = d.attr_dfa.get_accept_state(c.attr_alt)
        if ((pred_dfatarget).nil?)
          pred_dfatarget = @dfa.new_state # create if not there.
          # create a new DFA state that is a target of the predicate from d
          pred_dfatarget.add_nfaconfiguration(@dfa.attr_nfa.get_state(c.attr_state), c.attr_alt, c.attr_context, c.attr_semantic_context)
          pred_dfatarget.set_accept_state(true)
          @dfa.set_accept_state(c.attr_alt, pred_dfatarget)
          existing_state = @dfa.add_state(pred_dfatarget)
          if (!(pred_dfatarget).equal?(existing_state))
            # already there...use/return the existing DFA state that
            # is a target of this predicate.  Make this state number
            # point at the existing state
            @dfa.set_state(pred_dfatarget.attr_state_number, existing_state)
            pred_dfatarget = existing_state
          end
        end
        # add a transition to pred target from d
        d.add_transition(pred_dfatarget, PredicateLabel.new(c.attr_semantic_context))
        i_ += 1
      end
    end
    
    typesig { [::Java::Int] }
    def init_context_trees(number_of_alts)
      @context_trees = Array.typed(NFAContext).new(number_of_alts) { nil }
      i = 0
      while i < @context_trees.attr_length
        alt = i + 1
        # add a dummy root node so that an NFA configuration can
        # always point at an NFAContext.  If a context refers to this
        # node then it implies there is no call stack for
        # that configuration
        @context_trees[i] = NFAContext.new(nil, nil)
        i += 1
      end
    end
    
    class_module.module_eval {
      typesig { [JavaSet] }
      def max(s)
        if ((s).nil?)
          return JavaInteger::MIN_VALUE
        end
        i = 0
        m = 0
        it = s.iterator
        while it.has_next
          i += 1
          i_ = it.next_
          if ((i).equal?(1))
            # init m with first value
            m = i_.int_value
            next
          end
          if (i_.int_value > m)
            m = i_.int_value
          end
        end
        return m
      end
    }
    
    private
    alias_method :initialize__nfato_dfaconverter, :initialize
  end
  
end
