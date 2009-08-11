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
  module TestTreeParsingImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
    }
  end
  
  class TestTreeParsing < TestTreeParsingImports.const_get :BaseTest
    include_class_members TestTreeParsingImports
    
    typesig { [] }
    def test_flat_list
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a : ID INT\n" + "    {System.out.println($ID+\", \"+$INT);}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("abc, 34\n", found)
    end
    
    typesig { [] }
    def test_simple_tree
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT -> ^(ID INT);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a : ^(ID INT)\n" + "    {System.out.println($ID+\", \"+$INT);}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc 34")
      assert_equals("abc, 34\n", found)
    end
    
    typesig { [] }
    def test_flat_vs_tree_decision
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : b c ;\n" + "b : ID INT -> ^(ID INT);\n" + "c : ID INT;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a : b b ;\n" + "b : ID INT    {System.out.print($ID+\" \"+$INT);}\n" + "  | ^(ID INT) {System.out.print(\"^(\"+$ID+\" \"+$INT+')');}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 1 b 2")
      assert_equals("^(a 1)b 2\n", found)
    end
    
    typesig { [] }
    def test_flat_vs_tree_decision2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : b c ;\n" + "b : ID INT+ -> ^(ID INT+);\n" + "c : ID INT+;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a : b b ;\n" + "b : ID INT+    {System.out.print($ID+\" \"+$INT);}\n" + "  | ^(x=ID (y=INT)+) {System.out.print(\"^(\"+$x+' '+$y+')');}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 1 2 3 b 4 5")
      assert_equals("^(a 3)b 5\n", found)
    end
    
    typesig { [] }
    def test_cyclic_dfalookahead
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT+ PERIOD;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "SEMI : ';' ;\n" + "PERIOD : '.' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a : ID INT+ PERIOD {System.out.print(\"alt 1\");}" + "  | ID INT+ SEMI   {System.out.print(\"alt 2\");}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "a 1 2 3.")
      assert_equals("alt 1\n", found)
    end
    
    typesig { [] }
    def test_template_output
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {output=template; ASTLabelType=CommonTree;}\n" + "s : a {System.out.println($a.st);};\n" + "a : ID INT -> {new StringTemplate($INT.text)}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc 34")
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    def test_nullable_child_list
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT? -> ^(ID INT?);\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a : ^(ID INT?)\n" + "    {System.out.println($ID);}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc")
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_nullable_child_list2
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID INT? SEMI -> ^(ID INT?) SEMI ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "SEMI : ';' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a : ^(ID INT?) SEMI\n" + "    {System.out.println($ID);}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc;")
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_nullable_child_list3
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x=ID INT? (y=ID)? SEMI -> ^($x INT? $y?) SEMI ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "SEMI : ';' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a : ^(ID INT? b) SEMI\n" + "    {System.out.println($ID+\", \"+$b.text);}\n" + "  ;\n" + "b : ID? ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc def;")
      assert_equals("abc, def\n", found)
    end
    
    typesig { [] }
    def test_actions_after_root
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : x=ID INT? SEMI -> ^($x INT?) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "SEMI : ';' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP; options {ASTLabelType=CommonTree;}\n" + "a @init {int x=0;} : ^(ID {x=1;} {x=2;} INT?)\n" + "    {System.out.println($ID+\", \"+x);}\n" + "  ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "a", "abc;")
      assert_equals("abc, 2\n", found)
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_tree_parsing, :initialize
  end
  
end
