require "rjava"

# 
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
  module TestCommonTreeNodeStreamImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Runtime, :CommonToken
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime::Tree, :CommonTree
      include_const ::Org::Antlr::Runtime::Tree, :CommonTreeNodeStream
      include_const ::Org::Antlr::Runtime::Tree, :Tree
    }
  end
  
  # Tests specific to CommonTreeNodeStream
  class TestCommonTreeNodeStream < TestCommonTreeNodeStreamImports.const_get :TestTreeNodeStream
    include_class_members TestCommonTreeNodeStreamImports
    
    typesig { [] }
    def test_push_pop
      # ^(101 ^(102 103) ^(104 105) ^(106 107) 108 109)
      # stream has 9 real + 8 nav nodes
      # Sequence of types: 101 DN 102 DN 103 UP 104 DN 105 UP 106 DN 107 UP 108 109 UP
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r0.add_child(r1)
      r2 = CommonTree.new(CommonToken.new(104))
      r2.add_child(CommonTree.new(CommonToken.new(105)))
      r0.add_child(r2)
      r3 = CommonTree.new(CommonToken.new(106))
      r3.add_child(CommonTree.new(CommonToken.new(107)))
      r0.add_child(r3)
      r0.add_child(CommonTree.new(CommonToken.new(108)))
      r0.add_child(CommonTree.new(CommonToken.new(109)))
      stream = CommonTreeNodeStream.new(r0)
      expecting = " 101 2 102 2 103 3 104 2 105 3 106 2 107 3 108 109 3"
      found = stream.to_s
      assert_equals(expecting, found)
      # Assume we want to hit node 107 and then "call 102" then return
      index_of102 = 2
      index_of107 = 12
      k = 1
      while k <= index_of107
        # consume til 107 node
        stream.consume
        ((k += 1) - 1)
      end
      # CALL 102
      assert_equals(107, (stream._lt(1)).get_type)
      stream.push(index_of102)
      assert_equals(102, (stream._lt(1)).get_type)
      stream.consume # consume 102
      assert_equals(Token::DOWN, (stream._lt(1)).get_type)
      stream.consume # consume DN
      assert_equals(103, (stream._lt(1)).get_type)
      stream.consume # consume 103
      assert_equals(Token::UP, (stream._lt(1)).get_type)
      # RETURN
      stream.pop
      assert_equals(107, (stream._lt(1)).get_type)
    end
    
    typesig { [] }
    def test_nested_push_pop
      # ^(101 ^(102 103) ^(104 105) ^(106 107) 108 109)
      # stream has 9 real + 8 nav nodes
      # Sequence of types: 101 DN 102 DN 103 UP 104 DN 105 UP 106 DN 107 UP 108 109 UP
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r0.add_child(r1)
      r2 = CommonTree.new(CommonToken.new(104))
      r2.add_child(CommonTree.new(CommonToken.new(105)))
      r0.add_child(r2)
      r3 = CommonTree.new(CommonToken.new(106))
      r3.add_child(CommonTree.new(CommonToken.new(107)))
      r0.add_child(r3)
      r0.add_child(CommonTree.new(CommonToken.new(108)))
      r0.add_child(CommonTree.new(CommonToken.new(109)))
      stream = CommonTreeNodeStream.new(r0)
      # Assume we want to hit node 107 and then "call 102", which
      # calls 104, then return
      index_of102 = 2
      index_of107 = 12
      k = 1
      while k <= index_of107
        # consume til 107 node
        stream.consume
        ((k += 1) - 1)
      end
      assert_equals(107, (stream._lt(1)).get_type)
      # CALL 102
      stream.push(index_of102)
      assert_equals(102, (stream._lt(1)).get_type)
      stream.consume # consume 102
      assert_equals(Token::DOWN, (stream._lt(1)).get_type)
      stream.consume # consume DN
      assert_equals(103, (stream._lt(1)).get_type)
      stream.consume # consume 103
      # CALL 104
      index_of104 = 6
      stream.push(index_of104)
      assert_equals(104, (stream._lt(1)).get_type)
      stream.consume # consume 102
      assert_equals(Token::DOWN, (stream._lt(1)).get_type)
      stream.consume # consume DN
      assert_equals(105, (stream._lt(1)).get_type)
      stream.consume # consume 103
      assert_equals(Token::UP, (stream._lt(1)).get_type)
      # RETURN (to UP node in 102 subtree)
      stream.pop
      assert_equals(Token::UP, (stream._lt(1)).get_type)
      # RETURN (to empty stack)
      stream.pop
      assert_equals(107, (stream._lt(1)).get_type)
    end
    
    typesig { [] }
    def test_push_pop_from_eof
      # ^(101 ^(102 103) ^(104 105) ^(106 107) 108 109)
      # stream has 9 real + 8 nav nodes
      # Sequence of types: 101 DN 102 DN 103 UP 104 DN 105 UP 106 DN 107 UP 108 109 UP
      r0 = CommonTree.new(CommonToken.new(101))
      r1 = CommonTree.new(CommonToken.new(102))
      r1.add_child(CommonTree.new(CommonToken.new(103)))
      r0.add_child(r1)
      r2 = CommonTree.new(CommonToken.new(104))
      r2.add_child(CommonTree.new(CommonToken.new(105)))
      r0.add_child(r2)
      r3 = CommonTree.new(CommonToken.new(106))
      r3.add_child(CommonTree.new(CommonToken.new(107)))
      r0.add_child(r3)
      r0.add_child(CommonTree.new(CommonToken.new(108)))
      r0.add_child(CommonTree.new(CommonToken.new(109)))
      stream = CommonTreeNodeStream.new(r0)
      while (!(stream._la(1)).equal?(Token::EOF))
        stream.consume
      end
      index_of102 = 2
      index_of104 = 6
      assert_equals(Token::EOF, (stream._lt(1)).get_type)
      # CALL 102
      stream.push(index_of102)
      assert_equals(102, (stream._lt(1)).get_type)
      stream.consume # consume 102
      assert_equals(Token::DOWN, (stream._lt(1)).get_type)
      stream.consume # consume DN
      assert_equals(103, (stream._lt(1)).get_type)
      stream.consume # consume 103
      assert_equals(Token::UP, (stream._lt(1)).get_type)
      # RETURN (to empty stack)
      stream.pop
      assert_equals(Token::EOF, (stream._lt(1)).get_type)
      # CALL 104
      stream.push(index_of104)
      assert_equals(104, (stream._lt(1)).get_type)
      stream.consume # consume 102
      assert_equals(Token::DOWN, (stream._lt(1)).get_type)
      stream.consume # consume DN
      assert_equals(105, (stream._lt(1)).get_type)
      stream.consume # consume 103
      assert_equals(Token::UP, (stream._lt(1)).get_type)
      # RETURN (to empty stack)
      stream.pop
      assert_equals(Token::EOF, (stream._lt(1)).get_type)
    end
    
    typesig { [] }
    def test_stack_stretch
      # make more than INITIAL_CALL_STACK_SIZE pushes
      r0 = CommonTree.new(CommonToken.new(101))
      stream = CommonTreeNodeStream.new(r0)
      # go 1 over initial size
      i = 1
      while i <= CommonTreeNodeStream::INITIAL_CALL_STACK_SIZE + 1
        stream.push(i)
        ((i += 1) - 1)
      end
      assert_equals(10, stream.pop)
      assert_equals(9, stream.pop)
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_common_tree_node_stream, :initialize
  end
  
end
