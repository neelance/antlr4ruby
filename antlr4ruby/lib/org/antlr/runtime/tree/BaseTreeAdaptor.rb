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
module Org::Antlr::Runtime::Tree
  module BaseTreeAdaptorImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :TokenStream
      include_const ::Org::Antlr::Runtime, :RecognitionException
      include_const ::Java::Util, :HashMap
      include_const ::Java::Util, :Map
    }
  end
  
  # A TreeAdaptor that works with any Tree implementation.
  class BaseTreeAdaptor 
    include_class_members BaseTreeAdaptorImports
    include TreeAdaptor
    
    # System.identityHashCode() is not always unique; we have to
    # track ourselves.  That's ok, it's only for debugging, though it's
    # expensive: we have to create a hashtable with all tree nodes in it.
    attr_accessor :tree_to_unique_idmap
    alias_method :attr_tree_to_unique_idmap, :tree_to_unique_idmap
    undef_method :tree_to_unique_idmap
    alias_method :attr_tree_to_unique_idmap=, :tree_to_unique_idmap=
    undef_method :tree_to_unique_idmap=
    
    attr_accessor :unique_node_id
    alias_method :attr_unique_node_id, :unique_node_id
    undef_method :unique_node_id
    alias_method :attr_unique_node_id=, :unique_node_id=
    undef_method :unique_node_id=
    
    typesig { [] }
    def nil
      return create(nil)
    end
    
    typesig { [TokenStream, Token, Token, RecognitionException] }
    # create tree node that holds the start and stop tokens associated
    # with an error.
    # 
    # If you specify your own kind of tree nodes, you will likely have to
    # override this method. CommonTree returns Token.INVALID_TOKEN_TYPE
    # if no token payload but you might have to set token type for diff
    # node type.
    # 
    # You don't have to subclass CommonErrorNode; you will likely need to
    # subclass your own tree node class to avoid class cast exception.
    def error_node(input, start, stop, e)
      t = CommonErrorNode.new(input, start, stop, e)
      # System.out.println("returning error node '"+t+"' @index="+input.index());
      return t
    end
    
    typesig { [Object] }
    def is_nil(tree)
      return (tree).is_nil
    end
    
    typesig { [Object] }
    def dup_tree(tree)
      return dup_tree(tree, nil)
    end
    
    typesig { [Object, Object] }
    # This is generic in the sense that it will work with any kind of
    # tree (not just Tree interface).  It invokes the adaptor routines
    # not the tree node routines to do the construction.
    def dup_tree(t, parent)
      if ((t).nil?)
        return nil
      end
      new_tree = dup_node(t)
      # ensure new subtree root has parent/child index set
      set_child_index(new_tree, get_child_index(t)) # same index in new tree
      set_parent(new_tree, parent)
      n = get_child_count(t)
      i = 0
      while i < n
        child = get_child(t, i)
        new_sub_tree = dup_tree(child, t)
        add_child(new_tree, new_sub_tree)
        ((i += 1) - 1)
      end
      return new_tree
    end
    
    typesig { [Object, Object] }
    # Add a child to the tree t.  If child is a flat tree (a list), make all
    # in list children of t.  Warning: if t has no children, but child does
    # and child isNil then you can decide it is ok to move children to t via
    # t.children = child.children; i.e., without copying the array.  Just
    # make sure that this is consistent with have the user will build
    # ASTs.
    def add_child(t, child)
      if (!(t).nil? && !(child).nil?)
        (t).add_child(child)
      end
    end
    
    typesig { [Object, Object] }
    # If oldRoot is a nil root, just copy or move the children to newRoot.
    # If not a nil root, make oldRoot a child of newRoot.
    # 
    # old=^(nil a b c), new=r yields ^(r a b c)
    # old=^(a b c), new=r yields ^(r ^(a b c))
    # 
    # If newRoot is a nil-rooted single child tree, use the single
    # child as the new root node.
    # 
    # old=^(nil a b c), new=^(nil r) yields ^(r a b c)
    # old=^(a b c), new=^(nil r) yields ^(r ^(a b c))
    # 
    # If oldRoot was null, it's ok, just return newRoot (even if isNil).
    # 
    # old=null, new=r yields r
    # old=null, new=^(nil r) yields ^(nil r)
    # 
    # Return newRoot.  Throw an exception if newRoot is not a
    # simple node or nil root with a single child node--it must be a root
    # node.  If newRoot is ^(nil x) return x as newRoot.
    # 
    # Be advised that it's ok for newRoot to point at oldRoot's
    # children; i.e., you don't have to copy the list.  We are
    # constructing these nodes so we should have this control for
    # efficiency.
    def become_root(new_root, old_root)
      # System.out.println("becomeroot new "+newRoot.toString()+" old "+oldRoot);
      new_root_tree = new_root
      old_root_tree = old_root
      if ((old_root).nil?)
        return new_root
      end
      # handle ^(nil real-node)
      if (new_root_tree.is_nil)
        nc = new_root_tree.get_child_count
        if ((nc).equal?(1))
          new_root_tree = new_root_tree.get_child(0)
        else
          if (nc > 1)
            # TODO: make tree run time exceptions hierarchy
            raise RuntimeException.new("more than one node as root (TODO: make exception hierarchy)")
          end
        end
      end
      # add oldRoot to newRoot; addChild takes care of case where oldRoot
      # is a flat list (i.e., nil-rooted tree).  All children of oldRoot
      # are added to newRoot.
      new_root_tree.add_child(old_root_tree)
      return new_root_tree
    end
    
    typesig { [Object] }
    # Transform ^(nil x) to x and nil to null
    def rule_post_processing(root)
      # System.out.println("rulePostProcessing: "+((Tree)root).toStringTree());
      r = root
      if (!(r).nil? && r.is_nil)
        if ((r.get_child_count).equal?(0))
          r = nil
        else
          if ((r.get_child_count).equal?(1))
            r = r.get_child(0)
            # whoever invokes rule will set parent and child index
            r.set_parent(nil)
            r.set_child_index(-1)
          end
        end
      end
      return r
    end
    
    typesig { [Token, Object] }
    def become_root(new_root, old_root)
      return become_root(create(new_root), old_root)
    end
    
    typesig { [::Java::Int, Token] }
    def create(token_type, from_token)
      from_token = create_token(from_token)
      # ((ClassicToken)fromToken).setType(tokenType);
      from_token.set_type(token_type)
      t = create(from_token)
      return t
    end
    
    typesig { [::Java::Int, Token, String] }
    def create(token_type, from_token, text)
      from_token = create_token(from_token)
      from_token.set_type(token_type)
      from_token.set_text(text)
      t = create(from_token)
      return t
    end
    
    typesig { [::Java::Int, String] }
    def create(token_type, text)
      from_token = create_token(token_type, text)
      t = create(from_token)
      return t
    end
    
    typesig { [Object] }
    def get_type(t)
      (t).get_type
      return 0
    end
    
    typesig { [Object, ::Java::Int] }
    def set_type(t, type)
      raise NoSuchMethodError.new("don't know enough about Tree node")
    end
    
    typesig { [Object] }
    def get_text(t)
      return (t).get_text
    end
    
    typesig { [Object, String] }
    def set_text(t, text)
      raise NoSuchMethodError.new("don't know enough about Tree node")
    end
    
    typesig { [Object, ::Java::Int] }
    def get_child(t, i)
      return (t).get_child(i)
    end
    
    typesig { [Object, ::Java::Int, Object] }
    def set_child(t, i, child)
      (t).set_child(i, child)
    end
    
    typesig { [Object, ::Java::Int] }
    def delete_child(t, i)
      return (t).delete_child(i)
    end
    
    typesig { [Object] }
    def get_child_count(t)
      return (t).get_child_count
    end
    
    typesig { [Object] }
    def get_unique_id(node)
      if ((@tree_to_unique_idmap).nil?)
        @tree_to_unique_idmap = HashMap.new
      end
      prev_id = @tree_to_unique_idmap.get(node)
      if (!(prev_id).nil?)
        return prev_id.int_value
      end
      id = @unique_node_id
      @tree_to_unique_idmap.put(node, id)
      ((@unique_node_id += 1) - 1)
      return id
      # GC makes these nonunique:
      # return System.identityHashCode(node);
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
      raise NotImplementedError
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
      raise NotImplementedError
    end
    
    typesig { [] }
    def initialize
      @tree_to_unique_idmap = nil
      @unique_node_id = 1
    end
    
    private
    alias_method :initialize__base_tree_adaptor, :initialize
  end
  
end
