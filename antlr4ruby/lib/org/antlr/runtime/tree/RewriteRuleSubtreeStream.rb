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
  module RewriteRuleSubtreeStreamImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Java::Util, :JavaList
    }
  end
  
  class RewriteRuleSubtreeStream < RewriteRuleSubtreeStreamImports.const_get :RewriteRuleElementStream
    include_class_members RewriteRuleSubtreeStreamImports
    
    typesig { [TreeAdaptor, String] }
    def initialize(adaptor, element_description)
      super(adaptor, element_description)
    end
    
    typesig { [TreeAdaptor, String, Object] }
    # Create a stream with one element
    def initialize(adaptor, element_description, one_element)
      super(adaptor, element_description, one_element)
    end
    
    typesig { [TreeAdaptor, String, JavaList] }
    # Create a stream, but feed off an existing list
    def initialize(adaptor, element_description, elements)
      super(adaptor, element_description, elements)
    end
    
    typesig { [] }
    # Treat next element as a single node even if it's a subtree.
    # This is used instead of next() when the result has to be a
    # tree root node.  Also prevents us from duplicating recently-added
    # children; e.g., ^(type ID)+ adds ID to type and then 2nd iteration
    # must dup the type node, but ID has been added.
    # 
    # Referencing a rule result twice is ok; dup entire tree as
    # we can't be adding trees as root; e.g., expr expr.
    # 
    # Hideous code duplication here with super.next().  Can't think of
    # a proper way to refactor.  This needs to always call dup node
    # and super.next() doesn't know which to call: dup node or dup tree.
    def next_node
      n = size
      if (self.attr_dirty || (self.attr_cursor >= n && (n).equal?(1)))
        # if out of elements and size is 1, dup (at most a single node
        # since this is for making root nodes).
        el = __next
        return self.attr_adaptor.dup_node(el)
      end
      # test size above then fetch
      el = __next
      return el
    end
    
    typesig { [Object] }
    def dup(el)
      return self.attr_adaptor.dup_tree(el)
    end
    
    private
    alias_method :initialize__rewrite_rule_subtree_stream, :initialize
  end
  
end
