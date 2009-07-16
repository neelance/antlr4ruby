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
  module TestTokenRewriteStreamImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Runtime, :ANTLRStringStream
      include_const ::Org::Antlr::Runtime, :CharStream
      include_const ::Org::Antlr::Runtime, :TokenRewriteStream
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :Interpreter
    }
  end
  
  class TestTokenRewriteStream < TestTokenRewriteStreamImports.const_get :BaseTest
    include_class_members TestTokenRewriteStreamImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_insert_before_index0
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(0, "0")
      result = tokens.to_s
      expecting = "0abc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_insert_after_last_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_after(2, "x")
      result = tokens.to_s
      expecting = "abcx"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test2_insert_before_after_middle_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(1, "x")
      tokens.insert_after(1, "x")
      result = tokens.to_s
      expecting = "axbxc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_index0
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(0, "x")
      result = tokens.to_s
      expecting = "xbc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_last_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, "x")
      result = tokens.to_s
      expecting = "abx"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_middle_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(1, "x")
      result = tokens.to_s
      expecting = "axc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_to_string_start_stop
      g = Grammar.new("lexer grammar t;\n" + "ID : 'a'..'z'+;\n" + "INT : '0'..'9'+;\n" + "SEMI : ';';\n" + "MUL : '*';\n" + "ASSIGN : '=';\n" + "WS : ' '+;\n")
      # Tokens: 0123456789
      # Input:  x = 3 * 0;
      input = ANTLRStringStream.new("x = 3 * 0;")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(4, 8, "0") # replace 3 * 0 with 0
      result = tokens.to_original_string
      expecting = "x = 3 * 0;"
      assert_equals(expecting, result)
      result = (tokens.to_s).to_s
      expecting = "x = 0;"
      assert_equals(expecting, result)
      result = (tokens.to_s(0, 9)).to_s
      expecting = "x = 0;"
      assert_equals(expecting, result)
      result = (tokens.to_s(4, 8)).to_s
      expecting = "0"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_to_string_start_stop2
      g = Grammar.new("lexer grammar t;\n" + "ID : 'a'..'z'+;\n" + "INT : '0'..'9'+;\n" + "SEMI : ';';\n" + "ASSIGN : '=';\n" + "PLUS : '+';\n" + "MULT : '*';\n" + "WS : ' '+;\n")
      # Tokens: 012345678901234567
      # Input:  x = 3 * 0 + 2 * 0;
      input = ANTLRStringStream.new("x = 3 * 0 + 2 * 0;")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      result = tokens.to_original_string
      expecting = "x = 3 * 0 + 2 * 0;"
      assert_equals(expecting, result)
      tokens.replace(4, 8, "0") # replace 3 * 0 with 0
      result = (tokens.to_s).to_s
      expecting = "x = 0 + 2 * 0;"
      assert_equals(expecting, result)
      result = (tokens.to_s(0, 17)).to_s
      expecting = "x = 0 + 2 * 0;"
      assert_equals(expecting, result)
      result = (tokens.to_s(4, 8)).to_s
      expecting = "0"
      assert_equals(expecting, result)
      result = (tokens.to_s(0, 8)).to_s
      expecting = "x = 0"
      assert_equals(expecting, result)
      result = (tokens.to_s(12, 16)).to_s
      expecting = "2 * 0"
      assert_equals(expecting, result)
      tokens.insert_after(17, "// comment")
      result = (tokens.to_s(12, 17)).to_s
      expecting = "2 * 0;// comment"
      assert_equals(expecting, result)
      result = (tokens.to_s(0, 8)).to_s # try again after insert at end
      expecting = "x = 0"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test2_replace_middle_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(1, "x")
      tokens.replace(1, "y")
      result = tokens.to_s
      expecting = "ayc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test2_replace_middle_index1insert_before
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(0, "_")
      tokens.replace(1, "x")
      tokens.replace(1, "y")
      result = tokens.to_s
      expecting = "_ayc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_then_delete_middle_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(1, "x")
      tokens.delete(1)
      result = tokens.to_s
      expecting = "ac"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_insert_in_prior_replace
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(0, 2, "x")
      tokens.insert_before(1, "0")
      exc = nil
      begin
        tokens.to_s
      rescue IllegalArgumentException => iae
        exc = iae
      end
      expecting = "insert op <InsertBeforeOp@1:\"0\"> within boundaries of previous <ReplaceOp@0..2:\"x\">"
      assert_not_null(exc)
      assert_equals(expecting, exc.get_message)
    end
    
    typesig { [] }
    def test_insert_then_replace_same_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(0, "0")
      tokens.replace(0, "x") # supercedes insert at 0
      result = tokens.to_s
      expecting = "xbc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test2_insert_middle_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(1, "x")
      tokens.insert_before(1, "y")
      result = tokens.to_s
      expecting = "ayxbc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test2_insert_then_replace_index0
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(0, "x")
      tokens.insert_before(0, "y")
      tokens.replace(0, "z")
      result = tokens.to_s
      expecting = "zbc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_then_insert_before_last_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, "x")
      tokens.insert_before(2, "y")
      result = tokens.to_s
      expecting = "abyx"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_insert_then_replace_last_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(2, "y")
      tokens.replace(2, "x")
      result = tokens.to_s
      expecting = "abx"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_then_insert_after_last_index
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, "x")
      tokens.insert_after(2, "y")
      result = tokens.to_s
      expecting = "abxy"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_range_then_insert_at_left_edge
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcccba")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, 4, "x")
      tokens.insert_before(2, "y")
      result = tokens.to_s
      expecting = "abyxba"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_range_then_insert_at_right_edge
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcccba")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, 4, "x")
      tokens.insert_before(4, "y") # no effect; within range of a replace
      exc = nil
      begin
        tokens.to_s
      rescue IllegalArgumentException => iae
        exc = iae
      end
      expecting = "insert op <InsertBeforeOp@4:\"y\"> within boundaries of previous <ReplaceOp@2..4:\"x\">"
      assert_not_null(exc)
      assert_equals(expecting, exc.get_message)
    end
    
    typesig { [] }
    def test_replace_range_then_insert_after_right_edge
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcccba")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, 4, "x")
      tokens.insert_after(4, "y")
      result = tokens.to_s
      expecting = "abxyba"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_all
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcccba")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(0, 6, "x")
      result = tokens.to_s
      expecting = "x"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_subset_then_fetch
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcccba")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, 4, "xyz")
      result = tokens.to_s(0, 6)
      expecting = "abxyzba"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_replace_then_replace_superset
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcccba")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, 4, "xyz")
      tokens.replace(3, 5, "foo") # overlaps, error
      exc = nil
      begin
        tokens.to_s
      rescue IllegalArgumentException => iae
        exc = iae
      end
      expecting = "replace op boundaries of <ReplaceOp@3..5:\"foo\"> overlap with previous <ReplaceOp@2..4:\"xyz\">"
      assert_not_null(exc)
      assert_equals(expecting, exc.get_message)
    end
    
    typesig { [] }
    def test_replace_then_replace_lower_indexed_superset
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcccba")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, 4, "xyz")
      tokens.replace(1, 3, "foo") # overlap, error
      exc = nil
      begin
        tokens.to_s
      rescue IllegalArgumentException => iae
        exc = iae
      end
      expecting = "replace op boundaries of <ReplaceOp@1..3:\"foo\"> overlap with previous <ReplaceOp@2..4:\"xyz\">"
      assert_not_null(exc)
      assert_equals(expecting, exc.get_message)
    end
    
    typesig { [] }
    def test_replace_single_middle_then_overlapping_superset
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcba")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, 2, "xyz")
      tokens.replace(0, 3, "foo")
      result = tokens.to_s
      expecting = "fooa"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    # June 2, 2008 I rewrote core of rewrite engine; just adding lots more tests here
    def test_combine_inserts
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(0, "x")
      tokens.insert_before(0, "y")
      result = tokens.to_s
      expecting = "yxabc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_combine3inserts
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(1, "x")
      tokens.insert_before(0, "y")
      tokens.insert_before(1, "z")
      result = tokens.to_s
      expecting = "yazxbc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_combine_insert_on_left_with_replace
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(0, 2, "foo")
      tokens.insert_before(0, "z") # combine with left edge of rewrite
      result = tokens.to_s
      expecting = "zfoo"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_combine_insert_on_left_with_delete
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.delete(0, 2)
      tokens.insert_before(0, "z") # combine with left edge of rewrite
      result = tokens.to_s
      expecting = "z" # make sure combo is not znull
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_disjoint_inserts
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(1, "x")
      tokens.insert_before(2, "y")
      tokens.insert_before(0, "z")
      result = tokens.to_s
      expecting = "zaxbyc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_overlapping_replace
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(1, 2, "foo")
      tokens.replace(0, 3, "bar") # wipes prior nested replace
      result = tokens.to_s
      expecting = "bar"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_overlapping_replace2
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(0, 3, "bar")
      tokens.replace(1, 2, "foo") # cannot split earlier replace
      exc = nil
      begin
        tokens.to_s
      rescue IllegalArgumentException => iae
        exc = iae
      end
      expecting = "replace op boundaries of <ReplaceOp@1..2:\"foo\"> overlap with previous <ReplaceOp@0..3:\"bar\">"
      assert_not_null(exc)
      assert_equals(expecting, exc.get_message)
    end
    
    typesig { [] }
    def test_overlapping_replace3
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(1, 2, "foo")
      tokens.replace(0, 2, "bar") # wipes prior nested replace
      result = tokens.to_s
      expecting = "barc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_overlapping_replace4
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(1, 2, "foo")
      tokens.replace(1, 3, "bar") # wipes prior nested replace
      result = tokens.to_s
      expecting = "abar"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_drop_identical_replace
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(1, 2, "foo")
      tokens.replace(1, 2, "foo") # drop previous, identical
      result = tokens.to_s
      expecting = "afooc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_drop_prev_covered_insert
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(1, "foo")
      tokens.replace(1, 2, "foo") # kill prev insert
      result = tokens.to_s
      expecting = "afooc"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_leave_alone_disjoint_insert
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.insert_before(1, "x")
      tokens.replace(2, 3, "foo")
      result = tokens.to_s
      expecting = "axbfoo"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_leave_alone_disjoint_insert2
      g = Grammar.new("lexer grammar t;\n" + "A : 'a';\n" + "B : 'b';\n" + "C : 'c';\n")
      input = ANTLRStringStream.new("abcc")
      lex_engine = Interpreter.new(g, input)
      tokens = TokenRewriteStream.new(lex_engine)
      tokens._lt(1) # fill buffer
      tokens.replace(2, 3, "foo")
      tokens.insert_before(1, "x")
      result = tokens.to_s
      expecting = "axbfoo"
      assert_equals(expecting, result)
    end
    
    private
    alias_method :initialize__test_token_rewrite_stream, :initialize
  end
  
end
