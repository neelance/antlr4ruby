require "rjava"

# 
# [The "BSD licence"]
# Copyright (c) 2005-2007 Terence Parr
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
  module TestHeteroASTImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
    }
  end
  
  # Test hetero trees in parsers and tree parsers
  class TestHeteroAST < TestHeteroASTImports.const_get :BaseTest
    include_class_members TestHeteroASTImports
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    typesig { [] }
    # PARSERS -- AUTO AST
    def test_token
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : ID<V> ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a<V>\n", found)
    end
    
    typesig { [] }
    def test_token_with_qualified_type
      # TParser.V is qualified name
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : ID<TParser.V> ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a<V>\n", found)
    end
    
    typesig { [] }
    def test_token_with_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : x=ID<V> ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a<V>\n", found)
    end
    
    typesig { [] }
    def test_token_with_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : x+=ID<V> ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a<V>\n", found)
    end
    
    typesig { [] }
    def test_token_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : ID<V>^ ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a<V>\n", found)
    end
    
    typesig { [] }
    def test_token_root_with_list_label
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : x+=ID<V>^ ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a<V>\n", found)
    end
    
    typesig { [] }
    def test_string
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : 'begin'<V> ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "begin", @debug)
      assert_equals("begin<V>\n", found)
    end
    
    typesig { [] }
    def test_string_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : 'begin'<V>^ ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "begin", @debug)
      assert_equals("begin<V>\n", found)
    end
    
    typesig { [] }
    # PARSERS -- REWRITE AST
    def test_rewrite_token
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : ID -> ID<V> ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a<V>\n", found)
    end
    
    typesig { [] }
    def test_rewrite_token_with_args
      # arg to ID<V>[42,19,30] means you're constructing node not associated with ID
      # so must pass in token manually
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {\n" + "static class V extends CommonTree {\n" + "  public int x,y,z;\n" + "  public V(int ttype, int x, int y, int z) { this.x=x; this.y=y; this.z=z; token=new CommonToken(ttype,\"\"); }\n" + "  public V(int ttype, Token t, int x) { token=t; this.x=x;}\n" + "  public String toString() { return (token!=null?token.getText():\"\")+\"<V>;\"+x+y+z;}\n" + "}\n" + "}\n" + "a : ID -> ID<V>[42,19,30] ID<V>[$ID,99] ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("<V>;421930 a<V>;9900\n", found)
    end
    
    typesig { [] }
    def test_rewrite_token_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : ID INT -> ^(ID<V> INT) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a 2", @debug)
      assert_equals("(a<V> 2)\n", found)
    end
    
    typesig { [] }
    def test_rewrite_string
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : 'begin' -> 'begin'<V> ;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "begin", @debug)
      assert_equals("begin<V>\n", found)
    end
    
    typesig { [] }
    def test_rewrite_string_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : 'begin' INT -> ^('begin'<V> INT) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "begin 2", @debug)
      assert_equals("(begin<V> 2)\n", found)
    end
    
    typesig { [] }
    def test_rewrite_rule_results
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "tokens {LIST;}\n" + "@members {\n" + "static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "static class W extends CommonTree {\n" + "  public W(int tokenType, String txt) { super(new CommonToken(tokenType,txt)); }\n" + "  public W(Token t) { token=t;}\n" + "  public String toString() { return token.getText()+\"<W>\";}\n" + "}\n" + "}\n" + "a : id (',' id)* -> ^(LIST<W>[\"LIST\"] id+);\n" + "id : ID -> ID<V>;\n" + "ID : 'a'..'z'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a,b,c", @debug)
      assert_equals("(LIST<W> a<V> b<V> c<V>)\n", found)
    end
    
    typesig { [] }
    def test_copy_semantics_with_hetero
      # for 'int'<V>
      # for dupNode
      # for dup'ing type
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "@members {\n" + "static class V extends CommonTree {\n" + "  public V(Token t) { token=t;}\n" + "  public V(V node) { super(node); }\n\n" + "  public Tree dupNode() { return new V(this); }\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "}\n" + "a : type ID (',' ID)* ';' -> ^(type ID)+;\n" + "type : 'int'<V> ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "int a, b, c;", @debug)
      assert_equals("(int<V> a) (int<V> b) (int<V> c)\n", found)
    end
    
    typesig { [] }
    # TREE PARSERS -- REWRITE AST
    def test_tree_parser_rewrite_flat_list
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "@members {\n" + "static class V extends CommonTree {\n" + "  public V(Object t) { super((CommonTree)t); }\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "static class W extends CommonTree {\n" + "  public W(Object t) { super((CommonTree)t); }\n" + "  public String toString() { return token.getText()+\"<W>\";}\n" + "}\n" + "}\n" + "a : ID INT -> INT<V> ID<W>\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("34<V> abc<W>\n", found)
    end
    
    typesig { [] }
    def test_tree_parser_rewrite_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "@members {\n" + "static class V extends CommonTree {\n" + "  public V(Object t) { super((CommonTree)t); }\n" + "  public String toString() { return token.getText()+\"<V>\";}\n" + "}\n" + "static class W extends CommonTree {\n" + "  public W(Object t) { super((CommonTree)t); }\n" + "  public String toString() { return token.getText()+\"<W>\";}\n" + "}\n" + "}\n" + "a : ID INT -> ^(INT<V> ID<W>)\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("(34<V> abc<W>)\n", found)
    end
    
    typesig { [] }
    def test_tree_parser_rewrite_imaginary
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "tokens { ROOT; }\n" + "@members {\n" + "class V extends CommonTree {\n" + "  public V(int tokenType) { super(new CommonToken(tokenType)); }\n" + "  public String toString() { return tokenNames[token.getType()]+\"<V>\";}\n" + "}\n" + "}\n" + "a : ID -> ROOT<V> ID\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc")
      assert_equals("ROOT<V> abc\n", found)
    end
    
    typesig { [] }
    def test_tree_parser_rewrite_imaginary_with_args
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "tokens { ROOT; }\n" + "@members {\n" + "class V extends CommonTree {\n" + "  public int x;\n" + "  public V(int tokenType, int x) { super(new CommonToken(tokenType)); this.x=x;}\n" + "  public String toString() { return tokenNames[token.getType()]+\"<V>;\"+x;}\n" + "}\n" + "}\n" + "a : ID -> ROOT<V>[42] ID\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc")
      assert_equals("ROOT<V>;42 abc\n", found)
    end
    
    typesig { [] }
    def test_tree_parser_rewrite_imaginary_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "tokens { ROOT; }\n" + "@members {\n" + "class V extends CommonTree {\n" + "  public V(int tokenType) { super(new CommonToken(tokenType)); }\n" + "  public String toString() { return tokenNames[token.getType()]+\"<V>\";}\n" + "}\n" + "}\n" + "a : ID -> ^(ROOT<V> ID)\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc")
      assert_equals("(ROOT<V> abc)\n", found)
    end
    
    typesig { [] }
    def test_tree_parser_rewrite_imaginary_from_real
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "tokens { ROOT; }\n" + "@members {\n" + "class V extends CommonTree {\n" + "  public V(int tokenType) { super(new CommonToken(tokenType)); }\n" + "  public V(int tokenType, Object tree) { super((CommonTree)tree); token.setType(tokenType); }\n" + "  public String toString() { return tokenNames[token.getType()]+\"<V>@\"+token.getLine();}\n" + "}\n" + "}\n" + "a : ID -> ROOT<V>[$ID]\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc")
      assert_equals("ROOT<V>@1\n", found) # at line 1; shows copy of ID's stuff
    end
    
    typesig { [] }
    def test_tree_parser_auto_hetero_ast
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ';' ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      # NEEDS SPECIAL CTOR
      tree_grammar = "tree grammar TP;\n" + "options {output=AST; ASTLabelType=CommonTree; tokenVocab=T;}\n" + "tokens { ROOT; }\n" + "@members {\n" + "class V extends CommonTree {\n" + "  public V(CommonTree t) { super(t); }\n" + "  public String toString() { return super.toString()+\"<V>\";}\n" + "}\n" + "}\n" + "a : ID<V> ';'<V>\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc;")
      assert_equals("abc<V> ;<V>\n", found)
    end
    
    typesig { [] }
    def initialize
      @debug = false
      super()
      @debug = false
    end
    
    private
    alias_method :initialize__test_hetero_ast, :initialize
  end
  
end
