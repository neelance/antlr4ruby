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
  module TestTemplatesImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateGroup
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate::Language, :AngleBracketTemplateLexer
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Codegen, :ActionTranslator
    }
  end
  
  # Test templates in actions; %... shorthands
  class TestTemplates < TestTemplatesImports.const_get :BaseTest
    include_class_members TestTemplatesImports
    
    class_module.module_eval {
      const_set_lazy(:LINE_SEP) { System.get_property("line.separator") }
      const_attr_reader  :LINE_SEP
    }
    
    typesig { [] }
    def test_template_constructor
      action = "x = %foo(name={$ID.text});"
      expecting = "x = templateLib.getInstanceOf(\"foo\"," + LINE_SEP + "  new STAttrMap().put(\"name\", (ID1!=null?ID1.getText():null)));"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "\n" + "a : ID {" + action + "}\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_no_errors(equeue)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_template_constructor_no_args
      action = "x = %foo();"
      expecting = "x = templateLib.getInstanceOf(\"foo\");"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "\n" + "a : ID {" + action + "}\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_no_errors(equeue)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_indirect_template_constructor
      action = "x = %({\"foo\"})(name={$ID.text});"
      expecting = "x = templateLib.getInstanceOf(\"foo\"," + LINE_SEP + "  new STAttrMap().put(\"name\", (ID1!=null?ID1.getText():null)));"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "\n" + "a : ID {" + action + "}\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_no_errors(equeue)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_string_constructor
      action = "x = %{$ID.text};"
      expecting = "x = new StringTemplate(templateLib,(ID1!=null?ID1.getText():null));"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "\n" + "a : ID {" + action + "}\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_no_errors(equeue)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_set_attr
      action = "%x.y = z;"
      expecting = "(x).setAttribute(\"y\", z);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "\n" + "a : ID {" + action + "}\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_no_errors(equeue)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_set_attr_of_expr
      action = "%{foo($ID.text).getST()}.y = z;"
      expecting = "(foo((ID1!=null?ID1.getText():null)).getST()).setAttribute(\"y\", z);"
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "\n" + "a : ID {" + action + "}\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      translator = ActionTranslator.new(generator, "a", Antlr::CommonToken.new(ANTLRParser::ACTION, action), 1)
      raw_translation = translator.translate
      templates = StringTemplateGroup.new(".", AngleBracketTemplateLexer)
      action_st = StringTemplate.new(templates, raw_translation)
      found = action_st.to_s
      assert_no_errors(equeue)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_set_attr_of_expr_in_members
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      # must not get null ptr!
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "@members {\n" + "%code.instr = o;" + "}\n" + "a : ID\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      assert_no_errors(equeue)
    end
    
    typesig { [] }
    def test_cannot_have_space_before_dot
      action = "%x .y = z;"
      expecting = nil
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "\n" + "a : ID {" + action + "}\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      expected_msg_id = ErrorManager::MSG_INVALID_TEMPLATE_ACTION
      expected_arg = "%x"
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [] }
    def test_cannot_have_space_after_dot
      action = "%x. y = z;"
      expecting = nil
      equeue = ErrorQueue.new
      ErrorManager.set_error_listener(equeue)
      g = Grammar.new("grammar t;\n" + "options {\n" + "    output=template;\n" + "}\n" + "\n" + "a : ID {" + action + "}\n" + "  ;\n" + "\n" + "ID : 'a';\n")
      antlr = new_tool
      generator = CodeGenerator.new(antlr, g, "Java")
      g.set_code_generator(generator)
      generator.gen_recognizer # forces load of templates
      expected_msg_id = ErrorManager::MSG_INVALID_TEMPLATE_ACTION
      expected_arg = "%x."
      expected_message = GrammarSemanticsMessage.new(expected_msg_id, g, nil, expected_arg)
      check_error(equeue, expected_message)
    end
    
    typesig { [ErrorQueue, GrammarSemanticsMessage] }
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
      assert_true("no error; " + RJava.cast_to_string(expected_message.attr_msg_id) + " expected", equeue.attr_errors.size > 0)
      assert_true("too many errors; " + RJava.cast_to_string(equeue.attr_errors), equeue.attr_errors.size <= 1)
      assert_true("couldn't find expected error: " + RJava.cast_to_string(expected_message.attr_msg_id), !(found_msg).nil?)
      assert_true("error is not a GrammarSemanticsMessage", found_msg.is_a?(GrammarSemanticsMessage))
      assert_equals(expected_message.attr_arg, found_msg.attr_arg)
      assert_equals(expected_message.attr_arg2, found_msg.attr_arg2)
    end
    
    typesig { [ErrorQueue] }
    # S U P P O R T
    def assert_no_errors(equeue)
      assert_true("unexpected errors: " + RJava.cast_to_string(equeue), (equeue.attr_errors.size).equal?(0))
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_templates, :initialize
  end
  
end
