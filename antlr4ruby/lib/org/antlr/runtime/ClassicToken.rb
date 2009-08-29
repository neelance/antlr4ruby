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
  module ClassicTokenImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  # A Token object like we'd use in ANTLR 2.x; has an actual string created
  # and associated with this object.  These objects are needed for imaginary
  # tree nodes that have payload objects.  We need to create a Token object
  # that has a string; the tree node will point at this token.  CommonToken
  # has indexes into a char stream and hence cannot be used to introduce
  # new strings.
  class ClassicToken 
    include_class_members ClassicTokenImports
    include Token
    
    attr_accessor :text
    alias_method :attr_text, :text
    undef_method :text
    alias_method :attr_text=, :text=
    undef_method :text=
    
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
    
    attr_accessor :channel
    alias_method :attr_channel, :channel
    undef_method :channel
    alias_method :attr_channel=, :channel=
    undef_method :channel=
    
    # What token number is this from 0..n-1 tokens
    attr_accessor :index
    alias_method :attr_index, :index
    undef_method :index
    alias_method :attr_index=, :index=
    undef_method :index=
    
    typesig { [::Java::Int] }
    def initialize(type)
      @text = nil
      @type = 0
      @line = 0
      @char_position_in_line = 0
      @channel = DEFAULT_CHANNEL
      @index = 0
      @type = type
    end
    
    typesig { [Token] }
    def initialize(old_token)
      @text = nil
      @type = 0
      @line = 0
      @char_position_in_line = 0
      @channel = DEFAULT_CHANNEL
      @index = 0
      @text = RJava.cast_to_string(old_token.get_text)
      @type = old_token.get_type
      @line = old_token.get_line
      @char_position_in_line = old_token.get_char_position_in_line
      @channel = old_token.get_channel
    end
    
    typesig { [::Java::Int, String] }
    def initialize(type, text)
      @text = nil
      @type = 0
      @line = 0
      @char_position_in_line = 0
      @channel = DEFAULT_CHANNEL
      @index = 0
      @type = type
      @text = text
    end
    
    typesig { [::Java::Int, String, ::Java::Int] }
    def initialize(type, text, channel)
      @text = nil
      @type = 0
      @line = 0
      @char_position_in_line = 0
      @channel = DEFAULT_CHANNEL
      @index = 0
      @type = type
      @text = text
      @channel = channel
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
      return @text
    end
    
    typesig { [String] }
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
    def get_token_index
      return @index
    end
    
    typesig { [::Java::Int] }
    def set_token_index(index)
      @index = index
    end
    
    typesig { [] }
    def get_input_stream
      return nil
    end
    
    typesig { [CharStream] }
    def set_input_stream(input)
    end
    
    typesig { [] }
    def to_s
      channel_str = ""
      if (@channel > 0)
        channel_str = ",channel=" + RJava.cast_to_string(@channel)
      end
      txt = get_text
      if (!(txt).nil?)
        txt = RJava.cast_to_string(txt.replace_all("\n", "\\\\n"))
        txt = RJava.cast_to_string(txt.replace_all("\r", "\\\\r"))
        txt = RJava.cast_to_string(txt.replace_all("\t", "\\\\t"))
      else
        txt = "<no text>"
      end
      return "[@" + RJava.cast_to_string(get_token_index) + ",'" + txt + "',<" + RJava.cast_to_string(@type) + ">" + channel_str + "," + RJava.cast_to_string(@line) + ":" + RJava.cast_to_string(get_char_position_in_line) + "]"
    end
    
    private
    alias_method :initialize__classic_token, :initialize
  end
  
end
