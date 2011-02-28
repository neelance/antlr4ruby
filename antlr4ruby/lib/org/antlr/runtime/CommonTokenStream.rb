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
module Org::Antlr::Runtime
  module CommonTokenStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include ::Java::Util
    }
  end
  
  # The most common stream of tokens is one where every token is buffered up
  # and tokens are prefiltered for a certain channel (the parser will only
  # see these tokens and cannot change the filter channel number during the
  # parse).
  # 
  # TODO: how to access the full token stream?  How to track all tokens matched per rule?
  class CommonTokenStream 
    include_class_members CommonTokenStreamImports
    include TokenStream
    
    attr_accessor :token_source
    alias_method :attr_token_source, :token_source
    undef_method :token_source
    alias_method :attr_token_source=, :token_source=
    undef_method :token_source=
    
    # Record every single token pulled from the source so we can reproduce
    # chunks of it later.
    attr_accessor :tokens
    alias_method :attr_tokens, :tokens
    undef_method :tokens
    alias_method :attr_tokens=, :tokens=
    undef_method :tokens=
    
    # Map<tokentype, channel> to override some Tokens' channel numbers
    attr_accessor :channel_override_map
    alias_method :attr_channel_override_map, :channel_override_map
    undef_method :channel_override_map
    alias_method :attr_channel_override_map=, :channel_override_map=
    undef_method :channel_override_map=
    
    # Set<tokentype>; discard any tokens with this type
    attr_accessor :discard_set
    alias_method :attr_discard_set, :discard_set
    undef_method :discard_set
    alias_method :attr_discard_set=, :discard_set=
    undef_method :discard_set=
    
    # Skip tokens on any channel but this one; this is how we skip whitespace...
    attr_accessor :channel
    alias_method :attr_channel, :channel
    undef_method :channel
    alias_method :attr_channel=, :channel=
    undef_method :channel=
    
    # By default, track all incoming tokens
    attr_accessor :discard_off_channel_tokens
    alias_method :attr_discard_off_channel_tokens, :discard_off_channel_tokens
    undef_method :discard_off_channel_tokens
    alias_method :attr_discard_off_channel_tokens=, :discard_off_channel_tokens=
    undef_method :discard_off_channel_tokens=
    
    # Track the last mark() call result value for use in rewind().
    attr_accessor :last_marker
    alias_method :attr_last_marker, :last_marker
    undef_method :last_marker
    alias_method :attr_last_marker=, :last_marker=
    undef_method :last_marker=
    
    # The index into the tokens list of the current token (next token
    # to consume).  p==-1 indicates that the tokens list is empty
    attr_accessor :p
    alias_method :attr_p, :p
    undef_method :p
    alias_method :attr_p=, :p=
    undef_method :p=
    
    typesig { [] }
    def initialize
      @token_source = nil
      @tokens = nil
      @channel_override_map = nil
      @discard_set = nil
      @channel = Token::DEFAULT_CHANNEL
      @discard_off_channel_tokens = false
      @last_marker = 0
      @p = -1
      @tokens = ArrayList.new(500)
    end
    
    typesig { [TokenSource] }
    def initialize(token_source)
      initialize__common_token_stream()
      @token_source = token_source
    end
    
    typesig { [TokenSource, ::Java::Int] }
    def initialize(token_source, channel)
      initialize__common_token_stream(token_source)
      @channel = channel
    end
    
    typesig { [TokenSource] }
    # Reset this token stream by setting its token source.
    def set_token_source(token_source)
      @token_source = token_source
      @tokens.clear
      @p = -1
      @channel = Token::DEFAULT_CHANNEL
    end
    
    typesig { [] }
    # Load all tokens from the token source and put in tokens.
    # This is done upon first LT request because you might want to
    # set some token type / channel overrides before filling buffer.
    def fill_buffer
      index = 0
      t = @token_source.next_token
      while (!(t).nil? && !(t.get_type).equal?(CharStream::EOF))
        discard = false
        # is there a channel override for token type?
        if (!(@channel_override_map).nil?)
          channel_i = @channel_override_map.get(t.get_type)
          if (!(channel_i).nil?)
            t.set_channel(channel_i.int_value)
          end
        end
        if (!(@discard_set).nil? && @discard_set.contains(t.get_type))
          discard = true
        else
          if (@discard_off_channel_tokens && !(t.get_channel).equal?(@channel))
            discard = true
          end
        end
        if (!discard)
          t.set_token_index(index)
          @tokens.add(t)
          index += 1
        end
        t = @token_source.next_token
      end
      # leave p pointing at first token on channel
      @p = 0
      @p = skip_off_token_channels(@p)
    end
    
    typesig { [] }
    # Move the input pointer to the next incoming token.  The stream
    # must become active with LT(1) available.  consume() simply
    # moves the input pointer so that LT(1) points at the next
    # input symbol. Consume at least one token.
    # 
    # Walk past any token not on the channel the parser is listening to.
    def consume
      if (@p < @tokens.size)
        @p += 1
        @p = skip_off_token_channels(@p) # leave p on valid token
      end
    end
    
    typesig { [::Java::Int] }
    # Given a starting index, return the index of the first on-channel
    # token.
    def skip_off_token_channels(i)
      n = @tokens.size
      while (i < n && !((@tokens.get(i)).get_channel).equal?(@channel))
        i += 1
      end
      return i
    end
    
    typesig { [::Java::Int] }
    def skip_off_token_channels_reverse(i)
      while (i >= 0 && !((@tokens.get(i)).get_channel).equal?(@channel))
        i -= 1
      end
      return i
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # A simple filter mechanism whereby you can tell this token stream
    # to force all tokens of type ttype to be on channel.  For example,
    # when interpreting, we cannot exec actions so we need to tell
    # the stream to force all WS and NEWLINE to be a different, ignored
    # channel.
    def set_token_type_channel(ttype, channel)
      if ((@channel_override_map).nil?)
        @channel_override_map = HashMap.new
      end
      @channel_override_map.put(ttype, channel)
    end
    
    typesig { [::Java::Int] }
    def discard_token_type(ttype)
      if ((@discard_set).nil?)
        @discard_set = HashSet.new
      end
      @discard_set.add(ttype)
    end
    
    typesig { [::Java::Boolean] }
    def discard_off_channel_tokens(discard_off_channel_tokens)
      @discard_off_channel_tokens = discard_off_channel_tokens
    end
    
    typesig { [] }
    def get_tokens
      if ((@p).equal?(-1))
        fill_buffer
      end
      return @tokens
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def get_tokens(start, stop)
      return get_tokens(start, stop, nil)
    end
    
    typesig { [::Java::Int, ::Java::Int, BitSet] }
    # Given a start and stop index, return a List of all tokens in
    # the token type BitSet.  Return null if no tokens were found.  This
    # method looks at both on and off channel tokens.
    def get_tokens(start, stop, types)
      if ((@p).equal?(-1))
        fill_buffer
      end
      if (stop >= @tokens.size)
        stop = @tokens.size - 1
      end
      if (start < 0)
        start = 0
      end
      if (start > stop)
        return nil
      end
      # list = tokens[start:stop]:{Token t, t.getType() in types}
      filtered_tokens = ArrayList.new
      i = start
      while i <= stop
        t = @tokens.get(i)
        if ((types).nil? || types.member(t.get_type))
          filtered_tokens.add(t)
        end
        i += 1
      end
      if ((filtered_tokens.size).equal?(0))
        filtered_tokens = nil
      end
      return filtered_tokens
    end
    
    typesig { [::Java::Int, ::Java::Int, JavaList] }
    def get_tokens(start, stop, types)
      return get_tokens(start, stop, BitSet.new(types))
    end
    
    typesig { [::Java::Int, ::Java::Int, ::Java::Int] }
    def get_tokens(start, stop, ttype)
      return get_tokens(start, stop, BitSet.of(ttype))
    end
    
    typesig { [::Java::Int] }
    # Get the ith token from the current position 1..n where k=1 is the
    # first symbol of lookahead.
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
      if ((@p + k - 1) >= @tokens.size)
        return Token::EOF_TOKEN
      end
      # System.out.println(tokens.get(p+k-1));
      i = @p
      n = 1
      # find k good tokens
      while (n < k)
        # skip off-channel tokens
        i = skip_off_token_channels(i + 1) # leave p on valid token
        n += 1
      end
      if (i >= @tokens.size)
        return Token::EOF_TOKEN
      end
      return @tokens.get(i)
    end
    
    typesig { [::Java::Int] }
    # Look backwards k tokens on-channel tokens
    def _lb(k)
      # System.out.print("LB(p="+p+","+k+") ");
      if ((@p).equal?(-1))
        fill_buffer
      end
      if ((k).equal?(0))
        return nil
      end
      if ((@p - k) < 0)
        return nil
      end
      i = @p
      n = 1
      # find k good tokens looking backwards
      while (n <= k)
        # skip off-channel tokens
        i = skip_off_token_channels_reverse(i - 1) # leave p on valid token
        n += 1
      end
      if (i < 0)
        return nil
      end
      return @tokens.get(i)
    end
    
    typesig { [::Java::Int] }
    # Return absolute token i; ignore which channel the tokens are on;
    # that is, count all tokens not just on-channel tokens.
    def get(i)
      return @tokens.get(i)
    end
    
    typesig { [::Java::Int] }
    def _la(i)
      return _lt(i).get_type
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
    def size
      return @tokens.size
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
    
    typesig { [] }
    def reset
      @p = 0
      @last_marker = 0
    end
    
    typesig { [::Java::Int] }
    def seek(index_)
      @p = index_
    end
    
    typesig { [] }
    def get_token_source
      return @token_source
    end
    
    typesig { [] }
    def get_source_name
      return get_token_source.get_source_name
    end
    
    typesig { [] }
    def to_s
      if ((@p).equal?(-1))
        fill_buffer
      end
      return to_s(0, @tokens.size - 1)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def to_s(start, stop)
      if (start < 0 || stop < 0)
        return nil
      end
      if ((@p).equal?(-1))
        fill_buffer
      end
      if (stop >= @tokens.size)
        stop = @tokens.size - 1
      end
      buf = StringBuffer.new
      i = start
      while i <= stop
        t = @tokens.get(i)
        buf.append(t.get_text)
        i += 1
      end
      return buf.to_s
    end
    
    typesig { [Token, Token] }
    def to_s(start, stop)
      if (!(start).nil? && !(stop).nil?)
        return to_s(start.get_token_index, stop.get_token_index)
      end
      return nil
    end
    
    private
    alias_method :initialize__common_token_stream, :initialize
  end
  
end
