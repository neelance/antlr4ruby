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
module Org::Antlr::Runtime::Debug
  module ParseTreeBuilderImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :RecognitionException
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime::Tree, :ParseTree
      include_const ::Java::Util, :Stack
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :JavaList
    }
  end
  
  # This parser listener tracks rule entry/exit and token matches
  # to build a simple parse tree using ParseTree nodes.
  class ParseTreeBuilder < ParseTreeBuilderImports.const_get :BlankDebugEventListener
    include_class_members ParseTreeBuilderImports
    
    class_module.module_eval {
      const_set_lazy(:EPSILON_PAYLOAD) { "<epsilon>" }
      const_attr_reader  :EPSILON_PAYLOAD
    }
    
    attr_accessor :call_stack
    alias_method :attr_call_stack, :call_stack
    undef_method :call_stack
    alias_method :attr_call_stack=, :call_stack=
    undef_method :call_stack=
    
    attr_accessor :hidden_tokens
    alias_method :attr_hidden_tokens, :hidden_tokens
    undef_method :hidden_tokens
    alias_method :attr_hidden_tokens=, :hidden_tokens=
    undef_method :hidden_tokens=
    
    attr_accessor :backtracking
    alias_method :attr_backtracking, :backtracking
    undef_method :backtracking
    alias_method :attr_backtracking=, :backtracking=
    undef_method :backtracking=
    
    typesig { [String] }
    def initialize(grammar_name)
      @call_stack = nil
      @hidden_tokens = nil
      @backtracking = 0
      super()
      @call_stack = Stack.new
      @hidden_tokens = ArrayList.new
      @backtracking = 0
      root = create("<grammar " + grammar_name + ">")
      @call_stack.push(root)
    end
    
    typesig { [] }
    def get_tree
      return @call_stack.element_at(0)
    end
    
    typesig { [Object] }
    # What kind of node to create.  You might want to override
    # so I factored out creation here.
    def create(payload)
      return ParseTree.new(payload)
    end
    
    typesig { [] }
    def epsilon_node
      return create(EPSILON_PAYLOAD)
    end
    
    typesig { [::Java::Int] }
    # Backtracking or cyclic DFA, don't want to add nodes to tree
    def enter_decision(d)
      @backtracking += 1
    end
    
    typesig { [::Java::Int] }
    def exit_decision(i)
      @backtracking -= 1
    end
    
    typesig { [String, String] }
    def enter_rule(filename, rule_name)
      if (@backtracking > 0)
        return
      end
      parent_rule_node = @call_stack.peek
      rule_node = create(rule_name)
      parent_rule_node.add_child(rule_node)
      @call_stack.push(rule_node)
    end
    
    typesig { [String, String] }
    def exit_rule(filename, rule_name)
      if (@backtracking > 0)
        return
      end
      rule_node = @call_stack.peek
      if ((rule_node.get_child_count).equal?(0))
        rule_node.add_child(epsilon_node)
      end
      @call_stack.pop
    end
    
    typesig { [Token] }
    def consume_token(token)
      if (@backtracking > 0)
        return
      end
      rule_node = @call_stack.peek
      element_node = create(token)
      element_node.attr_hidden_tokens = @hidden_tokens
      @hidden_tokens = ArrayList.new
      rule_node.add_child(element_node)
    end
    
    typesig { [Token] }
    def consume_hidden_token(token)
      if (@backtracking > 0)
        return
      end
      @hidden_tokens.add(token)
    end
    
    typesig { [RecognitionException] }
    def recognition_exception(e)
      if (@backtracking > 0)
        return
      end
      rule_node = @call_stack.peek
      error_node = create(e)
      rule_node.add_child(error_node)
    end
    
    private
    alias_method :initialize__parse_tree_builder, :initialize
  end
  
end
