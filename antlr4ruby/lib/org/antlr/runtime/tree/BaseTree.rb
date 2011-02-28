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
module Org::Antlr::Runtime::Tree
  module BaseTreeImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :JavaList
    }
  end
  
  # A generic tree implementation with no payload.  You must subclass to
  # actually have any user data.  ANTLR v3 uses a list of children approach
  # instead of the child-sibling approach in v2.  A flat tree (a list) is
  # an empty node whose children represent the list.  An empty, but
  # non-null node is called "nil".
  class BaseTree 
    include_class_members BaseTreeImports
    include Tree
    
    attr_accessor :children
    alias_method :attr_children, :children
    undef_method :children
    alias_method :attr_children=, :children=
    undef_method :children=
    
    typesig { [] }
    def initialize
      @children = nil
    end
    
    typesig { [Tree] }
    # Create a new node from an existing node does nothing for BaseTree
    # as there are no fields other than the children list, which cannot
    # be copied as the children are not considered part of this node.
    def initialize(node)
      @children = nil
    end
    
    typesig { [::Java::Int] }
    def get_child(i)
      if ((@children).nil? || i >= @children.size)
        return nil
      end
      return @children.get(i)
    end
    
    typesig { [] }
    # Get the children internal List; note that if you directly mess with
    # the list, do so at your own risk.
    def get_children
      return @children
    end
    
    typesig { [::Java::Int] }
    def get_first_child_with_type(type)
      i = 0
      while !(@children).nil? && i < @children.size
        t = @children.get(i)
        if ((t.get_type).equal?(type))
          return t
        end
        i += 1
      end
      return nil
    end
    
    typesig { [] }
    def get_child_count
      if ((@children).nil?)
        return 0
      end
      return @children.size
    end
    
    typesig { [Tree] }
    # Add t as child of this node.
    # 
    # Warning: if t has no children, but child does
    # and child isNil then this routine moves children to t via
    # t.children = child.children; i.e., without copying the array.
    def add_child(t)
      # System.out.println("add child "+t.toStringTree()+" "+this.toStringTree());
      # System.out.println("existing children: "+children);
      if ((t).nil?)
        return # do nothing upon addChild(null)
      end
      child_tree = t
      if (child_tree.is_nil)
        # t is an empty node possibly with children
        if (!(@children).nil? && (@children).equal?(child_tree.attr_children))
          raise RuntimeException.new("attempt to add child list to itself")
        end
        # just add all of childTree's children to this
        if (!(child_tree.attr_children).nil?)
          if (!(@children).nil?)
            # must copy, this has children already
            n = child_tree.attr_children.size
            i = 0
            while i < n
              c = child_tree.attr_children.get(i)
              @children.add(c)
              # handle double-link stuff for each child of nil root
              c.set_parent(self)
              c.set_child_index(@children.size - 1)
              i += 1
            end
          else
            # no children for this but t has children; just set pointer
            # call general freshener routine
            @children = child_tree.attr_children
            self.freshen_parent_and_child_indexes
          end
        end
      else
        # child is not nil (don't care about children)
        if ((@children).nil?)
          @children = create_children_list # create children list on demand
        end
        @children.add(t)
        child_tree.set_parent(self)
        child_tree.set_child_index(@children.size - 1)
      end
      # System.out.println("now children are: "+children);
    end
    
    typesig { [JavaList] }
    # Add all elements of kids list as children of this node
    def add_children(kids)
      i = 0
      while i < kids.size
        t = kids.get(i)
        add_child(t)
        i += 1
      end
    end
    
    typesig { [::Java::Int, Tree] }
    def set_child(i, t)
      if ((t).nil?)
        return
      end
      if (t.is_nil)
        raise IllegalArgumentException.new("Can't set single child to a list")
      end
      if ((@children).nil?)
        @children = create_children_list
      end
      @children.set(i, t)
      t.set_parent(self)
      t.set_child_index(i)
    end
    
    typesig { [::Java::Int] }
    def delete_child(i)
      if ((@children).nil?)
        return nil
      end
      killed = @children.remove(i)
      # walk rest and decrement their child indexes
      self.freshen_parent_and_child_indexes(i)
      return killed
    end
    
    typesig { [::Java::Int, ::Java::Int, Object] }
    # Delete children from start to stop and replace with t even if t is
    # a list (nil-root tree).  num of children can increase or decrease.
    # For huge child lists, inserting children can force walking rest of
    # children to set their childindex; could be slow.
    def replace_children(start_child_index, stop_child_index, t)
      # 		System.out.println("replaceChildren "+startChildIndex+", "+stopChildIndex+
      # 						   " with "+((BaseTree)t).toStringTree());
      # 		System.out.println("in="+toStringTree());
      if ((@children).nil?)
        raise IllegalArgumentException.new("indexes invalid; no children in list")
      end
      replacing_how_many = stop_child_index - start_child_index + 1
      replacing_with_how_many = 0
      new_tree = t
      new_children = nil
      # normalize to a list of children to add: newChildren
      if (new_tree.is_nil)
        new_children = new_tree.attr_children
      else
        new_children = ArrayList.new(1)
        new_children.add(new_tree)
      end
      replacing_with_how_many = new_children.size
      num_new_children = new_children.size
      delta = replacing_how_many - replacing_with_how_many
      # if same number of nodes, do direct replace
      if ((delta).equal?(0))
        j = 0 # index into new children
        i = start_child_index
        while i <= stop_child_index
          child = new_children.get(j)
          @children.set(i, child)
          child.set_parent(self)
          child.set_child_index(i)
          j += 1
          i += 1
        end
      else
        if (delta > 0)
          # fewer new nodes than there were
          # set children and then delete extra
          j = 0
          while j < num_new_children
            @children.set(start_child_index + j, new_children.get(j))
            j += 1
          end
          index_to_delete = start_child_index + num_new_children
          c = index_to_delete
          while c <= stop_child_index
            # delete same index, shifting everybody down each time
            killed = @children.remove(index_to_delete)
            c += 1
          end
          freshen_parent_and_child_indexes(start_child_index)
        else
          # more new nodes than were there before
          # fill in as many children as we can (replacingHowMany) w/o moving data
          j = 0
          while j < replacing_how_many
            @children.set(start_child_index + j, new_children.get(j))
            j += 1
          end
          num_to_insert = replacing_with_how_many - replacing_how_many
          j_ = replacing_how_many
          while j_ < replacing_with_how_many
            @children.add(start_child_index + j_, new_children.get(j_))
            j_ += 1
          end
          freshen_parent_and_child_indexes(start_child_index)
        end
      end
      # System.out.println("out="+toStringTree());
    end
    
    typesig { [] }
    # Override in a subclass to change the impl of children list
    def create_children_list
      return ArrayList.new
    end
    
    typesig { [] }
    def is_nil
      return false
    end
    
    typesig { [] }
    # Set the parent and child index values for all child of t
    def freshen_parent_and_child_indexes
      freshen_parent_and_child_indexes(0)
    end
    
    typesig { [::Java::Int] }
    def freshen_parent_and_child_indexes(offset)
      n = get_child_count
      c = offset
      while c < n
        child = get_child(c)
        child.set_child_index(c)
        child.set_parent(self)
        c += 1
      end
    end
    
    typesig { [] }
    def sanity_check_parent_and_child_indexes
      sanity_check_parent_and_child_indexes(nil, -1)
    end
    
    typesig { [Tree, ::Java::Int] }
    def sanity_check_parent_and_child_indexes(parent, i)
      if (!(parent).equal?(self.get_parent))
        raise IllegalStateException.new("parents don't match; expected " + RJava.cast_to_string(parent) + " found " + RJava.cast_to_string(self.get_parent))
      end
      if (!(i).equal?(self.get_child_index))
        raise IllegalStateException.new("child indexes don't match; expected " + RJava.cast_to_string(i) + " found " + RJava.cast_to_string(self.get_child_index))
      end
      n = self.get_child_count
      c = 0
      while c < n
        child = self.get_child(c)
        child.sanity_check_parent_and_child_indexes(self, c)
        c += 1
      end
    end
    
    typesig { [] }
    # BaseTree doesn't track child indexes.
    def get_child_index
      return 0
    end
    
    typesig { [::Java::Int] }
    def set_child_index(index)
    end
    
    typesig { [] }
    # BaseTree doesn't track parent pointers.
    def get_parent
      return nil
    end
    
    typesig { [Tree] }
    def set_parent(t)
    end
    
    typesig { [] }
    # Print out a whole tree not just a node
    def to_string_tree
      if ((@children).nil? || (@children.size).equal?(0))
        return self.to_s
      end
      buf = StringBuffer.new
      if (!is_nil)
        buf.append("(")
        buf.append(self.to_s)
        buf.append(Character.new(?\s.ord))
      end
      i = 0
      while !(@children).nil? && i < @children.size
        t = @children.get(i)
        if (i > 0)
          buf.append(Character.new(?\s.ord))
        end
        buf.append(t.to_string_tree)
        i += 1
      end
      if (!is_nil)
        buf.append(")")
      end
      return buf.to_s
    end
    
    typesig { [] }
    def get_line
      return 0
    end
    
    typesig { [] }
    def get_char_position_in_line
      return 0
    end
    
    typesig { [] }
    # Override to say how a node (not a tree) should look as text
    def to_s
      raise NotImplementedError
    end
    
    private
    alias_method :initialize__base_tree, :initialize
  end
  
end
