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
  module TraceDebugEventListenerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime::Tree, :TreeAdaptor
    }
  end
  
  # Print out (most of) the events... Useful for debugging, testing...
  class TraceDebugEventListener < TraceDebugEventListenerImports.const_get :BlankDebugEventListener
    include_class_members TraceDebugEventListenerImports
    
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    typesig { [TreeAdaptor] }
    def initialize(adaptor)
      @adaptor = nil
      super()
      @adaptor = adaptor
    end
    
    typesig { [String] }
    def enter_rule(rule_name)
      System.out.println("enterRule " + rule_name)
    end
    
    typesig { [String] }
    def exit_rule(rule_name)
      System.out.println("exitRule " + rule_name)
    end
    
    typesig { [::Java::Int] }
    def enter_sub_rule(decision_number)
      System.out.println("enterSubRule")
    end
    
    typesig { [::Java::Int] }
    def exit_sub_rule(decision_number)
      System.out.println("exitSubRule")
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def location(line, pos)
      System.out.println("location " + RJava.cast_to_string(line) + ":" + RJava.cast_to_string(pos))
    end
    
    typesig { [Object] }
    # Tree parsing stuff
    def consume_node(t)
      id = @adaptor.get_unique_id(t)
      text = @adaptor.get_text(t)
      type = @adaptor.get_type(t)
      System.out.println("consumeNode " + RJava.cast_to_string(id) + " " + text + " " + RJava.cast_to_string(type))
    end
    
    typesig { [::Java::Int, Object] }
    def _lt(i, t)
      id = @adaptor.get_unique_id(t)
      text = @adaptor.get_text(t)
      type = @adaptor.get_type(t)
      System.out.println("LT " + RJava.cast_to_string(i) + " " + RJava.cast_to_string(id) + " " + text + " " + RJava.cast_to_string(type))
    end
    
    typesig { [Object] }
    # AST stuff
    def nil_node(t)
      System.out.println("nilNode " + RJava.cast_to_string(@adaptor.get_unique_id(t)))
    end
    
    typesig { [Object] }
    def create_node(t)
      id = @adaptor.get_unique_id(t)
      text = @adaptor.get_text(t)
      type = @adaptor.get_type(t)
      System.out.println("create " + RJava.cast_to_string(id) + ": " + text + ", " + RJava.cast_to_string(type))
    end
    
    typesig { [Object, Token] }
    def create_node(node, token)
      id = @adaptor.get_unique_id(node)
      text = @adaptor.get_text(node)
      token_index = token.get_token_index
      System.out.println("create " + RJava.cast_to_string(id) + ": " + RJava.cast_to_string(token_index))
    end
    
    typesig { [Object, Object] }
    def become_root(new_root, old_root)
      System.out.println("becomeRoot " + RJava.cast_to_string(@adaptor.get_unique_id(new_root)) + ", " + RJava.cast_to_string(@adaptor.get_unique_id(old_root)))
    end
    
    typesig { [Object, Object] }
    def add_child(root, child)
      System.out.println("addChild " + RJava.cast_to_string(@adaptor.get_unique_id(root)) + ", " + RJava.cast_to_string(@adaptor.get_unique_id(child)))
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int] }
    def set_token_boundaries(t, token_start_index, token_stop_index)
      System.out.println("setTokenBoundaries " + RJava.cast_to_string(@adaptor.get_unique_id(t)) + ", " + RJava.cast_to_string(token_start_index) + ", " + RJava.cast_to_string(token_stop_index))
    end
    
    private
    alias_method :initialize__trace_debug_event_listener, :initialize
  end
  
end
