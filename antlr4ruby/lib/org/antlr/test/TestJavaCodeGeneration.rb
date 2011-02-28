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
  module TestJavaCodeGenerationImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Junit::Framework, :TestCase
    }
  end
  
  # General code generation testing; compilation and/or execution.
  # These tests are more about avoiding duplicate var definitions
  # etc... than testing a particular ANTLR feature.
  class TestJavaCodeGeneration < TestJavaCodeGenerationImports.const_get :BaseTest
    include_class_members TestJavaCodeGenerationImports
    
    typesig { [] }
    def test_dup_var_def_for_pinched_state
      # so->s2 and s0->s3->s1 pinches back to s1
      # LA3_1, s1 state for DFA 3, was defined twice in similar scope
      # just wrapped in curlies and it's cool.
      grammar = "grammar T;\n" + "a : (| A | B) X Y\n" + "  | (| A | B) X Z\n" + "  ;\n"
      found = raw_generate_and_build_recognizer("T.g", grammar, "TParser", nil, false)
      expecting = true # should be ok
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_labeled_not_sets_in_lexer
      # d must be an int
      grammar = "lexer grammar T;\n" + "A : d=~('x'|'y') e='0'..'9'\n" + "  ; \n"
      found = raw_generate_and_build_recognizer("T.g", grammar, nil, "T", false)
      expecting = true # should be ok
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_labeled_sets_in_lexer
      # d must be an int
      grammar = "grammar T;\n" + "a : A ;\n" + "A : d=('x'|'y') {System.out.println((char)$d);}\n" + "  ; \n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", false)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_labeled_range_in_lexer
      # d must be an int
      grammar = "grammar T;\n" + "a : A;\n" + "A : d='a'..'z' {System.out.println((char)$d);} \n" + "  ; \n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", false)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_labeled_wildcard_in_lexer
      # d must be an int
      grammar = "grammar T;\n" + "a : A;\n" + "A : d=. {System.out.println((char)$d);}\n" + "  ; \n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "x", false)
      assert_equals("x\n", found)
    end
    
    typesig { [] }
    def test_synpred_with_plus_loop
      grammar = "grammar T; \n" + "a : (('x'+)=> 'x'+)?;\n"
      found = raw_generate_and_build_recognizer("T.g", grammar, "TParser", "TLexer", false)
      expecting = true # should be ok
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_double_quote_escape
      grammar = "lexer grammar T; \n" + "A : '\\\\\"';\n" # this is A : '\\"';
      found = raw_generate_and_build_recognizer("T.g", grammar, nil, "TLexer", false)
      expecting = true # should be ok
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_java_code_generation, :initialize
  end
  
end
