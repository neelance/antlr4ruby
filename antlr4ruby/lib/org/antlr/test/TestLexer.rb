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
  module TestLexerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
    }
  end
  
  class TestLexer < TestLexerImports.const_get :BaseTest
    include_class_members TestLexerImports
    
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
    def test_set_text
      # this must return A not I to the parser; calling a nonfragment rule
      # from a nonfragment rule does not set the overall token.
      grammar = "grammar P;\n" + "a : A {System.out.println(input);} ;\n" + "A : '\\\\' 't' {setText(\"\t\");} ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "\\t", @debug)
      assert_equals("\t\n", found)
    end
    
    typesig { [] }
    def test_ref_to_rule_does_not_set_token_nor_emit_another
      # this must return A not I to the parser; calling a nonfragment rule
      # from a nonfragment rule does not set the overall token.
      grammar = "grammar P;\n" + "a : A EOF {System.out.println(input);} ;\n" + "A : '-' I ;\n" + "I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "-34", @debug)
      assert_equals("-34\n", found)
    end
    
    typesig { [] }
    def test_ref_to_rule_does_not_set_channel
      # this must set channel of A to HIDDEN.  $channel is local to rule
      # like $type.
      grammar = "grammar P;\n" + "a : A EOF {System.out.println($A.text+\", channel=\"+$A.channel);} ;\n" + "A : '-' WS I ;\n" + "I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "- 34", @debug)
      assert_equals("- 34, channel=0\n", found)
    end
    
    typesig { [] }
    def test_we_can_set_type
      grammar = "grammar P;\n" + "tokens {X;}\n" + "a : X EOF {System.out.println(input);} ;\n" + "A : '-' I {$type = X;} ;\n" + "I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "-34", @debug)
      assert_equals("-34\n", found)
    end
    
    typesig { [] }
    def test_ref_to_fragment
      # this must return A not I to the parser; calling a nonfragment rule
      # from a nonfragment rule does not set the overall token.
      grammar = "grammar P;\n" + "a : A {System.out.println(input);} ;\n" + "A : '-' I ;\n" + "fragment I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "-34", @debug)
      assert_equals("-34\n", found)
    end
    
    typesig { [] }
    def test_multiple_ref_to_fragment
      # this must return A not I to the parser; calling a nonfragment rule
      # from a nonfragment rule does not set the overall token.
      grammar = "grammar P;\n" + "a : A EOF {System.out.println(input);} ;\n" + "A : I '.' I ;\n" + "fragment I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "3.14159", @debug)
      assert_equals("3.14159\n", found)
    end
    
    typesig { [] }
    def test_label_in_subrule
      # can we see v outside?
      grammar = "grammar P;\n" + "a : A EOF ;\n" + "A : 'hi' WS (v=I)? {$channel=0; System.out.println($v.text);} ;\n" + "fragment I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "hi 342", @debug)
      assert_equals("342\n", found)
    end
    
    typesig { [] }
    def test_ref_to_token_in_lexer
      grammar = "grammar P;\n" + "a : A EOF ;\n" + "A : I {System.out.println($I.text);} ;\n" + "fragment I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "342", @debug)
      assert_equals("342\n", found)
    end
    
    typesig { [] }
    def test_list_label_in_lexer
      grammar = "grammar P;\n" + "a : A ;\n" + "A : i+=I+ {for (Object t : $i) System.out.print(\" \"+((Token)t).getText());} ;\n" + "fragment I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "33 297", @debug)
      assert_equals(" 33 297\n", found)
    end
    
    typesig { [] }
    def test_dup_list_ref_in_lexer
      grammar = "grammar P;\n" + "a : A ;\n" + "A : i+=I WS i+=I {$channel=0; for (Object t : $i) System.out.print(\" \"+((Token)t).getText());} ;\n" + "fragment I : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "33 297", @debug)
      assert_equals(" 33 297\n", found)
    end
    
    typesig { [] }
    def test_char_label_in_lexer
      grammar = "grammar T;\n" + "a : B ;\n" + "B : x='a' {System.out.println((char)$x);} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "a", @debug)
      assert_equals("a\n", found)
    end
    
    typesig { [] }
    def test_repeated_label_in_lexer
      grammar = "lexer grammar T;\n" + "B : x='a' x='b' ;\n"
      found = raw_generate_and_build_recognizer("T.g", grammar, nil, "T", false)
      expecting = true # should be ok
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_repeated_rule_label_in_lexer
      grammar = "lexer grammar T;\n" + "B : x=A x=A ;\n" + "fragment A : 'a' ;\n"
      found = raw_generate_and_build_recognizer("T.g", grammar, nil, "T", false)
      expecting = true # should be ok
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_isolated_eotedge
      grammar = "lexer grammar T;\n" + "QUOTED_CONTENT \n" + "        : 'q' (~'q')* (('x' 'q') )* 'q' ; \n"
      found = raw_generate_and_build_recognizer("T.g", grammar, nil, "T", false)
      expecting = true # should be ok
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_escaped_literals
      # Grammar:
      # A : '\"' ;  should match a single double-quote: "
      # B : '\\\"' ; should match input \"
      grammar = "lexer grammar T;\n" + "A : '\\\"' ;\n" + "B : '\\\\\\\"' ;\n" # '\\\"'
      found = raw_generate_and_build_recognizer("T.g", grammar, nil, "T", false)
      expecting = true # should be ok
      assert_equals(expecting, found)
    end
    
    private
    alias_method :initialize__test_lexer, :initialize
  end
  
end
