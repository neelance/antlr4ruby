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
  module TestInterpretedLexingImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :Interpreter
      include ::Org::Antlr::Runtime
    }
  end
  
  class TestInterpretedLexing < TestInterpretedLexingImports.const_get :BaseTest
    include_class_members TestInterpretedLexingImports
    
    typesig { [] }
    # static class Tracer implements ANTLRDebugInterface {
    # Grammar g;
    # public DebugActions(Grammar g) {
    # this.g = g;
    # }
    # public void enterRule(String ruleName) {
    # System.out.println("enterRule("+ruleName+")");
    # }
    # 
    # public void exitRule(String ruleName) {
    # System.out.println("exitRule("+ruleName+")");
    # }
    # 
    # public void matchElement(int type) {
    # System.out.println("matchElement("+g.getTokenName(type)+")");
    # }
    # 
    # public void mismatchedElement(MismatchedTokenException e) {
    # System.out.println(e);
    # e.printStackTrace(System.out);
    # }
    # 
    # public void mismatchedSet(MismatchedSetException e) {
    # System.out.println(e);
    # e.printStackTrace(System.out);
    # }
    # 
    # public void noViableAlt(NoViableAltException e) {
    # System.out.println(e);
    # e.printStackTrace(System.out);
    # }
    # }
    # 
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_simple_alt_char_test
      g = Grammar.new("lexer grammar t;\n" + "A : 'a' | 'b' | 'c';")
      atype = g.get_token_type("A")
      engine = Interpreter.new(g, ANTLRStringStream.new("a"))
      engine = Interpreter.new(g, ANTLRStringStream.new("b"))
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
      engine = Interpreter.new(g, ANTLRStringStream.new("c"))
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
    end
    
    typesig { [] }
    def test_single_rule_ref
      g = Grammar.new("lexer grammar t;\n" + "A : 'a' B 'c' ;\n" + "B : 'b' ;\n")
      atype = g.get_token_type("A")
      engine = Interpreter.new(g, ANTLRStringStream.new("abc")) # should ignore the x
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
    end
    
    typesig { [] }
    def test_simple_loop
      g = Grammar.new("lexer grammar t;\n" + "INT : (DIGIT)+ ;\n" + "fragment DIGIT : '0'..'9';\n")
      inttype = g.get_token_type("INT")
      engine = Interpreter.new(g, ANTLRStringStream.new("12x")) # should ignore the x
      result = engine.scan("INT")
      assert_equals(result.get_type, inttype)
      engine = Interpreter.new(g, ANTLRStringStream.new("1234"))
      result = engine.scan("INT")
      assert_equals(result.get_type, inttype)
    end
    
    typesig { [] }
    def test_mult_alt_loop
      g = Grammar.new("lexer grammar t;\n" + "A : ('0'..'9'|'a'|'b')+ ;\n")
      atype = g.get_token_type("A")
      engine = Interpreter.new(g, ANTLRStringStream.new("a"))
      result = engine.scan("A")
      engine = Interpreter.new(g, ANTLRStringStream.new("a"))
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
      engine = Interpreter.new(g, ANTLRStringStream.new("1234"))
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
      engine = Interpreter.new(g, ANTLRStringStream.new("aaa"))
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
      engine = Interpreter.new(g, ANTLRStringStream.new("aaaa9"))
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
      engine = Interpreter.new(g, ANTLRStringStream.new("b"))
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
      engine = Interpreter.new(g, ANTLRStringStream.new("baa"))
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
    end
    
    typesig { [] }
    def test_simple_loops
      g = Grammar.new("lexer grammar t;\n" + "A : ('0'..'9')+ '.' ('0'..'9')* | ('0'..'9')+ ;\n")
      atype = g.get_token_type("A")
      input = ANTLRStringStream.new("1234.5")
      engine = Interpreter.new(g, input)
      result = engine.scan("A")
      assert_equals(result.get_type, atype)
    end
    
    typesig { [] }
    def test_tokens_rules
      pg = Grammar.new("grammar p;\n" + "a : (INT|FLOAT|WS)+;\n")
      g = Grammar.new
      g.import_token_vocabulary(pg)
      g.set_file_name("<string>")
      g.set_grammar_content("lexer grammar t;\n" + "INT : (DIGIT)+ ;\n" + "FLOAT : (DIGIT)+ '.' (DIGIT)* ;\n" + "fragment DIGIT : '0'..'9';\n" + "WS : (' ')+ {channel=99;};\n")
      input = ANTLRStringStream.new("123 139.52")
      lex_engine = Interpreter.new(g, input)
      tokens = CommonTokenStream.new(lex_engine)
      result = tokens.to_s
      # System.out.println(result);
      expecting = "123 139.52"
      assert_equals(result, expecting)
    end
    
    private
    alias_method :initialize__test_interpreted_lexing, :initialize
  end
  
end
