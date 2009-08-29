require "rjava"

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
  module TestCompositeGrammarsImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr, :Tool
      include ::Org::Antlr::Tool
    }
  end
  
  class TestCompositeGrammars < TestCompositeGrammarsImports.const_get :BaseTest
    include_class_members TestCompositeGrammarsImports
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    typesig { [] }
    def test_wildcard_still_works
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "parser grammar S;\n" + "a : B . C ;\n" # not qualified ID
      g = Grammar.new(grammar)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_delegator_invokes_delegate_rule
      slave = "parser grammar S;\n" + "a : B {System.out.println(\"S.a\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      # defines B from inherited token space
      master = "grammar M;\n" + "import S;\n" + "s : a ;\n" + "B : 'b' ;" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "s", "b", @debug)
      assert_equals("S.a\n", found)
    end
    
    typesig { [] }
    def test_delegator_invokes_delegate_rule_with_args
      # must generate something like:
      # public int a(int x) throws RecognitionException { return gS.a(x); }
      # in M.
      slave = "parser grammar S;\n" + "a[int x] returns [int y] : B {System.out.print(\"S.a\"); $y=1000;} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      # defines B from inherited token space
      master = "grammar M;\n" + "import S;\n" + "s : label=a[3] {System.out.println($label.y);} ;\n" + "B : 'b' ;" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "s", "b", @debug)
      assert_equals("S.a1000\n", found)
    end
    
    typesig { [] }
    def test_delegator_invokes_delegate_rule_with_return_struct
      # must generate something like:
      # public int a(int x) throws RecognitionException { return gS.a(x); }
      # in M.
      slave = "parser grammar S;\n" + "a : B {System.out.print(\"S.a\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      # defines B from inherited token space
      master = "grammar M;\n" + "import S;\n" + "s : a {System.out.println($a.text);} ;\n" + "B : 'b' ;" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "s", "b", @debug)
      assert_equals("S.ab\n", found)
    end
    
    typesig { [] }
    def test_delegator_accesses_delegate_members
      slave = "parser grammar S;\n" + "@members {\n" + "  public void foo() {System.out.println(\"foo\");}\n" + "}\n" + "a : B ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      # uses no rules from the import
      # gS is import pointer
      master = "grammar M;\n" + "import S;\n" + "s : 'b' {gS.foo();} ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "s", "b", @debug)
      assert_equals("foo\n", found)
    end
    
    typesig { [] }
    def test_delegator_invokes_first_version_of_delegate_rule
      slave = "parser grammar S;\n" + "a : b {System.out.println(\"S.a\");} ;\n" + "b : B ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      slave2 = "parser grammar T;\n" + "a : B {System.out.println(\"T.a\");} ;\n" # hidden by S.a
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "T.g", slave2)
      master = "grammar M;\n" + "import S,T;\n" + "s : a ;\n" + "B : 'b' ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "s", "b", @debug)
      assert_equals("S.a\n", found)
    end
    
    typesig { [] }
    def test_delegates_see_same_token_type
      # A, B, C token type order
      slave = "parser grammar S;\n" + "tokens { A; B; C; }\n" + "x : A {System.out.println(\"S.x\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      # reverse order
      slave2 = "parser grammar T;\n" + "tokens { C; B; A; }\n" + "y : A {System.out.println(\"T.y\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "T.g", slave2)
      # The lexer will create rules to match letters a, b, c.
      # The associated token types A, B, C must have the same value
      # and all import'd parsers.  Since ANTLR regenerates all imports
      # for use with the delegator M, it can generate the same token type
      # mapping in each parser:
      # public static final int C=6;
      # public static final int EOF=-1;
      # public static final int B=5;
      # public static final int WS=7;
      # public static final int A=4;
      # matches AA, which should be "aa"
      # another order: B, A, C
      master = "grammar M;\n" + "import S,T;\n" + "s : x y ;\n" + "B : 'b' ;\n" + "A : 'a' ;\n" + "C : 'c' ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "s", "aa", @debug)
      assert_equals("S.x\n" + "T.y\n", found)
    end
    
    typesig { [] }
    def test_delegates_see_same_token_type2
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # A, B, C token type order
      slave = "parser grammar S;\n" + "tokens { A; B; C; }\n" + "x : A {System.out.println(\"S.x\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      # reverse order
      slave2 = "parser grammar T;\n" + "tokens { C; B; A; }\n" + "y : A {System.out.println(\"T.y\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "T.g", slave2)
      # matches AA, which should be "aa"
      # another order: B, A, C
      master = "grammar M;\n" + "import S,T;\n" + "s : x y ;\n" + "B : 'b' ;\n" + "A : 'a' ;\n" + "C : 'c' ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      expected_token_idto_type_map = "[A=4, B=5, C=6, WS=7]"
      expected_string_literal_to_type_map = "{}"
      expected_type_to_token_list = "[A, B, C, WS]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_combined_imports_combined
      # for now, we don't allow combined to import combined
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # A, B, C token type order
      slave = "grammar S;\n" + "tokens { A; B; C; }\n" + "x : 'x' INT {System.out.println(\"S.x\");} ;\n" + "INT : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "grammar M;\n" + "import S;\n" + "s : x INT ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 1, equeue.attr_errors.size)
      expected_error = "error(161): /tmp/antlr3/M.g:2:8: combined grammar M cannot import combined grammar S"
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), expected_error, equeue.attr_errors.get(0).to_s.replace_first("\\-[0-9]+", "3"))
    end
    
    typesig { [] }
    def test_same_string_two_names
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar S;\n" + "tokens { A='a'; }\n" + "x : A {System.out.println(\"S.x\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      slave2 = "parser grammar T;\n" + "tokens { X='a'; }\n" + "y : X {System.out.println(\"T.y\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "T.g", slave2)
      master = "grammar M;\n" + "import S,T;\n" + "s : x y ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      expected_token_idto_type_map = "[A=4, WS=6, X=5]"
      expected_string_literal_to_type_map = "{'a'=4}"
      expected_type_to_token_list = "[A, X, WS]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      expected_arg = "X='a'"
      expected_arg2 = "A"
      expected_msg_id = ErrorManager::MSG_TOKEN_ALIAS_CONFLICT
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_grammar_semantics_error(equeue, expected_message)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 1, equeue.attr_errors.size)
      expected_error = "error(158): T.g:2:10: cannot alias X='a'; string already assigned to A"
      assert_equals(expected_error, equeue.attr_errors.get(0).to_s)
    end
    
    typesig { [] }
    def test_same_name_two_strings
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar S;\n" + "tokens { A='a'; }\n" + "x : A {System.out.println(\"S.x\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      slave2 = "parser grammar T;\n" + "tokens { A='x'; }\n" + "y : A {System.out.println(\"T.y\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "T.g", slave2)
      master = "grammar M;\n" + "import S,T;\n" + "s : x y ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      expected_token_idto_type_map = "[A=4, T__6=6, WS=5]"
      expected_string_literal_to_type_map = "{'x'=6, 'a'=4}"
      expected_type_to_token_list = "[A, WS, T__6]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      expected_arg = "A='x'"
      expected_arg2 = "'a'"
      expected_msg_id = ErrorManager::MSG_TOKEN_ALIAS_REASSIGNMENT
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_grammar_semantics_error(equeue, expected_message)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 1, equeue.attr_errors.size)
      expected_error = "error(159): T.g:2:10: cannot alias A='x'; token name already assigned to 'a'"
      assert_equals(expected_error, equeue.attr_errors.get(0).to_s)
    end
    
    typesig { [] }
    def test_imported_token_vocab_ignored_with_warning
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar S;\n" + "options {tokenVocab=whatever;}\n" + "tokens { A='a'; }\n" + "x : A {System.out.println(\"S.x\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "grammar M;\n" + "import S;\n" + "s : x ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      expected_arg = "S"
      expected_msg_id = ErrorManager::MSG_TOKEN_VOCAB_IN_DELEGATE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_warning(equeue, expected_message)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 1, equeue.attr_warnings.size)
      expected_error = "warning(160): S.g:2:10: tokenVocab option ignored in imported grammar S"
      assert_equals(expected_error, equeue.attr_warnings.get(0).to_s)
    end
    
    typesig { [] }
    def test_imported_token_vocab_works_in_root
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar S;\n" + "tokens { A='a'; }\n" + "x : A {System.out.println(\"S.x\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      tokens = "A=99\n"
      write_file(self.attr_tmpdir, "Test.tokens", tokens)
      master = "grammar M;\n" + "options {tokenVocab=Test;}\n" + "import S;\n" + "s : x ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      expected_token_idto_type_map = "[A=99, WS=101]"
      expected_string_literal_to_type_map = "{'a'=100}"
      expected_type_to_token_list = "[A, 'a', WS]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_syntax_errors_in_imports_not_thrown_out
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar S;\n" + "options {toke\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "grammar M;\n" + "import S;\n" + "s : x ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      # whole bunch of errors from bad S.g file
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 5, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_syntax_errors_in_imports_not_thrown_out2
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar S;\n" + ": A {System.out.println(\"S.x\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "grammar M;\n" + "import S;\n" + "s : x ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      # whole bunch of errors from bad S.g file
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 3, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_delegator_rule_overrides_delegate
      slave = "parser grammar S;\n" + "a : b {System.out.println(\"S.a\");} ;\n" + "b : B ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "grammar M;\n" + "import S;\n" + "b : 'b'|'c' ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "a", "c", @debug)
      assert_equals("S.a\n", found)
    end
    
    typesig { [] }
    def test_delegator_rule_overrides_lookahead_in_delegate
      slave = "parser grammar JavaDecl;\n" + "type : 'int' ;\n" + "decl : type ID ';'\n" + "     | type ID init ';' {System.out.println(\"JavaDecl: \"+$decl.text);}\n" + "     ;\n" + "init : '=' INT ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "JavaDecl.g", slave)
      master = "grammar Java;\n" + "import JavaDecl;\n" + "prog : decl ;\n" + "type : 'int' | 'float' ;\n" + "\n" + "ID  : 'a'..'z'+ ;\n" + "INT : '0'..'9'+ ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      # for float to work in decl, type must be overridden
      found = exec_parser("Java.g", master, "JavaParser", "JavaLexer", "prog", "float x = 3;", @debug)
      assert_equals("JavaDecl: floatx=3;\n", found)
    end
    
    typesig { [] }
    # LEXER INHERITANCE
    def test_lexer_delegator_invokes_delegate_rule
      slave = "lexer grammar S;\n" + "A : 'a' {System.out.println(\"S.A\");} ;\n" + "C : 'c' ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "lexer grammar M;\n" + "import S;\n" + "B : 'b' ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_lexer("M.g", master, "M", "abc", @debug)
      assert_equals("S.A\nabc\n", found)
    end
    
    typesig { [] }
    def test_lexer_delegator_rule_overrides_delegate
      slave = "lexer grammar S;\n" + "A : 'a' {System.out.println(\"S.A\");} ;\n" + "B : 'b' {System.out.println(\"S.B\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "lexer grammar M;\n" + "import S;\n" + "A : 'a' B {System.out.println(\"M.A\");} ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_lexer("M.g", master, "M", "ab", @debug)
      assert_equals("S.B\n" + "M.A\n" + "ab\n", found)
    end
    
    typesig { [] }
    def test_lexer_delegator_rule_overrides_delegate_leaving_no_rules
      # M.Tokens has nothing to predict tokens from S.  Should
      # not include S.Tokens alt in this case?
      slave = "lexer grammar S;\n" + "A : 'a' {System.out.println(\"S.A\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "lexer grammar M;\n" + "import S;\n" + "A : 'a' {System.out.println(\"M.A\");} ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      write_file(self.attr_tmpdir, "/M.g", master)
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      composite.assign_token_types
      composite.define_grammar_symbols
      composite.create_nfas
      g.create_lookahead_dfas(false)
      # predict only alts from M not S
      expecting_dfa = ".s0-'a'->.s1\n" + ".s0-{'\\n', ' '}->:s3=>2\n" + ".s1-<EOT>->:s2=>1\n"
      dfa = g.get_lookahead_dfa(1)
      serializer = FASerializer.new(g)
      result = serializer.serialize(dfa.attr_start_state)
      assert_equals(expecting_dfa, result)
      # must not be a "unreachable alt: Tokens" error
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_invalid_import_mechanism
      # M.Tokens has nothing to predict tokens from S.  Should
      # not include S.Tokens alt in this case?
      slave = "lexer grammar S;\n" + "A : 'a' {System.out.println(\"S.A\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "tree grammar M;\n" + "import S;\n" + "a : A ;"
      write_file(self.attr_tmpdir, "/M.g", master)
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 1, equeue.attr_errors.size)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_warnings.size)
      expected_error = "error(161): /tmp/antlr3/M.g:2:8: tree grammar M cannot import lexer grammar S"
      assert_equals(expected_error, equeue.attr_errors.get(0).to_s.replace_first("\\-[0-9]+", "3"))
    end
    
    typesig { [] }
    def test_syntactic_predicate_rules_are_not_inherited
      # if this compiles, it means that synpred1_S is defined in S.java
      # but not MParser.java.  MParser has its own synpred1_M which must
      # be separate to compile.
      slave = "parser grammar S;\n" + "a : 'a' {System.out.println(\"S.a1\");}\n" + "  | 'a' {System.out.println(\"S.a2\");}\n" + "  ;\n" + "b : 'x' | 'y' {;} ;\n" # preds generated but not need in DFA here
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      # forces def of preds here in M
      master = "grammar M;\n" + "options {backtrack=true;}\n" + "import S;\n" + "start : a b ;\n" + "nonsense : 'q' | 'q' {;} ;" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "start", "ax", @debug)
      assert_equals("S.a1\n", found)
    end
    
    typesig { [] }
    def test_keyword_vsidgives_no_warning
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "lexer grammar S;\n" + "A : 'abc' {System.out.println(\"S.A\");} ;\n" + "ID : 'a'..'z'+ ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "grammar M;\n" + "import S;\n" + "a : A {System.out.println(\"M.a\");} ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      found = exec_parser("M.g", master, "MParser", "MLexer", "a", "abc", @debug)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
      assert_equals("unexpected warnings: " + RJava.cast_to_string(equeue), 0, equeue.attr_warnings.size)
      assert_equals("S.A\nM.a\n", found)
    end
    
    typesig { [] }
    def test_warning_for_undefined_token
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "lexer grammar S;\n" + "A : 'abc' {System.out.println(\"S.A\");} ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      master = "grammar M;\n" + "import S;\n" + "a : ABC A {System.out.println(\"M.a\");} ;\n" + "WS : (' '|'\\n') {skip();} ;\n"
      # A is defined in S but M should still see it and not give warning.
      # only problem is ABC.
      raw_generate_and_build_recognizer("M.g", master, "MParser", "MLexer", @debug)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
      assert_equals("unexpected warnings: " + RJava.cast_to_string(equeue), 1, equeue.attr_warnings.size)
      expected_error = "warning(105): /tmp/antlr3/M.g:3:5: no lexer rule corresponding to token: ABC"
      assert_equals(expected_error, equeue.attr_warnings.get(0).to_s.replace_first("\\-[0-9]+", "3"))
    end
    
    typesig { [] }
    # Make sure that M can import S that imports T.
    def test3_level_import
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar T;\n" + "a : T ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "T.g", slave)
      # A, B, C token type order
      slave2 = "parser grammar S;\n" + "import T;\n" + "a : S ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave2)
      master = "grammar M;\n" + "import S;\n" + "a : M ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      g.attr_composite.define_grammar_symbols
      expected_token_idto_type_map = "[M=6, S=5, T=4]"
      expected_string_literal_to_type_map = "{}"
      expected_type_to_token_list = "[T, S, M]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
      ok = raw_generate_and_build_recognizer("M.g", master, "MParser", nil, false)
      expecting = true # should be ok
      assert_equals(expecting, ok)
    end
    
    typesig { [] }
    def test_big_tree_of_imports
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar T;\n" + "x : T ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "T.g", slave)
      slave = "parser grammar S;\n" + "import T;\n" + "y : S ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave)
      slave = "parser grammar C;\n" + "i : C ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "C.g", slave)
      slave = "parser grammar B;\n" + "j : B ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "B.g", slave)
      slave = "parser grammar A;\n" + "import B,C;\n" + "k : A ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "A.g", slave)
      master = "grammar M;\n" + "import S,A;\n" + "a : M ;\n"
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      g.attr_composite.define_grammar_symbols
      expected_token_idto_type_map = "[A=8, B=6, C=7, M=9, S=5, T=4]"
      expected_string_literal_to_type_map = "{}"
      expected_type_to_token_list = "[T, S, B, C, A, M]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
      ok = raw_generate_and_build_recognizer("M.g", master, "MParser", nil, false)
      expecting = true # should be ok
      assert_equals(expecting, ok)
    end
    
    typesig { [] }
    def test_rules_visible_through_multilevel_import
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      slave = "parser grammar T;\n" + "x : T ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "T.g", slave)
      # A, B, C token type order
      slave2 = "parser grammar S;\n" + "import T;\n" + "a : S ;\n"
      mkdir(self.attr_tmpdir)
      write_file(self.attr_tmpdir, "S.g", slave2)
      master = "grammar M;\n" + "import S;\n" + "a : M x ;\n" # x MUST BE VISIBLE TO M
      write_file(self.attr_tmpdir, "M.g", master)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/M.g", composite)
      composite.set_delegation_root(g)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      g.attr_composite.define_grammar_symbols
      expected_token_idto_type_map = "[M=6, S=5, T=4]"
      expected_string_literal_to_type_map = "{}"
      expected_type_to_token_list = "[T, S, M]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def initialize
      @debug = false
      super()
      @debug = false
    end
    
    private
    alias_method :initialize__test_composite_grammars, :initialize
  end
  
end
