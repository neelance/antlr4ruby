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
  module BaseRecognizerImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :HashMap
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :Map
    }
  end
  
  # A generic recognizer that can handle recognizers generated from
  # lexer, parser, and tree grammars.  This is all the parsing
  # support code essentially; most of it is error recovery stuff and
  # backtracking.
  class BaseRecognizer 
    include_class_members BaseRecognizerImports
    
    class_module.module_eval {
      const_set_lazy(:MEMO_RULE_FAILED) { -2 }
      const_attr_reader  :MEMO_RULE_FAILED
      
      const_set_lazy(:MEMO_RULE_UNKNOWN) { -1 }
      const_attr_reader  :MEMO_RULE_UNKNOWN
      
      const_set_lazy(:INITIAL_FOLLOW_STACK_SIZE) { 100 }
      const_attr_reader  :INITIAL_FOLLOW_STACK_SIZE
      
      # copies from Token object for convenience in actions
      const_set_lazy(:DEFAULT_TOKEN_CHANNEL) { Token::DEFAULT_CHANNEL }
      const_attr_reader  :DEFAULT_TOKEN_CHANNEL
      
      const_set_lazy(:HIDDEN) { Token::HIDDEN_CHANNEL }
      const_attr_reader  :HIDDEN
      
      const_set_lazy(:NEXT_TOKEN_RULE_NAME) { "nextToken" }
      const_attr_reader  :NEXT_TOKEN_RULE_NAME
    }
    
    # State of a lexer, parser, or tree parser are collected into a state
    # object so the state can be shared.  This sharing is needed to
    # have one grammar import others and share same error variables
    # and other state variables.  It's a kind of explicit multiple
    # inheritance via delegation of methods and shared state.
    attr_accessor :state
    alias_method :attr_state, :state
    undef_method :state
    alias_method :attr_state=, :state=
    undef_method :state=
    
    typesig { [] }
    def initialize
      @state = nil
      @state = RecognizerSharedState.new
    end
    
    typesig { [RecognizerSharedState] }
    def initialize(state)
      @state = nil
      if ((state).nil?)
        state = RecognizerSharedState.new
      end
      @state = state
    end
    
    typesig { [] }
    # reset the parser's state; subclasses must rewinds the input stream
    def reset
      # wack everything related to error recovery
      if ((@state).nil?)
        return # no shared state work to do
      end
      @state.attr__fsp = -1
      @state.attr_error_recovery = false
      @state.attr_last_error_index = -1
      @state.attr_failed = false
      @state.attr_syntax_errors = 0
      # wack everything related to backtracking and memoization
      @state.attr_backtracking = 0
      i = 0
      while !(@state.attr_rule_memo).nil? && i < @state.attr_rule_memo.attr_length
        # wipe cache
        @state.attr_rule_memo[i] = nil
        i += 1
      end
    end
    
    typesig { [IntStream, ::Java::Int, BitSet] }
    # Match current input symbol against ttype.  Attempt
    # single token insertion or deletion error recovery.  If
    # that fails, throw MismatchedTokenException.
    # 
    # To turn off single token insertion or deletion error
    # recovery, override mismatchRecover() and have it call
    # plain mismatch(), which does not recover.  Then any error
    # in a rule will cause an exception and immediate exit from
    # rule.  Rule would recover by resynchronizing to the set of
    # symbols that can follow rule ref.
    def match(input, ttype, follow)
      # System.out.println("match "+((TokenStream)input).LT(1));
      matched_symbol = get_current_input_symbol(input)
      if ((input._la(1)).equal?(ttype))
        input.consume
        @state.attr_error_recovery = false
        @state.attr_failed = false
        return matched_symbol
      end
      if (@state.attr_backtracking > 0)
        @state.attr_failed = true
        return matched_symbol
      end
      matched_symbol = recover_from_mismatched_token(input, ttype, follow)
      return matched_symbol
    end
    
    typesig { [IntStream] }
    # Match the wildcard: in a symbol
    def match_any(input)
      @state.attr_error_recovery = false
      @state.attr_failed = false
      input.consume
    end
    
    typesig { [IntStream, ::Java::Int] }
    def mismatch_is_unwanted_token(input, ttype)
      return (input._la(2)).equal?(ttype)
    end
    
    typesig { [IntStream, BitSet] }
    def mismatch_is_missing_token(input, follow)
      if ((follow).nil?)
        # we have no information about the follow; we can only consume
        # a single token and hope for the best
        return false
      end
      # compute what can follow this grammar element reference
      if (follow.member(Token::EOR_TOKEN_TYPE))
        viable_tokens_following_this_rule = compute_context_sensitive_rule_follow
        follow = follow.or_(viable_tokens_following_this_rule)
        if (@state.attr__fsp >= 0)
          # remove EOR if we're not the start symbol
          follow.remove(Token::EOR_TOKEN_TYPE)
        end
      end
      # if current token is consistent with what could come after set
      # then we know we're missing a token; error recovery is free to
      # "insert" the missing token
      # System.out.println("viable tokens="+follow.toString(getTokenNames()));
      # System.out.println("LT(1)="+((TokenStream)input).LT(1));
      # BitSet cannot handle negative numbers like -1 (EOF) so I leave EOR
      # in follow set to indicate that the fall of the start symbol is
      # in the set (EOF can follow).
      if (follow.member(input._la(1)) || follow.member(Token::EOR_TOKEN_TYPE))
        # System.out.println("LT(1)=="+((TokenStream)input).LT(1)+" is consistent with what follows; inserting...");
        return true
      end
      return false
    end
    
    typesig { [IntStream, ::Java::Int, BitSet] }
    # Factor out what to do upon token mismatch so tree parsers can behave
    # differently.  Override and call mismatchRecover(input, ttype, follow)
    # to get single token insertion and deletion.  Use this to turn of
    # single token insertion and deletion. Override mismatchRecover
    # to call this instead.
    def mismatch(input, ttype, follow)
      if (mismatch_is_unwanted_token(input, ttype))
        raise UnwantedTokenException.new(ttype, input)
      else
        if (mismatch_is_missing_token(input, follow))
          raise MissingTokenException.new(ttype, input, nil)
        end
      end
      raise MismatchedTokenException.new(ttype, input)
    end
    
    typesig { [RecognitionException] }
    # Report a recognition problem.
    # 
    # This method sets errorRecovery to indicate the parser is recovering
    # not parsing.  Once in recovery mode, no errors are generated.
    # To get out of recovery mode, the parser must successfully match
    # a token (after a resync).  So it will go:
    # 
    #        1. error occurs
    #        2. enter recovery mode, report error
    #        3. consume until token found in resynch set
    #        4. try to resume parsing
    #        5. next match() will reset errorRecovery mode
    # 
    # If you override, make sure to update syntaxErrors if you care about that.
    def report_error(e)
      # if we've already reported an error and have not matched a token
      # yet successfully, don't report any errors.
      if (@state.attr_error_recovery)
        # System.err.print("[SPURIOUS] ");
        return
      end
      @state.attr_syntax_errors += 1 # don't count spurious
      @state.attr_error_recovery = true
      display_recognition_error(self.get_token_names, e)
    end
    
    typesig { [Array.typed(String), RecognitionException] }
    def display_recognition_error(token_names, e)
      hdr = get_error_header(e)
      msg = get_error_message(e, token_names)
      emit_error_message(hdr + " " + msg)
    end
    
    typesig { [RecognitionException, Array.typed(String)] }
    # What error message should be generated for the various
    # exception types?
    # 
    # Not very object-oriented code, but I like having all error message
    # generation within one method rather than spread among all of the
    # exception classes. This also makes it much easier for the exception
    # handling because the exception classes do not have to have pointers back
    # to this object to access utility routines and so on. Also, changing
    # the message for an exception type would be difficult because you
    # would have to subclassing exception, but then somehow get ANTLR
    # to make those kinds of exception objects instead of the default.
    # This looks weird, but trust me--it makes the most sense in terms
    # of flexibility.
    # 
    # For grammar debugging, you will want to override this to add
    # more information such as the stack frame with
    # getRuleInvocationStack(e, this.getClass().getName()) and,
    # for no viable alts, the decision description and state etc...
    # 
    # Override this to change the message generated for one or more
    # exception types.
    def get_error_message(e, token_names)
      msg = e.get_message
      if (e.is_a?(UnwantedTokenException))
        ute = e
        token_name = "<unknown>"
        if ((ute.attr_expecting).equal?(Token::EOF))
          token_name = "EOF"
        else
          token_name = RJava.cast_to_string(token_names[ute.attr_expecting])
        end
        msg = "extraneous input " + RJava.cast_to_string(get_token_error_display(ute.get_unexpected_token)) + " expecting " + token_name
      else
        if (e.is_a?(MissingTokenException))
          mte = e
          token_name = "<unknown>"
          if ((mte.attr_expecting).equal?(Token::EOF))
            token_name = "EOF"
          else
            token_name = RJava.cast_to_string(token_names[mte.attr_expecting])
          end
          msg = "missing " + token_name + " at " + RJava.cast_to_string(get_token_error_display(e.attr_token))
        else
          if (e.is_a?(MismatchedTokenException))
            mte = e
            token_name = "<unknown>"
            if ((mte.attr_expecting).equal?(Token::EOF))
              token_name = "EOF"
            else
              token_name = RJava.cast_to_string(token_names[mte.attr_expecting])
            end
            msg = "mismatched input " + RJava.cast_to_string(get_token_error_display(e.attr_token)) + " expecting " + token_name
          else
            if (e.is_a?(MismatchedTreeNodeException))
              mtne = e
              token_name = "<unknown>"
              if ((mtne.attr_expecting).equal?(Token::EOF))
                token_name = "EOF"
              else
                token_name = RJava.cast_to_string(token_names[mtne.attr_expecting])
              end
              msg = "mismatched tree node: " + RJava.cast_to_string(mtne.attr_node) + " expecting " + token_name
            else
              if (e.is_a?(NoViableAltException))
                nvae = e
                # for development, can add "decision=<<"+nvae.grammarDecisionDescription+">>"
                # and "(decision="+nvae.decisionNumber+") and
                # "state "+nvae.stateNumber
                msg = "no viable alternative at input " + RJava.cast_to_string(get_token_error_display(e.attr_token))
              else
                if (e.is_a?(EarlyExitException))
                  eee = e
                  # for development, can add "(decision="+eee.decisionNumber+")"
                  msg = "required (...)+ loop did not match anything at input " + RJava.cast_to_string(get_token_error_display(e.attr_token))
                else
                  if (e.is_a?(MismatchedSetException))
                    mse = e
                    msg = "mismatched input " + RJava.cast_to_string(get_token_error_display(e.attr_token)) + " expecting set " + RJava.cast_to_string(mse.attr_expecting)
                  else
                    if (e.is_a?(MismatchedNotSetException))
                      mse = e
                      msg = "mismatched input " + RJava.cast_to_string(get_token_error_display(e.attr_token)) + " expecting set " + RJava.cast_to_string(mse.attr_expecting)
                    else
                      if (e.is_a?(FailedPredicateException))
                        fpe = e
                        msg = "rule " + RJava.cast_to_string(fpe.attr_rule_name) + " failed predicate: {" + RJava.cast_to_string(fpe.attr_predicate_text) + "}?"
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      return msg
    end
    
    typesig { [] }
    # Get number of recognition errors (lexer, parser, tree parser).  Each
    # recognizer tracks its own number.  So parser and lexer each have
    # separate count.  Does not count the spurious errors found between
    # an error and next valid token match
    # 
    # See also reportError()
    def get_number_of_syntax_errors
      return @state.attr_syntax_errors
    end
    
    typesig { [RecognitionException] }
    # What is the error header, normally line/character position information?
    def get_error_header(e)
      return "line " + RJava.cast_to_string(e.attr_line) + ":" + RJava.cast_to_string(e.attr_char_position_in_line)
    end
    
    typesig { [Token] }
    # How should a token be displayed in an error message? The default
    # is to display just the text, but during development you might
    # want to have a lot of information spit out.  Override in that case
    # to use t.toString() (which, for CommonToken, dumps everything about
    # the token). This is better than forcing you to override a method in
    # your token objects because you don't have to go modify your lexer
    # so that it creates a new Java type.
    def get_token_error_display(t)
      s = t.get_text
      if ((s).nil?)
        if ((t.get_type).equal?(Token::EOF))
          s = "<EOF>"
        else
          s = "<" + RJava.cast_to_string(t.get_type) + ">"
        end
      end
      s = RJava.cast_to_string(s.replace_all("\n", "\\\\n"))
      s = RJava.cast_to_string(s.replace_all("\r", "\\\\r"))
      s = RJava.cast_to_string(s.replace_all("\t", "\\\\t"))
      return "'" + s + "'"
    end
    
    typesig { [String] }
    # Override this method to change where error messages go
    def emit_error_message(msg)
      System.err.println(msg)
    end
    
    typesig { [IntStream, RecognitionException] }
    # Recover from an error found on the input stream.  This is
    # for NoViableAlt and mismatched symbol exceptions.  If you enable
    # single token insertion and deletion, this will usually not
    # handle mismatched symbol exceptions but there could be a mismatched
    # token that the match() routine could not recover from.
    def recover(input, re)
      if ((@state.attr_last_error_index).equal?(input.index))
        # uh oh, another error at same token index; must be a case
        # where LT(1) is in the recovery token set so nothing is
        # consumed; consume a single token so at least to prevent
        # an infinite loop; this is a failsafe.
        input.consume
      end
      @state.attr_last_error_index = input.index
      follow_set = compute_error_recovery_set
      begin_resync
      consume_until(input, follow_set)
      end_resync
    end
    
    typesig { [] }
    # A hook to listen in on the token consumption during error recovery.
    # The DebugParser subclasses this to fire events to the listenter.
    def begin_resync
    end
    
    typesig { [] }
    def end_resync
    end
    
    typesig { [] }
    # Compute the error recovery set for the current rule.  During
    # rule invocation, the parser pushes the set of tokens that can
    # follow that rule reference on the stack; this amounts to
    # computing FIRST of what follows the rule reference in the
    # enclosing rule. This local follow set only includes tokens
    # from within the rule; i.e., the FIRST computation done by
    # ANTLR stops at the end of a rule.
    # 
    # EXAMPLE
    # 
    # When you find a "no viable alt exception", the input is not
    # consistent with any of the alternatives for rule r.  The best
    # thing to do is to consume tokens until you see something that
    # can legally follow a call to r *or* any rule that called r.
    # You don't want the exact set of viable next tokens because the
    # input might just be missing a token--you might consume the
    # rest of the input looking for one of the missing tokens.
    # 
    # Consider grammar:
    # 
    # a : '[' b ']'
    #   | '(' b ')'
    #   ;
    # b : c '^' INT ;
    # c : ID
    #   | INT
    #   ;
    # 
    # At each rule invocation, the set of tokens that could follow
    # that rule is pushed on a stack.  Here are the various "local"
    # follow sets:
    # 
    # FOLLOW(b1_in_a) = FIRST(']') = ']'
    # FOLLOW(b2_in_a) = FIRST(')') = ')'
    # FOLLOW(c_in_b) = FIRST('^') = '^'
    # 
    # Upon erroneous input "[]", the call chain is
    # 
    # a -> b -> c
    # 
    # and, hence, the follow context stack is:
    # 
    # depth  local follow set     after call to rule
    #   0         <EOF>                    a (from main())
    #   1          ']'                     b
    #   3          '^'                     c
    # 
    # Notice that ')' is not included, because b would have to have
    # been called from a different context in rule a for ')' to be
    # included.
    # 
    # For error recovery, we cannot consider FOLLOW(c)
    # (context-sensitive or otherwise).  We need the combined set of
    # all context-sensitive FOLLOW sets--the set of all tokens that
    # could follow any reference in the call chain.  We need to
    # resync to one of those tokens.  Note that FOLLOW(c)='^' and if
    # we resync'd to that token, we'd consume until EOF.  We need to
    # sync to context-sensitive FOLLOWs for a, b, and c: {']','^'}.
    # In this case, for input "[]", LA(1) is in this set so we would
    # not consume anything and after printing an error rule c would
    # return normally.  It would not find the required '^' though.
    # At this point, it gets a mismatched token error and throws an
    # exception (since LA(1) is not in the viable following token
    # set).  The rule exception handler tries to recover, but finds
    # the same recovery set and doesn't consume anything.  Rule b
    # exits normally returning to rule a.  Now it finds the ']' (and
    # with the successful match exits errorRecovery mode).
    # 
    # So, you cna see that the parser walks up call chain looking
    # for the token that was a member of the recovery set.
    # 
    # Errors are not generated in errorRecovery mode.
    # 
    # ANTLR's error recovery mechanism is based upon original ideas:
    # 
    # "Algorithms + Data Structures = Programs" by Niklaus Wirth
    # 
    # and
    # 
    # "A note on error recovery in recursive descent parsers":
    # http://portal.acm.org/citation.cfm?id=947902.947905
    # 
    # Later, Josef Grosch had some good ideas:
    # 
    # "Efficient and Comfortable Error Recovery in Recursive Descent
    # Parsers":
    # ftp://www.cocolab.com/products/cocktail/doca4.ps/ell.ps.zip
    # 
    # Like Grosch I implemented local FOLLOW sets that are combined
    # at run-time upon error to avoid overhead during parsing.
    def compute_error_recovery_set
      return combine_follows(false)
    end
    
    typesig { [] }
    # Compute the context-sensitive FOLLOW set for current rule.
    # This is set of token types that can follow a specific rule
    # reference given a specific call chain.  You get the set of
    # viable tokens that can possibly come next (lookahead depth 1)
    # given the current call chain.  Contrast this with the
    # definition of plain FOLLOW for rule r:
    # 
    #  FOLLOW(r)={x | S=>*alpha r beta in G and x in FIRST(beta)}
    # 
    # where x in T* and alpha, beta in V*; T is set of terminals and
    # V is the set of terminals and nonterminals.  In other words,
    # FOLLOW(r) is the set of all tokens that can possibly follow
    # references to r in *any* sentential form (context).  At
    # runtime, however, we know precisely which context applies as
    # we have the call chain.  We may compute the exact (rather
    # than covering superset) set of following tokens.
    # 
    # For example, consider grammar:
    # 
    # stat : ID '=' expr ';'      // FOLLOW(stat)=={EOF}
    #      | "return" expr '.'
    #      ;
    # expr : atom ('+' atom)* ;   // FOLLOW(expr)=={';','.',')'}
    # atom : INT                  // FOLLOW(atom)=={'+',')',';','.'}
    #      | '(' expr ')'
    #      ;
    # 
    # The FOLLOW sets are all inclusive whereas context-sensitive
    # FOLLOW sets are precisely what could follow a rule reference.
    # For input input "i=(3);", here is the derivation:
    # 
    # stat => ID '=' expr ';'
    #      => ID '=' atom ('+' atom)* ';'
    #      => ID '=' '(' expr ')' ('+' atom)* ';'
    #      => ID '=' '(' atom ')' ('+' atom)* ';'
    #      => ID '=' '(' INT ')' ('+' atom)* ';'
    #      => ID '=' '(' INT ')' ';'
    # 
    # At the "3" token, you'd have a call chain of
    # 
    #   stat -> expr -> atom -> expr -> atom
    # 
    # What can follow that specific nested ref to atom?  Exactly ')'
    # as you can see by looking at the derivation of this specific
    # input.  Contrast this with the FOLLOW(atom)={'+',')',';','.'}.
    # 
    # You want the exact viable token set when recovering from a
    # token mismatch.  Upon token mismatch, if LA(1) is member of
    # the viable next token set, then you know there is most likely
    # a missing token in the input stream.  "Insert" one by just not
    # throwing an exception.
    def compute_context_sensitive_rule_follow
      return combine_follows(true)
    end
    
    typesig { [::Java::Boolean] }
    def combine_follows(exact)
      top = @state.attr__fsp
      follow_set = BitSet.new
      i = top
      while i >= 0
        local_follow_set = @state.attr_following[i]
        # System.out.println("local follow depth "+i+"="+
        #                    localFollowSet.toString(getTokenNames())+")");
        follow_set.or_in_place(local_follow_set)
        if (exact)
          # can we see end of rule?
          if (local_follow_set.member(Token::EOR_TOKEN_TYPE))
            # Only leave EOR in set if at top (start rule); this lets
            # us know if have to include follow(start rule); i.e., EOF
            if (i > 0)
              follow_set.remove(Token::EOR_TOKEN_TYPE)
            end
          else
            # can't see end of rule, quit
            break
          end
        end
        i -= 1
      end
      return follow_set
    end
    
    typesig { [IntStream, ::Java::Int, BitSet] }
    # Attempt to recover from a single missing or extra token.
    # 
    # EXTRA TOKEN
    # 
    # LA(1) is not what we are looking for.  If LA(2) has the right token,
    # however, then assume LA(1) is some extra spurious token.  Delete it
    # and LA(2) as if we were doing a normal match(), which advances the
    # input.
    # 
    # MISSING TOKEN
    # 
    # If current token is consistent with what could come after
    # ttype then it is ok to "insert" the missing token, else throw
    # exception For example, Input "i=(3;" is clearly missing the
    # ')'.  When the parser returns from the nested call to expr, it
    # will have call chain:
    # 
    #   stat -> expr -> atom
    # 
    # and it will be trying to match the ')' at this point in the
    # derivation:
    # 
    #      => ID '=' '(' INT ')' ('+' atom)* ';'
    #                         ^
    # match() will see that ';' doesn't match ')' and report a
    # mismatched token error.  To recover, it sees that LA(1)==';'
    # is in the set of tokens that can follow the ')' token
    # reference in rule atom.  It can assume that you forgot the ')'.
    def recover_from_mismatched_token(input, ttype, follow)
      e = nil
      # if next token is what we are looking for then "delete" this token
      if (mismatch_is_unwanted_token(input, ttype))
        e = UnwantedTokenException.new(ttype, input)
        # System.err.println("recoverFromMismatchedToken deleting "+
        #                    ((TokenStream)input).LT(1)+
        #                    " since "+((TokenStream)input).LT(2)+" is what we want");
        begin_resync
        input.consume # simply delete extra token
        end_resync
        report_error(e) # report after consuming so AW sees the token in the exception
        # we want to return the token we're actually matching
        matched_symbol = get_current_input_symbol(input)
        input.consume # move past ttype token as if all were ok
        return matched_symbol
      end
      # can't recover with single token deletion, try insertion
      if (mismatch_is_missing_token(input, follow))
        inserted = get_missing_symbol(input, e, ttype, follow)
        e = MissingTokenException.new(ttype, input, inserted)
        report_error(e) # report after inserting so AW sees the token in the exception
        return inserted
      end
      # even that didn't work; must throw the exception
      e = MismatchedTokenException.new(ttype, input)
      raise e
    end
    
    typesig { [IntStream, RecognitionException, BitSet] }
    # Not currently used
    def recover_from_mismatched_set(input, e, follow)
      if (mismatch_is_missing_token(input, follow))
        # System.out.println("missing token");
        report_error(e)
        # we don't know how to conjure up a token for sets yet
        return get_missing_symbol(input, e, Token::INVALID_TOKEN_TYPE, follow)
      end
      # TODO do single token deletion like above for Token mismatch
      raise e
    end
    
    typesig { [IntStream] }
    # Match needs to return the current input symbol, which gets put
    # into the label for the associated token ref; e.g., x=ID.  Token
    # and tree parsers need to return different objects. Rather than test
    # for input stream type or change the IntStream interface, I use
    # a simple method to ask the recognizer to tell me what the current
    # input symbol is.
    # 
    # This is ignored for lexers.
    def get_current_input_symbol(input)
      return nil
    end
    
    typesig { [IntStream, RecognitionException, ::Java::Int, BitSet] }
    # Conjure up a missing token during error recovery.
    # 
    # The recognizer attempts to recover from single missing
    # symbols. But, actions might refer to that missing symbol.
    # For example, x=ID {f($x);}. The action clearly assumes
    # that there has been an identifier matched previously and that
    # $x points at that token. If that token is missing, but
    # the next token in the stream is what we want we assume that
    # this token is missing and we keep going. Because we
    # have to return some token to replace the missing token,
    # we have to conjure one up. This method gives the user control
    # over the tokens returned for missing tokens. Mostly,
    # you will want to create something special for identifier
    # tokens. For literals such as '{' and ',', the default
    # action in the parser or tree parser works. It simply creates
    # a CommonToken of the appropriate type. The text will be the token.
    # If you change what tokens must be created by the lexer,
    # override this method to create the appropriate tokens.
    def get_missing_symbol(input, e, expected_token_type, follow)
      return nil
    end
    
    typesig { [IntStream, ::Java::Int] }
    def consume_until(input, token_type)
      # System.out.println("consumeUntil "+tokenType);
      ttype = input._la(1)
      while (!(ttype).equal?(Token::EOF) && !(ttype).equal?(token_type))
        input.consume
        ttype = input._la(1)
      end
    end
    
    typesig { [IntStream, BitSet] }
    # Consume tokens until one matches the given token set
    def consume_until(input, set)
      # System.out.println("consumeUntil("+set.toString(getTokenNames())+")");
      ttype = input._la(1)
      while (!(ttype).equal?(Token::EOF) && !set.member(ttype))
        # System.out.println("consume during recover LA(1)="+getTokenNames()[input.LA(1)]);
        input.consume
        ttype = input._la(1)
      end
    end
    
    typesig { [BitSet] }
    # Push a rule's follow set using our own hardcoded stack
    def push_follow(fset)
      if ((@state.attr__fsp + 1) >= @state.attr_following.attr_length)
        f = Array.typed(BitSet).new(@state.attr_following.attr_length * 2) { nil }
        System.arraycopy(@state.attr_following, 0, f, 0, @state.attr_following.attr_length)
        @state.attr_following = f
      end
      @state.attr_following[(@state.attr__fsp += 1)] = fset
    end
    
    typesig { [] }
    # Return List<String> of the rules in your parser instance
    # leading up to a call to this method.  You could override if
    # you want more details such as the file/line info of where
    # in the parser java code a rule is invoked.
    # 
    # This is very useful for error messages and for context-sensitive
    # error recovery.
    def get_rule_invocation_stack
      parser_class_name = get_class.get_name
      return get_rule_invocation_stack(JavaThrowable.new, parser_class_name)
    end
    
    class_module.module_eval {
      typesig { [JavaThrowable, String] }
      # A more general version of getRuleInvocationStack where you can
      # pass in, for example, a RecognitionException to get it's rule
      # stack trace.  This routine is shared with all recognizers, hence,
      # static.
      # 
      # TODO: move to a utility class or something; weird having lexer call this
      def get_rule_invocation_stack(e, recognizer_class_name)
        rules = ArrayList.new
        stack = e.get_stack_trace
        i = 0
        i = stack.attr_length - 1
        while i >= 0
          t = stack[i]
          if (t.get_class_name.starts_with("org.antlr.runtime."))
            i -= 1
            next # skip support code such as this method
          end
          if ((t.get_method_name == NEXT_TOKEN_RULE_NAME))
            i -= 1
            next
          end
          if (!(t.get_class_name == recognizer_class_name))
            i -= 1
            next # must not be part of this parser
          end
          rules.add(t.get_method_name)
          i -= 1
        end
        return rules
      end
    }
    
    typesig { [] }
    def get_backtracking_level
      return @state.attr_backtracking
    end
    
    typesig { [] }
    # Used to print out token names like ID during debugging and
    # error reporting.  The generated parsers implement a method
    # that overrides this to point to their String[] tokenNames.
    def get_token_names
      return nil
    end
    
    typesig { [] }
    # For debugging and other purposes, might want the grammar name.
    # Have ANTLR generate an implementation for this method.
    def get_grammar_file_name
      return nil
    end
    
    typesig { [] }
    def get_source_name
      raise NotImplementedError
    end
    
    typesig { [JavaList] }
    # A convenience method for use most often with template rewrites.
    # Convert a List<Token> to List<String>
    def to_strings(tokens)
      if ((tokens).nil?)
        return nil
      end
      strings = ArrayList.new(tokens.size)
      i = 0
      while i < tokens.size
        strings.add((tokens.get(i)).get_text)
        i += 1
      end
      return strings
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # Given a rule number and a start token index number, return
    # MEMO_RULE_UNKNOWN if the rule has not parsed input starting from
    # start index.  If this rule has parsed input starting from the
    # start index before, then return where the rule stopped parsing.
    # It returns the index of the last token matched by the rule.
    # 
    # For now we use a hashtable and just the slow Object-based one.
    # Later, we can make a special one for ints and also one that
    # tosses out data after we commit past input position i.
    def get_rule_memoization(rule_index, rule_start_index)
      if ((@state.attr_rule_memo[rule_index]).nil?)
        @state.attr_rule_memo[rule_index] = HashMap.new
      end
      stop_index_i = @state.attr_rule_memo[rule_index].get(rule_start_index)
      if ((stop_index_i).nil?)
        return MEMO_RULE_UNKNOWN
      end
      return stop_index_i.int_value
    end
    
    typesig { [IntStream, ::Java::Int] }
    # Has this rule already parsed input at the current index in the
    # input stream?  Return the stop token index or MEMO_RULE_UNKNOWN.
    # If we attempted but failed to parse properly before, return
    # MEMO_RULE_FAILED.
    # 
    # This method has a side-effect: if we have seen this input for
    # this rule and successfully parsed before, then seek ahead to
    # 1 past the stop token matched for this rule last time.
    def already_parsed_rule(input, rule_index)
      stop_index = get_rule_memoization(rule_index, input.index)
      if ((stop_index).equal?(MEMO_RULE_UNKNOWN))
        return false
      end
      if ((stop_index).equal?(MEMO_RULE_FAILED))
        # System.out.println("rule "+ruleIndex+" will never succeed");
        @state.attr_failed = true
      else
        # System.out.println("seen rule "+ruleIndex+" before; skipping ahead to @"+(stopIndex+1)+" failed="+state.failed);
        input.seek(stop_index + 1) # jump to one past stop token
      end
      return true
    end
    
    typesig { [IntStream, ::Java::Int, ::Java::Int] }
    # Record whether or not this rule parsed the input at this position
    # successfully.  Use a standard java hashtable for now.
    def memoize(input, rule_index, rule_start_index)
      stop_token_index = @state.attr_failed ? MEMO_RULE_FAILED : input.index - 1
      if ((@state.attr_rule_memo).nil?)
        System.err.println("!!!!!!!!! memo array is null for " + RJava.cast_to_string(get_grammar_file_name))
      end
      if (rule_index >= @state.attr_rule_memo.attr_length)
        System.err.println("!!!!!!!!! memo size is " + RJava.cast_to_string(@state.attr_rule_memo.attr_length) + ", but rule index is " + RJava.cast_to_string(rule_index))
      end
      if (!(@state.attr_rule_memo[rule_index]).nil?)
        @state.attr_rule_memo[rule_index].put(rule_start_index, stop_token_index)
      end
    end
    
    typesig { [] }
    # return how many rule/input-index pairs there are in total.
    # TODO: this includes synpreds. :(
    def get_rule_memoization_cache_size
      n = 0
      i = 0
      while !(@state.attr_rule_memo).nil? && i < @state.attr_rule_memo.attr_length
        rule_map = @state.attr_rule_memo[i]
        if (!(rule_map).nil?)
          n += rule_map.size # how many input indexes are recorded?
        end
        i += 1
      end
      return n
    end
    
    typesig { [String, ::Java::Int, Object] }
    def trace_in(rule_name, rule_index, input_symbol)
      System.out.print("enter " + rule_name + " " + RJava.cast_to_string(input_symbol))
      if (@state.attr_failed)
        System.out.println(" failed=" + RJava.cast_to_string(@state.attr_failed))
      end
      if (@state.attr_backtracking > 0)
        System.out.print(" backtracking=" + RJava.cast_to_string(@state.attr_backtracking))
      end
      System.out.println
    end
    
    typesig { [String, ::Java::Int, Object] }
    def trace_out(rule_name, rule_index, input_symbol)
      System.out.print("exit " + rule_name + " " + RJava.cast_to_string(input_symbol))
      if (@state.attr_failed)
        System.out.println(" failed=" + RJava.cast_to_string(@state.attr_failed))
      end
      if (@state.attr_backtracking > 0)
        System.out.print(" backtracking=" + RJava.cast_to_string(@state.attr_backtracking))
      end
      System.out.println
    end
    
    private
    alias_method :initialize__base_recognizer, :initialize
  end
  
end
