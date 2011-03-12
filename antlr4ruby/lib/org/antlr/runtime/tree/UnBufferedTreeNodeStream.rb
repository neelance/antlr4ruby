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
  module UnBufferedTreeNodeStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :TokenStream
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :Stack
    }
  end
  
  # A stream of tree nodes, accessing nodes from a tree of ANY kind.
  # No new nodes should be created in tree during the walk.  A small buffer
  # of tokens is kept to efficiently and easily handle LT(i) calls, though
  # the lookahead mechanism is fairly complicated.
  # 
  # For tree rewriting during tree parsing, this must also be able
  # to replace a set of children without "losing its place".
  # That part is not yet implemented.  Will permit a rule to return
  # a different tree and have it stitched into the output tree probably.
  # 
  # @see CommonTreeNodeStream
  class UnBufferedTreeNodeStream 
    include_class_members UnBufferedTreeNodeStreamImports
    include TreeNodeStream
    
    class_module.module_eval {
      const_set_lazy(:INITIAL_LOOKAHEAD_BUFFER_SIZE) { 5 }
      const_attr_reader  :INITIAL_LOOKAHEAD_BUFFER_SIZE
    }
    
    # Reuse same DOWN, UP navigation nodes unless this is true
    attr_accessor :unique_navigation_nodes
    alias_method :attr_unique_navigation_nodes, :unique_navigation_nodes
    undef_method :unique_navigation_nodes
    alias_method :attr_unique_navigation_nodes=, :unique_navigation_nodes=
    undef_method :unique_navigation_nodes=
    
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
    
    # As we walk down the nodes, we must track parent nodes so we know
    # where to go after walking the last child of a node.  When visiting
    # a child, push current node and current index.
    attr_accessor :node_stack
    alias_method :attr_node_stack, :node_stack
    undef_method :node_stack
    alias_method :attr_node_stack=, :node_stack=
    undef_method :node_stack=
    
    # Track which child index you are visiting for each node we push.
    # TODO: pretty inefficient...use int[] when you have time
    attr_accessor :index_stack
    alias_method :attr_index_stack, :index_stack
    undef_method :index_stack
    alias_method :attr_index_stack=, :index_stack=
    undef_method :index_stack=
    
    # Which node are we currently visiting?
    attr_accessor :current_node
    alias_method :attr_current_node, :current_node
    undef_method :current_node
    alias_method :attr_current_node=, :current_node=
    undef_method :current_node=
    
    # Which node did we visit last?  Used for LT(-1) calls.
    attr_accessor :previous_node
    alias_method :attr_previous_node, :previous_node
    undef_method :previous_node
    alias_method :attr_previous_node=, :previous_node=
    undef_method :previous_node=
    
    # Which child are we currently visiting?  If -1 we have not visited
    # this node yet; next consume() request will set currentIndex to 0.
    attr_accessor :current_child_index
    alias_method :attr_current_child_index, :current_child_index
    undef_method :current_child_index
    alias_method :attr_current_child_index=, :current_child_index=
    undef_method :current_child_index=
    
    # What node index did we just consume?  i=0..n-1 for n node trees.
    # IntStream.next is hence 1 + this value.  Size will be same.
    attr_accessor :absolute_node_index
    alias_method :attr_absolute_node_index, :absolute_node_index
    undef_method :absolute_node_index
    alias_method :attr_absolute_node_index=, :absolute_node_index=
    undef_method :absolute_node_index=
    
    # Buffer tree node stream for use with LT(i).  This list grows
    # to fit new lookahead depths, but consume() wraps like a circular
    # buffer.
    attr_accessor :lookahead
    alias_method :attr_lookahead, :lookahead
    undef_method :lookahead
    alias_method :attr_lookahead=, :lookahead=
    undef_method :lookahead=
    
    # lookahead[head] is the first symbol of lookahead, LT(1).
    attr_accessor :head
    alias_method :attr_head, :head
    undef_method :head
    alias_method :attr_head=, :head=
    undef_method :head=
    
    # Add new lookahead at lookahead[tail].  tail wraps around at the
    # end of the lookahead buffer so tail could be less than head.
    attr_accessor :tail
    alias_method :attr_tail, :tail
    undef_method :tail
    alias_method :attr_tail=, :tail=
    undef_method :tail=
    
    class_module.module_eval {
      # When walking ahead with cyclic DFA or for syntactic predicates,
      #  we need to record the state of the tree node stream.  This
      # class wraps up the current state of the UnBufferedTreeNodeStream.
      # Calling mark() will push another of these on the markers stack.
      const_set_lazy(:TreeWalkState) { Class.new do
        local_class_in UnBufferedTreeNodeStream
        include_class_members UnBufferedTreeNodeStream
        
        attr_accessor :current_child_index
        alias_method :attr_current_child_index, :current_child_index
        undef_method :current_child_index
        alias_method :attr_current_child_index=, :current_child_index=
        undef_method :current_child_index=
        
        attr_accessor :absolute_node_index
        alias_method :attr_absolute_node_index, :absolute_node_index
        undef_method :absolute_node_index
        alias_method :attr_absolute_node_index=, :absolute_node_index=
        undef_method :absolute_node_index=
        
        attr_accessor :current_node
        alias_method :attr_current_node, :current_node
        undef_method :current_node
        alias_method :attr_current_node=, :current_node=
        undef_method :current_node=
        
        attr_accessor :previous_node
        alias_method :attr_previous_node, :previous_node
        undef_method :previous_node
        alias_method :attr_previous_node=, :previous_node=
        undef_method :previous_node=
        
        # Record state of the nodeStack
        attr_accessor :node_stack_size
        alias_method :attr_node_stack_size, :node_stack_size
        undef_method :node_stack_size
        alias_method :attr_node_stack_size=, :node_stack_size=
        undef_method :node_stack_size=
        
        # Record state of the indexStack
        attr_accessor :index_stack_size
        alias_method :attr_index_stack_size, :index_stack_size
        undef_method :index_stack_size
        alias_method :attr_index_stack_size=, :index_stack_size=
        undef_method :index_stack_size=
        
        attr_accessor :lookahead
        alias_method :attr_lookahead, :lookahead
        undef_method :lookahead
        alias_method :attr_lookahead=, :lookahead=
        undef_method :lookahead=
        
        typesig { [] }
        def initialize
          @current_child_index = 0
          @absolute_node_index = 0
          @current_node = nil
          @previous_node = nil
          @node_stack_size = 0
          @index_stack_size = 0
          @lookahead = nil
        end
        
        private
        alias_method :initialize__tree_walk_state, :initialize
      end }
    }
    
    # Calls to mark() may be nested so we have to track a stack of
    # them.  The marker is an index into this stack.
    # This is a List<TreeWalkState>.  Indexed from 1..markDepth.
    # A null is kept @ index 0.  Create upon first call to mark().
    attr_accessor :markers
    alias_method :attr_markers, :markers
    undef_method :markers
    alias_method :attr_markers=, :markers=
    undef_method :markers=
    
    # tracks how deep mark() calls are nested
    attr_accessor :mark_depth
    alias_method :attr_mark_depth, :mark_depth
    undef_method :mark_depth
    alias_method :attr_mark_depth=, :mark_depth=
    undef_method :mark_depth=
    
    # Track the last mark() call result value for use in rewind().
    attr_accessor :last_marker
    alias_method :attr_last_marker, :last_marker
    undef_method :last_marker
    alias_method :attr_last_marker=, :last_marker=
    undef_method :last_marker=
    
    # navigation nodes
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
    
    typesig { [Object] }
    def initialize(tree)
      initialize__un_buffered_tree_node_stream(CommonTreeAdaptor.new, tree)
    end
    
    typesig { [TreeAdaptor, Object] }
    def initialize(adaptor, tree)
      @unique_navigation_nodes = false
      @root = nil
      @tokens = nil
      @adaptor = nil
      @node_stack = Stack.new
      @index_stack = Stack.new
      @current_node = nil
      @previous_node = nil
      @current_child_index = 0
      @absolute_node_index = 0
      @lookahead = Array.typed(Object).new(INITIAL_LOOKAHEAD_BUFFER_SIZE) { nil }
      @head = 0
      @tail = 0
      @markers = nil
      @mark_depth = 0
      @last_marker = 0
      @down = nil
      @up = nil
      @eof = nil
      @root = tree
      @adaptor = adaptor
      reset
      @down = adaptor.create(Token::DOWN, "DOWN")
      @up = adaptor.create(Token::UP, "UP")
      @eof = adaptor.create(Token::EOF, "EOF")
    end
    
    typesig { [] }
    def reset
      @current_node = @root
      @previous_node = nil
      @current_child_index = -1
      @absolute_node_index = -1
      @head = @tail = 0
    end
    
    typesig { [::Java::Int] }
    # Satisfy TreeNodeStream
    def get(i)
      raise UnsupportedOperationException.new("stream is unbuffered")
    end
    
    typesig { [::Java::Int] }
    # Get tree node at current input pointer + i ahead where i=1 is next node.
    # i<0 indicates nodes in the past.  So -1 is previous node and -2 is
    # two nodes ago. LT(0) is undefined.  For i>=n, return null.
    # Return null for LT(0) and any index that results in an absolute address
    # that is negative.
    # 
    # This is analogus to the LT() method of the TokenStream, but this
    # returns a tree node instead of a token.  Makes code gen identical
    # for both parser and tree grammars. :)
    def _lt(k)
      # System.out.println("LT("+k+"); head="+head+", tail="+tail);
      if ((k).equal?(-1))
        return @previous_node
      end
      if (k < 0)
        raise IllegalArgumentException.new("tree node streams cannot look backwards more than 1 node")
      end
      if ((k).equal?(0))
        return Tree::INVALID_NODE
      end
      fill(k)
      return @lookahead[(@head + k - 1) % @lookahead.attr_length]
    end
    
    typesig { [] }
    # Where is this stream pulling nodes from?  This is not the name, but
    # the object that provides node objects.
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
    
    typesig { [::Java::Int] }
    # Make sure we have at least k symbols in lookahead buffer
    def fill(k)
      n = get_lookahead_size
      # System.out.println("we have "+n+" nodes; need "+(k-n));
      i = 1
      while i <= k - n
        next_ # get at least k-depth lookahead nodes
        i += 1
      end
    end
    
    typesig { [Object] }
    # Add a node to the lookahead buffer.  Add at lookahead[tail].
    # If you tail+1 == head, then we must create a bigger buffer
    # and copy all the nodes over plus reset head, tail.  After
    # this method, LT(1) will be lookahead[0].
    def add_lookahead(node)
      # System.out.println("addLookahead head="+head+", tail="+tail);
      @lookahead[@tail] = node
      @tail = (@tail + 1) % @lookahead.attr_length
      if ((@tail).equal?(@head))
        # buffer overflow: tail caught up with head
        # allocate a buffer 2x as big
        bigger = Array.typed(Object).new(2 * @lookahead.attr_length) { nil }
        # copy head to end of buffer to beginning of bigger buffer
        remainder_head_to_end = @lookahead.attr_length - @head
        System.arraycopy(@lookahead, @head, bigger, 0, remainder_head_to_end)
        # copy 0..tail to after that
        System.arraycopy(@lookahead, 0, bigger, remainder_head_to_end, @tail)
        @lookahead = bigger # reset to bigger buffer
        @head = 0
        @tail += remainder_head_to_end
      end
    end
    
    typesig { [] }
    # Satisfy IntStream interface
    def consume
      # System.out.println("consume: currentNode="+currentNode.getType()+
      #                    " childIndex="+currentChildIndex+
      #                    " nodeIndex="+absoluteNodeIndex);
      # make sure there is something in lookahead buf, which might call next()
      fill(1)
      @absolute_node_index += 1
      @previous_node = @lookahead[@head] # track previous node before moving on
      @head = (@head + 1) % @lookahead.attr_length
    end
    
    typesig { [::Java::Int] }
    def _la(i)
      t = _lt(i)
      if ((t).nil?)
        return Token::INVALID_TOKEN_TYPE
      end
      return @adaptor.get_type(t)
    end
    
    typesig { [] }
    # Record the current state of the tree walk which includes
    # the current node and stack state as well as the lookahead
    # buffer.
    def mark
      if ((@markers).nil?)
        @markers = ArrayList.new
        @markers.add(nil) # depth 0 means no backtracking, leave blank
      end
      @mark_depth += 1
      state = nil
      if (@mark_depth >= @markers.size)
        state = TreeWalkState.new_local(self)
        @markers.add(state)
      else
        state = @markers.get(@mark_depth)
      end
      state.attr_absolute_node_index = @absolute_node_index
      state.attr_current_child_index = @current_child_index
      state.attr_current_node = @current_node
      state.attr_previous_node = @previous_node
      state.attr_node_stack_size = @node_stack.size
      state.attr_index_stack_size = @index_stack.size
      # take snapshot of lookahead buffer
      n = get_lookahead_size
      i = 0
      state.attr_lookahead = Array.typed(Object).new(n) { nil }
      k = 1
      while k <= n
        state.attr_lookahead[i] = _lt(k)
        k += 1
        i += 1
      end
      @last_marker = @mark_depth
      return @mark_depth
    end
    
    typesig { [::Java::Int] }
    def release(marker)
      # unwind any other markers made after marker and release marker
      @mark_depth = marker
      # release this marker
      @mark_depth -= 1
    end
    
    typesig { [::Java::Int] }
    # Rewind the current state of the tree walk to the state it
    # was in when mark() was called and it returned marker.  Also,
    # wipe out the lookahead which will force reloading a few nodes
    # but it is better than making a copy of the lookahead buffer
    # upon mark().
    def rewind(marker)
      if ((@markers).nil?)
        return
      end
      state = @markers.get(marker)
      @absolute_node_index = state.attr_absolute_node_index
      @current_child_index = state.attr_current_child_index
      @current_node = state.attr_current_node
      @previous_node = state.attr_previous_node
      # drop node and index stacks back to old size
      @node_stack.set_size(state.attr_node_stack_size)
      @index_stack.set_size(state.attr_index_stack_size)
      @head = @tail = 0 # wack lookahead buffer and then refill
      while @tail < state.attr_lookahead.attr_length
        @lookahead[@tail] = state.attr_lookahead[@tail]
        @tail += 1
      end
      release(marker)
    end
    
    typesig { [] }
    def rewind
      rewind(@last_marker)
    end
    
    typesig { [::Java::Int] }
    # consume() ahead until we hit index.  Can't just jump ahead--must
    # spit out the navigation nodes.
    def seek(index)
      if (index < self.index)
        raise IllegalArgumentException.new("can't seek backwards in node stream")
      end
      # seek forward, consume until we hit index
      while (self.index < index)
        consume
      end
    end
    
    typesig { [] }
    def index
      return @absolute_node_index + 1
    end
    
    typesig { [] }
    # Expensive to compute; recursively walk tree to find size;
    # include navigation nodes and EOF.  Reuse functionality
    # in CommonTreeNodeStream as we only really use this
    # for testing.
    def size
      s = CommonTreeNodeStream.new(@root)
      return s.size
    end
    
    typesig { [] }
    # Return the next node found during a depth-first walk of root.
    # Also, add these nodes and DOWN/UP imaginary nodes into the lokoahead
    # buffer as a side-effect.  Normally side-effects are bad, but because
    # we can emit many tokens for every next() call, it's pretty hard to
    # use a single return value for that.  We must add these tokens to
    # the lookahead buffer.
    # 
    # This does *not* return the DOWN/UP nodes; those are only returned
    # by the LT() method.
    # 
    # Ugh.  This mechanism is much more complicated than a recursive
    # solution, but it's the only way to provide nodes on-demand instead
    # of walking once completely through and buffering up the nodes. :(
    def next_
      # already walked entire tree; nothing to return
      if ((@current_node).nil?)
        add_lookahead(@eof)
        # this is infinite stream returning EOF at end forever
        # so don't throw NoSuchElementException
        return nil
      end
      # initial condition (first time method is called)
      if ((@current_child_index).equal?(-1))
        return handle_root_node
      end
      # index is in the child list?
      if (@current_child_index < @adaptor.get_child_count(@current_node))
        return visit_child(@current_child_index)
      end
      # hit end of child list, return to parent node or its parent ...
      walk_back_to_most_recent_node_with_unvisited_children
      if (!(@current_node).nil?)
        return visit_child(@current_child_index)
      end
      return nil
    end
    
    typesig { [] }
    def handle_root_node
      node = nil
      node = @current_node
      # point to first child in prep for subsequent next()
      @current_child_index = 0
      if (@adaptor.is_nil(node))
        # don't count this root nil node
        node = visit_child(@current_child_index)
      else
        add_lookahead(node)
        if ((@adaptor.get_child_count(@current_node)).equal?(0))
          # single node case
          @current_node = nil # say we're done
        end
      end
      return node
    end
    
    typesig { [::Java::Int] }
    def visit_child(child)
      node = nil
      # save state
      @node_stack.push(@current_node)
      @index_stack.push(child)
      if ((child).equal?(0) && !@adaptor.is_nil(@current_node))
        add_navigation_node(Token::DOWN)
      end
      # visit child
      @current_node = @adaptor.get_child(@current_node, child)
      @current_child_index = 0
      node = @current_node # record node to return
      add_lookahead(node)
      walk_back_to_most_recent_node_with_unvisited_children
      return node
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
      add_lookahead(nav_node)
    end
    
    typesig { [] }
    # Walk upwards looking for a node with more children to walk.
    def walk_back_to_most_recent_node_with_unvisited_children
      while (!(@current_node).nil? && @current_child_index >= @adaptor.get_child_count(@current_node))
        @current_node = @node_stack.pop
        if ((@current_node).nil?)
          # hit the root?
          return
        end
        @current_child_index = (@index_stack.pop).int_value
        @current_child_index += 1 # move to next child
        if (@current_child_index >= @adaptor.get_child_count(@current_node))
          if (!@adaptor.is_nil(@current_node))
            add_navigation_node(Token::UP)
          end
          if ((@current_node).equal?(@root))
            # we done yet?
            @current_node = nil
          end
        end
      end
    end
    
    typesig { [] }
    def get_tree_adaptor
      return @adaptor
    end
    
    typesig { [] }
    def has_unique_navigation_nodes
      return @unique_navigation_nodes
    end
    
    typesig { [::Java::Boolean] }
    def set_unique_navigation_nodes(unique_navigation_nodes)
      @unique_navigation_nodes = unique_navigation_nodes
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int, Object] }
    def replace_children(parent, start_child_index, stop_child_index, t)
      raise UnsupportedOperationException.new("can't do stream rewrites yet")
    end
    
    typesig { [] }
    # Print out the entire tree including DOWN/UP nodes.  Uses
    # a recursive walk.  Mostly useful for testing as it yields
    # the token types not text.
    def to_s
      return to_s(@root, nil)
    end
    
    typesig { [] }
    def get_lookahead_size
      return @tail < @head ? (@lookahead.attr_length - @head + @tail) : (@tail - @head)
    end
    
    typesig { [Object, Object] }
    def to_s(start, stop)
      if ((start).nil?)
        return nil
      end
      # if we have the token stream, use that to dump text in order
      if (!(@tokens).nil?)
        # don't trust stop node as it's often an UP node etc...
        # walk backwards until you find a non-UP, non-DOWN node
        # and ask for it's token index.
        begin_token_index = @adaptor.get_token_start_index(start)
        end_token_index = @adaptor.get_token_stop_index(stop)
        if (!(stop).nil? && (@adaptor.get_type(stop)).equal?(Token::UP))
          end_token_index = @adaptor.get_token_stop_index(start)
        else
          end_token_index = size - 1
        end
        return @tokens.to_s(begin_token_index, end_token_index)
      end
      buf = StringBuffer.new
      to_string_work(start, stop, buf)
      return buf.to_s
    end
    
    typesig { [Object, Object, StringBuffer] }
    def to_string_work(p, stop, buf)
      if (!@adaptor.is_nil(p))
        text = @adaptor.get_text(p)
        if ((text).nil?)
          text = " " + RJava.cast_to_string(String.value_of(@adaptor.get_type(p)))
        end
        buf.append(text) # ask the node to go to string
      end
      if ((p).equal?(stop))
        return
      end
      n = @adaptor.get_child_count(p)
      if (n > 0 && !@adaptor.is_nil(p))
        buf.append(" ")
        buf.append(Token::DOWN)
      end
      c = 0
      while c < n
        child = @adaptor.get_child(p, c)
        to_string_work(child, stop, buf)
        c += 1
      end
      if (n > 0 && !@adaptor.is_nil(p))
        buf.append(" ")
        buf.append(Token::UP)
      end
    end
    
    private
    alias_method :initialize__un_buffered_tree_node_stream, :initialize
  end
  
end
