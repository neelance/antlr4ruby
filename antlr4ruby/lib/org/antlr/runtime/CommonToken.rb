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
module Org::Antlr::Runtime
  module CommonTokenImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include_const ::Java::Io, :Serializable
    }
  end
  
  class CommonToken 
    include_class_members CommonTokenImports
    include Token
    include Serializable
    
    attr_accessor :type
    alias_method :attr_type, :type
    undef_method :type
    alias_method :attr_type=, :type=
    undef_method :type=
    
    attr_accessor :line
    alias_method :attr_line, :line
    undef_method :line
    alias_method :attr_line=, :line=
    undef_method :line=
    
    attr_accessor :char_position_in_line
    alias_method :attr_char_position_in_line, :char_position_in_line
    undef_method :char_position_in_line
    alias_method :attr_char_position_in_line=, :char_position_in_line=
    undef_method :char_position_in_line=
    
    # set to invalid position
    attr_accessor :channel
    alias_method :attr_channel, :channel
    undef_method :channel
    alias_method :attr_channel=, :channel=
    undef_method :channel=
    
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    # We need to be able to change the text once in a while.  If
    # this is non-null, then getText should return this.  Note that
    # start/stop are not affected by changing this.
    attr_accessor :text
    alias_method :attr_text, :text
    undef_method :text
    alias_method :attr_text=, :text=
    undef_method :text=
    
    # What token number is this from 0..n-1 tokens; < 0 implies invalid index
    attr_accessor :index
    alias_method :attr_index, :index
    undef_method :index
    alias_method :attr_index=, :index=
    undef_method :index=
    
    # The char position into the input buffer where this token starts
    attr_accessor :start
    alias_method :attr_start, :start
    undef_method :start
    alias_method :attr_start=, :start=
    undef_method :start=
    
    # The char position into the input buffer where this token stops
    attr_accessor :stop
    alias_method :attr_stop, :stop
    undef_method :stop
    alias_method :attr_stop=, :stop=
    undef_method :stop=
    
    typesig { [::Java::Int] }
    def initialize(type)
      @type = 0
      @line = 0
      @char_position_in_line = -1
      @channel = DEFAULT_CHANNEL
      @input = nil
      @text = nil
      @index = -1
      @start = 0
      @stop = 0
      @type = type
    end
    
    typesig { [CharStream, ::Java::Int, ::Java::Int, ::Java::Int, ::Java::Int] }
    def initialize(input, type, channel, start, stop)
      @type = 0
      @line = 0
      @char_position_in_line = -1
      @channel = DEFAULT_CHANNEL
      @input = nil
      @text = nil
      @index = -1
      @start = 0
      @stop = 0
      @input = input
      @type = type
      @channel = channel
      @start = start
      @stop = stop
    end
    
    typesig { [::Java::Int, String] }
    def initialize(type, text)
      @type = 0
      @line = 0
      @char_position_in_line = -1
      @channel = DEFAULT_CHANNEL
      @input = nil
      @text = nil
      @index = -1
      @start = 0
      @stop = 0
      @type = type
      @channel = DEFAULT_CHANNEL
      @text = text
    end
    
    typesig { [Token] }
    def initialize(old_token)
      @type = 0
      @line = 0
      @char_position_in_line = -1
      @channel = DEFAULT_CHANNEL
      @input = nil
      @text = nil
      @index = -1
      @start = 0
      @stop = 0
      @text = (old_token.get_text).to_s
      @type = old_token.get_type
      @line = old_token.get_line
      @index = old_token.get_token_index
      @char_position_in_line = old_token.get_char_position_in_line
      @channel = old_token.get_channel
      if (old_token.is_a?(CommonToken))
        @start = (old_token).attr_start
        @stop = (old_token).attr_stop
      end
    end
    
    typesig { [] }
    def get_type
      return @type
    end
    
    typesig { [::Java::Int] }
    def set_line(line)
      @line = line
    end
    
    typesig { [] }
    def get_text
      if (!(@text).nil?)
        return @text
      end
      if ((@input).nil?)
        return nil
      end
      @text = (@input.substring(@start, @stop)).to_s
      return @text
    end
    
    typesig { [String] }
    # Override the text for this token.  getText() will return this text
    # rather than pulling from the buffer.  Note that this does not mean
    # that start/stop indexes are not valid.  It means that that input
    # was converted to a new string in the token object.
    def set_text(text)
      @text = text
    end
    
    typesig { [] }
    def get_line
      return @line
    end
    
    typesig { [] }
    def get_char_position_in_line
      return @char_position_in_line
    end
    
    typesig { [::Java::Int] }
    def set_char_position_in_line(char_position_in_line)
      @char_position_in_line = char_position_in_line
    end
    
    typesig { [] }
    def get_channel
      return @channel
    end
    
    typesig { [::Java::Int] }
    def set_channel(channel)
      @channel = channel
    end
    
    typesig { [::Java::Int] }
    def set_type(type)
      @type = type
    end
    
    typesig { [] }
    def get_start_index
      return @start
    end
    
    typesig { [::Java::Int] }
    def set_start_index(start)
      @start = start
    end
    
    typesig { [] }
    def get_stop_index
      return @stop
    end
    
    typesig { [::Java::Int] }
    def set_stop_index(stop)
      @stop = stop
    end
    
    typesig { [] }
    def get_token_index
      return @index
    end
    
    typesig { [::Java::Int] }
    def set_token_index(index)
      @index = index
    end
    
    typesig { [] }
    def get_input_stream
      return @input
    end
    
    typesig { [CharStream] }
    def set_input_stream(input)
      @input = input
    end
    
    typesig { [] }
    def to_s
      channel_str = ""
      if (@channel > 0)
        channel_str = ",channel=" + (@channel).to_s
      end
      txt = get_text
      if (!(txt).nil?)
        txt = (txt.replace_all("\n", "\\\\n")).to_s
        txt = (txt.replace_all("\r", "\\\\r")).to_s
        txt = (txt.replace_all("\t", "\\\\t")).to_s
      else
        txt = "<no text>"
      end
      return "[@" + (get_token_index).to_s + "," + (@start).to_s + ":" + (@stop).to_s + "='" + txt + "',<" + (@type).to_s + ">" + channel_str + "," + (@line).to_s + ":" + (get_char_position_in_line).to_s + "]"
    end
    
    private
    alias_method :initialize__common_token, :initialize
  end
  
end
