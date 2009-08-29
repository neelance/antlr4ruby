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
  module TestInterpretedParsingImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :Interpreter
      include ::Org::Antlr::Runtime
      include_const ::Org::Antlr::Runtime::Tree, :ParseTree
    }
  end
  
  class TestInterpretedParsing < TestInterpretedParsingImports.const_get :BaseTest
    include_class_members TestInterpretedParsingImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_simple_parse
      pg = Grammar.new("parser grammar p;\n" + "prog : WHILE ID LCURLY (assign)* RCURLY EOF;\n" + "assign : ID ASSIGN expr SEMI ;\n" + "expr : INT | FLOAT | ID ;\n")
      g = Grammar.new
      g.import_token_vocabulary(pg)
      g.set_file_name(RJava.cast_to_string(Grammar::IGNORE_STRING_IN_GRAMMAR_FILE_NAME) + "string")
      g.set_grammar_content("lexer grammar t;\n" + "WHILE : 'while';\n" + "LCURLY : '{';\n" + "RCURLY : '}';\n" + "ASSIGN : '=';\n" + "SEMI : ';';\n" + "ID : ('a'..'z')+ ;\n" + "INT : (DIGIT)+ ;\n" + "FLOAT : (DIGIT)+ '.' (DIGIT)* ;\n" + "fragment DIGIT : '0'..'9';\n" + "WS : (' ')+ ;\n")
      input = ANTLRStringStream.new("while x { i=1; y=3.42; z=y; }")
      lex_engine = Interpreter.new(g, input)
      tokens = CommonTokenStream.new(lex_engine)
      tokens.set_token_type_channel(g.get_token_type("WS"), 99)
      # System.out.println("tokens="+tokens.toString());
      parse_engine = Interpreter.new(pg, tokens)
      t = parse_engine.parse("prog")
      result = t.to_string_tree
      expecting = "(<grammar p> (prog while x { (assign i = (expr 1) ;) (assign y = (expr 3.42) ;) (assign z = (expr y) ;) } <EOF>))"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_mismatched_token_error
      pg = Grammar.new("parser grammar p;\n" + "prog : WHILE ID LCURLY (assign)* RCURLY;\n" + "assign : ID ASSIGN expr SEMI ;\n" + "expr : INT | FLOAT | ID ;\n")
      g = Grammar.new
      g.set_file_name(RJava.cast_to_string(Grammar::IGNORE_STRING_IN_GRAMMAR_FILE_NAME) + "string")
      g.import_token_vocabulary(pg)
      g.set_grammar_content("lexer grammar t;\n" + "WHILE : 'while';\n" + "LCURLY : '{';\n" + "RCURLY : '}';\n" + "ASSIGN : '=';\n" + "SEMI : ';';\n" + "ID : ('a'..'z')+ ;\n" + "INT : (DIGIT)+ ;\n" + "FLOAT : (DIGIT)+ '.' (DIGIT)* ;\n" + "fragment DIGIT : '0'..'9';\n" + "WS : (' ')+ ;\n")
      input = ANTLRStringStream.new("while x { i=1 y=3.42; z=y; }")
      lex_engine = Interpreter.new(g, input)
      tokens = CommonTokenStream.new(lex_engine)
      tokens.set_token_type_channel(g.get_token_type("WS"), 99)
      # System.out.println("tokens="+tokens.toString());
      parse_engine = Interpreter.new(pg, tokens)
      t = parse_engine.parse("prog")
      result = t.to_string_tree
      expecting = "(<grammar p> (prog while x { (assign i = (expr 1) MismatchedTokenException(5!=9))))"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_mismatched_set_error
      pg = Grammar.new("parser grammar p;\n" + "prog : WHILE ID LCURLY (assign)* RCURLY;\n" + "assign : ID ASSIGN expr SEMI ;\n" + "expr : INT | FLOAT | ID ;\n")
      g = Grammar.new
      g.import_token_vocabulary(pg)
      g.set_file_name("<string>")
      g.set_grammar_content("lexer grammar t;\n" + "WHILE : 'while';\n" + "LCURLY : '{';\n" + "RCURLY : '}';\n" + "ASSIGN : '=';\n" + "SEMI : ';';\n" + "ID : ('a'..'z')+ ;\n" + "INT : (DIGIT)+ ;\n" + "FLOAT : (DIGIT)+ '.' (DIGIT)* ;\n" + "fragment DIGIT : '0'..'9';\n" + "WS : (' ')+ ;\n")
      input = ANTLRStringStream.new("while x { i=; y=3.42; z=y; }")
      lex_engine = Interpreter.new(g, input)
      tokens = CommonTokenStream.new(lex_engine)
      tokens.set_token_type_channel(g.get_token_type("WS"), 99)
      # System.out.println("tokens="+tokens.toString());
      parse_engine = Interpreter.new(pg, tokens)
      t = parse_engine.parse("prog")
      result = t.to_string_tree
      expecting = "(<grammar p> (prog while x { (assign i = (expr MismatchedSetException(9!={5,10,11})))))"
      assert_equals(expecting, result)
    end
    
    typesig { [] }
    def test_no_viable_alt_error
      pg = Grammar.new("parser grammar p;\n" + "prog : WHILE ID LCURLY (assign)* RCURLY;\n" + "assign : ID ASSIGN expr SEMI ;\n" + "expr : {;}INT | FLOAT | ID ;\n")
      g = Grammar.new
      g.import_token_vocabulary(pg)
      g.set_file_name("<string>")
      g.set_grammar_content("lexer grammar t;\n" + "WHILE : 'while';\n" + "LCURLY : '{';\n" + "RCURLY : '}';\n" + "ASSIGN : '=';\n" + "SEMI : ';';\n" + "ID : ('a'..'z')+ ;\n" + "INT : (DIGIT)+ ;\n" + "FLOAT : (DIGIT)+ '.' (DIGIT)* ;\n" + "fragment DIGIT : '0'..'9';\n" + "WS : (' ')+ ;\n")
      input = ANTLRStringStream.new("while x { i=; y=3.42; z=y; }")
      lex_engine = Interpreter.new(g, input)
      tokens = CommonTokenStream.new(lex_engine)
      tokens.set_token_type_channel(g.get_token_type("WS"), 99)
      # System.out.println("tokens="+tokens.toString());
      parse_engine = Interpreter.new(pg, tokens)
      t = parse_engine.parse("prog")
      result = t.to_string_tree
      expecting = "(<grammar p> (prog while x { (assign i = (expr NoViableAltException(9@[4:1: expr : ( INT | FLOAT | ID );])))))"
      assert_equals(expecting, result)
    end
    
    private
    alias_method :initialize__test_interpreted_parsing, :initialize
  end
  
end
