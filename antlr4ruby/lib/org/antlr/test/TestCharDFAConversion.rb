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
  module TestCharDFAConversionImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Analysis, :DFA
      include_const ::Org::Antlr::Analysis, :DFAOptimizer
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include ::Org::Antlr::Tool
      include_const ::Java::Util, :JavaList
    }
  end
  
  class TestCharDFAConversion < TestCharDFAConversionImports.const_get :BaseTest
    include_class_members TestCharDFAConversionImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    # R A N G E S  &  S E T S
    def test_simple_range_versus_char
      g = Grammar.new("lexer grammar t;\n" + "A : 'a'..'z' '@' | 'k' '$' ;")
      g.create_lookahead_dfas
      expecting = ".s0-'k'->.s1\n" + ".s0-{'a'..'j', 'l'..'z'}->:s2=>1\n" + ".s1-'$'->:s3=>2\n" + ".s1-'@'->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_range_with_disjoint_set
      g = Grammar.new("lexer grammar t;\n" + "A : 'a'..'z' '@'\n" + "  | ('k'|'9'|'p') '$'\n" + "  ;\n")
      g.create_lookahead_dfas
      # must break up a..z into {'a'..'j', 'l'..'o', 'q'..'z'}
      expecting = ".s0-'9'->:s3=>2\n" + ".s0-{'a'..'j', 'l'..'o', 'q'..'z'}->:s2=>1\n" + ".s0-{'k', 'p'}->.s1\n" + ".s1-'$'->:s3=>2\n" + ".s1-'@'->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_disjoint_set_colliding_with_two_ranges
      g = Grammar.new("lexer grammar t;\n" + "A : ('a'..'z'|'0'..'9') '@'\n" + "  | ('k'|'9'|'p') '$'\n" + "  ;\n")
      g.create_lookahead_dfas(false)
      # must break up a..z into {'a'..'j', 'l'..'o', 'q'..'z'} and 0..9
      # into 0..8
      expecting = ".s0-{'0'..'8', 'a'..'j', 'l'..'o', 'q'..'z'}->:s2=>1\n" + ".s0-{'9', 'k', 'p'}->.s1\n" + ".s1-'$'->:s3=>2\n" + ".s1-'@'->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_disjoint_set_colliding_with_two_ranges_chars_first
      g = Grammar.new("lexer grammar t;\n" + "A : ('k'|'9'|'p') '$'\n" + "  | ('a'..'z'|'0'..'9') '@'\n" + "  ;\n")
      # must break up a..z into {'a'..'j', 'l'..'o', 'q'..'z'} and 0..9
      # into 0..8
      expecting = ".s0-{'0'..'8', 'a'..'j', 'l'..'o', 'q'..'z'}->:s3=>2\n" + ".s0-{'9', 'k', 'p'}->.s1\n" + ".s1-'$'->:s2=>1\n" + ".s1-'@'->:s3=>2\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_disjoint_set_colliding_with_two_ranges_as_separate_alts
      g = Grammar.new("lexer grammar t;\n" + "A : 'a'..'z' '@'\n" + "  | 'k' '$'\n" + "  | '9' '$'\n" + "  | 'p' '$'\n" + "  | '0'..'9' '@'\n" + "  ;\n")
      # must break up a..z into {'a'..'j', 'l'..'o', 'q'..'z'} and 0..9
      # into 0..8
      expecting = ".s0-'0'..'8'->:s8=>5\n" + ".s0-'9'->.s6\n" + ".s0-'k'->.s1\n" + ".s0-'p'->.s4\n" + ".s0-{'a'..'j', 'l'..'o', 'q'..'z'}->:s2=>1\n" + ".s1-'$'->:s3=>2\n" + ".s1-'@'->:s2=>1\n" + ".s4-'$'->:s5=>4\n" + ".s4-'@'->:s2=>1\n" + ".s6-'$'->:s7=>3\n" + ".s6-'@'->:s8=>5\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_keyword_versus_id
      # choose this over ID
      g = Grammar.new("lexer grammar t;\n" + "IF : 'if' ;\n" + "ID : ('a'..'z')+ ;\n")
      expecting = ".s0-'a'..'z'->:s2=>1\n" + ".s0-<EOT>->:s1=>2\n"
      check_decision(g, 1, expecting, nil)
      expecting = ".s0-'i'->.s1\n" + ".s0-{'a'..'h', 'j'..'z'}->:s4=>2\n" + ".s1-'f'->.s2\n" + ".s1-<EOT>->:s4=>2\n" + ".s2-'a'..'z'->:s4=>2\n" + ".s2-<EOT>->:s3=>1\n"
      check_decision(g, 2, expecting, nil)
    end
    
    typesig { [] }
    def test_identical_rules
      g = Grammar.new("lexer grammar t;\n" + "A : 'a' ;\n" + "B : 'a' ;\n") # can't reach this
      expecting = ".s0-'a'->.s1\n" + ".s1-<EOT>->:s2=>1\n"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([2]))
      assert_equals("unexpected number of expected problems", 1, equeue.size)
      msg = equeue.attr_errors.get(0)
      assert_true("warning must be an unreachable alt", msg.is_a?(GrammarUnreachableAltsMessage))
      u = msg
      assert_equals("[2]", u.attr_alts.to_s)
    end
    
    typesig { [] }
    def test_adjacent_not_char_loops
      g = Grammar.new("lexer grammar t;\n" + "A : (~'r')+ ;\n" + "B : (~'s')+ ;\n")
      expecting = ".s0-'r'->:s3=>2\n" + ".s0-'s'->:s2=>1\n" + ".s0-{'\\u0000'..'q', 't'..'\\uFFFE'}->.s1\n" + ".s1-'r'->:s3=>2\n" + ".s1-<EOT>->:s2=>1\n" + ".s1-{'\\u0000'..'q', 't'..'\\uFFFE'}->.s1\n"
      check_decision(g, 3, expecting, nil)
    end
    
    typesig { [] }
    def test_non_adjacent_not_char_loops
      g = Grammar.new("lexer grammar t;\n" + "A : (~'r')+ ;\n" + "B : (~'t')+ ;\n")
      expecting = ".s0-'r'->:s3=>2\n" + ".s0-'t'->:s2=>1\n" + ".s0-{'\\u0000'..'q', 's', 'u'..'\\uFFFE'}->.s1\n" + ".s1-'r'->:s3=>2\n" + ".s1-<EOT>->:s2=>1\n" + ".s1-{'\\u0000'..'q', 's', 'u'..'\\uFFFE'}->.s1\n"
      check_decision(g, 3, expecting, nil)
    end
    
    typesig { [] }
    def test_loops_with_optimized_out_exit_branches
      g = Grammar.new("lexer grammar t;\n" + "A : 'x'* ~'x'+ ;\n")
      expecting = ".s0-'x'->:s1=>1\n" + ".s0-{'\\u0000'..'w', 'y'..'\\uFFFE'}->:s2=>2\n"
      check_decision(g, 1, expecting, nil)
      # The optimizer yanks out all exit branches from EBNF blocks
      # This is ok because we've already verified there are no problems
      # with the enter/exit decision
      optimizer = DFAOptimizer.new(g)
      optimizer.optimize
      serializer = FASerializer.new(g)
      dfa = g.get_lookahead_dfa(1)
      result = serializer.serialize(dfa.attr_start_state)
      expecting = ".s0-'x'->:s1=>1\n"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    # N O N G R E E D Y
    def test_non_greedy
      g = Grammar.new("lexer grammar t;\n" + "CMT : '/*' ( options {greedy=false;} : . )* '*/' ;")
      expecting = ".s0-'*'->.s1\n" + ".s0-{'\\u0000'..')', '+'..'\\uFFFE'}->:s3=>1\n" + ".s1-'/'->:s2=>2\n" + ".s1-{'\\u0000'..'.', '0'..'\\uFFFE'}->:s3=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_non_greedy_wildcard_star
      g = Grammar.new("lexer grammar t;\n" + "SLCMT : '//' ( options {greedy=false;} : . )* '\n' ;")
      expecting = ".s0-'\\n'->:s1=>2\n" + ".s0-{'\\u0000'..'\\t', '\\u000B'..'\\uFFFE'}->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_non_greedy_by_default_wildcard_star
      g = Grammar.new("lexer grammar t;\n" + "SLCMT : '//' .* '\n' ;")
      expecting = ".s0-'\\n'->:s1=>2\n" + ".s0-{'\\u0000'..'\\t', '\\u000B'..'\\uFFFE'}->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_non_greedy_wildcard_plus
      # same DFA as nongreedy .* but code gen checks number of
      # iterations at runtime
      g = Grammar.new("lexer grammar t;\n" + "SLCMT : '//' ( options {greedy=false;} : . )+ '\n' ;")
      expecting = ".s0-'\\n'->:s1=>2\n" + ".s0-{'\\u0000'..'\\t', '\\u000B'..'\\uFFFE'}->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_non_greedy_by_default_wildcard_plus
      g = Grammar.new("lexer grammar t;\n" + "SLCMT : '//' .+ '\n' ;")
      expecting = ".s0-'\\n'->:s1=>2\n" + ".s0-{'\\u0000'..'\\t', '\\u000B'..'\\uFFFE'}->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_non_greedy_by_default_wildcard_plus_with_parens
      g = Grammar.new("lexer grammar t;\n" + "SLCMT : '//' (.)+ '\n' ;")
      expecting = ".s0-'\\n'->:s1=>2\n" + ".s0-{'\\u0000'..'\\t', '\\u000B'..'\\uFFFE'}->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_non_wildcard_non_greedy
      g = Grammar.new("lexer grammar t;\n" + "DUH : (options {greedy=false;}:'x'|'y')* 'xy' ;")
      expecting = ".s0-'x'->.s1\n" + ".s0-'y'->:s4=>2\n" + ".s1-'x'->:s3=>1\n" + ".s1-'y'->:s2=>3\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_non_wildcard_eotmakes_it_work_without_non_greedy_option
      g = Grammar.new("lexer grammar t;\n" + "DUH : ('x'|'y')* 'xy' ;")
      expecting = ".s0-'x'->.s1\n" + ".s0-'y'->:s3=>1\n" + ".s1-'x'->:s3=>1\n" + ".s1-'y'->.s2\n" + ".s2-'x'..'y'->:s3=>1\n" + ".s2-<EOT>->:s4=>2\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_alt_conflicts_with_loop_then_exit
      # \" predicts alt 1, but wildcard then " can predict exit also
      g = Grammar.new("lexer grammar t;\n" + "STRING : '\"' (options {greedy=false;}: '\\\\\"' | .)* '\"' ;\n")
      expecting = ".s0-'\"'->:s1=>3\n" + ".s0-'\\\\'->.s2\n" + ".s0-{'\\u0000'..'!', '#'..'[', ']'..'\\uFFFE'}->:s4=>2\n" + ".s2-'\"'->:s3=>1\n" + ".s2-{'\\u0000'..'!', '#'..'\\uFFFE'}->:s4=>2\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_non_greedy_loop_that_never_loops
      g = Grammar.new("lexer grammar t;\n" + "DUH : (options {greedy=false;}:'x')+ ;") # loop never matched
      expecting = ":s0=>2\n"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      check_decision(g, 1, expecting, Array.typed(::Java::Int).new([1]))
      assert_equals("unexpected number of expected problems", 1, equeue.size)
      msg = equeue.attr_errors.get(0)
      assert_true("warning must be an unreachable alt", msg.is_a?(GrammarUnreachableAltsMessage))
      u = msg
      assert_equals("[1]", u.attr_alts.to_s)
    end
    
    typesig { [] }
    def test_recursive
      # this is cool because the 3rd alt includes !(all other possibilities)
      g = Grammar.new("lexer grammar duh;\n" + "SUBTEMPLATE\n" + "        :       '{'\n" + "                ( SUBTEMPLATE\n" + "                | ESC\n" + "                | ~('}'|'\\\\'|'{')\n" + "                )*\n" + "                '}'\n" + "        ;\n" + "fragment\n" + "ESC     :       '\\\\' . ;")
      g.create_lookahead_dfas
      expecting = ".s0-'\\\\'->:s2=>2\n" + ".s0-'{'->:s1=>1\n" + ".s0-'}'->:s4=>4\n" + ".s0-{'\\u0000'..'[', ']'..'z', '|', '~'..'\\uFFFE'}->:s3=>3\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_recursive2
      # this is also cool because it resolves \\ to be ESC alt; it's just
      # less efficient of a DFA
      g = Grammar.new("lexer grammar duh;\n" + "SUBTEMPLATE\n" + "        :       '{'\n" + "                ( SUBTEMPLATE\n" + "                | ESC\n" + "                | ~('}'|'{')\n" + "                )*\n" + "                '}'\n" + "        ;\n" + "fragment\n" + "ESC     :       '\\\\' . ;")
      g.create_lookahead_dfas
      expecting = ".s0-'\\\\'->.s3\n" + ".s0-'{'->:s2=>1\n" + ".s0-'}'->:s1=>4\n" + ".s0-{'\\u0000'..'[', ']'..'z', '|', '~'..'\\uFFFE'}->:s5=>3\n" + ".s3-'\\\\'->:s8=>2\n" + ".s3-'{'->:s7=>2\n" + ".s3-'}'->.s4\n" + ".s3-{'\\u0000'..'[', ']'..'z', '|', '~'..'\\uFFFE'}->:s6=>2\n" + ".s4-'\\u0000'..'\\uFFFE'->:s6=>2\n" + ".s4-<EOT>->:s5=>3\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_not_fragment_in_lexer
      g = Grammar.new("lexer grammar T;\n" + "A : 'a' | ~B {;} ;\n" + "fragment B : 'a' ;\n")
      g.create_lookahead_dfas
      expecting = ".s0-'a'->:s1=>1\n" + ".s0-{'\\u0000'..'`', 'b'..'\\uFFFE'}->:s2=>2\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_not_set_fragment_in_lexer
      g = Grammar.new("lexer grammar T;\n" + "A : B | ~B {;} ;\n" + "fragment B : 'a'|'b' ;\n")
      g.create_lookahead_dfas
      expecting = ".s0-'a'..'b'->:s1=>1\n" + ".s0-{'\\u0000'..'`', 'c'..'\\uFFFE'}->:s2=>2\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_not_token_in_lexer
      g = Grammar.new("lexer grammar T;\n" + "A : 'x' ('a' | ~B {;}) ;\n" + "B : 'a' ;\n")
      g.create_lookahead_dfas
      expecting = ".s0-'a'->:s1=>1\n" + ".s0-{'\\u0000'..'`', 'b'..'\\uFFFE'}->:s2=>2\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_not_complicated_set_rule_in_lexer
      g = Grammar.new("lexer grammar T;\n" + "A : B | ~B {;} ;\n" + "fragment B : 'a'|'b'|'c'..'e'|C ;\n" + "fragment C : 'f' ;\n") # has to seen from B to C
      expecting = ".s0-'a'..'f'->:s1=>1\n" + ".s0-{'\\u0000'..'`', 'g'..'\\uFFFE'}->:s2=>2\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_not_set_with_rule_in_lexer
      g = Grammar.new("lexer grammar T;\n" + "T : ~('a' | B) | 'a';\n" + "fragment\n" + "B : 'b' ;\n" + "C : ~'x'{;} ;") # force Tokens to not collapse T|C
      expecting = ".s0-'b'->:s3=>2\n" + ".s0-'x'->:s2=>1\n" + ".s0-{'\\u0000'..'a', 'c'..'w', 'y'..'\\uFFFE'}->.s1\n" + ".s1-<EOT>->:s2=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_set_calls_rule_with_not
      g = Grammar.new("lexer grammar A;\n" + "T : ~'x' ;\n" + "S : 'x' (T | 'x') ;\n")
      expecting = ".s0-'x'->:s2=>2\n" + ".s0-{'\\u0000'..'w', 'y'..'\\uFFFE'}->:s1=>1\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [] }
    def test_syn_pred_in_lexer
      # this was causing syntax error
      g = Grammar.new("lexer grammar T;\n" + "LT:  '<' ' '*\n" + "  |  ('<' IDENT) => '<' IDENT '>'\n" + "  ;\n" + "IDENT:    'a'+;\n")
      # basically, Tokens rule should not do set compression test
      expecting = ".s0-'<'->:s1=>1\n" + ".s0-'a'->:s2=>2\n"
      check_decision(g, 4, expecting, nil) # 4 is Tokens rule
    end
    
    typesig { [] }
    # S U P P O R T
    def __template
      g = Grammar.new("grammar T;\n" + "a : A | B;")
      expecting = "\n"
      check_decision(g, 1, expecting, nil)
    end
    
    typesig { [Grammar, ::Java::Int, String, Array.typed(::Java::Int)] }
    def check_decision(g, decision, expecting, expecting_unreachable_alts)
      # mimic actions of org.antlr.Tool first time for grammar g
      if ((g.get_code_generator).nil?)
        generator = CodeGenerator.new(nil, g, "Java")
        g.set_code_generator(generator)
        g.build_nfa
        g.create_lookahead_dfas(false)
      end
      dfa = g.get_lookahead_dfa(decision)
      assert_not_null("unknown decision #" + (decision).to_s, dfa)
      serializer = FASerializer.new(g)
      result = serializer.serialize(dfa.attr_start_state)
      # System.out.print(result);
      non_det_alts = dfa.get_unreachable_alts
      # System.out.println("alts w/o predict state="+nonDetAlts);
      # first make sure nondeterministic alts are as expected
      if ((expecting_unreachable_alts).nil?)
        if (!(non_det_alts).nil? && !(non_det_alts.size).equal?(0))
          System.err.println("nondeterministic alts (should be empty): " + (non_det_alts).to_s)
        end
        assert_equals("unreachable alts mismatch", 0, !(non_det_alts).nil? ? non_det_alts.size : 0)
      else
        i = 0
        while i < expecting_unreachable_alts.attr_length
          assert_true("unreachable alts mismatch", !(non_det_alts).nil? ? non_det_alts.contains(expecting_unreachable_alts[i]) : false)
          i += 1
        end
      end
      assert_equals(expecting, result)
    end
    
    private
    alias_method :initialize__test_char_dfaconversion, :initialize
  end
  
end
