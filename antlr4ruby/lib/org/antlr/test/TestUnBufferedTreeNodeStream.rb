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
  module TestUnBufferedTreeNodeStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :CommonToken
      include_const ::Org::Antlr::Runtime, :Token
    }
  end
  
  class TestUnBufferedTreeNodeStream < TestUnBufferedTreeNodeStreamImports.const_get :TestTreeNodeStream
    include_class_members TestUnBufferedTreeNodeStreamImports
    
    typesig { [Object] }
    def new_stream(t)
      return UnBufferedTreeNodeStream.new(t)
    end
    
    typesig { [] }
    def test_buffer_overflow
      buf = StringBuffer.new
      buf2 = StringBuffer.new
      # make ^(101 102 ... n)
      t = CommonTree.new(CommonToken.new(101))
      buf.append(" 101")
      buf2.append(" 101")
      buf2.append(" ")
      buf2.append(Token::DOWN)
      i = 0
      while i <= UnBufferedTreeNodeStream::INITIAL_LOOKAHEAD_BUFFER_SIZE + 10
        t.add_child(CommonTree.new(CommonToken.new(102 + i)))
        buf.append(" ")
        buf.append(102 + i)
        buf2.append(" ")
        buf2.append(102 + i)
        i += 1
      end
      buf2.append(" ")
      buf2.append(Token::UP)
      stream = new_stream(t)
      expecting = buf.to_s
      found = to_nodes_only_string(stream)
      assert_equals(expecting, found)
      expecting = RJava.cast_to_string(buf2.to_s)
      found = RJava.cast_to_string(stream.to_s)
      assert_equals(expecting, found)
    end
    
    typesig { [] }
    # Test what happens when tail hits the end of the buffer, but there
    # is more room left.  Specifically that would mean that head is not
    # at 0 but has advanced somewhere to the middle of the lookahead
    # buffer.
    # 
    # Use consume() to advance N nodes into lookahead.  Then use LT()
    # to load at least INITIAL_LOOKAHEAD_BUFFER_SIZE-N nodes so the
    # buffer has to wrap.
    def test_buffer_wrap
      n = 10
      # make tree with types: 1 2 ... INITIAL_LOOKAHEAD_BUFFER_SIZE+N
      t = CommonTree.new(nil)
      i = 0
      while i < UnBufferedTreeNodeStream::INITIAL_LOOKAHEAD_BUFFER_SIZE + n
        t.add_child(CommonTree.new(CommonToken.new(i + 1)))
        i += 1
      end
      # move head to index N
      stream = new_stream(t)
      i_ = 1
      while i_ <= n
        # consume N
        node = stream._lt(1)
        assert_equals(i_, node.get_type)
        stream.consume
        i_ += 1
      end
      # now use LT to lookahead past end of buffer
      remaining = UnBufferedTreeNodeStream::INITIAL_LOOKAHEAD_BUFFER_SIZE - n
      wrap_by = 4 # wrap around by 4 nodes
      assert_true("bad test code; wrapBy must be less than N", wrap_by < n)
      i__ = 1
      while i__ <= remaining + wrap_by
        # wrap past end of buffer
        node = stream._lt(i__) # look ahead to ith token
        assert_equals(n + i__, node.get_type)
        i__ += 1
      end
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__test_un_buffered_tree_node_stream, :initialize
  end
  
end
