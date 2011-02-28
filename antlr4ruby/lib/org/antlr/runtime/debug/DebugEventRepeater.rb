require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2008 Terence Parr
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
module Org::Antlr::Runtime::Debug
  module DebugEventRepeaterImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :RecognitionException
    }
  end
  
  # A simple event repeater (proxy) that delegates all functionality to the
  # listener sent into the ctor.  Useful if you want to listen in on a few
  # debug events w/o interrupting the debugger.  Just subclass the repeater
  # and override the methods you want to listen in on.  Remember to call
  # the method in this class so the event will continue on to the original
  # recipient.
  # 
  # @see DebugEventHub
  class DebugEventRepeater 
    include_class_members DebugEventRepeaterImports
    include DebugEventListener
    
    attr_accessor :listener
    alias_method :attr_listener, :listener
    undef_method :listener
    alias_method :attr_listener=, :listener=
    undef_method :listener=
    
    typesig { [DebugEventListener] }
    def initialize(listener)
      @listener = nil
      @listener = listener
    end
    
    typesig { [String, String] }
    def enter_rule(grammar_file_name, rule_name)
      @listener.enter_rule(grammar_file_name, rule_name)
    end
    
    typesig { [String, String] }
    def exit_rule(grammar_file_name, rule_name)
      @listener.exit_rule(grammar_file_name, rule_name)
    end
    
    typesig { [::Java::Int] }
    def enter_alt(alt)
      @listener.enter_alt(alt)
    end
    
    typesig { [::Java::Int] }
    def enter_sub_rule(decision_number)
      @listener.enter_sub_rule(decision_number)
    end
    
    typesig { [::Java::Int] }
    def exit_sub_rule(decision_number)
      @listener.exit_sub_rule(decision_number)
    end
    
    typesig { [::Java::Int] }
    def enter_decision(decision_number)
      @listener.enter_decision(decision_number)
    end
    
    typesig { [::Java::Int] }
    def exit_decision(decision_number)
      @listener.exit_decision(decision_number)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def location(line, pos)
      @listener.location(line, pos)
    end
    
    typesig { [Token] }
    def consume_token(token)
      @listener.consume_token(token)
    end
    
    typesig { [Token] }
    def consume_hidden_token(token)
      @listener.consume_hidden_token(token)
    end
    
    typesig { [::Java::Int, Token] }
    def _lt(i, t)
      @listener._lt(i, t)
    end
    
    typesig { [::Java::Int] }
    def mark(i)
      @listener.mark(i)
    end
    
    typesig { [::Java::Int] }
    def rewind(i)
      @listener.rewind(i)
    end
    
    typesig { [] }
    def rewind
      @listener.rewind
    end
    
    typesig { [::Java::Int] }
    def begin_backtrack(level)
      @listener.begin_backtrack(level)
    end
    
    typesig { [::Java::Int, ::Java::Boolean] }
    def end_backtrack(level, successful)
      @listener.end_backtrack(level, successful)
    end
    
    typesig { [RecognitionException] }
    def recognition_exception(e)
      @listener.recognition_exception(e)
    end
    
    typesig { [] }
    def begin_resync
      @listener.begin_resync
    end
    
    typesig { [] }
    def end_resync
      @listener.end_resync
    end
    
    typesig { [::Java::Boolean, String] }
    def semantic_predicate(result, predicate)
      @listener.semantic_predicate(result, predicate)
    end
    
    typesig { [] }
    def commence
      @listener.commence
    end
    
    typesig { [] }
    def terminate
      @listener.terminate
    end
    
    typesig { [Object] }
    # Tree parsing stuff
    def consume_node(t)
      @listener.consume_node(t)
    end
    
    typesig { [::Java::Int, Object] }
    def _lt(i, t)
      @listener._lt(i, t)
    end
    
    typesig { [Object] }
    # AST Stuff
    def nil_node(t)
      @listener.nil_node(t)
    end
    
    typesig { [Object] }
    def error_node(t)
      @listener.error_node(t)
    end
    
    typesig { [Object] }
    def create_node(t)
      @listener.create_node(t)
    end
    
    typesig { [Object, Token] }
    def create_node(node, token)
      @listener.create_node(node, token)
    end
    
    typesig { [Object, Object] }
    def become_root(new_root, old_root)
      @listener.become_root(new_root, old_root)
    end
    
    typesig { [Object, Object] }
    def add_child(root, child)
      @listener.add_child(root, child)
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int] }
    def set_token_boundaries(t, token_start_index, token_stop_index)
      @listener.set_token_boundaries(t, token_start_index, token_stop_index)
    end
    
    private
    alias_method :initialize__debug_event_repeater, :initialize
  end
  
end
