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
  module TokenImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  module Token
    include_class_members TokenImports
    
    class_module.module_eval {
      const_set_lazy(:EOR_TOKEN_TYPE) { 1 }
      const_attr_reader  :EOR_TOKEN_TYPE
      
      # imaginary tree navigation type; traverse "get child" link
      const_set_lazy(:DOWN) { 2 }
      const_attr_reader  :DOWN
      
      # imaginary tree navigation type; finish with a child list
      const_set_lazy(:UP) { 3 }
      const_attr_reader  :UP
      
      const_set_lazy(:MIN_TOKEN_TYPE) { UP + 1 }
      const_attr_reader  :MIN_TOKEN_TYPE
      
      # All tokens go to the parser (unless skip() is called in that rule)
      # on a particular "channel".  The parser tunes to a particular channel
      # so that whitespace etc... can go to the parser on a "hidden" channel.
      const_set_lazy(:DEFAULT_CHANNEL) { 0 }
      const_attr_reader  :DEFAULT_CHANNEL
      
      # Anything on different channel than DEFAULT_CHANNEL is not parsed
      # by parser.
      const_set_lazy(:HIDDEN_CHANNEL) { 99 }
      const_attr_reader  :HIDDEN_CHANNEL
      
      const_set_lazy(:EOF) { CharStream::EOF }
      const_attr_reader  :EOF
      
      const_set_lazy(:EOF_TOKEN) { CommonToken.new(EOF) }
      const_attr_reader  :EOF_TOKEN
      
      const_set_lazy(:INVALID_TOKEN_TYPE) { 0 }
      const_attr_reader  :INVALID_TOKEN_TYPE
      
      const_set_lazy(:INVALID_TOKEN) { CommonToken.new(INVALID_TOKEN_TYPE) }
      const_attr_reader  :INVALID_TOKEN
      
      # In an action, a lexer rule can set token to this SKIP_TOKEN and ANTLR
      # will avoid creating a token for this symbol and try to fetch another.
      const_set_lazy(:SKIP_TOKEN) { CommonToken.new(INVALID_TOKEN_TYPE) }
      const_attr_reader  :SKIP_TOKEN
    }
    
    typesig { [] }
    # Get the text of the token
    def get_text
      raise NotImplementedError
    end
    
    typesig { [String] }
    def set_text(text)
      raise NotImplementedError
    end
    
    typesig { [] }
    def get_type
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_type(ttype)
      raise NotImplementedError
    end
    
    typesig { [] }
    # The line number on which this token was matched; line=1..n
    def get_line
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_line(line)
      raise NotImplementedError
    end
    
    typesig { [] }
    # The index of the first character relative to the beginning of the line 0..n-1
    def get_char_position_in_line
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_char_position_in_line(pos)
      raise NotImplementedError
    end
    
    typesig { [] }
    def get_channel
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_channel(channel)
      raise NotImplementedError
    end
    
    typesig { [] }
    # An index from 0..n-1 of the token object in the input stream.
    # This must be valid in order to use the ANTLRWorks debugger.
    def get_token_index
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_token_index(index)
      raise NotImplementedError
    end
    
    typesig { [] }
    # From what character stream was this token created?  You don't have to
    # implement but it's nice to know where a Token comes from if you have
    # include files etc... on the input.
    def get_input_stream
      raise NotImplementedError
    end
    
    typesig { [CharStream] }
    def set_input_stream(input)
      raise NotImplementedError
    end
  end
  
end
