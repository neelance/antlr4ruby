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
  module DebugTreeAdaptorImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :TokenStream
      include_const ::Org::Antlr::Runtime, :RecognitionException
      include_const ::Org::Antlr::Runtime::Tree, :TreeAdaptor
    }
  end
  
  # A TreeAdaptor proxy that fires debugging events to a DebugEventListener
  # delegate and uses the TreeAdaptor delegate to do the actual work.  All
  # AST events are triggered by this adaptor; no code gen changes are needed
  # in generated rules.  Debugging events are triggered *after* invoking
  # tree adaptor routines.
  # 
  # Trees created with actions in rewrite actions like "-> ^(ADD {foo} {bar})"
  # cannot be tracked as they might not use the adaptor to create foo, bar.
  # The debug listener has to deal with tree node IDs for which it did
  # not see a createNode event.  A single <unknown> node is sufficient even
  # if it represents a whole tree.
  class DebugTreeAdaptor 
    include_class_members DebugTreeAdaptorImports
    include TreeAdaptor
    
    attr_accessor :dbg
    alias_method :attr_dbg, :dbg
    undef_method :dbg
    alias_method :attr_dbg=, :dbg=
    undef_method :dbg=
    
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    typesig { [DebugEventListener, TreeAdaptor] }
    def initialize(dbg, adaptor)
      @dbg = nil
      @adaptor = nil
      @dbg = dbg
      @adaptor = adaptor
    end
    
    typesig { [Token] }
    def create(payload)
      if (payload.get_token_index < 0)
        # could be token conjured up during error recovery
        return create(payload.get_type, payload.get_text)
      end
      node = @adaptor.create(payload)
      @dbg.create_node(node, payload)
      return node
    end
    
    typesig { [TokenStream, Token, Token, RecognitionException] }
    def error_node(input, start, stop, e)
      node = @adaptor.error_node(input, start, stop, e)
      if (!(node).nil?)
        @dbg.error_node(node)
      end
      return node
    end
    
    typesig { [Object] }
    def dup_tree(tree)
      t = @adaptor.dup_tree(tree)
      # walk the tree and emit create and add child events
      # to simulate what dupTree has done. dupTree does not call this debug
      # adapter so I must simulate.
      simulate_tree_construction(t)
      return t
    end
    
    typesig { [Object] }
    # ^(A B C): emit create A, create B, add child, ...
    def simulate_tree_construction(t)
      @dbg.create_node(t)
      n = @adaptor.get_child_count(t)
      i = 0
      while i < n
        child = @adaptor.get_child(t, i)
        simulate_tree_construction(child)
        @dbg.add_child(t, child)
        i += 1
      end
    end
    
    typesig { [Object] }
    def dup_node(tree_node)
      d = @adaptor.dup_node(tree_node)
      @dbg.create_node(d)
      return d
    end
    
    typesig { [] }
    def nil
      node = @adaptor.nil
      @dbg.nil_node(node)
      return node
    end
    
    typesig { [Object] }
    def is_nil(tree)
      return @adaptor.is_nil(tree)
    end
    
    typesig { [Object, Object] }
    def add_child(t, child)
      if ((t).nil? || (child).nil?)
        return
      end
      @adaptor.add_child(t, child)
      @dbg.add_child(t, child)
    end
    
    typesig { [Object, Object] }
    def become_root(new_root, old_root)
      n = @adaptor.become_root(new_root, old_root)
      @dbg.become_root(new_root, old_root)
      return n
    end
    
    typesig { [Object] }
    def rule_post_processing(root)
      return @adaptor.rule_post_processing(root)
    end
    
    typesig { [Object, Token] }
    def add_child(t, child)
      n = self.create(child)
      self.add_child(t, n)
    end
    
    typesig { [Token, Object] }
    def become_root(new_root, old_root)
      n = self.create(new_root)
      @adaptor.become_root(n, old_root)
      @dbg.become_root(new_root, old_root)
      return n
    end
    
    typesig { [::Java::Int, Token] }
    def create(token_type, from_token)
      node = @adaptor.create(token_type, from_token)
      @dbg.create_node(node)
      return node
    end
    
    typesig { [::Java::Int, Token, String] }
    def create(token_type, from_token, text)
      node = @adaptor.create(token_type, from_token, text)
      @dbg.create_node(node)
      return node
    end
    
    typesig { [::Java::Int, String] }
    def create(token_type, text)
      node = @adaptor.create(token_type, text)
      @dbg.create_node(node)
      return node
    end
    
    typesig { [Object] }
    def get_type(t)
      return @adaptor.get_type(t)
    end
    
    typesig { [Object, ::Java::Int] }
    def set_type(t, type)
      @adaptor.set_type(t, type)
    end
    
    typesig { [Object] }
    def get_text(t)
      return @adaptor.get_text(t)
    end
    
    typesig { [Object, String] }
    def set_text(t, text)
      @adaptor.set_text(t, text)
    end
    
    typesig { [Object] }
    def get_token(t)
      return @adaptor.get_token(t)
    end
    
    typesig { [Object, Token, Token] }
    def set_token_boundaries(t, start_token, stop_token)
      @adaptor.set_token_boundaries(t, start_token, stop_token)
      if (!(t).nil? && !(start_token).nil? && !(stop_token).nil?)
        @dbg.set_token_boundaries(t, start_token.get_token_index, stop_token.get_token_index)
      end
    end
    
    typesig { [Object] }
    def get_token_start_index(t)
      return @adaptor.get_token_start_index(t)
    end
    
    typesig { [Object] }
    def get_token_stop_index(t)
      return @adaptor.get_token_stop_index(t)
    end
    
    typesig { [Object, ::Java::Int] }
    def get_child(t, i)
      return @adaptor.get_child(t, i)
    end
    
    typesig { [Object, ::Java::Int, Object] }
    def set_child(t, i, child)
      @adaptor.set_child(t, i, child)
    end
    
    typesig { [Object, ::Java::Int] }
    def delete_child(t, i)
      return delete_child(t, i)
    end
    
    typesig { [Object] }
    def get_child_count(t)
      return @adaptor.get_child_count(t)
    end
    
    typesig { [Object] }
    def get_unique_id(node)
      return @adaptor.get_unique_id(node)
    end
    
    typesig { [Object] }
    def get_parent(t)
      return @adaptor.get_parent(t)
    end
    
    typesig { [Object] }
    def get_child_index(t)
      return @adaptor.get_child_index(t)
    end
    
    typesig { [Object, Object] }
    def set_parent(t, parent)
      @adaptor.set_parent(t, parent)
    end
    
    typesig { [Object, ::Java::Int] }
    def set_child_index(t, index)
      @adaptor.set_child_index(t, index)
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int, Object] }
    def replace_children(parent, start_child_index, stop_child_index, t)
      @adaptor.replace_children(parent, start_child_index, stop_child_index, t)
    end
    
    typesig { [] }
    # support
    def get_debug_listener
      return @dbg
    end
    
    typesig { [DebugEventListener] }
    def set_debug_listener(dbg)
      @dbg = dbg
    end
    
    typesig { [] }
    def get_tree_adaptor
      return @adaptor
    end
    
    private
    alias_method :initialize__debug_tree_adaptor, :initialize
  end
  
end
