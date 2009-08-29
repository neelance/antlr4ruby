require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2007 Terence Parr
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
  module TestTreeWizardImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include ::Org::Antlr::Runtime::Tree
      include_const ::Java::Util, :Map
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :HashMap
    }
  end
  
  class TestTreeWizard < TestTreeWizardImports.const_get :BaseTest
    include_class_members TestTreeWizardImports
    
    class_module.module_eval {
      const_set_lazy(:Tokens) { Array.typed(String).new(["", "", "", "", "", "A", "B", "C", "D", "E", "ID", "VAR"]) }
      const_attr_reader  :Tokens
      
      const_set_lazy(:Adaptor) { CommonTreeAdaptor.new }
      const_attr_reader  :Adaptor
    }
    
    typesig { [] }
    def test_single_node
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("ID")
      found = t.to_string_tree
      expecting = "ID"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_single_node_with_arg
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("ID[foo]")
      found = t.to_string_tree
      expecting = "foo"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_single_node_tree
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A)")
      found = t.to_string_tree
      expecting = "A"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_single_level_tree
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C D)")
      found = t.to_string_tree
      expecting = "(A B C D)"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_list_tree
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(nil A B C)")
      found = t.to_string_tree
      expecting = "A B C"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_invalid_list_tree
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("A B C")
      assert_true((t).nil?)
    end
    
    typesig { [] }
    def test_double_level_tree
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A (B C) (B D) E)")
      found = t.to_string_tree
      expecting = "(A (B C) (B D) E)"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_single_node_index
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("ID")
      m = wiz.index(t)
      found = m.to_s
      expecting = "{10=[ID]}"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_no_repeats_index
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C D)")
      m = wiz.index(t)
      found = m.to_s
      expecting = "{8=[D], 6=[B], 7=[C], 5=[A]}"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_repeats_index
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B (A C B) B D D)")
      m = wiz.index(t)
      found = m.to_s
      expecting = "{8=[D, D], 6=[B, B, B], 7=[C], 5=[A, A]}"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_no_repeats_visit
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C D)")
      elements = ArrayList.new
      wiz.visit(t, wiz.get_token_type("B"), Class.new(TreeWizard::Visitor.class == Class ? TreeWizard::Visitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::Visitor if TreeWizard::Visitor.class == Module
        
        typesig { [Object] }
        define_method :visit do |t|
          elements.add(t)
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[B]"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_no_repeats_visit2
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B (A C B) B D D)")
      elements = ArrayList.new
      wiz.visit(t, wiz.get_token_type("C"), Class.new(TreeWizard::Visitor.class == Class ? TreeWizard::Visitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::Visitor if TreeWizard::Visitor.class == Module
        
        typesig { [Object] }
        define_method :visit do |t|
          elements.add(t)
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[C]"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_repeats_visit
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B (A C B) B D D)")
      elements = ArrayList.new
      wiz.visit(t, wiz.get_token_type("B"), Class.new(TreeWizard::Visitor.class == Class ? TreeWizard::Visitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::Visitor if TreeWizard::Visitor.class == Module
        
        typesig { [Object] }
        define_method :visit do |t|
          elements.add(t)
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[B, B, B]"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_repeats_visit2
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B (A C B) B D D)")
      elements = ArrayList.new
      wiz.visit(t, wiz.get_token_type("A"), Class.new(TreeWizard::Visitor.class == Class ? TreeWizard::Visitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::Visitor if TreeWizard::Visitor.class == Module
        
        typesig { [Object] }
        define_method :visit do |t|
          elements.add(t)
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[A, A]"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_repeats_visit_with_context
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B (A C B) B D D)")
      elements = ArrayList.new
      wiz.visit(t, wiz.get_token_type("B"), Class.new(TreeWizard::ContextVisitor.class == Class ? TreeWizard::ContextVisitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::ContextVisitor if TreeWizard::ContextVisitor.class == Module
        
        typesig { [Object, Object, ::Java::Int, Map] }
        define_method :visit do |t, parent, child_index, labels|
          elements.add(RJava.cast_to_string(Adaptor.get_text(t)) + "@" + RJava.cast_to_string((!(parent).nil? ? Adaptor.get_text(parent) : "nil")) + "[" + RJava.cast_to_string(child_index) + "]")
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[B@A[0], B@A[1], B@A[2]]"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_repeats_visit_with_null_parent_and_context
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B (A C B) B D D)")
      elements = ArrayList.new
      wiz.visit(t, wiz.get_token_type("A"), Class.new(TreeWizard::ContextVisitor.class == Class ? TreeWizard::ContextVisitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::ContextVisitor if TreeWizard::ContextVisitor.class == Module
        
        typesig { [Object, Object, ::Java::Int, Map] }
        define_method :visit do |t, parent, child_index, labels|
          elements.add(RJava.cast_to_string(Adaptor.get_text(t)) + "@" + RJava.cast_to_string((!(parent).nil? ? Adaptor.get_text(parent) : "nil")) + "[" + RJava.cast_to_string(child_index) + "]")
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[A@nil[0], A@A[1]]"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_visit_pattern
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C (A B) D)")
      elements = ArrayList.new
      wiz.visit(t, "(A B)", Class.new(TreeWizard::Visitor.class == Class ? TreeWizard::Visitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::Visitor if TreeWizard::Visitor.class == Module
        
        typesig { [Object] }
        define_method :visit do |t|
          elements.add(t)
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[A]" # shouldn't match overall root, just (A B)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_visit_pattern_multiple
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C (A B) (D (A B)))")
      elements = ArrayList.new
      wiz.visit(t, "(A B)", Class.new(TreeWizard::ContextVisitor.class == Class ? TreeWizard::ContextVisitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::ContextVisitor if TreeWizard::ContextVisitor.class == Module
        
        typesig { [Object, Object, ::Java::Int, Map] }
        define_method :visit do |t, parent, child_index, labels|
          elements.add(RJava.cast_to_string(Adaptor.get_text(t)) + "@" + RJava.cast_to_string((!(parent).nil? ? Adaptor.get_text(parent) : "nil")) + "[" + RJava.cast_to_string(child_index) + "]")
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[A@A[2], A@D[0]]" # shouldn't match overall root, just (A B)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_visit_pattern_multiple_with_labels
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C (A[foo] B[bar]) (D (A[big] B[dog])))")
      elements = ArrayList.new
      wiz.visit(t, "(%a:A %b:B)", Class.new(TreeWizard::ContextVisitor.class == Class ? TreeWizard::ContextVisitor : Object) do
        extend LocalClass
        include_class_members TestTreeWizard
        include TreeWizard::ContextVisitor if TreeWizard::ContextVisitor.class == Module
        
        typesig { [Object, Object, ::Java::Int, Map] }
        define_method :visit do |t, parent, child_index, labels|
          elements.add(RJava.cast_to_string(Adaptor.get_text(t)) + "@" + RJava.cast_to_string((!(parent).nil? ? Adaptor.get_text(parent) : "nil")) + "[" + RJava.cast_to_string(child_index) + "]" + RJava.cast_to_string(labels.get("a")) + "&" + RJava.cast_to_string(labels.get("b")))
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      found = elements.to_s
      expecting = "[foo@A[2]foo&bar, big@D[0]big&dog]"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_parse
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C)")
      valid = wiz.parse(t, "(A B C)")
      assert_true(valid)
    end
    
    typesig { [] }
    def test_parse_single_node
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("A")
      valid = wiz.parse(t, "A")
      assert_true(valid)
    end
    
    typesig { [] }
    def test_parse_flat_tree
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(nil A B C)")
      valid = wiz.parse(t, "(nil A B C)")
      assert_true(valid)
    end
    
    typesig { [] }
    def test_wildcard
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C)")
      valid = wiz.parse(t, "(A . .)")
      assert_true(valid)
    end
    
    typesig { [] }
    def test_parse_with_text
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B[foo] C[bar])")
      # C pattern has no text arg so despite [bar] in t, no need
      # to match text--check structure only.
      valid = wiz.parse(t, "(A B[foo] C)")
      assert_true(valid)
    end
    
    typesig { [] }
    def test_parse_with_text_fails
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C)")
      valid = wiz.parse(t, "(A[foo] B C)")
      assert_true(!valid) # fails
    end
    
    typesig { [] }
    def test_parse_labels
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C)")
      labels = HashMap.new
      valid = wiz.parse(t, "(%a:A %b:B %c:C)", labels)
      assert_true(valid)
      assert_equals("A", labels.get("a").to_s)
      assert_equals("B", labels.get("b").to_s)
      assert_equals("C", labels.get("c").to_s)
    end
    
    typesig { [] }
    def test_parse_with_wildcard_labels
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C)")
      labels = HashMap.new
      valid = wiz.parse(t, "(A %b:. %c:.)", labels)
      assert_true(valid)
      assert_equals("B", labels.get("b").to_s)
      assert_equals("C", labels.get("c").to_s)
    end
    
    typesig { [] }
    def test_parse_labels_and_test_text
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B[foo] C)")
      labels = HashMap.new
      valid = wiz.parse(t, "(%a:A %b:B[foo] %c:C)", labels)
      assert_true(valid)
      assert_equals("A", labels.get("a").to_s)
      assert_equals("foo", labels.get("b").to_s)
      assert_equals("C", labels.get("c").to_s)
    end
    
    typesig { [] }
    def test_parse_labels_in_nested_tree
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A (B C) (D E))")
      labels = HashMap.new
      valid = wiz.parse(t, "(%a:A (%b:B %c:C) (%d:D %e:E) )", labels)
      assert_true(valid)
      assert_equals("A", labels.get("a").to_s)
      assert_equals("B", labels.get("b").to_s)
      assert_equals("C", labels.get("c").to_s)
      assert_equals("D", labels.get("d").to_s)
      assert_equals("E", labels.get("e").to_s)
    end
    
    typesig { [] }
    def test_equals
      wiz = TreeWizard.new(Adaptor, Tokens)
      t1 = wiz.create("(A B C)")
      t2 = wiz.create("(A B C)")
      same = (TreeWizard == t1)
      assert_true(same)
    end
    
    typesig { [] }
    def test_equals_with_text
      wiz = TreeWizard.new(Adaptor, Tokens)
      t1 = wiz.create("(A B[foo] C)")
      t2 = wiz.create("(A B[foo] C)")
      same = (TreeWizard == t1)
      assert_true(same)
    end
    
    typesig { [] }
    def test_equals_with_mismatched_text
      wiz = TreeWizard.new(Adaptor, Tokens)
      t1 = wiz.create("(A B[foo] C)")
      t2 = wiz.create("(A B C)")
      same = (TreeWizard == t1)
      assert_true(!same)
    end
    
    typesig { [] }
    def test_find_pattern
      wiz = TreeWizard.new(Adaptor, Tokens)
      t = wiz.create("(A B C (A[foo] B[bar]) (D (A[big] B[dog])))")
      subtrees = wiz.find(t, "(A B)")
      elements = subtrees
      found = elements.to_s
      expecting = "[foo, big]"
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_tree_wizard, :initialize
  end
  
end
