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
  module LexerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  # A lexer is recognizer that draws input symbols from a character stream.
  # lexer grammars result in a subclass of this object. A Lexer object
  # uses simplified match() and error recovery mechanisms in the interest
  # of speed.
  class Lexer < LexerImports.const_get :BaseRecognizer
    include_class_members LexerImports
    overload_protected {
      include TokenSource
    }
    
    # Where is the lexer drawing characters from?
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    typesig { [] }
    def initialize
      @input = nil
      super()
    end
    
    typesig { [CharStream] }
    def initialize(input)
      @input = nil
      super()
      @input = input
    end
    
    typesig { [CharStream, RecognizerSharedState] }
    def initialize(input, state)
      @input = nil
      super(state)
      @input = input
    end
    
    typesig { [] }
    def reset
      super # reset all recognizer state variables
      # wack Lexer state variables
      if (!(@input).nil?)
        @input.seek(0) # rewind the input
      end
      if ((self.attr_state).nil?)
        return # no shared state work to do
      end
      self.attr_state.attr_token = nil
      self.attr_state.attr_type = Token::INVALID_TOKEN_TYPE
      self.attr_state.attr_channel = Token::DEFAULT_CHANNEL
      self.attr_state.attr_token_start_char_index = -1
      self.attr_state.attr_token_start_char_position_in_line = -1
      self.attr_state.attr_token_start_line = -1
      self.attr_state.attr_text = nil
    end
    
    typesig { [] }
    # Return a token from this source; i.e., match a token on the char
    # stream.
    def next_token
      while (true)
        self.attr_state.attr_token = nil
        self.attr_state.attr_channel = Token::DEFAULT_CHANNEL
        self.attr_state.attr_token_start_char_index = @input.index
        self.attr_state.attr_token_start_char_position_in_line = @input.get_char_position_in_line
        self.attr_state.attr_token_start_line = @input.get_line
        self.attr_state.attr_text = nil
        if ((@input._la(1)).equal?(CharStream::EOF))
          return Token::EOF_TOKEN
        end
        begin
          m_tokens
          if ((self.attr_state.attr_token).nil?)
            emit
          else
            if ((self.attr_state.attr_token).equal?(Token::SKIP_TOKEN))
              next
            end
          end
          return self.attr_state.attr_token
        rescue NoViableAltException => nva
          report_error(nva)
          recover(nva) # throw out current char and try again
        rescue RecognitionException => re
          report_error(re)
          # match() routine has already called recover()
        end
      end
    end
    
    typesig { [] }
    # Instruct the lexer to skip creating a token for current lexer rule
    # and look for another token.  nextToken() knows to keep looking when
    # a lexer rule finishes with token set to SKIP_TOKEN.  Recall that
    # if token==null at end of any token rule, it creates one for you
    # and emits it.
    def skip
      self.attr_state.attr_token = Token::SKIP_TOKEN
    end
    
    typesig { [] }
    # This is the lexer entry point that sets instance var 'token'
    def m_tokens
      raise NotImplementedError
    end
    
    typesig { [CharStream] }
    # Set the char stream and reset the lexer
    def set_char_stream(input)
      @input = nil
      reset
      @input = input
    end
    
    typesig { [] }
    def get_char_stream
      return @input
    end
    
    typesig { [] }
    def get_source_name
      return @input.get_source_name
    end
    
    typesig { [Token] }
    # Currently does not support multiple emits per nextToken invocation
    # for efficiency reasons.  Subclass and override this method and
    # nextToken (to push tokens into a list and pull from that list rather
    # than a single variable as this implementation does).
    def emit(token)
      self.attr_state.attr_token = token
    end
    
    typesig { [] }
    # The standard method called to automatically emit a token at the
    # outermost lexical rule.  The token object should point into the
    # char buffer start..stop.  If there is a text override in 'text',
    # use that to set the token's text.  Override this method to emit
    # custom Token objects.
    # 
    # If you are building trees, then you should also override
    # Parser or TreeParser.getMissingSymbol().
    def emit
      t = CommonToken.new(@input, self.attr_state.attr_type, self.attr_state.attr_channel, self.attr_state.attr_token_start_char_index, get_char_index - 1)
      t.set_line(self.attr_state.attr_token_start_line)
      t.set_text(self.attr_state.attr_text)
      t.set_char_position_in_line(self.attr_state.attr_token_start_char_position_in_line)
      emit(t)
      return t
    end
    
    typesig { [String] }
    def match(s)
      i = 0
      while (i < s.length)
        if (!(@input._la(1)).equal?(s.char_at(i)))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          mte = MismatchedTokenException.new(s.char_at(i), @input)
          recover(mte)
          raise mte
        end
        i += 1
        @input.consume
        self.attr_state.attr_failed = false
      end
    end
    
    typesig { [] }
    def match_any
      @input.consume
    end
    
    typesig { [::Java::Int] }
    def match(c)
      if (!(@input._la(1)).equal?(c))
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return
        end
        mte = MismatchedTokenException.new(c, @input)
        recover(mte) # don't really recover; just consume in lexer
        raise mte
      end
      @input.consume
      self.attr_state.attr_failed = false
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def match_range(a, b)
      if (@input._la(1) < a || @input._la(1) > b)
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return
        end
        mre = MismatchedRangeException.new(a, b, @input)
        recover(mre)
        raise mre
      end
      @input.consume
      self.attr_state.attr_failed = false
    end
    
    typesig { [] }
    def get_line
      return @input.get_line
    end
    
    typesig { [] }
    def get_char_position_in_line
      return @input.get_char_position_in_line
    end
    
    typesig { [] }
    # What is the index of the current character of lookahead?
    def get_char_index
      return @input.index
    end
    
    typesig { [] }
    # Return the text matched so far for the current token or any
    # text override.
    def get_text
      if (!(self.attr_state.attr_text).nil?)
        return self.attr_state.attr_text
      end
      return @input.substring(self.attr_state.attr_token_start_char_index, get_char_index - 1)
    end
    
    typesig { [String] }
    # Set the complete text of this token; it wipes any previous
    # changes to the text.
    def set_text(text)
      self.attr_state.attr_text = text
    end
    
    typesig { [RecognitionException] }
    def report_error(e)
      # TODO: not thought about recovery in lexer yet.
      # 
      # // if we've already reported an error and have not matched a token
      # // yet successfully, don't report any errors.
      # if ( errorRecovery ) {
      # //System.err.print("[SPURIOUS] ");
      # return;
      # }
      # errorRecovery = true;
      display_recognition_error(self.get_token_names, e)
    end
    
    typesig { [RecognitionException, Array.typed(String)] }
    def get_error_message(e, token_names)
      msg = nil
      if (e.is_a?(MismatchedTokenException))
        mte = e
        msg = "mismatched character " + RJava.cast_to_string(get_char_error_display(e.attr_c)) + " expecting " + RJava.cast_to_string(get_char_error_display(mte.attr_expecting))
      else
        if (e.is_a?(NoViableAltException))
          nvae = e
          # for development, can add "decision=<<"+nvae.grammarDecisionDescription+">>"
          # and "(decision="+nvae.decisionNumber+") and
          # "state "+nvae.stateNumber
          msg = "no viable alternative at character " + RJava.cast_to_string(get_char_error_display(e.attr_c))
        else
          if (e.is_a?(EarlyExitException))
            eee = e
            # for development, can add "(decision="+eee.decisionNumber+")"
            msg = "required (...)+ loop did not match anything at character " + RJava.cast_to_string(get_char_error_display(e.attr_c))
          else
            if (e.is_a?(MismatchedNotSetException))
              mse = e
              msg = "mismatched character " + RJava.cast_to_string(get_char_error_display(e.attr_c)) + " expecting set " + RJava.cast_to_string(mse.attr_expecting)
            else
              if (e.is_a?(MismatchedSetException))
                mse = e
                msg = "mismatched character " + RJava.cast_to_string(get_char_error_display(e.attr_c)) + " expecting set " + RJava.cast_to_string(mse.attr_expecting)
              else
                if (e.is_a?(MismatchedRangeException))
                  mre = e
                  msg = "mismatched character " + RJava.cast_to_string(get_char_error_display(e.attr_c)) + " expecting set " + RJava.cast_to_string(get_char_error_display(mre.attr_a)) + ".." + RJava.cast_to_string(get_char_error_display(mre.attr_b))
                else
                  msg = RJava.cast_to_string(super(e, token_names))
                end
              end
            end
          end
        end
      end
      return msg
    end
    
    typesig { [::Java::Int] }
    def get_char_error_display(c)
      s = String.value_of(RJava.cast_to_char(c))
      case (c)
      when Token::EOF
        s = "<EOF>"
      when Character.new(?\n.ord)
        s = "\\n"
      when Character.new(?\t.ord)
        s = "\\t"
      when Character.new(?\r.ord)
        s = "\\r"
      end
      return "'" + s + "'"
    end
    
    typesig { [RecognitionException] }
    # Lexers can normally match any char in it's vocabulary after matching
    # a token, so do the easy thing and just kill a character and hope
    # it all works out.  You can instead use the rule invocation stack
    # to do sophisticated error recovery if you are in a fragment rule.
    def recover(re)
      # System.out.println("consuming char "+(char)input.LA(1)+" during recovery");
      # re.printStackTrace();
      @input.consume
    end
    
    typesig { [String, ::Java::Int] }
    def trace_in(rule_name, rule_index)
      input_symbol = RJava.cast_to_string((RJava.cast_to_char(@input._lt(1)))) + " line=" + RJava.cast_to_string(get_line) + ":" + RJava.cast_to_string(get_char_position_in_line)
      super(rule_name, rule_index, input_symbol)
    end
    
    typesig { [String, ::Java::Int] }
    def trace_out(rule_name, rule_index)
      input_symbol = RJava.cast_to_string((RJava.cast_to_char(@input._lt(1)))) + " line=" + RJava.cast_to_string(get_line) + ":" + RJava.cast_to_string(get_char_position_in_line)
      super(rule_name, rule_index, input_symbol)
    end
    
    private
    alias_method :initialize__lexer, :initialize
  end
  
end
