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
  module LL1AnalyzerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :Rule
      include_const ::Org::Antlr::Tool, :ANTLRParser
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Org::Antlr::Misc, :IntSet
      include ::Java::Util
    }
  end
  
  # Created by IntelliJ IDEA.
  # User: parrt
  # Date: Dec 31, 2007
  # Time: 1:31:16 PM
  # To change this template use File | Settings | File Templates.
  class LL1Analyzer 
    include_class_members LL1AnalyzerImports
    
    class_module.module_eval {
      # 0	if we hit end of rule and invoker should keep going (epsilon)
      const_set_lazy(:DETECT_PRED_EOR) { 0 }
      const_attr_reader  :DETECT_PRED_EOR
      
      # 1	if we found a nonautobacktracking pred
      const_set_lazy(:DETECT_PRED_FOUND) { 1 }
      const_attr_reader  :DETECT_PRED_FOUND
      
      # 2	if we didn't find such a pred
      const_set_lazy(:DETECT_PRED_NOT_FOUND) { 2 }
      const_attr_reader  :DETECT_PRED_NOT_FOUND
    }
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    # Used during LOOK to detect computation cycles
    attr_accessor :look_busy
    alias_method :attr_look_busy, :look_busy
    undef_method :look_busy
    alias_method :attr_look_busy=, :look_busy=
    undef_method :look_busy=
    
    attr_accessor :firstcache
    alias_method :attr_firstcache, :firstcache
    undef_method :firstcache
    alias_method :attr_firstcache=, :firstcache=
    undef_method :firstcache=
    
    attr_accessor :followcache
    alias_method :attr_followcache, :followcache
    undef_method :followcache
    alias_method :attr_followcache=, :followcache=
    undef_method :followcache=
    
    typesig { [Grammar] }
    def initialize(grammar)
      @grammar = nil
      @look_busy = HashSet.new
      @firstcache = HashMap.new
      @followcache = HashMap.new
      @grammar = grammar
    end
    
    typesig { [NFAState] }
    # public void computeRuleFIRSTSets() {
    # if ( getNumberOfDecisions()==0 ) {
    # createNFAs();
    # }
    # for (Iterator it = getRules().iterator(); it.hasNext();) {
    # Rule r = (Rule)it.next();
    # if ( r.isSynPred ) {
    # continue;
    # }
    # LookaheadSet s = FIRST(r);
    # System.out.println("FIRST("+r.name+")="+s);
    # }
    # }
    # 
    # 
    # public Set<String> getOverriddenRulesWithDifferentFIRST() {
    # // walk every rule in this grammar and compare FIRST set with
    # // those in imported grammars.
    # Set<String> rules = new HashSet();
    # for (Iterator it = getRules().iterator(); it.hasNext();) {
    # Rule r = (Rule)it.next();
    # //System.out.println(r.name+" FIRST="+r.FIRST);
    # for (int i = 0; i < delegates.size(); i++) {
    # Grammar g = delegates.get(i);
    # Rule importedRule = g.getRule(r.name);
    # if ( importedRule != null ) { // exists in imported grammar
    # // System.out.println(r.name+" exists in imported grammar: FIRST="+importedRule.FIRST);
    # if ( !r.FIRST.equals(importedRule.FIRST) ) {
    # rules.add(r.name);
    # }
    # }
    # }
    # }
    # return rules;
    # }
    # 
    # public Set<Rule> getImportedRulesSensitiveToOverriddenRulesDueToLOOK() {
    # Set<String> diffFIRSTs = getOverriddenRulesWithDifferentFIRST();
    # Set<Rule> rules = new HashSet();
    # for (Iterator it = diffFIRSTs.iterator(); it.hasNext();) {
    # String r = (String) it.next();
    # for (int i = 0; i < delegates.size(); i++) {
    # Grammar g = delegates.get(i);
    # Set<Rule> callers = g.ruleSensitivity.get(r);
    # // somebody invokes rule whose FIRST changed in subgrammar?
    # if ( callers!=null ) {
    # rules.addAll(callers);
    # //System.out.println(g.name+" rules "+callers+" sensitive to "+r+"; dup 'em");
    # }
    # }
    # }
    # return rules;
    # }
    # 
    # 
    # public LookaheadSet LOOK(Rule r) {
    # if ( r.FIRST==null ) {
    # r.FIRST = FIRST(r.startState);
    # }
    # return r.FIRST;
    # }
    # 
    # From an NFA state, s, find the set of all labels reachable from s.
    # Used to compute follow sets for error recovery.  Never computes
    # a FOLLOW operation.  FIRST stops at end of rules, returning EOR, unless
    # invoked from another rule.  I.e., routine properly handles
    # 
    # a : b A ;
    # 
    # where b is nullable.
    # 
    # We record with EOR_TOKEN_TYPE if we hit the end of a rule so we can
    # know at runtime (when these sets are used) to start walking up the
    # follow chain to compute the real, correct follow set (as opposed to
    # the FOLLOW, which is a superset).
    # 
    # This routine will only be used on parser and tree parser grammars.
    def _first(s)
      # System.out.println("> FIRST("+s.enclosingRule.name+") in rule "+s.enclosingRule);
      @look_busy.clear
      look = ___first(s, false)
      # System.out.println("< FIRST("+s.enclosingRule.name+") in rule "+s.enclosingRule+"="+look.toString(this.grammar));
      return look
    end
    
    typesig { [Rule] }
    def _follow(r)
      # System.out.println("> FOLLOW("+r.name+") in rule "+r.startState.enclosingRule);
      f = @followcache.get(r)
      if (!(f).nil?)
        return f
      end
      f = ___first(r.attr_stop_state, true)
      @followcache.put(r, f)
      # System.out.println("< FOLLOW("+r+") in rule "+r.startState.enclosingRule+"="+f.toString(this.grammar));
      return f
    end
    
    typesig { [NFAState] }
    def _look(s)
      if (NFAToDFAConverter.attr_debug)
        System.out.println("> LOOK(" + (s).to_s + ")")
      end
      @look_busy.clear
      look = ___first(s, true)
      # FOLLOW makes no sense (at the moment!) for lexical rules.
      if (!(@grammar.attr_type).equal?(Grammar::LEXER) && look.member(Label::EOR_TOKEN_TYPE))
        # avoid altering FIRST reset as it is cached
        f = _follow(s.attr_enclosing_rule)
        f.or_in_place(look)
        f.remove(Label::EOR_TOKEN_TYPE)
        look = f
        # look.orInPlace(FOLLOW(s.enclosingRule));
      else
        if ((@grammar.attr_type).equal?(Grammar::LEXER) && look.member(Label::EOT))
          # if this has EOT, lookahead is all char (all char can follow rule)
          # look = new LookaheadSet(Label.EOT);
          look = LookaheadSet.new(IntervalSet::COMPLETE_SET)
        end
      end
      if (NFAToDFAConverter.attr_debug)
        System.out.println("< LOOK(" + (s).to_s + ")=" + (look.to_s(@grammar)).to_s)
      end
      return look
    end
    
    typesig { [NFAState, ::Java::Boolean] }
    def ___first(s, chase_follow_transitions)
      # System.out.println("_LOOK("+s+") in rule "+s.enclosingRule);
      # if ( s.transition[0] instanceof RuleClosureTransition ) {
      # System.out.println("go to rule "+((NFAState)s.transition[0].target).enclosingRule);
      # }
      if (!chase_follow_transitions && s.is_accept_state)
        if ((@grammar.attr_type).equal?(Grammar::LEXER))
          # FOLLOW makes no sense (at the moment!) for lexical rules.
          # assume all char can follow
          return LookaheadSet.new(IntervalSet::COMPLETE_SET)
        end
        return LookaheadSet.new(Label::EOR_TOKEN_TYPE)
      end
      if (@look_busy.contains(s))
        # return a copy of an empty set; we may modify set inline
        return LookaheadSet.new
      end
      @look_busy.add(s)
      transition0 = s.attr_transition[0]
      if ((transition0).nil?)
        return nil
      end
      if (transition0.attr_label.is_atom)
        atom = transition0.attr_label.get_atom
        return LookaheadSet.new(atom)
      end
      if (transition0.attr_label.is_set)
        sl = transition0.attr_label.get_set
        return LookaheadSet.new(sl)
      end
      # compute FIRST of transition 0
      tset = nil
      # if transition 0 is a rule call and we don't want FOLLOW, check cache
      if (!chase_follow_transitions && transition0.is_a?(RuleClosureTransition))
        prev = @firstcache.get(transition0.attr_target)
        if (!(prev).nil?)
          tset = LookaheadSet.new(prev)
        end
      end
      # if not in cache, must compute
      if ((tset).nil?)
        tset = ___first(transition0.attr_target, chase_follow_transitions)
        # save FIRST cache for transition 0 if rule call
        if (!chase_follow_transitions && transition0.is_a?(RuleClosureTransition))
          @firstcache.put(transition0.attr_target, tset)
        end
      end
      # did we fall off the end?
      if (!(@grammar.attr_type).equal?(Grammar::LEXER) && tset.member(Label::EOR_TOKEN_TYPE))
        if (transition0.is_a?(RuleClosureTransition))
          # we called a rule that found the end of the rule.
          # That means the rule is nullable and we need to
          # keep looking at what follows the rule ref.  E.g.,
          # a : b A ; where b is nullable means that LOOK(a)
          # should include A.
          rule_invocation_trans = transition0
          # remove the EOR and get what follows
          # tset.remove(Label.EOR_TOKEN_TYPE);
          following = rule_invocation_trans.attr_follow_state
          fset = ___first(following, chase_follow_transitions)
          fset.or_in_place(tset) # tset cached; or into new set
          fset.remove(Label::EOR_TOKEN_TYPE)
          tset = fset
        end
      end
      transition1 = s.attr_transition[1]
      if (!(transition1).nil?)
        tset1 = ___first(transition1.attr_target, chase_follow_transitions)
        tset1.or_in_place(tset) # tset cached; or into new set
        tset = tset1
      end
      return tset
    end
    
    typesig { [NFAState] }
    # Is there a non-syn-pred predicate visible from s that is not in
    # the rule enclosing s?  This accounts for most predicate situations
    # and lets ANTLR do a simple LL(1)+pred computation.
    # 
    # TODO: what about gated vs regular preds?
    def detect_confounding_predicates(s)
      @look_busy.clear
      r = s.attr_enclosing_rule
      return (__detect_confounding_predicates(s, r, false)).equal?(DETECT_PRED_FOUND)
    end
    
    typesig { [NFAState, Rule, ::Java::Boolean] }
    def __detect_confounding_predicates(s, enclosing_rule, chase_follow_transitions)
      # System.out.println("_detectNonAutobacktrackPredicates("+s+")");
      if (!chase_follow_transitions && s.is_accept_state)
        if ((@grammar.attr_type).equal?(Grammar::LEXER))
          # FOLLOW makes no sense (at the moment!) for lexical rules.
          # assume all char can follow
          return DETECT_PRED_NOT_FOUND
        end
        return DETECT_PRED_EOR
      end
      if (@look_busy.contains(s))
        # return a copy of an empty set; we may modify set inline
        return DETECT_PRED_NOT_FOUND
      end
      @look_busy.add(s)
      transition0 = s.attr_transition[0]
      if ((transition0).nil?)
        return DETECT_PRED_NOT_FOUND
      end
      if (!(transition0.attr_label.is_semantic_predicate || transition0.attr_label.is_epsilon))
        return DETECT_PRED_NOT_FOUND
      end
      if (transition0.attr_label.is_semantic_predicate)
        # System.out.println("pred "+transition0.label);
        ctx = transition0.attr_label.get_semantic_context
        p = ctx
        if (!(p.attr_predicate_ast.get_type).equal?(ANTLRParser::BACKTRACK_SEMPRED))
          return DETECT_PRED_FOUND
        end
      end
      # if ( transition0.label.isSemanticPredicate() ) {
      # System.out.println("pred "+transition0.label);
      # SemanticContext ctx = transition0.label.getSemanticContext();
      # SemanticContext.Predicate p = (SemanticContext.Predicate)ctx;
      # // if a non-syn-pred found not in enclosingRule, say we found one
      # if ( p.predicateAST.getType() != ANTLRParser.BACKTRACK_SEMPRED &&
      # !p.predicateAST.enclosingRuleName.equals(enclosingRule.name) )
      # {
      # System.out.println("found pred "+p+" not in "+enclosingRule.name);
      # return DETECT_PRED_FOUND;
      # }
      # }
      result = __detect_confounding_predicates(transition0.attr_target, enclosing_rule, chase_follow_transitions)
      if ((result).equal?(DETECT_PRED_FOUND))
        return DETECT_PRED_FOUND
      end
      if ((result).equal?(DETECT_PRED_EOR))
        if (transition0.is_a?(RuleClosureTransition))
          # we called a rule that found the end of the rule.
          # That means the rule is nullable and we need to
          # keep looking at what follows the rule ref.  E.g.,
          # a : b A ; where b is nullable means that LOOK(a)
          # should include A.
          rule_invocation_trans = transition0
          following = rule_invocation_trans.attr_follow_state
          after_rule_result = __detect_confounding_predicates(following, enclosing_rule, chase_follow_transitions)
          if ((after_rule_result).equal?(DETECT_PRED_FOUND))
            return DETECT_PRED_FOUND
          end
        end
      end
      transition1 = s.attr_transition[1]
      if (!(transition1).nil?)
        t1result = __detect_confounding_predicates(transition1.attr_target, enclosing_rule, chase_follow_transitions)
        if ((t1result).equal?(DETECT_PRED_FOUND))
          return DETECT_PRED_FOUND
        end
      end
      return DETECT_PRED_NOT_FOUND
    end
    
    typesig { [NFAState] }
    # Return predicate expression found via epsilon edges from s.  Do
    # not look into other rules for now.  Do something simple.  Include
    # backtracking synpreds.
    def get_predicates(alt_start_state)
      @look_busy.clear
      return __get_predicates(alt_start_state, alt_start_state)
    end
    
    typesig { [NFAState, NFAState] }
    def __get_predicates(s, alt_start_state)
      # System.out.println("_getPredicates("+s+")");
      if (s.is_accept_state)
        return nil
      end
      # avoid infinite loops from (..)* etc...
      if (@look_busy.contains(s))
        return nil
      end
      @look_busy.add(s)
      transition0 = s.attr_transition[0]
      # no transitions
      if ((transition0).nil?)
        return nil
      end
      # not a predicate and not even an epsilon
      if (!(transition0.attr_label.is_semantic_predicate || transition0.attr_label.is_epsilon))
        return nil
      end
      p = nil
      p0 = nil
      p1 = nil
      if (transition0.attr_label.is_semantic_predicate)
        # System.out.println("pred "+transition0.label);
        p = transition0.attr_label.get_semantic_context
        # ignore backtracking preds not on left edge for this decision
        if (((p).attr_predicate_ast.get_type).equal?(ANTLRParser::BACKTRACK_SEMPRED) && (s).equal?(alt_start_state.attr_transition[0].attr_target))
          p = nil # don't count
        end
      end
      # get preds from beyond this state
      p0 = __get_predicates(transition0.attr_target, alt_start_state)
      # get preds from other transition
      transition1 = s.attr_transition[1]
      if (!(transition1).nil?)
        p1 = __get_predicates(transition1.attr_target, alt_start_state)
      end
      # join this&following-right|following-down
      return SemanticContext.and(p, SemanticContext.or(p0, p1))
    end
    
    private
    alias_method :initialize__ll1analyzer, :initialize
  end
  
end
