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
module Org::Antlr::Tool
  module InterpreterImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Analysis, :DFA
      include ::Org::Antlr::Analysis
      include ::Org::Antlr::Runtime
      include_const ::Org::Antlr::Runtime::Debug, :DebugEventListener
      include_const ::Org::Antlr::Runtime::Debug, :BlankDebugEventListener
      include_const ::Org::Antlr::Runtime::Tree, :ParseTree
      include_const ::Org::Antlr::Runtime::Debug, :ParseTreeBuilder
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :Stack
    }
  end
  
  # The recognition interpreter/engine for grammars.  Separated
  # out of Grammar as it's related, but technically not a Grammar function.
  # You create an interpreter for a grammar and an input stream.  This object
  # can act as a TokenSource so that you can hook up two grammars (via
  # a CommonTokenStream) to lex/parse.  Being a token source only makes sense
  # for a lexer grammar of course.
  class Interpreter 
    include_class_members InterpreterImports
    include TokenSource
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    class_module.module_eval {
      # A lexer listener that just creates token objects as they
      # are matched.  scan() use this listener to get a single object.
      # To get a stream of tokens, you must call scan() multiple times,
      # recording the token object result after each call.
      const_set_lazy(:LexerActionGetTokenType) { Class.new(BlankDebugEventListener) do
        local_class_in Interpreter
        include_class_members Interpreter
        
        attr_accessor :token
        alias_method :attr_token, :token
        undef_method :token
        alias_method :attr_token=, :token=
        undef_method :token=
        
        attr_accessor :g
        alias_method :attr_g, :g
        undef_method :g
        alias_method :attr_g=, :g=
        undef_method :g=
        
        typesig { [class_self::Grammar] }
        def initialize(g)
          @token = nil
          @g = nil
          super()
          @g = g
        end
        
        typesig { [String, String] }
        def exit_rule(grammar_file_name, rule_name)
          if (!(rule_name == Grammar::ARTIFICIAL_TOKENS_RULENAME))
            type = @g.get_token_type(rule_name)
            channel = Token::DEFAULT_CHANNEL
            @token = self.class::CommonToken.new(self.attr_input, type, channel, 0, 0)
          end
        end
        
        private
        alias_method :initialize__lexer_action_get_token_type, :initialize
      end }
    }
    
    typesig { [Grammar, IntStream] }
    def initialize(grammar, input)
      @grammar = nil
      @input = nil
      @grammar = grammar
      @input = input
    end
    
    typesig { [] }
    def next_token
      if (!(@grammar.attr_type).equal?(Grammar::LEXER))
        return nil
      end
      if ((@input._la(1)).equal?(CharStream::EOF))
        return Token::EOF_TOKEN
      end
      start = @input.index
      char_pos = (@input).get_char_position_in_line
      token = nil
      while (!(@input._la(1)).equal?(CharStream::EOF))
        begin
          token = scan(Grammar::ARTIFICIAL_TOKENS_RULENAME, nil)
          break
        rescue RecognitionException => re
          # report a problem and try for another
          report_scan_error(re)
          next
        end
      end
      # the scan can only set type
      # we must set the line, and other junk here to make it a complete token
      stop = @input.index - 1
      if ((token).nil?)
        return Token::EOF_TOKEN
      end
      token.set_line((@input).get_line)
      token.set_start_index(start)
      token.set_stop_index(stop)
      token.set_char_position_in_line(char_pos)
      return token
    end
    
    typesig { [String, DebugEventListener, JavaList] }
    # For a given input char stream, try to match against the NFA
    # starting at startRule.  This is a deterministic parse even though
    # it is using an NFA because it uses DFAs at each decision point to
    # predict which alternative will succeed.  This is exactly what the
    # generated parser will do.
    # 
    # This only does lexer grammars.
    # 
    # Return the token type associated with the final rule end state.
    def scan(start_rule, actions, visited_states)
      if (!(@grammar.attr_type).equal?(Grammar::LEXER))
        return
      end
      in_ = @input
      # System.out.println("scan("+startRule+",'"+in.substring(in.index(),in.size()-1)+"')");
      # Build NFAs/DFAs from the grammar AST if NFAs haven't been built yet
      if ((@grammar.get_rule_start_state(start_rule)).nil?)
        @grammar.build_nfa
      end
      if (!@grammar.all_decision_dfahave_been_created)
        # Create the DFA predictors for each decision
        @grammar.create_lookahead_dfas
      end
      # do the parse
      rule_invocation_stack = Stack.new
      start = @grammar.get_rule_start_state(start_rule)
      stop = @grammar.get_rule_stop_state(start_rule)
      parse_engine(start_rule, start, stop, in_, rule_invocation_stack, actions, visited_states)
    end
    
    typesig { [String] }
    def scan(start_rule)
      return scan(start_rule, nil)
    end
    
    typesig { [String, JavaList] }
    def scan(start_rule, visited_states)
      actions = LexerActionGetTokenType.new_local(self, @grammar)
      scan(start_rule, actions, visited_states)
      return actions.attr_token
    end
    
    typesig { [String, DebugEventListener, JavaList] }
    def parse(start_rule, actions, visited_states)
      # System.out.println("parse("+startRule+")");
      # Build NFAs/DFAs from the grammar AST if NFAs haven't been built yet
      if ((@grammar.get_rule_start_state(start_rule)).nil?)
        @grammar.build_nfa
      end
      if (!@grammar.all_decision_dfahave_been_created)
        # Create the DFA predictors for each decision
        @grammar.create_lookahead_dfas
      end
      # do the parse
      rule_invocation_stack = Stack.new
      start = @grammar.get_rule_start_state(start_rule)
      stop = @grammar.get_rule_stop_state(start_rule)
      parse_engine(start_rule, start, stop, @input, rule_invocation_stack, actions, visited_states)
    end
    
    typesig { [String] }
    def parse(start_rule)
      return parse(start_rule, nil)
    end
    
    typesig { [String, JavaList] }
    def parse(start_rule, visited_states)
      actions = ParseTreeBuilder.new(@grammar.attr_name)
      begin
        parse(start_rule, actions, visited_states)
      rescue RecognitionException => re
        # Errors are tracked via the ANTLRDebugInterface
        # Exceptions are used just to blast out of the parse engine
        # The error will be in the parse tree.
      end
      return actions.get_tree
    end
    
    typesig { [String, NFAState, NFAState, IntStream, Stack, DebugEventListener, JavaList] }
    # Fill a list of all NFA states visited during the parse
    def parse_engine(start_rule, start, stop, input, rule_invocation_stack, actions, visited_states)
      s = start
      if (!(actions).nil?)
        actions.enter_rule(s.attr_nfa.attr_grammar.get_file_name, start.attr_enclosing_rule.attr_name)
      end
      t = input._la(1)
      while (!(s).equal?(stop))
        if (!(visited_states).nil?)
          visited_states.add(s)
        end
        # System.out.println("parse state "+s.stateNumber+" input="+
        # s.nfa.grammar.getTokenDisplayName(t));
        # 
        # CASE 1: decision state
        if (s.get_decision_number > 0 && s.attr_nfa.attr_grammar.get_number_of_alts_for_decision_nfa(s) > 1)
          # decision point, must predict and jump to alt
          dfa = s.attr_nfa.attr_grammar.get_lookahead_dfa(s.get_decision_number)
          # if ( s.nfa.grammar.type!=Grammar.LEXER ) {
          # System.out.println("decision: "+
          # dfa.getNFADecisionStartState().getDescription()+
          # " input="+s.nfa.grammar.getTokenDisplayName(t));
          # }
          m = input.mark
          predicted_alt = predict(dfa)
          if ((predicted_alt).equal?(NFA::INVALID_ALT_NUMBER))
            description = dfa.get_nfadecision_start_state.get_description
            nvae = NoViableAltException.new(description, dfa.get_decision_number, s.attr_state_number, input)
            if (!(actions).nil?)
              actions.recognition_exception(nvae)
            end
            input.consume # recover
            raise nvae
          end
          input.rewind(m)
          parse_alt = s.translate_display_alt_to_walk_alt(predicted_alt)
          # if ( s.nfa.grammar.type!=Grammar.LEXER ) {
          # System.out.println("predicted alt "+predictedAlt+", parseAlt "+
          # parseAlt);
          # }
          alt = nil
          if (parse_alt > s.attr_nfa.attr_grammar.get_number_of_alts_for_decision_nfa(s))
            # implied branch of loop etc...
            alt = s.attr_nfa.attr_grammar.attr_nfa.get_state(s.attr_end_of_block_state_number)
          else
            alt = s.attr_nfa.attr_grammar.get_nfastate_for_alt_of_decision(s, parse_alt)
          end
          s = alt.attr_transition[0].attr_target
          next
        end
        # CASE 2: finished matching a rule
        if (s.is_accept_state)
          # end of rule node
          if (!(actions).nil?)
            actions.exit_rule(s.attr_nfa.attr_grammar.get_file_name, s.attr_enclosing_rule.attr_name)
          end
          if (rule_invocation_stack.empty)
            # done parsing.  Hit the start state.
            # System.out.println("stack empty in stop state for "+s.getEnclosingRule());
            break
          end
          # pop invoking state off the stack to know where to return to
          invoking_state = rule_invocation_stack.pop
          invoking_transition = invoking_state.attr_transition[0]
          # move to node after state that invoked this rule
          s = invoking_transition.attr_follow_state
          next
        end
        trans = s.attr_transition[0]
        label = trans.attr_label
        if (label.is_semantic_predicate)
          fpe = FailedPredicateException.new(input, s.attr_enclosing_rule.attr_name, "can't deal with predicates yet")
          if (!(actions).nil?)
            actions.recognition_exception(fpe)
          end
        end
        # CASE 3: epsilon transition
        if (label.is_epsilon)
          # CASE 3a: rule invocation state
          if (trans.is_a?(RuleClosureTransition))
            rule_invocation_stack.push(s)
            s = trans.attr_target
            # System.out.println("call "+s.enclosingRule.name+" from "+s.nfa.grammar.getFileName());
            if (!(actions).nil?)
              actions.enter_rule(s.attr_nfa.attr_grammar.get_file_name, s.attr_enclosing_rule.attr_name)
            end
            # could be jumping to new grammar, make sure DFA created
            if (!s.attr_nfa.attr_grammar.all_decision_dfahave_been_created)
              s.attr_nfa.attr_grammar.create_lookahead_dfas
            end
          # CASE 3b: plain old epsilon transition, just move
          else
            s = trans.attr_target
          end
        # CASE 4: match label on transition
        else
          if (label.matches(t))
            if (!(actions).nil?)
              if ((s.attr_nfa.attr_grammar.attr_type).equal?(Grammar::PARSER) || (s.attr_nfa.attr_grammar.attr_type).equal?(Grammar::COMBINED))
                actions.consume_token((input)._lt(1))
              end
            end
            s = s.attr_transition[0].attr_target
            input.consume
            t = input._la(1)
          # CASE 5: error condition; label is inconsistent with input
          else
            if (label.is_atom)
              mte = MismatchedTokenException.new(label.get_atom, input)
              if (!(actions).nil?)
                actions.recognition_exception(mte)
              end
              input.consume # recover
              raise mte
            else
              if (label.is_set)
                mse = MismatchedSetException.new((label.get_set).to_runtime_bit_set, input)
                if (!(actions).nil?)
                  actions.recognition_exception(mse)
                end
                input.consume # recover
                raise mse
              else
                if (label.is_semantic_predicate)
                  fpe = FailedPredicateException.new(input, s.attr_enclosing_rule.attr_name, label.get_semantic_context.to_s)
                  if (!(actions).nil?)
                    actions.recognition_exception(fpe)
                  end
                  input.consume # recover
                  raise fpe
                else
                  raise RecognitionException.new(input) # unknown error
                end
              end
            end
          end
        end
      end
      # System.out.println("hit stop state for "+stop.getEnclosingRule());
      if (!(actions).nil?)
        actions.exit_rule(s.attr_nfa.attr_grammar.get_file_name, stop.attr_enclosing_rule.attr_name)
      end
    end
    
    typesig { [DFA] }
    # Given an input stream, return the unique alternative predicted by
    # matching the input.  Upon error, return NFA.INVALID_ALT_NUMBER
    # The first symbol of lookahead is presumed to be primed; that is,
    # input.lookahead(1) must point at the input symbol you want to start
    # predicting with.
    def predict(dfa)
      s = dfa.attr_start_state
      c = @input._la(1)
      eot_transition = nil
      while (!s.is_accept_state)
        catch(:next_dfa_loop) do
          # System.out.println("DFA.predict("+s.getStateNumber()+", "+
          # dfa.getNFA().getGrammar().getTokenName(c)+")");
          # 
          # for each edge of s, look for intersection with current char
          i = 0
          while i < s.get_number_of_transitions
            t = s.transition(i)
            # special case: EOT matches any char
            if (t.attr_label.matches(c))
              # take transition i
              s = t.attr_target
              @input.consume
              c = @input._la(1)
              throw :next_dfa_loop, :thrown
            end
            if ((t.attr_label.get_atom).equal?(Label::EOT))
              eot_transition = t
            end
            i += 1
          end
          if (!(eot_transition).nil?)
            s = eot_transition.attr_target
            next
          end
          # ErrorManager.error(ErrorManager.MSG_NO_VIABLE_DFA_ALT,
          # s,
          # dfa.nfa.grammar.getTokenName(c));
          return NFA::INVALID_ALT_NUMBER
        end
      end
      # woohoo!  We know which alt to predict
      # nothing emanates from a stop state; must terminate anyway
      # 
      # System.out.println("DFA stop state "+s.getStateNumber()+" predicts "+
      # s.getUniquelyPredictedAlt());
      return s.get_uniquely_predicted_alt
    end
    
    typesig { [RecognitionException] }
    def report_scan_error(re)
      cs = @input
      # print as good of a message as we can, given that we do not have
      # a Lexer object and, hence, cannot call the routine to get a
      # decent error message.
      System.err.println("problem matching token at " + RJava.cast_to_string(cs.get_line) + ":" + RJava.cast_to_string(cs.get_char_position_in_line) + " " + RJava.cast_to_string(re))
    end
    
    typesig { [] }
    def get_source_name
      return @input.get_source_name
    end
    
    private
    alias_method :initialize__interpreter, :initialize
  end
  
end
