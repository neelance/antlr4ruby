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
# 
# $ANTLR 3.1b1 ActionTranslator.g 2008-05-01 15:02:49
module Org::Antlr::Codegen
  module ActionTranslatorImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include ::Org::Antlr::Runtime
      include ::Org::Antlr::Tool
      include ::Org::Antlr::Runtime
      include_const ::Java::Util, :Stack
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :Map
      include_const ::Java::Util, :HashMap
    }
  end
  
  class ActionTranslator < ActionTranslatorImports.const_get :Lexer
    include_class_members ActionTranslatorImports
    
    class_module.module_eval {
      const_set_lazy(:LOCAL_ATTR) { 17 }
      const_attr_reader  :LOCAL_ATTR
      
      const_set_lazy(:SET_DYNAMIC_SCOPE_ATTR) { 18 }
      const_attr_reader  :SET_DYNAMIC_SCOPE_ATTR
      
      const_set_lazy(:ISOLATED_DYNAMIC_SCOPE) { 24 }
      const_attr_reader  :ISOLATED_DYNAMIC_SCOPE
      
      const_set_lazy(:WS) { 5 }
      const_attr_reader  :WS
      
      const_set_lazy(:UNKNOWN_SYNTAX) { 35 }
      const_attr_reader  :UNKNOWN_SYNTAX
      
      const_set_lazy(:DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR) { 23 }
      const_attr_reader  :DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR
      
      const_set_lazy(:SCOPE_INDEX_EXPR) { 21 }
      const_attr_reader  :SCOPE_INDEX_EXPR
      
      const_set_lazy(:DYNAMIC_SCOPE_ATTR) { 19 }
      const_attr_reader  :DYNAMIC_SCOPE_ATTR
      
      const_set_lazy(:ISOLATED_TOKEN_REF) { 14 }
      const_attr_reader  :ISOLATED_TOKEN_REF
      
      const_set_lazy(:SET_ATTRIBUTE) { 30 }
      const_attr_reader  :SET_ATTRIBUTE
      
      const_set_lazy(:SET_EXPR_ATTRIBUTE) { 29 }
      const_attr_reader  :SET_EXPR_ATTRIBUTE
      
      const_set_lazy(:ACTION) { 27 }
      const_attr_reader  :ACTION
      
      const_set_lazy(:ERROR_X) { 34 }
      const_attr_reader  :ERROR_X
      
      const_set_lazy(:TEMPLATE_INSTANCE) { 26 }
      const_attr_reader  :TEMPLATE_INSTANCE
      
      const_set_lazy(:TOKEN_SCOPE_ATTR) { 10 }
      const_attr_reader  :TOKEN_SCOPE_ATTR
      
      const_set_lazy(:ISOLATED_LEXER_RULE_REF) { 15 }
      const_attr_reader  :ISOLATED_LEXER_RULE_REF
      
      const_set_lazy(:ESC) { 32 }
      const_attr_reader  :ESC
      
      const_set_lazy(:SET_ENCLOSING_RULE_SCOPE_ATTR) { 7 }
      const_attr_reader  :SET_ENCLOSING_RULE_SCOPE_ATTR
      
      const_set_lazy(:ATTR_VALUE_EXPR) { 6 }
      const_attr_reader  :ATTR_VALUE_EXPR
      
      const_set_lazy(:RULE_SCOPE_ATTR) { 12 }
      const_attr_reader  :RULE_SCOPE_ATTR
      
      const_set_lazy(:LABEL_REF) { 13 }
      const_attr_reader  :LABEL_REF
      
      const_set_lazy(:INT) { 37 }
      const_attr_reader  :INT
      
      const_set_lazy(:ARG) { 25 }
      const_attr_reader  :ARG
      
      const_set_lazy(:EOF) { -1 }
      const_attr_reader  :EOF
      
      const_set_lazy(:SET_LOCAL_ATTR) { 16 }
      const_attr_reader  :SET_LOCAL_ATTR
      
      const_set_lazy(:TEXT) { 36 }
      const_attr_reader  :TEXT
      
      const_set_lazy(:DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR) { 22 }
      const_attr_reader  :DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR
      
      const_set_lazy(:SET_TOKEN_SCOPE_ATTR) { 9 }
      const_attr_reader  :SET_TOKEN_SCOPE_ATTR
      
      const_set_lazy(:ERROR_SCOPED_XY) { 20 }
      const_attr_reader  :ERROR_SCOPED_XY
      
      const_set_lazy(:SET_RULE_SCOPE_ATTR) { 11 }
      const_attr_reader  :SET_RULE_SCOPE_ATTR
      
      const_set_lazy(:ENCLOSING_RULE_SCOPE_ATTR) { 8 }
      const_attr_reader  :ENCLOSING_RULE_SCOPE_ATTR
      
      const_set_lazy(:ERROR_XY) { 33 }
      const_attr_reader  :ERROR_XY
      
      const_set_lazy(:TEMPLATE_EXPR) { 31 }
      const_attr_reader  :TEMPLATE_EXPR
      
      const_set_lazy(:INDIRECT_TEMPLATE_INSTANCE) { 28 }
      const_attr_reader  :INDIRECT_TEMPLATE_INSTANCE
      
      const_set_lazy(:ID) { 4 }
      const_attr_reader  :ID
    }
    
    attr_accessor :chunks
    alias_method :attr_chunks, :chunks
    undef_method :chunks
    alias_method :attr_chunks=, :chunks=
    undef_method :chunks=
    
    attr_accessor :enclosing_rule
    alias_method :attr_enclosing_rule, :enclosing_rule
    undef_method :enclosing_rule
    alias_method :attr_enclosing_rule=, :enclosing_rule=
    undef_method :enclosing_rule=
    
    attr_accessor :outer_alt_num
    alias_method :attr_outer_alt_num, :outer_alt_num
    undef_method :outer_alt_num
    alias_method :attr_outer_alt_num=, :outer_alt_num=
    undef_method :outer_alt_num=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :generator
    alias_method :attr_generator, :generator
    undef_method :generator
    alias_method :attr_generator=, :generator=
    undef_method :generator=
    
    attr_accessor :action_token
    alias_method :attr_action_token, :action_token
    undef_method :action_token
    alias_method :attr_action_token=, :action_token=
    undef_method :action_token=
    
    typesig { [CodeGenerator, String, GrammarAST] }
    def initialize(generator, rule_name, action_ast)
      initialize__action_translator(ANTLRStringStream.new(action_ast.attr_token.get_text))
      @generator = generator
      @grammar = generator.attr_grammar
      @enclosing_rule = @grammar.get_locally_defined_rule(rule_name)
      @action_token = action_ast.attr_token
      @outer_alt_num = action_ast.attr_outer_alt_num
    end
    
    typesig { [CodeGenerator, String, Antlr::Token, ::Java::Int] }
    def initialize(generator, rule_name, action_token, outer_alt_num)
      initialize__action_translator(ANTLRStringStream.new(action_token.get_text))
      @generator = generator
      @grammar = generator.attr_grammar
      @enclosing_rule = @grammar.get_rule(rule_name)
      @action_token = action_token
      @outer_alt_num = outer_alt_num
    end
    
    typesig { [] }
    # Return a list of strings and StringTemplate objects that
    # represent the translated action.
    def translate_to_chunks
      # System.out.println("###\naction="+action);
      t = nil
      begin
        t = next_token
      end while (!(t.get_type).equal?(Token::EOF))
      return @chunks
    end
    
    typesig { [] }
    def translate
      the_chunks = translate_to_chunks
      # System.out.println("chunks="+a.chunks);
      buf = StringBuffer.new
      i = 0
      while i < the_chunks.size
        o = the_chunks.get(i)
        buf.append(o)
        i += 1
      end
      # System.out.println("translated: "+buf.toString());
      return buf.to_s
    end
    
    typesig { [String] }
    def translate_action(action)
      rname = nil
      if (!(@enclosing_rule).nil?)
        rname = RJava.cast_to_string(@enclosing_rule.attr_name)
      end
      translator = ActionTranslator.new(@generator, rname, Antlr::CommonToken.new(ANTLRParser::ACTION, action), @outer_alt_num)
      return translator.translate_to_chunks
    end
    
    typesig { [String] }
    def is_token_ref_in_alt(id)
      return !(@enclosing_rule.get_token_refs_in_alt(id, @outer_alt_num)).nil?
    end
    
    typesig { [String] }
    def is_rule_ref_in_alt(id)
      return !(@enclosing_rule.get_rule_refs_in_alt(id, @outer_alt_num)).nil?
    end
    
    typesig { [String] }
    def get_element_label(id)
      return @enclosing_rule.get_label(id)
    end
    
    typesig { [String, ::Java::Boolean] }
    def check_element_ref_uniqueness(ref, is_token)
      refs = nil
      if (is_token)
        refs = @enclosing_rule.get_token_refs_in_alt(ref, @outer_alt_num)
      else
        refs = @enclosing_rule.get_rule_refs_in_alt(ref, @outer_alt_num)
      end
      if (!(refs).nil? && refs.size > 1)
        ErrorManager.grammar_error(ErrorManager::MSG_NONUNIQUE_REF, @grammar, @action_token, ref)
      end
    end
    
    typesig { [String, String] }
    # For $rulelabel.name, return the Attribute found for name.  It
    # will be a predefined property or a return value.
    def get_rule_label_attribute(rule_name, attr_name)
      r = @grammar.get_rule(rule_name)
      scope = r.get_local_attribute_scope(attr_name)
      if (!(scope).nil? && !scope.attr_is_parameter_scope)
        return scope.get_attribute(attr_name)
      end
      return nil
    end
    
    typesig { [String] }
    def resolve_dynamic_scope(scope_name)
      if (!(@grammar.get_global_scope(scope_name)).nil?)
        return @grammar.get_global_scope(scope_name)
      end
      scope_rule = @grammar.get_rule(scope_name)
      if (!(scope_rule).nil?)
        return scope_rule.attr_rule_scope
      end
      return nil # not a valid dynamic scope
    end
    
    typesig { [String] }
    def template(name)
      st = @generator.get_templates.get_instance_of(name)
      @chunks.add(st)
      return st
    end
    
    typesig { [] }
    # delegates
    # delegators
    def initialize
      @chunks = nil
      @enclosing_rule = nil
      @outer_alt_num = 0
      @grammar = nil
      @generator = nil
      @action_token = nil
      @dfa22 = nil
      @dfa28 = nil
      super()
      @chunks = ArrayList.new
      @dfa22 = DFA22.new_local(self, self)
      @dfa28 = DFA28.new_local(self, self)
    end
    
    typesig { [CharStream] }
    def initialize(input)
      initialize__action_translator(input, RecognizerSharedState.new)
    end
    
    typesig { [CharStream, RecognizerSharedState] }
    def initialize(input, state)
      @chunks = nil
      @enclosing_rule = nil
      @outer_alt_num = 0
      @grammar = nil
      @generator = nil
      @action_token = nil
      @dfa22 = nil
      @dfa28 = nil
      super(input, state)
      @chunks = ArrayList.new
      @dfa22 = DFA22.new_local(self, self)
      @dfa28 = DFA28.new_local(self, self)
    end
    
    typesig { [] }
    def get_grammar_file_name
      return "ActionTranslator.g"
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
    # $ANTLR start SET_ENCLOSING_RULE_SCOPE_ATTR
    def m_set_enclosing_rule_scope_attr
      begin
        _type = SET_ENCLOSING_RULE_SCOPE_ATTR
        x = nil
        y = nil
        expr = nil
        # ActionTranslator.g:177:2: ( '$' x= ID '.' y= ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';' {...}?)
        # ActionTranslator.g:177:4: '$' x= ID '.' y= ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';' {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start50 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start50, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start56 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start56, get_char_index - 1)
        # ActionTranslator.g:177:22: ( WS )?
        alt1 = 2
        la1_0 = self.attr_input._la(1)
        if (((la1_0 >= Character.new(?\t.ord) && la1_0 <= Character.new(?\n.ord)) || (la1_0).equal?(Character.new(?\r.ord)) || (la1_0).equal?(Character.new(?\s.ord))))
          alt1 = 1
        end
        case (alt1)
        when 1
          # ActionTranslator.g:177:22: WS
          m_ws
          if (self.attr_state.attr_failed)
            return
          end
        end
        match(Character.new(?=.ord))
        if (self.attr_state.attr_failed)
          return
        end
        expr_start65 = get_char_index
        m_attr_value_expr
        if (self.attr_state.attr_failed)
          return
        end
        expr = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, expr_start65, get_char_index - 1)
        match(Character.new(?;.ord))
        if (self.attr_state.attr_failed)
          return
        end
        if (!(!(@enclosing_rule).nil? && ((!(x).nil? ? x.get_text : nil) == @enclosing_rule.attr_name) && !(@enclosing_rule.get_local_attribute_scope((!(y).nil? ? y.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "SET_ENCLOSING_RULE_SCOPE_ATTR", "enclosingRule!=null &&\n\t                         $x.text.equals(enclosingRule.name) &&\n\t                         enclosingRule.getLocalAttributeScope($y.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = nil
          scope = @enclosing_rule.get_local_attribute_scope((!(y).nil? ? y.get_text : nil))
          if (scope.attr_is_predefined_rule_scope)
            if (((!(y).nil? ? y.get_text : nil) == "st") || ((!(y).nil? ? y.get_text : nil) == "tree"))
              st = template("ruleSetPropertyRef_" + RJava.cast_to_string((!(y).nil? ? y.get_text : nil)))
              @grammar.reference_rule_label_predefined_attribute((!(x).nil? ? x.get_text : nil))
              st.set_attribute("scope", (!(x).nil? ? x.get_text : nil))
              st.set_attribute("attr", (!(y).nil? ? y.get_text : nil))
              st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
            else
              ErrorManager.grammar_error(ErrorManager::MSG_WRITE_TO_READONLY_ATTR, @grammar, @action_token, (!(x).nil? ? x.get_text : nil), (!(y).nil? ? y.get_text : nil))
            end
          else
            if (scope.attr_is_predefined_lexer_rule_scope)
              # this is a better message to emit than the previous one...
              ErrorManager.grammar_error(ErrorManager::MSG_WRITE_TO_READONLY_ATTR, @grammar, @action_token, (!(x).nil? ? x.get_text : nil), (!(y).nil? ? y.get_text : nil))
            else
              if (scope.attr_is_parameter_scope)
                st = template("parameterSetAttributeRef")
                st.set_attribute("attr", scope.get_attribute((!(y).nil? ? y.get_text : nil)))
                st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
              else
                # must be return value
                st = template("returnSetAttributeRef")
                st.set_attribute("ruleDescriptor", @enclosing_rule)
                st.set_attribute("attr", scope.get_attribute((!(y).nil? ? y.get_text : nil)))
                st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
              end
            end
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end SET_ENCLOSING_RULE_SCOPE_ATTR
    # $ANTLR start ENCLOSING_RULE_SCOPE_ATTR
    def m_enclosing_rule_scope_attr
      begin
        _type = ENCLOSING_RULE_SCOPE_ATTR
        x = nil
        y = nil
        # ActionTranslator.g:222:2: ( '$' x= ID '.' y= ID {...}?)
        # ActionTranslator.g:222:4: '$' x= ID '.' y= ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start97 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start97, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start103 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start103, get_char_index - 1)
        if (!(!(@enclosing_rule).nil? && ((!(x).nil? ? x.get_text : nil) == @enclosing_rule.attr_name) && !(@enclosing_rule.get_local_attribute_scope((!(y).nil? ? y.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "ENCLOSING_RULE_SCOPE_ATTR", "enclosingRule!=null &&\n\t                         $x.text.equals(enclosingRule.name) &&\n\t                         enclosingRule.getLocalAttributeScope($y.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          if (is_rule_ref_in_alt((!(x).nil? ? x.get_text : nil)))
            ErrorManager.grammar_error(ErrorManager::MSG_RULE_REF_AMBIG_WITH_RULE_IN_ALT, @grammar, @action_token, (!(x).nil? ? x.get_text : nil))
          end
          st = nil
          scope = @enclosing_rule.get_local_attribute_scope((!(y).nil? ? y.get_text : nil))
          if (scope.attr_is_predefined_rule_scope)
            st = template("rulePropertyRef_" + RJava.cast_to_string((!(y).nil? ? y.get_text : nil)))
            @grammar.reference_rule_label_predefined_attribute((!(x).nil? ? x.get_text : nil))
            st.set_attribute("scope", (!(x).nil? ? x.get_text : nil))
            st.set_attribute("attr", (!(y).nil? ? y.get_text : nil))
          else
            if (scope.attr_is_predefined_lexer_rule_scope)
              # perhaps not the most precise error message to use, but...
              ErrorManager.grammar_error(ErrorManager::MSG_RULE_HAS_NO_ARGS, @grammar, @action_token, (!(x).nil? ? x.get_text : nil))
            else
              if (scope.attr_is_parameter_scope)
                st = template("parameterAttributeRef")
                st.set_attribute("attr", scope.get_attribute((!(y).nil? ? y.get_text : nil)))
              else
                # must be return value
                st = template("returnAttributeRef")
                st.set_attribute("ruleDescriptor", @enclosing_rule)
                st.set_attribute("attr", scope.get_attribute((!(y).nil? ? y.get_text : nil)))
              end
            end
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ENCLOSING_RULE_SCOPE_ATTR
    # $ANTLR start SET_TOKEN_SCOPE_ATTR
    def m_set_token_scope_attr
      begin
        _type = SET_TOKEN_SCOPE_ATTR
        x = nil
        y = nil
        # ActionTranslator.g:262:2: ( '$' x= ID '.' y= ID ( WS )? '=' {...}?)
        # ActionTranslator.g:262:4: '$' x= ID '.' y= ID ( WS )? '=' {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start129 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start129, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start135 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start135, get_char_index - 1)
        # ActionTranslator.g:262:22: ( WS )?
        alt2 = 2
        la2_0 = self.attr_input._la(1)
        if (((la2_0 >= Character.new(?\t.ord) && la2_0 <= Character.new(?\n.ord)) || (la2_0).equal?(Character.new(?\r.ord)) || (la2_0).equal?(Character.new(?\s.ord))))
          alt2 = 1
        end
        case (alt2)
        when 1
          # ActionTranslator.g:262:22: WS
          m_ws
          if (self.attr_state.attr_failed)
            return
          end
        end
        match(Character.new(?=.ord))
        if (self.attr_state.attr_failed)
          return
        end
        if (!(!(@enclosing_rule).nil? && !(self.attr_input._la(1)).equal?(Character.new(?=.ord)) && (!(@enclosing_rule.get_token_label((!(x).nil? ? x.get_text : nil))).nil? || is_token_ref_in_alt((!(x).nil? ? x.get_text : nil))) && !(AttributeScope.attr_token_scope.get_attribute((!(y).nil? ? y.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "SET_TOKEN_SCOPE_ATTR", "enclosingRule!=null && input.LA(1)!='=' &&\n\t                         (enclosingRule.getTokenLabel($x.text)!=null||\n\t                          isTokenRefInAlt($x.text)) &&\n\t                         AttributeScope.tokenScope.getAttribute($y.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          ErrorManager.grammar_error(ErrorManager::MSG_WRITE_TO_READONLY_ATTR, @grammar, @action_token, (!(x).nil? ? x.get_text : nil), (!(y).nil? ? y.get_text : nil))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end SET_TOKEN_SCOPE_ATTR
    # $ANTLR start TOKEN_SCOPE_ATTR
    def m_token_scope_attr
      begin
        _type = TOKEN_SCOPE_ATTR
        x = nil
        y = nil
        # ActionTranslator.g:281:2: ( '$' x= ID '.' y= ID {...}?)
        # ActionTranslator.g:281:4: '$' x= ID '.' y= ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start174 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start174, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start180 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start180, get_char_index - 1)
        if (!(!(@enclosing_rule).nil? && (!(@enclosing_rule.get_token_label((!(x).nil? ? x.get_text : nil))).nil? || is_token_ref_in_alt((!(x).nil? ? x.get_text : nil))) && !(AttributeScope.attr_token_scope.get_attribute((!(y).nil? ? y.get_text : nil))).nil? && (!(@grammar.attr_type).equal?(Grammar::LEXER) || (get_element_label((!(x).nil? ? x.get_text : nil)).attr_element_ref.attr_token.get_type).equal?(ANTLRParser::TOKEN_REF) || (get_element_label((!(x).nil? ? x.get_text : nil)).attr_element_ref.attr_token.get_type).equal?(ANTLRParser::STRING_LITERAL))))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "TOKEN_SCOPE_ATTR", "enclosingRule!=null &&\n\t                         (enclosingRule.getTokenLabel($x.text)!=null||\n\t                          isTokenRefInAlt($x.text)) &&\n\t                         AttributeScope.tokenScope.getAttribute($y.text)!=null &&\n\t                         (grammar.type!=Grammar.LEXER ||\n\t                         getElementLabel($x.text).elementRef.token.getType()==ANTLRParser.TOKEN_REF ||\n\t                         getElementLabel($x.text).elementRef.token.getType()==ANTLRParser.STRING_LITERAL)")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          label = (!(x).nil? ? x.get_text : nil)
          if ((@enclosing_rule.get_token_label((!(x).nil? ? x.get_text : nil))).nil?)
            # $tokenref.attr  gotta get old label or compute new one
            check_element_ref_uniqueness((!(x).nil? ? x.get_text : nil), true)
            label = RJava.cast_to_string(@enclosing_rule.get_element_label((!(x).nil? ? x.get_text : nil), @outer_alt_num, @generator))
            if ((label).nil?)
              ErrorManager.grammar_error(ErrorManager::MSG_FORWARD_ELEMENT_REF, @grammar, @action_token, "$" + RJava.cast_to_string((!(x).nil? ? x.get_text : nil)) + "." + RJava.cast_to_string((!(y).nil? ? y.get_text : nil)))
              label = RJava.cast_to_string((!(x).nil? ? x.get_text : nil))
            end
          end
          st = template("tokenLabelPropertyRef_" + RJava.cast_to_string((!(y).nil? ? y.get_text : nil)))
          st.set_attribute("scope", label)
          st.set_attribute("attr", AttributeScope.attr_token_scope.get_attribute((!(y).nil? ? y.get_text : nil)))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end TOKEN_SCOPE_ATTR
    # $ANTLR start SET_RULE_SCOPE_ATTR
    def m_set_rule_scope_attr
      begin
        _type = SET_RULE_SCOPE_ATTR
        x = nil
        y = nil
        pair = nil
        refd_rule_name = nil
        # ActionTranslator.g:319:2: ( '$' x= ID '.' y= ID ( WS )? '=' {...}?{...}?)
        # ActionTranslator.g:319:4: '$' x= ID '.' y= ID ( WS )? '=' {...}?{...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start211 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start211, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start217 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start217, get_char_index - 1)
        # ActionTranslator.g:319:22: ( WS )?
        alt3 = 2
        la3_0 = self.attr_input._la(1)
        if (((la3_0 >= Character.new(?\t.ord) && la3_0 <= Character.new(?\n.ord)) || (la3_0).equal?(Character.new(?\r.ord)) || (la3_0).equal?(Character.new(?\s.ord))))
          alt3 = 1
        end
        case (alt3)
        when 1
          # ActionTranslator.g:319:22: WS
          m_ws
          if (self.attr_state.attr_failed)
            return
          end
        end
        match(Character.new(?=.ord))
        if (self.attr_state.attr_failed)
          return
        end
        if (!(!(@enclosing_rule).nil? && !(self.attr_input._la(1)).equal?(Character.new(?=.ord))))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "SET_RULE_SCOPE_ATTR", "enclosingRule!=null && input.LA(1)!='='")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          pair = @enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))
          refd_rule_name = RJava.cast_to_string((!(x).nil? ? x.get_text : nil))
          if (!(pair).nil?)
            refd_rule_name = RJava.cast_to_string(pair.attr_referenced_rule_name)
          end
        end
        if (!((!(@enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))).nil? || is_rule_ref_in_alt((!(x).nil? ? x.get_text : nil))) && !(get_rule_label_attribute(!(@enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))).nil? ? @enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil)).attr_referenced_rule_name : (!(x).nil? ? x.get_text : nil), (!(y).nil? ? y.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "SET_RULE_SCOPE_ATTR", "(enclosingRule.getRuleLabel($x.text)!=null || isRuleRefInAlt($x.text)) &&\n\t      getRuleLabelAttribute(enclosingRule.getRuleLabel($x.text)!=null?enclosingRule.getRuleLabel($x.text).referencedRuleName:$x.text,$y.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          ErrorManager.grammar_error(ErrorManager::MSG_WRITE_TO_READONLY_ATTR, @grammar, @action_token, (!(x).nil? ? x.get_text : nil), (!(y).nil? ? y.get_text : nil))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end SET_RULE_SCOPE_ATTR
    # $ANTLR start RULE_SCOPE_ATTR
    def m_rule_scope_attr
      begin
        _type = RULE_SCOPE_ATTR
        x = nil
        y = nil
        pair = nil
        refd_rule_name = nil
        # ActionTranslator.g:348:2: ( '$' x= ID '.' y= ID {...}?{...}?)
        # ActionTranslator.g:348:4: '$' x= ID '.' y= ID {...}?{...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start270 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start270, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start276 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start276, get_char_index - 1)
        if (!(!(@enclosing_rule).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "RULE_SCOPE_ATTR", "enclosingRule!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          pair = @enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))
          refd_rule_name = RJava.cast_to_string((!(x).nil? ? x.get_text : nil))
          if (!(pair).nil?)
            refd_rule_name = RJava.cast_to_string(pair.attr_referenced_rule_name)
          end
        end
        if (!((!(@enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))).nil? || is_rule_ref_in_alt((!(x).nil? ? x.get_text : nil))) && !(get_rule_label_attribute(!(@enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil))).nil? ? @enclosing_rule.get_rule_label((!(x).nil? ? x.get_text : nil)).attr_referenced_rule_name : (!(x).nil? ? x.get_text : nil), (!(y).nil? ? y.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "RULE_SCOPE_ATTR", "(enclosingRule.getRuleLabel($x.text)!=null || isRuleRefInAlt($x.text)) &&\n\t      getRuleLabelAttribute(enclosingRule.getRuleLabel($x.text)!=null?enclosingRule.getRuleLabel($x.text).referencedRuleName:$x.text,$y.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          label = (!(x).nil? ? x.get_text : nil)
          if ((pair).nil?)
            # $ruleref.attr  gotta get old label or compute new one
            check_element_ref_uniqueness((!(x).nil? ? x.get_text : nil), false)
            label = RJava.cast_to_string(@enclosing_rule.get_element_label((!(x).nil? ? x.get_text : nil), @outer_alt_num, @generator))
            if ((label).nil?)
              ErrorManager.grammar_error(ErrorManager::MSG_FORWARD_ELEMENT_REF, @grammar, @action_token, "$" + RJava.cast_to_string((!(x).nil? ? x.get_text : nil)) + "." + RJava.cast_to_string((!(y).nil? ? y.get_text : nil)))
              label = RJava.cast_to_string((!(x).nil? ? x.get_text : nil))
            end
          end
          st = nil
          refd_rule = @grammar.get_rule(refd_rule_name)
          scope = refd_rule.get_local_attribute_scope((!(y).nil? ? y.get_text : nil))
          if (scope.attr_is_predefined_rule_scope)
            st = template("ruleLabelPropertyRef_" + RJava.cast_to_string((!(y).nil? ? y.get_text : nil)))
            @grammar.reference_rule_label_predefined_attribute(refd_rule_name)
            st.set_attribute("scope", label)
            st.set_attribute("attr", (!(y).nil? ? y.get_text : nil))
          else
            if (scope.attr_is_predefined_lexer_rule_scope)
              st = template("lexerRuleLabelPropertyRef_" + RJava.cast_to_string((!(y).nil? ? y.get_text : nil)))
              @grammar.reference_rule_label_predefined_attribute(refd_rule_name)
              st.set_attribute("scope", label)
              st.set_attribute("attr", (!(y).nil? ? y.get_text : nil))
            else
              if (scope.attr_is_parameter_scope)
                # TODO: error!
              else
                st = template("ruleLabelRef")
                st.set_attribute("referencedRule", refd_rule)
                st.set_attribute("scope", label)
                st.set_attribute("attr", scope.get_attribute((!(y).nil? ? y.get_text : nil)))
              end
            end
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end RULE_SCOPE_ATTR
    # $ANTLR start LABEL_REF
    def m_label_ref
      begin
        _type = LABEL_REF
        id1 = nil
        # ActionTranslator.g:406:2: ( '$' ID {...}?)
        # ActionTranslator.g:406:4: '$' ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        id1start318 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        id1 = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, id1start318, get_char_index - 1)
        if (!(!(@enclosing_rule).nil? && !(get_element_label((!(id1).nil? ? id1.get_text : nil))).nil? && (@enclosing_rule.get_rule_label((!(id1).nil? ? id1.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "LABEL_REF", "enclosingRule!=null &&\n\t            getElementLabel($ID.text)!=null &&\n\t\t        enclosingRule.getRuleLabel($ID.text)==null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = nil
          pair = get_element_label((!(id1).nil? ? id1.get_text : nil))
          if ((pair.attr_type).equal?(Grammar::TOKEN_LABEL) || (pair.attr_type).equal?(Grammar::CHAR_LABEL))
            st = template("tokenLabelRef")
          else
            st = template("listLabelRef")
          end
          st.set_attribute("label", (!(id1).nil? ? id1.get_text : nil))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end LABEL_REF
    # $ANTLR start ISOLATED_TOKEN_REF
    def m_isolated_token_ref
      begin
        _type = ISOLATED_TOKEN_REF
        id2 = nil
        # ActionTranslator.g:427:2: ( '$' ID {...}?)
        # ActionTranslator.g:427:4: '$' ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        id2start342 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        id2 = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, id2start342, get_char_index - 1)
        if (!(!(@grammar.attr_type).equal?(Grammar::LEXER) && !(@enclosing_rule).nil? && is_token_ref_in_alt((!(id2).nil? ? id2.get_text : nil))))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "ISOLATED_TOKEN_REF", "grammar.type!=Grammar.LEXER && enclosingRule!=null && isTokenRefInAlt($ID.text)")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          label = @enclosing_rule.get_element_label((!(id2).nil? ? id2.get_text : nil), @outer_alt_num, @generator)
          check_element_ref_uniqueness((!(id2).nil? ? id2.get_text : nil), true)
          if ((label).nil?)
            ErrorManager.grammar_error(ErrorManager::MSG_FORWARD_ELEMENT_REF, @grammar, @action_token, (!(id2).nil? ? id2.get_text : nil))
          else
            st = template("tokenLabelRef")
            st.set_attribute("label", label)
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ISOLATED_TOKEN_REF
    # $ANTLR start ISOLATED_LEXER_RULE_REF
    def m_isolated_lexer_rule_ref
      begin
        _type = ISOLATED_LEXER_RULE_REF
        id3 = nil
        # ActionTranslator.g:447:2: ( '$' ID {...}?)
        # ActionTranslator.g:447:4: '$' ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        id3start366 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        id3 = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, id3start366, get_char_index - 1)
        if (!((@grammar.attr_type).equal?(Grammar::LEXER) && !(@enclosing_rule).nil? && is_rule_ref_in_alt((!(id3).nil? ? id3.get_text : nil))))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "ISOLATED_LEXER_RULE_REF", "grammar.type==Grammar.LEXER &&\n\t             enclosingRule!=null &&\n\t             isRuleRefInAlt($ID.text)")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          label = @enclosing_rule.get_element_label((!(id3).nil? ? id3.get_text : nil), @outer_alt_num, @generator)
          check_element_ref_uniqueness((!(id3).nil? ? id3.get_text : nil), false)
          if ((label).nil?)
            ErrorManager.grammar_error(ErrorManager::MSG_FORWARD_ELEMENT_REF, @grammar, @action_token, (!(id3).nil? ? id3.get_text : nil))
          else
            st = template("lexerRuleLabel")
            st.set_attribute("label", label)
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ISOLATED_LEXER_RULE_REF
    # $ANTLR start SET_LOCAL_ATTR
    def m_set_local_attr
      begin
        _type = SET_LOCAL_ATTR
        expr = nil
        id4 = nil
        # ActionTranslator.g:479:2: ( '$' ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';' {...}?)
        # ActionTranslator.g:479:4: '$' ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';' {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        id4start390 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        id4 = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, id4start390, get_char_index - 1)
        # ActionTranslator.g:479:11: ( WS )?
        alt4 = 2
        la4_0 = self.attr_input._la(1)
        if (((la4_0 >= Character.new(?\t.ord) && la4_0 <= Character.new(?\n.ord)) || (la4_0).equal?(Character.new(?\r.ord)) || (la4_0).equal?(Character.new(?\s.ord))))
          alt4 = 1
        end
        case (alt4)
        when 1
          # ActionTranslator.g:479:11: WS
          m_ws
          if (self.attr_state.attr_failed)
            return
          end
        end
        match(Character.new(?=.ord))
        if (self.attr_state.attr_failed)
          return
        end
        expr_start399 = get_char_index
        m_attr_value_expr
        if (self.attr_state.attr_failed)
          return
        end
        expr = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, expr_start399, get_char_index - 1)
        match(Character.new(?;.ord))
        if (self.attr_state.attr_failed)
          return
        end
        if (!(!(@enclosing_rule).nil? && !(@enclosing_rule.get_local_attribute_scope((!(id4).nil? ? id4.get_text : nil))).nil? && !@enclosing_rule.get_local_attribute_scope((!(id4).nil? ? id4.get_text : nil)).attr_is_predefined_lexer_rule_scope))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "SET_LOCAL_ATTR", "enclosingRule!=null\n\t\t\t\t\t\t\t\t\t\t\t\t\t&& enclosingRule.getLocalAttributeScope($ID.text)!=null\n\t\t\t\t\t\t\t\t\t\t\t\t\t&& !enclosingRule.getLocalAttributeScope($ID.text).isPredefinedLexerRuleScope")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = nil
          scope = @enclosing_rule.get_local_attribute_scope((!(id4).nil? ? id4.get_text : nil))
          if (scope.attr_is_predefined_rule_scope)
            if (((!(id4).nil? ? id4.get_text : nil) == "tree") || ((!(id4).nil? ? id4.get_text : nil) == "st"))
              st = template("ruleSetPropertyRef_" + RJava.cast_to_string((!(id4).nil? ? id4.get_text : nil)))
              @grammar.reference_rule_label_predefined_attribute(@enclosing_rule.attr_name)
              st.set_attribute("scope", @enclosing_rule.attr_name)
              st.set_attribute("attr", (!(id4).nil? ? id4.get_text : nil))
              st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
            else
              ErrorManager.grammar_error(ErrorManager::MSG_WRITE_TO_READONLY_ATTR, @grammar, @action_token, (!(id4).nil? ? id4.get_text : nil), "")
            end
          else
            if (scope.attr_is_parameter_scope)
              st = template("parameterSetAttributeRef")
              st.set_attribute("attr", scope.get_attribute((!(id4).nil? ? id4.get_text : nil)))
              st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
            else
              st = template("returnSetAttributeRef")
              st.set_attribute("ruleDescriptor", @enclosing_rule)
              st.set_attribute("attr", scope.get_attribute((!(id4).nil? ? id4.get_text : nil)))
              st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
            end
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end SET_LOCAL_ATTR
    # $ANTLR start LOCAL_ATTR
    def m_local_attr
      begin
        _type = LOCAL_ATTR
        id5 = nil
        # ActionTranslator.g:515:2: ( '$' ID {...}?)
        # ActionTranslator.g:515:4: '$' ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        id5start422 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        id5 = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, id5start422, get_char_index - 1)
        if (!(!(@enclosing_rule).nil? && !(@enclosing_rule.get_local_attribute_scope((!(id5).nil? ? id5.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "LOCAL_ATTR", "enclosingRule!=null && enclosingRule.getLocalAttributeScope($ID.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = nil
          scope = @enclosing_rule.get_local_attribute_scope((!(id5).nil? ? id5.get_text : nil))
          if (scope.attr_is_predefined_rule_scope)
            st = template("rulePropertyRef_" + RJava.cast_to_string((!(id5).nil? ? id5.get_text : nil)))
            @grammar.reference_rule_label_predefined_attribute(@enclosing_rule.attr_name)
            st.set_attribute("scope", @enclosing_rule.attr_name)
            st.set_attribute("attr", (!(id5).nil? ? id5.get_text : nil))
          else
            if (scope.attr_is_predefined_lexer_rule_scope)
              st = template("lexerRulePropertyRef_" + RJava.cast_to_string((!(id5).nil? ? id5.get_text : nil)))
              st.set_attribute("scope", @enclosing_rule.attr_name)
              st.set_attribute("attr", (!(id5).nil? ? id5.get_text : nil))
            else
              if (scope.attr_is_parameter_scope)
                st = template("parameterAttributeRef")
                st.set_attribute("attr", scope.get_attribute((!(id5).nil? ? id5.get_text : nil)))
              else
                st = template("returnAttributeRef")
                st.set_attribute("ruleDescriptor", @enclosing_rule)
                st.set_attribute("attr", scope.get_attribute((!(id5).nil? ? id5.get_text : nil)))
              end
            end
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end LOCAL_ATTR
    # $ANTLR start SET_DYNAMIC_SCOPE_ATTR
    def m_set_dynamic_scope_attr
      begin
        _type = SET_DYNAMIC_SCOPE_ATTR
        x = nil
        y = nil
        expr = nil
        # ActionTranslator.g:556:2: ( '$' x= ID '::' y= ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';' {...}?)
        # ActionTranslator.g:556:4: '$' x= ID '::' y= ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';' {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start448 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start448, get_char_index - 1)
        match("::")
        if (self.attr_state.attr_failed)
          return
        end
        y_start454 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start454, get_char_index - 1)
        # ActionTranslator.g:556:23: ( WS )?
        alt5 = 2
        la5_0 = self.attr_input._la(1)
        if (((la5_0 >= Character.new(?\t.ord) && la5_0 <= Character.new(?\n.ord)) || (la5_0).equal?(Character.new(?\r.ord)) || (la5_0).equal?(Character.new(?\s.ord))))
          alt5 = 1
        end
        case (alt5)
        when 1
          # ActionTranslator.g:556:23: WS
          m_ws
          if (self.attr_state.attr_failed)
            return
          end
        end
        match(Character.new(?=.ord))
        if (self.attr_state.attr_failed)
          return
        end
        expr_start463 = get_char_index
        m_attr_value_expr
        if (self.attr_state.attr_failed)
          return
        end
        expr = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, expr_start463, get_char_index - 1)
        match(Character.new(?;.ord))
        if (self.attr_state.attr_failed)
          return
        end
        if (!(!(resolve_dynamic_scope((!(x).nil? ? x.get_text : nil))).nil? && !(resolve_dynamic_scope((!(x).nil? ? x.get_text : nil)).get_attribute((!(y).nil? ? y.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "SET_DYNAMIC_SCOPE_ATTR", "resolveDynamicScope($x.text)!=null &&\n\t\t\t\t\t\t     resolveDynamicScope($x.text).getAttribute($y.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          scope = resolve_dynamic_scope((!(x).nil? ? x.get_text : nil))
          if (!(scope).nil?)
            st = template("scopeSetAttributeRef")
            st.set_attribute("scope", (!(x).nil? ? x.get_text : nil))
            st.set_attribute("attr", scope.get_attribute((!(y).nil? ? y.get_text : nil)))
            st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
          else
            # error: invalid dynamic attribute
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end SET_DYNAMIC_SCOPE_ATTR
    # $ANTLR start DYNAMIC_SCOPE_ATTR
    def m_dynamic_scope_attr
      begin
        _type = DYNAMIC_SCOPE_ATTR
        x = nil
        y = nil
        # ActionTranslator.g:575:2: ( '$' x= ID '::' y= ID {...}?)
        # ActionTranslator.g:575:4: '$' x= ID '::' y= ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start498 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start498, get_char_index - 1)
        match("::")
        if (self.attr_state.attr_failed)
          return
        end
        y_start504 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start504, get_char_index - 1)
        if (!(!(resolve_dynamic_scope((!(x).nil? ? x.get_text : nil))).nil? && !(resolve_dynamic_scope((!(x).nil? ? x.get_text : nil)).get_attribute((!(y).nil? ? y.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "DYNAMIC_SCOPE_ATTR", "resolveDynamicScope($x.text)!=null &&\n\t\t\t\t\t\t     resolveDynamicScope($x.text).getAttribute($y.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          scope = resolve_dynamic_scope((!(x).nil? ? x.get_text : nil))
          if (!(scope).nil?)
            st = template("scopeAttributeRef")
            st.set_attribute("scope", (!(x).nil? ? x.get_text : nil))
            st.set_attribute("attr", scope.get_attribute((!(y).nil? ? y.get_text : nil)))
          else
            # error: invalid dynamic attribute
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end DYNAMIC_SCOPE_ATTR
    # $ANTLR start ERROR_SCOPED_XY
    def m_error_scoped_xy
      begin
        _type = ERROR_SCOPED_XY
        x = nil
        y = nil
        # ActionTranslator.g:594:2: ( '$' x= ID '::' y= ID )
        # ActionTranslator.g:594:4: '$' x= ID '::' y= ID
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start538 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start538, get_char_index - 1)
        match("::")
        if (self.attr_state.attr_failed)
          return
        end
        y_start544 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start544, get_char_index - 1)
        if ((self.attr_state.attr_backtracking).equal?(1))
          @chunks.add(get_text)
          @generator.issue_invalid_scope_error((!(x).nil? ? x.get_text : nil), (!(y).nil? ? y.get_text : nil), @enclosing_rule, @action_token, @outer_alt_num)
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ERROR_SCOPED_XY
    # $ANTLR start DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR
    def m_dynamic_negative_indexed_scope_attr
      begin
        _type = DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR
        x = nil
        expr = nil
        y = nil
        # ActionTranslator.g:612:2: ( '$' x= ID '[' '-' expr= SCOPE_INDEX_EXPR ']' '::' y= ID )
        # ActionTranslator.g:612:4: '$' x= ID '[' '-' expr= SCOPE_INDEX_EXPR ']' '::' y= ID
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start566 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start566, get_char_index - 1)
        match(Character.new(?[.ord))
        if (self.attr_state.attr_failed)
          return
        end
        match(Character.new(?-.ord))
        if (self.attr_state.attr_failed)
          return
        end
        expr_start574 = get_char_index
        m_scope_index_expr
        if (self.attr_state.attr_failed)
          return
        end
        expr = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, expr_start574, get_char_index - 1)
        match(Character.new(?].ord))
        if (self.attr_state.attr_failed)
          return
        end
        match("::")
        if (self.attr_state.attr_failed)
          return
        end
        y_start582 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start582, get_char_index - 1)
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = template("scopeAttributeRef")
          st.set_attribute("scope", (!(x).nil? ? x.get_text : nil))
          st.set_attribute("attr", resolve_dynamic_scope((!(x).nil? ? x.get_text : nil)).get_attribute((!(y).nil? ? y.get_text : nil)))
          st.set_attribute("negIndex", (!(expr).nil? ? expr.get_text : nil))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR
    # $ANTLR start DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR
    def m_dynamic_absolute_indexed_scope_attr
      begin
        _type = DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR
        x = nil
        expr = nil
        y = nil
        # ActionTranslator.g:623:2: ( '$' x= ID '[' expr= SCOPE_INDEX_EXPR ']' '::' y= ID )
        # ActionTranslator.g:623:4: '$' x= ID '[' expr= SCOPE_INDEX_EXPR ']' '::' y= ID
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start606 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start606, get_char_index - 1)
        match(Character.new(?[.ord))
        if (self.attr_state.attr_failed)
          return
        end
        expr_start612 = get_char_index
        m_scope_index_expr
        if (self.attr_state.attr_failed)
          return
        end
        expr = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, expr_start612, get_char_index - 1)
        match(Character.new(?].ord))
        if (self.attr_state.attr_failed)
          return
        end
        match("::")
        if (self.attr_state.attr_failed)
          return
        end
        y_start620 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start620, get_char_index - 1)
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = template("scopeAttributeRef")
          st.set_attribute("scope", (!(x).nil? ? x.get_text : nil))
          st.set_attribute("attr", resolve_dynamic_scope((!(x).nil? ? x.get_text : nil)).get_attribute((!(y).nil? ? y.get_text : nil)))
          st.set_attribute("index", (!(expr).nil? ? expr.get_text : nil))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR
    # $ANTLR start SCOPE_INDEX_EXPR
    def m_scope_index_expr
      begin
        # ActionTranslator.g:635:2: ( (~ ']' )+ )
        # ActionTranslator.g:635:4: (~ ']' )+
        # ActionTranslator.g:635:4: (~ ']' )+
        cnt6 = 0
        begin
          alt6 = 2
          la6_0 = self.attr_input._la(1)
          if (((la6_0 >= Character.new(0x0000) && la6_0 <= Character.new(?\\.ord)) || (la6_0 >= Character.new(?^.ord) && la6_0 <= Character.new(0xFFFE))))
            alt6 = 1
          end
          case (alt6)
          when 1
            # ActionTranslator.g:635:5: ~ ']'
            if ((self.attr_input._la(1) >= Character.new(0x0000) && self.attr_input._la(1) <= Character.new(?\\.ord)) || (self.attr_input._la(1) >= Character.new(?^.ord) && self.attr_input._la(1) <= Character.new(0xFFFE)))
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
            if (cnt6 >= 1)
              break
            end
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            eee = EarlyExitException.new(6, self.attr_input)
            raise eee
          end
          cnt6 += 1
        end while (true)
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end SCOPE_INDEX_EXPR
    # $ANTLR start ISOLATED_DYNAMIC_SCOPE
    def m_isolated_dynamic_scope
      begin
        _type = ISOLATED_DYNAMIC_SCOPE
        id6 = nil
        # ActionTranslator.g:644:2: ( '$' ID {...}?)
        # ActionTranslator.g:644:4: '$' ID {...}?
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        id6start663 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        id6 = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, id6start663, get_char_index - 1)
        if (!(!(resolve_dynamic_scope((!(id6).nil? ? id6.get_text : nil))).nil?))
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          raise FailedPredicateException.new(self.attr_input, "ISOLATED_DYNAMIC_SCOPE", "resolveDynamicScope($ID.text)!=null")
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = template("isolatedDynamicScopeRef")
          st.set_attribute("scope", (!(id6).nil? ? id6.get_text : nil))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ISOLATED_DYNAMIC_SCOPE
    # $ANTLR start TEMPLATE_INSTANCE
    def m_template_instance
      begin
        _type = TEMPLATE_INSTANCE
        # ActionTranslator.g:657:2: ( '%' ID '(' ( ( WS )? ARG ( ',' ( WS )? ARG )* ( WS )? )? ')' )
        # ActionTranslator.g:657:4: '%' ID '(' ( ( WS )? ARG ( ',' ( WS )? ARG )* ( WS )? )? ')'
        match(Character.new(?%.ord))
        if (self.attr_state.attr_failed)
          return
        end
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        match(Character.new(?(.ord))
        if (self.attr_state.attr_failed)
          return
        end
        # ActionTranslator.g:657:15: ( ( WS )? ARG ( ',' ( WS )? ARG )* ( WS )? )?
        alt11 = 2
        la11_0 = self.attr_input._la(1)
        if (((la11_0 >= Character.new(?\t.ord) && la11_0 <= Character.new(?\n.ord)) || (la11_0).equal?(Character.new(?\r.ord)) || (la11_0).equal?(Character.new(?\s.ord)) || (la11_0 >= Character.new(?A.ord) && la11_0 <= Character.new(?Z.ord)) || (la11_0).equal?(Character.new(?_.ord)) || (la11_0 >= Character.new(?a.ord) && la11_0 <= Character.new(?z.ord))))
          alt11 = 1
        end
        case (alt11)
        when 1
          # ActionTranslator.g:657:17: ( WS )? ARG ( ',' ( WS )? ARG )* ( WS )?
          # ActionTranslator.g:657:17: ( WS )?
          alt7 = 2
          la7_0 = self.attr_input._la(1)
          if (((la7_0 >= Character.new(?\t.ord) && la7_0 <= Character.new(?\n.ord)) || (la7_0).equal?(Character.new(?\r.ord)) || (la7_0).equal?(Character.new(?\s.ord))))
            alt7 = 1
          end
          case (alt7)
          when 1
            # ActionTranslator.g:657:17: WS
            m_ws
            if (self.attr_state.attr_failed)
              return
            end
          end
          m_arg
          if (self.attr_state.attr_failed)
            return
          end
          # ActionTranslator.g:657:25: ( ',' ( WS )? ARG )*
          begin
            alt9 = 2
            la9_0 = self.attr_input._la(1)
            if (((la9_0).equal?(Character.new(?,.ord))))
              alt9 = 1
            end
            case (alt9)
            when 1
              # ActionTranslator.g:657:26: ',' ( WS )? ARG
              match(Character.new(?,.ord))
              if (self.attr_state.attr_failed)
                return
              end
              # ActionTranslator.g:657:30: ( WS )?
              alt8 = 2
              la8_0 = self.attr_input._la(1)
              if (((la8_0 >= Character.new(?\t.ord) && la8_0 <= Character.new(?\n.ord)) || (la8_0).equal?(Character.new(?\r.ord)) || (la8_0).equal?(Character.new(?\s.ord))))
                alt8 = 1
              end
              case (alt8)
              when 1
                # ActionTranslator.g:657:30: WS
                m_ws
                if (self.attr_state.attr_failed)
                  return
                end
              end
              m_arg
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
          # ActionTranslator.g:657:40: ( WS )?
          alt10 = 2
          la10_0 = self.attr_input._la(1)
          if (((la10_0 >= Character.new(?\t.ord) && la10_0 <= Character.new(?\n.ord)) || (la10_0).equal?(Character.new(?\r.ord)) || (la10_0).equal?(Character.new(?\s.ord))))
            alt10 = 1
          end
          case (alt10)
          when 1
            # ActionTranslator.g:657:40: WS
            m_ws
            if (self.attr_state.attr_failed)
              return
            end
          end
        end
        match(Character.new(?).ord))
        if (self.attr_state.attr_failed)
          return
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          action = get_text.substring(1, get_text.length)
          rule_name = "<outside-of-rule>"
          if (!(@enclosing_rule).nil?)
            rule_name = RJava.cast_to_string(@enclosing_rule.attr_name)
          end
          st = @generator.translate_template_constructor(rule_name, @outer_alt_num, @action_token, action)
          if (!(st).nil?)
            @chunks.add(st)
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end TEMPLATE_INSTANCE
    # $ANTLR start INDIRECT_TEMPLATE_INSTANCE
    def m_indirect_template_instance
      begin
        _type = INDIRECT_TEMPLATE_INSTANCE
        # ActionTranslator.g:678:2: ( '%' '(' ACTION ')' '(' ( ( WS )? ARG ( ',' ( WS )? ARG )* ( WS )? )? ')' )
        # ActionTranslator.g:678:4: '%' '(' ACTION ')' '(' ( ( WS )? ARG ( ',' ( WS )? ARG )* ( WS )? )? ')'
        match(Character.new(?%.ord))
        if (self.attr_state.attr_failed)
          return
        end
        match(Character.new(?(.ord))
        if (self.attr_state.attr_failed)
          return
        end
        m_action
        if (self.attr_state.attr_failed)
          return
        end
        match(Character.new(?).ord))
        if (self.attr_state.attr_failed)
          return
        end
        match(Character.new(?(.ord))
        if (self.attr_state.attr_failed)
          return
        end
        # ActionTranslator.g:678:27: ( ( WS )? ARG ( ',' ( WS )? ARG )* ( WS )? )?
        alt16 = 2
        la16_0 = self.attr_input._la(1)
        if (((la16_0 >= Character.new(?\t.ord) && la16_0 <= Character.new(?\n.ord)) || (la16_0).equal?(Character.new(?\r.ord)) || (la16_0).equal?(Character.new(?\s.ord)) || (la16_0 >= Character.new(?A.ord) && la16_0 <= Character.new(?Z.ord)) || (la16_0).equal?(Character.new(?_.ord)) || (la16_0 >= Character.new(?a.ord) && la16_0 <= Character.new(?z.ord))))
          alt16 = 1
        end
        case (alt16)
        when 1
          # ActionTranslator.g:678:29: ( WS )? ARG ( ',' ( WS )? ARG )* ( WS )?
          # ActionTranslator.g:678:29: ( WS )?
          alt12 = 2
          la12_0 = self.attr_input._la(1)
          if (((la12_0 >= Character.new(?\t.ord) && la12_0 <= Character.new(?\n.ord)) || (la12_0).equal?(Character.new(?\r.ord)) || (la12_0).equal?(Character.new(?\s.ord))))
            alt12 = 1
          end
          case (alt12)
          when 1
            # ActionTranslator.g:678:29: WS
            m_ws
            if (self.attr_state.attr_failed)
              return
            end
          end
          m_arg
          if (self.attr_state.attr_failed)
            return
          end
          # ActionTranslator.g:678:37: ( ',' ( WS )? ARG )*
          begin
            alt14 = 2
            la14_0 = self.attr_input._la(1)
            if (((la14_0).equal?(Character.new(?,.ord))))
              alt14 = 1
            end
            case (alt14)
            when 1
              # ActionTranslator.g:678:38: ',' ( WS )? ARG
              match(Character.new(?,.ord))
              if (self.attr_state.attr_failed)
                return
              end
              # ActionTranslator.g:678:42: ( WS )?
              alt13 = 2
              la13_0 = self.attr_input._la(1)
              if (((la13_0 >= Character.new(?\t.ord) && la13_0 <= Character.new(?\n.ord)) || (la13_0).equal?(Character.new(?\r.ord)) || (la13_0).equal?(Character.new(?\s.ord))))
                alt13 = 1
              end
              case (alt13)
              when 1
                # ActionTranslator.g:678:42: WS
                m_ws
                if (self.attr_state.attr_failed)
                  return
                end
              end
              m_arg
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
          # ActionTranslator.g:678:52: ( WS )?
          alt15 = 2
          la15_0 = self.attr_input._la(1)
          if (((la15_0 >= Character.new(?\t.ord) && la15_0 <= Character.new(?\n.ord)) || (la15_0).equal?(Character.new(?\r.ord)) || (la15_0).equal?(Character.new(?\s.ord))))
            alt15 = 1
          end
          case (alt15)
          when 1
            # ActionTranslator.g:678:52: WS
            m_ws
            if (self.attr_state.attr_failed)
              return
            end
          end
        end
        match(Character.new(?).ord))
        if (self.attr_state.attr_failed)
          return
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          action = get_text.substring(1, get_text.length)
          st = @generator.translate_template_constructor(@enclosing_rule.attr_name, @outer_alt_num, @action_token, action)
          @chunks.add(st)
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end INDIRECT_TEMPLATE_INSTANCE
    # $ANTLR start ARG
    def m_arg
      begin
        # ActionTranslator.g:692:5: ( ID '=' ACTION )
        # ActionTranslator.g:692:7: ID '=' ACTION
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        match(Character.new(?=.ord))
        if (self.attr_state.attr_failed)
          return
        end
        m_action
        if (self.attr_state.attr_failed)
          return
        end
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ARG
    # $ANTLR start SET_EXPR_ATTRIBUTE
    def m_set_expr_attribute
      begin
        _type = SET_EXPR_ATTRIBUTE
        a = nil
        expr = nil
        id7 = nil
        # ActionTranslator.g:697:2: ( '%' a= ACTION '.' ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';' )
        # ActionTranslator.g:697:4: '%' a= ACTION '.' ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';'
        match(Character.new(?%.ord))
        if (self.attr_state.attr_failed)
          return
        end
        a_start813 = get_char_index
        m_action
        if (self.attr_state.attr_failed)
          return
        end
        a = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, a_start813, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        id7start817 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        id7 = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, id7start817, get_char_index - 1)
        # ActionTranslator.g:697:24: ( WS )?
        alt17 = 2
        la17_0 = self.attr_input._la(1)
        if (((la17_0 >= Character.new(?\t.ord) && la17_0 <= Character.new(?\n.ord)) || (la17_0).equal?(Character.new(?\r.ord)) || (la17_0).equal?(Character.new(?\s.ord))))
          alt17 = 1
        end
        case (alt17)
        when 1
          # ActionTranslator.g:697:24: WS
          m_ws
          if (self.attr_state.attr_failed)
            return
          end
        end
        match(Character.new(?=.ord))
        if (self.attr_state.attr_failed)
          return
        end
        expr_start826 = get_char_index
        m_attr_value_expr
        if (self.attr_state.attr_failed)
          return
        end
        expr = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, expr_start826, get_char_index - 1)
        match(Character.new(?;.ord))
        if (self.attr_state.attr_failed)
          return
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = template("actionSetAttribute")
          action = (!(a).nil? ? a.get_text : nil)
          action = RJava.cast_to_string(action.substring(1, action.length - 1)) # stuff inside {...}
          st.set_attribute("st", translate_action(action))
          st.set_attribute("attrName", (!(id7).nil? ? id7.get_text : nil))
          st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end SET_EXPR_ATTRIBUTE
    # $ANTLR start SET_ATTRIBUTE
    def m_set_attribute
      begin
        _type = SET_ATTRIBUTE
        x = nil
        y = nil
        expr = nil
        # ActionTranslator.g:714:2: ( '%' x= ID '.' y= ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';' )
        # ActionTranslator.g:714:4: '%' x= ID '.' y= ID ( WS )? '=' expr= ATTR_VALUE_EXPR ';'
        match(Character.new(?%.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start853 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start853, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start859 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start859, get_char_index - 1)
        # ActionTranslator.g:714:22: ( WS )?
        alt18 = 2
        la18_0 = self.attr_input._la(1)
        if (((la18_0 >= Character.new(?\t.ord) && la18_0 <= Character.new(?\n.ord)) || (la18_0).equal?(Character.new(?\r.ord)) || (la18_0).equal?(Character.new(?\s.ord))))
          alt18 = 1
        end
        case (alt18)
        when 1
          # ActionTranslator.g:714:22: WS
          m_ws
          if (self.attr_state.attr_failed)
            return
          end
        end
        match(Character.new(?=.ord))
        if (self.attr_state.attr_failed)
          return
        end
        expr_start868 = get_char_index
        m_attr_value_expr
        if (self.attr_state.attr_failed)
          return
        end
        expr = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, expr_start868, get_char_index - 1)
        match(Character.new(?;.ord))
        if (self.attr_state.attr_failed)
          return
        end
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = template("actionSetAttribute")
          st.set_attribute("st", (!(x).nil? ? x.get_text : nil))
          st.set_attribute("attrName", (!(y).nil? ? y.get_text : nil))
          st.set_attribute("expr", translate_action((!(expr).nil? ? expr.get_text : nil)))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end SET_ATTRIBUTE
    # $ANTLR start ATTR_VALUE_EXPR
    def m_attr_value_expr
      begin
        # ActionTranslator.g:727:2: (~ '=' (~ ';' )* )
        # ActionTranslator.g:727:4: ~ '=' (~ ';' )*
        if ((self.attr_input._la(1) >= Character.new(0x0000) && self.attr_input._la(1) <= Character.new(?<.ord)) || (self.attr_input._la(1) >= Character.new(?>.ord) && self.attr_input._la(1) <= Character.new(0xFFFE)))
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
        # ActionTranslator.g:727:9: (~ ';' )*
        begin
          alt19 = 2
          la19_0 = self.attr_input._la(1)
          if (((la19_0 >= Character.new(0x0000) && la19_0 <= Character.new(?:.ord)) || (la19_0 >= Character.new(?<.ord) && la19_0 <= Character.new(0xFFFE))))
            alt19 = 1
          end
          case (alt19)
          when 1
            # ActionTranslator.g:727:10: ~ ';'
            if ((self.attr_input._la(1) >= Character.new(0x0000) && self.attr_input._la(1) <= Character.new(?:.ord)) || (self.attr_input._la(1) >= Character.new(?<.ord) && self.attr_input._la(1) <= Character.new(0xFFFE)))
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
    # $ANTLR end ATTR_VALUE_EXPR
    # $ANTLR start TEMPLATE_EXPR
    def m_template_expr
      begin
        _type = TEMPLATE_EXPR
        a = nil
        # ActionTranslator.g:732:2: ( '%' a= ACTION )
        # ActionTranslator.g:732:4: '%' a= ACTION
        match(Character.new(?%.ord))
        if (self.attr_state.attr_failed)
          return
        end
        a_start917 = get_char_index
        m_action
        if (self.attr_state.attr_failed)
          return
        end
        a = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, a_start917, get_char_index - 1)
        if ((self.attr_state.attr_backtracking).equal?(1))
          st = template("actionStringConstructor")
          action = (!(a).nil? ? a.get_text : nil)
          action = RJava.cast_to_string(action.substring(1, action.length - 1)) # stuff inside {...}
          st.set_attribute("stringExpr", translate_action(action))
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end TEMPLATE_EXPR
    # $ANTLR start ACTION
    def m_action
      begin
        # ActionTranslator.g:744:2: ( '{' ( options {greedy=false; } : . )* '}' )
        # ActionTranslator.g:744:4: '{' ( options {greedy=false; } : . )* '}'
        match(Character.new(?{.ord))
        if (self.attr_state.attr_failed)
          return
        end
        # ActionTranslator.g:744:8: ( options {greedy=false; } : . )*
        begin
          alt20 = 2
          la20_0 = self.attr_input._la(1)
          if (((la20_0).equal?(Character.new(?}.ord))))
            alt20 = 2
          else
            if (((la20_0 >= Character.new(0x0000) && la20_0 <= Character.new(?|.ord)) || (la20_0 >= Character.new(?~.ord) && la20_0 <= Character.new(0xFFFE))))
              alt20 = 1
            end
          end
          case (alt20)
          when 1
            # ActionTranslator.g:744:33: .
            match_any
            if (self.attr_state.attr_failed)
              return
            end
          else
            break
          end
        end while (true)
        match(Character.new(?}.ord))
        if (self.attr_state.attr_failed)
          return
        end
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ACTION
    # $ANTLR start ESC
    def m_esc
      begin
        _type = ESC
        # ActionTranslator.g:747:5: ( '\\\\' '$' | '\\\\' '%' | '\\\\' ~ ( '$' | '%' ) )
        alt21 = 3
        la21_0 = self.attr_input._la(1)
        if (((la21_0).equal?(Character.new(?\\.ord))))
          la21_1 = self.attr_input._la(2)
          if (((la21_1).equal?(Character.new(?$.ord))))
            alt21 = 1
          else
            if (((la21_1).equal?(Character.new(?%.ord))))
              alt21 = 2
            else
              if (((la21_1 >= Character.new(0x0000) && la21_1 <= Character.new(?#.ord)) || (la21_1 >= Character.new(?&.ord) && la21_1 <= Character.new(0xFFFE))))
                alt21 = 3
              else
                if (self.attr_state.attr_backtracking > 0)
                  self.attr_state.attr_failed = true
                  return
                end
                nvae = NoViableAltException.new("", 21, 1, self.attr_input)
                raise nvae
              end
            end
          end
        else
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return
          end
          nvae = NoViableAltException.new("", 21, 0, self.attr_input)
          raise nvae
        end
        case (alt21)
        when 1
          # ActionTranslator.g:747:9: '\\\\' '$'
          match(Character.new(?\\.ord))
          if (self.attr_state.attr_failed)
            return
          end
          match(Character.new(?$.ord))
          if (self.attr_state.attr_failed)
            return
          end
          if ((self.attr_state.attr_backtracking).equal?(1))
            @chunks.add("$")
          end
        when 2
          # ActionTranslator.g:748:4: '\\\\' '%'
          match(Character.new(?\\.ord))
          if (self.attr_state.attr_failed)
            return
          end
          match(Character.new(?%.ord))
          if (self.attr_state.attr_failed)
            return
          end
          if ((self.attr_state.attr_backtracking).equal?(1))
            @chunks.add("%")
          end
        when 3
          # ActionTranslator.g:749:4: '\\\\' ~ ( '$' | '%' )
          match(Character.new(?\\.ord))
          if (self.attr_state.attr_failed)
            return
          end
          if ((self.attr_input._la(1) >= Character.new(0x0000) && self.attr_input._la(1) <= Character.new(?#.ord)) || (self.attr_input._la(1) >= Character.new(?&.ord) && self.attr_input._la(1) <= Character.new(0xFFFE)))
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
          if ((self.attr_state.attr_backtracking).equal?(1))
            @chunks.add(get_text)
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ESC
    # $ANTLR start ERROR_XY
    def m_error_xy
      begin
        _type = ERROR_XY
        x = nil
        y = nil
        # ActionTranslator.g:753:2: ( '$' x= ID '.' y= ID )
        # ActionTranslator.g:753:4: '$' x= ID '.' y= ID
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start1017 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start1017, get_char_index - 1)
        match(Character.new(?..ord))
        if (self.attr_state.attr_failed)
          return
        end
        y_start1023 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        y = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, y_start1023, get_char_index - 1)
        if ((self.attr_state.attr_backtracking).equal?(1))
          @chunks.add(get_text)
          @generator.issue_invalid_attribute_error((!(x).nil? ? x.get_text : nil), (!(y).nil? ? y.get_text : nil), @enclosing_rule, @action_token, @outer_alt_num)
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ERROR_XY
    # $ANTLR start ERROR_X
    def m_error_x
      begin
        _type = ERROR_X
        x = nil
        # ActionTranslator.g:763:2: ( '$' x= ID )
        # ActionTranslator.g:763:4: '$' x= ID
        match(Character.new(?$.ord))
        if (self.attr_state.attr_failed)
          return
        end
        x_start1043 = get_char_index
        m_id
        if (self.attr_state.attr_failed)
          return
        end
        x = CommonToken.new(self.attr_input, Token::INVALID_TOKEN_TYPE, Token::DEFAULT_CHANNEL, x_start1043, get_char_index - 1)
        if ((self.attr_state.attr_backtracking).equal?(1))
          @chunks.add(get_text)
          @generator.issue_invalid_attribute_error((!(x).nil? ? x.get_text : nil), @enclosing_rule, @action_token, @outer_alt_num)
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end ERROR_X
    # $ANTLR start UNKNOWN_SYNTAX
    def m_unknown_syntax
      begin
        _type = UNKNOWN_SYNTAX
        # ActionTranslator.g:773:2: ( '$' | '%' ( ID | '.' | '(' | ')' | ',' | '{' | '}' | '\"' )* )
        alt23 = 2
        la23_0 = self.attr_input._la(1)
        if (((la23_0).equal?(Character.new(?$.ord))))
          alt23 = 1
        else
          if (((la23_0).equal?(Character.new(?%.ord))))
            alt23 = 2
          else
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            nvae = NoViableAltException.new("", 23, 0, self.attr_input)
            raise nvae
          end
        end
        case (alt23)
        when 1
          # ActionTranslator.g:773:4: '$'
          match(Character.new(?$.ord))
          if (self.attr_state.attr_failed)
            return
          end
          if ((self.attr_state.attr_backtracking).equal?(1))
            @chunks.add(get_text)
            # shouldn't need an error here.  Just accept $ if it doesn't look like anything
          end
        when 2
          # ActionTranslator.g:778:4: '%' ( ID | '.' | '(' | ')' | ',' | '{' | '}' | '\"' )*
          match(Character.new(?%.ord))
          if (self.attr_state.attr_failed)
            return
          end
          # ActionTranslator.g:778:8: ( ID | '.' | '(' | ')' | ',' | '{' | '}' | '\"' )*
          begin
            alt22 = 9
            alt22 = @dfa22.predict(self.attr_input)
            case (alt22)
            when 1
              # ActionTranslator.g:778:9: ID
              m_id
              if (self.attr_state.attr_failed)
                return
              end
            when 2
              # ActionTranslator.g:778:12: '.'
              match(Character.new(?..ord))
              if (self.attr_state.attr_failed)
                return
              end
            when 3
              # ActionTranslator.g:778:16: '('
              match(Character.new(?(.ord))
              if (self.attr_state.attr_failed)
                return
              end
            when 4
              # ActionTranslator.g:778:20: ')'
              match(Character.new(?).ord))
              if (self.attr_state.attr_failed)
                return
              end
            when 5
              # ActionTranslator.g:778:24: ','
              match(Character.new(?,.ord))
              if (self.attr_state.attr_failed)
                return
              end
            when 6
              # ActionTranslator.g:778:28: '{'
              match(Character.new(?{.ord))
              if (self.attr_state.attr_failed)
                return
              end
            when 7
              # ActionTranslator.g:778:32: '}'
              match(Character.new(?}.ord))
              if (self.attr_state.attr_failed)
                return
              end
            when 8
              # ActionTranslator.g:778:36: '\"'
              match(Character.new(?\".ord))
              if (self.attr_state.attr_failed)
                return
              end
            else
              break
            end
          end while (true)
          if ((self.attr_state.attr_backtracking).equal?(1))
            @chunks.add(get_text)
            ErrorManager.grammar_error(ErrorManager::MSG_INVALID_TEMPLATE_ACTION, @grammar, @action_token, get_text)
          end
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end UNKNOWN_SYNTAX
    # $ANTLR start TEXT
    def m_text
      begin
        _type = TEXT
        # ActionTranslator.g:788:5: ( (~ ( '$' | '%' | '\\\\' ) )+ )
        # ActionTranslator.g:788:7: (~ ( '$' | '%' | '\\\\' ) )+
        # ActionTranslator.g:788:7: (~ ( '$' | '%' | '\\\\' ) )+
        cnt24 = 0
        begin
          alt24 = 2
          la24_0 = self.attr_input._la(1)
          if (((la24_0 >= Character.new(0x0000) && la24_0 <= Character.new(?#.ord)) || (la24_0 >= Character.new(?&.ord) && la24_0 <= Character.new(?[.ord)) || (la24_0 >= Character.new(?].ord) && la24_0 <= Character.new(0xFFFE))))
            alt24 = 1
          end
          case (alt24)
          when 1
            # ActionTranslator.g:788:7: ~ ( '$' | '%' | '\\\\' )
            if ((self.attr_input._la(1) >= Character.new(0x0000) && self.attr_input._la(1) <= Character.new(?#.ord)) || (self.attr_input._la(1) >= Character.new(?&.ord) && self.attr_input._la(1) <= Character.new(?[.ord)) || (self.attr_input._la(1) >= Character.new(?].ord) && self.attr_input._la(1) <= Character.new(0xFFFE)))
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
            if (cnt24 >= 1)
              break
            end
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            eee = EarlyExitException.new(24, self.attr_input)
            raise eee
          end
          cnt24 += 1
        end while (true)
        if ((self.attr_state.attr_backtracking).equal?(1))
          @chunks.add(get_text)
        end
        self.attr_state.attr_type = _type
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end TEXT
    # $ANTLR start ID
    def m_id
      begin
        # ActionTranslator.g:792:5: ( ( 'a' .. 'z' | 'A' .. 'Z' | '_' ) ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )* )
        # ActionTranslator.g:792:9: ( 'a' .. 'z' | 'A' .. 'Z' | '_' ) ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )*
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
        # ActionTranslator.g:792:33: ( 'a' .. 'z' | 'A' .. 'Z' | '_' | '0' .. '9' )*
        begin
          alt25 = 2
          la25_0 = self.attr_input._la(1)
          if (((la25_0 >= Character.new(?0.ord) && la25_0 <= Character.new(?9.ord)) || (la25_0 >= Character.new(?A.ord) && la25_0 <= Character.new(?Z.ord)) || (la25_0).equal?(Character.new(?_.ord)) || (la25_0 >= Character.new(?a.ord) && la25_0 <= Character.new(?z.ord))))
            alt25 = 1
          end
          case (alt25)
          when 1
            # ActionTranslator.g:
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
    # $ANTLR start INT
    def m_int
      begin
        # ActionTranslator.g:796:5: ( ( '0' .. '9' )+ )
        # ActionTranslator.g:796:7: ( '0' .. '9' )+
        # ActionTranslator.g:796:7: ( '0' .. '9' )+
        cnt26 = 0
        begin
          alt26 = 2
          la26_0 = self.attr_input._la(1)
          if (((la26_0 >= Character.new(?0.ord) && la26_0 <= Character.new(?9.ord))))
            alt26 = 1
          end
          case (alt26)
          when 1
            # ActionTranslator.g:796:7: '0' .. '9'
            match_range(Character.new(?0.ord), Character.new(?9.ord))
            if (self.attr_state.attr_failed)
              return
            end
          else
            if (cnt26 >= 1)
              break
            end
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            eee = EarlyExitException.new(26, self.attr_input)
            raise eee
          end
          cnt26 += 1
        end while (true)
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end INT
    # $ANTLR start WS
    def m_ws
      begin
        # ActionTranslator.g:800:4: ( ( ' ' | '\\t' | '\\n' | '\\r' )+ )
        # ActionTranslator.g:800:6: ( ' ' | '\\t' | '\\n' | '\\r' )+
        # ActionTranslator.g:800:6: ( ' ' | '\\t' | '\\n' | '\\r' )+
        cnt27 = 0
        begin
          alt27 = 2
          la27_0 = self.attr_input._la(1)
          if (((la27_0 >= Character.new(?\t.ord) && la27_0 <= Character.new(?\n.ord)) || (la27_0).equal?(Character.new(?\r.ord)) || (la27_0).equal?(Character.new(?\s.ord))))
            alt27 = 1
          end
          case (alt27)
          when 1
            # ActionTranslator.g:
            if ((self.attr_input._la(1) >= Character.new(?\t.ord) && self.attr_input._la(1) <= Character.new(?\n.ord)) || (self.attr_input._la(1)).equal?(Character.new(?\r.ord)) || (self.attr_input._la(1)).equal?(Character.new(?\s.ord)))
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
            if (cnt27 >= 1)
              break
            end
            if (self.attr_state.attr_backtracking > 0)
              self.attr_state.attr_failed = true
              return
            end
            eee = EarlyExitException.new(27, self.attr_input)
            raise eee
          end
          cnt27 += 1
        end while (true)
      ensure
      end
    end
    
    typesig { [] }
    # $ANTLR end WS
    def m_tokens
      # ActionTranslator.g:1:39: ( SET_ENCLOSING_RULE_SCOPE_ATTR | ENCLOSING_RULE_SCOPE_ATTR | SET_TOKEN_SCOPE_ATTR | TOKEN_SCOPE_ATTR | SET_RULE_SCOPE_ATTR | RULE_SCOPE_ATTR | LABEL_REF | ISOLATED_TOKEN_REF | ISOLATED_LEXER_RULE_REF | SET_LOCAL_ATTR | LOCAL_ATTR | SET_DYNAMIC_SCOPE_ATTR | DYNAMIC_SCOPE_ATTR | ERROR_SCOPED_XY | DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR | DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR | ISOLATED_DYNAMIC_SCOPE | TEMPLATE_INSTANCE | INDIRECT_TEMPLATE_INSTANCE | SET_EXPR_ATTRIBUTE | SET_ATTRIBUTE | TEMPLATE_EXPR | ESC | ERROR_XY | ERROR_X | UNKNOWN_SYNTAX | TEXT )
      alt28 = 27
      alt28 = @dfa28.predict(self.attr_input)
      case (alt28)
      when 1
        # ActionTranslator.g:1:41: SET_ENCLOSING_RULE_SCOPE_ATTR
        m_set_enclosing_rule_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 2
        # ActionTranslator.g:1:71: ENCLOSING_RULE_SCOPE_ATTR
        m_enclosing_rule_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 3
        # ActionTranslator.g:1:97: SET_TOKEN_SCOPE_ATTR
        m_set_token_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 4
        # ActionTranslator.g:1:118: TOKEN_SCOPE_ATTR
        m_token_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 5
        # ActionTranslator.g:1:135: SET_RULE_SCOPE_ATTR
        m_set_rule_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 6
        # ActionTranslator.g:1:155: RULE_SCOPE_ATTR
        m_rule_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 7
        # ActionTranslator.g:1:171: LABEL_REF
        m_label_ref
        if (self.attr_state.attr_failed)
          return
        end
      when 8
        # ActionTranslator.g:1:181: ISOLATED_TOKEN_REF
        m_isolated_token_ref
        if (self.attr_state.attr_failed)
          return
        end
      when 9
        # ActionTranslator.g:1:200: ISOLATED_LEXER_RULE_REF
        m_isolated_lexer_rule_ref
        if (self.attr_state.attr_failed)
          return
        end
      when 10
        # ActionTranslator.g:1:224: SET_LOCAL_ATTR
        m_set_local_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 11
        # ActionTranslator.g:1:239: LOCAL_ATTR
        m_local_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 12
        # ActionTranslator.g:1:250: SET_DYNAMIC_SCOPE_ATTR
        m_set_dynamic_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 13
        # ActionTranslator.g:1:273: DYNAMIC_SCOPE_ATTR
        m_dynamic_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 14
        # ActionTranslator.g:1:292: ERROR_SCOPED_XY
        m_error_scoped_xy
        if (self.attr_state.attr_failed)
          return
        end
      when 15
        # ActionTranslator.g:1:308: DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR
        m_dynamic_negative_indexed_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 16
        # ActionTranslator.g:1:344: DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR
        m_dynamic_absolute_indexed_scope_attr
        if (self.attr_state.attr_failed)
          return
        end
      when 17
        # ActionTranslator.g:1:380: ISOLATED_DYNAMIC_SCOPE
        m_isolated_dynamic_scope
        if (self.attr_state.attr_failed)
          return
        end
      when 18
        # ActionTranslator.g:1:403: TEMPLATE_INSTANCE
        m_template_instance
        if (self.attr_state.attr_failed)
          return
        end
      when 19
        # ActionTranslator.g:1:421: INDIRECT_TEMPLATE_INSTANCE
        m_indirect_template_instance
        if (self.attr_state.attr_failed)
          return
        end
      when 20
        # ActionTranslator.g:1:448: SET_EXPR_ATTRIBUTE
        m_set_expr_attribute
        if (self.attr_state.attr_failed)
          return
        end
      when 21
        # ActionTranslator.g:1:467: SET_ATTRIBUTE
        m_set_attribute
        if (self.attr_state.attr_failed)
          return
        end
      when 22
        # ActionTranslator.g:1:481: TEMPLATE_EXPR
        m_template_expr
        if (self.attr_state.attr_failed)
          return
        end
      when 23
        # ActionTranslator.g:1:495: ESC
        m_esc
        if (self.attr_state.attr_failed)
          return
        end
      when 24
        # ActionTranslator.g:1:499: ERROR_XY
        m_error_xy
        if (self.attr_state.attr_failed)
          return
        end
      when 25
        # ActionTranslator.g:1:508: ERROR_X
        m_error_x
        if (self.attr_state.attr_failed)
          return
        end
      when 26
        # ActionTranslator.g:1:516: UNKNOWN_SYNTAX
        m_unknown_syntax
        if (self.attr_state.attr_failed)
          return
        end
      when 27
        # ActionTranslator.g:1:531: TEXT
        m_text
        if (self.attr_state.attr_failed)
          return
        end
      end
    end
    
    typesig { [] }
    # $ANTLR start synpred1_ActionTranslator
    def synpred1__action_translator_fragment
      # ActionTranslator.g:1:41: ( SET_ENCLOSING_RULE_SCOPE_ATTR )
      # ActionTranslator.g:1:41: SET_ENCLOSING_RULE_SCOPE_ATTR
      m_set_enclosing_rule_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred1_ActionTranslator
    # $ANTLR start synpred2_ActionTranslator
    def synpred2__action_translator_fragment
      # ActionTranslator.g:1:71: ( ENCLOSING_RULE_SCOPE_ATTR )
      # ActionTranslator.g:1:71: ENCLOSING_RULE_SCOPE_ATTR
      m_enclosing_rule_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred2_ActionTranslator
    # $ANTLR start synpred3_ActionTranslator
    def synpred3__action_translator_fragment
      # ActionTranslator.g:1:97: ( SET_TOKEN_SCOPE_ATTR )
      # ActionTranslator.g:1:97: SET_TOKEN_SCOPE_ATTR
      m_set_token_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred3_ActionTranslator
    # $ANTLR start synpred4_ActionTranslator
    def synpred4__action_translator_fragment
      # ActionTranslator.g:1:118: ( TOKEN_SCOPE_ATTR )
      # ActionTranslator.g:1:118: TOKEN_SCOPE_ATTR
      m_token_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred4_ActionTranslator
    # $ANTLR start synpred5_ActionTranslator
    def synpred5__action_translator_fragment
      # ActionTranslator.g:1:135: ( SET_RULE_SCOPE_ATTR )
      # ActionTranslator.g:1:135: SET_RULE_SCOPE_ATTR
      m_set_rule_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred5_ActionTranslator
    # $ANTLR start synpred6_ActionTranslator
    def synpred6__action_translator_fragment
      # ActionTranslator.g:1:155: ( RULE_SCOPE_ATTR )
      # ActionTranslator.g:1:155: RULE_SCOPE_ATTR
      m_rule_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred6_ActionTranslator
    # $ANTLR start synpred7_ActionTranslator
    def synpred7__action_translator_fragment
      # ActionTranslator.g:1:171: ( LABEL_REF )
      # ActionTranslator.g:1:171: LABEL_REF
      m_label_ref
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred7_ActionTranslator
    # $ANTLR start synpred8_ActionTranslator
    def synpred8__action_translator_fragment
      # ActionTranslator.g:1:181: ( ISOLATED_TOKEN_REF )
      # ActionTranslator.g:1:181: ISOLATED_TOKEN_REF
      m_isolated_token_ref
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred8_ActionTranslator
    # $ANTLR start synpred9_ActionTranslator
    def synpred9__action_translator_fragment
      # ActionTranslator.g:1:200: ( ISOLATED_LEXER_RULE_REF )
      # ActionTranslator.g:1:200: ISOLATED_LEXER_RULE_REF
      m_isolated_lexer_rule_ref
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred9_ActionTranslator
    # $ANTLR start synpred10_ActionTranslator
    def synpred10__action_translator_fragment
      # ActionTranslator.g:1:224: ( SET_LOCAL_ATTR )
      # ActionTranslator.g:1:224: SET_LOCAL_ATTR
      m_set_local_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred10_ActionTranslator
    # $ANTLR start synpred11_ActionTranslator
    def synpred11__action_translator_fragment
      # ActionTranslator.g:1:239: ( LOCAL_ATTR )
      # ActionTranslator.g:1:239: LOCAL_ATTR
      m_local_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred11_ActionTranslator
    # $ANTLR start synpred12_ActionTranslator
    def synpred12__action_translator_fragment
      # ActionTranslator.g:1:250: ( SET_DYNAMIC_SCOPE_ATTR )
      # ActionTranslator.g:1:250: SET_DYNAMIC_SCOPE_ATTR
      m_set_dynamic_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred12_ActionTranslator
    # $ANTLR start synpred13_ActionTranslator
    def synpred13__action_translator_fragment
      # ActionTranslator.g:1:273: ( DYNAMIC_SCOPE_ATTR )
      # ActionTranslator.g:1:273: DYNAMIC_SCOPE_ATTR
      m_dynamic_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred13_ActionTranslator
    # $ANTLR start synpred14_ActionTranslator
    def synpred14__action_translator_fragment
      # ActionTranslator.g:1:292: ( ERROR_SCOPED_XY )
      # ActionTranslator.g:1:292: ERROR_SCOPED_XY
      m_error_scoped_xy
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred14_ActionTranslator
    # $ANTLR start synpred15_ActionTranslator
    def synpred15__action_translator_fragment
      # ActionTranslator.g:1:308: ( DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR )
      # ActionTranslator.g:1:308: DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR
      m_dynamic_negative_indexed_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred15_ActionTranslator
    # $ANTLR start synpred16_ActionTranslator
    def synpred16__action_translator_fragment
      # ActionTranslator.g:1:344: ( DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR )
      # ActionTranslator.g:1:344: DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR
      m_dynamic_absolute_indexed_scope_attr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred16_ActionTranslator
    # $ANTLR start synpred17_ActionTranslator
    def synpred17__action_translator_fragment
      # ActionTranslator.g:1:380: ( ISOLATED_DYNAMIC_SCOPE )
      # ActionTranslator.g:1:380: ISOLATED_DYNAMIC_SCOPE
      m_isolated_dynamic_scope
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred17_ActionTranslator
    # $ANTLR start synpred18_ActionTranslator
    def synpred18__action_translator_fragment
      # ActionTranslator.g:1:403: ( TEMPLATE_INSTANCE )
      # ActionTranslator.g:1:403: TEMPLATE_INSTANCE
      m_template_instance
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred18_ActionTranslator
    # $ANTLR start synpred19_ActionTranslator
    def synpred19__action_translator_fragment
      # ActionTranslator.g:1:421: ( INDIRECT_TEMPLATE_INSTANCE )
      # ActionTranslator.g:1:421: INDIRECT_TEMPLATE_INSTANCE
      m_indirect_template_instance
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred19_ActionTranslator
    # $ANTLR start synpred20_ActionTranslator
    def synpred20__action_translator_fragment
      # ActionTranslator.g:1:448: ( SET_EXPR_ATTRIBUTE )
      # ActionTranslator.g:1:448: SET_EXPR_ATTRIBUTE
      m_set_expr_attribute
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred20_ActionTranslator
    # $ANTLR start synpred21_ActionTranslator
    def synpred21__action_translator_fragment
      # ActionTranslator.g:1:467: ( SET_ATTRIBUTE )
      # ActionTranslator.g:1:467: SET_ATTRIBUTE
      m_set_attribute
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred21_ActionTranslator
    # $ANTLR start synpred22_ActionTranslator
    def synpred22__action_translator_fragment
      # ActionTranslator.g:1:481: ( TEMPLATE_EXPR )
      # ActionTranslator.g:1:481: TEMPLATE_EXPR
      m_template_expr
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred22_ActionTranslator
    # $ANTLR start synpred24_ActionTranslator
    def synpred24__action_translator_fragment
      # ActionTranslator.g:1:499: ( ERROR_XY )
      # ActionTranslator.g:1:499: ERROR_XY
      m_error_xy
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred24_ActionTranslator
    # $ANTLR start synpred25_ActionTranslator
    def synpred25__action_translator_fragment
      # ActionTranslator.g:1:508: ( ERROR_X )
      # ActionTranslator.g:1:508: ERROR_X
      m_error_x
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred25_ActionTranslator
    # $ANTLR start synpred26_ActionTranslator
    def synpred26__action_translator_fragment
      # ActionTranslator.g:1:516: ( UNKNOWN_SYNTAX )
      # ActionTranslator.g:1:516: UNKNOWN_SYNTAX
      m_unknown_syntax
      if (self.attr_state.attr_failed)
        return
      end
    end
    
    typesig { [] }
    # $ANTLR end synpred26_ActionTranslator
    def synpred19__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred19__action_translator_fragment # can never throw exception
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
    def synpred16__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred16__action_translator_fragment # can never throw exception
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
    def synpred25__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred25__action_translator_fragment # can never throw exception
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
    def synpred17__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred17__action_translator_fragment # can never throw exception
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
    def synpred1__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred1__action_translator_fragment # can never throw exception
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
    def synpred10__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred10__action_translator_fragment # can never throw exception
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
    def synpred24__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred24__action_translator_fragment # can never throw exception
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
    def synpred15__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred15__action_translator_fragment # can never throw exception
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
    def synpred11__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred11__action_translator_fragment # can never throw exception
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
    def synpred18__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred18__action_translator_fragment # can never throw exception
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
    def synpred21__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred21__action_translator_fragment # can never throw exception
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
    def synpred3__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred3__action_translator_fragment # can never throw exception
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
    def synpred26__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred26__action_translator_fragment # can never throw exception
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
    def synpred9__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred9__action_translator_fragment # can never throw exception
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
    def synpred2__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred2__action_translator_fragment # can never throw exception
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
    def synpred4__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred4__action_translator_fragment # can never throw exception
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
    def synpred22__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred22__action_translator_fragment # can never throw exception
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
    def synpred5__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred5__action_translator_fragment # can never throw exception
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
    def synpred6__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred6__action_translator_fragment # can never throw exception
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
    def synpred7__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred7__action_translator_fragment # can never throw exception
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
    def synpred12__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred12__action_translator_fragment # can never throw exception
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
    def synpred8__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred8__action_translator_fragment # can never throw exception
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
    def synpred13__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred13__action_translator_fragment # can never throw exception
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
    def synpred20__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred20__action_translator_fragment # can never throw exception
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
    def synpred14__action_translator
      self.attr_state.attr_backtracking += 1
      start = self.attr_input.mark
      begin
        synpred14__action_translator_fragment # can never throw exception
      rescue RecognitionException => re
        System.err.println("impossible: " + RJava.cast_to_string(re))
      end
      success = !self.attr_state.attr_failed
      self.attr_input.rewind(start)
      self.attr_state.attr_backtracking -= 1
      self.attr_state.attr_failed = false
      return success
    end
    
    attr_accessor :dfa22
    alias_method :attr_dfa22, :dfa22
    undef_method :dfa22
    alias_method :attr_dfa22=, :dfa22=
    undef_method :dfa22=
    
    attr_accessor :dfa28
    alias_method :attr_dfa28, :dfa28
    undef_method :dfa28
    alias_method :attr_dfa28=, :dfa28=
    undef_method :dfa28=
    
    class_module.module_eval {
      const_set_lazy(:DFA22_eotS) { ("\1\1\11".to_u << 0xffff << "") }
      const_attr_reader  :DFA22_eotS
      
      const_set_lazy(:DFA22_eofS) { ("\12".to_u << 0xffff << "") }
      const_attr_reader  :DFA22_eofS
      
      const_set_lazy(:DFA22_minS) { ("\1\42\11".to_u << 0xffff << "") }
      const_attr_reader  :DFA22_minS
      
      const_set_lazy(:DFA22_maxS) { ("\1\175\11".to_u << 0xffff << "") }
      const_attr_reader  :DFA22_maxS
      
      const_set_lazy(:DFA22_acceptS) { ("\1".to_u << 0xffff << "\1\11\1\1\1\2\1\3\1\4\1\5\1\6\1\7\1\10") }
      const_attr_reader  :DFA22_acceptS
      
      const_set_lazy(:DFA22_specialS) { ("\12".to_u << 0xffff << "}>") }
      const_attr_reader  :DFA22_specialS
      
      const_set_lazy(:DFA22_transitionS) { Array.typed(String).new([("\1\11\5".to_u << 0xffff << "\1\4\1\5\2".to_u << 0xffff << "\1\6\1".to_u << 0xffff << "\1\3\22".to_u << 0xffff << "\32\2") + ("\4".to_u << 0xffff << "\1\2\1".to_u << 0xffff << "\32\2\1\7\1".to_u << 0xffff << "\1\10"), "", "", "", "", "", "", "", "", ""]) }
      const_attr_reader  :DFA22_transitionS
      
      const_set_lazy(:DFA22_eot) { DFA.unpack_encoded_string(DFA22_eotS) }
      const_attr_reader  :DFA22_eot
      
      const_set_lazy(:DFA22_eof) { DFA.unpack_encoded_string(DFA22_eofS) }
      const_attr_reader  :DFA22_eof
      
      const_set_lazy(:DFA22_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA22_minS) }
      const_attr_reader  :DFA22_min
      
      const_set_lazy(:DFA22_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA22_maxS) }
      const_attr_reader  :DFA22_max
      
      const_set_lazy(:DFA22_accept) { DFA.unpack_encoded_string(DFA22_acceptS) }
      const_attr_reader  :DFA22_accept
      
      const_set_lazy(:DFA22_special) { DFA.unpack_encoded_string(DFA22_specialS) }
      const_attr_reader  :DFA22_special
      
      when_class_loaded do
        num_states = DFA22_transitionS.attr_length
        const_set :DFA22_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
        i = 0
        while i < num_states
          DFA22_transition[i] = DFA.unpack_encoded_string(DFA22_transitionS[i])
          i += 1
        end
      end
      
      const_set_lazy(:DFA22) { Class.new(DFA) do
        extend LocalClass
        include_class_members ActionTranslator
        
        typesig { [class_self::BaseRecognizer] }
        def initialize(recognizer)
          super()
          self.attr_recognizer = recognizer
          self.attr_decision_number = 22
          self.attr_eot = DFA22_eot
          self.attr_eof = DFA22_eof
          self.attr_min = DFA22_min
          self.attr_max = DFA22_max
          self.attr_accept = DFA22_accept
          self.attr_special = DFA22_special
          self.attr_transition = DFA22_transition
        end
        
        typesig { [] }
        def get_description
          return "()* loopback of 778:8: ( ID | '.' | '(' | ')' | ',' | '{' | '}' | '\"' )*"
        end
        
        private
        alias_method :initialize__dfa22, :initialize
      end }
      
      const_set_lazy(:DFA28_eotS) { ("\36".to_u << 0xffff << "") }
      const_attr_reader  :DFA28_eotS
      
      const_set_lazy(:DFA28_eofS) { ("\36".to_u << 0xffff << "") }
      const_attr_reader  :DFA28_eofS
      
      const_set_lazy(:DFA28_minS) { ("\2\0\10".to_u << 0xffff << "\1\0\23".to_u << 0xffff << "") }
      const_attr_reader  :DFA28_minS
      
      const_set_lazy(:DFA28_maxS) { ("\1".to_u << 0xfffe << "\1\0\10".to_u << 0xffff << "\1\0\23".to_u << 0xffff << "") }
      const_attr_reader  :DFA28_maxS
      
      const_set_lazy(:DFA28_acceptS) { ("\2".to_u << 0xffff << "\1\22\1\23\1\24\1\25\1\26\1\32\1\33\1\27\1".to_u << 0xffff << "\1\1\1\2") + "\1\3\1\4\1\5\1\6\1\7\1\10\1\11\1\12\1\13\1\14\1\15\1\16\1\17\1\20" + "\1\21\1\30\1\31" }
      const_attr_reader  :DFA28_acceptS
      
      const_set_lazy(:DFA28_specialS) { ("\1".to_u << 0xffff << "\1\0\10".to_u << 0xffff << "\1\1\23".to_u << 0xffff << "}>") }
      const_attr_reader  :DFA28_specialS
      
      const_set_lazy(:DFA28_transitionS) { Array.typed(String).new([("\44\10\1\12\1\1\66\10\1\11".to_u << 0xffa2 << "\10"), ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", ("\1".to_u << 0xffff << ""), "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]) }
      const_attr_reader  :DFA28_transitionS
      
      const_set_lazy(:DFA28_eot) { DFA.unpack_encoded_string(DFA28_eotS) }
      const_attr_reader  :DFA28_eot
      
      const_set_lazy(:DFA28_eof) { DFA.unpack_encoded_string(DFA28_eofS) }
      const_attr_reader  :DFA28_eof
      
      const_set_lazy(:DFA28_min) { DFA.unpack_encoded_string_to_unsigned_chars(DFA28_minS) }
      const_attr_reader  :DFA28_min
      
      const_set_lazy(:DFA28_max) { DFA.unpack_encoded_string_to_unsigned_chars(DFA28_maxS) }
      const_attr_reader  :DFA28_max
      
      const_set_lazy(:DFA28_accept) { DFA.unpack_encoded_string(DFA28_acceptS) }
      const_attr_reader  :DFA28_accept
      
      const_set_lazy(:DFA28_special) { DFA.unpack_encoded_string(DFA28_specialS) }
      const_attr_reader  :DFA28_special
      
      when_class_loaded do
        num_states = DFA28_transitionS.attr_length
        const_set :DFA28_transition, Array.typed(Array.typed(::Java::Short)).new(num_states) { nil }
        i = 0
        while i < num_states
          DFA28_transition[i] = DFA.unpack_encoded_string(DFA28_transitionS[i])
          i += 1
        end
      end
      
      const_set_lazy(:DFA28) { Class.new(DFA) do
        extend LocalClass
        include_class_members ActionTranslator
        
        typesig { [class_self::BaseRecognizer] }
        def initialize(recognizer)
          super()
          self.attr_recognizer = recognizer
          self.attr_decision_number = 28
          self.attr_eot = DFA28_eot
          self.attr_eof = DFA28_eof
          self.attr_min = DFA28_min
          self.attr_max = DFA28_max
          self.attr_accept = DFA28_accept
          self.attr_special = DFA28_special
          self.attr_transition = DFA28_transition
        end
        
        typesig { [] }
        def get_description
          return "1:1: Tokens options {k=1; backtrack=true; } : ( SET_ENCLOSING_RULE_SCOPE_ATTR | ENCLOSING_RULE_SCOPE_ATTR | SET_TOKEN_SCOPE_ATTR | TOKEN_SCOPE_ATTR | SET_RULE_SCOPE_ATTR | RULE_SCOPE_ATTR | LABEL_REF | ISOLATED_TOKEN_REF | ISOLATED_LEXER_RULE_REF | SET_LOCAL_ATTR | LOCAL_ATTR | SET_DYNAMIC_SCOPE_ATTR | DYNAMIC_SCOPE_ATTR | ERROR_SCOPED_XY | DYNAMIC_NEGATIVE_INDEXED_SCOPE_ATTR | DYNAMIC_ABSOLUTE_INDEXED_SCOPE_ATTR | ISOLATED_DYNAMIC_SCOPE | TEMPLATE_INSTANCE | INDIRECT_TEMPLATE_INSTANCE | SET_EXPR_ATTRIBUTE | SET_ATTRIBUTE | TEMPLATE_EXPR | ESC | ERROR_XY | ERROR_X | UNKNOWN_SYNTAX | TEXT );"
        end
        
        typesig { [::Java::Int, class_self::IntStream] }
        def special_state_transition(s, _input)
          input = _input
          _s = s
          case (s)
          when 0
            la28_1 = input._la(1)
            index28_1 = input.index
            input.rewind
            s = -1
            if ((synpred18__action_translator))
              s = 2
            else
              if ((synpred19__action_translator))
                s = 3
              else
                if ((synpred20__action_translator))
                  s = 4
                else
                  if ((synpred21__action_translator))
                    s = 5
                  else
                    if ((synpred22__action_translator))
                      s = 6
                    else
                      if ((synpred26__action_translator))
                        s = 7
                      end
                    end
                  end
                end
              end
            end
            input.seek(index28_1)
            if (s >= 0)
              return s
            end
          when 1
            la28_10 = input._la(1)
            index28_10 = input.index
            input.rewind
            s = -1
            if ((synpred1__action_translator))
              s = 11
            else
              if ((synpred2__action_translator))
                s = 12
              else
                if ((synpred3__action_translator))
                  s = 13
                else
                  if ((synpred4__action_translator))
                    s = 14
                  else
                    if ((synpred5__action_translator))
                      s = 15
                    else
                      if ((synpred6__action_translator))
                        s = 16
                      else
                        if ((synpred7__action_translator))
                          s = 17
                        else
                          if ((synpred8__action_translator))
                            s = 18
                          else
                            if ((synpred9__action_translator))
                              s = 19
                            else
                              if ((synpred10__action_translator))
                                s = 20
                              else
                                if ((synpred11__action_translator))
                                  s = 21
                                else
                                  if ((synpred12__action_translator))
                                    s = 22
                                  else
                                    if ((synpred13__action_translator))
                                      s = 23
                                    else
                                      if ((synpred14__action_translator))
                                        s = 24
                                      else
                                        if ((synpred15__action_translator))
                                          s = 25
                                        else
                                          if ((synpred16__action_translator))
                                            s = 26
                                          else
                                            if ((synpred17__action_translator))
                                              s = 27
                                            else
                                              if ((synpred24__action_translator))
                                                s = 28
                                              else
                                                if ((synpred25__action_translator))
                                                  s = 29
                                                else
                                                  if ((synpred26__action_translator))
                                                    s = 7
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            input.seek(index28_10)
            if (s >= 0)
              return s
            end
          end
          if (self.attr_state.attr_backtracking > 0)
            self.attr_state.attr_failed = true
            return -1
          end
          nvae = self.class::NoViableAltException.new(get_description, 28, _s, input)
          error(nvae)
          raise nvae
        end
        
        private
        alias_method :initialize__dfa28, :initialize
      end }
    }
    
    private
    alias_method :initialize__action_translator, :initialize
  end
  
end
