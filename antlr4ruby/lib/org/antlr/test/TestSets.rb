require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2008 Terence Parr
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
  module TestSetsImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
    }
  end
  
  # Test the set stuff in lexer and parser
  class TestSets < TestSetsImports.const_get :BaseTest
    include_class_members TestSetsImports
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      @debug = false
      super()
      @debug = false
    end
    
    typesig { [] }
    def test_seq_does_not_become_set
      # this must return A not I to the parser; calling a nonfragment rule
      # from a nonfragment rule does not set the overall token.
      grammar = "grammar P;\n" + "a : C {System.out.println(input);} ;\n" + "fragment A : '1' | '2';\n" + "fragment B : '3' '4';\n" + "C : A | B;\n"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "34", @debug)
      assert_equals("34\n", found)
    end
    
    typesig { [] }
    def test_parser_set
      grammar = "grammar T;\n" + "a : t=('x'|'y') {System.out.println($t.text);} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", @debug)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_parser_not_set
      grammar = "grammar T;\n" + "a : t=~('x'|'y') 'z' {System.out.println($t.text);} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "zz", @debug)
      assert_equals("z\n", found)
    end
    
    typesig { [] }
    def test_parser_not_token
      grammar = "grammar T;\n" + "a : ~'x' 'z' {System.out.println(input);} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "zz", @debug)
      assert_equals("zz\n", found)
    end
    
    typesig { [] }
    def test_parser_not_token_with_label
      grammar = "grammar T;\n" + "a : t=~'x' 'z' {System.out.println($t.text);} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "zz", @debug)
      assert_equals("z\n", found)
    end
    
    typesig { [] }
    def test_rule_as_set
      grammar = "grammar T;\n" + "a @after {System.out.println(input);} : 'a' | 'b' |'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "b", @debug)
      assert_equals("b\n", found)
    end
    
    typesig { [] }
    def test_rule_as_set_ast
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : 'a' | 'b' |'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "b", @debug)
      assert_equals("b\n", found)
    end
    
    typesig { [] }
    def test_not_char
      grammar = "grammar T;\n" + "a : A {System.out.println($A.text);} ;\n" + "A : ~'b' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", @debug)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_optional_single_element
      grammar = "grammar T;\n" + "a : A? 'c' {System.out.println(input);} ;\n" + "A : 'b' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "bc", @debug)
      assert_equals("bc\n", found)
    end
    
    typesig { [] }
    def test_optional_lexer_single_element
      grammar = "grammar T;\n" + "a : A {System.out.println(input);} ;\n" + "A : 'b'? 'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "bc", @debug)
      assert_equals("bc\n", found)
    end
    
    typesig { [] }
    def test_star_lexer_single_element
      grammar = "grammar T;\n" + "a : A {System.out.println(input);} ;\n" + "A : 'b'* 'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "bbbbc", @debug)
      assert_equals("bbbbc\n", found)
      found = (exec_parser("T.g", grammar, "TParser", "TLexer", "a", "c", @debug)).to_s
      assert_equals("c\n", found)
    end
    
    typesig { [] }
    def test_plus_lexer_single_element
      grammar = "grammar T;\n" + "a : A {System.out.println(input);} ;\n" + "A : 'b'+ 'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "bbbbc", @debug)
      assert_equals("bbbbc\n", found)
    end
    
    typesig { [] }
    def test_optional_set
      grammar = "grammar T;\n" + "a : ('a'|'b')? 'c' {System.out.println(input);} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "ac", @debug)
      assert_equals("ac\n", found)
    end
    
    typesig { [] }
    def test_star_set
      grammar = "grammar T;\n" + "a : ('a'|'b')* 'c' {System.out.println(input);} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abaac", @debug)
      assert_equals("abaac\n", found)
    end
    
    typesig { [] }
    def test_plus_set
      grammar = "grammar T;\n" + "a : ('a'|'b')+ 'c' {System.out.println(input);} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abaac", @debug)
      assert_equals("abaac\n", found)
    end
    
    typesig { [] }
    def test_lexer_optional_set
      grammar = "grammar T;\n" + "a : A {System.out.println(input);} ;\n" + "A : ('a'|'b')? 'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "ac", @debug)
      assert_equals("ac\n", found)
    end
    
    typesig { [] }
    def test_lexer_star_set
      grammar = "grammar T;\n" + "a : A {System.out.println(input);} ;\n" + "A : ('a'|'b')* 'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abaac", @debug)
      assert_equals("abaac\n", found)
    end
    
    typesig { [] }
    def test_lexer_plus_set
      grammar = "grammar T;\n" + "a : A {System.out.println(input);} ;\n" + "A : ('a'|'b')+ 'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abaac", @debug)
      assert_equals("abaac\n", found)
    end
    
    typesig { [] }
    def test_not_char_set
      grammar = "grammar T;\n" + "a : A {System.out.println($A.text);} ;\n" + "A : ~('b'|'c') ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", @debug)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_not_char_set_with_label
      # This doesn't work in lexer yet.
      # Generates: h=input.LA(1); but h is defined as a Token
      grammar = "grammar T;\n" + "a : A {System.out.println($A.text);} ;\n" + "A : h=~('b'|'c') ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", @debug)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_not_char_set_with_rule_ref
      grammar = "grammar T;\n" + "a : A {System.out.println($A.text);} ;\n" + "A : ~('a'|B) ;\n" + "B : 'b' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", @debug)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_not_char_set_with_rule_ref2
      grammar = "grammar T;\n" + "a : A {System.out.println($A.text);} ;\n" + "A : ~('a'|B) ;\n" + "B : 'b'|'c' ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", @debug)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_not_char_set_with_rule_ref3
      grammar = "grammar T;\n" + "a : A {System.out.println($A.text);} ;\n" + "A : ('a'|B) ;\n" + "fragment\n" + "B : ~('a'|'c') ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", @debug)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_not_char_set_with_rule_ref4
      grammar = "grammar T;\n" + "a : A {System.out.println($A.text);} ;\n" + "A : ('a'|B) ;\n" + "fragment\n" + "B : ~('a'|C) ;\n" + "fragment\n" + "C : 'c'|'d' ;\n "
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", @debug)
      assert_equals("x\n", found)
    end
    
    private
    alias_method :initialize__test_sets, :initialize
  end
  
end
