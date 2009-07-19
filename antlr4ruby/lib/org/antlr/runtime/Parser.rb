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
  module ParserImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  # A parser for TokenStreams.  "parser grammars" result in a subclass
  # of this.
  class Parser < ParserImports.const_get :BaseRecognizer
    include_class_members ParserImports
    
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    typesig { [TokenStream] }
    def initialize(input)
      @input = nil
      super() # highlight that we go to super to set state object
      set_token_stream(input)
    end
    
    typesig { [TokenStream, RecognizerSharedState] }
    def initialize(input, state)
      @input = nil
      super(state) # share the state object with another parser
      set_token_stream(input)
    end
    
    typesig { [] }
    def reset
      super # reset all recognizer state variables
      if (!(@input).nil?)
        @input.seek(0) # rewind the input
      end
    end
    
    typesig { [IntStream] }
    def get_current_input_symbol(input)
      return (input)._lt(1)
    end
    
    typesig { [IntStream, RecognitionException, ::Java::Int, BitSet] }
    def get_missing_symbol(input, e, expected_token_type, follow)
      token_text = nil
      if ((expected_token_type).equal?(Token::EOF))
        token_text = "<missing EOF>"
      else
        token_text = "<missing " + (get_token_names[expected_token_type]).to_s + ">"
      end
      t = CommonToken.new(expected_token_type, token_text)
      current = (input)._lt(1)
      if ((current.get_type).equal?(Token::EOF))
        current = (input)._lt(-1)
      end
      t.attr_line = current.get_line
      t.attr_char_position_in_line = current.get_char_position_in_line
      t.attr_channel = DEFAULT_TOKEN_CHANNEL
      return t
    end
    
    typesig { [TokenStream] }
    # Set the token stream and reset the parser
    def set_token_stream(input)
      @input = nil
      reset
      @input = input
    end
    
    typesig { [] }
    def get_token_stream
      return @input
    end
    
    typesig { [] }
    def get_source_name
      return @input.get_source_name
    end
    
    typesig { [String, ::Java::Int] }
    def trace_in(rule_name, rule_index)
      super(rule_name, rule_index, @input._lt(1))
    end
    
    typesig { [String, ::Java::Int] }
    def trace_out(rule_name, rule_index)
      super(rule_name, rule_index, @input._lt(1))
    end
    
    private
    alias_method :initialize__parser, :initialize
  end
  
end
