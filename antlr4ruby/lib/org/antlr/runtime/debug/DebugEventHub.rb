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
  module DebugEventHubImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :RecognitionException
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :ArrayList
    }
  end
  
  # Broadcast debug events to multiple listeners.  Lets you debug and still
  # use the event mechanism to build parse trees etc...  Not thread-safe.
  # Don't add events in one thread while parser fires events in another.
  # 
  # @see also DebugEventRepeater
  class DebugEventHub 
    include_class_members DebugEventHubImports
    include DebugEventListener
    
    attr_accessor :listeners
    alias_method :attr_listeners, :listeners
    undef_method :listeners
    alias_method :attr_listeners=, :listeners=
    undef_method :listeners=
    
    typesig { [DebugEventListener] }
    def initialize(listener)
      @listeners = ArrayList.new
      @listeners.add(listener)
    end
    
    typesig { [DebugEventListener, DebugEventListener] }
    def initialize(a, b)
      @listeners = ArrayList.new
      @listeners.add(a)
      @listeners.add(b)
    end
    
    typesig { [DebugEventListener] }
    # Add another listener to broadcast events too.  Not thread-safe.
    # Don't add events in one thread while parser fires events in another.
    def add_listener(listener)
      @listeners.add(@listeners)
    end
    
    typesig { [String, String] }
    # To avoid a mess like this:
    #  public void enterRule(final String ruleName) {
    #      broadcast(new Code(){
    #          public void exec(DebugEventListener listener) {listener.enterRule(ruleName);}}
    #          );
    #  }
    #  I am dup'ing the for-loop in each.  Where are Java closures!? blech!
    def enter_rule(grammar_file_name, rule_name)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.enter_rule(grammar_file_name, rule_name)
        i += 1
      end
    end
    
    typesig { [String, String] }
    def exit_rule(grammar_file_name, rule_name)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.exit_rule(grammar_file_name, rule_name)
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def enter_alt(alt)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.enter_alt(alt)
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def enter_sub_rule(decision_number)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.enter_sub_rule(decision_number)
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def exit_sub_rule(decision_number)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.exit_sub_rule(decision_number)
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def enter_decision(decision_number)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.enter_decision(decision_number)
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def exit_decision(decision_number)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.exit_decision(decision_number)
        i += 1
      end
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def location(line, pos)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.location(line, pos)
        i += 1
      end
    end
    
    typesig { [Token] }
    def consume_token(token)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.consume_token(token)
        i += 1
      end
    end
    
    typesig { [Token] }
    def consume_hidden_token(token)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.consume_hidden_token(token)
        i += 1
      end
    end
    
    typesig { [::Java::Int, Token] }
    def _lt(index, t)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener._lt(index, t)
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def mark(index)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.mark(index)
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def rewind(index)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.rewind(index)
        i += 1
      end
    end
    
    typesig { [] }
    def rewind
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.rewind
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def begin_backtrack(level)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.begin_backtrack(level)
        i += 1
      end
    end
    
    typesig { [::Java::Int, ::Java::Boolean] }
    def end_backtrack(level, successful)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.end_backtrack(level, successful)
        i += 1
      end
    end
    
    typesig { [RecognitionException] }
    def recognition_exception(e)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.recognition_exception(e)
        i += 1
      end
    end
    
    typesig { [] }
    def begin_resync
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.begin_resync
        i += 1
      end
    end
    
    typesig { [] }
    def end_resync
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.end_resync
        i += 1
      end
    end
    
    typesig { [::Java::Boolean, String] }
    def semantic_predicate(result, predicate)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.semantic_predicate(result, predicate)
        i += 1
      end
    end
    
    typesig { [] }
    def commence
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.commence
        i += 1
      end
    end
    
    typesig { [] }
    def terminate
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.terminate
        i += 1
      end
    end
    
    typesig { [Object] }
    # Tree parsing stuff
    def consume_node(t)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.consume_node(t)
        i += 1
      end
    end
    
    typesig { [::Java::Int, Object] }
    def _lt(index, t)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener._lt(index, t)
        i += 1
      end
    end
    
    typesig { [Object] }
    # AST Stuff
    def nil_node(t)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.nil_node(t)
        i += 1
      end
    end
    
    typesig { [Object] }
    def error_node(t)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.error_node(t)
        i += 1
      end
    end
    
    typesig { [Object] }
    def create_node(t)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.create_node(t)
        i += 1
      end
    end
    
    typesig { [Object, Token] }
    def create_node(node, token)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.create_node(node, token)
        i += 1
      end
    end
    
    typesig { [Object, Object] }
    def become_root(new_root, old_root)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.become_root(new_root, old_root)
        i += 1
      end
    end
    
    typesig { [Object, Object] }
    def add_child(root, child)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.add_child(root, child)
        i += 1
      end
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int] }
    def set_token_boundaries(t, token_start_index, token_stop_index)
      i = 0
      while i < @listeners.size
        listener = @listeners.get(i)
        listener.set_token_boundaries(t, token_start_index, token_stop_index)
        i += 1
      end
    end
    
    private
    alias_method :initialize__debug_event_hub, :initialize
  end
  
end
