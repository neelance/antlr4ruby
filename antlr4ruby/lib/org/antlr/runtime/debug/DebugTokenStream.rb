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
  module DebugTokenStreamImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include ::Org::Antlr::Runtime
    }
  end
  
  class DebugTokenStream 
    include_class_members DebugTokenStreamImports
    include TokenStream
    
    attr_accessor :dbg
    alias_method :attr_dbg, :dbg
    undef_method :dbg
    alias_method :attr_dbg=, :dbg=
    undef_method :dbg=
    
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
    
    typesig { [TokenStream, DebugEventListener] }
    def initialize(input, dbg)
      @dbg = nil
      @input = nil
      @initial_stream_state = true
      @last_marker = 0
      @input = input
      set_debug_listener(dbg)
      # force TokenStream to get at least first valid token
      # so we know if there are any hidden tokens first in the stream
      input._lt(1)
    end
    
    typesig { [DebugEventListener] }
    def set_debug_listener(dbg)
      @dbg = dbg
    end
    
    typesig { [] }
    def consume
      if (@initial_stream_state)
        consume_initial_hidden_tokens
      end
      a = @input.index
      t = @input._lt(1)
      @input.consume
      b = @input.index
      @dbg.consume_token(t)
      if (b > a + 1)
        # then we consumed more than one token; must be off channel tokens
        i = a + 1
        while i < b
          @dbg.consume_hidden_token(@input.get(i))
          i += 1
        end
      end
    end
    
    typesig { [] }
    # consume all initial off-channel tokens
    def consume_initial_hidden_tokens
      first_on_channel_token_index = @input.index
      i = 0
      while i < first_on_channel_token_index
        @dbg.consume_hidden_token(@input.get(i))
        i += 1
      end
      @initial_stream_state = false
    end
    
    typesig { [::Java::Int] }
    def _lt(i)
      if (@initial_stream_state)
        consume_initial_hidden_tokens
      end
      @dbg._lt(i, @input._lt(i))
      return @input._lt(i)
    end
    
    typesig { [::Java::Int] }
    def _la(i)
      if (@initial_stream_state)
        consume_initial_hidden_tokens
      end
      @dbg._lt(i, @input._lt(i))
      return @input._la(i)
    end
    
    typesig { [::Java::Int] }
    def get(i)
      return @input.get(i)
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
    def get_token_source
      return @input.get_token_source
    end
    
    typesig { [] }
    def get_source_name
      return get_token_source.get_source_name
    end
    
    typesig { [] }
    def to_s
      return @input.to_s
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def to_s(start, stop)
      return @input.to_s(start, stop)
    end
    
    typesig { [Token, Token] }
    def to_s(start, stop)
      return @input.to_s(start, stop)
    end
    
    private
    alias_method :initialize__debug_token_stream, :initialize
  end
  
end
