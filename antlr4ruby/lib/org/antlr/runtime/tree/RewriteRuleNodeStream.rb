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
  module RewriteRuleNodeStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Java::Util, :JavaList
    }
  end
  
  # Queues up nodes matched on left side of -> in a tree parser. This is
  # the analog of RewriteRuleTokenStream for normal parsers.
  class RewriteRuleNodeStream < RewriteRuleNodeStreamImports.const_get :RewriteRuleElementStream
    include_class_members RewriteRuleNodeStreamImports
    
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
    def next_node
      return __next
    end
    
    typesig { [Object] }
    def to_tree(el)
      return self.attr_adaptor.dup_node(el)
    end
    
    typesig { [Object] }
    def dup(el)
      # we dup every node, so don't have to worry about calling dup; short-
      # circuited next() so it doesn't call.
      raise UnsupportedOperationException.new("dup can't be called for a node stream.")
    end
    
    private
    alias_method :initialize__rewrite_rule_node_stream, :initialize
  end
  
end
