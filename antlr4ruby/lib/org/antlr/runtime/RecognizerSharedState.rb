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
  module RecognizerSharedStateImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include_const ::Java::Util, :Map
    }
  end
  
  # The set of fields needed by an abstract recognizer to recognize input
  # and recover from errors etc...  As a separate state object, it can be
  # shared among multiple grammars; e.g., when one grammar imports another.
  # 
  # These fields are publically visible but the actual state pointer per
  # parser is protected.
  class RecognizerSharedState 
    include_class_members RecognizerSharedStateImports
    
    # Track the set of token types that can follow any rule invocation.
    # Stack grows upwards.  When it hits the max, it grows 2x in size
    # and keeps going.
    attr_accessor :following
    alias_method :attr_following, :following
    undef_method :following
    alias_method :attr_following=, :following=
    undef_method :following=
    
    attr_accessor :_fsp
    alias_method :attr__fsp, :_fsp
    undef_method :_fsp
    alias_method :attr__fsp=, :_fsp=
    undef_method :_fsp=
    
    # This is true when we see an error and before having successfully
    # matched a token.  Prevents generation of more than one error message
    # per error.
    attr_accessor :error_recovery
    alias_method :attr_error_recovery, :error_recovery
    undef_method :error_recovery
    alias_method :attr_error_recovery=, :error_recovery=
    undef_method :error_recovery=
    
    # The index into the input stream where the last error occurred.
    # This is used to prevent infinite loops where an error is found
    # but no token is consumed during recovery...another error is found,
    # ad naseum.  This is a failsafe mechanism to guarantee that at least
    # one token/tree node is consumed for two errors.
    attr_accessor :last_error_index
    alias_method :attr_last_error_index, :last_error_index
    undef_method :last_error_index
    alias_method :attr_last_error_index=, :last_error_index=
    undef_method :last_error_index=
    
    # In lieu of a return value, this indicates that a rule or token
    # has failed to match.  Reset to false upon valid token match.
    attr_accessor :failed
    alias_method :attr_failed, :failed
    undef_method :failed
    alias_method :attr_failed=, :failed=
    undef_method :failed=
    
    # Did the recognizer encounter a syntax error?  Track how many.
    attr_accessor :syntax_errors
    alias_method :attr_syntax_errors, :syntax_errors
    undef_method :syntax_errors
    alias_method :attr_syntax_errors=, :syntax_errors=
    undef_method :syntax_errors=
    
    # If 0, no backtracking is going on.  Safe to exec actions etc...
    # If >0 then it's the level of backtracking.
    attr_accessor :backtracking
    alias_method :attr_backtracking, :backtracking
    undef_method :backtracking
    alias_method :attr_backtracking=, :backtracking=
    undef_method :backtracking=
    
    # An array[size num rules] of Map<Integer,Integer> that tracks
    # the stop token index for each rule.  ruleMemo[ruleIndex] is
    # the memoization table for ruleIndex.  For key ruleStartIndex, you
    # get back the stop token for associated rule or MEMO_RULE_FAILED.
    # 
    # This is only used if rule memoization is on (which it is by default).
    attr_accessor :rule_memo
    alias_method :attr_rule_memo, :rule_memo
    undef_method :rule_memo
    alias_method :attr_rule_memo=, :rule_memo=
    undef_method :rule_memo=
    
    # LEXER FIELDS (must be in same state object to avoid casting
    # constantly in generated code and Lexer object) :(
    # The goal of all lexer rules/methods is to create a token object.
    # This is an instance variable as multiple rules may collaborate to
    # create a single token.  nextToken will return this object after
    # matching lexer rule(s).  If you subclass to allow multiple token
    # emissions, then set this to the last token to be matched or
    # something nonnull so that the auto token emit mechanism will not
    # emit another token.
    attr_accessor :token
    alias_method :attr_token, :token
    undef_method :token
    alias_method :attr_token=, :token=
    undef_method :token=
    
    # What character index in the stream did the current token start at?
    # Needed, for example, to get the text for current token.  Set at
    # the start of nextToken.
    attr_accessor :token_start_char_index
    alias_method :attr_token_start_char_index, :token_start_char_index
    undef_method :token_start_char_index
    alias_method :attr_token_start_char_index=, :token_start_char_index=
    undef_method :token_start_char_index=
    
    # The line on which the first character of the token resides
    attr_accessor :token_start_line
    alias_method :attr_token_start_line, :token_start_line
    undef_method :token_start_line
    alias_method :attr_token_start_line=, :token_start_line=
    undef_method :token_start_line=
    
    # The character position of first character within the line
    attr_accessor :token_start_char_position_in_line
    alias_method :attr_token_start_char_position_in_line, :token_start_char_position_in_line
    undef_method :token_start_char_position_in_line
    alias_method :attr_token_start_char_position_in_line=, :token_start_char_position_in_line=
    undef_method :token_start_char_position_in_line=
    
    # The channel number for the current token
    attr_accessor :channel
    alias_method :attr_channel, :channel
    undef_method :channel
    alias_method :attr_channel=, :channel=
    undef_method :channel=
    
    # The token type for the current token
    attr_accessor :type
    alias_method :attr_type, :type
    undef_method :type
    alias_method :attr_type=, :type=
    undef_method :type=
    
    # You can set the text for the current token to override what is in
    # the input char buffer.  Use setText() or can set this instance var.
    attr_accessor :text
    alias_method :attr_text, :text
    undef_method :text
    alias_method :attr_text=, :text=
    undef_method :text=
    
    typesig { [] }
    def initialize
      @following = Array.typed(BitSet).new(BaseRecognizer::INITIAL_FOLLOW_STACK_SIZE) { nil }
      @_fsp = -1
      @error_recovery = false
      @last_error_index = -1
      @failed = false
      @syntax_errors = 0
      @backtracking = 0
      @rule_memo = nil
      @token = nil
      @token_start_char_index = -1
      @token_start_line = 0
      @token_start_char_position_in_line = 0
      @channel = 0
      @type = 0
      @text = nil
    end
    
    private
    alias_method :initialize__recognizer_shared_state, :initialize
  end
  
end
