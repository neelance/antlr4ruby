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
  module TestSyntacticPredicateEvaluationImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
    }
  end
  
  class TestSyntacticPredicateEvaluation < TestSyntacticPredicateEvaluationImports.const_get :BaseTest
    include_class_members TestSyntacticPredicateEvaluationImports
    
    typesig { [] }
    def test_two_preds_with_naked_alt
      grammar = "grammar T;\n" + "s : (a ';')+ ;\n" + "a\n" + "options {\n" + "  k=1;\n" + "}\n" + "  : (b '.')=> b '.' {System.out.println(\"alt 1\");}\n" + "  | (b)=> b {System.out.println(\"alt 2\");}\n" + "  | c       {System.out.println(\"alt 3\");}\n" + "  ;\n" + "b\n" + "@init {System.out.println(\"enter b\");}\n" + "   : '(' 'x' ')' ;\n" + "c\n" + "@init {System.out.println(\"enter c\");}\n" + "   : '(' c ')' | 'x' ;\n" + "WS : (' '|'\\n')+ {$channel=HIDDEN;}\n" + "   ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "(x) ;", false)
      expecting = "enter b\n" + "enter b\n" + "enter b\n" + "alt 2\n"
      assert_equals(expecting, found)
      found = (exec_parser("T.g", grammar, "TParser", "TLexer", "a", "(x). ;", false)).to_s
      expecting = "enter b\n" + "enter b\n" + "alt 1\n"
      assert_equals(expecting, found)
      found = (exec_parser("T.g", grammar, "TParser", "TLexer", "a", "((x)) ;", false)).to_s
      expecting = "enter b\n" + "enter b\n" + "enter c\n" + "enter c\n" + "enter c\n" + "alt 3\n"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_two_preds_with_naked_alt_not_last
      grammar = "grammar T;\n" + "s : (a ';')+ ;\n" + "a\n" + "options {\n" + "  k=1;\n" + "}\n" + "  : (b '.')=> b '.' {System.out.println(\"alt 1\");}\n" + "  | c       {System.out.println(\"alt 2\");}\n" + "  | (b)=> b {System.out.println(\"alt 3\");}\n" + "  ;\n" + "b\n" + "@init {System.out.println(\"enter b\");}\n" + "   : '(' 'x' ')' ;\n" + "c\n" + "@init {System.out.println(\"enter c\");}\n" + "   : '(' c ')' | 'x' ;\n" + "WS : (' '|'\\n')+ {$channel=HIDDEN;}\n" + "   ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "(x) ;", false)
      expecting = "enter b\n" + "enter c\n" + "enter c\n" + "alt 2\n"
      assert_equals(expecting, found)
      found = (exec_parser("T.g", grammar, "TParser", "TLexer", "a", "(x). ;", false)).to_s
      expecting = "enter b\n" + "enter b\n" + "alt 1\n"
      assert_equals(expecting, found)
      found = (exec_parser("T.g", grammar, "TParser", "TLexer", "a", "((x)) ;", false)).to_s
      expecting = "enter b\n" + "enter c\n" + "enter c\n" + "enter c\n" + "alt 2\n"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def tes_tlexer_pred
      # force backtracking
      grammar = "grammar T;\n" + "s : A ;\n" + "A options {k=1;}\n" + "  : (B '.')=>B '.' {System.out.println(\"alt1\");}\n" + "  | B {System.out.println(\"alt2\");}" + "  ;\n" + "fragment\n" + "B : 'x'+ ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "xxx", false)
      assert_equals("alt2\n", found)
      found = (exec_parser("T.g", grammar, "TParser", "TLexer", "s", "xxx.", false)).to_s
      assert_equals("alt1\n", found)
    end
    
    typesig { [] }
    def tes_tlexer_with_pred_longer_than_alt
      # force backtracking
      grammar = "grammar T;\n" + "s : A ;\n" + "A options {k=1;}\n" + "  : (B '.')=>B {System.out.println(\"alt1\");}\n" + "  | B {System.out.println(\"alt2\");}" + "  ;\n" + "D : '.' {System.out.println(\"D\");} ;\n" + "fragment\n" + "B : 'x'+ ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "xxx", false)
      assert_equals("alt2\n", found)
      found = (exec_parser("T.g", grammar, "TParser", "TLexer", "s", "xxx.", false)).to_s
      assert_equals("alt1\nD\n", found)
    end
    
    typesig { [] }
    def tes_tlexer_pred_cyclic_prediction
      grammar = "grammar T;\n" + "s : A ;\n" + "A : (B)=>(B|'y'+) {System.out.println(\"alt1\");}\n" + "  | B {System.out.println(\"alt2\");}\n" + "  | 'y'+ ';'" + "  ;\n" + "fragment\n" + "B : 'x'+ ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "xxx", false)
      assert_equals("alt1\n", found)
    end
    
    typesig { [] }
    def tes_tlexer_pred_cyclic_prediction2
      grammar = "grammar T;\n" + "s : A ;\n" + "A : (B '.')=>(B|'y'+) {System.out.println(\"alt1\");}\n" + "  | B {System.out.println(\"alt2\");}\n" + "  | 'y'+ ';'" + "  ;\n" + "fragment\n" + "B : 'x'+ ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "xxx", false)
      assert_equals("alt2\n", found)
    end
    
    typesig { [] }
    def test_simple_nested_pred
      grammar = "grammar T;\n" + "s : (expr ';')+ ;\n" + "expr\n" + "options {\n" + "  k=1;\n" + "}\n" + "@init {System.out.println(\"enter expr \"+input.LT(1).getText());}\n" + "  : (atom 'x') => atom 'x'\n" + "  | atom\n" + ";\n" + "atom\n" + "@init {System.out.println(\"enter atom \"+input.LT(1).getText());}\n" + "   : '(' expr ')'\n" + "   | INT\n" + "   ;\n" + "INT: '0'..'9'+ ;\n" + "WS : (' '|'\\n')+ {$channel=HIDDEN;}\n" + "   ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "(34)x;", false)
      expecting = "enter expr (\n" + "enter atom (\n" + "enter expr 34\n" + "enter atom 34\n" + "enter atom 34\n" + "enter atom (\n" + "enter expr 34\n" + "enter atom 34\n" + "enter atom 34\n"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_triple_nested_pred_in_lexer
      grammar = "grammar T;\n" + "s : (.)+ {System.out.println(\"done\");} ;\n" + "EXPR\n" + "options {\n" + "  k=1;\n" + "}\n" + "@init {System.out.println(\"enter expr \"+(char)input.LT(1));}\n" + "  : (ATOM 'x') => ATOM 'x' {System.out.println(\"ATOM x\");}\n" + "  | ATOM {System.out.println(\"ATOM \"+$ATOM.text);}\n" + ";\n" + "fragment ATOM\n" + "@init {System.out.println(\"enter atom \"+(char)input.LT(1));}\n" + "   : '(' EXPR ')'\n" + "   | INT\n" + "   ;\n" + "fragment INT: '0'..'9'+ ;\n" + "fragment WS : (' '|'\\n')+ \n" + "   ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "((34)x)x", false)
      # has no memoization
      expecting = "enter expr (\n" + "enter atom (\n" + "enter expr (\n" + "enter atom (\n" + "enter expr 3\n" + "enter atom 3\n" + "enter atom 3\n" + "enter atom (\n" + "enter expr 3\n" + "enter atom 3\n" + "enter atom 3\n" + "enter atom (\n" + "enter expr (\n" + "enter atom (\n" + "enter expr 3\n" + "enter atom 3\n" + "enter atom 3\n" + "enter atom (\n" + "enter expr 3\n" + "enter atom 3\n" + "enter atom 3\n" + "ATOM 34\n" + "ATOM x\n" + "ATOM x\n" + "done\n"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_tree_parser_with_syn_pred
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT+ (PERIOD|SEMI);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "SEMI : ';' ;\n" + "PERIOD : '.' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {k=1; backtrack=true; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ID INT+ PERIOD {System.out.print(\"alt 1\");}" + "  | ID INT+ SEMI   {System.out.print(\"alt 2\");}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 1 2 3;")
      assert_equals("alt 2\n", found)
    end
    
    typesig { [] }
    def test_tree_parser_with_nested_syn_pred
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT+ (PERIOD|SEMI);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "SEMI : ';' ;\n" + "PERIOD : '.' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # backtracks in a and b due to k=1
      # choose this alt for just one INT
      tree_grammar = "tree grammar TP;\n" + "options {k=1; backtrack=true; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ID b {System.out.print(\" a:alt 1\");}" + "  | ID INT+ SEMI   {System.out.print(\" a:alt 2\");}\n" + "  ;\n" + "b : INT PERIOD  {System.out.print(\"b:alt 1\");}" + "  | INT+ PERIOD {System.out.print(\"b:alt 2\");}" + "  ;"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 1 2 3.")
      assert_equals("b:alt 2 a:alt 1\n", found)
    end
    
    typesig { [] }
    def test_syn_pred_with_output_template
      # really just seeing if it will compile
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a\n" + "options {\n" + "  k=1;\n" + "}\n" + "  : ('x'+ 'y')=> 'x'+ 'y' -> template(a={$text}) <<1:<a>;>>\n" + "  | 'x'+ 'z' -> template(a={$text}) <<2:<a>;>>\n" + "  ;\n" + "WS : (' '|'\\n')+ {$channel=HIDDEN;}\n" + "   ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "xxxy", false)
      assert_equals("1:xxxy;\n", found)
    end
    
    typesig { [] }
    def test_syn_pred_with_output_ast
      # really just seeing if it will compile
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a\n" + "options {\n" + "  k=1;\n" + "}\n" + "  : ('x'+ 'y')=> 'x'+ 'y'\n" + "  | 'x'+ 'z'\n" + "  ;\n" + "WS : (' '|'\\n')+ {$channel=HIDDEN;}\n" + "   ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "xxxy", false)
      assert_equals("x x x y\n", found)
    end
    
    typesig { [] }
    def test_optional_block_with_syn_pred
      grammar = "grammar T;\n" + "\n" + "a : ( (b)=> b {System.out.println(\"b\");})? b ;\n" + "b : 'x' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "xx", false)
      assert_equals("b\n", found)
      found = (exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", false)).to_s
      assert_equals("", found)
    end
    
    typesig { [] }
    def test_syn_pred_k2
      # all manually specified syn predicates are gated (i.e., forced
      # to execute).
      grammar = "grammar T;\n" + "\n" + "a : (b)=> b {System.out.println(\"alt1\");} | 'a' 'c' ;\n" + "b : 'a' 'b' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "ab", false)
      assert_equals("alt1\n", found)
    end
    
    typesig { [] }
    def test_syn_pred_kstar
      grammar = "grammar T;\n" + "\n" + "a : (b)=> b {System.out.println(\"alt1\");} | 'a'+ 'c' ;\n" + "b : 'a'+ 'b' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "aaab", false)
      assert_equals("alt1\n", found)
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_syntactic_predicate_evaluation, :initialize
  end
  
end
