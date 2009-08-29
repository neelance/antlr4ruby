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
module Org::Antlr::Test
  module TestSemanticPredicatesImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Analysis, :DFA
      include_const ::Org::Antlr::Analysis, :DecisionProbe
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Misc, :BitSet
      include ::Org::Antlr::Tool
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :JavaSet
      include_const ::Java::Util, :Map
      include_const ::Antlr, :Token
    }
  end
  
  class TestSemanticPredicates < TestSemanticPredicatesImports.const_get :BaseTest
    include_class_members TestSemanticPredicatesImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_preds_but_syntax_resolves
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? A | {p2}? B ;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-B->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_ll_1_pred
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? A | {p2}? A ;")
      expecting = ".s0-A->.s1\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{p2}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_ll_1_pred_forced_k_1
      # should stop just like before w/o k set.
      g = Grammar.new("parser grammar P;\n" + "a options {k=1;} : {p1}? A | {p2}? A ;")
      expecting = ".s0-A->.s1\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{p2}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_ll_2_pred
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? A B | {p2}? A B ;")
      expecting = ".s0-A->.s1\n" + ".s1-B->.s2\n" + ".s2-{p1}?->:s3=>1\n" + ".s2-{p2}?->:s4=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_predicated_loop
      g = Grammar.new("parser grammar P;\n" + "a : ( {p1}? A | {p2}? A )+;")
      # loop back
      expecting = ".s0-A->.s2\n" + ".s0-EOF->:s1=>3\n" + ".s2-{p1}?->:s3=>1\n" + ".s2-{p2}?->:s4=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_predicated_to_stay_in_loop
      g = Grammar.new("parser grammar P;\n" + "a : ( {p1}? A )+ (A)+;")
      expecting = ".s0-A->.s1\n" + ".s1-{!(p1)}?->:s2=>1\n" + ".s1-{p1}?->:s3=>2\n" # loop back
    end
    
    typesig { [] }
    def test_and_predicates
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? {p1a}? A | {p2}? A ;")
      expecting = ".s0-A->.s1\n" + ".s1-{(p1&&p1a)}?->:s2=>1\n" + ".s1-{p2}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_or_predicates
      g = Grammar.new("parser grammar P;\n" + "a : b | {p2}? A ;\n" + "b : {p1}? A | {p1a}? A ;")
      expecting = ".s0-A->.s1\n" + ".s1-{(p1||p1a)}?->:s2=>1\n" + ".s1-{p2}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_ignores_hoisting_depth_greater_than_zero
      g = Grammar.new("parser grammar P;\n" + "a : A {p1}? | A {p2}?;")
      expecting = ".s0-A->:s1=>1\n"
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([2]), Array.typed(::Java::Int).new([1, 2]), "A", nil, nil, 2, false)
    end
    
    typesig { [] }
    def test_ignores_preds_hidden_by_actions
      g = Grammar.new("parser grammar P;\n" + "a : {a1} {p1}? A | {a2} {p2}? A ;")
      expecting = ".s0-A->:s1=>1\n"
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([2]), Array.typed(::Java::Int).new([1, 2]), "A", nil, nil, 2, true)
    end
    
    typesig { [] }
    def test_ignores_preds_hidden_by_actions_one_alt
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? A | {a2} {p2}? A ;") # ok since 1 pred visible
      expecting = ".s0-A->.s1\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, true)
    end
    
    typesig { [] }
    # public void testIncompleteSemanticHoistedContextk2() throws Exception {
    # ErrorQueue equeue = new ErrorQueue();
    # ErrorManager.setErrorListener(equeue);
    # Grammar g = new Grammar(
    # "parser grammar t;\n"+
    # "a : b | A B;\n" +
    # "b : {p1}? A B | A B ;");
    # String expecting =
    # ".s0-A->.s1\n" +
    # ".s1-B->:s2=>1\n";
    # checkDecision(g, 1, expecting, new int[] {2},
    # new int[] {1,2}, "A B", new int[] {1}, null, 3);
    # }
    def test_hoist2
      g = Grammar.new("parser grammar P;\n" + "a : b | c ;\n" + "b : {p1}? A ;\n" + "c : {p2}? A ;\n")
      expecting = ".s0-A->.s1\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{p2}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_hoist_correct_context
      g = Grammar.new("parser grammar P;\n" + "a : b | {p2}? ID ;\n" + "b : {p1}? ID | INT ;\n")
      # only tests after ID, not INT :)
      expecting = ".s0-ID->.s1\n" + ".s0-INT->:s2=>1\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{p2}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_default_pred_naked_alt_is_last
      g = Grammar.new("parser grammar P;\n" + "a : b | ID ;\n" + "b : {p1}? ID | INT ;\n")
      expecting = ".s0-ID->.s1\n" + ".s0-INT->:s2=>1\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_default_pred_naked_alt_not_last
      g = Grammar.new("parser grammar P;\n" + "a : ID | b ;\n" + "b : {p1}? ID | INT ;\n")
      expecting = ".s0-ID->.s1\n" + ".s0-INT->:s3=>2\n" + ".s1-{!(p1)}?->:s2=>1\n" + ".s1-{p1}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_left_recursive_pred
      # No analysis possible. but probably good to fail.  Not sure we really want
      # left-recursion even if guarded with pred.
      g = Grammar.new("parser grammar P;\n" + "s : a ;\n" + "a : {p1}? a | ID ;\n")
      expecting = ".s0-ID->.s1\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n"
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      generator = CodeGenerator.new(new_tool, g, "Java")
      g.set_code_generator(generator)
      if ((g.get_number_of_decisions).equal?(0))
        g.build_nfa
        g.create_lookahead_dfas(false)
      end
      dfa = g.get_lookahead_dfa(1)
      assert_equals(nil, dfa) # can't analyze.
      # String result = serializer.serialize(dfa.startState);
      # assertEquals(expecting, result);
      assert_equals("unexpected number of expected problems", 1, equeue.size)
      msg = equeue.attr_warnings.get(0)
      assert_true("warning must be a left recursion msg", msg.is_a?(LeftRecursionCyclesMessage))
    end
    
    typesig { [] }
    def test_ignore_pred_from_ll2alt_last_alt_is_default_true
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? A B | A C | {p2}? A | {p3}? A | A ;\n")
      # two situations of note:
      # 1. A B syntax is enough to predict that alt, so p1 is not used
      # to distinguish it from alts 2..5
      # 2. Alts 3, 4, 5 are nondeterministic with upon A.  p2, p3 and the
      # complement of p2||p3 is sufficient to resolve the conflict. Do
      # not include alt 1's p1 pred in the "complement of other alts"
      # because it is not considered nondeterministic with alts 3..5
      expecting = ".s0-A->.s1\n" + ".s1-B->:s2=>1\n" + ".s1-C->:s3=>2\n" + ".s1-{p2}?->:s4=>3\n" + ".s1-{p3}?->:s5=>4\n" + ".s1-{true}?->:s6=>5\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_ignore_pred_from_ll2alt_pred_union_needed
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? A B | A C | {p2}? A | A | {p3}? A ;\n")
      # two situations of note:
      # 1. A B syntax is enough to predict that alt, so p1 is not used
      # to distinguish it from alts 2..5
      # 2. Alts 3, 4, 5 are nondeterministic with upon A.  p2, p3 and the
      # complement of p2||p3 is sufficient to resolve the conflict. Do
      # not include alt 1's p1 pred in the "complement of other alts"
      # because it is not considered nondeterministic with alts 3..5
      expecting = ".s0-A->.s1\n" + ".s1-B->:s2=>1\n" + ".s1-C->:s3=>2\n" + ".s1-{!((p3||p2))}?->:s5=>4\n" + ".s1-{p2}?->:s4=>3\n" + ".s1-{p3}?->:s6=>5\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_pred_gets2symbol_syntactic_context
      g = Grammar.new("parser grammar P;\n" + "a : b | A B | C ;\n" + "b : {p1}? A B ;\n")
      expecting = ".s0-A->.s1\n" + ".s0-C->:s5=>3\n" + ".s1-B->.s2\n" + ".s2-{p1}?->:s3=>1\n" + ".s2-{true}?->:s4=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_matches_longest_then_test_pred
      g = Grammar.new("parser grammar P;\n" + "a : b | c ;\n" + "b : {p}? A ;\n" + "c : {q}? (A|B)+ ;")
      expecting = ".s0-A->.s1\n" + ".s0-B->:s3=>2\n" + ".s1-{p}?->:s2=>1\n" + ".s1-{q}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_preds_used_after_recursion_overflow
      # analysis must bail out due to non-LL(*) nature (ovf)
      # retries with k=1 (but with LL(*) algorithm not optimized version
      # as it has preds)
      g = Grammar.new("parser grammar P;\n" + "s : {p1}? e '.' | {p2}? e ':' ;\n" + "e : '(' e ')' | INT ;\n")
      expecting = ".s0-'('->.s1\n" + ".s0-INT->.s4\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{p2}?->:s3=>2\n" + ".s4-{p1}?->:s2=>1\n" + ".s4-{p2}?->:s3=>2\n"
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      generator = CodeGenerator.new(new_tool, g, "Java")
      g.set_code_generator(generator)
      if ((g.get_number_of_decisions).equal?(0))
        g.build_nfa
        g.create_lookahead_dfas(false)
      end
      assert_equals("unexpected number of expected problems", 0, equeue.size)
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_preds_used_after_k2fails_no_recursion_overflow
      # analysis must bail out due to non-LL(*) nature (ovf)
      # retries with k=1 (but with LL(*) algorithm not optimized version
      # as it has preds)
      g = Grammar.new("grammar P;\n" + "options {k=2;}\n" + "s : {p1}? e '.' | {p2}? e ':' ;\n" + "e : '(' e ')' | INT ;\n")
      expecting = ".s0-'('->.s1\n" + ".s0-INT->.s6\n" + ".s1-'('->.s2\n" + ".s1-INT->.s5\n" + ".s2-{p1}?->:s3=>1\n" + ".s2-{p2}?->:s4=>2\n" + ".s5-{p1}?->:s3=>1\n" + ".s5-{p2}?->:s4=>2\n" + ".s6-'.'->:s3=>1\n" + ".s6-':'->:s4=>2\n"
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      generator = CodeGenerator.new(new_tool, g, "Java")
      g.set_code_generator(generator)
      if ((g.get_number_of_decisions).equal?(0))
        g.build_nfa
        g.create_lookahead_dfas(false)
      end
      assert_equals("unexpected number of expected problems", 0, equeue.size)
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_lexer_matches_longest_then_test_pred
      g = Grammar.new("lexer grammar P;\n" + "B : {p}? 'a' ;\n" + "C : {q}? ('a'|'b')+ ;")
      expecting = ".s0-'a'->.s1\n" + ".s0-'b'->:s4=>2\n" + ".s1-'a'..'b'->:s4=>2\n" + ".s1-<EOT>->.s2\n" + ".s2-{p}?->:s3=>1\n" + ".s2-{q}?->:s4=>2\n"
      check_decision(g, 2, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_lexer_matches_longest_minus_pred
      g = Grammar.new("lexer grammar P;\n" + "B : 'a' ;\n" + "C : ('a'|'b')+ ;")
      expecting = ".s0-'a'->.s1\n" + ".s0-'b'->:s3=>2\n" + ".s1-'a'..'b'->:s3=>2\n" + ".s1-<EOT>->:s2=>1\n"
      check_decision(g, 2, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_gated_pred
      # gated preds are present on all arcs in predictor
      g = Grammar.new("lexer grammar P;\n" + "B : {p}? => 'a' ;\n" + "C : {q}? => ('a'|'b')+ ;")
      expecting = ".s0-'a'&&{(p||q)}?->.s1\n" + ".s0-'b'&&{q}?->:s4=>2\n" + ".s1-'a'..'b'&&{q}?->:s4=>2\n" + ".s1-<EOT>&&{(p||q)}?->.s2\n" + ".s2-{p}?->:s3=>1\n" + ".s2-{q}?->:s4=>2\n"
      check_decision(g, 2, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_gated_pred_hoists_and_can_be_in_stop_state
      # I found a bug where merging stop states made us throw away
      # a stop state with a gated pred!
      g = Grammar.new("grammar u;\n" + "a : b+ ;\n" + "b : 'x' | {p}?=> 'y' ;")
      expecting = ".s0-'x'->:s2=>1\n" + ".s0-'y'&&{p}?->:s3=>1\n" + ".s0-EOF->:s1=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_gated_pred_in_cyclic_dfa
      g = Grammar.new("lexer grammar P;\n" + "A : {p}?=> ('a')+ 'x' ;\n" + "B : {q}?=> ('a'|'b')+ 'x' ;")
      expecting = ".s0-'a'&&{(p||q)}?->.s1\n" + ".s0-'b'&&{q}?->:s5=>2\n" + ".s1-'a'&&{(p||q)}?->.s1\n" + ".s1-'b'&&{q}?->:s5=>2\n" + ".s1-'x'&&{(p||q)}?->.s2\n" + ".s2-<EOT>&&{(p||q)}?->.s3\n" + ".s3-{p}?->:s4=>1\n" + ".s3-{q}?->:s5=>2\n"
      check_decision(g, 3, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_gated_pred_not_actually_used_on_edges
      g = Grammar.new("lexer grammar P;\n" + "A : ('a' | {p}?=> 'a')\n" + "  | 'a' 'b'\n" + "  ;")
      # Used to disambig subrule
      expecting1 = ".s0-'a'->.s1\n" + ".s1-{!(p)}?->:s2=>1\n" + ".s1-{p}?->:s3=>2\n"
      # rule A decision can't test p from s0->1 because 'a' is valid
      # for alt1 *and* alt2 w/o p.  Can't test p from s1 to s3 because
      # we might have passed the first alt of subrule.  The same state
      # is listed in s2 in 2 different configurations: one with and one
      # w/o p.  Can't test therefore.  p||true == true.
      expecting2 = ".s0-'a'->.s1\n" + ".s1-'b'->:s2=>2\n" + ".s1-<EOT>->:s3=>1\n"
      check_decision(g, 1, expecting1, nil, nil, nil, nil, nil, 0, false)
      check_decision(g, 2, expecting2, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_gated_pred_does_not_force_all_to_be_gated
      g = Grammar.new("grammar w;\n" + "a : b | c ;\n" + "b : {p}? B ;\n" + "c : {q}?=> d ;\n" + "d : {r}? C ;\n")
      expecting = ".s0-B->:s1=>1\n" + ".s0-C&&{q}?->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_gated_pred_does_not_force_all_to_be_gated2
      g = Grammar.new("grammar w;\n" + "a : b | c ;\n" + "b : {p}? B ;\n" + "c : {q}?=> d ;\n" + "d : {r}?=> C\n" + "  | B\n" + "  ;\n")
      expecting = ".s0-B->.s1\n" + ".s0-C&&{(q&&r)}?->:s3=>2\n" + ".s1-{p}?->:s2=>1\n" + ".s1-{q}?->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    def test_orgated_pred
      g = Grammar.new("grammar w;\n" + "a : b | c ;\n" + "b : {p}? B ;\n" + "c : {q}?=> d ;\n" + "d : {r}?=> C\n" + "  | {s}?=> B\n" + "  ;\n")
      expecting = ".s0-B->.s1\n" + ".s0-C&&{(q&&r)}?->:s3=>2\n" + ".s1-{(q&&s)}?->:s3=>2\n" + ".s1-{p}?->:s2=>1\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    # The following grammar should yield an error that rule 'a' has
    # insufficient semantic info pulled from 'b'.
    def test_incomplete_semantic_hoisted_context
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : b | B;\n" + "b : {p1}? B | B ;")
      expecting = ".s0-B->:s1=>1\n"
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([2]), Array.typed(::Java::Int).new([1, 2]), "B", Array.typed(::Java::Int).new([1]), nil, 3, false)
    end
    
    typesig { [] }
    def test_incomplete_semantic_hoisted_contextk2
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : b | A B;\n" + "b : {p1}? A B | A B ;")
      expecting = ".s0-A->.s1\n" + ".s1-B->:s2=>1\n"
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([2]), Array.typed(::Java::Int).new([1, 2]), "A B", Array.typed(::Java::Int).new([1]), nil, 3, false)
    end
    
    typesig { [] }
    def test_incomplete_semantic_hoisted_context_in_follow
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # limit to k=1 because it's LL(2); force pred hoist
      # need FOLLOW
      g = Grammar.new("parser grammar t;\n" + "options {k=1;}\n" + "a : A? ;\n" + "b : X a {p1}? A | Y a A ;") # only one A is covered
      expecting = ".s0-A->:s1=>1\n" # s0-EOF->s2 branch pruned during optimization
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([2]), Array.typed(::Java::Int).new([1, 2]), "A", Array.typed(::Java::Int).new([2]), nil, 3, false)
    end
    
    typesig { [] }
    def test_incomplete_semantic_hoisted_context_in_followk2
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # need FOLLOW
      g = Grammar.new("parser grammar t;\n" + "a : (A B)? ;\n" + "b : X a {p1}? A B | Y a A B | Z a ;") # only first alt is covered
      expecting = ".s0-A->.s1\n" + ".s0-EOF->:s3=>2\n" + ".s1-B->:s2=>1\n"
      check_decision(g, 1, expecting, nil, Array.typed(::Java::Int).new([1, 2]), "A B", Array.typed(::Java::Int).new([2]), nil, 2, false)
    end
    
    typesig { [] }
    def test_incomplete_semantic_hoisted_context_in_followdue_to_hidden_pred
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # need FOLLOW
      g = Grammar.new("parser grammar t;\n" + "a : (A B)? ;\n" + "b : X a {p1}? A B | Y a {a1} {p2}? A B | Z a ;") # only first alt is covered
      expecting = ".s0-A->.s1\n" + ".s0-EOF->:s3=>2\n" + ".s1-B->:s2=>1\n"
      check_decision(g, 1, expecting, nil, Array.typed(::Java::Int).new([1, 2]), "A B", Array.typed(::Java::Int).new([2]), nil, 2, true)
    end
    
    typesig { [] }
    # The following grammar should yield an error that rule 'a' has
    # insufficient semantic info pulled from 'b'.  This is the same
    # as the previous case except that the D prevents the B path from
    # "pinching" together into a single NFA state.
    # 
    # This test also demonstrates that just because B D could predict
    # alt 1 in rule 'a', it is unnecessary to continue NFA->DFA
    # conversion to include an edge for D.  Alt 1 is the only possible
    # prediction because we resolve the ambiguity by choosing alt 1.
    def test_incomplete_semantic_hoisted_context2
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : b | B;\n" + "b : {p1}? B | B D ;")
      expecting = ".s0-B->:s1=>1\n"
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([2]), Array.typed(::Java::Int).new([1, 2]), "B", Array.typed(::Java::Int).new([1]), nil, 3, false)
    end
    
    typesig { [] }
    def test_too_few_semantic_predicates
      g = Grammar.new("parser grammar t;\n" + "a : {p1}? A | A | A ;")
      expecting = ".s0-A->:s1=>1\n"
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([2, 3]), Array.typed(::Java::Int).new([1, 2, 3]), "A", nil, nil, 2, false)
    end
    
    typesig { [] }
    def test_pred_with_k1
      g = Grammar.new("\tlexer grammar TLexer;\n" + "A\n" + "options {\n" + "  k=1;\n" + "}\n" + "  : {p1}? ('x')+ '.'\n" + "  | {p2}? ('x')+ '.'\n" + "  ;\n")
      expecting = ".s0-'x'->.s1\n" + ".s1-{p1}?->:s2=>1\n" + ".s1-{p2}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      insufficient_pred_alts = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 3, expecting, unreachable_alts, non_det_alts, ambig_input, insufficient_pred_alts, dangling_alts, num_warnings, false)
    end
    
    typesig { [] }
    def test_pred_with_arbitrary_lookahead
      g = Grammar.new("\tlexer grammar TLexer;\n" + "A : {p1}? ('x')+ '.'\n" + "  | {p2}? ('x')+ '.'\n" + "  ;\n")
      expecting = ".s0-'x'->.s1\n" + ".s1-'.'->.s2\n" + ".s1-'x'->.s1\n" + ".s2-{p1}?->:s3=>1\n" + ".s2-{p2}?->:s4=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      insufficient_pred_alts = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 3, expecting, unreachable_alts, non_det_alts, ambig_input, insufficient_pred_alts, dangling_alts, num_warnings, false)
    end
    
    typesig { [] }
    # For a DFA state with lots of configurations that have the same
    # predicate, don't just OR them all together as it's a waste to
    # test a||a||b||a||a etc...  ANTLR makes a unique set and THEN
    # OR's them together.
    def test_unique_predicate_or
      g = Grammar.new("parser grammar v;\n" + "\n" + "a : {a}? b\n" + "  | {b}? b\n" + "  ;\n" + "\n" + "b : {c}? (X)+ ;\n" + "\n" + "c : a\n" + "  | b\n" + "  ;\n")
      expecting = ".s0-X->.s1\n" + ".s1-{((b&&c)||(a&&c))}?->:s2=>1\n" + ".s1-{c}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      insufficient_pred_alts = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 3, expecting, unreachable_alts, non_det_alts, ambig_input, insufficient_pred_alts, dangling_alts, num_warnings, false)
    end
    
    typesig { [] }
    def test_semantic_context_prevents_early_termination_of_closure
      g = Grammar.new("parser grammar T;\n" + "a : loop SEMI | ID SEMI\n" + "  ;\n" + "loop\n" + "    : {while}? ID\n" + "    | {do}? ID\n" + "    | {for}? ID\n" + "    ;")
      expecting = ".s0-ID->.s1\n" + ".s1-SEMI->.s2\n" + ".s2-{(do||while||for)}?->:s3=>1\n" + ".s2-{true}?->:s4=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, nil, 0, false)
    end
    
    typesig { [] }
    # S U P P O R T
    def __template
      g = Grammar.new("parser grammar t;\n" + "a : A | B;")
      expecting = "\n"
      unreachable_alts = nil
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "L ID R"
      insufficient_pred_alts = Array.typed(::Java::Int).new([1])
      dangling_alts = nil
      num_warnings = 1
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, insufficient_pred_alts, dangling_alts, num_warnings, false)
    end
    
    typesig { [Grammar, ::Java::Int, String, Array.typed(::Java::Int), Array.typed(::Java::Int), String, Array.typed(::Java::Int), Array.typed(::Java::Int), ::Java::Int, ::Java::Boolean] }
    def check_decision(g, decision, expecting, expecting_unreachable_alts, expecting_non_det_alts, expecting_ambig_input, expecting_insufficient_pred_alts, expecting_dangling_alts, expecting_num_warnings, has_pred_hidden_by_action)
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      generator = CodeGenerator.new(new_tool, g, "Java")
      g.set_code_generator(generator)
      # mimic actions of org.antlr.Tool first time for grammar g
      if ((g.get_number_of_decisions).equal?(0))
        g.build_nfa
        g.create_lookahead_dfas(false)
      end
      if (!(equeue.size).equal?(expecting_num_warnings))
        System.err.println("Warnings issued: " + RJava.cast_to_string(equeue))
      end
      assert_equals("unexpected number of expected problems", expecting_num_warnings, equeue.size)
      dfa = g.get_lookahead_dfa(decision)
      serializer = FASerializer.new(g)
      result = serializer.serialize(dfa.attr_start_state)
      # System.out.print(result);
      unreachable_alts = dfa.get_unreachable_alts
      # make sure unreachable alts are as expected
      if (!(expecting_unreachable_alts).nil?)
        s = BitSet.new
        s.add_all(expecting_unreachable_alts)
        s2 = BitSet.new
        s2.add_all(unreachable_alts)
        assert_equals("unreachable alts mismatch", s, s2)
      else
        assert_equals("unreachable alts mismatch", 0, !(unreachable_alts).nil? ? unreachable_alts.size : 0)
      end
      # check conflicting input
      if (!(expecting_ambig_input).nil?)
        # first, find nondet message
        msg = get_non_determinism_message(equeue.attr_warnings)
        assert_not_null("no nondeterminism warning?", msg)
        assert_true("expecting nondeterminism; found " + RJava.cast_to_string(msg.get_class.get_name), msg.is_a?(GrammarNonDeterminismMessage))
        nondet_msg = get_non_determinism_message(equeue.attr_warnings)
        labels = nondet_msg.attr_probe.get_sample_non_deterministic_input_sequence(nondet_msg.attr_problem_state)
        input = nondet_msg.attr_probe.get_input_sequence_display(labels)
        assert_equals(expecting_ambig_input, input)
      end
      # check nondet alts
      if (!(expecting_non_det_alts).nil?)
        nondet_msg = get_non_determinism_message(equeue.attr_warnings)
        assert_not_null("found no nondet alts; expecting: " + RJava.cast_to_string(str(expecting_non_det_alts)), nondet_msg)
        non_det_alts = nondet_msg.attr_probe.get_non_deterministic_alts_for_state(nondet_msg.attr_problem_state)
        # compare nonDetAlts with expectingNonDetAlts
        s = BitSet.new
        s.add_all(expecting_non_det_alts)
        s2 = BitSet.new
        s2.add_all(non_det_alts)
        assert_equals("nondet alts mismatch", s, s2)
        assert_equals("mismatch between expected hasPredHiddenByAction", has_pred_hidden_by_action, nondet_msg.attr_problem_state.attr_dfa.attr_has_predicate_blocked_by_action)
      else
        # not expecting any nondet alts, make sure there are none
        nondet_msg = get_non_determinism_message(equeue.attr_warnings)
        assert_null("found nondet alts, but expecting none", nondet_msg)
      end
      if (!(expecting_insufficient_pred_alts).nil?)
        insuff_pred_msg = get_grammar_insufficient_predicates_message(equeue.attr_warnings)
        assert_not_null("found no GrammarInsufficientPredicatesMessage alts; expecting: " + RJava.cast_to_string(str(expecting_non_det_alts)), insuff_pred_msg)
        locations = insuff_pred_msg.attr_alt_to_locations
        actual_alts = locations.key_set
        s = BitSet.new
        s.add_all(expecting_insufficient_pred_alts)
        s2 = BitSet.new
        s2.add_all(actual_alts)
        assert_equals("mismatch between insufficiently covered alts", s, s2)
        assert_equals("mismatch between expected hasPredHiddenByAction", has_pred_hidden_by_action, insuff_pred_msg.attr_problem_state.attr_dfa.attr_has_predicate_blocked_by_action)
      else
        # not expecting any nondet alts, make sure there are none
        nondet_msg = get_grammar_insufficient_predicates_message(equeue.attr_warnings)
        if (!(nondet_msg).nil?)
          System.out.println(equeue.attr_warnings)
        end
        assert_null("found insufficiently covered alts, but expecting none", nondet_msg)
      end
      assert_equals(expecting, result)
    end
    
    typesig { [JavaList] }
    def get_non_determinism_message(warnings)
      i = 0
      while i < warnings.size
        m = warnings.get(i)
        if (m.is_a?(GrammarNonDeterminismMessage))
          return m
        end
        i += 1
      end
      return nil
    end
    
    typesig { [JavaList] }
    def get_grammar_insufficient_predicates_message(warnings)
      i = 0
      while i < warnings.size
        m = warnings.get(i)
        if (m.is_a?(GrammarInsufficientPredicatesMessage))
          return m
        end
        i += 1
      end
      return nil
    end
    
    typesig { [Array.typed(::Java::Int)] }
    def str(elements)
      buf = StringBuffer.new
      i = 0
      while i < elements.attr_length
        if (i > 0)
          buf.append(", ")
        end
        element = elements[i]
        buf.append(element)
        i += 1
      end
      return buf.to_s
    end
    
    private
    alias_method :initialize__test_semantic_predicates, :initialize
  end
  
end
