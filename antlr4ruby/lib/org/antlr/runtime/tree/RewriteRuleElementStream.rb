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
  module RewriteRuleElementStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :CommonToken
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :ArrayList
    }
  end
  
  # A generic list of elements tracked in an alternative to be used in
  # a -> rewrite rule.  We need to subclass to fill in the next() method,
  # which returns either an AST node wrapped around a token payload or
  # an existing subtree.
  # 
  # Once you start next()ing, do not try to add more elements.  It will
  # break the cursor tracking I believe.
  # 
  # @see org.antlr.runtime.tree.RewriteRuleSubtreeStream
  # @see org.antlr.runtime.tree.RewriteRuleTokenStream
  # 
  # TODO: add mechanism to detect/puke on modification after reading from stream
  class RewriteRuleElementStream 
    include_class_members RewriteRuleElementStreamImports
    
    # Cursor 0..n-1.  If singleElement!=null, cursor is 0 until you next(),
    # which bumps it to 1 meaning no more elements.
    attr_accessor :cursor
    alias_method :attr_cursor, :cursor
    undef_method :cursor
    alias_method :attr_cursor=, :cursor=
    undef_method :cursor=
    
    # Track single elements w/o creating a list.  Upon 2nd add, alloc list
    attr_accessor :single_element
    alias_method :attr_single_element, :single_element
    undef_method :single_element
    alias_method :attr_single_element=, :single_element=
    undef_method :single_element=
    
    # The list of tokens or subtrees we are tracking
    attr_accessor :elements
    alias_method :attr_elements, :elements
    undef_method :elements
    alias_method :attr_elements=, :elements=
    undef_method :elements=
    
    # Once a node / subtree has been used in a stream, it must be dup'd
    # from then on.  Streams are reset after subrules so that the streams
    # can be reused in future subrules.  So, reset must set a dirty bit.
    # If dirty, then next() always returns a dup.
    # 
    # I wanted to use "naughty bit" here, but couldn't think of a way
    # to use "naughty".
    attr_accessor :dirty
    alias_method :attr_dirty, :dirty
    undef_method :dirty
    alias_method :attr_dirty=, :dirty=
    undef_method :dirty=
    
    # The element or stream description; usually has name of the token or
    # rule reference that this list tracks.  Can include rulename too, but
    # the exception would track that info.
    attr_accessor :element_description
    alias_method :attr_element_description, :element_description
    undef_method :element_description
    alias_method :attr_element_description=, :element_description=
    undef_method :element_description=
    
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    typesig { [TreeAdaptor, String] }
    def initialize(adaptor, element_description)
      @cursor = 0
      @single_element = nil
      @elements = nil
      @dirty = false
      @element_description = nil
      @adaptor = nil
      @element_description = element_description
      @adaptor = adaptor
    end
    
    typesig { [TreeAdaptor, String, Object] }
    # Create a stream with one element
    def initialize(adaptor, element_description, one_element)
      initialize__rewrite_rule_element_stream(adaptor, element_description)
      add(one_element)
    end
    
    typesig { [TreeAdaptor, String, JavaList] }
    # Create a stream, but feed off an existing list
    def initialize(adaptor, element_description, elements)
      initialize__rewrite_rule_element_stream(adaptor, element_description)
      @single_element = nil
      @elements = elements
    end
    
    typesig { [] }
    # Reset the condition of this stream so that it appears we have
    # not consumed any of its elements.  Elements themselves are untouched.
    # Once we reset the stream, any future use will need duplicates.  Set
    # the dirty bit.
    def reset
      @cursor = 0
      @dirty = true
    end
    
    typesig { [Object] }
    def add(el)
      # System.out.println("add '"+elementDescription+"' is "+el);
      if ((el).nil?)
        return
      end
      if (!(@elements).nil?)
        # if in list, just add
        @elements.add(el)
        return
      end
      if ((@single_element).nil?)
        # no elements yet, track w/o list
        @single_element = el
        return
      end
      # adding 2nd element, move to list
      @elements = ArrayList.new(5)
      @elements.add(@single_element)
      @single_element = nil
      @elements.add(el)
    end
    
    typesig { [] }
    # Return the next element in the stream.  If out of elements, throw
    # an exception unless size()==1.  If size is 1, then return elements[0].
    # Return a duplicate node/subtree if stream is out of elements and
    # size==1.  If we've already used the element, dup (dirty bit set).
    def next_tree
      n = size
      if (@dirty || (@cursor >= n && (n).equal?(1)))
        # if out of elements and size is 1, dup
        el = __next
        return dup(el)
      end
      # test size above then fetch
      el = __next
      return el
    end
    
    typesig { [] }
    # do the work of getting the next element, making sure that it's
    # a tree node or subtree.  Deal with the optimization of single-
    # element list versus list of size > 1.  Throw an exception
    # if the stream is empty or we're out of elements and size>1.
    # protected so you can override in a subclass if necessary.
    def __next
      n = size
      if ((n).equal?(0))
        raise RewriteEmptyStreamException.new(@element_description)
      end
      if (@cursor >= n)
        # out of elements?
        if ((n).equal?(1))
          # if size is 1, it's ok; return and we'll dup
          return to_tree(@single_element)
        end
        # out of elements and size was not 1, so we can't dup
        raise RewriteCardinalityException.new(@element_description)
      end
      # we have elements
      if (!(@single_element).nil?)
        @cursor += 1 # move cursor even for single element list
        return to_tree(@single_element)
      end
      # must have more than one in list, pull from elements
      o = to_tree(@elements.get(@cursor))
      @cursor += 1
      return o
    end
    
    typesig { [Object] }
    # When constructing trees, sometimes we need to dup a token or AST
    # subtree.  Dup'ing a token means just creating another AST node
    # around it.  For trees, you must call the adaptor.dupTree() unless
    # the element is for a tree root; then it must be a node dup.
    def dup(el)
      raise NotImplementedError
    end
    
    typesig { [Object] }
    # Ensure stream emits trees; tokens must be converted to AST nodes.
    # AST nodes can be passed through unmolested.
    def to_tree(el)
      return el
    end
    
    typesig { [] }
    def has_next
      return (!(@single_element).nil? && @cursor < 1) || (!(@elements).nil? && @cursor < @elements.size)
    end
    
    typesig { [] }
    def size
      n = 0
      if (!(@single_element).nil?)
        n = 1
      end
      if (!(@elements).nil?)
        return @elements.size
      end
      return n
    end
    
    typesig { [] }
    def get_description
      return @element_description
    end
    
    private
    alias_method :initialize__rewrite_rule_element_stream, :initialize
  end
  
end
