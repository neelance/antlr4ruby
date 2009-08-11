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
  module DebugTreeParserImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include ::Org::Antlr::Runtime
      include_const ::Org::Antlr::Runtime::Tree, :TreeNodeStream
      include_const ::Org::Antlr::Runtime::Tree, :TreeParser
      include_const ::Java::Io, :IOException
    }
  end
  
  class DebugTreeParser < DebugTreeParserImports.const_get :TreeParser
    include_class_members DebugTreeParserImports
    
    # Who to notify when events in the parser occur.
    attr_accessor :dbg
    alias_method :attr_dbg, :dbg
    undef_method :dbg
    alias_method :attr_dbg=, :dbg=
    undef_method :dbg=
    
    # Used to differentiate between fixed lookahead and cyclic DFA decisions
    # while profiling.
    attr_accessor :is_cyclic_decision
    alias_method :attr_is_cyclic_decision, :is_cyclic_decision
    undef_method :is_cyclic_decision
    alias_method :attr_is_cyclic_decision=, :is_cyclic_decision=
    undef_method :is_cyclic_decision=
    
    typesig { [TreeNodeStream, DebugEventListener, RecognizerSharedState] }
    # Create a normal parser except wrap the token stream in a debug
    # proxy that fires consume events.
    def initialize(input, dbg, state)
      @dbg = nil
      @is_cyclic_decision = false
      super(input.is_a?(DebugTreeNodeStream) ? input : DebugTreeNodeStream.new(input, dbg), state)
      @dbg = nil
      @is_cyclic_decision = false
      set_debug_listener(dbg)
    end
    
    typesig { [TreeNodeStream, RecognizerSharedState] }
    def initialize(input, state)
      @dbg = nil
      @is_cyclic_decision = false
      super(input.is_a?(DebugTreeNodeStream) ? input : DebugTreeNodeStream.new(input, nil), state)
      @dbg = nil
      @is_cyclic_decision = false
    end
    
    typesig { [TreeNodeStream, DebugEventListener] }
    def initialize(input, dbg)
      initialize__debug_tree_parser(input.is_a?(DebugTreeNodeStream) ? input : DebugTreeNodeStream.new(input, dbg), dbg, nil)
    end
    
    typesig { [DebugEventListener] }
    # Provide a new debug event listener for this parser.  Notify the
    # input stream too that it should send events to this listener.
    def set_debug_listener(dbg)
      if (self.attr_input.is_a?(DebugTreeNodeStream))
        (self.attr_input).set_debug_listener(dbg)
      end
      @dbg = dbg
    end
    
    typesig { [] }
    def get_debug_listener
      return @dbg
    end
    
    typesig { [IOException] }
    def report_error(e)
      System.err.println(e)
      e.print_stack_trace(System.err)
    end
    
    typesig { [RecognitionException] }
    def report_error(e)
      @dbg.recognition_exception(e)
    end
    
    typesig { [IntStream, RecognitionException, ::Java::Int, BitSet] }
    def get_missing_symbol(input, e, expected_token_type, follow)
      o = super(input, e, expected_token_type, follow)
      @dbg.consume_node(o)
      return o
    end
    
    typesig { [] }
    def begin_resync
      @dbg.begin_resync
    end
    
    typesig { [] }
    def end_resync
      @dbg.end_resync
    end
    
    typesig { [::Java::Int] }
    def begin_backtrack(level)
      @dbg.begin_backtrack(level)
    end
    
    typesig { [::Java::Int, ::Java::Boolean] }
    def end_backtrack(level, successful)
      @dbg.end_backtrack(level, successful)
    end
    
    private
    alias_method :initialize__debug_tree_parser, :initialize
  end
  
end
