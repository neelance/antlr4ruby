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
  module TestSemanticPredicateEvaluationImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
    }
  end
  
  class TestSemanticPredicateEvaluation < TestSemanticPredicateEvaluationImports.const_get :BaseTest
    include_class_members TestSemanticPredicateEvaluationImports
    
    typesig { [] }
    def test_simple_cyclic_dfawith_predicate
      grammar = "grammar foo;\n" + "a : {false}? 'x'* 'y' {System.out.println(\"alt1\");}\n" + "  | {true}?  'x'* 'y' {System.out.println(\"alt2\");}\n" + "  ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "xxxy", false)
      assert_equals("alt2\n", found)
    end
    
    typesig { [] }
    def test_simple_cyclic_dfawith_instance_var_predicate
      grammar = "grammar foo;\n" + "@members {boolean v=true;}\n" + "a : {false}? 'x'* 'y' {System.out.println(\"alt1\");}\n" + "  | {v}?     'x'* 'y' {System.out.println(\"alt2\");}\n" + "  ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "xxxy", false)
      assert_equals("alt2\n", found)
    end
    
    typesig { [] }
    def test_predicate_validation
      grammar = "grammar foo;\n" + "@members {\n" + "public void reportError(RecognitionException e) {\n" + "    System.out.println(\"error: \"+e.toString());\n" + "}\n" + "}\n" + "\n" + "a : {false}? 'x'\n" + "  ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "x", false)
      assert_equals("error: FailedPredicateException(a,{false}?)\n", found)
    end
    
    typesig { [] }
    def test_lexer_preds
      grammar = "grammar foo;" + "@lexer::members {boolean p=false;}\n" + "a : (A|B)+ ;\n" + "A : {p}? 'a'  {System.out.println(\"token 1\");} ;\n" + "B : {!p}? 'a' {System.out.println(\"token 2\");} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "a", false)
      # "a" is ambig; can match both A, B.  Pred says match 2
      assert_equals("token 2\n", found)
    end
    
    typesig { [] }
    def test_lexer_preds2
      grammar = "grammar foo;" + "@lexer::members {boolean p=true;}\n" + "a : (A|B)+ ;\n" + "A : {p}? 'a' {System.out.println(\"token 1\");} ;\n" + "B : ('a'|'b')+ {System.out.println(\"token 2\");} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "a", false)
      # "a" is ambig; can match both A, B.  Pred says match 1
      assert_equals("token 1\n", found)
    end
    
    typesig { [] }
    def test_lexer_pred_in_exit_branch
      # p says it's ok to exit; it has precendence over the !p loopback branch
      grammar = "grammar foo;" + "@lexer::members {boolean p=true;}\n" + "a : (A|B)+ ;\n" + "A : ('a' {System.out.print(\"1\");})*\n" + "    {p}?\n" + "    ('a' {System.out.print(\"2\");})* ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aaa", false)
      assert_equals("222\n", found)
    end
    
    typesig { [] }
    def test_lexer_pred_in_exit_branch2
      grammar = "grammar foo;" + "@lexer::members {boolean p=true;}\n" + "a : (A|B)+ ;\n" + "A : ({p}? 'a' {System.out.print(\"1\");})*\n" + "    ('a' {System.out.print(\"2\");})* ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aaa", false)
      assert_equals("111\n", found)
    end
    
    typesig { [] }
    def test_lexer_pred_in_exit_branch3
      grammar = "grammar foo;" + "@lexer::members {boolean p=true;}\n" + "a : (A|B)+ ;\n" + "A : ({p}? 'a' {System.out.print(\"1\");} | )\n" + "    ('a' {System.out.print(\"2\");})* ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aaa", false)
      assert_equals("122\n", found)
    end
    
    typesig { [] }
    def test_lexer_pred_in_exit_branch4
      grammar = "grammar foo;" + "a : (A|B)+ ;\n" + "A @init {int n=0;} : ({n<2}? 'a' {System.out.print(n++);})+\n" + "    ('a' {System.out.print(\"x\");})* ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aaaaa", false)
      assert_equals("01xxx\n", found)
    end
    
    typesig { [] }
    def test_lexer_preds_in_cyclic_dfa
      grammar = "grammar foo;" + "@lexer::members {boolean p=false;}\n" + "a : (A|B)+ ;\n" + "A : {p}? ('a')+ 'x'  {System.out.println(\"token 1\");} ;\n" + "B :      ('a')+ 'x' {System.out.println(\"token 2\");} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aax", false)
      assert_equals("token 2\n", found)
    end
    
    typesig { [] }
    def test_lexer_preds_in_cyclic_dfa2
      grammar = "grammar foo;" + "@lexer::members {boolean p=false;}\n" + "a : (A|B)+ ;\n" + "A : {p}? ('a')+ 'x' ('y')? {System.out.println(\"token 1\");} ;\n" + "B :      ('a')+ 'x' {System.out.println(\"token 2\");} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aax", false)
      assert_equals("token 2\n", found)
    end
    
    typesig { [] }
    def test_gated_pred
      grammar = "grammar foo;" + "a : (A|B)+ ;\n" + "A : {true}?=> 'a' {System.out.println(\"token 1\");} ;\n" + "B : {false}?=>('a'|'b')+ {System.out.println(\"token 2\");} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aa", false)
      # "a" is ambig; can match both A, B.  Pred says match A twice
      assert_equals("token 1\ntoken 1\n", found)
    end
    
    typesig { [] }
    def test_gated_pred2
      grammar = "grammar foo;\n" + "@lexer::members {boolean sig=false;}\n" + "a : (A|B)+ ;\n" + "A : 'a' {System.out.print(\"A\"); sig=true;} ;\n" + "B : 'b' ;\n" + "C : {sig}?=> ('a'|'b') {System.out.print(\"C\");} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aa", false)
      assert_equals("AC\n", found)
    end
    
    typesig { [] }
    def test_pred_with_action_translation
      grammar = "grammar foo;\n" + "a : b[2] ;\n" + "b[int i]\n" + "  : {$i==1}?   'a' {System.out.println(\"alt 1\");}\n" + "  | {$b.i==2}? 'a' {System.out.println(\"alt 2\");}\n" + "  ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "aa", false)
      assert_equals("alt 2\n", found)
    end
    
    typesig { [] }
    def test_predicates_on_eottarget
      grammar = "grammar foo; \n" + "@lexer::members {boolean p=true, q=false;}" + "a : B ;\n" + "A: '</'; \n" + "B: {p}? '<!' {System.out.println(\"B\");};\n" + "C: {q}? '<' {System.out.println(\"C\");}; \n" + "D: '<';\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "<!", false)
      assert_equals("B\n", found)
    end
    
    typesig { [] }
    # S U P P O R T
    def __test
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a :  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {channel=99;} ;\n"
      found = exec_parser("t.g", grammar, "T", "TLexer", "a", "abc 34", false)
      assert_equals("\n", found)
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_semantic_predicate_evaluation, :initialize
  end
  
end
