require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
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
module Org::Antlr::Test
  module TestTreeNodeStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Runtime, :CommonToken
      include_const ::Org::Antlr::Runtime, :Token
      include ::Org::Antlr::Runtime::Tree
    }
  end
  
  # Test the tree node stream.
  class TestTreeNodeStream < TestTreeNodeStreamImports.const_get :BaseTest
    include_class_members TestTreeNodeStreamImports
    
    typesig { [Object] }
    # Build new stream; let's us override to test other streams.
    def new_stream(t)
      return CommonTreeNodeStream.new(t)
    end
    
    typesig { [] }
    def test_single_node
      t = CommonTree.new(CommonToken.new(101))
      stream = new_stream(t)
      expecting = " 101"
      found = to_nodes_only_string(stream)
      assert_equals(expecting, found)
      expecting = " 101"
      found = RJava.cast_to_string(stream.to_s)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test4_nodes
      # ^(101 ^(102 103) 104)
      t = CommonTree.new(CommonToken.new(101))
      t.add_child(CommonTree.new(CommonToken.new(102)))
      t.get_child(0).add_child(CommonTree.new(CommonToken.new(103)))
      t.add_child(CommonTree.new(CommonToken.new(104)))
      stream = new_stream(t)
      expecting = " 101 102 103 104"
      found = to_nodes_only_string(stream)
      assert_equals(expecting, found)
      expecting = " 101 2 102 2 103 3 104 3"
      found = RJava.cast_to_string(stream.to_s)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_list
      root = CommonTree.new(nil)
      t = CommonTree.new(CommonToken.new(101))
      t.add_child(CommonTree.new(CommonToken.new(102)))
      t.get_child(0).add_child(CommonTree.new(CommonToken.new(103)))
      t.add_child(CommonTree.new(CommonToken.new(104)))
      u = CommonTree.new(CommonToken.new(105))
      root.add_child(t)
      root.add_child(u)
      stream = CommonTreeNodeStream.new(root)
      expecting = " 101 102 103 104 105"
      found = to_nodes_only_string(stream)
      assert_equals(expecting, found)
      expecting = " 101 2 102 2 103 3 104 3 105"
      found = RJava.cast_to_string(stream.to_s)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_flat_list
      root = CommonTree.new(nil)
      root.add_child(CommonTree.new(CommonToken.new(101)))
      root.add_child(CommonTree.new(CommonToken.new(102)))
      root.add_child(CommonTree.new(CommonToken.new(103)))
      stream = CommonTreeNodeStream.new(root)
      expecting = " 101 102 103"
      found = to_nodes_only_string(stream)
      assert_equals(expecting, found)
      expecting = " 101 102 103"
      found = RJava.cast_to_string(stream.to_s)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_list_with_one_node
      root = CommonTree.new(nil)
      root.add_child(CommonTree.new(CommonToken.new(101)))
      stream = CommonTreeNodeStream.new(root)
      expecting = " 101"
      found = to_nodes_only_string(stream)
      assert_equals(expecting, found)
      expecting = " 101"
      found = RJava.cast_to_string(stream.to_s)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_aover_b
      t = CommonTree.new(CommonToken.new(101))
      t.add_child(CommonTree.new(CommonToken.new(102)))
      stream = new_stream(t)
      expecting = " 101 102"
      found = to_nodes_only_string(stream)
      assert_equals(expecting, found)
      expecting = " 101 2 102 3"
      found = RJava.cast_to_string(stream.to_s)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    def test_lt
      # ^(101 ^(102 103) 104)
      t = CommonTree.new(CommonToken.new(101))
      t.add_child(CommonTree.new(CommonToken.new(102)))
      t.get_child(0).add_child(CommonTree.new(CommonToken.new(103)))
      t.add_child(CommonTree.new(CommonToken.new(104)))
      stream = new_stream(t)
      assert_equals(101, (stream._lt(1)).get_type)
      assert_equals(Token::DOWN, (stream._lt(2)).get_type)
      assert_equals(102, (stream._lt(3)).get_type)
      assert_equals(Token::DOWN, (stream._lt(4)).get_type)
      assert_equals(103, (stream._lt(5)).get_type)
      assert_equals(Token::UP, (stream._lt(6)).get_type)
      assert_equals(104, (stream._lt(7)).get_type)
      assert_equals(Token::UP, (stream._lt(8)).get_type)
      assert_equals(Token::EOF, (stream._lt(9)).get_type)
      # check way ahead
      assert_equals(Token::EOF, (stream._lt(100)).get_type)
    end
    
    typesig { [] }
    def test_mark_rewind_entire
      # ^(101 ^(102 103 ^(106 107) ) 104 105)
      # stream has 7 real + 6 nav nodes
      # Sequence of types: 101 DN 102 DN 103 106 DN 107 UP UP 104 105 UP EOF
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r0.add_child(r1)
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r2 = CommonTree.new(CommonToken.new(106))
      r2.add_child(CommonTree.new(CommonToken.new(107)))
      r1.add_child(r2)
      r0.add_child(CommonTree.new(CommonToken.new(104)))
      r0.add_child(CommonTree.new(CommonToken.new(105)))
      stream = CommonTreeNodeStream.new(r0)
      m = stream.mark # MARK
      k = 1
      while k <= 13
        # consume til end
        stream._lt(1)
        stream.consume
        k += 1
      end
      assert_equals(Token::EOF, (stream._lt(1)).get_type)
      assert_equals(Token::UP, (stream._lt(-1)).get_type)
      stream.rewind(m) # REWIND
      # consume til end again :)
      k_ = 1
      while k_ <= 13
        # consume til end
        stream._lt(1)
        stream.consume
        k_ += 1
      end
      assert_equals(Token::EOF, (stream._lt(1)).get_type)
      assert_equals(Token::UP, (stream._lt(-1)).get_type)
    end
    
    typesig { [] }
    def test_mark_rewind_in_middle
      # ^(101 ^(102 103 ^(106 107) ) 104 105)
      # stream has 7 real + 6 nav nodes
      # Sequence of types: 101 DN 102 DN 103 106 DN 107 UP UP 104 105 UP EOF
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r0.add_child(r1)
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r2 = CommonTree.new(CommonToken.new(106))
      r2.add_child(CommonTree.new(CommonToken.new(107)))
      r1.add_child(r2)
      r0.add_child(CommonTree.new(CommonToken.new(104)))
      r0.add_child(CommonTree.new(CommonToken.new(105)))
      stream = CommonTreeNodeStream.new(r0)
      k = 1
      while k <= 7
        # consume til middle
        # System.out.println(((Tree)stream.LT(1)).getType());
        stream.consume
        k += 1
      end
      assert_equals(107, (stream._lt(1)).get_type)
      m = stream.mark # MARK
      stream.consume # consume 107
      stream.consume # consume UP
      stream.consume # consume UP
      stream.consume # consume 104
      stream.rewind(m) # REWIND
      assert_equals(107, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(Token::UP, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(Token::UP, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(104, (stream._lt(1)).get_type)
      stream.consume
      # now we're past rewind position
      assert_equals(105, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(Token::UP, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(Token::EOF, (stream._lt(1)).get_type)
      assert_equals(Token::UP, (stream._lt(-1)).get_type)
    end
    
    typesig { [] }
    def test_mark_rewind_nested
      # ^(101 ^(102 103 ^(106 107) ) 104 105)
      # stream has 7 real + 6 nav nodes
      # Sequence of types: 101 DN 102 DN 103 106 DN 107 UP UP 104 105 UP EOF
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r0.add_child(r1)
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r2 = CommonTree.new(CommonToken.new(106))
      r2.add_child(CommonTree.new(CommonToken.new(107)))
      r1.add_child(r2)
      r0.add_child(CommonTree.new(CommonToken.new(104)))
      r0.add_child(CommonTree.new(CommonToken.new(105)))
      stream = CommonTreeNodeStream.new(r0)
      m = stream.mark # MARK at start
      stream.consume # consume 101
      stream.consume # consume DN
      m2 = stream.mark # MARK on 102
      stream.consume # consume 102
      stream.consume # consume DN
      stream.consume # consume 103
      stream.consume # consume 106
      stream.rewind(m2) # REWIND to 102
      assert_equals(102, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(Token::DOWN, (stream._lt(1)).get_type)
      stream.consume
      # stop at 103 and rewind to start
      stream.rewind(m) # REWIND to 101
      assert_equals(101, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(Token::DOWN, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(102, (stream._lt(1)).get_type)
      stream.consume
      assert_equals(Token::DOWN, (stream._lt(1)).get_type)
    end
    
    typesig { [] }
    def test_seek
      # ^(101 ^(102 103 ^(106 107) ) 104 105)
      # stream has 7 real + 6 nav nodes
      # Sequence of types: 101 DN 102 DN 103 106 DN 107 UP UP 104 105 UP EOF
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r0.add_child(r1)
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r2 = CommonTree.new(CommonToken.new(106))
      r2.add_child(CommonTree.new(CommonToken.new(107)))
      r1.add_child(r2)
      r0.add_child(CommonTree.new(CommonToken.new(104)))
      r0.add_child(CommonTree.new(CommonToken.new(105)))
      stream = CommonTreeNodeStream.new(r0)
      stream.consume # consume 101
      stream.consume # consume DN
      stream.consume # consume 102
      stream.seek(7) # seek to 107
      assert_equals(107, (stream._lt(1)).get_type)
      stream.consume # consume 107
      stream.consume # consume UP
      stream.consume # consume UP
      assert_equals(104, (stream._lt(1)).get_type)
    end
    
    typesig { [] }
    def test_seek_from_start
      # ^(101 ^(102 103 ^(106 107) ) 104 105)
      # stream has 7 real + 6 nav nodes
      # Sequence of types: 101 DN 102 DN 103 106 DN 107 UP UP 104 105 UP EOF
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r0.add_child(r1)
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r2 = CommonTree.new(CommonToken.new(106))
      r2.add_child(CommonTree.new(CommonToken.new(107)))
      r1.add_child(r2)
      r0.add_child(CommonTree.new(CommonToken.new(104)))
      r0.add_child(CommonTree.new(CommonToken.new(105)))
      stream = CommonTreeNodeStream.new(r0)
      stream.seek(7) # seek to 107
      assert_equals(107, (stream._lt(1)).get_type)
      stream.consume # consume 107
      stream.consume # consume UP
      stream.consume # consume UP
      assert_equals(104, (stream._lt(1)).get_type)
    end
    
    typesig { [TreeNodeStream] }
    def to_nodes_only_string(nodes)
      buf = StringBuffer.new
      i = 0
      while i < nodes.size
        t = nodes._lt(i + 1)
        type = nodes.get_tree_adaptor.get_type(t)
        if (!((type).equal?(Token::DOWN) || (type).equal?(Token::UP)))
          buf.append(" ")
          buf.append(type)
        end
        i += 1
      end
      return buf.to_s
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_tree_node_stream, :initialize
  end
  
end
