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
  module CommonTreeImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
    }
  end
  
  # A tree node that is wrapper for a Token object.  After 3.0 release
  # while building tree rewrite stuff, it became clear that computing
  # parent and child index is very difficult and cumbersome.  Better to
  # spend the space in every tree node.  If you don't want these extra
  # fields, it's easy to cut them out in your own BaseTree subclass.
  class CommonTree < CommonTreeImports.const_get :BaseTree
    include_class_members CommonTreeImports
    
    # A single token is the payload
    attr_accessor :token
    alias_method :attr_token, :token
    undef_method :token
    alias_method :attr_token=, :token=
    undef_method :token=
    
    # What token indexes bracket all tokens associated with this node
    # and below?
    attr_accessor :start_index
    alias_method :attr_start_index, :start_index
    undef_method :start_index
    alias_method :attr_start_index=, :start_index=
    undef_method :start_index=
    
    attr_accessor :stop_index
    alias_method :attr_stop_index, :stop_index
    undef_method :stop_index
    alias_method :attr_stop_index=, :stop_index=
    undef_method :stop_index=
    
    # Who is the parent node of this node; if null, implies node is root
    attr_accessor :parent
    alias_method :attr_parent, :parent
    undef_method :parent
    alias_method :attr_parent=, :parent=
    undef_method :parent=
    
    # What index is this node in the child list? Range: 0..n-1
    attr_accessor :child_index
    alias_method :attr_child_index, :child_index
    undef_method :child_index
    alias_method :attr_child_index=, :child_index=
    undef_method :child_index=
    
    typesig { [] }
    def initialize
      @token = nil
      @start_index = 0
      @stop_index = 0
      @parent = nil
      @child_index = 0
      super()
      @start_index = -1
      @stop_index = -1
      @child_index = -1
    end
    
    typesig { [CommonTree] }
    def initialize(node)
      @token = nil
      @start_index = 0
      @stop_index = 0
      @parent = nil
      @child_index = 0
      super(node)
      @start_index = -1
      @stop_index = -1
      @child_index = -1
      @token = node.attr_token
      @start_index = node.attr_start_index
      @stop_index = node.attr_stop_index
    end
    
    typesig { [Token] }
    def initialize(t)
      @token = nil
      @start_index = 0
      @stop_index = 0
      @parent = nil
      @child_index = 0
      super()
      @start_index = -1
      @stop_index = -1
      @child_index = -1
      @token = t
    end
    
    typesig { [] }
    def get_token
      return @token
    end
    
    typesig { [] }
    def dup_node
      return CommonTree.new(self)
    end
    
    typesig { [] }
    def is_nil
      return (@token).nil?
    end
    
    typesig { [] }
    def get_type
      if ((@token).nil?)
        return Token::INVALID_TOKEN_TYPE
      end
      return @token.get_type
    end
    
    typesig { [] }
    def get_text
      if ((@token).nil?)
        return nil
      end
      return @token.get_text
    end
    
    typesig { [] }
    def get_line
      if ((@token).nil? || (@token.get_line).equal?(0))
        if (get_child_count > 0)
          return get_child(0).get_line
        end
        return 0
      end
      return @token.get_line
    end
    
    typesig { [] }
    def get_char_position_in_line
      if ((@token).nil? || (@token.get_char_position_in_line).equal?(-1))
        if (get_child_count > 0)
          return get_child(0).get_char_position_in_line
        end
        return 0
      end
      return @token.get_char_position_in_line
    end
    
    typesig { [] }
    def get_token_start_index
      if ((@start_index).equal?(-1) && !(@token).nil?)
        return @token.get_token_index
      end
      return @start_index
    end
    
    typesig { [::Java::Int] }
    def set_token_start_index(index)
      @start_index = index
    end
    
    typesig { [] }
    def get_token_stop_index
      if ((@stop_index).equal?(-1) && !(@token).nil?)
        return @token.get_token_index
      end
      return @stop_index
    end
    
    typesig { [::Java::Int] }
    def set_token_stop_index(index)
      @stop_index = index
    end
    
    typesig { [] }
    def get_child_index
      return @child_index
    end
    
    typesig { [] }
    def get_parent
      return @parent
    end
    
    typesig { [Tree] }
    def set_parent(t)
      @parent = t
    end
    
    typesig { [::Java::Int] }
    def set_child_index(index)
      @child_index = index
    end
    
    typesig { [] }
    def to_s
      if (is_nil)
        return "nil"
      end
      if ((get_type).equal?(Token::INVALID_TOKEN_TYPE))
        return "<errornode>"
      end
      if ((@token).nil?)
        return nil
      end
      return @token.get_text
    end
    
    private
    alias_method :initialize__common_tree, :initialize
  end
  
end
