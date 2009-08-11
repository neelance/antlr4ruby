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
  module TestAttributesImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Codegen, :ActionTranslator
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateGroup
      include_const ::Org::Antlr::Stringtemplate::Language, :AngleBracketTemplateLexer
      include ::Org::Antlr::Tool
      include_const ::Java::Io, :StringReader
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :JavaList
    }
  end
  
  # Check the $x, $x.y attributes.  For checking the actual
  # translation, assume the Java target.  This is still a great test
  # for the semantics of the $x.y stuff regardless of the target.
  class TestAttributes < TestAttributesImports.const_get :BaseTest
    include_class_members TestAttributesImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_escaped_less_than_in_action
      g = Grammar.new
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      action = "i<3; '<xmltag>'"
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 0)
      expecting = action
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, "<action>")
      action_st.set_attribute("action", raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_escaped$in_action
      action = "int \\$n; \"\\$in string\\$\""
      expecting = "int $n; \"$in string$\""
      g = Grammar.new("parser grammar t;\n" + "@members {" + action + "}\n" + "a[User u, int i]\n" + "        : {" + action + "}\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 0)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_arguments
      action = "$i; $i.x; $u; $u.x"
      expecting = "i; i.x; u; u.x"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a[User u, int i]\n" + "        : {" + action + "}\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_complicated_arg_parsing
      action = "x, (*a).foo(21,33), 3.2+1, '\\n', " + "\"a,oo\\nick\", {bl, \"fdkj\"eck}"
      expecting = "x, (*a).foo(21,33), 3.2+1, '\\n', \"a,oo\\nick\", {bl, \"fdkj\"eck}"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # now check in actual grammar.
      g = Grammar.new("parser grammar t;\n" + "a[User u, int i]\n" + "        : A a[" + action + "] B\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      assert_equals(expecting, raw_translation)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_bracket_arg_parsing
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # now check in actual grammar.
      g = Grammar.new("parser grammar t;\n" + "a[String[\\] ick, int i]\n" + "        : A \n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      r = g.get_rule("a")
      parameters = r.attr_parameter_scope
      attrs = parameters.get_attributes
      assert_equals("attribute mismatch", "String[] ick", attrs.get(0).attr_decl.to_s)
      assert_equals("parameter name mismatch", "ick", attrs.get(0).attr_name)
      assert_equals("declarator mismatch", "String[]", attrs.get(0).attr_type)
      assert_equals("attribute mismatch", "int i", attrs.get(1).attr_decl.to_s)
      assert_equals("parameter name mismatch", "i", attrs.get(1).attr_name)
      assert_equals("declarator mismatch", "int", attrs.get(1).attr_type)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_string_arg_parsing
      action = "34, '{', \"it's<\", '\"', \"\\\"\", 19"
      expecting = "34, '{', \"it's<\", '\"', \"\\\"\", 19"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # now check in actual grammar.
      g = Grammar.new("parser grammar t;\n" + "a[User u, int i]\n" + "        : A a[" + action + "] B\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      assert_equals(expecting, raw_translation)
      add("34")
      add("'{'")
      add("\"it's<\"")
      add("'\"'")
      add("\"\\\"\"") # that's "\""
      add("19")
      expect_args = Class.new(ArrayList.class == Class ? ArrayList : Object) do
        extend LocalClass
        include_class_members TestAttributes
        include ArrayList if ArrayList.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      actual_args = CodeGenerator.get_list_of_arguments_from_action(action, Character.new(?,.ord))
      assert_equals("args mismatch", expect_args, actual_args)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_complicated_single_arg_parsing
      action = "(*a).foo(21,33,\",\")"
      expecting = "(*a).foo(21,33,\",\")"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # now check in actual grammar.
      g = Grammar.new("parser grammar t;\n" + "a[User u, int i]\n" + "        : A a[" + action + "] B\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      assert_equals(expecting, raw_translation)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_arg_with_lt
      action = "34<50"
      expecting = "34<50"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # now check in actual grammar.
      g = Grammar.new("parser grammar t;\n" + "a[boolean b]\n" + "        : A a[" + action + "] B\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      assert_equals(expecting, raw_translation)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_generics_as_argument_definition
      action = "$foo.get(\"ick\");"
      expecting = "foo.get(\"ick\");"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "parser grammar T;\n" + "a[HashMap<String,String> foo]\n" + "        : {" + action + "}\n" + "        ;"
      g = Grammar.new(grammar)
      ra = g.get_rule("a")
      attrs = ra.attr_parameter_scope.get_attributes
      assert_equals("attribute mismatch", "HashMap<String,String> foo", attrs.get(0).attr_decl.to_s)
      assert_equals("parameter name mismatch", "foo", attrs.get(0).attr_name)
      assert_equals("declarator mismatch", "HashMap<String,String>", attrs.get(0).attr_type)
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_generics_as_argument_definition2
      action = "$foo.get(\"ick\"); x=3;"
      expecting = "foo.get(\"ick\"); x=3;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "parser grammar T;\n" + "a[HashMap<String,String> foo, int x, List<String> duh]\n" + "        : {" + action + "}\n" + "        ;"
      g = Grammar.new(grammar)
      ra = g.get_rule("a")
      attrs = ra.attr_parameter_scope.get_attributes
      assert_equals("attribute mismatch", "HashMap<String,String> foo", attrs.get(0).attr_decl.to_s.trim)
      assert_equals("parameter name mismatch", "foo", attrs.get(0).attr_name)
      assert_equals("declarator mismatch", "HashMap<String,String>", attrs.get(0).attr_type)
      assert_equals("attribute mismatch", "int x", attrs.get(1).attr_decl.to_s.trim)
      assert_equals("parameter name mismatch", "x", attrs.get(1).attr_name)
      assert_equals("declarator mismatch", "int", attrs.get(1).attr_type)
      assert_equals("attribute mismatch", "List<String> duh", attrs.get(2).attr_decl.to_s.trim)
      assert_equals("parameter name mismatch", "duh", attrs.get(2).attr_name)
      assert_equals("declarator mismatch", "List<String>", attrs.get(2).attr_type)
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_generics_as_return_value
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      grammar = "parser grammar T;\n" + "a returns [HashMap<String,String> foo] : ;\n"
      g = Grammar.new(grammar)
      ra = g.get_rule("a")
      attrs = ra.attr_return_scope.get_attributes
      assert_equals("attribute mismatch", "HashMap<String,String> foo", attrs.get(0).attr_decl.to_s)
      assert_equals("parameter name mismatch", "foo", attrs.get(0).attr_name)
      assert_equals("declarator mismatch", "HashMap<String,String>", attrs.get(0).attr_type)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_complicated_arg_parsing_with_translation
      action = "x, $A.text+\"3242\", (*$A).foo(21,33), 3.2+1, '\\n', " + "\"a,oo\\nick\", {bl, \"fdkj\"eck}"
      expecting = "x, (A1!=null?A1.getText():null)+\"3242\", (*A1).foo(21,33), 3.2+1, '\\n', \"a,oo\\nick\", {bl, \"fdkj\"eck}"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # now check in actual grammar.
      g = Grammar.new("parser grammar t;\n" + "a[User u, int i]\n" + "        : A a[" + action + "] B\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    # $x.start refs are checked during translation not before so ANTLR misses
    # the fact that rule r has refs to predefined attributes if the ref is after
    # the def of the method or self-referential.  Actually would be ok if I didn't
    # convert actions to strings; keep as templates.
    # June 9, 2006: made action translation leave templates not strings
    def test_ref_to_return_value_before_ref_to_predefined_attr
      action = "$x.foo"
      expecting = "(x!=null?x.foo:0)"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : x=b {" + action + "} ;\n" + "b returns [int foo] : B {$b.start} ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_label_before_ref_to_predefined_attr
      # As of Mar 2007, I'm removing unused labels.  Unfortunately,
      # the action is not seen until code gen.  Can't see $x.text
      # before stripping unused labels.  We really need to translate
      # actions first so code gen logic can use info.
      action = "$x.text"
      expecting = "(x!=null?input.toString(x.start,x.stop):null)"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : x=b {" + action + "} ;\n" + "b : B ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_invalid_arguments
      action = "$x"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a[User u, int i]\n" + "        : {" + action + "}\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_UNKNOWN_SIMPLE_ATTRIBUTE
      expected_arg = "x"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_return_value
      action = "$x.i"
      expecting = "x"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a returns [int i]\n" + "        : 'a'\n" + "        ;\n" + "b : x=a {" + action + "} ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_return_value_with_number
      action = "$x.i1"
      expecting = "x"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a returns [int i1]\n" + "        : 'a'\n" + "        ;\n" + "b : x=a {" + action + "} ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_return_values
      action = "$i; $i.x; $u; $u.x"
      expecting = "retval.i; retval.i.x; retval.u; retval.u.x"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a returns [User u, int i]\n" + "        : {" + action + "}\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    # regression test for ANTLR-46
    def test_return_with_multiple_rule_refs
      action1 = "$obj = $rule2.obj;"
      action2 = "$obj = $rule3.obj;"
      expecting1 = "obj = rule21;"
      expecting2 = "obj = rule32;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "rule1 returns [ Object obj ]\n" + ":	rule2 { " + action1 + " }\n" + "|	rule3 { " + action2 + " }\n" + ";\n" + "rule2 returns [ Object obj ]\n" + ":	foo='foo' { $obj = $foo.text; }\n" + ";\n" + "rule3 returns [ Object obj ]\n" + ":	bar='bar' { $obj = $bar.text; }\n" + ";")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      i = 0
      action = action1
      expecting = expecting1
      begin
        translator = ActionTranslator.new(generator, "rule1", Antlr::CommonToken.new(ANTLRParser::ACTION, action), i + 1)
        raw_translation = translator.translate
        templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
        action_st = StringTemplate.new(templates, raw_translation)
        found = action_st.to_s
        assert_equals(expecting, found)
        action = action2
        expecting = expecting2
      end while (((i += 1) - 1) < 1)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_invalid_return_values
      action = "$x"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a returns [User u, int i]\n" + "        : {" + action + "}\n" + "        ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_UNKNOWN_SIMPLE_ATTRIBUTE
      expected_arg = "x"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_token_labels
      action = "$id; $f; $id.text; $id.getText(); $id.dork " + "$id.type; $id.line; $id.pos; " + "$id.channel; $id.index;"
      expecting = "id; f; (id!=null?id.getText():null); id.getText(); id.dork (id!=null?id.getType():0); (id!=null?id.getLine():0); (id!=null?id.getCharPositionInLine():0); (id!=null?id.getChannel():0); (id!=null?id.getTokenIndex():0);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : id=ID f=FLOAT {" + action + "}\n" + "  ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_labels
      action = "$r.x; $r.start;\r\n $r.stop;\r\n $r.tree; $a.x; $a.stop;"
      expecting = "(r!=null?r.x:0); (r!=null?((Token)r.start):null);\r\n" + "             (r!=null?((Token)r.stop):null);\r\n" + "             (r!=null?((Object)r.tree):null); (r!=null?r.x:0); (r!=null?((Token)r.stop):null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a returns [int x]\n" + "  :\n" + "  ;\n" + "b : r=a {###" + action + "!!!}\n" + "  ;")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # codegen phase sets some vars we need
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_ambigu_rule_ref
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : A a {$a.text} | B ;")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      # error(132): <string>:2:9: reference $a is ambiguous; rule a is enclosing rule and referenced in the production
      assert_equals("unexpected errors: " + (equeue).to_s, 1, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_labels_with_special_token
      action = "$r.x; $r.start; $r.stop; $r.tree; $a.x; $a.stop;"
      expecting = "(r!=null?r.x:0); (r!=null?((MYTOKEN)r.start):null); (r!=null?((MYTOKEN)r.stop):null); (r!=null?((Object)r.tree):null); (r!=null?r.x:0); (r!=null?((MYTOKEN)r.stop):null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "options {TokenLabelType=MYTOKEN;}\n" + "a returns [int x]\n" + "  :\n" + "  ;\n" + "b : r=a {###" + action + "!!!}\n" + "  ;")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # codegen phase sets some vars we need
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_forward_ref_rule_labels
      action = "$r.x; $r.start; $r.stop; $r.tree; $a.x; $a.tree;"
      expecting = "(r!=null?r.x:0); (r!=null?((Token)r.start):null); (r!=null?((Token)r.stop):null); (r!=null?((Object)r.tree):null); (r!=null?r.x:0); (r!=null?((Object)r.tree):null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "b : r=a {###" + action + "!!!}\n" + "  ;\n" + "a returns [int x]\n" + "  : ;\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # codegen phase sets some vars we need
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_invalid_rule_label_accesses_parameter
      action = "$r.z"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a[int z] returns [int x]\n" + "  :\n" + "  ;\n" + "b : r=a[3] {" + action + "}\n" + "  ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_INVALID_RULE_PARAMETER_REF
      expected_arg = "a"
      expected_arg2 = "z"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_invalid_rule_label_accesses_scope_attribute
      action = "$r.n"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a\n" + "scope { int n; }\n" + "  :\n" + "  ;\n" + "b : r=a[3] {" + action + "}\n" + "  ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_INVALID_RULE_SCOPE_ATTRIBUTE_REF
      expected_arg = "a"
      expected_arg2 = "n"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_invalid_rule_attribute
      action = "$r.blort"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a[int z] returns [int x]\n" + "  :\n" + "  ;\n" + "b : r=a[3] {" + action + "}\n" + "  ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_UNKNOWN_RULE_ATTRIBUTE
      expected_arg = "a"
      expected_arg2 = "blort"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_missing_rule_attribute
      action = "$r"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a[int z] returns [int x]\n" + "  :\n" + "  ;\n" + "b : r=a[3] {" + action + "}\n" + "  ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      expected_msg_id = ErrorManager::MSG_ISOLATED_RULE_SCOPE
      expected_arg = "r"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_missing_unlabeled_rule_attribute
      action = "$a"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a returns [int x]:\n" + "  ;\n" + "b : a {" + action + "}\n" + "  ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      expected_msg_id = ErrorManager::MSG_ISOLATED_RULE_SCOPE
      expected_arg = "a"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_non_dynamic_attribute_outside_rule
      action = "public void foo() { $x; }"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "@members {'+action+'}\n" + "a : ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, nil, Antlr::CommonToken.new(ANTLRParser::ACTION, action), 0)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_ATTRIBUTE_REF_NOT_IN_RULE
      expected_arg = "x"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_non_dynamic_attribute_outside_rule2
      action = "public void foo() { $x.y; }"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "@members {'+action+'}\n" + "a : ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, nil, Antlr::CommonToken.new(ANTLRParser::ACTION, action), 0)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_ATTRIBUTE_REF_NOT_IN_RULE
      expected_arg = "x"
      expected_arg2 = "y"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    # D Y N A M I C A L L Y  S C O P E D  A T T R I B U T E S
    def test_basic_global_scope
      action = "$Symbols::names.add($id.text);"
      expecting = "((Symbols_scope)Symbols_stack.peek()).names.add((id!=null?id.getText():null));"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope Symbols {\n" + "  int n;\n" + "  List names;\n" + "}\n" + "a scope Symbols; : (id=ID ';' {" + action + "} )+\n" + "  ;\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_unknown_global_scope
      action = "$Symbols::names.add($id.text);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a scope Symbols; : (id=ID ';' {" + action + "} )+\n" + "  ;\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      assert_equals("unexpected errors: " + (equeue).to_s, 2, equeue.attr_errors.size)
      expected_msg_id = ErrorManager::MSG_UNKNOWN_DYNAMIC_SCOPE
      expected_arg = "Symbols"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_indexed_global_scope
      action = "$Symbols[-1]::names.add($id.text);"
      expecting = "((Symbols_scope)Symbols_stack.elementAt(Symbols_stack.size()-1-1)).names.add((id!=null?id.getText():null));"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope Symbols {\n" + "  int n;\n" + "  List names;\n" + "}\n" + "a scope Symbols; : (id=ID ';' {" + action + "} )+\n" + "  ;\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test0_indexed_global_scope
      action = "$Symbols[0]::names.add($id.text);"
      expecting = "((Symbols_scope)Symbols_stack.elementAt(0)).names.add((id!=null?id.getText():null));"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope Symbols {\n" + "  int n;\n" + "  List names;\n" + "}\n" + "a scope Symbols; : (id=ID ';' {" + action + "} )+\n" + "  ;\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      assert_equals(expecting, raw_translation)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_absolute_indexed_global_scope
      action = "$Symbols[3]::names.add($id.text);"
      expecting = "((Symbols_scope)Symbols_stack.elementAt(3)).names.add((id!=null?id.getText():null));"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope Symbols {\n" + "  int n;\n" + "  List names;\n" + "}\n" + "a scope Symbols; : (id=ID ';' {" + action + "} )+\n" + "  ;\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      assert_equals(expecting, raw_translation)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_scope_and_attribute_with_underscore
      action = "$foo_bar::a_b;"
      expecting = "((foo_bar_scope)foo_bar_stack.peek()).a_b;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope foo_bar {\n" + "  int a_b;\n" + "}\n" + "a scope foo_bar; : (ID {" + action + "} )+\n" + "  ;\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_shared_global_scope
      action = "$Symbols::x;"
      expecting = "((Symbols_scope)Symbols_stack.peek()).x;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope Symbols {\n" + "  String x;\n" + "}\n" + "a\n" + "scope { int y; }\n" + "scope Symbols;\n" + " : b {" + action + "}\n" + " ;\n" + "b : ID {$Symbols::x=$ID.text} ;\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_global_scope_outside_rule
      action = "public void foo() {$Symbols::names.add('foo');}"
      expecting = "public void foo() {((Symbols_scope)Symbols_stack.peek()).names.add('foo');}"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope Symbols {\n" + "  int n;\n" + "  List names;\n" + "}\n" + "@members {'+action+'}\n" + "a : \n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_scope_outside_rule
      action = "public void foo() {$a::name;}"
      expecting = "public void foo() {((a_scope)a_stack.peek()).name;}"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "@members {" + action + "}\n" + "a\n" + "scope { String name; }\n" + "  : {foo();}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, nil, Antlr::CommonToken.new(ANTLRParser::ACTION, action), 0)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_basic_rule_scope
      action = "$a::n;"
      expecting = "((a_scope)a_stack.peek()).n;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a\n" + "scope {\n" + "  int n;\n" + "} : {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_unqualified_rule_scope_access_inside_rule
      action = "$n;"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a\n" + "scope {\n" + "  int n;\n" + "} : {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      expected_msg_id = ErrorManager::MSG_ISOLATED_RULE_ATTRIBUTE
      expected_arg = "n"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_isolated_dynamic_rule_scope_ref
      action = "$a;" # refers to stack not top of stack
      expecting = "a_stack;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a\n" + "scope {\n" + "  int n;\n" + "} : b ;\n" + "b : {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_dynamic_rule_scope_ref_in_subrule
      action = "$a::n;"
      expecting = "((a_scope)a_stack.peek()).n;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a\n" + "scope {\n" + "  float n;\n" + "} : b ;\n" + "b : {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_isolated_global_scope_ref
      action = "$Symbols;"
      expecting = "Symbols_stack;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope Symbols {\n" + "  String x;\n" + "}\n" + "a\n" + "scope { int y; }\n" + "scope Symbols;\n" + " : b {" + action + "}\n" + " ;\n" + "b : ID {$Symbols::x=$ID.text} ;\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_scope_from_another_rule
      action = "$a::n;" # must be qualified
      expecting = "((a_scope)a_stack.peek()).n;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a\n" + "scope {\n" + "  boolean n;\n" + "} : b\n" + "  ;\n" + "b : {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_fully_qualified_ref_to_current_rule_parameter
      action = "$a.i;"
      expecting = "i;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a[int i]: {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_fully_qualified_ref_to_current_rule_ret_val
      action = "$a.i;"
      expecting = "retval.i;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a returns [int i, int j]: {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_set_fully_qualified_ref_to_current_rule_ret_val
      action = "$a.i = 1;"
      expecting = "retval.i = 1;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a returns [int i, int j]: {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_isolated_ref_to_current_rule
      action = "$a;"
      expecting = ""
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : 'a' {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      expected_msg_id = ErrorManager::MSG_ISOLATED_RULE_SCOPE
      expected_arg = "a"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_isolated_ref_to_rule
      action = "$x;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : x=b {" + action + "}\n" + "  ;\n" + "b : 'b' ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      expected_msg_id = ErrorManager::MSG_ISOLATED_RULE_SCOPE
      expected_arg = "x"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    # I think these have to be errors $a.x makes no sense.
    # public void testFullyQualifiedRefToLabelInCurrentRule() throws Exception {
    # String action = "$a.x;";
    # String expecting = "x;";
    # 
    # ErrorQueue equeue = new ErrorQueue();
    # ErrorManager.setErrorListener(equeue);
    # Grammar g = new Grammar(
    # "grammar t;\n"+
    # "a : x='a' {"+action+"}\n" +
    # "  ;\n");
    # Tool antlr = newTool();
    # CodeGenerator generator = new CodeGenerator(antlr, g, "Java");
    # g.setCodeGenerator(generator);
    # generator.genRecognizer(); // forces load of templates
    # ActionTranslator translator = new ActionTranslator(generator,"a",
    # new antlr.CommonToken(ANTLRParser.ACTION,action),1);
    # String rawTranslation =
    # translator.translate();
    # StringTemplateGroup templates =
    # new StringTemplateGroup(".", AngleBracketTemplateLexer.class);
    # StringTemplate actionST = new StringTemplate(templates, rawTranslation);
    # String found = actionST.toString();
    # assertEquals(expecting, found);
    # 
    # assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
    # }
    # 
    # public void testFullyQualifiedRefToListLabelInCurrentRule() throws Exception {
    # String action = "$a.x;"; // must be qualified
    # String expecting = "list_x;";
    # 
    # ErrorQueue equeue = new ErrorQueue();
    # ErrorManager.setErrorListener(equeue);
    # Grammar g = new Grammar(
    # "grammar t;\n"+
    # "a : x+='a' {"+action+"}\n" +
    # "  ;\n");
    # Tool antlr = newTool();
    # CodeGenerator generator = new CodeGenerator(antlr, g, "Java");
    # g.setCodeGenerator(generator);
    # generator.genRecognizer(); // forces load of templates
    # ActionTranslator translator = new ActionTranslator(generator,"a",
    # new antlr.CommonToken(ANTLRParser.ACTION,action),1);
    # String rawTranslation =
    # translator.translate();
    # StringTemplateGroup templates =
    # new StringTemplateGroup(".", AngleBracketTemplateLexer.class);
    # StringTemplate actionST = new StringTemplate(templates, rawTranslation);
    # String found = actionST.toString();
    # assertEquals(expecting, found);
    # 
    # assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
    # }
    def test_fully_qualified_ref_to_template_attribute_in_current_rule
      action = "$a.st;" # can be qualified
      expecting = "retval.st;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "options {output=template;}\n" + "a : (A->{$A.text}) {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_ref_when_rule_has_scope
      action = "$b.start;"
      expecting = "(b1!=null?((Token)b1.start):null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : b {###" + action + "!!!} ;\n" + "b\n" + "scope {\n" + "  int n;\n" + "} : 'b' \n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_dynamic_scope_ref_ok_even_though_rule_ref_exists
      action = "$b::n;"
      expecting = "((b_scope)b_stack.peek()).n;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # refers to current invocation's n
      g = Grammar.new("grammar t;\n" + "s : b ;\n" + "b\n" + "scope {\n" + "  int n;\n" + "} : '(' b ')' {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_ref_to_template_attribute_for_current_rule
      action = "$st=null;"
      expecting = "retval.st =null;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "options {output=template;}\n" + "a : {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_ref_to_text_attribute_for_current_rule
      action = "$text"
      expecting = "input.toString(retval.start,input.LT(-1))"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "options {output=template;}\n" + "a : {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_ref_to_start_attribute_for_current_rule
      action = "$start;"
      expecting = "((Token)retval.start);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : {###" + action + "!!!}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_token_label_from_multiple_alts
      action = "$ID.text;" # must be qualified
      action2 = "$INT.text;" # must be qualified
      expecting = "(ID1!=null?ID1.getText():null);"
      expecting2 = "(INT2!=null?INT2.getText():null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ID {" + action + "}\n" + "  | INT {" + action2 + "}\n" + "  ;\n" + "ID : 'a';\n" + "INT : '0';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action2), 2)
      raw_translation = (translator.translate).to_s
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = (action_st.to_s).to_s
      assert_equals(expecting2, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_label_from_multiple_alts
      action = "$b.text;" # must be qualified
      action2 = "$c.text;" # must be qualified
      expecting = "(b1!=null?input.toString(b1.start,b1.stop):null);"
      expecting2 = "(c2!=null?input.toString(c2.start,c2.stop):null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : b {" + action + "}\n" + "  | c {" + action2 + "}\n" + "  ;\n" + "b : 'a';\n" + "c : '0';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action2), 2)
      raw_translation = (translator.translate).to_s
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = (action_st.to_s).to_s
      assert_equals(expecting2, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_unknown_dynamic_attribute
      action = "$a::x"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a\n" + "scope {\n" + "  int n;\n" + "} : {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_UNKNOWN_DYNAMIC_SCOPE_ATTRIBUTE
      expected_arg = "a"
      expected_arg2 = "x"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_unknown_global_dynamic_attribute
      action = "$Symbols::x"
      expecting = action
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "scope Symbols {\n" + "  int n;\n" + "}\n" + "a : {'+action+'}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_UNKNOWN_DYNAMIC_SCOPE_ATTRIBUTE
      expected_arg = "Symbols"
      expected_arg2 = "x"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_unqualified_rule_scope_attribute
      action = "$n;" # must be qualified
      expecting = "$n;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a\n" + "scope {\n" + "  int n;\n" + "} : b\n" + "  ;\n" + "b : {'+action+'}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_UNKNOWN_SIMPLE_ATTRIBUTE
      expected_arg = "n"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_and_token_label_type_mismatch
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : id='foo' id=b\n" + "  ;\n" + "b : ;\n")
      expected_msg_id = ErrorManager::MSG_LABEL_TYPE_CONFLICT
      expected_arg = "id"
      expected_arg2 = "rule!=token"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_list_and_token_label_type_mismatch
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ids+='a' ids='b'\n" + "  ;\n" + "b : ;\n")
      expected_msg_id = ErrorManager::MSG_LABEL_TYPE_CONFLICT
      expected_arg = "ids"
      expected_arg2 = "token!=token-list"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_list_and_rule_label_type_mismatch
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {output=AST;}\n" + "a : bs+=b bs=b\n" + "  ;\n" + "b : 'b';\n")
      expected_msg_id = ErrorManager::MSG_LABEL_TYPE_CONFLICT
      expected_arg = "bs"
      expected_arg2 = "rule!=rule-list"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_arg_return_value_mismatch
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a[int i] returns [int x, int i]\n" + "  : \n" + "  ;\n" + "b : ;\n")
      expected_msg_id = ErrorManager::MSG_ARG_RETVAL_CONFLICT
      expected_arg = "i"
      expected_arg2 = "a"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_simple_plus_equal_label
      action = "$ids.size();" # must be qualified
      expecting = "list_ids.size();"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("parser grammar t;\n" + "a : ids+=ID ( COMMA ids+=ID {" + action + "})* ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_plus_equal_string_label
      action = "$ids.size();" # must be qualified
      expecting = "list_ids.size();"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ids+='if' ( ',' ids+=ID {" + action + "})* ;" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_plus_equal_set_label
      action = "$ids.size();" # must be qualified
      expecting = "list_ids.size();"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ids+=('a'|'b') ( ',' ids+=ID {" + action + "})* ;" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_plus_equal_wildcard_label
      action = "$ids.size();" # must be qualified
      expecting = "list_ids.size();"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ids+=. ( ',' ids+=ID {" + action + "})* ;" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_implicit_token_label
      action = "$ID; $ID.text; $ID.getText()"
      expecting = "ID1; (ID1!=null?ID1.getText():null); ID1.getText()"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ID {" + action + "} ;" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_implicit_rule_label
      action = "$r.start;"
      expecting = "(r1!=null?((Token)r1.start):null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : r {###" + action + "!!!} ;" + "r : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_reuse_existing_label_with_implicit_rule_label
      action = "$r.start;"
      expecting = "(x!=null?((Token)x.start):null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : x=r {###" + action + "!!!} ;" + "r : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_reuse_existing_list_label_with_implicit_rule_label
      action = "$r.start;"
      expecting = "(x!=null?((Token)x.start):null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {output=AST;}\n" + "a : x+=r {###" + action + "!!!} ;" + "r : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_reuse_existing_label_with_implicit_token_label
      action = "$ID.text;"
      expecting = "(x!=null?x.getText():null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : x=ID {" + action + "} ;" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_reuse_existing_list_label_with_implicit_token_label
      action = "$ID.text;"
      expecting = "(x!=null?x.getText():null);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : x+=ID {" + action + "} ;" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_rule_label_without_output_option
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar T;\n" + "s : x+=a ;" + "a : 'a';\n" + "b : 'b';\n" + "WS : ' '|'\n';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_LIST_LABEL_INVALID_UNLESS_RETVAL_STRUCT
      expected_arg = "x"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_label_on_two_different_rules_ast
      grammar = "grammar T;\n" + "options {output=AST;}\n" + "s : x+=a x+=b {System.out.println($x);} ;" + "a : 'a';\n" + "b : 'b';\n" + "WS : (' '|'\n') {skip();};\n"
      expecting = "[a, b]\na b\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "a b", false)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_rule_label_on_two_different_rules_template
      grammar = "grammar T;\n" + "options {output=template;}\n" + "s : x+=a x+=b {System.out.println($x);} ;" + "a : 'a' -> {%{\"hi\"}} ;\n" + "b : 'b' -> {%{\"mom\"}} ;\n" + "WS : (' '|'\n') {skip();};\n"
      expecting = "[hi, mom]\n"
      found = exec_parser("T.g", grammar, "TParser", "TLexer", "s", "a b", false)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_missing_args
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : r ;" + "r[int i] : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_MISSING_RULE_ARGS
      expected_arg = "r"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_args_when_none_defined
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : r[32,34] ;" + "r : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_RULE_HAS_NO_ARGS
      expected_arg = "r"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_return_init_value
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : r ;\n" + "r returns [int x=0] : 'a' {$x = 4;} ;\n")
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
      r = g.get_rule("r")
      ret_scope = r.attr_return_scope
      parameters = ret_scope.get_attributes
      assert_not_null("missing return action", parameters)
      assert_equals(1, parameters.size)
      found = parameters.get(0).to_s
      expecting = "int x=0"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_multiple_return_init_value
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : r ;\n" + "r returns [int x=0, int y, String s=new String(\"foo\")] : 'a' {$x = 4;} ;\n")
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
      r = g.get_rule("r")
      ret_scope = r.attr_return_scope
      parameters = ret_scope.get_attributes
      assert_not_null("missing return action", parameters)
      assert_equals(3, parameters.size)
      assert_equals("int x=0", parameters.get(0).to_s)
      assert_equals("int y", parameters.get(1).to_s)
      assert_equals("String s=new String(\"foo\")", parameters.get(2).to_s)
    end
    
    typesig { [] }
    def test_cstyle_return_init_value
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : r ;\n" + "r returns [int (*x)()=NULL] : 'a' ;\n")
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
      r = g.get_rule("r")
      ret_scope = r.attr_return_scope
      parameters = ret_scope.get_attributes
      assert_not_null("missing return action", parameters)
      assert_equals(1, parameters.size)
      found = parameters.get(0).to_s
      expecting = "int (*)() x=NULL"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_args_with_init_values
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : r[32,34] ;" + "r[int x, int y=3] : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_ARG_INIT_VALUES_ILLEGAL
      expected_arg = "y"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_args_on_token
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ID[32,34] ;" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_ARGS_ON_TOKEN_REF
      expected_arg = "ID"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_args_on_token_in_lexer
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : 'z' ID[32,34] ;" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_RULE_HAS_NO_ARGS
      expected_arg = "ID"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_label_on_rule_ref_in_lexer
      action = "$i.text"
      expecting = "(i!=null?i.getText():null)"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : 'z' i=ID {" + action + "};" + "fragment ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "R", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_ref_to_rule_ref_in_lexer
      action = "$ID.text"
      expecting = "(ID1!=null?ID1.getText():null)"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : 'z' ID {" + action + "};" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "R", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_ref_to_rule_ref_in_lexer_no_attribute
      action = "$ID"
      expecting = "ID1"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : 'z' ID {" + action + "};" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "R", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_char_label_in_lexer
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : x='z' ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_char_list_label_in_lexer
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : x+='z' ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_wildcard_char_label_in_lexer
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : x=. ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_wildcard_char_list_label_in_lexer
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : x+=. ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_missing_args_in_lexer
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "A : R ;" + "R[int i] : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_MISSING_RULE_ARGS
      expected_arg = "R"
      expected_arg2 = nil
      # getting a second error @1:12, probably from nextToken
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_lexer_rule_property_refs
      action = "$text $type $line $pos $channel $index $start $stop"
      expecting = "getText() _type state.tokenStartLine state.tokenStartCharPositionInLine _channel -1 state.tokenStartCharIndex (getCharIndex()-1)"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : 'r' {" + action + "};\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "R", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_lexer_label_refs
      action = "$a $b.text $c $d.text"
      expecting = "a (b!=null?b.getText():null) c (d!=null?d.getText():null)"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : a='c' b='hi' c=. d=DUH {" + action + "};\n" + "DUH : 'd' ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "R", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_setting_lexer_rule_property_refs
      action = "$text $type=1 $line=1 $pos=1 $channel=1 $index"
      expecting = "getText() _type=1 state.tokenStartLine=1 state.tokenStartCharPositionInLine=1 _channel=1 -1"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar t;\n" + "R : 'r' {" + action + "};\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "R", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_args_on_token_in_lexer_rule_of_combined
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : R;\n" + "R : 'z' ID[32] ;\n" + "ID : 'a';\n")
      lexer_grammar_str = g.get_lexer_grammar
      sr = StringReader.new(lexer_grammar_str)
      lexer_grammar = Grammar.new
      lexer_grammar.set_file_name("<internally-generated-lexer>")
      lexer_grammar.import_token_vocabulary(g)
      lexer_grammar.parse_and_build_ast(sr)
      lexer_grammar.define_grammar_symbols
      lexer_grammar.check_name_space_and_actions
      sr.close
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, lexer_grammar, "Java")
      lexer_grammar.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_RULE_HAS_NO_ARGS
      expected_arg = "ID"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, lexer_grammar, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_missing_args_on_token_in_lexer_rule_of_combined
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : R;\n" + "R : 'z' ID ;\n" + "ID[int i] : 'a';\n")
      lexer_grammar_str = g.get_lexer_grammar
      sr = StringReader.new(lexer_grammar_str)
      lexer_grammar = Grammar.new
      lexer_grammar.set_file_name("<internally-generated-lexer>")
      lexer_grammar.import_token_vocabulary(g)
      lexer_grammar.parse_and_build_ast(sr)
      lexer_grammar.define_grammar_symbols
      lexer_grammar.check_name_space_and_actions
      sr.close
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, lexer_grammar, "Java")
      lexer_grammar.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_MISSING_RULE_ARGS
      expected_arg = "ID"
      expected_arg2 = nil
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, lexer_grammar, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    # T R E E S
    def test_token_label_tree_property
      action = "$id.tree;"
      expecting = "id_tree;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : id=ID {" + action + "} ;\n" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_token_ref_tree_property
      action = "$ID.tree;"
      expecting = "ID1_tree;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ID {" + action + "} ;" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_ambiguous_token_ref
      action = "$ID;"
      expecting = ""
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ID ID {" + action + "};" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_NONUNIQUE_REF
      expected_arg = "ID"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_ambiguous_token_ref_with_prop
      action = "$ID.text;"
      expecting = ""
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "a : ID ID {" + action + "};" + "ID : 'a';\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      expected_msg_id = ErrorManager::MSG_NONUNIQUE_REF
      expected_arg = "ID"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_rule_ref_with_dynamic_scope
      action = "$field::x = $field.st;"
      expecting = "((field_scope)field_stack.peek()).x = retval.st;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "field\n" + "scope { StringTemplate x; }\n" + "    :   'y' {" + action + "}\n" + "    ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "field", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_assign_to_own_rulename_attr
      action = "$rule.tree = null;"
      expecting = "retval.tree = null;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "rule\n" + "    : 'y' {" + action + "}\n" + "    ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "rule", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_assign_to_own_param_attr
      action = "$rule.i = 42; $i = 23;"
      expecting = "i = 42; i = 23;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "rule[int i]\n" + "    : 'y' {" + action + "}\n" + "    ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "rule", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_illegal_assign_to_own_rulename_attr
      action = "$rule.stop = 0;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "rule\n" + "    : 'y' {" + action + "}\n" + "    ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "rule", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      expected_msg_id = ErrorManager::MSG_WRITE_TO_READONLY_ATTR
      expected_arg = "rule"
      expected_arg2 = "stop"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_illegal_assign_to_local_attr
      action = "$tree = null; $st = null; $start = 0; $stop = 0; $text = 0;"
      expecting = "retval.tree = null; retval.st = null;   "
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "rule\n" + "    : 'y' {" + action + "}\n" + "    ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "rule", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      expected_msg_id = ErrorManager::MSG_WRITE_TO_READONLY_ATTR
      expected_errors = ArrayList.new(3)
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, "start", "")
      expected_errors.add(expected_message)
      expected_message2 = GrammarSemanticsMessage.new(expected_msg_id, g, nil, "stop", "")
      expected_errors.add(expected_message2)
      expected_message3 = GrammarSemanticsMessage.new(expected_msg_id, g, nil, "text", "")
      expected_errors.add(expected_message3)
      check_errors(equeue, expected_errors)
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_illegal_assign_rule_ref_attr
      action = "$other.tree = null;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "options { output = AST;}" + "otherrule\n" + "    : 'y' ;" + "rule\n" + "    : other=otherrule {" + action + "}\n" + "    ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "rule", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      expected_msg_id = ErrorManager::MSG_WRITE_TO_READONLY_ATTR
      expected_arg = "other"
      expected_arg2 = "tree"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_illegal_assign_token_ref_attr
      action = "$ID.text = \"test\";"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "ID\n" + "    : 'y' ;" + "rule\n" + "    : ID {" + action + "}\n" + "    ;")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "rule", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      expected_msg_id = ErrorManager::MSG_WRITE_TO_READONLY_ATTR
      expected_arg = "ID"
      expected_arg2 = "text"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_assign_to_tree_node_attribute
      action = "$tree.scope = localScope;"
      expecting = "(()retval.tree).scope = localScope;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "options { output=AST; }" + "rule\n" + "@init {\n" + "   Scope localScope=null;\n" + "}\n" + "@after {\n" + "   $tree.scope = localScope;\n" + "}\n" + "   : 'a' -> ^('a')\n" + ";")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "rule", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_do_not_translate_attribute_compare
      action = "$a.line == $b.line"
      expecting = "(a!=null?a.getLine():0) == (b!=null?b.getLine():0)"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("lexer grammar a;\n" + "RULE:\n" + "     a=ID b=ID {" + action + "}" + "    ;\n" + "ID : 'id';")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      translator = ActionTranslator.new(generator, "RULE", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_do_not_translate_scope_attribute_compare
      action = "if ($rule::foo == \"foo\" || 1) { System.out.println(\"ouch\"); }"
      expecting = "if (((rule_scope)rule_stack.peek()).foo == \"foo\" || 1) { System.out.println(\"ouch\"); }"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar a;\n" + "rule\n" + "scope {\n" + "   String foo;" + "} :\n" + "     twoIDs" + "    ;\n" + "twoIDs:\n" + "    ID ID {" + action + "}\n" + "    ;\n" + "ID : 'id';")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer
      translator = ActionTranslator.new(generator, "twoIDs", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      # check that we didn't use scopeSetAttributeRef int translation!
      found_scope_set_attribute_ref = false
      i = 0
      while i < translator.attr_chunks.size
        chunk = translator.attr_chunks.get(i)
        if (chunk.is_a?(StringTemplate))
          if (((chunk).get_name == "scopeSetAttributeRef"))
            found_scope_set_attribute_ref = true
          end
        end
        i += 1
      end
      assert_false("action translator used scopeSetAttributeRef template in comparison!", found_scope_set_attribute_ref)
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_tree_rule_stop_attribute_is_invalid
      action = "$r.x; $r.start; $r.stop"
      expecting = "(r!=null?r.x:0); (r!=null?((CommonTree)r.start):null); $r.stop"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("tree grammar t;\n" + "options {ASTLabelType=CommonTree;}\n" + "a returns [int x]\n" + "  :\n" + "  ;\n" + "b : r=a {###" + action + "!!!}\n" + "  ;")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # codegen phase sets some vars we need
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      expected_msg_id = ErrorManager::MSG_UNKNOWN_RULE_ATTRIBUTE
      expected_arg = "a"
      expected_arg2 = "stop"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg, expected_arg2)
      System.out.println("equeue:" + (equeue).to_s)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_ref_to_text_attribute_for_current_tree_rule
      action = "$text"
      expecting = "input.getTokenStream().toString(\n" + "              input.getTreeAdaptor().getTokenStartIndex(retval.start),\n" + "              input.getTreeAdaptor().getTokenStopIndex(retval.start))"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("tree grammar t;\n" + "options {ASTLabelType=CommonTree;}\n" + "a : {###" + action + "!!!}\n" + "  ;\n")
      antlr = new_tool
      antlr.set_output_directory(nil) # write to /dev/null
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # codegen phase sets some vars we need
      code_st = generator.get_recognizer_st
      code = code_st.to_s
      found = code.substring(code.index_of("###") + 3, code.index_of("!!!"))
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [] }
    def test_type_of_guarded_attribute_ref_is_correct
      action = "int x = $b::n;"
      expecting = "int x = ((b_scope)b_stack.peek()).n;"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # refers to current invocation's n
      g = Grammar.new("grammar t;\n" + "s : b ;\n" + "b\n" + "scope {\n" + "  int n;\n" + "} : '(' b ')' {" + action + "}\n" + "  ;\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "b", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer.class)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_equals(expecting, found)
      assert_equals("unexpected errors: " + (equeue).to_s, 0, equeue.attr_errors.size)
    end
    
    typesig { [ErrorQueue, GrammarSemanticsMessage] }
    # S U P P O R T
    def check_error(equeue, expected_message)
      # System.out.println(equeue.infos);
      # System.out.println(equeue.warnings);
      # System.out.println(equeue.errors);
      found_msg = nil
      i = 0
      while i < equeue.attr_errors.size
        m = equeue.attr_errors.get(i)
        if ((m.attr_msg_id).equal?(expected_message.attr_msg_id))
          found_msg = m
        end
        i += 1
      end
      assert_true("no error; " + (expected_message.attr_msg_id).to_s + " expected", equeue.attr_errors.size > 0)
      assert_not_null("couldn't find expected error: " + (expected_message.attr_msg_id).to_s + " in " + (equeue).to_s, found_msg)
      assert_true("error is not a GrammarSemanticsMessage", found_msg.is_a?(GrammarSemanticsMessage))
      assert_equals(expected_message.attr_arg, found_msg.attr_arg)
      assert_equals(expected_message.attr_arg2, found_msg.attr_arg2)
    end
    
    typesig { [ErrorQueue, ArrayList] }
    # Allow checking for multiple errors in one test
    def check_errors(equeue, expected_messages)
      message_expected = ArrayList.new(equeue.attr_errors.size)
      i = 0
      while i < equeue.attr_errors.size
        m = equeue.attr_errors.get(i)
        found_msg = false
        j = 0
        while j < expected_messages.size
          em = expected_messages.get(j)
          if ((m.attr_msg_id).equal?(em.attr_msg_id) && (m.attr_arg == em.attr_arg) && (m.attr_arg2 == em.attr_arg2))
            found_msg = true
          end
          j += 1
        end
        if (found_msg)
          message_expected.add(i, Boolean::TRUE)
        else
          message_expected.add(i, Boolean::FALSE)
        end
        i += 1
      end
      i_ = 0
      while i_ < equeue.attr_errors.size
        assert_true("unexpected error:" + (equeue.attr_errors.get(i_)).to_s, (message_expected.get(i_)).boolean_value)
        i_ += 1
      end
    end
    
    private
    alias_method :initialize__test_attributes, :initialize
  end
  
end
