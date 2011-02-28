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
  module TestSymbolDefinitionsImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include ::Org::Antlr::Tool
      include ::Java::Util
    }
  end
  
  class TestSymbolDefinitions < TestSymbolDefinitionsImports.const_get :BaseTest
    include_class_members TestSymbolDefinitionsImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_parser_simple_tokens
      g = Grammar.new("parser grammar t;\n" + "a : A | B;\n" + "b : C ;")
      rules = "a, b"
      token_names = "A, B, C"
      check_symbols(g, rules, token_names)
    end
    
    typesig { [] }
    def test_parser_tokens_section
      g = Grammar.new("parser grammar t;\n" + "tokens {\n" + "  C;\n" + "  D;" + "}\n" + "a : A | B;\n" + "b : C ;")
      rules = "a, b"
      token_names = "A, B, C, D"
      check_symbols(g, rules, token_names)
    end
    
    typesig { [] }
    def test_lexer_tokens_section
      g = Grammar.new("lexer grammar t;\n" + "tokens {\n" + "  C;\n" + "  D;" + "}\n" + "A : 'a';\n" + "C : 'c' ;")
      rules = "A, C, Tokens"
      token_names = "A, C, D"
      check_symbols(g, rules, token_names)
    end
    
    typesig { [] }
    def test_tokens_section_with_assignment_section
      g = Grammar.new("grammar t;\n" + "tokens {\n" + "  C='c';\n" + "  D;" + "}\n" + "a : A | B;\n" + "b : C ;")
      rules = "a, b"
      token_names = "A, B, C, D, 'c'"
      check_symbols(g, rules, token_names)
    end
    
    typesig { [] }
    def test_combined_grammar_literals
      # "foo" is not a token name
      g = Grammar.new("grammar t;\n" + "a : 'begin' b 'end';\n" + "b : C ';' ;\n" + "ID : 'a' ;\n" + "FOO : 'foo' ;\n" + "C : 'c' ;\n") # nor is 'c'
      rules = "a, b"
      token_names = "C, FOO, ID, 'begin', 'end', ';'"
      check_symbols(g, rules, token_names)
    end
    
    typesig { [] }
    def test_literal_in_parser_and_lexer
      # 'x' is token and char in lexer rule
      g = Grammar.new("grammar t;\n" + "a : 'x' E ; \n" + "E: 'x' '0' ;\n") # nor is 'c'
      literals = "['x']"
      found_literals = g.get_string_literals.to_s
      assert_equals(literals, found_literals)
      implicit_lexer = "lexer grammar t;\n" + "\n" + "T__5 : 'x' ;\n" + "\n" + "// $ANTLR src \"<string>\" 3\n" + "E: 'x' '0' ;\n"
      assert_equals(implicit_lexer, g.get_lexer_grammar)
    end
    
    typesig { [] }
    def test_combined_grammar_with_ref_to_literal_but_no_token_idref
      g = Grammar.new("grammar t;\n" + "a : 'a' ;\n" + "A : 'a' ;\n")
      rules = "a"
      token_names = "A, 'a'"
      check_symbols(g, rules, token_names)
    end
    
    typesig { [] }
    def test_set_does_not_miss_token_aliases
      g = Grammar.new("grammar t;\n" + "a : 'a'|'b' ;\n" + "A : 'a' ;\n" + "B : 'b' ;\n")
      rules = "a"
      token_names = "A, 'a', B, 'b'"
      check_symbols(g, rules, token_names)
    end
    
    typesig { [] }
    def test_simple_plus_equal_label
      g = Grammar.new("parser grammar t;\n" + "a : ids+=ID ( COMMA ids+=ID )* ;\n")
      rule = "a"
      token_labels = "ids"
      rule_labels = nil
      check_plus_equals_labels(g, rule, token_labels, rule_labels)
    end
    
    typesig { [] }
    def test_mixed_plus_equal_label
      g = Grammar.new("grammar t;\n" + "options {output=AST;}\n" + "a : id+=ID ( ',' e+=expr )* ;\n" + "expr : 'e';\n" + "ID : 'a';\n")
      rule = "a"
      token_labels = "id"
      rule_labels = "e"
      check_plus_equals_labels(g, rule, token_labels, rule_labels)
    end
    
    typesig { [] }
    # T E S T  L I T E R A L  E S C A P E S
    def test_parser_char_literal_with_escape
      g = Grammar.new("grammar t;\n" + "a : '\\n';\n")
      literals = g.get_string_literals
      # must store literals how they appear in the antlr grammar
      assert_equals("'\\n'", literals.to_array[0])
    end
    
    typesig { [] }
    def test_token_in_tokens_section_and_token_rule_def
      # this must return A not I to the parser; calling a nonfragment rule
      # from a nonfragment rule does not set the overall token.
      grammar = "grammar P;\n" + "tokens { B='}'; }\n" + "a : A B {System.out.println(input);} ;\n" + "A : 'a' ;\n" + "B : '}' ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "a}", false)
      assert_equals("a}\n", found)
    end
    
    typesig { [] }
    def test_token_in_tokens_section_and_token_rule_def2
      # this must return A not I to the parser; calling a nonfragment rule
      # from a nonfragment rule does not set the overall token.
      grammar = "grammar P;\n" + "tokens { B='}'; }\n" + "a : A '}' {System.out.println(input);} ;\n" + "A : 'a' ;\n" + "B : '}' {/* */} ;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;"
      found = exec_parser("P.g", grammar, "PParser", "PLexer", "a", "a}", false)
      assert_equals("a}\n", found)
    end
    
    typesig { [] }
    def test_ref_to_rule_with_no_return_value
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar_str = "grammar P;\n" + "a : x=b ;\n" + "b : B ;\n" + "B : 'b' ;\n"
      g = Grammar.new(grammar_str)
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      recog_st = generator.gen_recognizer
      code = recog_st.to_s
      assert_true("not expecting label", code.index_of("x=b();") < 0)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    # T E S T  E R R O R S
    def test_parser_string_literals
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : 'begin' b ;\n" + "b : C ;")
      expected_arg = "'begin'"
      expected_msg_id = ErrorManager::MSG_LITERAL_NOT_ASSOCIATED_WITH_LEXER_RULE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_parser_char_literals
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : '(' b ;\n" + "b : C ;")
      expected_arg = "'('"
      expected_msg_id = ErrorManager::MSG_LITERAL_NOT_ASSOCIATED_WITH_LEXER_RULE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_empty_not_char
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar foo;\n" + "a : (~'x')+ ;\n")
      g.build_nfa
      expected_arg = "'x'"
      expected_msg_id = ErrorManager::MSG_EMPTY_COMPLEMENT
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_empty_not_token
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar foo;\n" + "a : (~A)+ ;\n")
      g.build_nfa
      expected_arg = "A"
      expected_msg_id = ErrorManager::MSG_EMPTY_COMPLEMENT
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_empty_not_set
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar foo;\n" + "a : (~(A|B))+ ;\n")
      g.build_nfa
      expected_arg = nil
      expected_msg_id = ErrorManager::MSG_EMPTY_COMPLEMENT
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_string_literal_in_parser_tokens_section
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "tokens {\n" + "  B='begin';\n" + "}\n" + "a : A B;\n" + "b : C ;")
      expected_arg = "'begin'"
      expected_msg_id = ErrorManager::MSG_LITERAL_NOT_ASSOCIATED_WITH_LEXER_RULE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_char_literal_in_parser_tokens_section
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "tokens {\n" + "  B='(';\n" + "}\n" + "a : A B;\n" + "b : C ;")
      expected_arg = "'('"
      expected_msg_id = ErrorManager::MSG_LITERAL_NOT_ASSOCIATED_WITH_LEXER_RULE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_char_literal_in_lexer_tokens_section
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("lexer grammar t;\n" + "tokens {\n" + "  B='(';\n" + "}\n" + "ID : 'a';\n")
      expected_arg = "'('"
      expected_msg_id = ErrorManager::MSG_CANNOT_ALIAS_TOKENS_IN_LEXER
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_redefinition
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a : A | B;\n" + "a : C ;")
      expected_arg = "a"
      expected_msg_id = ErrorManager::MSG_RULE_REDEFINITION
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_lexer_rule_redefinition
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("lexer grammar t;\n" + "ID : 'a' ;\n" + "ID : 'd' ;")
      expected_arg = "ID"
      expected_msg_id = ErrorManager::MSG_RULE_REDEFINITION
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_combined_rule_redefinition
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("grammar t;\n" + "x : ID ;\n" + "ID : 'a' ;\n" + "x : ID ID ;")
      expected_arg = "x"
      expected_msg_id = ErrorManager::MSG_RULE_REDEFINITION
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_undefined_token
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("grammar t;\n" + "x : ID ;")
      expected_arg = "ID"
      expected_msg_id = ErrorManager::MSG_NO_TOKEN_DEFINITION
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_warning(equeue, expected_message)
    end
    
    typesig { [] }
    def test_undefined_token_ok_in_parser
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "x : ID ;")
      assert_equals("should not be an error", 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_undefined_rule
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("grammar t;\n" + "x : r ;")
      expected_arg = "r"
      expected_msg_id = ErrorManager::MSG_UNDEFINED_RULE_REF
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_lexer_rule_in_parser
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "X : ;")
      expected_arg = "X"
      expected_msg_id = ErrorManager::MSG_LEXER_RULES_NOT_ALLOWED
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_parser_rule_in_lexer
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("lexer grammar t;\n" + "a : ;")
      expected_arg = "a"
      expected_msg_id = ErrorManager::MSG_PARSER_RULES_NOT_ALLOWED
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_scope_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("grammar t;\n" + "scope a {\n" + "  int n;\n" + "}\n" + "a : \n" + "  ;\n")
      expected_arg = "a"
      expected_msg_id = ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_token_rule_scope_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("grammar t;\n" + "scope ID {\n" + "  int n;\n" + "}\n" + "ID : 'a'\n" + "  ;\n")
      expected_arg = "ID"
      expected_msg_id = ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_token_scope_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("grammar t;\n" + "tokens { ID; }\n" + "scope ID {\n" + "  int n;\n" + "}\n" + "a : \n" + "  ;\n")
      expected_arg = "ID"
      expected_msg_id = ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_token_rule_scope_conflict_in_lexer_grammar
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("lexer grammar t;\n" + "scope ID {\n" + "  int n;\n" + "}\n" + "ID : 'a'\n" + "  ;\n")
      expected_arg = "ID"
      expected_msg_id = ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_token_label_scope_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "scope s {\n" + "  int n;\n" + "}\n" + "a : s=ID \n" + "  ;\n")
      expected_arg = "s"
      expected_msg_id = ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_label_scope_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "scope s {\n" + "  int n;\n" + "}\n" + "a : s=b \n" + "  ;\n" + "b : ;\n")
      expected_arg = "s"
      expected_msg_id = ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_label_and_rule_name_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a : c=b \n" + "  ;\n" + "b : ;\n" + "c : ;\n")
      expected_arg = "c"
      expected_msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_RULE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_label_and_token_name_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a : ID=b \n" + "  ;\n" + "b : ID ;\n" + "c : ;\n")
      expected_arg = "ID"
      expected_msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_TOKEN
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_label_and_arg_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a[int i] returns [int x]: i=ID \n" + "  ;\n")
      expected_arg = "i"
      expected_msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_RULE_ARG_RETVAL
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_label_and_parameter_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a[int i] returns [int x]: x=ID \n" + "  ;\n")
      expected_arg = "x"
      expected_msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_RULE_ARG_RETVAL
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_label_rule_scope_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a\n" + "scope {" + "  int n;" + "}\n" + "  : n=ID\n" + "  ;\n")
      expected_arg = "n"
      expected_arg2 = "a"
      expected_msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_RULE_SCOPE_ATTRIBUTE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_scope_arg_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a[int n]\n" + "scope {" + "  int n;" + "}\n" + "  : \n" + "  ;\n")
      expected_arg = "n"
      expected_arg2 = "a"
      expected_msg_id = ErrorManager::MSG_ATTRIBUTE_CONFLICTS_WITH_RULE_ARG_RETVAL
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_scope_return_value_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a returns [int n]\n" + "scope {" + "  int n;" + "}\n" + "  : \n" + "  ;\n")
      expected_arg = "n"
      expected_arg2 = "a"
      expected_msg_id = ErrorManager::MSG_ATTRIBUTE_CONFLICTS_WITH_RULE_ARG_RETVAL
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_scope_rule_name_conflict
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("parser grammar t;\n" + "a\n" + "scope {" + "  int a;" + "}\n" + "  : \n" + "  ;\n")
      expected_arg = "a"
      expected_arg2 = nil
      expected_msg_id = ErrorManager::MSG_ATTRIBUTE_CONFLICTS_WITH_RULE
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_bad_grammar_option
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      antlr = new_tool
      g = Grammar.new(antlr, "grammar t;\n" + "options {foo=3; language=Java;}\n" + "a : 'a';\n")
      expected_arg = "foo"
      expected_msg_id = ErrorManager::MSG_ILLEGAL_OPTION
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_bad_rule_option
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("grammar t;\n" + "a\n" + "options {k=3; tokenVocab=blort;}\n" + "  : 'a';\n")
      expected_arg = "tokenVocab"
      expected_msg_id = ErrorManager::MSG_ILLEGAL_OPTION
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_bad_sub_rule_option
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue) # unique listener per thread
      g = Grammar.new("grammar t;\n" + "a : ( options {k=3; language=Java;}\n" + "    : 'a'\n" + "    | 'b'\n" + "    )\n" + "  ;\n")
      expected_arg = "language"
      expected_msg_id = ErrorManager::MSG_ILLEGAL_OPTION
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_grammar_semantics_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_token_vocab_string_used_in_lexer
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      tokens = "';'=4\n"
      write_file(self.attr_tmpdir, "T.tokens", tokens)
      importer = "lexer grammar B; \n" + "options\t{tokenVocab=T;} \n" + "SEMI:';' ; \n"
      write_file(self.attr_tmpdir, "B.g", importer)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/B.g", composite)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      expected_token_idto_type_map = "[SEMI=4]"
      expected_string_literal_to_type_map = "{';'=4}"
      expected_type_to_token_list = "[SEMI]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_token_vocab_string_used_in_combined
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      tokens = "';'=4\n"
      write_file(self.attr_tmpdir, "T.tokens", tokens)
      importer = "grammar B; \n" + "options\t{tokenVocab=T;} \n" + "SEMI:';' ; \n"
      write_file(self.attr_tmpdir, "B.g", importer)
      antlr = new_tool(Array.typed(String).new(["-lib", self.attr_tmpdir]))
      composite = CompositeGrammar.new
      g = Grammar.new(antlr, RJava.cast_to_string(self.attr_tmpdir) + "/B.g", composite)
      g.parse_and_build_ast
      g.attr_composite.assign_token_types
      expected_token_idto_type_map = "[SEMI=4]"
      expected_string_literal_to_type_map = "{';'=4}"
      expected_type_to_token_list = "[SEMI]"
      assert_equals(expected_token_idto_type_map, real_elements(g.attr_composite.attr_token_idto_type_map).to_s)
      assert_equals(expected_string_literal_to_type_map, g.attr_composite.attr_string_literal_to_type_map.to_s)
      assert_equals(expected_type_to_token_list, real_elements(g.attr_composite.attr_type_to_token_list).to_s)
      assert_equals("unexpected errors: " + RJava.cast_to_string(equeue), 0, equeue.attr_errors.size)
    end
    
    typesig { [Grammar, String, String, String] }
    def check_plus_equals_labels(g, rule_name, token_labels_str, rule_labels_str)
      # make sure expected += labels are there
      r = g.get_rule(rule_name)
      st = StringTokenizer.new(token_labels_str, ", ")
      token_labels = nil
      while (st.has_more_tokens)
        if ((token_labels).nil?)
          token_labels = HashSet.new
        end
        label_name = st.next_token
        token_labels.add(label_name)
      end
      rule_labels = nil
      if (!(rule_labels_str).nil?)
        st = StringTokenizer.new(rule_labels_str, ", ")
        rule_labels = HashSet.new
        while (st.has_more_tokens)
          label_name = st.next_token
          rule_labels.add(label_name)
        end
      end
      assert_true("token += labels mismatch; " + RJava.cast_to_string(token_labels) + "!=" + RJava.cast_to_string(r.attr_token_list_labels), (!(token_labels).nil? && !(r.attr_token_list_labels).nil?) || ((token_labels).nil? && (r.attr_token_list_labels).nil?))
      assert_true("rule += labels mismatch; " + RJava.cast_to_string(rule_labels) + "!=" + RJava.cast_to_string(r.attr_rule_list_labels), (!(rule_labels).nil? && !(r.attr_rule_list_labels).nil?) || ((rule_labels).nil? && (r.attr_rule_list_labels).nil?))
      if (!(token_labels).nil?)
        assert_equals(token_labels, r.attr_token_list_labels.key_set)
      end
      if (!(rule_labels).nil?)
        assert_equals(rule_labels, r.attr_rule_list_labels.key_set)
      end
    end
    
    typesig { [Grammar, String, String] }
    def check_symbols(g, rules_str, tokens_str)
      tokens = g.get_token_display_names
      # make sure expected tokens are there
      st = StringTokenizer.new(tokens_str, ", ")
      while (st.has_more_tokens)
        token_name = st.next_token
        assert_true("token " + token_name + " expected", !(g.get_token_type(token_name)).equal?(Label::INVALID))
        tokens.remove(token_name)
      end
      # make sure there are not any others (other than <EOF> etc...)
      iter = tokens.iterator
      while iter.has_next
        token_name = iter.next_
        assert_true("unexpected token name " + token_name, g.get_token_type(token_name) < Label::MIN_TOKEN_TYPE)
      end
      # make sure all expected rules are there
      st = StringTokenizer.new(rules_str, ", ")
      n = 0
      while (st.has_more_tokens)
        rule_name = st.next_token
        assert_not_null("rule " + rule_name + " expected", g.get_rule(rule_name))
        n += 1
      end
      rules = g.get_rules
      # System.out.println("rules="+rules);
      # make sure there are no extra rules
      assert_equals("number of rules mismatch; expecting " + RJava.cast_to_string(n) + "; found " + RJava.cast_to_string(rules.size), n, rules.size)
    end
    
    private
    alias_method :initialize__test_symbol_definitions, :initialize
  end
  
end
