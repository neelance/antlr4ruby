require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
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
module Org::Antlr::Test
  module TestTreesImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :CommonToken
      include_const ::Org::Antlr::Runtime, :Token
    }
  end
  
  class TestTrees < TestTreesImports.const_get :BaseTest
    include_class_members TestTreesImports
    
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    class_module.module_eval {
      const_set_lazy(:V) { Class.new(CommonTree) do
        include_class_members TestTrees
        
        attr_accessor :x
        alias_method :attr_x, :x
        undef_method :x
        alias_method :attr_x=, :x=
        undef_method :x=
        
        typesig { [self::Token] }
        def initialize(t)
          @x = 0
          super()
          self.attr_token = t
        end
        
        typesig { [::Java::Int, ::Java::Int] }
        def initialize(ttype, x)
          @x = 0
          super()
          @x = x
          self.attr_token = self.class::CommonToken.new(ttype)
        end
        
        typesig { [::Java::Int, self::Token, ::Java::Int] }
        def initialize(ttype, t, x)
          @x = 0
          super()
          self.attr_token = t
          @x = x
        end
        
        typesig { [] }
        def to_s
          return RJava.cast_to_string((!(self.attr_token).nil? ? self.attr_token.get_text : "")) + "<V>"
        end
        
        private
        alias_method :initialize__v, :initialize
      end }
    }
    
    typesig { [] }
    def test_single_node
      t = CommonTree.new(CommonToken.new(101))
      assert_null(t.attr_parent)
      assert_equals(-1, t.attr_child_index)
    end
    
    typesig { [] }
    def test_two_children_of_nil_root
      root_0 = @adaptor.nil_
      t = V.new(101, 2)
      u = V.new(CommonToken.new(102, "102"))
      @adaptor.add_child(root_0, t)
      @adaptor.add_child(root_0, u)
      assert_null(root_0.attr_parent)
      assert_equals(-1, root_0.attr_child_index)
      assert_equals(0, t.attr_child_index)
      assert_equals(1, u.attr_child_index)
    end
    
    typesig { [] }
    def test4_nodes
      # ^(101 ^(102 103) 104)
      r0 = CommonTree.new(CommonToken.new(101))
      r0.add_child(CommonTree.new(CommonToken.new(102)))
      r0.get_child(0).add_child(CommonTree.new(CommonToken.new(103)))
      r0.add_child(CommonTree.new(CommonToken.new(104)))
      assert_null(r0.attr_parent)
      assert_equals(-1, r0.attr_child_index)
    end
    
    typesig { [] }
    def test_list
      # ^(nil 101 102 103)
      r0 = CommonTree.new(nil)
      c0 = nil
      c1 = nil
      c2 = nil
      r0.add_child(c0 = CommonTree.new(CommonToken.new(101)))
      r0.add_child(c1 = CommonTree.new(CommonToken.new(102)))
      r0.add_child(c2 = CommonTree.new(CommonToken.new(103)))
      assert_null(r0.attr_parent)
      assert_equals(-1, r0.attr_child_index)
      assert_equals(r0, c0.attr_parent)
      assert_equals(0, c0.attr_child_index)
      assert_equals(r0, c1.attr_parent)
      assert_equals(1, c1.attr_child_index)
      assert_equals(r0, c2.attr_parent)
      assert_equals(2, c2.attr_child_index)
    end
    
    typesig { [] }
    def test_list2
      # Add child ^(nil 101 102 103) to root 5
      # should pull 101 102 103 directly to become 5's child list
      root = CommonTree.new(CommonToken.new(5))
      # child tree
      r0 = CommonTree.new(nil)
      c0 = nil
      c1 = nil
      c2 = nil
      r0.add_child(c0 = CommonTree.new(CommonToken.new(101)))
      r0.add_child(c1 = CommonTree.new(CommonToken.new(102)))
      r0.add_child(c2 = CommonTree.new(CommonToken.new(103)))
      root.add_child(r0)
      assert_null(root.attr_parent)
      assert_equals(-1, root.attr_child_index)
      # check children of root all point at root
      assert_equals(root, c0.attr_parent)
      assert_equals(0, c0.attr_child_index)
      assert_equals(root, c0.attr_parent)
      assert_equals(1, c1.attr_child_index)
      assert_equals(root, c0.attr_parent)
      assert_equals(2, c2.attr_child_index)
    end
    
    typesig { [] }
    def test_add_list_to_exist_children
      # Add child ^(nil 101 102 103) to root ^(5 6)
      # should add 101 102 103 to end of 5's child list
      root = CommonTree.new(CommonToken.new(5))
      root.add_child(CommonTree.new(CommonToken.new(6)))
      # child tree
      r0 = CommonTree.new(nil)
      c0 = nil
      c1 = nil
      c2 = nil
      r0.add_child(c0 = CommonTree.new(CommonToken.new(101)))
      r0.add_child(c1 = CommonTree.new(CommonToken.new(102)))
      r0.add_child(c2 = CommonTree.new(CommonToken.new(103)))
      root.add_child(r0)
      assert_null(root.attr_parent)
      assert_equals(-1, root.attr_child_index)
      # check children of root all point at root
      assert_equals(root, c0.attr_parent)
      assert_equals(1, c0.attr_child_index)
      assert_equals(root, c0.attr_parent)
      assert_equals(2, c1.attr_child_index)
      assert_equals(root, c0.attr_parent)
      assert_equals(3, c2.attr_child_index)
    end
    
    typesig { [] }
    def test_dup_tree
      # ^(101 ^(102 103 ^(106 107) ) 104 105)
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r0.add_child(r1)
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r2 = CommonTree.new(CommonToken.new(106))
      r2.add_child(CommonTree.new(CommonToken.new(107)))
      r1.add_child(r2)
      r0.add_child(CommonTree.new(CommonToken.new(104)))
      r0.add_child(CommonTree.new(CommonToken.new(105)))
      dup = (CommonTreeAdaptor.new).dup_tree(r0)
      assert_null(dup.attr_parent)
      assert_equals(-1, dup.attr_child_index)
      dup.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_become_root
      # 5 becomes new root of ^(nil 101 102 103)
      new_root = CommonTree.new(CommonToken.new(5))
      old_root = CommonTree.new(nil)
      old_root.add_child(CommonTree.new(CommonToken.new(101)))
      old_root.add_child(CommonTree.new(CommonToken.new(102)))
      old_root.add_child(CommonTree.new(CommonToken.new(103)))
      adaptor = CommonTreeAdaptor.new
      adaptor.become_root(new_root, old_root)
      new_root.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_become_root2
      # 5 becomes new root of ^(101 102 103)
      new_root = CommonTree.new(CommonToken.new(5))
      old_root = CommonTree.new(CommonToken.new(101))
      old_root.add_child(CommonTree.new(CommonToken.new(102)))
      old_root.add_child(CommonTree.new(CommonToken.new(103)))
      adaptor = CommonTreeAdaptor.new
      adaptor.become_root(new_root, old_root)
      new_root.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_become_root3
      # ^(nil 5) becomes new root of ^(nil 101 102 103)
      new_root = CommonTree.new(nil)
      new_root.add_child(CommonTree.new(CommonToken.new(5)))
      old_root = CommonTree.new(nil)
      old_root.add_child(CommonTree.new(CommonToken.new(101)))
      old_root.add_child(CommonTree.new(CommonToken.new(102)))
      old_root.add_child(CommonTree.new(CommonToken.new(103)))
      adaptor = CommonTreeAdaptor.new
      adaptor.become_root(new_root, old_root)
      new_root.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_become_root5
      # ^(nil 5) becomes new root of ^(101 102 103)
      new_root = CommonTree.new(nil)
      new_root.add_child(CommonTree.new(CommonToken.new(5)))
      old_root = CommonTree.new(CommonToken.new(101))
      old_root.add_child(CommonTree.new(CommonToken.new(102)))
      old_root.add_child(CommonTree.new(CommonToken.new(103)))
      adaptor = CommonTreeAdaptor.new
      adaptor.become_root(new_root, old_root)
      new_root.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_become_root6
      # emulates construction of ^(5 6)
      root_0 = @adaptor.nil_
      root_1 = @adaptor.nil_
      root_1 = @adaptor.become_root(CommonTree.new(CommonToken.new(5)), root_1)
      @adaptor.add_child(root_1, CommonTree.new(CommonToken.new(6)))
      @adaptor.add_child(root_0, root_1)
      root_0.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    # Test replaceChildren
    def test_replace_with_no_children
      t = CommonTree.new(CommonToken.new(101))
      new_child = CommonTree.new(CommonToken.new(5))
      error = false
      begin
        t.replace_children(0, 0, new_child)
      rescue IllegalArgumentException => iae
        error = true
      end
      assert_true(error)
    end
    
    typesig { [] }
    def test_replace_with_one_children
      # assume token type 99 and use text
      t = CommonTree.new(CommonToken.new(99, "a"))
      c0 = CommonTree.new(CommonToken.new(99, "b"))
      t.add_child(c0)
      new_child = CommonTree.new(CommonToken.new(99, "c"))
      t.replace_children(0, 0, new_child)
      expecting = "(a c)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_in_middle
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c"))) # index 1
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_child = CommonTree.new(CommonToken.new(99, "x"))
      t.replace_children(1, 1, new_child)
      expecting = "(a b x d)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_at_left
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b"))) # index 0
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_child = CommonTree.new(CommonToken.new(99, "x"))
      t.replace_children(0, 0, new_child)
      expecting = "(a x c d)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_at_right
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d"))) # index 2
      new_child = CommonTree.new(CommonToken.new(99, "x"))
      t.replace_children(2, 2, new_child)
      expecting = "(a b c x)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_one_with_two_at_left
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_children = @adaptor.nil_
      new_children.add_child(CommonTree.new(CommonToken.new(99, "x")))
      new_children.add_child(CommonTree.new(CommonToken.new(99, "y")))
      t.replace_children(0, 0, new_children)
      expecting = "(a x y c d)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_one_with_two_at_right
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_children = @adaptor.nil_
      new_children.add_child(CommonTree.new(CommonToken.new(99, "x")))
      new_children.add_child(CommonTree.new(CommonToken.new(99, "y")))
      t.replace_children(2, 2, new_children)
      expecting = "(a b c x y)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_one_with_two_in_middle
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_children = @adaptor.nil_
      new_children.add_child(CommonTree.new(CommonToken.new(99, "x")))
      new_children.add_child(CommonTree.new(CommonToken.new(99, "y")))
      t.replace_children(1, 1, new_children)
      expecting = "(a b x y d)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_two_with_one_at_left
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_child = CommonTree.new(CommonToken.new(99, "x"))
      t.replace_children(0, 1, new_child)
      expecting = "(a x d)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_two_with_one_at_right
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_child = CommonTree.new(CommonToken.new(99, "x"))
      t.replace_children(1, 2, new_child)
      expecting = "(a b x)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_all_with_one
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_child = CommonTree.new(CommonToken.new(99, "x"))
      t.replace_children(0, 2, new_child)
      expecting = "(a x)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def test_replace_all_with_two
      t = CommonTree.new(CommonToken.new(99, "a"))
      t.add_child(CommonTree.new(CommonToken.new(99, "b")))
      t.add_child(CommonTree.new(CommonToken.new(99, "c")))
      t.add_child(CommonTree.new(CommonToken.new(99, "d")))
      new_children = @adaptor.nil_
      new_children.add_child(CommonTree.new(CommonToken.new(99, "x")))
      new_children.add_child(CommonTree.new(CommonToken.new(99, "y")))
      t.replace_children(0, 2, new_children)
      expecting = "(a x y)"
      assert_equals(expecting, t.to_string_tree)
      t.sanity_check_parent_and_child_indexes
    end
    
    typesig { [] }
    def initialize
      @adaptor = nil
      @debug = false
      super()
      @adaptor = CommonTreeAdaptor.new
      @debug = false
    end
    
    private
    alias_method :initialize__test_trees, :initialize
  end
  
end
