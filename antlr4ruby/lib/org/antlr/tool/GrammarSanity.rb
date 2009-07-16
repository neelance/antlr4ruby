require "rjava"

# 
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
module Org::Antlr::Tool
  module GrammarSanityImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Analysis, :NFAState
      include_const ::Org::Antlr::Analysis, :Transition
      include_const ::Org::Antlr::Analysis, :RuleClosureTransition
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :HashSet
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :JavaSet
    }
  end
  
  # Factor out routines that check sanity of rules, alts, grammars, etc..
  class GrammarSanity 
    include_class_members GrammarSanityImports
    
    # The checkForLeftRecursion method needs to track what rules it has
    # visited to track infinite recursion.
    attr_accessor :visited_during_recursion_check
    alias_method :attr_visited_during_recursion_check, :visited_during_recursion_check
    undef_method :visited_during_recursion_check
    alias_method :attr_visited_during_recursion_check=, :visited_during_recursion_check=
    undef_method :visited_during_recursion_check=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    typesig { [Grammar] }
    def initialize(grammar)
      @visited_during_recursion_check = nil
      @grammar = nil
      @grammar = grammar
    end
    
    typesig { [] }
    # Check all rules for infinite left recursion before analysis. Return list
    # of troublesome rule cycles.  This method has two side-effects: it notifies
    # the error manager that we have problems and it sets the list of
    # recursive rules that we should ignore during analysis.
    def check_all_rules_for_left_recursion
      @grammar.build_nfa # make sure we have NFAs
      @grammar.attr_left_recursive_rules = HashSet.new
      list_of_recursive_cycles = ArrayList.new
      i = 0
      while i < @grammar.attr_composite.attr_rule_index_to_rule_list.size
        r = @grammar.attr_composite.attr_rule_index_to_rule_list.element_at(i)
        if (!(r).nil?)
          @visited_during_recursion_check = HashSet.new
          @visited_during_recursion_check.add(r)
          visited_states = HashSet.new
          trace_states_looking_for_left_recursion(r.attr_start_state, visited_states, list_of_recursive_cycles)
        end
        ((i += 1) - 1)
      end
      if (list_of_recursive_cycles.size > 0)
        ErrorManager.left_recursion_cycles(list_of_recursive_cycles)
      end
      return list_of_recursive_cycles
    end
    
    typesig { [NFAState, JavaSet, JavaList] }
    # From state s, look for any transition to a rule that is currently
    # being traced.  When tracing r, visitedDuringRecursionCheck has r
    # initially.  If you reach an accept state, return but notify the
    # invoking rule that it is nullable, which implies that invoking
    # rule must look at follow transition for that invoking state.
    # The visitedStates tracks visited states within a single rule so
    # we can avoid epsilon-loop-induced infinite recursion here.  Keep
    # filling the cycles in listOfRecursiveCycles and also, as a
    # side-effect, set leftRecursiveRules.
    def trace_states_looking_for_left_recursion(s, visited_states, list_of_recursive_cycles)
      if (s.is_accept_state)
        # this rule must be nullable!
        # At least one epsilon edge reached accept state
        return true
      end
      if (visited_states.contains(s))
        # within same rule, we've hit same state; quit looping
        return false
      end
      visited_states.add(s)
      state_reaches_accept_state = false
      t0 = s.attr_transition[0]
      if (t0.is_a?(RuleClosureTransition))
        ref_trans = t0
        ref_rule_def = ref_trans.attr_rule
        # String targetRuleName = ((NFAState)t0.target).getEnclosingRule();
        if (@visited_during_recursion_check.contains(ref_rule_def))
          # record left-recursive rule, but don't go back in
          @grammar.attr_left_recursive_rules.add(ref_rule_def)
          # 
          # System.out.println("already visited "+refRuleDef+", calling from "+
          # s.enclosingRule);
          add_rules_to_cycle(ref_rule_def, s.attr_enclosing_rule, list_of_recursive_cycles)
        else
          # must visit if not already visited; send new visitedStates set
          @visited_during_recursion_check.add(ref_rule_def)
          call_reached_accept_state = trace_states_looking_for_left_recursion(t0.attr_target, HashSet.new, list_of_recursive_cycles)
          # we're back from visiting that rule
          @visited_during_recursion_check.remove(ref_rule_def)
          # must keep going in this rule then
          if (call_reached_accept_state)
            following_state = (t0).attr_follow_state
            state_reaches_accept_state |= trace_states_looking_for_left_recursion(following_state, visited_states, list_of_recursive_cycles)
          end
        end
      else
        if (t0.attr_label.is_epsilon || t0.attr_label.is_semantic_predicate)
          state_reaches_accept_state |= trace_states_looking_for_left_recursion(t0.attr_target, visited_states, list_of_recursive_cycles)
        end
      end
      # else it has a labeled edge
      # now do the other transition if it exists
      t1 = s.attr_transition[1]
      if (!(t1).nil?)
        state_reaches_accept_state |= trace_states_looking_for_left_recursion(t1.attr_target, visited_states, list_of_recursive_cycles)
      end
      return state_reaches_accept_state
    end
    
    typesig { [Rule, Rule, JavaList] }
    # enclosingRuleName calls targetRuleName, find the cycle containing
    # the target and add the caller.  Find the cycle containing the caller
    # and add the target.  If no cycles contain either, then create a new
    # cycle.  listOfRecursiveCycles is List<Set<String>> that holds a list
    # of cycles (sets of rule names).
    def add_rules_to_cycle(target_rule, enclosing_rule, list_of_recursive_cycles)
      found_cycle = false
      i = 0
      while i < list_of_recursive_cycles.size
        rules_in_cycle = list_of_recursive_cycles.get(i)
        # ensure both rules are in same cycle
        if (rules_in_cycle.contains(target_rule))
          rules_in_cycle.add(enclosing_rule)
          found_cycle = true
        end
        if (rules_in_cycle.contains(enclosing_rule))
          rules_in_cycle.add(target_rule)
          found_cycle = true
        end
        ((i += 1) - 1)
      end
      if (!found_cycle)
        cycle = HashSet.new
        cycle.add(target_rule)
        cycle.add(enclosing_rule)
        list_of_recursive_cycles.add(cycle)
      end
    end
    
    typesig { [GrammarAST, GrammarAST, GrammarAST, String] }
    def check_rule_reference(scope_ast, ref_ast, args_ast, current_rule_name)
      r = @grammar.get_rule(ref_ast.get_text)
      if ((ref_ast.get_type).equal?(ANTLRParser::RULE_REF))
        if (!(args_ast).nil?)
          # rule[args]; ref has args
          if (!(r).nil? && (r.attr_arg_action_ast).nil?)
            # but rule def has no args
            ErrorManager.grammar_error(ErrorManager::MSG_RULE_HAS_NO_ARGS, @grammar, args_ast.get_token, r.attr_name)
          end
        else
          # rule ref has no args
          if (!(r).nil? && !(r.attr_arg_action_ast).nil?)
            # but rule def has args
            ErrorManager.grammar_error(ErrorManager::MSG_MISSING_RULE_ARGS, @grammar, ref_ast.get_token, r.attr_name)
          end
        end
      else
        if ((ref_ast.get_type).equal?(ANTLRParser::TOKEN_REF))
          if (!(@grammar.attr_type).equal?(Grammar::LEXER))
            if (!(args_ast).nil?)
              # args on a token ref not in a lexer rule
              ErrorManager.grammar_error(ErrorManager::MSG_ARGS_ON_TOKEN_REF, @grammar, ref_ast.get_token, ref_ast.get_text)
            end
            return # ignore token refs in nonlexers
          end
          if (!(args_ast).nil?)
            # tokenRef[args]; ref has args
            if (!(r).nil? && (r.attr_arg_action_ast).nil?)
              # but token rule def has no args
              ErrorManager.grammar_error(ErrorManager::MSG_RULE_HAS_NO_ARGS, @grammar, args_ast.get_token, r.attr_name)
            end
          else
            # token ref has no args
            if (!(r).nil? && !(r.attr_arg_action_ast).nil?)
              # but token rule def has args
              ErrorManager.grammar_error(ErrorManager::MSG_MISSING_RULE_ARGS, @grammar, ref_ast.get_token, r.attr_name)
            end
          end
        end
      end
    end
    
    typesig { [GrammarAST, GrammarAST, ::Java::Int] }
    # Rules in tree grammar that use -> rewrites and are spitting out
    # templates via output=template and then use rewrite=true must only
    # use -> on alts that are simple nodes or trees or single rule refs
    # that match either nodes or trees.  The altAST is the ALT node
    # for an ALT.  Verify that its first child is simple.  Must be either
    # ( ALT ^( A B ) <end-of-alt> ) or ( ALT A <end-of-alt> ) or
    # other element.
    # 
    # Ignore predicates in front and labels.
    def ensure_alt_is_simple_node_or_tree(alt_ast, element_ast, outer_alt_num)
      if (is_valid_simple_element_node(element_ast))
        next_ = element_ast.get_next_sibling
        if (!is_next_non_action_element_eoa(next_))
          ErrorManager.grammar_warning(ErrorManager::MSG_REWRITE_FOR_MULTI_ELEMENT_ALT, @grammar, next_.attr_token, outer_alt_num)
        end
        return
      end
      case (element_ast.get_type)
      # labels ok on non-rule refs
      # skip past actions
      when ANTLRParser::ASSIGN, ANTLRParser::PLUS_ASSIGN
        if (is_valid_simple_element_node(element_ast.get_child(1)))
          return
        end
      when ANTLRParser::ACTION, ANTLRParser::SEMPRED, ANTLRParser::SYN_SEMPRED, ANTLRParser::BACKTRACK_SEMPRED, ANTLRParser::GATED_SEMPRED
        ensure_alt_is_simple_node_or_tree(alt_ast, element_ast.get_next_sibling, outer_alt_num)
        return
      end
      ErrorManager.grammar_warning(ErrorManager::MSG_REWRITE_FOR_MULTI_ELEMENT_ALT, @grammar, element_ast.attr_token, outer_alt_num)
    end
    
    typesig { [GrammarAST] }
    def is_valid_simple_element_node(t)
      case (t.get_type)
      when ANTLRParser::TREE_BEGIN, ANTLRParser::TOKEN_REF, ANTLRParser::CHAR_LITERAL, ANTLRParser::STRING_LITERAL, ANTLRParser::WILDCARD
        return true
      else
        return false
      end
    end
    
    typesig { [GrammarAST] }
    def is_next_non_action_element_eoa(t)
      while ((t.get_type).equal?(ANTLRParser::ACTION) || (t.get_type).equal?(ANTLRParser::SEMPRED))
        t = t.get_next_sibling
      end
      if ((t.get_type).equal?(ANTLRParser::EOA))
        return true
      end
      return false
    end
    
    private
    alias_method :initialize__grammar_sanity, :initialize
  end
  
end
