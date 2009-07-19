require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2008 Terence Parr
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
  module TestMessagesImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Codegen, :ActionTranslator
      include ::Org::Antlr::Tool
    }
  end
  
  class TestMessages < TestMessagesImports.const_get :BaseTest
    include_class_members TestMessagesImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_message_stringification_is_consistent
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
      expected_message_string = expected_message.to_s
      assert_equals(expected_message_string, expected_message.to_s)
    end
    
    private
    alias_method :initialize__test_messages, :initialize
  end
  
end
