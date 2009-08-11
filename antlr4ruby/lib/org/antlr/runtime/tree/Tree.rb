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
module Org::Antlr::Runtime::Tree
  module TreeImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
    }
  end
  
  # What does a tree look like?  ANTLR has a number of support classes
  # such as CommonTreeNodeStream that work on these kinds of trees.  You
  # don't have to make your trees implement this interface, but if you do,
  # you'll be able to use more support code.
  # 
  # NOTE: When constructing trees, ANTLR can build any kind of tree; it can
  # even use Token objects as trees if you add a child list to your tokens.
  # 
  # This is a tree node without any payload; just navigation and factory stuff.
  module Tree
    include_class_members TreeImports
    
    class_module.module_eval {
      const_set_lazy(:INVALID_NODE) { CommonTree.new(Token::INVALID_TOKEN) }
      const_attr_reader  :INVALID_NODE
    }
    
    typesig { [::Java::Int] }
    def get_child(i)
      raise NotImplementedError
    end
    
    typesig { [] }
    def get_child_count
      raise NotImplementedError
    end
    
    typesig { [] }
    # Tree tracks parent and child index now > 3.0
    def get_parent
      raise NotImplementedError
    end
    
    typesig { [Tree] }
    def set_parent(t)
      raise NotImplementedError
    end
    
    typesig { [] }
    # This node is what child index? 0..n-1
    def get_child_index
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_child_index(index)
      raise NotImplementedError
    end
    
    typesig { [] }
    # Set the parent and child index values for all children
    def freshen_parent_and_child_indexes
      raise NotImplementedError
    end
    
    typesig { [Tree] }
    # Add t as a child to this node.  If t is null, do nothing.  If t
    # is nil, add all children of t to this' children.
    def add_child(t)
      raise NotImplementedError
    end
    
    typesig { [::Java::Int, Tree] }
    # Set ith child (0..n-1) to t; t must be non-null and non-nil node
    def set_child(i, t)
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def delete_child(i)
      raise NotImplementedError
    end
    
    typesig { [::Java::Int, ::Java::Int, Object] }
    # Delete children from start to stop and replace with t even if t is
    # a list (nil-root tree).  num of children can increase or decrease.
    # For huge child lists, inserting children can force walking rest of
    # children to set their childindex; could be slow.
    def replace_children(start_child_index, stop_child_index, t)
      raise NotImplementedError
    end
    
    typesig { [] }
    # Indicates the node is a nil node but may still have children, meaning
    # the tree is a flat list.
    def is_nil
      raise NotImplementedError
    end
    
    typesig { [] }
    # What is the smallest token index (indexing from 0) for this node
    # and its children?
    def get_token_start_index
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_token_start_index(index)
      raise NotImplementedError
    end
    
    typesig { [] }
    # What is the largest token index (indexing from 0) for this node
    # and its children?
    def get_token_stop_index
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_token_stop_index(index)
      raise NotImplementedError
    end
    
    typesig { [] }
    def dup_node
      raise NotImplementedError
    end
    
    typesig { [] }
    # Return a token type; needed for tree parsing
    def get_type
      raise NotImplementedError
    end
    
    typesig { [] }
    def get_text
      raise NotImplementedError
    end
    
    typesig { [] }
    # In case we don't have a token payload, what is the line for errors?
    def get_line
      raise NotImplementedError
    end
    
    typesig { [] }
    def get_char_position_in_line
      raise NotImplementedError
    end
    
    typesig { [] }
    def to_string_tree
      raise NotImplementedError
    end
    
    typesig { [] }
    def to_s
      raise NotImplementedError
    end
  end
  
end
