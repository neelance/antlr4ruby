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
module Org::Antlr::Runtime::Debug
  module DebugTreeNodeStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime::Tree, :TreeAdaptor
      include_const ::Org::Antlr::Runtime::Tree, :TreeNodeStream
      include_const ::Org::Antlr::Runtime, :TokenStream
    }
  end
  
  # Debug any tree node stream.  The constructor accepts the stream
  # and a debug listener.  As node stream calls come in, debug events
  # are triggered.
  class DebugTreeNodeStream 
    include_class_members DebugTreeNodeStreamImports
    include TreeNodeStream
    
    attr_accessor :dbg
    alias_method :attr_dbg, :dbg
    undef_method :dbg
    alias_method :attr_dbg=, :dbg=
    undef_method :dbg=
    
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    attr_accessor :initial_stream_state
    alias_method :attr_initial_stream_state, :initial_stream_state
    undef_method :initial_stream_state
    alias_method :attr_initial_stream_state=, :initial_stream_state=
    undef_method :initial_stream_state=
    
    # Track the last mark() call result value for use in rewind().
    attr_accessor :last_marker
    alias_method :attr_last_marker, :last_marker
    undef_method :last_marker
    alias_method :attr_last_marker=, :last_marker=
    undef_method :last_marker=
    
    typesig { [TreeNodeStream, DebugEventListener] }
    def initialize(input, dbg)
      @dbg = nil
      @adaptor = nil
      @input = nil
      @initial_stream_state = true
      @last_marker = 0
      @input = input
      @adaptor = input.get_tree_adaptor
      @input.set_unique_navigation_nodes(true)
      set_debug_listener(dbg)
    end
    
    typesig { [DebugEventListener] }
    def set_debug_listener(dbg)
      @dbg = dbg
    end
    
    typesig { [] }
    def get_tree_adaptor
      return @adaptor
    end
    
    typesig { [] }
    def consume
      node = @input._lt(1)
      @input.consume
      @dbg.consume_node(node)
    end
    
    typesig { [::Java::Int] }
    def get(i)
      return @input.get(i)
    end
    
    typesig { [::Java::Int] }
    def _lt(i)
      node = @input._lt(i)
      id = @adaptor.get_unique_id(node)
      text = @adaptor.get_text(node)
      type = @adaptor.get_type(node)
      @dbg._lt(i, node)
      return node
    end
    
    typesig { [::Java::Int] }
    def _la(i)
      node = @input._lt(i)
      id = @adaptor.get_unique_id(node)
      text = @adaptor.get_text(node)
      type = @adaptor.get_type(node)
      @dbg._lt(i, node)
      return type
    end
    
    typesig { [] }
    def mark
      @last_marker = @input.mark
      @dbg.mark(@last_marker)
      return @last_marker
    end
    
    typesig { [] }
    def index
      return @input.index
    end
    
    typesig { [::Java::Int] }
    def rewind(marker)
      @dbg.rewind(marker)
      @input.rewind(marker)
    end
    
    typesig { [] }
    def rewind
      @dbg.rewind
      @input.rewind(@last_marker)
    end
    
    typesig { [::Java::Int] }
    def release(marker)
    end
    
    typesig { [::Java::Int] }
    def seek(index_)
      # TODO: implement seek in dbg interface
      # db.seek(index);
      @input.seek(index_)
    end
    
    typesig { [] }
    def size
      return @input.size
    end
    
    typesig { [] }
    def get_tree_source
      return @input
    end
    
    typesig { [] }
    def get_source_name
      return get_token_stream.get_source_name
    end
    
    typesig { [] }
    def get_token_stream
      return @input.get_token_stream
    end
    
    typesig { [::Java::Boolean] }
    # It is normally this object that instructs the node stream to
    # create unique nav nodes, but to satisfy interface, we have to
    # define it.  It might be better to ignore the parameter but
    # there might be a use for it later, so I'll leave.
    def set_unique_navigation_nodes(unique_navigation_nodes)
      @input.set_unique_navigation_nodes(unique_navigation_nodes)
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int, Object] }
    def replace_children(parent, start_child_index, stop_child_index, t)
      @input.replace_children(parent, start_child_index, stop_child_index, t)
    end
    
    typesig { [Object, Object] }
    def to_s(start, stop)
      return @input.to_s(start, stop)
    end
    
    private
    alias_method :initialize__debug_tree_node_stream, :initialize
  end
  
end
