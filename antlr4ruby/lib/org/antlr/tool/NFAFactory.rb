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
module Org::Antlr::Tool
  module NFAFactoryImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :IntSet
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Java::Util, :Iterator
      include_const ::Java::Util, :JavaList
      include_const ::Antlr, :Token
    }
  end
  
  # Routines to construct StateClusters from EBNF grammar constructs.
  # No optimization is done to remove unnecessary epsilon edges.
  # 
  # TODO: add an optimization that reduces number of states and transitions
  # will help with speed of conversion and make it easier to view NFA.  For
  # example, o-A->o-->o-B->o should be o-A->o-B->o
  class NFAFactory 
    include_class_members NFAFactoryImports
    
    # This factory is attached to a specifc NFA that it is building.
    # The NFA will be filled up with states and transitions.
    attr_accessor :nfa
    alias_method :attr_nfa, :nfa
    undef_method :nfa
    alias_method :attr_nfa=, :nfa=
    undef_method :nfa=
    
    attr_accessor :current_rule
    alias_method :attr_current_rule, :current_rule
    undef_method :current_rule
    alias_method :attr_current_rule=, :current_rule=
    undef_method :current_rule=
    
    typesig { [NFA] }
    def initialize(nfa)
      @nfa = nil
      @current_rule = nil
      nfa.set_factory(self)
      @nfa = nfa
    end
    
    typesig { [] }
    def new_state
      n = NFAState.new(@nfa)
      state = @nfa.get_new_nfastate_number
      n.attr_state_number = state
      @nfa.add_state(n)
      n.attr_enclosing_rule = @current_rule
      return n
    end
    
    typesig { [StateCluster] }
    # Optimize an alternative (list of grammar elements).
    # 
    # Walk the chain of elements (which can be complicated loop blocks...)
    # and throw away any epsilon transitions used to link up simple elements.
    # 
    # This only removes 195 states from the java.g's NFA, but every little
    # bit helps.  Perhaps I can improve in the future.
    def optimize_alternative(alt)
      s = alt.attr_left
      while (!(s).equal?(alt.attr_right))
        # if it's a block element, jump over it and continue
        if (!(s.attr_end_of_block_state_number).equal?(State::INVALID_STATE_NUMBER))
          s = @nfa.get_state(s.attr_end_of_block_state_number)
          next
        end
        t = s.attr_transition[0]
        if (t.is_a?(RuleClosureTransition))
          s = (t).attr_follow_state
          next
        end
        if (t.attr_label.is_epsilon && !t.attr_label.is_action && (s.get_number_of_transitions).equal?(1))
          # bypass epsilon transition and point to what the epsilon's
          # target points to unless that epsilon transition points to
          # a block or loop etc..  Also don't collapse epsilons that
          # point at the last node of the alt. Don't collapse action edges
          epsilon_target = t.attr_target
          if ((epsilon_target.attr_end_of_block_state_number).equal?(State::INVALID_STATE_NUMBER) && !(epsilon_target.attr_transition[0]).nil?)
            s.set_transition0(epsilon_target.attr_transition[0])
            # 					System.out.println("### opt "+s.stateNumber+"->"+
            # 									   epsilonTarget.transition(0).target.stateNumber);
          end
        end
        s = t.attr_target
      end
    end
    
    typesig { [::Java::Int, GrammarAST] }
    # From label A build Graph o-A->o
    def build__atom(label, associated_ast)
      left = new_state
      right = new_state
      left.attr_associated_astnode = associated_ast
      right.attr_associated_astnode = associated_ast
      transition_between_states(left, right, label)
      g = StateCluster.new(left, right)
      return g
    end
    
    typesig { [GrammarAST] }
    def build__atom(atom_ast)
      token_type = @nfa.attr_grammar.get_token_type(atom_ast.get_text)
      return build__atom(token_type, atom_ast)
    end
    
    typesig { [IntSet, GrammarAST] }
    # From set build single edge graph o->o-set->o.  To conform to
    # what an alt block looks like, must have extra state on left.
    def build__set(set, associated_ast)
      left = new_state
      right = new_state
      left.attr_associated_astnode = associated_ast
      right.attr_associated_astnode = associated_ast
      label = Label.new(set)
      e = Transition.new(label, right)
      left.add_transition(e)
      g = StateCluster.new(left, right)
      return g
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # Can only complement block of simple alts; can complement build_Set()
    # result, that is.  Get set and complement, replace old with complement.
    #    public StateCluster build_AlternativeBlockComplement(StateCluster blk) {
    #        State s0 = blk.left;
    #        IntSet set = getCollapsedBlockAsSet(s0);
    #        if ( set!=null ) {
    #            // if set is available, then structure known and blk is a set
    #            set = nfa.grammar.complement(set);
    #            Label label = s0.transition(0).target.transition(0).label;
    #            label.setSet(set);
    #        }
    #        return blk;
    #    }
    def build__range(a, b)
      left = new_state
      right = new_state
      label = Label.new(IntervalSet.of(a, b))
      e = Transition.new(label, right)
      left.add_transition(e)
      g = StateCluster.new(left, right)
      return g
    end
    
    typesig { [GrammarAST] }
    # From char 'c' build StateCluster o-intValue(c)->o
    def build__char_literal_atom(char_literal_ast)
      c = Grammar.get_char_value_from_grammar_char_literal(char_literal_ast.get_text)
      return build__atom(c, char_literal_ast)
    end
    
    typesig { [String, String] }
    # From char 'c' build StateCluster o-intValue(c)->o
    # can include unicode spec likes '\u0024' later.  Accepts
    # actual unicode 16-bit now, of course, by default.
    # TODO not supplemental char clean!
    def build__char_range(a, b)
      from = Grammar.get_char_value_from_grammar_char_literal(a)
      to = Grammar.get_char_value_from_grammar_char_literal(b)
      return build__range(from, to)
    end
    
    typesig { [GrammarAST] }
    # For a non-lexer, just build a simple token reference atom.
    # For a lexer, a string is a sequence of char to match.  That is,
    # "fog" is treated as 'f' 'o' 'g' not as a single transition in
    # the DFA.  Machine== o-'f'->o-'o'->o-'g'->o and has n+1 states
    # for n characters.
    def build__string_literal_atom(string_literal_ast)
      if ((@nfa.attr_grammar.attr_type).equal?(Grammar::LEXER))
        chars = Grammar.get_unescaped_string_from_grammar_string_literal(string_literal_ast.get_text)
        first = new_state
        last = nil
        prev = first
        i = 0
        while i < chars.length
          c = chars.char_at(i)
          next_ = new_state
          transition_between_states(prev, next_, c)
          prev = last = next_
          i += 1
        end
        return StateCluster.new(first, last)
      end
      # a simple token reference in non-Lexers
      token_type = @nfa.attr_grammar.get_token_type(string_literal_ast.get_text)
      return build__atom(token_type, string_literal_ast)
    end
    
    typesig { [Rule, NFAState] }
    # For reference to rule r, build
    # 
    # o-e->(r)  o
    # 
    # where (r) is the start of rule r and the trailing o is not linked
    # to from rule ref state directly (it's done thru the transition(0)
    # RuleClosureTransition.
    # 
    # If the rule r is just a list of tokens, it's block will be just
    # a set on an edge o->o->o-set->o->o->o, could inline it rather than doing
    # the rule reference, but i'm not doing this yet as I'm not sure
    # it would help much in the NFA->DFA construction.
    # 
    # TODO add to codegen: collapse alt blks that are sets into single matchSet
    def build__rule_ref(ref_def, rule_start)
      # System.out.println("building ref to rule "+nfa.grammar.name+"."+refDef.name);
      left = new_state
      # left.setDescription("ref to "+ruleStart.getDescription());
      right = new_state
      # right.setDescription("NFAState following ref to "+ruleStart.getDescription());
      e = RuleClosureTransition.new(ref_def, rule_start, right)
      left.add_transition(e)
      g = StateCluster.new(left, right)
      return g
    end
    
    typesig { [] }
    # From an empty alternative build StateCluster o-e->o
    def build__epsilon
      left = new_state
      right = new_state
      transition_between_states(left, right, Label::EPSILON)
      g = StateCluster.new(left, right)
      return g
    end
    
    typesig { [GrammarAST] }
    # Build what amounts to an epsilon transition with a semantic
    # predicate action.  The pred is a pointer into the AST of
    # the SEMPRED token.
    def build__semantic_predicate(pred)
      # don't count syn preds
      if (!pred.get_text.to_upper_case.starts_with(Grammar::SYNPRED_RULE_PREFIX.to_upper_case))
        @nfa.attr_grammar.attr_number_of_semantic_predicates += 1
      end
      left = new_state
      right = new_state
      e = Transition.new(PredicateLabel.new(pred), right)
      left.add_transition(e)
      g = StateCluster.new(left, right)
      return g
    end
    
    typesig { [GrammarAST] }
    # Build what amounts to an epsilon transition with an action.
    # The action goes into NFA though it is ignored during analysis.
    # It slows things down a bit, but I must ignore predicates after
    # having seen an action (5-5-2008).
    def build__action(action)
      left = new_state
      right = new_state
      e = Transition.new(ActionLabel.new(action), right)
      left.add_transition(e)
      return StateCluster.new(left, right)
    end
    
    typesig { [JavaList] }
    # add an EOF transition to any rule end NFAState that points to nothing
    # (i.e., for all those rules not invoked by another rule).  These
    # are start symbols then.
    # 
    # Return the number of grammar entry points; i.e., how many rules are
    # not invoked by another rule (they can only be invoked from outside).
    # These are the start rules.
    def build__eofstates(rules)
      number_un_invoked_rules = 0
      iterator_ = rules.iterator
      while iterator_.has_next
        r = iterator_.next_
        end_nfastate = r.attr_stop_state
        # Is this rule a start symbol?  (no follow links)
        if ((end_nfastate.attr_transition[0]).nil?)
          # if so, then don't let algorithm fall off the end of
          # the rule, make it hit EOF/EOT.
          build__eofstate(end_nfastate)
          # track how many rules have been invoked by another rule
          number_un_invoked_rules += 1
        end
      end
      return number_un_invoked_rules
    end
    
    typesig { [NFAState] }
    # set up an NFA NFAState that will yield eof tokens or,
    # in the case of a lexer grammar, an EOT token when the conversion
    # hits the end of a rule.
    def build__eofstate(end_nfastate)
      end_ = new_state
      label = Label::EOF
      if ((@nfa.attr_grammar.attr_type).equal?(Grammar::LEXER))
        label = Label::EOT
        end_.set_eottarget_state(true)
      end
      # 		System.out.println("build "+nfa.grammar.getTokenDisplayName(label)+
      # 						   " loop on end of state "+endNFAState.getDescription()+
      # 						   " to state "+end.stateNumber);
      to_end = Transition.new(label, end_)
      end_nfastate.add_transition(to_end)
    end
    
    typesig { [StateCluster, StateCluster] }
    # From A B build A-e->B (that is, build an epsilon arc from right
    # of A to left of B).
    # 
    # As a convenience, return B if A is null or return A if B is null.
    def build__ab(a, b)
      if ((a).nil?)
        return b
      end
      if ((b).nil?)
        return a
      end
      transition_between_states(a.attr_right, b.attr_left, Label::EPSILON)
      g = StateCluster.new(a.attr_left, b.attr_right)
      return g
    end
    
    typesig { [StateCluster] }
    # From a set ('a'|'b') build
    # 
    # o->o-'a'..'b'->o->o (last NFAState is blockEndNFAState pointed to by all alts)
    def build__alternative_block_from_set(set)
      if ((set).nil?)
        return nil
      end
      # single alt, no decision, just return only alt state cluster
      start_of_alt = new_state # must have this no matter what
      transition_between_states(start_of_alt, set.attr_left, Label::EPSILON)
      return StateCluster.new(start_of_alt, set.attr_right)
    end
    
    typesig { [JavaList] }
    # From A|B|..|Z alternative block build
    # 
    # o->o-A->o->o (last NFAState is blockEndNFAState pointed to by all alts)
    # |          ^
    # o->o-B->o--|
    # |          |
    # ...        |
    # |          |
    # o->o-Z->o--|
    # 
    # So every alternative gets begin NFAState connected by epsilon
    # and every alt right side points at a block end NFAState.  There is a
    # new NFAState in the NFAState in the StateCluster for each alt plus one for the
    # end NFAState.
    # 
    # Special case: only one alternative: don't make a block with alt
    # begin/end.
    # 
    # Special case: if just a list of tokens/chars/sets, then collapse
    # to a single edge'd o-set->o graph.
    # 
    # Set alt number (1..n) in the left-Transition NFAState.
    def build__alternative_block(alternative_state_clusters)
      result = nil
      if ((alternative_state_clusters).nil? || (alternative_state_clusters.size).equal?(0))
        return nil
      end
      # single alt case
      if ((alternative_state_clusters.size).equal?(1))
        # single alt, no decision, just return only alt state cluster
        g = alternative_state_clusters.get(0)
        start_of_alt = new_state # must have this no matter what
        transition_between_states(start_of_alt, g.attr_left, Label::EPSILON)
        # System.out.println("### opt saved start/stop end in (...)");
        return StateCluster.new(start_of_alt, g.attr_right)
      end
      # even if we can collapse for lookahead purposes, we will still
      # need to predict the alts of this subrule in case there are actions
      # etc...  This is the decision that is pointed to from the AST node
      # (always)
      prev_alternative = nil # tracks prev so we can link to next alt
      first_alt = nil
      block_end_nfastate = new_state
      block_end_nfastate.set_description("end block")
      alt_num = 1
      iter = alternative_state_clusters.iterator
      while iter.has_next
        g = iter.next_
        # add begin NFAState for this alt connected by epsilon
        left = new_state
        left.set_description("alt " + RJava.cast_to_string(alt_num) + " of ()")
        transition_between_states(left, g.attr_left, Label::EPSILON)
        transition_between_states(g.attr_right, block_end_nfastate, Label::EPSILON)
        # Are we the first alternative?
        if ((first_alt).nil?)
          first_alt = left # track extreme left node of StateCluster
        else
          # if not first alternative, must link to this alt from previous
          transition_between_states(prev_alternative, left, Label::EPSILON)
        end
        prev_alternative = left
        alt_num += 1
      end
      # return StateCluster pointing representing entire block
      # Points to first alt NFAState on left, block end on right
      result = StateCluster.new(first_alt, block_end_nfastate)
      first_alt.attr_decision_state_type = NFAState::BLOCK_START
      # set EOB markers for Jean
      first_alt.attr_end_of_block_state_number = block_end_nfastate.attr_state_number
      return result
    end
    
    typesig { [StateCluster] }
    # From (A)? build either:
    # 
    # o--A->o
    # |     ^
    # o---->|
    # 
    # or, if A is a block, just add an empty alt to the end of the block
    def build__aoptional(a)
      g = nil
      n = @nfa.attr_grammar.get_number_of_alts_for_decision_nfa(a.attr_left)
      if ((n).equal?(1))
        # no decision, just wrap in an optional path
        # NFAState decisionState = newState();
        decision_state = a.attr_left # resuse left edge
        decision_state.set_description("only alt of ()? block")
        empty_alt = new_state
        empty_alt.set_description("epsilon path of ()? block")
        block_end_nfastate = nil
        block_end_nfastate = new_state
        transition_between_states(a.attr_right, block_end_nfastate, Label::EPSILON)
        block_end_nfastate.set_description("end ()? block")
        # transitionBetweenStates(decisionState, A.left, Label.EPSILON);
        transition_between_states(decision_state, empty_alt, Label::EPSILON)
        transition_between_states(empty_alt, block_end_nfastate, Label::EPSILON)
        # set EOB markers for Jean
        decision_state.attr_end_of_block_state_number = block_end_nfastate.attr_state_number
        block_end_nfastate.attr_decision_state_type = NFAState::RIGHT_EDGE_OF_BLOCK
        g = StateCluster.new(decision_state, block_end_nfastate)
      else
        # a decision block, add an empty alt
        last_real_alt = @nfa.attr_grammar.get_nfastate_for_alt_of_decision(a.attr_left, n)
        empty_alt = new_state
        empty_alt.set_description("epsilon path of ()? block")
        transition_between_states(last_real_alt, empty_alt, Label::EPSILON)
        transition_between_states(empty_alt, a.attr_right, Label::EPSILON)
        # set EOB markers for Jean (I think this is redundant here)
        a.attr_left.attr_end_of_block_state_number = a.attr_right.attr_state_number
        a.attr_right.attr_decision_state_type = NFAState::RIGHT_EDGE_OF_BLOCK
        g = a # return same block, but now with optional last path
      end
      g.attr_left.attr_decision_state_type = NFAState::OPTIONAL_BLOCK_START
      return g
    end
    
    typesig { [StateCluster] }
    # From (A)+ build
    # 
    # |---|    (Transition 2 from A.right points at alt 1)
    # v   |    (follow of loop is Transition 1)
    # o->o-A-o->o
    # 
    # Meaning that the last NFAState in A points back to A's left Transition NFAState
    # and we add a new begin/end NFAState.  A can be single alternative or
    # multiple.
    # 
    # During analysis we'll call the follow link (transition 1) alt n+1 for
    # an n-alt A block.
    def build__aplus(a)
      left = new_state
      block_end_nfastate = new_state
      block_end_nfastate.attr_decision_state_type = NFAState::RIGHT_EDGE_OF_BLOCK
      # don't reuse A.right as loopback if it's right edge of another block
      if ((a.attr_right.attr_decision_state_type).equal?(NFAState::RIGHT_EDGE_OF_BLOCK))
        # nested A* so make another tail node to be the loop back
        # instead of the usual A.right which is the EOB for inner loop
        extra_right_edge = new_state
        transition_between_states(a.attr_right, extra_right_edge, Label::EPSILON)
        a.attr_right = extra_right_edge
      end
      transition_between_states(a.attr_right, block_end_nfastate, Label::EPSILON) # follow is Transition 1
      # turn A's block end into a loopback (acts like alt 2)
      transition_between_states(a.attr_right, a.attr_left, Label::EPSILON) # loop back Transition 2
      transition_between_states(left, a.attr_left, Label::EPSILON)
      a.attr_right.attr_decision_state_type = NFAState::LOOPBACK
      a.attr_left.attr_decision_state_type = NFAState::BLOCK_START
      # set EOB markers for Jean
      a.attr_left.attr_end_of_block_state_number = a.attr_right.attr_state_number
      g = StateCluster.new(left, block_end_nfastate)
      return g
    end
    
    typesig { [StateCluster] }
    # From (A)* build
    # 
    # |---|
    # v   |
    # o->o-A-o--o (Transition 2 from block end points at alt 1; follow is Transition 1)
    # |         ^
    # o---------| (optional branch is 2nd alt of optional block containing A+)
    # 
    # Meaning that the last (end) NFAState in A points back to A's
    # left side NFAState and we add 3 new NFAStates (the
    # optional branch is built just like an optional subrule).
    # See the Aplus() method for more on the loop back Transition.
    # The new node on right edge is set to RIGHT_EDGE_OF_CLOSURE so we
    # can detect nested (A*)* loops and insert an extra node.  Previously,
    # two blocks shared same EOB node.
    # 
    # There are 2 or 3 decision points in a A*.  If A is not a block (i.e.,
    # it only has one alt), then there are two decisions: the optional bypass
    # and then loopback.  If A is a block of alts, then there are three
    # decisions: bypass, loopback, and A's decision point.
    # 
    # Note that the optional bypass must be outside the loop as (A|B)* is
    # not the same thing as (A|B|)+.
    # 
    # This is an accurate NFA representation of the meaning of (A)*, but
    # for generating code, I don't need a DFA for the optional branch by
    # virtue of how I generate code.  The exit-loopback-branch decision
    # is sufficient to let me make an appropriate enter, exit, loop
    # determination.  See codegen.g
    def build__astar(a)
      bypass_decision_state = new_state
      bypass_decision_state.set_description("enter loop path of ()* block")
      optional_alt = new_state
      optional_alt.set_description("epsilon path of ()* block")
      block_end_nfastate = new_state
      block_end_nfastate.attr_decision_state_type = NFAState::RIGHT_EDGE_OF_BLOCK
      # don't reuse A.right as loopback if it's right edge of another block
      if ((a).nil?)
        System.out.println("what?")
      end
      if ((a.attr_right.attr_decision_state_type).equal?(NFAState::RIGHT_EDGE_OF_BLOCK))
        # nested A* so make another tail node to be the loop back
        # instead of the usual A.right which is the EOB for inner loop
        extra_right_edge = new_state
        transition_between_states(a.attr_right, extra_right_edge, Label::EPSILON)
        a.attr_right = extra_right_edge
      end
      # convert A's end block to loopback
      a.attr_right.set_description("()* loopback")
      # Transition 1 to actual block of stuff
      transition_between_states(bypass_decision_state, a.attr_left, Label::EPSILON)
      # Transition 2 optional to bypass
      transition_between_states(bypass_decision_state, optional_alt, Label::EPSILON)
      transition_between_states(optional_alt, block_end_nfastate, Label::EPSILON)
      # Transition 1 of end block exits
      transition_between_states(a.attr_right, block_end_nfastate, Label::EPSILON)
      # Transition 2 of end block loops
      transition_between_states(a.attr_right, a.attr_left, Label::EPSILON)
      bypass_decision_state.attr_decision_state_type = NFAState::BYPASS
      a.attr_left.attr_decision_state_type = NFAState::BLOCK_START
      a.attr_right.attr_decision_state_type = NFAState::LOOPBACK
      # set EOB markers for Jean
      a.attr_left.attr_end_of_block_state_number = a.attr_right.attr_state_number
      bypass_decision_state.attr_end_of_block_state_number = block_end_nfastate.attr_state_number
      g = StateCluster.new(bypass_decision_state, block_end_nfastate)
      return g
    end
    
    typesig { [] }
    # Build an NFA predictor for special rule called Tokens manually that
    # predicts which token will succeed.  The refs to the rules are not
    # RuleRefTransitions as I want DFA conversion to stop at the EOT
    # transition on the end of each token, rather than return to Tokens rule.
    # If I used normal build_alternativeBlock for this, the RuleRefTransitions
    # would save return address when jumping away from Tokens rule.
    # 
    # All I do here is build n new states for n rules with an epsilon
    # edge to the rule start states and then to the next state in the
    # list:
    # 
    # o->(A)  (a state links to start of A and to next in list)
    # |
    # o->(B)
    # |
    # ...
    # |
    # o->(Z)
    # 
    # This is the NFA created for the artificial rule created in
    # Grammar.addArtificialMatchTokensRule().
    # 
    # 11/28/2005: removed so we can use normal rule construction for Tokens.
    #    public NFAState build_ArtificialMatchTokensRuleNFA() {
    #        int altNum = 1;
    #        NFAState firstAlt = null; // the start state for the "rule"
    #        NFAState prevAlternative = null;
    #        Iterator iter = nfa.grammar.getRules().iterator();
    # 		// TODO: add a single decision node/state for good description
    #        while (iter.hasNext()) {
    # 			Rule r = (Rule) iter.next();
    #            String ruleName = r.name;
    # 			String modifier = nfa.grammar.getRuleModifier(ruleName);
    #            if ( ruleName.equals(Grammar.ARTIFICIAL_TOKENS_RULENAME) ||
    # 				 (modifier!=null &&
    # 				  modifier.equals(Grammar.FRAGMENT_RULE_MODIFIER)) )
    # 			{
    #                continue; // don't loop to yourself or do nontoken rules
    #            }
    #            NFAState ruleStartState = nfa.grammar.getRuleStartState(ruleName);
    #            NFAState left = newState();
    #            left.setDescription("alt "+altNum+" of artificial rule "+Grammar.ARTIFICIAL_TOKENS_RULENAME);
    #            transitionBetweenStates(left, ruleStartState, Label.EPSILON);
    #            // Are we the first alternative?
    #            if ( firstAlt==null ) {
    #                firstAlt = left; // track extreme top left node as rule start
    #            }
    #            else {
    #                // if not first alternative, must link to this alt from previous
    #                transitionBetweenStates(prevAlternative, left, Label.EPSILON);
    #            }
    #            prevAlternative = left;
    #            altNum++;
    #        }
    # 		firstAlt.decisionStateType = NFAState.BLOCK_START;
    # 
    #        return firstAlt;
    #    }
    # Build an atom with all possible values in its label
    def build__wildcard
      left = new_state
      right = new_state
      label = Label.new(@nfa.attr_grammar.get_token_types) # char or tokens
      e = Transition.new(label, right)
      left.add_transition(e)
      g = StateCluster.new(left, right)
      return g
    end
    
    typesig { [State] }
    # Given a collapsed block of alts (a set of atoms), pull out
    # the set and return it.
    def get_collapsed_block_as_set(blk)
      s0 = blk
      if (!(s0).nil? && !(s0.transition(0)).nil?)
        s1 = s0.transition(0).attr_target
        if (!(s1).nil? && !(s1.transition(0)).nil?)
          label = s1.transition(0).attr_label
          if (label.is_set)
            return label.get_set
          end
        end
      end
      return nil
    end
    
    typesig { [NFAState, NFAState, ::Java::Int] }
    def transition_between_states(a, b, label)
      e = Transition.new(label, b)
      a.add_transition(e)
    end
    
    private
    alias_method :initialize__nfafactory, :initialize
  end
  
end
