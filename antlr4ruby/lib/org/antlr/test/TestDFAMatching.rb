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
  module TestDFAMatchingImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Analysis, :DFA
      include_const ::Org::Antlr::Analysis, :NFA
      include_const ::Org::Antlr::Runtime, :ANTLRStringStream
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  class TestDFAMatching < TestDFAMatchingImports.const_get :BaseTest
    include_class_members TestDFAMatchingImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_simple_alt_char_test
      g = Grammar.new("lexer grammar t;\n" + "A : {;}'a' | 'b' | 'c';")
      g.build_nfa
      g.create_lookahead_dfas(false)
      dfa = g.get_lookahead_dfa(1)
      check_prediction(dfa, "a", 1)
      check_prediction(dfa, "b", 2)
      check_prediction(dfa, "c", 3)
      check_prediction(dfa, "d", NFA::INVALID_ALT_NUMBER)
    end
    
    typesig { [] }
    def test_sets
      g = Grammar.new("lexer grammar t;\n" + "A : {;}'a'..'z' | ';' | '0'..'9' ;")
      g.build_nfa
      g.create_lookahead_dfas(false)
      dfa = g.get_lookahead_dfa(1)
      check_prediction(dfa, "a", 1)
      check_prediction(dfa, "q", 1)
      check_prediction(dfa, "z", 1)
      check_prediction(dfa, ";", 2)
      check_prediction(dfa, "9", 3)
    end
    
    typesig { [] }
    def test_finite_common_left_prefixes
      g = Grammar.new("lexer grammar t;\n" + "A : 'a' 'b' | 'a' 'c' | 'd' 'e' ;")
      g.build_nfa
      g.create_lookahead_dfas(false)
      dfa = g.get_lookahead_dfa(1)
      check_prediction(dfa, "ab", 1)
      check_prediction(dfa, "ac", 2)
      check_prediction(dfa, "de", 3)
      check_prediction(dfa, "q", NFA::INVALID_ALT_NUMBER)
    end
    
    typesig { [] }
    def test_simple_loops
      g = Grammar.new("lexer grammar t;\n" + "A : (DIGIT)+ '.' DIGIT | (DIGIT)+ ;\n" + "fragment DIGIT : '0'..'9' ;\n")
      g.build_nfa
      g.create_lookahead_dfas(false)
      dfa = g.get_lookahead_dfa(3)
      check_prediction(dfa, "32", 2)
      check_prediction(dfa, "999.2", 1)
      check_prediction(dfa, ".2", NFA::INVALID_ALT_NUMBER)
    end
    
    typesig { [DFA, String, ::Java::Int] }
    def check_prediction(dfa, input, expected)
      stream = ANTLRStringStream.new(input)
      assert_equals(dfa.predict(stream), expected)
    end
    
    private
    alias_method :initialize__test_dfamatching, :initialize
  end
  
end
