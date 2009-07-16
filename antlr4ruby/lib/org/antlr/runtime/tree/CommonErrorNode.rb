require "rjava"

# 
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
  module CommonErrorNodeImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include ::Org::Antlr::Runtime
    }
  end
  
  # A node representing erroneous token range in token stream
  class CommonErrorNode < CommonErrorNodeImports.const_get :CommonTree
    include_class_members CommonErrorNodeImports
    
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    attr_accessor :start
    alias_method :attr_start, :start
    undef_method :start
    alias_method :attr_start=, :start=
    undef_method :start=
    
    attr_accessor :stop
    alias_method :attr_stop, :stop
    undef_method :stop
    alias_method :attr_stop=, :stop=
    undef_method :stop=
    
    attr_accessor :trapped_exception
    alias_method :attr_trapped_exception, :trapped_exception
    undef_method :trapped_exception
    alias_method :attr_trapped_exception=, :trapped_exception=
    undef_method :trapped_exception=
    
    typesig { [TokenStream, Token, Token, RecognitionException] }
    def initialize(input, start, stop, e)
      @input = nil
      @start = nil
      @stop = nil
      @trapped_exception = nil
      super()
      # System.out.println("start: "+start+", stop: "+stop);
      if ((stop).nil? || (stop.get_token_index < start.get_token_index && !(stop.get_type).equal?(Token::EOF)))
        # sometimes resync does not consume a token (when LT(1) is
        # in follow set.  So, stop will be 1 to left to start. adjust.
        # Also handle case where start is the first token and no token
        # is consumed during recovery; LT(-1) will return null.
        stop = start
      end
      @input = input
      @start = start
      @stop = stop
      @trapped_exception = e
    end
    
    typesig { [] }
    def is_nil
      return false
    end
    
    typesig { [] }
    def get_type
      return Token::INVALID_TOKEN_TYPE
    end
    
    typesig { [] }
    def get_text
      bad_text = nil
      if (@start.is_a?(Token))
        i = (@start).get_token_index
        j = (@stop).get_token_index
        if (((@stop).get_type).equal?(Token::EOF))
          j = (@input).size
        end
        bad_text = ((@input).to_s(i, j)).to_s
      else
        if (@start.is_a?(Tree))
          bad_text = ((@input).to_s(@start, @stop)).to_s
        else
          # people should subclass if they alter the tree type so this
          # next one is for sure correct.
          bad_text = "<unknown>"
        end
      end
      return bad_text
    end
    
    typesig { [] }
    def to_s
      if (@trapped_exception.is_a?(MissingTokenException))
        return "<missing type: " + ((@trapped_exception).get_missing_type).to_s + ">"
      else
        if (@trapped_exception.is_a?(UnwantedTokenException))
          return "<extraneous: " + ((@trapped_exception).get_unexpected_token).to_s + ", resync=" + (get_text).to_s + ">"
        else
          if (@trapped_exception.is_a?(MismatchedTokenException))
            return "<mismatched token: " + (@trapped_exception.attr_token).to_s + ", resync=" + (get_text).to_s + ">"
          else
            if (@trapped_exception.is_a?(NoViableAltException))
              return "<unexpected: " + (@trapped_exception.attr_token).to_s + ", resync=" + (get_text).to_s + ">"
            end
          end
        end
      end
      return "<error: " + (get_text).to_s + ">"
    end
    
    private
    alias_method :initialize__common_error_node, :initialize
  end
  
end
