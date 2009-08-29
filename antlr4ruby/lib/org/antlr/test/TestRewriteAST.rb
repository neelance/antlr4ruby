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
  module TestRewriteASTImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Tool, :ErrorManager
      include_const ::Org::Antlr::Tool, :GrammarSemanticsMessage
      include_const ::Org::Antlr::Tool, :Message
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Codegen, :CodeGenerator
    }
  end
  
  class TestRewriteAST < TestRewriteASTImports.const_get :BaseTest
    include_class_members TestRewriteASTImports
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    typesig { [] }
    def test_delete
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("", found)
    end
    
    typesig { [] }
    def test_single_token
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID -> ID;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_single_token_to_new_node
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID -> ID[\"x\"];\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_single_token_to_new_node_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID -> ^(ID[\"x\"] INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("(x INT)\n", found)
    end
    
    typesig { [] }
    def test_single_token_to_new_node2
      # Allow creation of new nodes w/o args.
      grammar = "grammar TT;\n" + "options {output=AST;}\n" + "a : ID -> ID[ ];\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("TT.g", grammar, "TTParser", "TTLexer", "a", "abc", @debug)
      assert_equals("ID\n", found)
    end
    
    typesig { [] }
    def test_single_char_literal
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'c' -> 'c';\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "c", @debug)
      assert_equals("c\n", found)
    end
    
    typesig { [] }
    def test_single_string_literal
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'ick' -> 'ick';\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "ick", @debug)
      assert_equals("ick\n", found)
    end
    
    typesig { [] }
    def test_single_rule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : b -> b;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_reorder_tokens
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> INT ID;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("34 abc\n", found)
    end
    
    typesig { [] }
    def test_reorder_token_and_rule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : b INT -> INT b;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("34 abc\n", found)
    end
    
    typesig { [] }
    def test_token_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(INT ID);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("(34 abc)\n", found)
    end
    
    typesig { [] }
    def test_token_tree_after_other_stuff
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'void' ID INT -> 'void' ^(INT ID);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "void abc 34", @debug)
      assert_equals("void (34 abc)\n", found)
    end
    
    typesig { [] }
    def test_nested_token_tree_with_outer_loop
      # verify that ID and INT both iterate over outer index variable
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {DUH;}\n" + "a : ID INT ID INT -> ^( DUH ID ^( DUH INT) )+ ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 1 b 2", @debug)
      assert_equals("(DUH a (DUH 1)) (DUH b (DUH 2))\n", found)
    end
    
    typesig { [] }
    def test_optional_single_token
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID -> ID? ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_closure_single_token
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ID -> ID* ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_positive_closure_single_token
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ID -> ID+ ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_optional_single_rule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : b -> b?;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_closure_single_rule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : b b -> b*;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_closure_of_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x+=b x+=b -> $x*;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_optional_label_no_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : (x=ID)? -> $x?;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a\n", found)
    end
    
    typesig { [] }
    def test_positive_closure_single_rule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : b b -> b+;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_single_predicate_t
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID -> {true}? ID -> ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_single_predicate_f
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID -> {false}? ID -> ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("", found)
    end
    
    typesig { [] }
    def test_multiple_predicate
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> {false}? ID\n" + "           -> {true}? INT\n" + "           -> \n" + "  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 2", @debug)
      assert_equals("2\n", found)
    end
    
    typesig { [] }
    def test_multiple_predicate_trees
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> {false}? ^(ID INT)\n" + "           -> {true}? ^(INT ID)\n" + "           -> ID\n" + "  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 2", @debug)
      assert_equals("(2 a)\n", found)
    end
    
    typesig { [] }
    def test_simple_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : op INT -> ^(op INT);\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "-34", @debug)
      assert_equals("(- 34)\n", found)
    end
    
    typesig { [] }
    def test_simple_tree2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : op INT -> ^(INT op);\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "+ 34", @debug)
      assert_equals("(34 +)\n", found)
    end
    
    typesig { [] }
    def test_nested_trees
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'var' (ID ':' type ';')+ -> ^('var' ^(':' ID type)+) ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "var a:int; b:float;", @debug)
      assert_equals("(var (: a int) (: b float))\n", found)
    end
    
    typesig { [] }
    def test_imaginary_token_copy
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {VAR;}\n" + "a : ID (',' ID)*-> ^(VAR ID)+ ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a,b,c", @debug)
      assert_equals("(VAR a) (VAR b) (VAR c)\n", found)
    end
    
    typesig { [] }
    def test_token_unreferenced_on_left_but_defined
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {VAR;}\n" + "a : b -> ID ;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("ID\n", found)
    end
    
    typesig { [] }
    def test_imaginary_token_copy_set_text
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {VAR;}\n" + "a : ID (',' ID)*-> ^(VAR[\"var\"] ID)+ ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a,b,c", @debug)
      assert_equals("(var a) (var b) (var c)\n", found)
    end
    
    typesig { [] }
    def test_imaginary_token_no_copy_from_token
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : lc='{' ID+ '}' -> ^(BLOCK[$lc] ID+) ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "{a b c}", @debug)
      assert_equals("({ a b c)\n", found)
    end
    
    typesig { [] }
    def test_imaginary_token_no_copy_from_token_set_text
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : lc='{' ID+ '}' -> ^(BLOCK[$lc,\"block\"] ID+) ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "{a b c}", @debug)
      assert_equals("(block a b c)\n", found)
    end
    
    typesig { [] }
    def test_mixed_rewrite_and_auto_ast
      # 2nd b matches only an INT; can make it root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : b b^ ;\n" + "b : ID INT -> INT ID\n" + "  | INT\n" + "  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 1 2", @debug)
      assert_equals("(2 1 a)\n", found)
    end
    
    typesig { [] }
    def test_subrule_with_rewrite
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : b b ;\n" + "b : (ID INT -> INT ID | INT INT -> INT+ )\n" + "  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 1 2 3", @debug)
      assert_equals("1 a 2 3\n", found)
    end
    
    typesig { [] }
    def test_subrule_with_rewrite2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {TYPE;}\n" + "a : b b ;\n" + "b : 'int'\n" + "    ( ID -> ^(TYPE 'int' ID)\n" + "    | ID '=' INT -> ^(TYPE 'int' ID INT)\n" + "    )\n" + "    ';'\n" + "  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a; int b=3;", @debug)
      assert_equals("(TYPE int a) (TYPE int b 3)\n", found)
    end
    
    typesig { [] }
    def test_nested_rewrite_shuts_off_auto_ast
      # get last ID
      # should still get auto AST construction
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : b b ;\n" + "b : ID ( ID (last=ID -> $last)+ ) ';'\n" + "  | INT\n" + "  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b c d; 42", @debug)
      assert_equals("d 42\n", found)
    end
    
    typesig { [] }
    def test_rewrite_actions
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : atom -> ^({adaptor.create(INT,\"9\")} atom) ;\n" + "atom : INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "3", @debug)
      assert_equals("(9 3)\n", found)
    end
    
    typesig { [] }
    def test_rewrite_actions2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : atom -> {adaptor.create(INT,\"9\")} atom ;\n" + "atom : INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "3", @debug)
      assert_equals("9 3\n", found)
    end
    
    typesig { [] }
    def test_ref_to_old_value
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : (atom -> atom) (op='+' r=atom -> ^($op $a $r) )* ;\n" + "atom : INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "3+4+5", @debug)
      assert_equals("(+ (+ 3 4) 5)\n", found)
    end
    
    typesig { [] }
    def test_copy_semantics_for_rules
      # NOT CYCLE! (dup atom)
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : atom -> ^(atom atom) ;\n" + "atom : INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "3", @debug)
      assert_equals("(3 3)\n", found)
    end
    
    typesig { [] }
    def test_copy_semantics_for_rules2
      # copy type as a root for each invocation of (...)+ in rewrite
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : type ID (',' ID)* ';' -> ^(type ID)+ ;\n" + "type : 'int' ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a,b,c;", @debug)
      assert_equals("(int a) (int b) (int c)\n", found)
    end
    
    typesig { [] }
    def test_copy_semantics_for_rules3
      # copy type *and* modifier even though it's optional
      # for each invocation of (...)+ in rewrite
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : modifier? type ID (',' ID)* ';' -> ^(type modifier? ID)+ ;\n" + "type : 'int' ;\n" + "modifier : 'public' ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "public int a,b,c;", @debug)
      assert_equals("(int public a) (int public b) (int public c)\n", found)
    end
    
    typesig { [] }
    def test_copy_semantics_for_rules3double
      # copy type *and* modifier even though it's optional
      # for each invocation of (...)+ in rewrite
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : modifier? type ID (',' ID)* ';' -> ^(type modifier? ID)+ ^(type modifier? ID)+ ;\n" + "type : 'int' ;\n" + "modifier : 'public' ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "public int a,b,c;", @debug)
      assert_equals("(int public a) (int public b) (int public c) (int public a) (int public b) (int public c)\n", found)
    end
    
    typesig { [] }
    def test_copy_semantics_for_rules4
      # copy type *and* modifier even though it's optional
      # for each invocation of (...)+ in rewrite
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {MOD;}\n" + "a : modifier? type ID (',' ID)* ';' -> ^(type ^(MOD modifier)? ID)+ ;\n" + "type : 'int' ;\n" + "modifier : 'public' ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "public int a,b,c;", @debug)
      assert_equals("(int (MOD public) a) (int (MOD public) b) (int (MOD public) c)\n", found)
    end
    
    typesig { [] }
    def test_copy_semantics_lists
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {MOD;}\n" + "a : ID (',' ID)* ';' -> ID+ ID+ ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a,b,c;", @debug)
      assert_equals("a b c a b c\n", found)
    end
    
    typesig { [] }
    def test_copy_rule_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x=b -> $x $x;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a a\n", found)
    end
    
    typesig { [] }
    def test_copy_rule_label2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x=b -> ^($x $x);\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("(a a)\n", found)
    end
    
    typesig { [] }
    def test_queueing_of_tokens
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'int' ID (',' ID)* ';' -> ^('int' ID+) ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a,b,c;", @debug)
      assert_equals("(int a b c)\n", found)
    end
    
    typesig { [] }
    def test_copy_of_tokens
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'int' ID ';' -> 'int' ID 'int' ID ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a;", @debug)
      assert_equals("int a int a\n", found)
    end
    
    typesig { [] }
    def test_token_copy_in_loop
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'int' ID (',' ID)* ';' -> ^('int' ID)+ ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a,b,c;", @debug)
      assert_equals("(int a) (int b) (int c)\n", found)
    end
    
    typesig { [] }
    def test_token_copy_in_loop_against_two_others
      # must smear 'int' copies across as root of multiple trees
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'int' ID ':' INT (',' ID ':' INT)* ';' -> ^('int' ID INT)+ ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a:1,b:2,c:3;", @debug)
      assert_equals("(int a 1) (int b 2) (int c 3)\n", found)
    end
    
    typesig { [] }
    def test_list_refd_one_at_atime
      # works if 3 input IDs
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID+ -> ID ID ID ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b c", @debug)
      assert_equals("a b c\n", found)
    end
    
    typesig { [] }
    def test_split_list_with_labels
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {VAR;}\n" + "a : first=ID others+=ID* -> $first VAR $others+ ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b c", @debug)
      assert_equals("a VAR b c\n", found)
    end
    
    typesig { [] }
    def test_complicated_melange
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : A A b=B B b=B c+=C C c+=C D {String s=$D.text;} -> A+ B+ C+ D ;\n" + "type : 'int' | 'float' ;\n" + "A : 'a' ;\n" + "B : 'b' ;\n" + "C : 'c' ;\n" + "D : 'd' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a a b b b c c c d", @debug)
      assert_equals("a a b b b c c c d\n", found)
    end
    
    typesig { [] }
    def test_rule_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x=b -> $x;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a\n", found)
    end
    
    typesig { [] }
    def test_ambiguous_rule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID a -> a | INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT: '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    def test_weird_rule_ref
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID a -> $a | INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT: '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      g = Grammar.new(grammar)
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      # $a is ambig; is it previous root or ref to a ref in alt?
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 1, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x+=b x+=b -> $x+;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_rule_list_label2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x+=b x+=b -> $x $x*;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_optional
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x=b (y=b)? -> $x $y?;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a\n", found)
    end
    
    typesig { [] }
    def test_optional2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x=ID (y=b)? -> $x $y?;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_optional3
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x=ID (y=b)? -> ($x $y)?;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_optional4
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x+=ID (y=b)? -> ($x $y)?;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("a b\n", found)
    end
    
    typesig { [] }
    def test_optional5
      # match an ID to optional ID
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : ID -> ID? ;\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a\n", found)
    end
    
    typesig { [] }
    def test_arbitrary_expr_type
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : x+=b x+=b -> {new CommonTree()};\n" + "b : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("", found)
    end
    
    typesig { [] }
    def test_set
      grammar = "grammar T;\n" + "options { output = AST; } \n" + "a: (INT|ID)+ -> INT+ ID+ ;\n" + "INT: '0'..'9'+;\n" + "ID : 'a'..'z'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "2 a 34 de", @debug)
      assert_equals("2 34 a de\n", found)
    end
    
    typesig { [] }
    def test_set2
      grammar = "grammar T;\n" + "options { output = AST; } \n" + "a: (INT|ID) -> INT? ID? ;\n" + "INT: '0'..'9'+;\n" + "ID : 'a'..'z'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "2", @debug)
      assert_equals("2\n", found)
    end
    
    typesig { [] }
    def test_set_with_label
      # FAILS. The should probably generate a warning from antlr
      # See http://www.antlr.org:8888/browse/ANTLR-162
      grammar = "grammar T;\n" + "options { output = AST; } \n" + "a : x=(INT|ID) -> $x ;\n" + "INT: '0'..'9'+;\n" + "ID : 'a'..'z'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "2", @debug)
      assert_equals("2\n", found)
    end
    
    typesig { [] }
    def test_rewrite_action
      grammar = "grammar T; \n" + "options { output = AST; }\n" + "tokens { FLOAT; }\n" + "r\n" + "    : INT -> {new CommonTree(new CommonToken(FLOAT,$INT.text+\".0\"))} \n" + "    ; \n" + "INT : '0'..'9'+; \n" + "WS: (' ' | '\\n' | '\\t')+ {$channel = HIDDEN;}; \n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "r", "25", @debug)
      assert_equals("25.0\n", found)
    end
    
    typesig { [] }
    def test_optional_subrule_without_real_elements
      # copy type *and* modifier even though it's optional
      # for each invocation of (...)+ in rewrite
      grammar = "grammar T;\n" + "options {output=AST;} \n" + "tokens {PARMS;} \n" + "\n" + "modulo \n" + " : 'modulo' ID ('(' parms+ ')')? -> ^('modulo' ID ^(PARMS parms+)?) \n" + " ; \n" + "parms : '#'|ID; \n" + "ID : ('a'..'z' | 'A'..'Z')+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "modulo", "modulo abc (x y #)", @debug)
      assert_equals("(modulo abc (PARMS x y #))\n", found)
    end
    
    typesig { [] }
    # C A R D I N A L I T Y  I S S U E S
    def test_cardinality
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {BLOCK;}\n" + "a : ID ID INT INT INT -> (ID INT)+;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+; \n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b 3 4 5", @debug)
      expecting = "org.antlr.runtime.tree.RewriteCardinalityException: token ID"
      found = get_first_line_of_exception
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_cardinality2
      # only 2 input IDs
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID+ -> ID ID ID ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      expecting = "org.antlr.runtime.tree.RewriteCardinalityException: token ID"
      found = get_first_line_of_exception
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_cardinality3
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID? INT -> ID INT ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      exec_parser("T.g", grammar, "TParser", "TLexer", "a", "3", @debug)
      expecting = "org.antlr.runtime.tree.RewriteEmptyStreamException: token ID"
      found = get_first_line_of_exception
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_loop_cardinality
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID? INT -> ID+ INT ;\n" + "op : '+'|'-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      exec_parser("T.g", grammar, "TParser", "TLexer", "a", "3", @debug)
      expecting = "org.antlr.runtime.tree.RewriteEarlyExitException"
      found = get_first_line_of_exception
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_wildcard
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID c=. -> $c;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    # E R R O R S
    def test_unknown_rule
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT -> ugh ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      g = Grammar.new(grammar)
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_UNDEFINED_RULE_REF
      expected_arg = "ugh"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_known_rule_but_not_in_lhs
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT -> b ;\n" + "b : 'b' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      g = Grammar.new(grammar)
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_REWRITE_ELEMENT_NOT_PRESENT_ON_LHS
      expected_arg = "b"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_unknown_token
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT -> ICK ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      g = Grammar.new(grammar)
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_UNDEFINED_TOKEN_REF_IN_REWRITE
      expected_arg = "ICK"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_unknown_label
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT -> $foo ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      g = Grammar.new(grammar)
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_UNDEFINED_LABEL_REF_IN_REWRITE
      expected_arg = "foo"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_unknown_char_literal_token
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT -> 'a' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      g = Grammar.new(grammar)
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_UNDEFINED_TOKEN_REF_IN_REWRITE
      expected_arg = "'a'"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_unknown_string_literal_token
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT -> 'foo' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      g = Grammar.new(grammar)
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_UNDEFINED_TOKEN_REF_IN_REWRITE
      expected_arg = "'foo'"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_extra_token_in_simple_decl
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "tokens {EXPR;}\n" + "decl : type ID '=' INT ';' -> ^(EXPR type ID INT) ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "decl", "int 34 x=1;", @debug)
      assert_equals("line 1:4 extraneous input '34' expecting ID\n", self.attr_stderr)
      assert_equals("(EXPR int x 1)\n", found) # tree gets correct x and 1 tokens
    end
    
    typesig { [] }
    def test_missing_idin_simple_decl
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "tokens {EXPR;}\n" + "decl : type ID '=' INT ';' -> ^(EXPR type ID INT) ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "decl", "int =1;", @debug)
      assert_equals("line 1:4 missing ID at '='\n", self.attr_stderr)
      assert_equals("(EXPR int <missing ID> 1)\n", found) # tree gets invented ID token
    end
    
    typesig { [] }
    def test_missing_set_in_simple_decl
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "tokens {EXPR;}\n" + "decl : type ID '=' INT ';' -> ^(EXPR type ID INT) ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "decl", "x=1;", @debug)
      assert_equals("line 1:0 mismatched input 'x' expecting set null\n", self.attr_stderr)
      assert_equals("(EXPR <error: x> x 1)\n", found) # tree gets invented ID token
    end
    
    typesig { [] }
    def test_missing_token_gives_error_node
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : ID INT -> ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc", @debug)
      assert_equals("line 0:-1 missing INT at '<EOF>'\n", self.attr_stderr)
      # doesn't do in-line recovery for sets (yet?)
      assert_equals("abc <missing INT>\n", found)
    end
    
    typesig { [] }
    def test_extra_token_gives_error_node
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : b c -> b c;\n" + "b : ID -> ID ;\n" + "c : INT -> INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc ick 34", @debug)
      assert_equals("line 1:4 extraneous input 'ick' expecting INT\n", self.attr_stderr)
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_missing_first_token_gives_error_node
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : ID INT -> ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "34", @debug)
      assert_equals("line 1:0 missing ID at '34'\n", self.attr_stderr)
      assert_equals("<missing ID> 34\n", found)
    end
    
    typesig { [] }
    def test_missing_first_token_gives_error_node2
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : b c -> b c;\n" + "b : ID -> ID ;\n" + "c : INT -> INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "34", @debug)
      # finds an error at the first token, 34, and re-syncs.
      # re-synchronizing does not consume a token because 34 follows
      # ref to rule b (start of c). It then matches 34 in c.
      assert_equals("line 1:0 missing ID at '34'\n", self.attr_stderr)
      assert_equals("<missing ID> 34\n", found)
    end
    
    typesig { [] }
    def test_no_viable_alt_gives_error_node
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : b -> b | c -> c;\n" + "b : ID -> ID ;\n" + "c : INT -> INT ;\n" + "ID : 'a'..'z'+ ;\n" + "S : '*' ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "*", @debug)
      # finds an error at the first token, 34, and re-syncs.
      # re-synchronizing does not consume a token because 34 follows
      # ref to rule b (start of c). It then matches 34 in c.
      assert_equals("line 1:0 no viable alternative at input '*'\n", self.attr_stderr)
      assert_equals("<unexpected: [@0,0:0='*',<6>,1:0], resync=*>\n", found)
    end
    
    typesig { [ErrorQueue, GrammarSemanticsMessage] }
    # S U P P O R T
    def check_error(equeue, expected_message)
      # System.out.println("errors="+equeue);
      found_msg = nil
      i = 0
      while i < equeue.attr_errors.size
        m = equeue.attr_errors.get(i)
        if ((m.attr_msg_id).equal?(expected_message.attr_msg_id))
          found_msg = m
        end
        i += 1
      end
      assert_true("no error; " + RJava.cast_to_string(expected_message.attr_msg_id) + " expected", equeue.attr_errors.size > 0)
      assert_true("too many errors; " + RJava.cast_to_string(equeue.attr_errors), equeue.attr_errors.size <= 1)
      assert_not_null("couldn't find expected error: " + RJava.cast_to_string(expected_message.attr_msg_id), found_msg)
      assert_true("error is not a GrammarSemanticsMessage", found_msg.is_a?(GrammarSemanticsMessage))
      assert_equals(expected_message.attr_arg, found_msg.attr_arg)
      assert_equals(expected_message.attr_arg2, found_msg.attr_arg2)
      ErrorManager.reset_error_state # wack errors for next test
    end
    
    typesig { [] }
    def initialize
      @debug = false
      super()
      @debug = false
    end
    
    private
    alias_method :initialize__test_rewrite_ast, :initialize
  end
  
end
