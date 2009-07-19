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
  module TestRewriteTemplatesImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Tool, :ErrorManager
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  class TestRewriteTemplates < TestRewriteTemplatesImports.const_get :BaseTest
    include_class_members TestRewriteTemplatesImports
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    typesig { [] }
    def test_delete
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : ID INT -> ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("", found)
    end
    
    typesig { [] }
    def test_action
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : ID INT -> {new StringTemplate($ID.text)} ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_embedded_literal_constructor
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : ID INT -> {%{$ID.text}} ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("abc\n", found)
    end
    
    typesig { [] }
    def test_inline_template
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : ID INT -> template(x={$ID},y={$INT}) <<x:<x.text>, y:<y.text>;>> ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("x:abc, y:34;\n", found)
    end
    
    typesig { [] }
    def test_named_template
      # the support code adds template group in it's output Test.java
      # that defines template foo.
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : ID INT -> foo(x={$ID.text},y={$INT.text}) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_indirect_template
      # the support code adds template group in it's output Test.java
      # that defines template foo.
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : ID INT -> ({\"foo\"})(x={$ID.text},y={$INT.text}) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_inline_template_invoking_lib
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : ID INT -> template(x={$ID.text},y={$INT.text}) \"<foo(...)>\" ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_predicated_alts
      # the support code adds template group in it's output Test.java
      # that defines template foo.
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : ID INT -> {false}? foo(x={$ID.text},y={$INT.text})\n" + "           -> foo(x={\"hi\"}, y={$ID.text})\n" + "  ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("hi abc\n", found)
    end
    
    typesig { [] }
    def test_template_return
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : b {System.out.println($b.st);} ;\n" + "b : ID INT -> foo(x={$ID.text},y={$INT.text}) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("abc 34\n", found)
    end
    
    typesig { [] }
    def test_return_value_with_template
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a : b {System.out.println($b.i);} ;\n" + "b returns [int i] : ID INT {$i=8;} ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("8\n", found)
    end
    
    typesig { [] }
    def test_template_ref_to_dynamic_attributes
      grammar = "grammar T;\n" + "options {output=template;}\n" + "a scope {String id;} : ID {$a::id=$ID.text;} b\n" + "	{System.out.println($b.st.toString());}\n" + "   ;\n" + "b : INT -> foo(x={$a::id}) ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "a", "abc 34", @debug)
      assert_equals("abc \n", found)
    end
    
    typesig { [] }
    # tests for rewriting templates in tree parsers
    def test_single_node
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {ASTLabelType=CommonTree; output=template;}\n" + "s : a {System.out.println($a.st);} ;\n" + "a : ID -> template(x={$ID.text}) <<|<x>|>> ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc")
      assert_equals("|abc|\n", found)
    end
    
    typesig { [] }
    def test_single_node_rewrite_mode
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "a : ID ;\n" + "ID : 'a'..'z'+ ;\n" + "INT : '0'..'9'+;\n" + "WS : (' '|'\\n') {$channel=HIDDEN;} ;\n"
      tree_grammar = "tree grammar TP;\n" + "options {ASTLabelType=CommonTree; output=template; rewrite=true;}\n" + "s : a {System.out.println(input.getTokenStream().toString(0,0));} ;\n" + "a : ID -> template(x={$ID.text}) <<|<x>|>> ;\n"
      found = exec_tree_parser("T.g", grammar, "TParser", "TP.g", tree_grammar, "TP", "TLexer", "a", "s", "abc")
      assert_equals("|abc|\n", found)
    end
    
    typesig { [] }
    def test_rewrite_rule_and_rewrite_mode_on_simple_elements
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("tree grammar TP;\n" + "options {ASTLabelType=CommonTree; output=template; rewrite=true;}\n" + "a: ^(A B) -> {ick}\n" + " | y+=INT -> {ick}\n" + " | x=ID -> {ick}\n" + " | BLORT -> {ick}\n" + " ;\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_warnings.size)
    end
    
    typesig { [] }
    def test_rewrite_rule_and_rewrite_mode_ignore_actions_predicates
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("tree grammar TP;\n" + "options {ASTLabelType=CommonTree; output=template; rewrite=true;}\n" + "a: {action} {action2} x=A -> {ick}\n" + " | {pred1}? y+=B -> {ick}\n" + " | C {action} -> {ick}\n" + " | {pred2}?=> z+=D -> {ick}\n" + " | (E)=> ^(F G) -> {ick}\n" + " ;\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_warnings.size)
    end
    
    typesig { [] }
    def test_rewrite_rule_and_rewrite_mode_not_simple
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("tree grammar TP;\n" + "options {ASTLabelType=CommonTree; output=template; rewrite=true;}\n" + "a  : ID+ -> {ick}\n" + "   | INT INT -> {ick}\n" + "   ;\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      assert_equals("unexpected errors: " + (equeue).to_s, 2, equeue.attr_warnings.size)
    end
    
    typesig { [] }
    def test_rewrite_rule_and_rewrite_mode_ref_rule
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("tree grammar TP;\n" + "options {ASTLabelType=CommonTree; output=template; rewrite=true;}\n" + "a  : b+ -> {ick}\n" + "   | b b A -> {ick}\n" + "   ;\n" + "b  : B ;\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      assert_equals("unexpected errors: " + (equeue).to_s, 2, equeue.attr_warnings.size)
    end
    
    typesig { [] }
    def initialize
      @debug = false
      super()
      @debug = false
    end
    
    private
    alias_method :initialize__test_rewrite_templates, :initialize
  end
  
end
