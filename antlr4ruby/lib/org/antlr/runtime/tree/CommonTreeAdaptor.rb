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
  module CommonTreeAdaptorImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :CommonToken
      include_const ::Org::Antlr::Runtime, :Token
    }
  end
  
  # A TreeAdaptor that works with any Tree implementation.  It provides
  # really just factory methods; all the work is done by BaseTreeAdaptor.
  # If you would like to have different tokens created than ClassicToken
  # objects, you need to override this and then set the parser tree adaptor to
  # use your subclass.
  # 
  # To get your parser to build nodes of a different type, override
  # create(Token), errorNode(), and to be safe, YourTreeClass.dupNode().
  # dupNode is called to duplicate nodes during rewrite operations.
  class CommonTreeAdaptor < CommonTreeAdaptorImports.const_get :BaseTreeAdaptor
    include_class_members CommonTreeAdaptorImports
    
    typesig { [Object] }
    # Duplicate a node.  This is part of the factory;
    # override if you want another kind of node to be built.
    # 
    # I could use reflection to prevent having to override this
    # but reflection is slow.
    def dup_node(t)
      if ((t).nil?)
        return nil
      end
      return (t).dup_node
    end
    
    typesig { [Token] }
    def create(payload)
      return CommonTree.new(payload)
    end
    
    typesig { [::Java::Int, String] }
    # Tell me how to create a token for use with imaginary token nodes.
    # For example, there is probably no input symbol associated with imaginary
    # token DECL, but you need to create it as a payload or whatever for
    # the DECL node as in ^(DECL type ID).
    # 
    # If you care what the token payload objects' type is, you should
    # override this method and any other createToken variant.
    def create_token(token_type, text)
      return CommonToken.new(token_type, text)
    end
    
    typesig { [Token] }
    # Tell me how to create a token for use with imaginary token nodes.
    # For example, there is probably no input symbol associated with imaginary
    # token DECL, but you need to create it as a payload or whatever for
    # the DECL node as in ^(DECL type ID).
    # 
    # This is a variant of createToken where the new token is derived from
    # an actual real input token.  Typically this is for converting '{'
    # tokens to BLOCK etc...  You'll see
    # 
    # r : lc='{' ID+ '}' -> ^(BLOCK[$lc] ID+) ;
    # 
    # If you care what the token payload objects' type is, you should
    # override this method and any other createToken variant.
    def create_token(from_token)
      return CommonToken.new(from_token)
    end
    
    typesig { [Object, Token, Token] }
    # Track start/stop token for subtree root created for a rule.
    # Only works with Tree nodes.  For rules that match nothing,
    # seems like this will yield start=i and stop=i-1 in a nil node.
    # Might be useful info so I'll not force to be i..i.
    def set_token_boundaries(t, start_token, stop_token)
      if ((t).nil?)
        return
      end
      start = 0
      stop = 0
      if (!(start_token).nil?)
        start = start_token.get_token_index
      end
      if (!(stop_token).nil?)
        stop = stop_token.get_token_index
      end
      (t).set_token_start_index(start)
      (t).set_token_stop_index(stop)
    end
    
    typesig { [Object] }
    def get_token_start_index(t)
      if ((t).nil?)
        return -1
      end
      return (t).get_token_start_index
    end
    
    typesig { [Object] }
    def get_token_stop_index(t)
      if ((t).nil?)
        return -1
      end
      return (t).get_token_stop_index
    end
    
    typesig { [Object] }
    def get_text(t)
      if ((t).nil?)
        return nil
      end
      return (t).get_text
    end
    
    typesig { [Object] }
    def get_type(t)
      if ((t).nil?)
        return Token::INVALID_TOKEN_TYPE
      end
      return (t).get_type
    end
    
    typesig { [Object] }
    # What is the Token associated with this node?  If
    # you are not using CommonTree, then you must
    # override this in your own adaptor.
    def get_token(t)
      if (t.is_a?(CommonTree))
        return (t).get_token
      end
      return nil # no idea what to do
    end
    
    typesig { [Object, ::Java::Int] }
    def get_child(t, i)
      if ((t).nil?)
        return nil
      end
      return (t).get_child(i)
    end
    
    typesig { [Object] }
    def get_child_count(t)
      if ((t).nil?)
        return 0
      end
      return (t).get_child_count
    end
    
    typesig { [Object] }
    def get_parent(t)
      return (t).get_parent
    end
    
    typesig { [Object, Object] }
    def set_parent(t, parent)
      (t).set_parent(parent)
    end
    
    typesig { [Object] }
    def get_child_index(t)
      return (t).get_child_index
    end
    
    typesig { [Object, ::Java::Int] }
    def set_child_index(t, index)
      (t).set_child_index(index)
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int, Object] }
    def replace_children(parent, start_child_index, stop_child_index, t)
      if (!(parent).nil?)
        (parent).replace_children(start_child_index, stop_child_index, t)
      end
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__common_tree_adaptor, :initialize
  end
  
end
