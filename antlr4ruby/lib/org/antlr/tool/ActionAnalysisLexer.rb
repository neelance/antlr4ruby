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
# $ANTLR 3.1b1 ActionAnalysis.g 2007-12-11 15:11:24
module Org::Antlr::Tool
  module ActionAnalysisLexerImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Org::Antlr::Runtime
      include_const ::Java::Util, :HashMap
    }
  end
  
  # We need to set Rule.referencedPredefinedRuleAttributes before
  # code generation.  This filter looks at an action in context of
  # its rule and outer alternative number and figures out which
  # rules have predefined prefs referenced.  I need this so I can
  # remove unusued labels.  This also tracks, for labeled rules,
  # which are referenced by actions.
  class ActionAnalysisLexer < ActionAnalysisLexerImports.const_get :Lexer
    include_class_members ActionAnalysisLexerImports
    
    class_module.module_eval {
      const_set_lazy(:X_Y) { 5 }
      const_attr_reader  :X_Y
      
      const_set_lazy(:EOF) { -1 }
      const_attr_reader  :EOF
      
      const_set_lazy(:Tokens) { 8 }
      const_attr_reader  :Tokens
      
      const_set_lazy(:Y) { 7 }
      const_attr_reader  :Y
      
      const_set_lazy(:ID) { 4 }
      const_attr_reader  :ID
      
      const_set_lazy(:X) { 6 }
      const_attr_reader  :X
    }
    
    attr_accessor :enclosing_rule
    alias_method :attr_enclosing_rule, :enclosing_rule
    undef_method :enclosing_rule
    alias_method :attr_enclosing_rule=, :enclosing_rule=
    undef_method :enclosing_rule=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :action_token
    alias_method :attr_action_token, :action_token
    undef_method :action_token
    alias_method :attr_action_token=, :action_token=
    undef_method :action_token=
    
    attr_accessor :outer_alt_num
    alias_method :attr_outer_alt_num, :outer_alt_num
    undef_method :outer_alt_num
    alias_method :attr_outer_alt_num=, :outer_alt_num=
    undef_method :outer_alt_num=
    
    typesig { [Grammar, String, GrammarAST] }
    def initialize(grammar, rule_name, action_ast)
      initialize__action_analysis_lexer(ANTLRStringStream.new(action_ast.attr_token.get_text))
      @grammar = grammar
      @enclosing_rule = grammar.get_locally_defined_rule(rule_name)
      @action_token = action_ast.attr_token
      @outer_alt_num = action_ast.attr_outer_alt_num
    end
    
    typesig { [] }
    def analyze
      # System.out.println("###\naction="+actionToken);
      t = nil
      begin
        t = next_token
      end while (!(t.get_type).equal?(Token::EOF))
    end
    
    typesig { [] }
    # delegates
    # delegators
    def initialize
      @enclosing_rule = nil
      @grammar = nil
      @action_token = nil
      @outer_alt_num = 0
      super()
      @outer_alt_num = 0
    end
    
    typesig { [CharStream] }
    def initialize(input)
      initialize__action_analysis_lexer(input, RecognizerSharedState.new)
    end
    
    typesig { [CharStream, RecognizerSharedState] }
    def initialize(input, state)
      @enclosing_rule = nil
      @grammar = nil
      @action_token = nil
      @outer_alt_num = 0
      super(input, state)
      @outer_alt_num = 0
      self.attr_state.attr_rule_memo = Array.typed(HashMap).new(7 + 1) { nil }
    end
    
    typesig { [] }
    def get_grammar_file_name
      return "ActionAnalysis.g"
    end
    
    typesig { [] }
    def next_token
      while (true)
        if ((self.attr_input._la(1)).equal?(CharStream::EOF))
          return Token::EOF_TOKEN
        end
        self.attr_state.attr_token = nil
        self.attr_state.attr_channel = Token::DEFAULT_CHANNEL
        self.attr_state.attr_token_start_char_index = self.attr_input.index
        self.attr_state.attr_token_start_char_position_in_line = self.attr_input.get_char_position_in_line
        self.attr_state.attr_token_start_line = self.attr_input.get_line
        self.attr_state.attr_text = nil
        begin
          m = self.attr_input.mark
          self.attr_state.attr_backtracking = 1
          self.attr_state.attr_failed = false
          m_tokens
          self.attr_state.attr_backtracking = 0
          if (self.attr_state.attr_failed)
            self.attr_input.rewind(m)
            self.attr_input.consume
          else
            emit
            return self.attr_state.attr_token
          end
        rescue RecognitionException => re
          # shouldn't happen in backtracking mode, but...
          report_error(re)
          recover(re)
        end
      end
    end
    
    typesig { [IntStream, ::Java::Int, ::Java::Int] }
    def memoize(input, rule_index, rule_start_index)
      if (self.attr_state.attr_backtracking > 1)
        super(input, rule_index, rule_start_index)
      end
    end
    
    typesig { [IntStream, ::Java::Int] }
    def already_parsed_rule(input, rule_index)
      if (self.attr_state.attr_backtracking > 1)
        return super(input, rule_index)
      end
      return false
    end
    
    typesig { [] }
    # $ANTLR start X_Y
    def m_x_y
      begin
        _type = X_Y
        x = nil
        y = nil
        # ActionAnalysis.g:74:5: ( '$' x= ID '.' y= ID {...}?)
        # ActionAnalysis.g:74:7: '$' x= ID '.' y= ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start48 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start48, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start54 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start54, get_char_index - 1)
        if (!(!(@enclosing_rule).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "X_Y", "enclosingRule!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          scope = nil
          refd_rule_name = nil
          if (((!(x).nil? ? x.get_text : nil) == @enclosing_rule.attr_name))
            # ref to enclosing rule.
            refd_rule_name = RJava.cast_to_string((!(x).nil? ? x.get_text : nil))
            scope = @enclosing_rule.get_local_attribute_scope((!(y).nil? ? y.get_text : nil))
          else
            if (!(@enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))).nil?)
              # ref to rule label
              pair = @enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))
              pair.attr_action_references_label = true
              refd_rule_name = RJava.cast_to_string(pair.attr_referenced_rule_name)
              refd_rule = @grammar.get_rule(refd_rule_name)
              if (!(refd_rule).nil?)
                scope = refd_rule.get_local_attribute_scope((!(y).nil? ? y.get_text : nil))
              end
            else
              if (!(@enclosing_rule.get_rule_refs_in_alt(x.get_text, @outer_alt_num)).nil?)
                # ref to rule referenced in this alt
                refd_rule_name = RJava.cast_to_string((!(x).nil? ? x.get_text : nil))
                refd_rule = @grammar.get_rule(refd_rule_name)
                if (!(refd_rule).nil?)
                  scope = refd_rule.get_local_attribute_scope((!(y).nil? ? y.get_text : nil))
                end
              end
            end
          end
          if (!(scope).nil? && (scope.attr_is_predefined_rule_scope || scope.attr_is_predefined_lexer_rule_scope))
            @grammar.reference_rule_label_predefined_attribute(refd_rule_name)
            # System.out.println("referenceRuleLabelPredefinedAttribute for "+refdRuleName);
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end X_Y
    # $ANTLR start X
    def m_x
      begin
        _type = X
        x = nil
        # ActionAnalysis.g:111:3: ( '$' x= ID {...}?)
        # ActionAnalysis.g:111:5: '$' x= ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start76 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start76, get_char_index - 1)
        if (!(!(@enclosing_rule).nil? && !(@enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "X", "enclosingRule!=null && enclosingRule.getRuleLabel($x.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          pair = @enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))
          pair.attr_action_references_label = true
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end X
    # $ANTLR start Y
    def m_y
      begin
        _type = Y
        id1 = nil
        # ActionAnalysis.g:119:3: ( '$' ID {...}?)
        # ActionAnalysis.g:119:5: '$' ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        id1start97 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        id1 = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, id1start97, get_char_index - 1)
        if (!(!(@enclosing_rule).nil? && !(@enclosing_rule.get_local_attribute_scope((!(id1).nil? ? id1.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "Y", "enclosingRule!=null && enclosingRule.getLocalAttributeScope($ID.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          scope = @enclosing_rule.get_local_attribute_scope((!(id1).nil? ? id1.get_text : nil))
          if (!(scope).nil? && (scope.attr_is_predefined_rule_scope || scope.attr_is_predefined_lexer_rule_scope))
            @grammar.reference_rule_label_predefined_attribute(@enclosing_rule.attr_name)
            # System.out.println("referenceRuleLabelPredefinedAttribute for "+(ID1!=null?ID1.getText():null));
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end Y
    # $ANTLR start ID
    def m_id
      begin
        # ActionAnalysis.g:132:5: ( ( 'a' .. 'z' | 'A' .. 'Z' | '_' ) ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )* )
        # ActionAnalysis.g:132:9: ( 'a' .. 'z' | 'A' .. 'Z' | '_' ) ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )*
        if ((self.attr_input._la(1) >= Character.new(?A.ord) && self.attr_input._la(1) <= Character.new(?Z.ord)) || (self.attr_input._la(1)).equal?(Character.new(?_.ord)) || (self.attr_input._la(1) >= Character.new(?a.ord) && self.attr_input._la(1) <= Character.new(?z.ord)))
          self.attr_input.consume
          self.attr_state.attr_failed = false
        else
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          mse = MismatchedSetException.new(nil, self.attr_input)
          recover(mse)
          raise mse
        end
        # ActionAnalysis.g:132:33: ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )*
        begin
          alt1 = 2
          la1_0 = self.attr_input._la(1)
          if (((la1_0 >= Character.new(?0.ord) && la1_0 <= Character.new(?9.ord)) || (la1_0 >= Character.new(?A.ord) && la1_0 <= Character.new(?Z.ord)) || (la1_0).equal?(Character.new(?_.ord)) || (la1_0 >= Character.new(?a.ord) && la1_0 <= Character.new(?z.ord))))
            alt1 = 1
          end
          case (alt1)
          when 1
            # ActionAnalysis.g:
            if ((self.attr_input._la(1) >= Character.new(?0.ord) && self.attr_input._la(1) <= Character.new(?9.ord)) || (self.attr_input._la(1) >= Character.new(?A.ord) && self.attr_input._la(1) <= Character.new(?Z.ord)) || (self.attr_input._la(1)).equal?(Character.new(?_.ord)) || (self.attr_input._la(1) >= Character.new(?a.ord) && self.attr_input._la(1) <= Character.new(?z.ord)))
              self.attr_input.consume
              self.attr_state.attr_failed = false
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              mse = MismatchedSetException.new(nil, self.attr_input)
              recover(mse)
              raise mse
            end
          else
            break
          end
        end while (true)
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ID
    def m_tokens
      # ActionAnalysis.g:1:39: ( X_Y | X | Y )
      alt2 = 3
      la2_0 = self.attr_input._la(1)
      if (((la2_0).equal?(Character.new(?$.ord))))
        la2_1 = self.attr_input._la(2)
        if ((synpred1))
          alt2 = 1
        else
          if ((synpred2))
            alt2 = 2
          else
            if ((true))
              alt2 = 3
            else
              if (self.attr_state.attr_backtracking > 0)
                self.attr_state.attr_failed = true
                return
              end
              nvae = NoViableAltException.new("1:1: Tokens options {k=1; backtrack=true; } : ( X_Y | X | Y );", 2, 1, self.attr_input)
              raise nvae
            end
          end
        end
      else
        if (self.attr_state.attr_backtracking > 0)
          self.attr_state.attr_failed = true
          return
        end
        nvae = NoViableAltException.new("1:1: Tokens options {k=1; backtrack=true; } : ( X_Y | X | Y );", 2, 0, self.attr_input)
        raise nvae
      end
      case (alt2)
      when 1
        # ActionAnalysis.g:1:41: X_Y
        m_x_y
        if (self.attr_state.attr_failed)
          return
        end
      when 2
        # ActionAnalysis.g:1:45: X
        m_x
        if (self.attr_state.attr_failed)
          return
        end
      when 3
        # ActionAnalysis.g:1:47: Y
        m_y
        if (self.attr_state.attr_failed)
          return
        end
      end
    end
    
    typesig { [] }
    # $ANTLR start synpred1
    def synpred1_fragment
      # ActionAnalysis.g:1:41: ( X_Y )
      # ActionAnalysis.g:1:41: X_Y
      m_x_y
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred1
    # $ANTLR start synpred2
    def synpred2_fragment
      # ActionAnalysis.g:1:45: ( X )
      # ActionAnalysis.g:1:45: X
      m_x
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred2
    def synpred2
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred2_fragment # can never throw exception
      rescue RecognitionException => re
        System.err.println("impossible: " + RJava.cast_to_string(re))
      end
      success = !self.attr_state.attr_failed
      self.attr_input.rewind(start)
      self.attr_state.attr_backtracking -= 1
      self.attr_state.attr_failed = false
      return success
    end
    
    typesig { [] }
    def synpred1
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred1_fragment # can never throw exception
      rescue RecognitionException => re
        System.err.println("impossible: " + RJava.cast_to_string(re))
      end
      success = !self.attr_state.attr_failed
      self.attr_input.rewind(start)
      self.attr_state.attr_backtracking -= 1
      self.attr_state.attr_failed = false
      return success
    end
    
    private
    alias_method :initialize__action_analysis_lexer, :initialize
  end
  
end
