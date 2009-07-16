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
  module TestTreeGrammarRewriteASTImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
    }
  end
  
  # Tree rewrites in tree parsers are basically identical to rewrites
  # in a normal grammar except that the atomic element is a node not
  # a Token.  Tests here ensure duplication of nodes occurs properly
  # and basic functionality.
  class TestTreeGrammarRewriteAST < TestTreeGrammarRewriteASTImports.const_get :BaseTest
    include_class_members TestTreeGrammarRewriteASTImports
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    typesig { [] }
    def test_flat_list
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ID INT -> INT ID\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("34 abc\n", found)
    end
    
    typesig { [] }
    def test_simple_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(ID INT) -> ^(INT ID)\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("(34 abc)\n", found)
    end
    
    typesig { [] }
    def test_non_imaginary_with_ctor
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # make new INT node
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : INT -> INT[\"99\"]\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "34")
      assert_equals("99\n", found)
    end
    
    typesig { [] }
    def test_combined_rewrite_and_auto
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT) | INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(ID INT) -> ^(INT ID) | INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("(34 abc)\n", found)
      found = (exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "34")).to_s
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    def test_avoid_dup
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ID -> ^(ID ID)\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc")
      assert_equals("(abc abc)\n", found)
    end
    
    typesig { [] }
    def test_loop
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID+ INT+ -> (^(ID INT))+ ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : (^(ID INT))+ -> INT+ ID+\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a b c 3 4 5")
      assert_equals("3 4 5 a b c\n", found)
    end
    
    typesig { [] }
    def test_auto_dup
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ID \n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc")
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_rule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : b c ;\n" + "b : ID ;\n" + "c : INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 1")
      assert_equals("a 1\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_multiple
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ID INT;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ID ID INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a b 3")
      assert_equals("a b 3\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(ID INT)\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 3")
      assert_equals("(a 3)\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_tree2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT INT -> ^(ID INT INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(ID b b)\n" + "  ;\n" + "b : INT ;"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 3 4")
      assert_equals("(a 3 4)\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_tree_with_labels
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(x=ID y=INT)\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 3")
      assert_equals("(a 3)\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_tree_with_list_labels
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(x+=ID y+=INT)\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 3")
      assert_equals("(a 3)\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_tree_with_rule_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(b INT) ;\n" + "b : ID ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 3")
      assert_equals("(a 3)\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_tree_with_rule_root_and_labels
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(x=b INT) ;\n" + "b : ID ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 3")
      assert_equals("(a 3)\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_tree_with_rule_root_and_list_labels
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(x+=b y+=c) ;\n" + "b : ID ;\n" + "c : INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 3")
      assert_equals("(a 3)\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_nested_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x=ID y=ID INT -> ^($x ^($y INT));\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(ID ^(ID INT))\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a b 3")
      assert_equals("(a (b 3))\n", found)
    end
    
    typesig { [] }
    def test_auto_dup_tree_with_subrule_inside
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {OP;}\n" + "a : (x=ID|x=INT) -> ^(OP $x) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(OP (b|c)) ;\n" + "b : ID ;\n" + "c : INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a")
      assert_equals("(OP a)\n", found)
    end
    
    typesig { [] }
    def test_delete
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ID -> \n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc")
      assert_equals("", found)
    end
    
    typesig { [] }
    def test_set_match_no_rewrite
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : b INT\n" + "  ;\n" + "b : ID | INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_set_optional_match_no_rewrite
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : (ID|INT)? INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_set_match_no_rewrite_level2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x=ID INT -> ^($x INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^(ID (ID | INT) ) ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("(abc 34)\n", found)
    end
    
    typesig { [] }
    def test_set_match_no_rewrite_level2root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x=ID INT -> ^($x INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "a : ^((ID | INT) INT) ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("(abc 34)\n", found)
    end
    
    typesig { [] }
    # REWRITE MODE
    def test_rewrite_mode_combined_rewrite_and_auto
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT) | INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # leaves it alone, returning $a.start
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "a : ^(ID INT) -> ^(ID[\"ick\"] INT)\n" + "  | INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("(ick 34)\n", found)
      found = (exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "34")).to_s
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    def test_rewrite_mode_flat_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ID INT | INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : ID a ;\n" + "a : INT -> INT[\"1\"]\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("abc 1\n", found)
    end
    
    typesig { [] }
    def test_rewrite_mode_chain_rule_flat_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ID INT | INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : a ;\n" + "a : b ;\n" + "b : ID INT -> INT ID\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("34 abc\n", found)
    end
    
    typesig { [] }
    def test_rewrite_mode_chain_rule_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # a.tree must become b.tree
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : a ;\n" + "a : b ;\n" + "b : ^(ID INT) -> INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    def test_rewrite_mode_chain_rule_tree2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # only b contributes to tree, but it's after a*; s.tree = b.tree
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "tokens { X; }\n" + "s : a* b ;\n" + "a : X ;\n" + "b : ^(ID INT) -> INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    def test_rewrite_mode_chain_rule_tree3
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'boo' ID INT -> 'boo' ^(ID INT) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # don't reset s.tree to b.tree due to 'boo'
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "tokens { X; }\n" + "s : 'boo' a* b ;\n" + "a : X ;\n" + "b : ^(ID INT) -> INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "boo abc 34")
      assert_equals("boo 34\n", found)
    end
    
    typesig { [] }
    def test_rewrite_mode_chain_rule_tree4
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'boo' ID INT -> ^('boo' ^(ID INT)) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # don't reset s.tree to b.tree due to 'boo'
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "tokens { X; }\n" + "s : ^('boo' a* b) ;\n" + "a : X ;\n" + "b : ^(ID INT) -> INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "boo abc 34")
      assert_equals("(boo 34)\n", found)
    end
    
    typesig { [] }
    def test_rewrite_mode_chain_rule_tree5
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'boo' ID INT -> ^('boo' ^(ID INT)) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # s.tree is a.tree
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "tokens { X; }\n" + "s : ^(a b) ;\n" + "a : 'boo' ;\n" + "b : ^(ID INT) -> INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "boo abc 34")
      assert_equals("(boo 34)\n", found)
    end
    
    typesig { [] }
    def test_rewrite_of_rule_ref
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ID INT | INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : a -> a ;\n" + "a : ID INT -> ID INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_rewrite_of_rule_ref_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT INT -> ^(INT ^(ID INT));\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : ^(a ^(ID INT)) -> a ;\n" + "a : INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 12 34")
      # emits whole tree when you ref the root since I can't know whether
      # you want the children or not.  You might be returning a whole new
      # tree.  Hmm...still seems weird.  oh well.
      assert_equals("(12 (abc 34))\n", found)
    end
    
    typesig { [] }
    def test_rewrite_of_rule_ref_root_labeled
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT INT -> ^(INT ^(ID INT));\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : ^(label=a ^(ID INT)) -> a ;\n" + "a : INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 12 34")
      # emits whole tree when you ref the root since I can't know whether
      # you want the children or not.  You might be returning a whole new
      # tree.  Hmm...still seems weird.  oh well.
      assert_equals("(12 (abc 34))\n", found)
    end
    
    typesig { [] }
    def test_rewrite_of_rule_ref_root_list_labeled
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT INT -> ^(INT ^(ID INT));\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : ^(label+=a ^(ID INT)) -> a ;\n" + "a : INT ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 12 34")
      # emits whole tree when you ref the root since I can't know whether
      # you want the children or not.  You might be returning a whole new
      # tree.  Hmm...still seems weird.  oh well.
      assert_equals("(12 (abc 34))\n", found)
    end
    
    typesig { [] }
    def test_rewrite_of_rule_ref_child
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID ^(INT INT));\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : ^(ID a) -> a ;\n" + "a : ^(INT INT) ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("(34 34)\n", found)
    end
    
    typesig { [] }
    def test_rewrite_of_rule_ref_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID ^(INT INT));\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : ^(ID label=a) -> a ;\n" + "a : ^(INT INT) ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("(34 34)\n", found)
    end
    
    typesig { [] }
    def test_rewrite_of_rule_ref_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID ^(INT INT));\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : ^(ID label+=a) -> a ;\n" + "a : ^(INT INT) ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("(34 34)\n", found)
    end
    
    typesig { [] }
    def test_rewrite_mode_with_predicated_rewrites
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID[\"root\"] ^(ID INT)) | INT -> ^(ID[\"root\"] INT) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T; rewrite=true;}\n" + "s : ^(ID a) {System.out.println(\"altered tree=\"+$s.start.toStringTree());};\n" + "a : ^(ID INT) -> {true}? ^(ID[\"ick\"] INT)\n" + "              -> INT\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("altered tree=(root (ick 34))\n" + "(root (ick 34))\n", found)
    end
    
    typesig { [] }
    def test_wildcard
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID[\"root\"] INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "s : ^(ID c=.) -> $c\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    def initialize
      @debug = false
      super()
      @debug = false
    end
    
    private
    alias_method :initialize__test_tree_grammar_rewrite_ast, :initialize
  end
  
end
