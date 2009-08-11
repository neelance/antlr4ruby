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
  module TestNFAConstructionImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Analysis, :State
      include_const ::Org::Antlr::Tool, :FASerializer
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  class TestNFAConstruction < TestNFAConstructionImports.const_get :BaseTest
    include_class_members TestNFAConstructionImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_a
      g = Grammar.new("parser grammar P;\n" + "a : A;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-A->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_ab
      g = Grammar.new("parser grammar P;\n" + "a : A B ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-A->.s3\n" + ".s3-B->.s4\n" + ".s4->:s5\n" + ":s5-EOF->.s6\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_aor_b
      g = Grammar.new("parser grammar P;\n" + "a : A | B {;} ;")
      # expecting (0)--Ep-->(1)--Ep-->(2)--A-->(3)--Ep-->(4)--Ep-->(5,end)
      # |                            ^
      # (6)--Ep-->(7)--B-->(8)--------|
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s1->.s7\n" + ".s10->.s4\n" + ".s2-A->.s3\n" + ".s3->.s4\n" + ".s4->:s5\n" + ".s7->.s8\n" + ".s8-B->.s9\n" + ".s9-{}->.s10\n" + ":s5-EOF->.s6\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_range_or_range
      g = Grammar.new("lexer grammar P;\n" + "A : ('a'..'c' 'h' | 'q' 'j'..'l') ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10-'q'->.s11\n" + ".s11-'j'..'l'->.s12\n" + ".s12->.s6\n" + ".s2->.s3\n" + ".s2->.s9\n" + ".s3-'a'..'c'->.s4\n" + ".s4-'h'->.s5\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s10\n" + ":s7-<EOT>->.s8\n"
      check_rule(g, "A", expecting)
    end
    
    typesig { [] }
    def test_range
      g = Grammar.new("lexer grammar P;\n" + "A : 'a'..'c' ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-'a'..'c'->.s3\n" + ".s3->:s4\n" + ":s4-<EOT>->.s5\n"
      check_rule(g, "A", expecting)
    end
    
    typesig { [] }
    def test_char_set_in_parser
      g = Grammar.new("grammar P;\n" + "a : A|'b' ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-A..'b'->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_abor_cd
      g = Grammar.new("parser grammar P;\n" + "a : A B | C D;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s1->.s8\n" + ".s10-D->.s11\n" + ".s11->.s5\n" + ".s2-A->.s3\n" + ".s3-B->.s4\n" + ".s4->.s5\n" + ".s5->:s6\n" + ".s8->.s9\n" + ".s9-C->.s10\n" + ":s6-EOF->.s7\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def testb_a
      g = Grammar.new("parser grammar P;\n" + "a : b A ;\n" + "b : B ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4->.s5\n" + ".s5-B->.s6\n" + ".s6->:s7\n" + ".s8-A->.s9\n" + ".s9->:s10\n" + ":s10-EOF->.s11\n" + ":s7->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def testb_a_b_c
      g = Grammar.new("parser grammar P;\n" + "a : b A ;\n" + "b : B ;\n" + "c : b C;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s12->.s13\n" + ".s13-C->.s14\n" + ".s14->:s15\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4->.s5\n" + ".s5-B->.s6\n" + ".s6->:s7\n" + ".s8-A->.s9\n" + ".s9->:s10\n" + ":s10-EOF->.s11\n" + ":s15-EOF->.s16\n" + ":s7->.s12\n" + ":s7->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_aor_epsilon
      g = Grammar.new("parser grammar P;\n" + "a : A | ;")
      # expecting (0)--Ep-->(1)--Ep-->(2)--A-->(3)--Ep-->(4)--Ep-->(5,end)
      # |                            ^
      # (6)--Ep-->(7)--Ep-->(8)-------|
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s1->.s7\n" + ".s2-A->.s3\n" + ".s3->.s4\n" + ".s4->:s5\n" + ".s7->.s8\n" + ".s8->.s9\n" + ".s9->.s4\n" + ":s5-EOF->.s6\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_aoptional
      g = Grammar.new("parser grammar P;\n" + "a : (A)?;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s8\n" + ".s3-A->.s4\n" + ".s4->.s5\n" + ".s5->:s6\n" + ".s8->.s5\n" + ":s6-EOF->.s7\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_naked_aoptional
      g = Grammar.new("parser grammar P;\n" + "a : A?;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s8\n" + ".s3-A->.s4\n" + ".s4->.s5\n" + ".s5->:s6\n" + ".s8->.s5\n" + ":s6-EOF->.s7\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_aor_bthen_c
      g = Grammar.new("parser grammar P;\n" + "a : (A | B) C;")
      # expecting
      # 
      # (0)--Ep-->(1)--Ep-->(2)--A-->(3)--Ep-->(4)--Ep-->(5)--C-->(6)--Ep-->(7,end)
      # |                            ^
      # (8)--Ep-->(9)--B-->(10)-------|
    end
    
    typesig { [] }
    def test_aplus
      g = Grammar.new("parser grammar P;\n" + "a : (A)+;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4-A->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_naked_aplus
      g = Grammar.new("parser grammar P;\n" + "a : A+;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4-A->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_aplus_non_greedy
      g = Grammar.new("lexer grammar t;\n" + "A : (options {greedy=false;}:'0'..'9')+ ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4-'0'..'9'->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ":s7-<EOT>->.s8\n"
      check_rule(g, "A", expecting)
    end
    
    typesig { [] }
    def test_aor_bplus
      g = Grammar.new("parser grammar P;\n" + "a : (A | B{action})+ ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->.s11\n" + ".s11-B->.s12\n" + ".s12-{}->.s13\n" + ".s13->.s6\n" + ".s2->.s3\n" + ".s3->.s10\n" + ".s3->.s4\n" + ".s4-A->.s5\n" + ".s5->.s6\n" + ".s6->.s3\n" + ".s6->.s7\n" + ".s7->:s8\n" + ":s8-EOF->.s9\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_aor_bor_empty_plus
      g = Grammar.new("parser grammar P;\n" + "a : (A | B | )+ ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->.s11\n" + ".s10->.s13\n" + ".s11-B->.s12\n" + ".s12->.s6\n" + ".s13->.s14\n" + ".s14->.s15\n" + ".s15->.s6\n" + ".s2->.s3\n" + ".s3->.s10\n" + ".s3->.s4\n" + ".s4-A->.s5\n" + ".s5->.s6\n" + ".s6->.s3\n" + ".s6->.s7\n" + ".s7->:s8\n" + ":s8-EOF->.s9\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_astar
      g = Grammar.new("parser grammar P;\n" + "a : (A)*;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s9\n" + ".s3->.s4\n" + ".s4-A->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s6\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_nested_astar
      g = Grammar.new("parser grammar P;\n" + "a : (A*)*;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->:s11\n" + ".s13->.s8\n" + ".s14->.s10\n" + ".s2->.s14\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4->.s13\n" + ".s4->.s5\n" + ".s5->.s6\n" + ".s6-A->.s7\n" + ".s7->.s5\n" + ".s7->.s8\n" + ".s8->.s9\n" + ".s9->.s10\n" + ".s9->.s3\n" + ":s11-EOF->.s12\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_plus_nested_in_star
      g = Grammar.new("parser grammar P;\n" + "a : (A+)*;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->:s11\n" + ".s13->.s10\n" + ".s2->.s13\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4->.s5\n" + ".s5->.s6\n" + ".s6-A->.s7\n" + ".s7->.s5\n" + ".s7->.s8\n" + ".s8->.s9\n" + ".s9->.s10\n" + ".s9->.s3\n" + ":s11-EOF->.s12\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_star_nested_in_plus
      g = Grammar.new("parser grammar P;\n" + "a : (A*)+;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->:s11\n" + ".s13->.s8\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4->.s13\n" + ".s4->.s5\n" + ".s5->.s6\n" + ".s6-A->.s7\n" + ".s7->.s5\n" + ".s7->.s8\n" + ".s8->.s9\n" + ".s9->.s10\n" + ".s9->.s3\n" + ":s11-EOF->.s12\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_naked_astar
      g = Grammar.new("parser grammar P;\n" + "a : A*;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s9\n" + ".s3->.s4\n" + ".s4-A->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s6\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_aor_bstar
      g = Grammar.new("parser grammar P;\n" + "a : (A | B{action})* ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->.s11\n" + ".s11-B->.s12\n" + ".s12-{}->.s13\n" + ".s13->.s6\n" + ".s14->.s7\n" + ".s2->.s14\n" + ".s2->.s3\n" + ".s3->.s10\n" + ".s3->.s4\n" + ".s4-A->.s5\n" + ".s5->.s6\n" + ".s6->.s3\n" + ".s6->.s7\n" + ".s7->:s8\n" + ":s8-EOF->.s9\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_aor_boptional_subrule
      g = Grammar.new("parser grammar P;\n" + "a : ( A | B )? ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s8\n" + ".s3-A..B->.s4\n" + ".s4->.s5\n" + ".s5->:s6\n" + ".s8->.s5\n" + ":s6-EOF->.s7\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_predicated_aor_b
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? A | {p2}? B ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s1->.s8\n" + ".s10-B->.s11\n" + ".s11->.s5\n" + ".s2-{p1}?->.s3\n" + ".s3-A->.s4\n" + ".s4->.s5\n" + ".s5->:s6\n" + ".s8->.s9\n" + ".s9-{p2}?->.s10\n" + ":s6-EOF->.s7\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_multiple_predicates
      g = Grammar.new("parser grammar P;\n" + "a : {p1}? {p1a}? A | {p2}? B | {p3} b;\n" + "b : {p4}? B ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s1->.s9\n" + ".s10-{p2}?->.s11\n" + ".s11-B->.s12\n" + ".s12->.s6\n" + ".s13->.s14\n" + ".s14-{}->.s15\n" + ".s15->.s16\n" + ".s16->.s17\n" + ".s17->.s18\n" + ".s18-{p4}?->.s19\n" + ".s19-B->.s20\n" + ".s2-{p1}?->.s3\n" + ".s20->:s21\n" + ".s22->.s6\n" + ".s3-{p1a}?->.s4\n" + ".s4-A->.s5\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s10\n" + ".s9->.s13\n" + ":s21->.s22\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_sets
      g = Grammar.new("parser grammar P;\n" + "a : ( A | B )+ ;\n" + "b : ( A | B{;} )+ ;\n" + "c : (A|B) (A|B) ;\n" + "d : ( A | B )* ;\n" + "e : ( A | B )? ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4-A..B->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->.s11\n" + ".s11-B->.s12\n" + ".s12-{}->.s13\n" + ".s13->.s6\n" + ".s2->.s3\n" + ".s3->.s10\n" + ".s3->.s4\n" + ".s4-A->.s5\n" + ".s5->.s6\n" + ".s6->.s3\n" + ".s6->.s7\n" + ".s7->:s8\n" + ":s8-EOF->.s9\n"
      check_rule(g, "b", expecting)
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-A..B->.s3\n" + ".s3-A..B->.s4\n" + ".s4->:s5\n" + ":s5-EOF->.s6\n"
      check_rule(g, "c", expecting)
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s9\n" + ".s3->.s4\n" + ".s4-A..B->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s6\n" + ":s7-EOF->.s8\n"
      check_rule(g, "d", expecting)
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s8\n" + ".s3-A..B->.s4\n" + ".s4->.s5\n" + ".s5->:s6\n" + ".s8->.s5\n" + ":s6-EOF->.s7\n"
      check_rule(g, "e", expecting)
    end
    
    typesig { [] }
    def test_not_set
      g = Grammar.new("parser grammar P;\n" + "tokens { A; B; C; }\n" + "a : ~A ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-B..C->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
      expecting_grammar_str = "1:8: parser grammar P;\n" + "a : ~ A ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_not_singleton_block_set
      g = Grammar.new("parser grammar P;\n" + "tokens { A; B; C; }\n" + "a : ~(A) ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-B..C->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
      expecting_grammar_str = "1:8: parser grammar P;\n" + "a : ~ ( A ) ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_not_char_set
      g = Grammar.new("lexer grammar P;\n" + "A : ~'3' ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-{'\\u0000'..'2', '4'..'\\uFFFE'}->.s3\n" + ".s3->:s4\n" + ":s4-<EOT>->.s5\n"
      check_rule(g, "A", expecting)
      expecting_grammar_str = "1:7: lexer grammar P;\n" + "A : ~ '3' ;\n" + "Tokens : A ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_not_block_set
      g = Grammar.new("lexer grammar P;\n" + "A : ~('3'|'b') ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-{'\\u0000'..'2', '4'..'a', 'c'..'\\uFFFE'}->.s3\n" + ".s3->:s4\n" + ":s4-<EOT>->.s5\n"
      check_rule(g, "A", expecting)
      expecting_grammar_str = "1:7: lexer grammar P;\n" + "A : ~ ( '3' | 'b' ) ;\n" + "Tokens : A ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_not_set_loop
      g = Grammar.new("lexer grammar P;\n" + "A : ~('3')* ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s9\n" + ".s3->.s4\n" + ".s4-{'\\u0000'..'2', '4'..'\\uFFFE'}->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s6\n" + ":s7-<EOT>->.s8\n"
      check_rule(g, "A", expecting)
      expecting_grammar_str = "1:7: lexer grammar P;\n" + "A : (~ ( '3' ) )* ;\n" + "Tokens : A ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_not_block_set_loop
      g = Grammar.new("lexer grammar P;\n" + "A : ~('3'|'b')* ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s9\n" + ".s3->.s4\n" + ".s4-{'\\u0000'..'2', '4'..'a', 'c'..'\\uFFFE'}->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s6\n" + ":s7-<EOT>->.s8\n"
      check_rule(g, "A", expecting)
      expecting_grammar_str = "1:7: lexer grammar P;\n" + "A : (~ ( '3' | 'b' ) )* ;\n" + "Tokens : A ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_sets_in_combined_grammar_sent_to_lexer
      # not sure this belongs in this test suite, but whatever.
      g = Grammar.new("grammar t;\n" + "A : '{' ~('}')* '}';\n")
      result = g.get_lexer_grammar
      expecting = "lexer grammar t;\n" + "\n" + "// $ANTLR src \"<string>\" 2\n" + "A : '{' ~('}')* '}';\n"
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_labeled_not_set
      g = Grammar.new("parser grammar P;\n" + "tokens { A; B; C; }\n" + "a : t=~A ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-B..C->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
      expecting_grammar_str = "1:8: parser grammar P;\n" + "a : t=~ A ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_labeled_not_char_set
      g = Grammar.new("lexer grammar P;\n" + "A : t=~'3' ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-{'\\u0000'..'2', '4'..'\\uFFFE'}->.s3\n" + ".s3->:s4\n" + ":s4-<EOT>->.s5\n"
      check_rule(g, "A", expecting)
      expecting_grammar_str = "1:7: lexer grammar P;\n" + "A : t=~ '3' ;\n" + "Tokens : A ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_labeled_not_block_set
      g = Grammar.new("lexer grammar P;\n" + "A : t=~('3'|'b') ;\n")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-{'\\u0000'..'2', '4'..'a', 'c'..'\\uFFFE'}->.s3\n" + ".s3->:s4\n" + ":s4-<EOT>->.s5\n"
      check_rule(g, "A", expecting)
      expecting_grammar_str = "1:7: lexer grammar P;\n" + "A : t=~ ( '3' | 'b' ) ;\n" + "Tokens : A ;"
      assert_equals(expecting_grammar_str, g.to_s)
    end
    
    typesig { [] }
    def test_escaped_char_literal
      g = Grammar.new("grammar P;\n" + "a : '\\n';")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-'\\n'->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_escaped_string_literal
      g = Grammar.new("grammar P;\n" + "a : 'a\\nb\\u0030c\\'';")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-'a\\nb\\u0030c\\''->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    # AUTO BACKTRACKING STUFF
    def test_auto_backtracking_rule_block
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : 'a'{;}|'b';")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s1->.s9\n" + ".s10-'b'->.s11\n" + ".s11->.s6\n" + ".s2-{synpred1_t}?->.s3\n" + ".s3-'a'->.s4\n" + ".s4-{}->.s5\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s10\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_rule_set_block
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : 'a'|'b';")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-'a'..'b'->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_simple_block
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a'{;}|'b') ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->.s11\n" + ".s11-'b'->.s12\n" + ".s12->.s7\n" + ".s2->.s10\n" + ".s2->.s3\n" + ".s3-{synpred1_t}?->.s4\n" + ".s4-'a'->.s5\n" + ".s5-{}->.s6\n" + ".s6->.s7\n" + ".s7->:s8\n" + ":s8-EOF->.s9\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_set_block
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a'|'b') ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2-'a'..'b'->.s3\n" + ".s3->:s4\n" + ":s4-EOF->.s5\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_star_block
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a'{;}|'b')* ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s12->.s13\n" + ".s13-{synpred2_t}?->.s14\n" + ".s14-'b'->.s15\n" + ".s15->.s8\n" + ".s16->.s9\n" + ".s2->.s16\n" + ".s2->.s3\n" + ".s3->.s12\n" + ".s3->.s4\n" + ".s4-{synpred1_t}?->.s5\n" + ".s5-'a'->.s6\n" + ".s6-{}->.s7\n" + ".s7->.s8\n" + ".s8->.s3\n" + ".s8->.s9\n" + ".s9->:s10\n" + ":s10-EOF->.s11\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_star_set_block_ignores_preds
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a'|'b')* ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s9\n" + ".s3->.s4\n" + ".s4-'a'..'b'->.s5\n" + ".s5->.s3\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s6\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_star_set_block
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a'|'b'{;})* ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s11->.s12\n" + ".s12-{synpred2_t}?->.s13\n" + ".s13-'b'->.s14\n" + ".s14-{}->.s15\n" + ".s15->.s7\n" + ".s16->.s8\n" + ".s2->.s16\n" + ".s2->.s3\n" + ".s3->.s11\n" + ".s3->.s4\n" + ".s4-{synpred1_t}?->.s5\n" + ".s5-'a'->.s6\n" + ".s6->.s7\n" + ".s7->.s3\n" + ".s7->.s8\n" + ".s8->:s9\n" + ":s9-EOF->.s10\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_star_block1alt
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a')* ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->.s7\n" + ".s2->.s10\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4-{synpred1_t}?->.s5\n" + ".s5-'a'->.s6\n" + ".s6->.s3\n" + ".s6->.s7\n" + ".s7->:s8\n" + ":s8-EOF->.s9\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_plus_block
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a'{;}|'b')+ ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s12->.s13\n" + ".s13-{synpred2_t}?->.s14\n" + ".s14-'b'->.s15\n" + ".s15->.s8\n" + ".s2->.s3\n" + ".s3->.s12\n" + ".s3->.s4\n" + ".s4-{synpred1_t}?->.s5\n" + ".s5-'a'->.s6\n" + ".s6-{}->.s7\n" + ".s7->.s8\n" + ".s8->.s3\n" + ".s8->.s9\n" + ".s9->:s10\n" + ":s10-EOF->.s11\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_plus_set_block
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a'|'b'{;})+ ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s11->.s12\n" + ".s12-{synpred2_t}?->.s13\n" + ".s13-'b'->.s14\n" + ".s14-{}->.s15\n" + ".s15->.s7\n" + ".s2->.s3\n" + ".s3->.s11\n" + ".s3->.s4\n" + ".s4-{synpred1_t}?->.s5\n" + ".s5-'a'->.s6\n" + ".s6->.s7\n" + ".s7->.s3\n" + ".s7->.s8\n" + ".s8->:s9\n" + ":s9-EOF->.s10\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_plus_block1alt
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a')+ ;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s3->.s4\n" + ".s4-{synpred1_t}?->.s5\n" + ".s5-'a'->.s6\n" + ".s6->.s3\n" + ".s6->.s7\n" + ".s7->:s8\n" + ":s8-EOF->.s9\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_optional_block2alts
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a'{;}|'b')?;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s10->.s11\n" + ".s10->.s14\n" + ".s11-{synpred2_t}?->.s12\n" + ".s12-'b'->.s13\n" + ".s13->.s7\n" + ".s14->.s7\n" + ".s2->.s10\n" + ".s2->.s3\n" + ".s3-{synpred1_t}?->.s4\n" + ".s4-'a'->.s5\n" + ".s5-{}->.s6\n" + ".s6->.s7\n" + ".s7->:s8\n" + ":s8-EOF->.s9\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_optional_block1alt
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a')?;")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s2->.s3\n" + ".s2->.s9\n" + ".s3-{synpred1_t}?->.s4\n" + ".s4-'a'->.s5\n" + ".s5->.s6\n" + ".s6->:s7\n" + ".s9->.s6\n" + ":s7-EOF->.s8\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [] }
    def test_auto_backtracking_existing_pred
      g = Grammar.new("grammar t;\n" + "options {backtrack=true;}\n" + "a : ('a')=> 'a' | 'b';")
      expecting = ".s0->.s1\n" + ".s1->.s2\n" + ".s1->.s8\n" + ".s10->.s5\n" + ".s2-{synpred1_t}?->.s3\n" + ".s3-'a'->.s4\n" + ".s4->.s5\n" + ".s5->:s6\n" + ".s8->.s9\n" + ".s9-'b'->.s10\n" + ":s6-EOF->.s7\n"
      check_rule(g, "a", expecting)
    end
    
    typesig { [Grammar, String, String] }
    def check_rule(g, rule, expecting)
      g.build_nfa
      start_state = g.get_rule_start_state(rule)
      serializer = FASerializer.new(g)
      result = serializer.serialize(start_state)
      # System.out.print(result);
      assert_equals(expecting, result)
    end
    
    private
    alias_method :initialize__test_nfaconstruction, :initialize
  end
  
end
