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
  module TestAutoASTImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
    }
  end
  
  class TestAutoAST < TestAutoASTImports.const_get :BaseTest
    include_class_members TestAutoASTImports
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    typesig { [] }
    def test_token_list
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc 34", @debug)
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_token_list_in_single_alt_block
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : (ID INT) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc 34", @debug)
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_simple_root_at_outer_level
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : ID^ INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc 34", @debug)
      assert_equals("(abc 34)\n", found)
    end
    
    typesig { [] }
    def test_simple_root_at_outer_level_reverse
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT ID^ ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "34 abc", @debug)
      assert_equals("(abc 34)\n", found)
    end
    
    typesig { [] }
    def test_bang
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT! ID! INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34 dag 4532", @debug)
      assert_equals("abc 4532\n", found)
    end
    
    typesig { [] }
    def test_optional_then_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ( ID INT )? ID^ ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 1 b", @debug)
      assert_equals("(b a 1)\n", found)
    end
    
    typesig { [] }
    def test_labeled_string_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : v='void'^ ID ';' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "void foo;", @debug)
      assert_equals("(void foo ;)\n", found)
    end
    
    typesig { [] }
    def test_wildcard
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : v='void'^ . ';' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "void foo;", @debug)
      assert_equals("(void foo ;)\n", found)
    end
    
    typesig { [] }
    def test_wildcard_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : v='void' .^ ';' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "void foo;", @debug)
      assert_equals("(foo void ;)\n", found)
    end
    
    typesig { [] }
    def test_wildcard_root_with_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : v='void' x=.^ ';' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "void foo;", @debug)
      assert_equals("(foo void ;)\n", found)
    end
    
    typesig { [] }
    def test_wildcard_root_with_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : v='void' x=.^ ';' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "void foo;", @debug)
      assert_equals("(foo void ;)\n", found)
    end
    
    typesig { [] }
    def test_root_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID^ INT^ ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 34 c", @debug)
      assert_equals("(34 a c)\n", found)
    end
    
    typesig { [] }
    def test_root_root2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT^ ID^ ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 34 c", @debug)
      assert_equals("(c (34 a))\n", found)
    end
    
    typesig { [] }
    def test_root_then_root_in_loop
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID^ (INT '*'^ ID)+ ;\n" + "ID  : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 34 * b 9 * c", @debug)
      assert_equals("(* (* (a 34) b 9) c)\n", found)
    end
    
    typesig { [] }
    def test_nested_subrule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'void' (({;}ID|INT) ID | 'null' ) ';' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "void a b;", @debug)
      assert_equals("void a b ;\n", found)
    end
    
    typesig { [] }
    def test_invoke_rule
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a  : type ID ;\n" + "type : {;}'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a", @debug)
      assert_equals("int a\n", found)
    end
    
    typesig { [] }
    def test_invoke_rule_as_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a  : type^ ID ;\n" + "type : {;}'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a", @debug)
      assert_equals("(int a)\n", found)
    end
    
    typesig { [] }
    def test_invoke_rule_as_root_with_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a  : x=type^ ID ;\n" + "type : {;}'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a", @debug)
      assert_equals("(int a)\n", found)
    end
    
    typesig { [] }
    def test_invoke_rule_as_root_with_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a  : x+=type^ ID ;\n" + "type : {;}'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a", @debug)
      assert_equals("(int a)\n", found)
    end
    
    typesig { [] }
    def test_rule_root_in_loop
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ('+'^ ID)* ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a+b+c+d", @debug)
      assert_equals("(+ (+ (+ a b) c) d)\n", found)
    end
    
    typesig { [] }
    def test_rule_invocation_rule_root_in_loop
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID (op^ ID)* ;\n" + "op : {;}'+' | '-' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a+b+c-d", @debug)
      assert_equals("(- (+ (+ a b) c) d)\n", found)
    end
    
    typesig { [] }
    def test_tail_recursion
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "s : a ;\n" + "a : atom ('exp'^ a)? ;\n" + "atom : INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "3 exp 4 exp 5", @debug)
      assert_equals("(exp 3 (exp 4 5))\n", found)
    end
    
    typesig { [] }
    def test_set
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID|INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc", @debug)
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_set_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ('+' | '-')^ ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "+abc", @debug)
      assert_equals("(+ abc)\n", found)
    end
    
    typesig { [] }
    def test_set_root_with_label
      # FAILS until I rebuild the antlr.g in v3
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x=('+' | '-')^ ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "+abc", @debug)
      assert_equals("(+ abc)\n", found)
    end
    
    typesig { [] }
    def test_set_as_rule_root_in_loop
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID (('+'|'-')^ ID)* ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a+b-c", @debug)
      assert_equals("(- (+ a b) c)\n", found)
    end
    
    typesig { [] }
    def test_not_set
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ~ID '+' INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "34+2", @debug)
      assert_equals("34 + 2\n", found)
    end
    
    typesig { [] }
    def test_not_set_with_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x=~ID '+' INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "34+2", @debug)
      assert_equals("34 + 2\n", found)
    end
    
    typesig { [] }
    def test_not_set_with_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x=~ID '+' INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "34+2", @debug)
      assert_equals("34 + 2\n", found)
    end
    
    typesig { [] }
    def test_not_set_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ~'+'^ INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "34 55", @debug)
      assert_equals("(34 55)\n", found)
    end
    
    typesig { [] }
    def test_not_set_root_with_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ~'+'^ INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "34 55", @debug)
      assert_equals("(34 55)\n", found)
    end
    
    typesig { [] }
    def test_not_set_root_with_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ~'+'^ INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "34 55", @debug)
      assert_equals("(34 55)\n", found)
    end
    
    typesig { [] }
    def test_not_set_rule_root_in_loop
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : INT (~INT^ INT)* ;\n" + "blort : '+' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "3+4+5", @debug)
      assert_equals("(+ (+ 3 4) 5)\n", found)
    end
    
    typesig { [] }
    def test_token_label_reuse
      # check for compilation problem due to multiple defines
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : id=ID id=ID {System.out.print(\"2nd id=\"+$id.text+';');} ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("2nd id=b;a b\n", found)
    end
    
    typesig { [] }
    def test_token_label_reuse2
      # check for compilation problem due to multiple defines
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : id=ID id=ID^ {System.out.print(\"2nd id=\"+$id.text+';');} ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("2nd id=b;(b a)\n", found)
    end
    
    typesig { [] }
    def test_token_list_label_reuse
      # check for compilation problem due to multiple defines
      # make sure ids has both ID tokens
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ids+=ID ids+=ID {System.out.print(\"id list=\"+$ids+';');} ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      expecting = "id list=[[@0,0:0='a',<4>,1:0], [@2,2:2='b',<4>,1:2]];a b\n"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_token_list_label_reuse2
      # check for compilation problem due to multiple defines
      # make sure ids has both ID tokens
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ids+=ID^ ids+=ID {System.out.print(\"id list=\"+$ids+';');} ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      expecting = "id list=[[@0,0:0='a',<4>,1:0], [@2,2:2='b',<4>,1:2]];(a b)\n"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_token_list_label_rule_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : id+=ID^ ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a\n", found)
    end
    
    typesig { [] }
    def test_token_list_label_bang
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : id+=ID! ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("", found)
    end
    
    typesig { [] }
    def test_rule_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x+=b x+=b {" + "Tree t=(Tree)$x.get(1);" + "System.out.print(\"2nd x=\"+t.toStringTree()+';');} ;\n" + "b : ID;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("2nd x=b;a b\n", found)
    end
    
    typesig { [] }
    def test_rule_list_label_rule_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ( x+=b^ )+ {" + "System.out.print(\"x=\"+((CommonTree)$x.get(1)).toStringTree()+';');} ;\n" + "b : ID;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("x=(b a);(b a)\n", found)
    end
    
    typesig { [] }
    def test_rule_list_label_bang
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x+=b! x+=b {" + "System.out.print(\"1st x=\"+((CommonTree)$x.get(0)).toStringTree()+';');} ;\n" + "b : ID;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b", @debug)
      assert_equals("1st x=a;b\n", found)
    end
    
    typesig { [] }
    def test_complicated_melange
      # check for compilation problem
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : A b=B b=B c+=C c+=C D {String s = $D.text;} ;\n" + "A : 'a' ;\n" + "B : 'b' ;\n" + "C : 'c' ;\n" + "D : 'd' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a b b c c d", @debug)
      assert_equals("a b b c c d\n", found)
    end
    
    typesig { [] }
    def test_return_value_with_ast
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : ID b {System.out.println($b.i);} ;\n" + "b returns [int i] : INT {$i=Integer.parseInt($INT.text);} ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc 34", @debug)
      assert_equals("34\nabc 34\n", found)
    end
    
    typesig { [] }
    def test_set_loop
      grammar = "grammar T;\n" + "options { output=AST; }\n" + "r : (INT|ID)+ ; \n" + "ID : 'a'..'z' + ;\n" + "INT : '0'..'9' +;\n" + "WS: (' ' | '\\n' | '\\t')+ {$channel = HIDDEN;};\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "r", "abc 34 d", @debug)
      assert_equals("abc 34 d\n", found)
    end
    
    typesig { [] }
    def test_extra_token_in_simple_decl
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "decl : type^ ID '='! INT ';'! ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "decl", "int 34 x=1;", @debug)
      assert_equals("line 1:4 extraneous input '34' expecting ID\n", self.attr_stderr)
      assert_equals("(int x 1)\n", found) # tree gets correct x and 1 tokens
    end
    
    typesig { [] }
    def test_missing_idin_simple_decl
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "tokens {EXPR;}\n" + "decl : type^ ID '='! INT ';'! ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "decl", "int =1;", @debug)
      assert_equals("line 1:4 missing ID at '='\n", self.attr_stderr)
      assert_equals("(int <missing ID> 1)\n", found) # tree gets invented ID token
    end
    
    typesig { [] }
    def test_missing_set_in_simple_decl
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "tokens {EXPR;}\n" + "decl : type^ ID '='! INT ';'! ;\n" + "type : 'int' | 'float' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "decl", "x=1;", @debug)
      assert_equals("line 1:0 mismatched input 'x' expecting set null\n", self.attr_stderr)
      assert_equals("(<error: x> x 1)\n", found) # tree gets invented ID token
    end
    
    typesig { [] }
    def test_missing_token_gives_error_node
      # follow is EOF
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc", @debug)
      assert_equals("line 0:-1 missing INT at '<EOF>'\n", self.attr_stderr)
      assert_equals("abc <missing INT>\n", found)
    end
    
    typesig { [] }
    def test_missing_token_gives_error_node_in_invoked_rule
      # follow should see EOF
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : b ;\n" + "b : ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc", @debug)
      assert_equals("line 0:-1 missing INT at '<EOF>'\n", self.attr_stderr)
      assert_equals("abc <missing INT>\n", found)
    end
    
    typesig { [] }
    def test_extra_token_gives_error_node
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : b c ;\n" + "b : ID ;\n" + "c : INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "abc ick 34", @debug)
      assert_equals("line 1:4 extraneous input 'ick' expecting INT\n", self.attr_stderr)
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_missing_first_token_gives_error_node
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : ID INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "34", @debug)
      assert_equals("line 1:0 missing ID at '34'\n", self.attr_stderr)
      assert_equals("<missing ID> 34\n", found)
    end
    
    typesig { [] }
    def test_missing_first_token_gives_error_node2
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : b c ;\n" + "b : ID ;\n" + "c : INT ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "34", @debug)
      # finds an error at the first token, 34, and re-syncs.
      # re-synchronizing does not consume a token because 34 follows
      # ref to rule b (start of c). It then matches 34 in c.
      assert_equals("line 1:0 missing ID at '34'\n", self.attr_stderr)
      assert_equals("<missing ID> 34\n", found)
    end
    
    typesig { [] }
    def test_no_viable_alt_gives_error_node
      grammar = "grammar foo;\n" + "options {output=AST;}\n" + "a : b | c ;\n" + "b : ID ;\n" + "c : INT ;\n" + "ID : 'a'..'z'+ ;\n" + "S : '*' ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("foo.g", grammar, "fooParser", "fooLexer", "a", "*", @debug)
      assert_equals("line 1:0 no viable alternative at input '*'\n", self.attr_stderr)
      assert_equals("<unexpected: [@0,0:0='*',<6>,1:0], resync=*>\n", found)
    end
    
    typesig { [] }
    # S U P P O R T
    def __test
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a :  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("\n", found)
    end
    
    typesig { [] }
    def initialize
      @debug = false
      super()
      @debug = false
    end
    
    private
    alias_method :initialize__test_auto_ast, :initialize
  end
  
end
