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
  module ParseTreeImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Java::Util, :JavaList
    }
  end
  
  # A record of the rules used to match a token sequence.  The tokens
  # end up as the leaves of this tree and rule nodes are the interior nodes.
  # This really adds no functionality, it is just an alias for CommonTree
  # that is more meaningful (specific) and holds a String to display for a node.
  class ParseTree < ParseTreeImports.const_get :BaseTree
    include_class_members ParseTreeImports
    
    attr_accessor :payload
    alias_method :attr_payload, :payload
    undef_method :payload
    alias_method :attr_payload=, :payload=
    undef_method :payload=
    
    attr_accessor :hidden_tokens
    alias_method :attr_hidden_tokens, :hidden_tokens
    undef_method :hidden_tokens
    alias_method :attr_hidden_tokens=, :hidden_tokens=
    undef_method :hidden_tokens=
    
    typesig { [Object] }
    def initialize(label)
      @payload = nil
      @hidden_tokens = nil
      super()
      @payload = label
    end
    
    typesig { [] }
    def dup_node
      return nil
    end
    
    typesig { [] }
    def get_type
      return 0
    end
    
    typesig { [] }
    def get_text
      return to_s
    end
    
    typesig { [] }
    def get_token_start_index
      return 0
    end
    
    typesig { [::Java::Int] }
    def set_token_start_index(index)
    end
    
    typesig { [] }
    def get_token_stop_index
      return 0
    end
    
    typesig { [::Java::Int] }
    def set_token_stop_index(index)
    end
    
    typesig { [] }
    def to_s
      if (@payload.is_a?(Token))
        t = @payload
        if ((t.get_type).equal?(Token::EOF))
          return "<EOF>"
        end
        return t.get_text
      end
      return @payload.to_s
    end
    
    typesig { [] }
    # Emit a token and all hidden nodes before.  EOF node holds all
    # hidden tokens after last real token.
    def to_string_with_hidden_tokens
      buf = StringBuffer.new
      if (!(@hidden_tokens).nil?)
        i = 0
        while i < @hidden_tokens.size
          hidden = @hidden_tokens.get(i)
          buf.append(hidden.get_text)
          i += 1
        end
      end
      node_text = self.to_s
      if (!(node_text == "<EOF>"))
        buf.append(node_text)
      end
      return buf.to_s
    end
    
    typesig { [] }
    # Print out the leaves of this tree, which means printing original
    # input back out.
    def to_input_string
      buf = StringBuffer.new
      __to_string_leaves(buf)
      return buf.to_s
    end
    
    typesig { [StringBuffer] }
    def __to_string_leaves(buf)
      if (@payload.is_a?(Token))
        # leaf node token?
        buf.append(self.to_string_with_hidden_tokens)
        return
      end
      i = 0
      while !(self.attr_children).nil? && i < self.attr_children.size
        t = self.attr_children.get(i)
        t.__to_string_leaves(buf)
        i += 1
      end
    end
    
    private
    alias_method :initialize__parse_tree, :initialize
  end
  
end
