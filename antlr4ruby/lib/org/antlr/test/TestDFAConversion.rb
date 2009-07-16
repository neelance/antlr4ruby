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
module Org::Antlr::Test
  module TestDFAConversionImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Analysis, :DFA
      include_const ::Org::Antlr::Analysis, :DecisionProbe
      include_const ::Org::Antlr::Misc, :BitSet
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include ::Java::Util
    }
  end
  
  class TestDFAConversion < TestDFAConversionImports.const_get :BaseTest
    include_class_members TestDFAConversionImports
    
    typesig { [] }
    def test_a
      g = Grammar.new("parser grammar t;\n" + "a : A C | B;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-B->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_ab_or_ac
      g = Grammar.new("parser grammar t;\n" + "a : A B | A C;")
      expecting = ".s0-A->.s1\n" + ".s1-B->:s2=>1\n" + ".s1-C->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_ab_or_ac_k2
      g = Grammar.new("parser grammar t;\n" + "options {k=2;}\n" + "a : A B | A C;")
      expecting = ".s0-A->.s1\n" + ".s1-B->:s2=>1\n" + ".s1-C->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_ab_or_ac_k1
      g = Grammar.new("parser grammar t;\n" + "options {k=1;}\n" + "a : A B | A C;")
      expecting = ".s0-A->:s1=>1\n"
      unreachable_alts = Array.typed(::Java::Int).new([2])
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "A"
      dangling_alts = Array.typed(::Java::Int).new([2])
      num_warnings = 2 # ambig upon A
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def testself_recurse_non_det
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : A a X | A a Y;")
      alts_with_recursion = Arrays.as_list(Array.typed(Object).new([1, 2]))
      assert_non_llstar(g, alts_with_recursion)
    end
    
    typesig { [] }
    def test_recursion_overflow
      # force recursion past m=4
      g = Grammar.new("parser grammar t;\n" + "s : a Y | A A A A A X ;\n" + "a : A a | Q;")
      expected_target_rules = Arrays.as_list(Array.typed(Object).new(["a"]))
      expected_alt = 1
      assert_recursion_overflow(g, expected_target_rules, expected_alt)
    end
    
    typesig { [] }
    def test_recursion_overflow2
      # force recursion past m=4
      g = Grammar.new("parser grammar t;\n" + "s : a Y | A+ X ;\n" + "a : A a | Q;")
      expected_target_rules = Arrays.as_list(Array.typed(Object).new(["a"]))
      expected_alt = 1
      assert_recursion_overflow(g, expected_target_rules, expected_alt)
    end
    
    typesig { [] }
    def test_recursion_overflow_with_pred_ok
      # overflows with k=*, but resolves with pred
      # no warnings/errors
      # force recursion past m=4
      g = Grammar.new("parser grammar t;\n" + "s : (a Y)=> a Y | A A A A A X ;\n" + "a : A a | Q;")
      expecting = ".s0-A->.s1\n" + ".s0-Q&&{synpred1_t}?->:s11=>1\n" + ".s1-A->.s2\n" + ".s1-Q&&{synpred1_t}?->:s10=>1\n" + ".s2-A->.s3\n" + ".s2-Q&&{synpred1_t}?->:s9=>1\n" + ".s3-A->.s4\n" + ".s3-Q&&{synpred1_t}?->:s8=>1\n" + ".s4-A->.s5\n" + ".s4-Q&&{synpred1_t}?->:s6=>1\n" + ".s5-{synpred1_t}?->:s6=>1\n" + ".s5-{true}?->:s7=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_recursion_overflow_with_pred_ok2
      # must predict Z w/o predicate
      # force recursion past m=4
      g = Grammar.new("parser grammar t;\n" + "s : (a Y)=> a Y | A A A A A X | Z;\n" + "a : A a | Q;")
      expecting = ".s0-A->.s1\n" + ".s0-Q&&{synpred1_t}?->:s11=>1\n" + ".s0-Z->:s12=>3\n" + ".s1-A->.s2\n" + ".s1-Q&&{synpred1_t}?->:s10=>1\n" + ".s2-A->.s3\n" + ".s2-Q&&{synpred1_t}?->:s9=>1\n" + ".s3-A->.s4\n" + ".s3-Q&&{synpred1_t}?->:s8=>1\n" + ".s4-A->.s5\n" + ".s4-Q&&{synpred1_t}?->:s6=>1\n" + ".s5-{synpred1_t}?->:s6=>1\n" + ".s5-{true}?->:s7=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_cannot_see_past_recursion
      g = Grammar.new("parser grammar t;\n" + "x   : y X\n" + "    | y Y\n" + "    ;\n" + "y   : L y R\n" + "    | B\n" + "    ;")
      alts_with_recursion = Arrays.as_list(Array.typed(Object).new([1, 2]))
      assert_non_llstar(g, alts_with_recursion)
    end
    
    typesig { [] }
    def test_syn_pred_resolves_recursion
      g = Grammar.new("parser grammar t;\n" + "x   : (y X)=> y X\n" + "    | y Y\n" + "    ;\n" + "y   : L y R\n" + "    | B\n" + "    ;")
      expecting = ".s0-B->.s4\n" + ".s0-L->.s1\n" + ".s1-{synpred1_t}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n" + ".s4-{synpred1_t}?->:s2=>1\n" + ".s4-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_sem_pred_resolves_recursion
      g = Grammar.new("parser grammar t;\n" + "x   : {p}? y X\n" + "    | y Y\n" + "    ;\n" + "y   : L y R\n" + "    | B\n" + "    ;")
      expecting = ".s0-B->.s4\n" + ".s0-L->.s1\n" + ".s1-{p}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n" + ".s4-{p}?->:s2=>1\n" + ".s4-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_sem_pred_resolves_recursion2
      g = Grammar.new("parser grammar t;\n" + "x\n" + "options {k=1;}\n" + "   : {p}? y X\n" + "    | y Y\n" + "    ;\n" + "y   : L y R\n" + "    | B\n" + "    ;")
      expecting = ".s0-B->.s4\n" + ".s0-L->.s1\n" + ".s1-{p}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n" + ".s4-{p}?->:s2=>1\n" + ".s4-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_sem_pred_resolves_recursion3
      # just makes bigger DFA
      g = Grammar.new("parser grammar t;\n" + "x\n" + "options {k=2;}\n" + "   : {p}? y X\n" + "    | y Y\n" + "    ;\n" + "y   : L y R\n" + "    | B\n" + "    ;")
      expecting = ".s0-B->.s6\n" + ".s0-L->.s1\n" + ".s1-B->.s5\n" + ".s1-L->.s2\n" + ".s2-{p}?->:s3=>1\n" + ".s2-{true}?->:s4=>2\n" + ".s5-{p}?->:s3=>1\n" + ".s5-{true}?->:s4=>2\n" + ".s6-X->:s3=>1\n" + ".s6-Y->:s4=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_syn_pred_resolves_recursion2
      # k=* fails and it retries/succeeds with k=1 silently
      # because of predicate
      g = Grammar.new("parser grammar t;\n" + "statement\n" + "    :     (reference ASSIGN)=> reference ASSIGN expr\n" + "    |     expr\n" + "    ;\n" + "expr:     reference\n" + "    |     INT\n" + "    |     FLOAT\n" + "    ;\n" + "reference\n" + "    :     ID L argument_list R\n" + "    ;\n" + "argument_list\n" + "    :     expr COMMA expr\n" + "    ;")
      expecting = ".s0-ID->.s1\n" + ".s0-INT..FLOAT->:s3=>2\n" + ".s1-{synpred1_t}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_syn_pred_resolves_recursion3
      # No errors with k=1; don't try k=* first
      g = Grammar.new("parser grammar t;\n" + "statement\n" + "options {k=1;}\n" + "    :     (reference ASSIGN)=> reference ASSIGN expr\n" + "    |     expr\n" + "    ;\n" + "expr:     reference\n" + "    |     INT\n" + "    |     FLOAT\n" + "    ;\n" + "reference\n" + "    :     ID L argument_list R\n" + "    ;\n" + "argument_list\n" + "    :     expr COMMA expr\n" + "    ;")
      expecting = ".s0-ID->.s1\n" + ".s0-INT..FLOAT->:s3=>2\n" + ".s1-{synpred1_t}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_syn_pred_resolves_recursion4
      # No errors with k=2; don't try k=* first
      # Should be ok like k=1 'except bigger DFA
      g = Grammar.new("parser grammar t;\n" + "statement\n" + "options {k=2;}\n" + "    :     (reference ASSIGN)=> reference ASSIGN expr\n" + "    |     expr\n" + "    ;\n" + "expr:     reference\n" + "    |     INT\n" + "    |     FLOAT\n" + "    ;\n" + "reference\n" + "    :     ID L argument_list R\n" + "    ;\n" + "argument_list\n" + "    :     expr COMMA expr\n" + "    ;")
      expecting = ".s0-ID->.s1\n" + ".s0-INT..FLOAT->:s4=>2\n" + ".s1-L->.s2\n" + ".s2-{synpred1_t}?->:s3=>1\n" + ".s2-{true}?->:s4=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_syn_pred_resolves_recursion_in_lexer
      g = Grammar.new("lexer grammar t;\n" + "A :     (B ';')=> B ';'\n" + "  |     B '.'\n" + "  ;\n" + "fragment\n" + "B :     '(' B ')'\n" + "  |     'x'\n" + "  ;\n")
      expecting = ".s0-'('->.s1\n" + ".s0-'x'->.s4\n" + ".s1-{synpred1_t}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n" + ".s4-{synpred1_t}?->:s2=>1\n" + ".s4-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_auto_backtrack_resolves_recursion_in_lexer
      g = Grammar.new("lexer grammar t;\n" + "options {backtrack=true;}\n" + "A :     B ';'\n" + "  |     B '.'\n" + "  ;\n" + "fragment\n" + "B :     '(' B ')'\n" + "  |     'x'\n" + "  ;\n")
      expecting = ".s0-'('->.s1\n" + ".s0-'x'->.s4\n" + ".s1-{synpred1_t}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n" + ".s4-{synpred1_t}?->:s2=>1\n" + ".s4-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_auto_backtrack_resolves_recursion
      g = Grammar.new("parser grammar t;\n" + "options {backtrack=true;}\n" + "x   : y X\n" + "    | y Y\n" + "    ;\n" + "y   : L y R\n" + "    | B\n" + "    ;")
      expecting = ".s0-B->.s4\n" + ".s0-L->.s1\n" + ".s1-{synpred1_t}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n" + ".s4-{synpred1_t}?->:s2=>1\n" + ".s4-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def testself_recurse_non_det2
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : P a P | P;")
      # nondeterministic from left edge
      expecting = ".s0-P->.s1\n" + ".s1-EOF->:s2=>2\n" + ".s1-P->:s3=>1\n"
      unreachable_alts = nil
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "P P"
      dangling_alts = nil
      num_warnings = 1
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_indirect_recursion_loop
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : b X ;\n" + "b : a B ;\n")
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      left_recursive = g.get_left_recursive_rules
      add("a")
      add("b")
      expected_rules = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expected_rules, rule_names(left_recursive))
      g.create_lookahead_dfas(false)
      msg = equeue.attr_warnings.get(0)
      assert_true("expecting left recursion cycles; found " + (msg.get_class.get_name).to_s, msg.is_a?(LeftRecursionCyclesMessage))
      cycles_msg = msg
      # cycle of [a, b]
      result = cycles_msg.attr_cycles
      add("a")
      add("b")
      expecting = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expecting, rule_names2(result))
    end
    
    typesig { [] }
    def test_indirect_recursion_loop2
      # should see through i
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : i b X ;\n" + "b : a B ;\n" + "i : ;\n")
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      left_recursive = g.get_left_recursive_rules
      add("a")
      add("b")
      expected_rules = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expected_rules, rule_names(left_recursive))
      g.create_lookahead_dfas(false)
      msg = equeue.attr_warnings.get(0)
      assert_true("expecting left recursion cycles; found " + (msg.get_class.get_name).to_s, msg.is_a?(LeftRecursionCyclesMessage))
      cycles_msg = msg
      # cycle of [a, b]
      result = cycles_msg.attr_cycles
      add("a")
      add("b")
      expecting = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expecting, rule_names2(result))
    end
    
    typesig { [] }
    def test_indirect_recursion_loop3
      # should see through i
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : i b X ;\n" + "b : a B ;\n" + "i : ;\n" + "d : e ;\n" + "e : d ;\n")
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      left_recursive = g.get_left_recursive_rules
      add("a")
      add("b")
      add("e")
      add("d")
      expected_rules = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expected_rules, rule_names(left_recursive))
      msg = equeue.attr_warnings.get(0)
      assert_true("expecting left recursion cycles; found " + (msg.get_class.get_name).to_s, msg.is_a?(LeftRecursionCyclesMessage))
      cycles_msg = msg
      # cycle of [a, b]
      result = cycles_msg.attr_cycles
      add("a")
      add("b")
      add("d")
      add("e")
      expecting = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expecting, rule_names2(result))
    end
    
    typesig { [] }
    def testif_then_else
      g = Grammar.new("parser grammar t;\n" + "s : IF s (E s)? | B;\n" + "slist: s SEMI ;")
      expecting = ".s0-E->:s1=>1\n" + ".s0-SEMI->:s2=>2\n"
      unreachable_alts = nil
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "E"
      dangling_alts = nil
      num_warnings = 1
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
      expecting = ".s0-B->:s2=>2\n" + ".s0-IF->:s1=>1\n"
      check_decision(g, 2, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def testif_then_else_checks_stack_suffix_conflict
      # if you don't check stack soon enough, this finds E B not just E
      # as ambig input
      g = Grammar.new("parser grammar t;\n" + "slist: s SEMI ;\n" + "s : IF s el | B;\n" + "el: (E s)? ;\n")
      expecting = ".s0-E->:s1=>1\n" + ".s0-SEMI->:s2=>2\n"
      unreachable_alts = nil
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "E"
      dangling_alts = nil
      num_warnings = 1
      check_decision(g, 2, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
      expecting = ".s0-B->:s2=>2\n" + ".s0-IF->:s1=>1\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_invoke_rule
      g = Grammar.new("parser grammar t;\n" + "a : b A\n" + "  | b B\n" + "  | C\n" + "  ;\n" + "b : X\n" + "  ;\n")
      expecting = ".s0-C->:s4=>3\n" + ".s0-X->.s1\n" + ".s1-A->:s3=>1\n" + ".s1-B->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_double_invoke_rule_left_edge
      g = Grammar.new("parser grammar t;\n" + "a : b X\n" + "  | b Y\n" + "  ;\n" + "b : c B\n" + "  | c\n" + "  ;\n" + "c : C ;\n")
      expecting = ".s0-C->.s1\n" + ".s1-B->.s4\n" + ".s1-X->:s2=>1\n" + ".s1-Y->:s3=>2\n" + ".s4-X->:s2=>1\n" + ".s4-Y->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
      expecting = ".s0-C->.s1\n" + ".s1-B->:s3=>1\n" + ".s1-X..Y->:s2=>2\n"
      check_decision(g, 2, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def testimmediate_tail_recursion
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : A a | A B;")
      expecting = ".s0-A->.s1\n" + ".s1-A->:s3=>1\n" + ".s1-B->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_astar_immediate_tail_recursion
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : A a | ;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-EOF->:s2=>2\n"
      unreachable_alts = nil # without
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_no_start_rule
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : A a | X;") # single rule 'a' refers to itself; no start rule
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      msg = equeue.attr_warnings.get(0)
      assert_true("expecting no start rules; found " + (msg.get_class.get_name).to_s, msg.is_a?(GrammarSemanticsMessage))
    end
    
    typesig { [] }
    def test_astar_immediate_tail_recursion2
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : A a | A ;")
      expecting = ".s0-A->.s1\n" + ".s1-A->:s3=>1\n" + ".s1-EOF->:s2=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def testimmediate_left_recursion
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : a A | B;")
      left_recursive = g.get_left_recursive_rules
      add("a")
      expected_rules = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expected_rules, rule_names(left_recursive))
    end
    
    typesig { [] }
    def test_indirect_left_recursion
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : b | A ;\n" + "b : c ;\n" + "c : a | C ;\n")
      left_recursive = g.get_left_recursive_rules
      add("a")
      add("b")
      add("c")
      expected_rules = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expected_rules, rule_names(left_recursive))
    end
    
    typesig { [] }
    def test_left_recursion_in_multiple_cycles
      g = Grammar.new("parser grammar t;\n" + "s : a x ;\n" + "a : b | A ;\n" + "b : c ;\n" + "c : a | C ;\n" + "x : y | X ;\n" + "y : x ;\n")
      left_recursive = g.get_left_recursive_rules
      add("a")
      add("b")
      add("c")
      add("x")
      add("y")
      expected_rules = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals(expected_rules, rule_names(left_recursive))
    end
    
    typesig { [] }
    def test_cycle_inside_rule_does_not_force_infinite_recursion
      g = Grammar.new("parser grammar t;\n" + "s : a ;\n" + "a : (A|)+ B;\n")
      # before I added a visitedStates thing, it was possible to loop
      # forever inside of a rule if there was an epsilon loop.
      left_recursive = g.get_left_recursive_rules
      expected_rules = HashSet.new
      assert_equals(expected_rules, left_recursive)
    end
    
    typesig { [] }
    # L O O P S
    def test_astar
      g = Grammar.new("parser grammar t;\n" + "a : ( A )* ;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-EOF->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_aor_bor_cstar
      g = Grammar.new("parser grammar t;\n" + "a : ( A | B | C )* ;")
      expecting = ".s0-A..C->:s1=>1\n" + ".s0-EOF->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_aplus
      g = Grammar.new("parser grammar t;\n" + "a : ( A )+ ;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-EOF->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0) # loopback decision
    end
    
    typesig { [] }
    def test_aplus_non_greedy_when_deterministic
      g = Grammar.new("parser grammar t;\n" + "a : (options {greedy=false;}:A)+ ;\n")
      # should look the same as A+ since no ambiguity
      expecting = ".s0-A->:s1=>1\n" + ".s0-EOF->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_aplus_non_greedy_when_non_deterministic
      g = Grammar.new("parser grammar t;\n" + "a : (options {greedy=false;}:A)+ A+ ;\n")
      # should look the same as A+ since no ambiguity
      expecting = ".s0-A->:s1=>2\n" # always chooses to exit
      unreachable_alts = Array.typed(::Java::Int).new([1])
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "A"
      dangling_alts = nil
      num_warnings = 2
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_aplus_greedy_when_non_deterministic
      g = Grammar.new("parser grammar t;\n" + "a : (options {greedy=true;}:A)+ A+ ;\n")
      # should look the same as A+ since no ambiguity
      expecting = ".s0-A->:s1=>1\n" # always chooses to enter loop upon A
      unreachable_alts = Array.typed(::Java::Int).new([2])
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "A"
      dangling_alts = nil
      num_warnings = 2
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_aor_bor_cplus
      g = Grammar.new("parser grammar t;\n" + "a : ( A | B | C )+ ;")
      expecting = ".s0-A..C->:s1=>1\n" + ".s0-EOF->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_aoptional
      g = Grammar.new("parser grammar t;\n" + "a : ( A )? B ;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-B->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0) # loopback decision
    end
    
    typesig { [] }
    def test_aor_bor_coptional
      g = Grammar.new("parser grammar t;\n" + "a : ( A | B | C )? Z ;")
      expecting = ".s0-A..C->:s1=>1\n" + ".s0-Z->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0) # loopback decision
    end
    
    typesig { [] }
    # A R B I T R A R Y  L O O K A H E A D
    def test_astar_bor_astar_c
      g = Grammar.new("parser grammar t;\n" + "a : (A)* B | (A)* C;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-B->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0) # loopback
      expecting = ".s0-A->:s1=>1\n" + ".s0-C->:s2=>2\n"
      check_decision(g, 2, expecting, nil, nil, nil, nil, 0) # loopback
      expecting = ".s0-A->.s1\n" + ".s0-B->:s3=>1\n" + ".s0-C->:s2=>2\n" + ".s1-A->.s1\n" + ".s1-B->:s3=>1\n" + ".s1-C->:s2=>2\n"
      check_decision(g, 3, expecting, nil, nil, nil, nil, 0) # rule block
    end
    
    typesig { [] }
    def test_astar_bor_aplus_c
      g = Grammar.new("parser grammar t;\n" + "a : (A)* B | (A)+ C;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-B->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0) # loopback
      expecting = ".s0-A->:s1=>1\n" + ".s0-C->:s2=>2\n"
      check_decision(g, 2, expecting, nil, nil, nil, nil, 0) # loopback
      expecting = ".s0-A->.s1\n" + ".s0-B->:s3=>1\n" + ".s1-A->.s1\n" + ".s1-B->:s3=>1\n" + ".s1-C->:s2=>2\n"
      check_decision(g, 3, expecting, nil, nil, nil, nil, 0) # rule block
    end
    
    typesig { [] }
    def test_aor_bplus_or_aplus
      g = Grammar.new("parser grammar t;\n" + "a : (A|B)* X | (A)+ Y;")
      expecting = ".s0-A..B->:s1=>1\n" + ".s0-X->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0) # loopback (A|B)*
      expecting = ".s0-A->:s1=>1\n" + ".s0-Y->:s2=>2\n"
      check_decision(g, 2, expecting, nil, nil, nil, nil, 0) # loopback (A)+
      expecting = ".s0-A->.s1\n" + ".s0-B..X->:s3=>1\n" + ".s1-A->.s1\n" + ".s1-B..X->:s3=>1\n" + ".s1-Y->:s2=>2\n"
      check_decision(g, 3, expecting, nil, nil, nil, nil, 0) # rule
    end
    
    typesig { [] }
    def test_loopback_and_exit
      g = Grammar.new("parser grammar t;\n" + "a : (A|B)+ B;")
      expecting = ".s0-A->:s2=>1\n" + ".s0-B->.s1\n" + ".s1-A..B->:s2=>1\n" + ".s1-EOF->:s3=>2\n" # sees A|B as a set
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_optional_alt_and_bypass
      g = Grammar.new("parser grammar t;\n" + "a : (A|B)? B;")
      expecting = ".s0-A->:s2=>1\n" + ".s0-B->.s1\n" + ".s1-B->:s2=>1\n" + ".s1-EOF->:s3=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    # R E S O L V E  S Y N  C O N F L I C T S
    def test_resolve_ll1by_choosing_first
      g = Grammar.new("parser grammar t;\n" + "a : A C | A C;")
      expecting = ".s0-A->.s1\n" + ".s1-C->:s2=>1\n"
      unreachable_alts = Array.typed(::Java::Int).new([2])
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "A C"
      dangling_alts = nil
      num_warnings = 2
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_resolve_ll2by_choosing_first
      g = Grammar.new("parser grammar t;\n" + "a : A B | A B;")
      expecting = ".s0-A->.s1\n" + ".s1-B->:s2=>1\n"
      unreachable_alts = Array.typed(::Java::Int).new([2])
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "A B"
      dangling_alts = nil
      num_warnings = 2
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_resolve_ll2mix_alt
      g = Grammar.new("parser grammar t;\n" + "a : A B | A C | A B | Z;")
      expecting = ".s0-A->.s1\n" + ".s0-Z->:s4=>4\n" + ".s1-B->:s2=>1\n" + ".s1-C->:s3=>2\n"
      unreachable_alts = Array.typed(::Java::Int).new([3])
      non_det_alts = Array.typed(::Java::Int).new([1, 3])
      ambig_input = "A B"
      dangling_alts = nil
      num_warnings = 2
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_indirect_ifthen_else_style_ambig
      # the (c)+ loopback is ambig because it could match "CASE"
      # by entering the loop or by falling out and ignoring (s)*
      # back falling back into (cg)* loop which stats over and
      # calls cg again.  Either choice allows it to get back to
      # the same node.  The software catches it as:
      # "avoid infinite closure computation emanating from alt 1
      # of ():27|2|[8 $]" where state 27 is the first alt of (c)+
      # and 8 is the first alt of the (cg)* loop.
      g = Grammar.new("parser grammar t;\n" + "s : stat ;\n" + "stat : LCURLY ( cg )* RCURLY | E SEMI  ;\n" + "cg : (c)+ (stat)* ;\n" + "c : CASE E ;\n")
      expecting = ".s0-CASE->:s2=>1\n" + ".s0-LCURLY..E->:s1=>2\n"
      unreachable_alts = nil
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "CASE"
      dangling_alts = nil
      num_warnings = 1
      check_decision(g, 3, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    # S E T S
    def test_complement
      g = Grammar.new("parser grammar t;\n" + "a : ~(A | B | C) | C {;} ;\n" + "b : X Y Z ;")
      expecting = ".s0-C->:s2=>2\n" + ".s0-X..Z->:s1=>1\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_complement_token
      g = Grammar.new("parser grammar t;\n" + "a : ~C | C {;} ;\n" + "b : X Y Z ;")
      expecting = ".s0-C->:s2=>2\n" + ".s0-X..Z->:s1=>1\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_complement_char
      g = Grammar.new("lexer grammar t;\n" + "A : ~'x' | 'x' {;} ;\n")
      expecting = ".s0-'x'->:s2=>2\n" + ".s0-{'\\u0000'..'w', 'y'..'\\uFFFE'}->:s1=>1\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_complement_char_set
      # collapse into single set
      g = Grammar.new("lexer grammar t;\n" + "A : ~(' '|'\t'|'x'|'y') | 'x';\n" + "B : 'y' ;")
      expecting = ".s0-'y'->:s2=>2\n" + ".s0-{'\\u0000'..'\\b', '\\n'..'\\u001F', '!'..'x', 'z'..'\\uFFFE'}->:s1=>1\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_no_set_collapse_with_actions
      g = Grammar.new("parser grammar t;\n" + "a : (A | B {foo}) | C;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-B->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_rule_alts_set_collapse
      g = Grammar.new("parser grammar t;\n" + "a : A | B | C ;")
      # still looks like block
      expecting = " ( grammar t ( rule a ARG RET scope ( BLOCK ( ALT A <end-of-alt> ) ( ALT B <end-of-alt> ) ( ALT C <end-of-alt> ) <end-of-block> ) <end-of-rule> ) )"
      assert_equals(expecting, g.get_grammar_tree.to_string_tree)
    end
    
    typesig { [] }
    def test_tokens_rule_alts_do_not_collapse
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';" + "B : 'b';\n")
      expecting = ".s0-'a'->:s1=>1\n" + ".s0-'b'->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_multiple_sequence_collision
      g = Grammar.new("parser grammar t;\n" + "a : (A{;}|B)\n" + "  | (A{;}|B)\n" + "  | A\n" + "  ;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-B->:s2=>1\n" # not optimized because states are nondet
      unreachable_alts = Array.typed(::Java::Int).new([2, 3])
      non_det_alts = Array.typed(::Java::Int).new([1, 2, 3])
      ambig_input = "A"
      dangling_alts = nil
      num_warnings = 3
      check_decision(g, 3, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
      # There are 2 nondet errors, but the checkDecision only checks first one :(
      # The "B" conflicting input is not checked except by virtue of the
      # result DFA.
      # <string>:2:5: Decision can match input such as "A" using multiple alternatives:
      # alt 1 via NFA path 7,2,3
      # alt 2 via NFA path 14,9,10
      # alt 3 via NFA path 16,17
      # As a result, alternative(s) 2,3 were disabled for that input,
      # <string>:2:5: Decision can match input such as "B" using multiple alternatives:
      # alt 1 via NFA path 7,8,4,5
      # alt 2 via NFA path 14,15,11,12
      # As a result, alternative(s) 2 were disabled for that input
      # <string>:2:5: The following alternatives are unreachable: 2,3
    end
    
    typesig { [] }
    def test_multiple_alts_same_sequence_collision
      g = Grammar.new("parser grammar t;\n" + "a : type ID \n" + "  | type ID\n" + "  | type ID\n" + "  | type ID\n" + "  ;\n" + "\n" + "type : I | F;")
      # nondeterministic from left edge; no stop state
      expecting = ".s0-I..F->.s1\n" + ".s1-ID->:s2=>1\n"
      unreachable_alts = Array.typed(::Java::Int).new([2, 3, 4])
      non_det_alts = Array.typed(::Java::Int).new([1, 2, 3, 4])
      ambig_input = "I..F ID"
      dangling_alts = nil
      num_warnings = 2
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_follow_returns_to_loop_reentering_same_rule
      # D07 can be matched in the (...)? or fall out of esc back into (..)*
      # loop in sl.  Note that D07 is matched by ~(R|SLASH).  No good
      # way to write that grammar I guess
      g = Grammar.new("parser grammar t;\n" + "sl : L ( esc | ~(R|SLASH) )* R ;\n" + "\n" + "esc : SLASH ( N | D03 (D07)? ) ;")
      expecting = ".s0-R->:s3=>3\n" + ".s0-SLASH->:s1=>1\n" + ".s0-{L, N..D07}->:s2=>2\n"
      unreachable_alts = nil
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "D07"
      dangling_alts = nil
      num_warnings = 1
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_token_calls_another_on_left_edge
      g = Grammar.new("lexer grammar t;\n" + "F   :   I '.'\n" + "    ;\n" + "I   :   '0'\n" + "    ;\n")
      expecting = ".s0-'0'->.s1\n" + ".s1-'.'->:s3=>1\n" + ".s1-<EOT>->:s2=>2\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [] }
    def test_self_recursion_ambig_alts
      # ambiguous grammar for "L ID R" (alts 1,2 of a)
      # disabled for L ID R
      g = Grammar.new("parser grammar t;\n" + "s : a;\n" + "a   :   L ID R\n" + "    |   L a R\n" + "    |   b\n" + "    ;\n" + "\n" + "b   :   ID\n" + "    ;\n")
      expecting = ".s0-ID->:s5=>3\n" + ".s0-L->.s1\n" + ".s1-ID->.s2\n" + ".s1-L->:s4=>2\n" + ".s2-R->:s3=>1\n"
      unreachable_alts = nil
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "L ID R"
      dangling_alts = nil
      num_warnings = 1
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_indirect_recursion_ambig_alts
      # ambiguous grammar for "L ID R" (alts 1,2 of a)
      # This was derived from the java grammar 12/4/2004 when it
      # was not handling a unaryExpression properly.  I traced it
      # to incorrect closure-busy condition.  It thought that the trace
      # of a->b->a->b again for "L ID" was an infinite loop, but actually
      # the repeat call to b only happens *after* an L has been matched.
      # I added a check to see what the initial stack looks like and it
      # seems to work now.
      g = Grammar.new("parser grammar t;\n" + "s   :   a ;\n" + "a   :   L ID R\n" + "    |   b\n" + "    ;\n" + "\n" + "b   :   ID\n" + "    |   L a R\n" + "    ;")
      expecting = ".s0-ID->:s4=>2\n" + ".s0-L->.s1\n" + ".s1-ID->.s2\n" + ".s1-L->:s4=>2\n" + ".s2-R->:s3=>1\n"
      unreachable_alts = nil
      non_det_alts = Array.typed(::Java::Int).new([1, 2])
      ambig_input = "L ID R"
      dangling_alts = nil
      num_warnings = 1
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_tail_recursion_invoked_from_arbitrary_lookahead_decision
      g = Grammar.new("parser grammar t;\n" + "a : b X\n" + "  | b Y\n" + "  ;\n" + "\n" + "b : A\n" + "  | A b\n" + "  ;\n")
      alts_with_recursion = Arrays.as_list(Array.typed(Object).new([1, 2]))
      assert_non_llstar(g, alts_with_recursion)
    end
    
    typesig { [] }
    def test_wildcard_star_k1and_non_greedy_by_default_in_parser
      # no error because .* assumes it should finish when it sees R
      g = Grammar.new("parser grammar t;\n" + "s : A block EOF ;\n" + "block : L .* R ;")
      expecting = ".s0-A..L->:s2=>1\n" + ".s0-R->:s1=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_wildcard_plus_k1and_non_greedy_by_default_in_parser
      g = Grammar.new("parser grammar t;\n" + "s : A block EOF ;\n" + "block : L .+ R ;")
      expecting = ".s0-A..L->:s2=>1\n" + ".s0-R->:s1=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
    end
    
    typesig { [] }
    def test_gated_syn_pred
      g = Grammar.new("parser grammar t;\n" + "x   : (X)=> X\n" + "    | Y\n" + "    ;\n")
      # does not hoist; it gates edges
      expecting = ".s0-X&&{synpred1_t}?->:s1=>1\n" + ".s0-Y->:s2=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
      preds = g.attr_syn_pred_names_used_in_dfa
      add("synpred1_t")
      expected_preds = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals("predicate names not recorded properly in grammar", expected_preds, preds)
    end
    
    typesig { [] }
    def test_hoisted_gated_syn_pred
      g = Grammar.new("parser grammar t;\n" + "x   : (X)=> X\n" + "    | X\n" + "    ;\n")
      # hoists into decision
      expecting = ".s0-X->.s1\n" + ".s1-{synpred1_t}?->:s2=>1\n" + ".s1-{true}?->:s3=>2\n"
      unreachable_alts = nil
      non_det_alts = nil
      ambig_input = nil
      dangling_alts = nil
      num_warnings = 0
      check_decision(g, 1, expecting, unreachable_alts, non_det_alts, ambig_input, dangling_alts, num_warnings)
      preds = g.attr_syn_pred_names_used_in_dfa
      add("synpred1_t")
      expected_preds = Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members TestDFAConversion
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      assert_equals("predicate names not recorded properly in grammar", expected_preds, preds)
    end
    
    typesig { [] }
    # Check state table creation
    def test_cyclic_table_creation
      g = Grammar.new("parser grammar t;\n" + "a : A+ X | A+ Y ;")
      expecting = ".s0-A->:s1=>1\n" + ".s0-B->:s2=>2\n"
    end
    
    typesig { [] }
    # S U P P O R T
    def __template
      g = Grammar.new("parser grammar t;\n" + "a : A | B;")
      expecting = "\n"
      check_decision(g, 1, expecting, nil, nil, nil, nil, 0)
    end
    
    typesig { [Grammar, JavaList] }
    def assert_non_llstar(g, expected_bad_alts)
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # mimic actions of org.antlr.Tool first time for grammar g
      if ((g.get_number_of_decisions).equal?(0))
        g.build_nfa
        g.create_lookahead_dfas(false)
      end
      msg = get_non_regular_decision_message(equeue.attr_errors)
      assert_true("expected fatal non-LL(*) msg", !(msg).nil?)
      alts = ArrayList.new
      alts.add_all(msg.attr_alts_with_recursion)
      Collections.sort(alts)
      assert_equals(expected_bad_alts, alts)
    end
    
    typesig { [Grammar, JavaList, ::Java::Int] }
    def assert_recursion_overflow(g, expected_target_rules, expected_alt)
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # mimic actions of org.antlr.Tool first time for grammar g
      if ((g.get_number_of_decisions).equal?(0))
        g.build_nfa
        g.create_lookahead_dfas(false)
      end
      msg = get_recursion_overflow_message(equeue.attr_errors)
      assert_true("missing expected recursion overflow msg" + (msg).to_s, !(msg).nil?)
      assert_equals("target rules mismatch", expected_target_rules.to_s, msg.attr_target_rules.to_s)
      assert_equals("mismatched alt", expected_alt, msg.attr_alt)
    end
    
    typesig { [Grammar, ::Java::Int, String, Array.typed(::Java::Int), Array.typed(::Java::Int), String, Array.typed(::Java::Int), ::Java::Int] }
    def check_decision(g, decision, expecting, expecting_unreachable_alts, expecting_non_det_alts, expecting_ambig_input, expecting_dangling_alts, expecting_num_warnings)
      DecisionProbe.attr_verbose = true # make sure we get all error info
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # mimic actions of org.antlr.Tool first time for grammar g
      if ((g.get_number_of_decisions).equal?(0))
        g.build_nfa
        g.create_lookahead_dfas(false)
      end
      generator = CodeGenerator.new(new_tool, g, "Java")
      g.set_code_generator(generator)
      if (!(equeue.size).equal?(expecting_num_warnings))
        System.err.println("Warnings issued: " + (equeue).to_s)
      end
      assert_equals("unexpected number of expected problems", expecting_num_warnings, equeue.size)
      dfa = g.get_lookahead_dfa(decision)
      assert_not_null("no DFA for decision " + (decision).to_s, dfa)
      serializer = FASerializer.new(g)
      result = serializer.serialize(dfa.attr_start_state)
      unreachable_alts = dfa.get_unreachable_alts
      # make sure unreachable alts are as expected
      if (!(expecting_unreachable_alts).nil?)
        s = BitSet.new
        s.add_all(expecting_unreachable_alts)
        s2 = BitSet.new
        s2.add_all(unreachable_alts)
        assert_equals("unreachable alts mismatch", s, s2)
      else
        assert_equals("number of unreachable alts", 0, !(unreachable_alts).nil? ? unreachable_alts.size : 0)
      end
      # check conflicting input
      if (!(expecting_ambig_input).nil?)
        # first, find nondet message
        msg = equeue.attr_warnings.get(0)
        assert_true("expecting nondeterminism; found " + (msg.get_class.get_name).to_s, msg.is_a?(GrammarNonDeterminismMessage))
        nondet_msg = get_non_determinism_message(equeue.attr_warnings)
        labels = nondet_msg.attr_probe.get_sample_non_deterministic_input_sequence(nondet_msg.attr_problem_state)
        input = nondet_msg.attr_probe.get_input_sequence_display(labels)
        assert_equals(expecting_ambig_input, input)
      end
      # check nondet alts
      if (!(expecting_non_det_alts).nil?)
        rec_msg = nil
        nondet_msg_ = get_non_determinism_message(equeue.attr_warnings)
        non_det_alts = nil
        if (!(nondet_msg_).nil?)
          non_det_alts = nondet_msg_.attr_probe.get_non_deterministic_alts_for_state(nondet_msg_.attr_problem_state)
        else
          rec_msg = get_recursion_overflow_message(equeue.attr_warnings)
          if (!(rec_msg).nil?)
            # nonDetAlts = new ArrayList(recMsg.alts);
          end
        end
        # compare nonDetAlts with expectingNonDetAlts
        s_ = BitSet.new
        s_.add_all(expecting_non_det_alts)
        s2_ = BitSet.new
        s2_.add_all(non_det_alts)
        assert_equals("nondet alts mismatch", s_, s2_)
        assert_true("found no nondet alts; expecting: " + (str(expecting_non_det_alts)).to_s, !(nondet_msg_).nil? || !(rec_msg).nil?)
      else
        # not expecting any nondet alts, make sure there are none
        nondet_msg__ = get_non_determinism_message(equeue.attr_warnings)
        assert_null("found nondet alts, but expecting none", nondet_msg__)
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
        ((i += 1) - 1)
      end
      return nil
    end
    
    typesig { [JavaList] }
    def get_non_regular_decision_message(errors)
      i = 0
      while i < errors.size
        m = errors.get(i)
        if (m.is_a?(NonRegularDecisionMessage))
          return m
        end
        ((i += 1) - 1)
      end
      return nil
    end
    
    typesig { [JavaList] }
    def get_recursion_overflow_message(warnings)
      i = 0
      while i < warnings.size
        m = warnings.get(i)
        if (m.is_a?(RecursionOverflowMessage))
          return m
        end
        ((i += 1) - 1)
      end
      return nil
    end
    
    typesig { [JavaList] }
    def get_left_recursion_cycles_message(warnings)
      i = 0
      while i < warnings.size
        m = warnings.get(i)
        if (m.is_a?(LeftRecursionCyclesMessage))
          return m
        end
        ((i += 1) - 1)
      end
      return nil
    end
    
    typesig { [JavaList] }
    def get_dangling_state_message(warnings)
      i = 0
      while i < warnings.size
        m = warnings.get(i)
        if (m.is_a?(GrammarDanglingStateMessage))
          return m
        end
        ((i += 1) - 1)
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
        ((i += 1) - 1)
      end
      return buf.to_s
    end
    
    typesig { [JavaSet] }
    def rule_names(rules)
      x = HashSet.new
      rules.each do |r|
        x.add(r.attr_name)
      end
      return x
    end
    
    typesig { [Collection] }
    def rule_names2(rules)
      x = HashSet.new
      rules.each do |s|
        x.add_all(rule_names(s))
      end
      return x
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_dfaconversion, :initialize
  end
  
end
