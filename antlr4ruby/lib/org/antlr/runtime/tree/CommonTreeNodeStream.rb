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
  module CommonTreeNodeStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :TokenStream
      include_const ::Org::Antlr::Runtime::Misc, :IntArray
      include ::Java::Util
    }
  end
  
  # A buffered stream of tree nodes.  Nodes can be from a tree of ANY kind.
  # 
  # This node stream sucks all nodes out of the tree specified in
  # the constructor during construction and makes pointers into
  # the tree using an array of Object pointers. The stream necessarily
  # includes pointers to DOWN and UP and EOF nodes.
  # 
  # This stream knows how to mark/release for backtracking.
  # 
  # This stream is most suitable for tree interpreters that need to
  # jump around a lot or for tree parsers requiring speed (at cost of memory).
  # There is some duplicated functionality here with UnBufferedTreeNodeStream
  # but just in bookkeeping, not tree walking etc...
  # 
  # @see UnBufferedTreeNodeStream
  class CommonTreeNodeStream 
    include_class_members CommonTreeNodeStreamImports
    include TreeNodeStream
    
    class_module.module_eval {
      const_set_lazy(:DEFAULT_INITIAL_BUFFER_SIZE) { 100 }
      const_attr_reader  :DEFAULT_INITIAL_BUFFER_SIZE
      
      const_set_lazy(:INITIAL_CALL_STACK_SIZE) { 10 }
      const_attr_reader  :INITIAL_CALL_STACK_SIZE
      
      const_set_lazy(:StreamIterator) { Class.new do
        local_class_in CommonTreeNodeStream
        include_class_members CommonTreeNodeStream
        include Iterator
        
        attr_accessor :i
        alias_method :attr_i, :i
        undef_method :i
        alias_method :attr_i=, :i=
        undef_method :i=
        
        typesig { [] }
        def has_next
          return @i < self.attr_nodes.size
        end
        
        typesig { [] }
        def next_
          current = @i
          @i += 1
          if (current < self.attr_nodes.size)
            return self.attr_nodes.get(current)
          end
          return self.attr_eof
        end
        
        typesig { [] }
        def remove
          raise self.class::RuntimeException.new("cannot remove nodes from stream")
        end
        
        typesig { [] }
        def initialize
          @i = 0
        end
        
        private
        alias_method :initialize__stream_iterator, :initialize
      end }
    }
    
    # all these navigation nodes are shared and hence they
    # cannot contain any line/column info
    attr_accessor :down
    alias_method :attr_down, :down
    undef_method :down
    alias_method :attr_down=, :down=
    undef_method :down=
    
    attr_accessor :up
    alias_method :attr_up, :up
    undef_method :up
    alias_method :attr_up=, :up=
    undef_method :up=
    
    attr_accessor :eof
    alias_method :attr_eof, :eof
    undef_method :eof
    alias_method :attr_eof=, :eof=
    undef_method :eof=
    
    # The complete mapping from stream index to tree node.
    # This buffer includes pointers to DOWN, UP, and EOF nodes.
    # It is built upon ctor invocation.  The elements are type
    # Object as we don't what the trees look like.
    # 
    # Load upon first need of the buffer so we can set token types
    # of interest for reverseIndexing.  Slows us down a wee bit to
    # do all of the if p==-1 testing everywhere though.
    attr_accessor :nodes
    alias_method :attr_nodes, :nodes
    undef_method :nodes
    alias_method :attr_nodes=, :nodes=
    undef_method :nodes=
    
    # Pull nodes from which tree?
    attr_accessor :root
    alias_method :attr_root, :root
    undef_method :root
    alias_method :attr_root=, :root=
    undef_method :root=
    
    # IF this tree (root) was created from a token stream, track it.
    attr_accessor :tokens
    alias_method :attr_tokens, :tokens
    undef_method :tokens
    alias_method :attr_tokens=, :tokens=
    undef_method :tokens=
    
    # What tree adaptor was used to build these trees
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    # Reuse same DOWN, UP navigation nodes unless this is true
    attr_accessor :unique_navigation_nodes
    alias_method :attr_unique_navigation_nodes, :unique_navigation_nodes
    undef_method :unique_navigation_nodes
    alias_method :attr_unique_navigation_nodes=, :unique_navigation_nodes=
    undef_method :unique_navigation_nodes=
    
    # The index into the nodes list of the current node (next node
    # to consume).  If -1, nodes array not filled yet.
    attr_accessor :p
    alias_method :attr_p, :p
    undef_method :p
    alias_method :attr_p=, :p=
    undef_method :p=
    
    # Track the last mark() call result value for use in rewind().
    attr_accessor :last_marker
    alias_method :attr_last_marker, :last_marker
    undef_method :last_marker
    alias_method :attr_last_marker=, :last_marker=
    undef_method :last_marker=
    
    # Stack of indexes used for push/pop calls
    attr_accessor :calls
    alias_method :attr_calls, :calls
    undef_method :calls
    alias_method :attr_calls=, :calls=
    undef_method :calls=
    
    typesig { [Object] }
    def initialize(tree)
      initialize__common_tree_node_stream(CommonTreeAdaptor.new, tree)
    end
    
    typesig { [TreeAdaptor, Object] }
    def initialize(adaptor, tree)
      initialize__common_tree_node_stream(adaptor, tree, DEFAULT_INITIAL_BUFFER_SIZE)
    end
    
    typesig { [TreeAdaptor, Object, ::Java::Int] }
    def initialize(adaptor, tree, initial_buffer_size)
      @down = nil
      @up = nil
      @eof = nil
      @nodes = nil
      @root = nil
      @tokens = nil
      @adaptor = nil
      @unique_navigation_nodes = false
      @p = -1
      @last_marker = 0
      @calls = nil
      @root = tree
      @adaptor = adaptor
      @nodes = ArrayList.new(initial_buffer_size)
      @down = adaptor.create(Token::DOWN, "DOWN")
      @up = adaptor.create(Token::UP, "UP")
      @eof = adaptor.create(Token::EOF, "EOF")
    end
    
    typesig { [] }
    # Walk tree with depth-first-search and fill nodes buffer.
    # Don't do DOWN, UP nodes if its a list (t is isNil).
    def fill_buffer
      fill_buffer(@root)
      # System.out.println("revIndex="+tokenTypeToStreamIndexesMap);
      @p = 0 # buffer of nodes intialized now
    end
    
    typesig { [Object] }
    def fill_buffer(t)
      nil_ = @adaptor.is_nil(t)
      if (!nil_)
        @nodes.add(t) # add this node
      end
      # add DOWN node if t has children
      n = @adaptor.get_child_count(t)
      if (!nil_ && n > 0)
        add_navigation_node(Token::DOWN)
      end
      # and now add all its children
      c = 0
      while c < n
        child = @adaptor.get_child(t, c)
        fill_buffer(child)
        c += 1
      end
      # add UP node if t has children
      if (!nil_ && n > 0)
        add_navigation_node(Token::UP)
      end
    end
    
    typesig { [Object] }
    # What is the stream index for node? 0..n-1
    # Return -1 if node not found.
    def get_node_index(node)
      if ((@p).equal?(-1))
        fill_buffer
      end
      i = 0
      while i < @nodes.size
        t = @nodes.get(i)
        if ((t).equal?(node))
          return i
        end
        i += 1
      end
      return -1
    end
    
    typesig { [::Java::Int] }
    # As we flatten the tree, we use UP, DOWN nodes to represent
    # the tree structure.  When debugging we need unique nodes
    # so instantiate new ones when uniqueNavigationNodes is true.
    def add_navigation_node(ttype)
      nav_node = nil
      if ((ttype).equal?(Token::DOWN))
        if (has_unique_navigation_nodes)
          nav_node = @adaptor.create(Token::DOWN, "DOWN")
        else
          nav_node = @down
        end
      else
        if (has_unique_navigation_nodes)
          nav_node = @adaptor.create(Token::UP, "UP")
        else
          nav_node = @up
        end
      end
      @nodes.add(nav_node)
    end
    
    typesig { [::Java::Int] }
    def get(i)
      if ((@p).equal?(-1))
        fill_buffer
      end
      return @nodes.get(i)
    end
    
    typesig { [::Java::Int] }
    def _lt(k)
      if ((@p).equal?(-1))
        fill_buffer
      end
      if ((k).equal?(0))
        return nil
      end
      if (k < 0)
        return _lb(-k)
      end
      # System.out.print("LT(p="+p+","+k+")=");
      if ((@p + k - 1) >= @nodes.size)
        return @eof
      end
      return @nodes.get(@p + k - 1)
    end
    
    typesig { [] }
    def get_current_symbol
      return _lt(1)
    end
    
    typesig { [::Java::Int] }
    # public Object getLastTreeNode() {
    #     int i = index();
    #     if ( i>=size() ) {
    #         i--; // if at EOF, have to start one back
    #     }
    #     System.out.println("start last node: "+i+" size=="+nodes.size());
    #     while ( i>=0 &&
    #         (adaptor.getType(get(i))==Token.EOF ||
    #          adaptor.getType(get(i))==Token.UP ||
    #          adaptor.getType(get(i))==Token.DOWN) )
    #     {
    #         i--;
    #     }
    #     System.out.println("stop at node: "+i+" "+nodes.get(i));
    #     return nodes.get(i);
    # }
    # Look backwards k nodes
    def _lb(k)
      if ((k).equal?(0))
        return nil
      end
      if ((@p - k) < 0)
        return nil
      end
      return @nodes.get(@p - k)
    end
    
    typesig { [] }
    def get_tree_source
      return @root
    end
    
    typesig { [] }
    def get_source_name
      return get_token_stream.get_source_name
    end
    
    typesig { [] }
    def get_token_stream
      return @tokens
    end
    
    typesig { [TokenStream] }
    def set_token_stream(tokens)
      @tokens = tokens
    end
    
    typesig { [] }
    def get_tree_adaptor
      return @adaptor
    end
    
    typesig { [TreeAdaptor] }
    def set_tree_adaptor(adaptor)
      @adaptor = adaptor
    end
    
    typesig { [] }
    def has_unique_navigation_nodes
      return @unique_navigation_nodes
    end
    
    typesig { [::Java::Boolean] }
    def set_unique_navigation_nodes(unique_navigation_nodes)
      @unique_navigation_nodes = unique_navigation_nodes
    end
    
    typesig { [] }
    def consume
      if ((@p).equal?(-1))
        fill_buffer
      end
      @p += 1
    end
    
    typesig { [::Java::Int] }
    def _la(i)
      return @adaptor.get_type(_lt(i))
    end
    
    typesig { [] }
    def mark
      if ((@p).equal?(-1))
        fill_buffer
      end
      @last_marker = index
      return @last_marker
    end
    
    typesig { [::Java::Int] }
    def release(marker)
      # no resources to release
    end
    
    typesig { [] }
    def index
      return @p
    end
    
    typesig { [::Java::Int] }
    def rewind(marker)
      seek(marker)
    end
    
    typesig { [] }
    def rewind
      seek(@last_marker)
    end
    
    typesig { [::Java::Int] }
    def seek(index_)
      if ((@p).equal?(-1))
        fill_buffer
      end
      @p = index_
    end
    
    typesig { [::Java::Int] }
    # Make stream jump to a new location, saving old location.
    # Switch back with pop().
    def push(index_)
      if ((@calls).nil?)
        @calls = IntArray.new
      end
      @calls.push(@p) # save current index
      seek(index_)
    end
    
    typesig { [] }
    # Seek back to previous index saved during last push() call.
    # Return top of stack (return index).
    def pop
      ret = @calls.pop
      seek(ret)
      return ret
    end
    
    typesig { [] }
    def reset
      @p = 0
      @last_marker = 0
      if (!(@calls).nil?)
        @calls.clear
      end
    end
    
    typesig { [] }
    def size
      if ((@p).equal?(-1))
        fill_buffer
      end
      return @nodes.size
    end
    
    typesig { [] }
    def iterator
      if ((@p).equal?(-1))
        fill_buffer
      end
      return StreamIterator.new_local(self)
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int, Object] }
    # TREE REWRITE INTERFACE
    def replace_children(parent, start_child_index, stop_child_index, t)
      if (!(parent).nil?)
        @adaptor.replace_children(parent, start_child_index, stop_child_index, t)
      end
    end
    
    typesig { [] }
    # Used for testing, just return the token type stream
    def to_s
      if ((@p).equal?(-1))
        fill_buffer
      end
      buf = StringBuffer.new
      i = 0
      while i < @nodes.size
        t = @nodes.get(i)
        buf.append(" ")
        buf.append(@adaptor.get_type(t))
        i += 1
      end
      return buf.to_s
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # Debugging
    def to_token_string(start, stop)
      if ((@p).equal?(-1))
        fill_buffer
      end
      buf = StringBuffer.new
      i = start
      while i < @nodes.size && i <= stop
        t = @nodes.get(i)
        buf.append(" ")
        buf.append(@adaptor.get_token(t))
        i += 1
      end
      return buf.to_s
    end
    
    typesig { [Object, Object] }
    def to_s(start, stop)
      System.out.println("toString")
      if ((start).nil? || (stop).nil?)
        return nil
      end
      if ((@p).equal?(-1))
        fill_buffer
      end
      # System.out.println("stop: "+stop);
      if (start.is_a?(CommonTree))
        System.out.print("toString: " + RJava.cast_to_string((start).get_token) + ", ")
      else
        System.out.println(start)
      end
      if (stop.is_a?(CommonTree))
        System.out.println((stop).get_token)
      else
        System.out.println(stop)
      end
      # if we have the token stream, use that to dump text in order
      if (!(@tokens).nil?)
        begin_token_index = @adaptor.get_token_start_index(start)
        end_token_index = @adaptor.get_token_stop_index(stop)
        # if it's a tree, use start/stop index from start node
        # else use token range from start/stop nodes
        if ((@adaptor.get_type(stop)).equal?(Token::UP))
          end_token_index = @adaptor.get_token_stop_index(start)
        else
          if ((@adaptor.get_type(stop)).equal?(Token::EOF))
            end_token_index = size - 2 # don't use EOF
          end
        end
        return @tokens.to_s(begin_token_index, end_token_index)
      end
      # walk nodes looking for start
      t = nil
      i = 0
      while i < @nodes.size
        t = @nodes.get(i)
        if ((t).equal?(start))
          break
        end
        i += 1
      end
      # now walk until we see stop, filling string buffer with text
      buf = StringBuffer.new
      t = @nodes.get(i)
      while (!(t).equal?(stop))
        text = @adaptor.get_text(t)
        if ((text).nil?)
          text = " " + RJava.cast_to_string(String.value_of(@adaptor.get_type(t)))
        end
        buf.append(text)
        i += 1
        t = @nodes.get(i)
      end
      # include stop node too
      text = @adaptor.get_text(stop)
      if ((text).nil?)
        text = " " + RJava.cast_to_string(String.value_of(@adaptor.get_type(stop)))
      end
      buf.append(text)
      return buf.to_s
    end
    
    private
    alias_method :initialize__common_tree_node_stream, :initialize
  end
  
end
