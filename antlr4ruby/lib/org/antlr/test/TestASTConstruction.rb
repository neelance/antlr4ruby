require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
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
  module TestASTConstructionImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  class TestASTConstruction < TestASTConstructionImports.const_get :BaseTest
    include_class_members TestASTConstructionImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_a
      g = Grammar.new("parser grammar P;\n" + "a : A;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT A <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_nake_rule_plus_in_lexer
      g = Grammar.new("lexer grammar P;\n" + "A : B+;\n" + "B : 'a';")
      expecting = " ( rule A ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT B <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("A").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_rule_plus
      g = Grammar.new("parser grammar P;\n" + "a : (b)+;\n" + "b : B;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT b <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_naked_rule_plus
      g = Grammar.new("parser grammar P;\n" + "a : b+;\n" + "b : B;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT b <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_rule_optional
      g = Grammar.new("parser grammar P;\n" + "a : (b)?;\n" + "b : B;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( ? ( BLOCK ( ALT b <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_naked_rule_optional
      g = Grammar.new("parser grammar P;\n" + "a : b?;\n" + "b : B;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( ? ( BLOCK ( ALT b <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_rule_star
      g = Grammar.new("parser grammar P;\n" + "a : (b)*;\n" + "b : B;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT b <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_naked_rule_star
      g = Grammar.new("parser grammar P;\n" + "a : b*;\n" + "b : B;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT b <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_char_star
      g = Grammar.new("grammar P;\n" + "a : 'a'*;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT 'a' <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_char_star_in_lexer
      g = Grammar.new("lexer grammar P;\n" + "B : 'b'*;")
      expecting = " ( rule B ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT 'b' <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("B").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_string_star
      g = Grammar.new("grammar P;\n" + "a : 'while'*;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT 'while' <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_string_star_in_lexer
      g = Grammar.new("lexer grammar P;\n" + "B : 'while'*;")
      expecting = " ( rule B ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT 'while' <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("B").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_char_plus
      g = Grammar.new("grammar P;\n" + "a : 'a'+;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT 'a' <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_char_plus_in_lexer
      g = Grammar.new("lexer grammar P;\n" + "B : 'b'+;")
      expecting = " ( rule B ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT 'b' <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("B").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_char_optional
      g = Grammar.new("grammar P;\n" + "a : 'a'?;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( ? ( BLOCK ( ALT 'a' <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_char_optional_in_lexer
      g = Grammar.new("lexer grammar P;\n" + "B : 'b'?;")
      expecting = " ( rule B ARG RET scope ( BLOCK ( ALT ( ? ( BLOCK ( ALT 'b' <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("B").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_char_range_plus
      g = Grammar.new("lexer grammar P;\n" + "ID : 'a'..'z'+;")
      expecting = " ( rule ID ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT ( .. 'a' 'z' ) <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("ID").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_label
      g = Grammar.new("grammar P;\n" + "a : x=ID;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( = x ID ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_label_of_optional
      g = Grammar.new("grammar P;\n" + "a : x=ID?;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( ? ( BLOCK ( ALT ( = x ID ) <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_label_of_closure
      g = Grammar.new("grammar P;\n" + "a : x=ID*;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT ( = x ID ) <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_rule_label
      g = Grammar.new("grammar P;\n" + "a : x=b;\n" + "b : ID;\n")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( = x b ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_set_label
      g = Grammar.new("grammar P;\n" + "a : x=(A|B);\n")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( = x ( BLOCK ( ALT A <end-of-alt> ) ( ALT B <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_not_set_label
      g = Grammar.new("grammar P;\n" + "a : x=~(A|B);\n")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( = x ( ~ ( BLOCK ( ALT A <end-of-alt> ) ( ALT B <end-of-alt> ) <end-of-block> ) ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_not_set_list_label
      g = Grammar.new("grammar P;\n" + "a : x+=~(A|B);\n")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( += x ( ~ ( BLOCK ( ALT A <end-of-alt> ) ( ALT B <end-of-alt> ) <end-of-block> ) ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_not_set_list_label_in_loop
      g = Grammar.new("grammar P;\n" + "a : x+=~(A|B)+;\n")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT ( += x ( ~ ( BLOCK ( ALT A <end-of-alt> ) ( ALT B <end-of-alt> ) <end-of-block> ) ) ) <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_rule_label_of_positive_closure
      g = Grammar.new("grammar P;\n" + "a : x=b+;\n" + "b : ID;\n")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT ( = x b ) <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_list_label_of_closure
      g = Grammar.new("grammar P;\n" + "a : x+=ID*;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT ( += x ID ) <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_list_label_of_closure2
      g = Grammar.new("grammar P;\n" + "a : x+='int'*;")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( * ( BLOCK ( ALT ( += x 'int' ) <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_rule_list_label_of_positive_closure
      g = Grammar.new("grammar P;\n" + "options {output=AST;}\n" + "a : x+=b+;\n" + "b : ID;\n")
      expecting = " ( rule a ARG RET scope ( BLOCK ( ALT ( + ( BLOCK ( ALT ( += x b ) <end-of-alt> ) <end-of-block> ) ) <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("a").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_root_token_in_star_loop
      g = Grammar.new("grammar Expr;\n" + "options { backtrack=true; }\n" + "a : ('*'^)* ;\n") # bug: the synpred had nothing in it
      expecting = " ( rule synpred1_Expr ARG RET scope ( BLOCK ( ALT '*' <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("synpred1_Expr").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_action_in_star_loop
      g = Grammar.new("grammar Expr;\n" + "options { backtrack=true; }\n" + "a : ({blort} 'x')* ;\n") # bug: the synpred had nothing in it
      expecting = " ( rule synpred1_Expr ARG RET scope ( BLOCK ( ALT blort 'x' <end-of-alt> ) <end-of-block> ) <end-of-rule> )"
      found = g.get_rule("synpred1_Expr").attr_tree.to_string_tree
      assert_equals(expecting, found)
    end
    
    private
    alias_method :initialize__test_astconstruction, :initialize
  end
  
end
