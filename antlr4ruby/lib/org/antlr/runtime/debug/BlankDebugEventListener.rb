require "rjava"

# 
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
  module BlankDebugEventListenerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :RecognitionException
      include_const ::Org::Antlr::Runtime, :Token
    }
  end
  
  # A blank listener that does nothing; useful for real classes so
  # they don't have to have lots of blank methods and are less
  # sensitive to updates to debug interface.
  class BlankDebugEventListener 
    include_class_members BlankDebugEventListenerImports
    include DebugEventListener
    
    typesig { [String, String] }
    def enter_rule(grammar_file_name, rule_name)
    end
    
    typesig { [String, String] }
    def exit_rule(grammar_file_name, rule_name)
    end
    
    typesig { [::Java::Int] }
    def enter_alt(alt)
    end
    
    typesig { [::Java::Int] }
    def enter_sub_rule(decision_number)
    end
    
    typesig { [::Java::Int] }
    def exit_sub_rule(decision_number)
    end
    
    typesig { [::Java::Int] }
    def enter_decision(decision_number)
    end
    
    typesig { [::Java::Int] }
    def exit_decision(decision_number)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def location(line, pos)
    end
    
    typesig { [Token] }
    def consume_token(token)
    end
    
    typesig { [Token] }
    def consume_hidden_token(token)
    end
    
    typesig { [::Java::Int, Token] }
    def _lt(i, t)
    end
    
    typesig { [::Java::Int] }
    def mark(i)
    end
    
    typesig { [::Java::Int] }
    def rewind(i)
    end
    
    typesig { [] }
    def rewind
    end
    
    typesig { [::Java::Int] }
    def begin_backtrack(level)
    end
    
    typesig { [::Java::Int, ::Java::Boolean] }
    def end_backtrack(level, successful)
    end
    
    typesig { [RecognitionException] }
    def recognition_exception(e)
    end
    
    typesig { [] }
    def begin_resync
    end
    
    typesig { [] }
    def end_resync
    end
    
    typesig { [::Java::Boolean, String] }
    def semantic_predicate(result, predicate)
    end
    
    typesig { [] }
    def commence
    end
    
    typesig { [] }
    def terminate
    end
    
    typesig { [Object] }
    # Tree parsing stuff
    def consume_node(t)
    end
    
    typesig { [::Java::Int, Object] }
    def _lt(i, t)
    end
    
    typesig { [Object] }
    # AST Stuff
    def nil_node(t)
    end
    
    typesig { [Object] }
    def error_node(t)
    end
    
    typesig { [Object] }
    def create_node(t)
    end
    
    typesig { [Object, Token] }
    def create_node(node, token)
    end
    
    typesig { [Object, Object] }
    def become_root(new_root, old_root)
    end
    
    typesig { [Object, Object] }
    def add_child(root, child)
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int] }
    def set_token_boundaries(t, token_start_index, token_stop_index)
    end
    
    typesig { [] }
    def initialize
    end
    
    private
    alias_method :initialize__blank_debug_event_listener, :initialize
  end
  
end
