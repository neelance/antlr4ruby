require "rjava"
 # $ANTLR 2.7.7 (2006-01-29): "assign.types.g" -> "AssignTokenTypesWalker.java"$
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
  module AssignTokenTypesWalkerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Java::Util
      include ::Org::Antlr::Analysis
      include ::Org::Antlr::Misc
      include ::Java::Io
      include_const ::Antlr, :TreeParser
      include_const ::Antlr, :Token
      include_const ::Antlr::Collections, :AST
      include_const ::Antlr, :RecognitionException
      include_const ::Antlr, :ANTLRException
      include_const ::Antlr, :NoViableAltException
      include_const ::Antlr, :MismatchedTokenException
      include_const ::Antlr, :SemanticException
      include_const ::Antlr::Collections::Impl, :BitSet
      include_const ::Antlr, :ASTPair
      include_const ::Antlr::Collections::Impl, :ASTArray
    }
  end
  
  # [Warning: TJP says that this is probably out of date as of 11/19/2005,
  # but since it's probably still useful, I'll leave in.  Don't have energy
  # to update at the moment.]
  # 
  # Compute the token types for all literals and rules etc..  There are
  # a few different cases to consider for grammar types and a few situations
  # within.
  # 
  # CASE 1 : pure parser grammar
  # a) Any reference to a token gets a token type.
  # b) The tokens section may alias a token name to a string or char
  # 
  # CASE 2 : pure lexer grammar
  # a) Import token vocabulary if available. Set token types for any new tokens
  # to values above last imported token type
  # b) token rule definitions get token types if not already defined
  # c) literals do NOT get token types
  # 
  # CASE 3 : merged parser / lexer grammar
  # a) Any char or string literal gets a token type in a parser rule
  # b) Any reference to a token gets a token type if not referencing
  # a fragment lexer rule
  # c) The tokens section may alias a token name to a string or char
  # which must add a rule to the lexer
  # d) token rule definitions get token types if not already defined
  # e) token rule definitions may also alias a token name to a literal.
  # E.g., Rule 'FOR : "for";' will alias FOR to "for" in the sense that
  # references to either in the parser grammar will yield the token type
  # 
  # What this pass does:
  # 
  # 0. Collects basic info about the grammar like grammar name and type;
  # Oh, I have go get the options in case they affect the token types.
  # E.g., tokenVocab option.
  # Imports any token vocab name/type pairs into a local hashtable.
  # 1. Finds a list of all literals and token names.
  # 2. Finds a list of all token name rule definitions;
  # no token rules implies pure parser.
  # 3. Finds a list of all simple token rule defs of form "<NAME> : <literal>;"
  # and aliases them.
  # 4. Walks token names table and assign types to any unassigned
  # 5. Walks aliases and assign types to referenced literals
  # 6. Walks literals, assigning types if untyped
  # 4. Informs the Grammar object of the type definitions such as:
  # g.defineToken(<charliteral>, ttype);
  # g.defineToken(<stringliteral>, ttype);
  # g.defineToken(<tokenID>, ttype);
  # where some of the ttype values will be the same for aliases tokens.
  class AssignTokenTypesWalker < Antlr::TreeParser
    include_class_members AssignTokenTypesWalkerImports
    include AssignTokenTypesWalkerTokenTypes
    
    typesig { [RecognitionException] }
    def report_error(ex)
      token = nil
      if (ex.is_a?(MismatchedTokenException))
        token = (ex).attr_token
      else
        if (ex.is_a?(NoViableAltException))
          token = (ex).attr_token
        end
      end
      ErrorManager.syntax_error(ErrorManager::MSG_SYNTAX_ERROR, @grammar, token, "assign.types: " + (ex.to_s).to_s, ex)
    end
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :current_rule_name
    alias_method :attr_current_rule_name, :current_rule_name
    undef_method :current_rule_name
    alias_method :attr_current_rule_name=, :current_rule_name=
    undef_method :current_rule_name=
    
    class_module.module_eval {
      
      def string_alias
        defined?(@@string_alias) ? @@string_alias : @@string_alias= nil
      end
      alias_method :attr_string_alias, :string_alias
      
      def string_alias=(value)
        @@string_alias = value
      end
      alias_method :attr_string_alias=, :string_alias=
      
      
      def char_alias
        defined?(@@char_alias) ? @@char_alias : @@char_alias= nil
      end
      alias_method :attr_char_alias, :char_alias
      
      def char_alias=(value)
        @@char_alias = value
      end
      alias_method :attr_char_alias=, :char_alias=
      
      
      def string_alias2
        defined?(@@string_alias2) ? @@string_alias2 : @@string_alias2= nil
      end
      alias_method :attr_string_alias2, :string_alias2
      
      def string_alias2=(value)
        @@string_alias2 = value
      end
      alias_method :attr_string_alias2=, :string_alias2=
      
      
      def char_alias2
        defined?(@@char_alias2) ? @@char_alias2 : @@char_alias2= nil
      end
      alias_method :attr_char_alias2, :char_alias2
      
      def char_alias2=(value)
        @@char_alias2 = value
      end
      alias_method :attr_char_alias2=, :char_alias2=
    }
    
    typesig { [] }
    def init_astpatterns
      self.attr_string_alias = self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(BLOCK)).add(self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(ALT)).add(self.attr_ast_factory.create(STRING_LITERAL)).add(self.attr_ast_factory.create(EOA)))).add(self.attr_ast_factory.create(EOB)))
      self.attr_char_alias = self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(BLOCK)).add(self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(ALT)).add(self.attr_ast_factory.create(CHAR_LITERAL)).add(self.attr_ast_factory.create(EOA)))).add(self.attr_ast_factory.create(EOB)))
      self.attr_string_alias2 = self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(BLOCK)).add(self.attr_ast_factory.make((ASTArray.new(4)).add(self.attr_ast_factory.create(ALT)).add(self.attr_ast_factory.create(STRING_LITERAL)).add(self.attr_ast_factory.create(ACTION)).add(self.attr_ast_factory.create(EOA)))).add(self.attr_ast_factory.create(EOB)))
      self.attr_char_alias2 = self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(BLOCK)).add(self.attr_ast_factory.make((ASTArray.new(4)).add(self.attr_ast_factory.create(ALT)).add(self.attr_ast_factory.create(CHAR_LITERAL)).add(self.attr_ast_factory.create(ACTION)).add(self.attr_ast_factory.create(EOA)))).add(self.attr_ast_factory.create(EOB)))
    end
    
    typesig { [GrammarAST] }
    # Behavior moved to AssignTokenTypesBehavior
    def track_string(t)
    end
    
    typesig { [GrammarAST] }
    def track_token(t)
    end
    
    typesig { [GrammarAST, GrammarAST, GrammarAST] }
    def track_token_rule(t, modifier, block)
    end
    
    typesig { [GrammarAST, GrammarAST] }
    def alias(t, s)
    end
    
    typesig { [Grammar] }
    def define_tokens(root)
    end
    
    typesig { [] }
    def define_string_literals_from_delegates
    end
    
    typesig { [Grammar] }
    def assign_string_types(root)
    end
    
    typesig { [Grammar] }
    def alias_token_ids_and_literals(root)
    end
    
    typesig { [Grammar] }
    def assign_token_idtypes(root)
    end
    
    typesig { [Grammar] }
    def define_token_names_and_literals_in_grammar(root)
    end
    
    typesig { [Grammar] }
    def init(root)
    end
    
    typesig { [] }
    def initialize
      @grammar = nil
      @current_rule_name = nil
      super()
      self.attr_token_names = _tokenNames
    end
    
    typesig { [AST, Grammar] }
    def grammar(_t, g)
      grammar_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      init(g)
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LEXER_GRAMMAR
          __t3 = _t
          tmp1_ast_in = _t
          match(_t, LEXER_GRAMMAR)
          _t = _t.get_first_child
          grammar_spec(_t)
          _t = self.attr__ret_tree
          _t = __t3
          _t = _t.get_next_sibling
        when PARSER_GRAMMAR
          __t4 = _t
          tmp2_ast_in = _t
          match(_t, PARSER_GRAMMAR)
          _t = _t.get_first_child
          grammar_spec(_t)
          _t = self.attr__ret_tree
          _t = __t4
          _t = _t.get_next_sibling
        when TREE_GRAMMAR
          __t5 = _t
          tmp3_ast_in = _t
          match(_t, TREE_GRAMMAR)
          _t = _t.get_first_child
          grammar_spec(_t)
          _t = self.attr__ret_tree
          _t = __t5
          _t = _t.get_next_sibling
        when COMBINED_GRAMMAR
          __t6 = _t
          tmp4_ast_in = _t
          match(_t, COMBINED_GRAMMAR)
          _t = _t.get_first_child
          grammar_spec(_t)
          _t = self.attr__ret_tree
          _t = __t6
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def grammar_spec(_t)
      grammar_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      cmt = nil
      opts = nil
      begin
        # for error handling
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when DOC_COMMENT
          cmt = _t
          match(_t, DOC_COMMENT)
          _t = _t.get_next_sibling
        when OPTIONS, TOKENS, RULE, SCOPE, IMPORT, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          options_spec(_t)
          _t = self.attr__ret_tree
        when TOKENS, RULE, SCOPE, IMPORT, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when IMPORT
          delegate_grammars(_t)
          _t = self.attr__ret_tree
        when TOKENS, RULE, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when TOKENS
          tokens_spec(_t)
          _t = self.attr__ret_tree
        when RULE, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(SCOPE)))
            attr_scope(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            tmp5_ast_in = _t
            match(_t, AMPERSAND)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        rules(_t)
        _t = self.attr__ret_tree
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def options_spec(_t)
      opts = HashMap.new
      options_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t19 = _t
        tmp6_ast_in = _t
        match(_t, OPTIONS)
        _t = _t.get_first_child
        _cnt21 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ASSIGN)))
            option(_t, opts)
            _t = self.attr__ret_tree
          else
            if (_cnt21 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt21 += 1
        end while (true)
        _t = __t19
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return opts
    end
    
    typesig { [AST] }
    def delegate_grammars(_t)
      delegate_grammars_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t31 = _t
        tmp7_ast_in = _t
        match(_t, IMPORT)
        _t = _t.get_first_child
        _cnt34 = 0
        catch(:break__loop34) do
          begin
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when ASSIGN
              __t33 = _t
              tmp8_ast_in = _t
              match(_t, ASSIGN)
              _t = _t.get_first_child
              tmp9_ast_in = _t
              match(_t, ID)
              _t = _t.get_next_sibling
              tmp10_ast_in = _t
              match(_t, ID)
              _t = _t.get_next_sibling
              _t = __t33
              _t = _t.get_next_sibling
            when ID
              tmp11_ast_in = _t
              match(_t, ID)
              _t = _t.get_next_sibling
            else
              if (_cnt34 >= 1)
                throw :break__loop34, :thrown
              else
                raise NoViableAltException.new(_t)
              end
            end
            _cnt34 += 1
          end while (true)
        end
        _t = __t31
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def tokens_spec(_t)
      tokens_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t36 = _t
        tmp12_ast_in = _t
        match(_t, TOKENS)
        _t = _t.get_first_child
        _cnt38 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(TOKEN_REF)))
            token_spec(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt38 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt38 += 1
        end while (true)
        _t = __t36
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def attr_scope(_t)
      attr_scope_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t17 = _t
        tmp13_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        tmp14_ast_in = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        tmp15_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t17
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rules(_t)
      rules_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        _cnt44 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(RULE)))
            rule(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt44 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt44 += 1
        end while (true)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, Map] }
    def option(_t, opts)
      option_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      key = nil
      value = nil
      begin
        # for error handling
        __t23 = _t
        tmp16_ast_in = _t
        match(_t, ASSIGN)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        key = (id.get_text).to_s
        value = option_value(_t)
        _t = self.attr__ret_tree
        _t = __t23
        _t = _t.get_next_sibling
        opts.put(key, value)
        # check for grammar-level option to import vocabulary
        if ((@current_rule_name).nil? && (key == "tokenVocab"))
          @grammar.import_token_vocabulary(id, value)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def option_value(_t)
      value = nil
      option_value_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      s = nil
      c = nil
      i = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ID
          id = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          value = id.get_text
        when STRING_LITERAL
          s = _t
          match(_t, STRING_LITERAL)
          _t = _t.get_next_sibling
          value = s.get_text
        when CHAR_LITERAL
          c = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          value = c.get_text
        when INT
          i = _t
          match(_t, INT)
          _t = _t.get_next_sibling
          value = i.get_text
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return value
    end
    
    typesig { [AST] }
    def char_set(_t)
      char_set_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t26 = _t
        tmp17_ast_in = _t
        match(_t, CHARSET)
        _t = _t.get_first_child
        char_set_element(_t)
        _t = self.attr__ret_tree
        _t = __t26
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def char_set_element(_t)
      char_set_element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      c = nil
      c1 = nil
      c2 = nil
      c3 = nil
      c4 = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when CHAR_LITERAL
          c = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
        when OR
          __t28 = _t
          tmp18_ast_in = _t
          match(_t, OR)
          _t = _t.get_first_child
          c1 = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          c2 = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          _t = __t28
          _t = _t.get_next_sibling
        when RANGE
          __t29 = _t
          tmp19_ast_in = _t
          match(_t, RANGE)
          _t = _t.get_first_child
          c3 = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          c4 = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          _t = __t29
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def token_spec(_t)
      token_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      t = nil
      t2 = nil
      s = nil
      c = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when TOKEN_REF
          t = _t
          match(_t, TOKEN_REF)
          _t = _t.get_next_sibling
          track_token(t)
        when ASSIGN
          __t40 = _t
          tmp20_ast_in = _t
          match(_t, ASSIGN)
          _t = _t.get_first_child
          t2 = _t
          match(_t, TOKEN_REF)
          _t = _t.get_next_sibling
          track_token(t2)
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when STRING_LITERAL
            s = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_next_sibling
            track_string(s)
            alias(t2, s)
          when CHAR_LITERAL
            c = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            track_string(c)
            alias(t2, c)
          else
            raise NoViableAltException.new(_t)
          end
          _t = __t40
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rule(_t)
      rule_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      m = nil
      b = nil
      begin
        # for error handling
        __t46 = _t
        tmp21_ast_in = _t
        match(_t, RULE)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        @current_rule_name = (id.get_text).to_s
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when FRAGMENT, LITERAL_protected, LITERAL_public, LITERAL_private
          m = (_t).equal?(ASTNULL) ? nil : _t
          modifier(_t)
          _t = self.attr__ret_tree
        when ARG
        else
          raise NoViableAltException.new(_t)
        end
        tmp22_ast_in = _t
        match(_t, ARG)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ARG_ACTION
          tmp23_ast_in = _t
          match(_t, ARG_ACTION)
          _t = _t.get_next_sibling
        when RET
        else
          raise NoViableAltException.new(_t)
        end
        tmp24_ast_in = _t
        match(_t, RET)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ARG_ACTION
          tmp25_ast_in = _t
          match(_t, ARG_ACTION)
          _t = _t.get_next_sibling
        when OPTIONS, BLOCK, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          options_spec(_t)
          _t = self.attr__ret_tree
        when BLOCK, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when SCOPE
          rule_scope_spec(_t)
          _t = self.attr__ret_tree
        when BLOCK, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            tmp26_ast_in = _t
            match(_t, AMPERSAND)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        b = (_t).equal?(ASTNULL) ? nil : _t
        block(_t)
        _t = self.attr__ret_tree
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_catch, LITERAL_finally
          exception_group(_t)
          _t = self.attr__ret_tree
        when EOR
        else
          raise NoViableAltException.new(_t)
        end
        tmp27_ast_in = _t
        match(_t, EOR)
        _t = _t.get_next_sibling
        track_token_rule(id, m, b)
        _t = __t46
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def modifier(_t)
      modifier_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_protected
          tmp28_ast_in = _t
          match(_t, LITERAL_protected)
          _t = _t.get_next_sibling
        when LITERAL_public
          tmp29_ast_in = _t
          match(_t, LITERAL_public)
          _t = _t.get_next_sibling
        when LITERAL_private
          tmp30_ast_in = _t
          match(_t, LITERAL_private)
          _t = _t.get_next_sibling
        when FRAGMENT
          tmp31_ast_in = _t
          match(_t, FRAGMENT)
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rule_scope_spec(_t)
      rule_scope_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t59 = _t
        tmp32_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ACTION
          tmp33_ast_in = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
        when 3, ID
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ID)))
            tmp34_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        _t = __t59
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def block(_t)
      block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t64 = _t
        tmp35_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          options_spec(_t)
          _t = self.attr__ret_tree
        when ALT
        else
          raise NoViableAltException.new(_t)
        end
        _cnt67 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            alternative(_t)
            _t = self.attr__ret_tree
            rewrite(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt67 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt67 += 1
        end while (true)
        tmp36_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t64
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def exception_group(_t)
      exception_group_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_catch
          _cnt74 = 0
          begin
            if ((_t).nil?)
              _t = ASTNULL
            end
            if (((_t.get_type).equal?(LITERAL_catch)))
              exception_handler(_t)
              _t = self.attr__ret_tree
            else
              if (_cnt74 >= 1)
                break
              else
                raise NoViableAltException.new(_t)
              end
            end
            _cnt74 += 1
          end while (true)
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when LITERAL_finally
            finally_clause(_t)
            _t = self.attr__ret_tree
          when EOR
          else
            raise NoViableAltException.new(_t)
          end
        when LITERAL_finally
          finally_clause(_t)
          _t = self.attr__ret_tree
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def alternative(_t)
      alternative_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t69 = _t
        tmp37_ast_in = _t
        match(_t, ALT)
        _t = _t.get_first_child
        _cnt71 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(BLOCK) || (_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(SYNPRED) || (_t.get_type).equal?(RANGE) || (_t.get_type).equal?(CHAR_RANGE) || (_t.get_type).equal?(EPSILON) || (_t.get_type).equal?(FORCED_ACTION) || (_t.get_type).equal?(GATED_SEMPRED) || (_t.get_type).equal?(SYN_SEMPRED) || (_t.get_type).equal?(BACKTRACK_SEMPRED) || (_t.get_type).equal?(DOT) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(BANG) || (_t.get_type).equal?(PLUS_ASSIGN) || (_t.get_type).equal?(SEMPRED) || (_t.get_type).equal?(ROOT) || (_t.get_type).equal?(WILDCARD) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(NOT) || (_t.get_type).equal?(TREE_BEGIN)))
            element(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt71 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt71 += 1
        end while (true)
        tmp38_ast_in = _t
        match(_t, EOA)
        _t = _t.get_next_sibling
        _t = __t69
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite(_t)
      rewrite_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(REWRITE)))
            __t82 = _t
            tmp39_ast_in = _t
            match(_t, REWRITE)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when SEMPRED
              tmp40_ast_in = _t
              match(_t, SEMPRED)
              _t = _t.get_next_sibling
            when ALT, TEMPLATE, ACTION, ETC
            else
              raise NoViableAltException.new(_t)
            end
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when ALT
              tmp41_ast_in = _t
              match(_t, ALT)
              _t = _t.get_next_sibling
            when TEMPLATE
              tmp42_ast_in = _t
              match(_t, TEMPLATE)
              _t = _t.get_next_sibling
            when ACTION
              tmp43_ast_in = _t
              match(_t, ACTION)
              _t = _t.get_next_sibling
            when ETC
              tmp44_ast_in = _t
              match(_t, ETC)
              _t = _t.get_next_sibling
            else
              raise NoViableAltException.new(_t)
            end
            _t = __t82
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def element(_t)
      element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ROOT
          __t87 = _t
          tmp45_ast_in = _t
          match(_t, ROOT)
          _t = _t.get_first_child
          element(_t)
          _t = self.attr__ret_tree
          _t = __t87
          _t = _t.get_next_sibling
        when BANG
          __t88 = _t
          tmp46_ast_in = _t
          match(_t, BANG)
          _t = _t.get_first_child
          element(_t)
          _t = self.attr__ret_tree
          _t = __t88
          _t = _t.get_next_sibling
        when DOT, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, WILDCARD, RULE_REF
          atom(_t)
          _t = self.attr__ret_tree
        when NOT
          __t89 = _t
          tmp47_ast_in = _t
          match(_t, NOT)
          _t = _t.get_first_child
          element(_t)
          _t = self.attr__ret_tree
          _t = __t89
          _t = _t.get_next_sibling
        when RANGE
          __t90 = _t
          tmp48_ast_in = _t
          match(_t, RANGE)
          _t = _t.get_first_child
          atom(_t)
          _t = self.attr__ret_tree
          atom(_t)
          _t = self.attr__ret_tree
          _t = __t90
          _t = _t.get_next_sibling
        when CHAR_RANGE
          __t91 = _t
          tmp49_ast_in = _t
          match(_t, CHAR_RANGE)
          _t = _t.get_first_child
          atom(_t)
          _t = self.attr__ret_tree
          atom(_t)
          _t = self.attr__ret_tree
          _t = __t91
          _t = _t.get_next_sibling
        when ASSIGN
          __t92 = _t
          tmp50_ast_in = _t
          match(_t, ASSIGN)
          _t = _t.get_first_child
          tmp51_ast_in = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          element(_t)
          _t = self.attr__ret_tree
          _t = __t92
          _t = _t.get_next_sibling
        when PLUS_ASSIGN
          __t93 = _t
          tmp52_ast_in = _t
          match(_t, PLUS_ASSIGN)
          _t = _t.get_first_child
          tmp53_ast_in = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          element(_t)
          _t = self.attr__ret_tree
          _t = __t93
          _t = _t.get_next_sibling
        when BLOCK, OPTIONAL, CLOSURE, POSITIVE_CLOSURE
          ebnf(_t)
          _t = self.attr__ret_tree
        when TREE_BEGIN
          tree(_t)
          _t = self.attr__ret_tree
        when SYNPRED
          __t94 = _t
          tmp54_ast_in = _t
          match(_t, SYNPRED)
          _t = _t.get_first_child
          block(_t)
          _t = self.attr__ret_tree
          _t = __t94
          _t = _t.get_next_sibling
        when FORCED_ACTION
          tmp55_ast_in = _t
          match(_t, FORCED_ACTION)
          _t = _t.get_next_sibling
        when ACTION
          tmp56_ast_in = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
        when SEMPRED
          tmp57_ast_in = _t
          match(_t, SEMPRED)
          _t = _t.get_next_sibling
        when SYN_SEMPRED
          tmp58_ast_in = _t
          match(_t, SYN_SEMPRED)
          _t = _t.get_next_sibling
        when BACKTRACK_SEMPRED
          tmp59_ast_in = _t
          match(_t, BACKTRACK_SEMPRED)
          _t = _t.get_next_sibling
        when GATED_SEMPRED
          tmp60_ast_in = _t
          match(_t, GATED_SEMPRED)
          _t = _t.get_next_sibling
        when EPSILON
          tmp61_ast_in = _t
          match(_t, EPSILON)
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def exception_handler(_t)
      exception_handler_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t77 = _t
        tmp62_ast_in = _t
        match(_t, LITERAL_catch)
        _t = _t.get_first_child
        tmp63_ast_in = _t
        match(_t, ARG_ACTION)
        _t = _t.get_next_sibling
        tmp64_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t77
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def finally_clause(_t)
      finally_clause_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t79 = _t
        tmp65_ast_in = _t
        match(_t, LITERAL_finally)
        _t = _t.get_first_child
        tmp66_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t79
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def atom(_t)
      atom_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      rr = nil
      rarg = nil
      t = nil
      targ = nil
      c = nil
      s = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when RULE_REF
          __t104 = _t
          rr = (_t).equal?(ASTNULL) ? nil : _t
          match(_t, RULE_REF)
          _t = _t.get_first_child
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when ARG_ACTION
            rarg = _t
            match(_t, ARG_ACTION)
            _t = _t.get_next_sibling
          when 3
          else
            raise NoViableAltException.new(_t)
          end
          _t = __t104
          _t = _t.get_next_sibling
        when TOKEN_REF
          __t106 = _t
          t = (_t).equal?(ASTNULL) ? nil : _t
          match(_t, TOKEN_REF)
          _t = _t.get_first_child
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when ARG_ACTION
            targ = _t
            match(_t, ARG_ACTION)
            _t = _t.get_next_sibling
          when 3
          else
            raise NoViableAltException.new(_t)
          end
          _t = __t106
          _t = _t.get_next_sibling
          track_token(t)
        when CHAR_LITERAL
          c = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          track_string(c)
        when STRING_LITERAL
          s = _t
          match(_t, STRING_LITERAL)
          _t = _t.get_next_sibling
          track_string(s)
        when WILDCARD
          tmp67_ast_in = _t
          match(_t, WILDCARD)
          _t = _t.get_next_sibling
        when DOT
          __t108 = _t
          tmp68_ast_in = _t
          match(_t, DOT)
          _t = _t.get_first_child
          tmp69_ast_in = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          atom(_t)
          _t = self.attr__ret_tree
          _t = __t108
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def ebnf(_t)
      ebnf_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when BLOCK
          block(_t)
          _t = self.attr__ret_tree
        when OPTIONAL
          __t96 = _t
          tmp70_ast_in = _t
          match(_t, OPTIONAL)
          _t = _t.get_first_child
          block(_t)
          _t = self.attr__ret_tree
          _t = __t96
          _t = _t.get_next_sibling
        when CLOSURE
          __t97 = _t
          tmp71_ast_in = _t
          match(_t, CLOSURE)
          _t = _t.get_first_child
          block(_t)
          _t = self.attr__ret_tree
          _t = __t97
          _t = _t.get_next_sibling
        when POSITIVE_CLOSURE
          __t98 = _t
          tmp72_ast_in = _t
          match(_t, POSITIVE_CLOSURE)
          _t = _t.get_first_child
          block(_t)
          _t = self.attr__ret_tree
          _t = __t98
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def tree(_t)
      tree_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t100 = _t
        tmp73_ast_in = _t
        match(_t, TREE_BEGIN)
        _t = _t.get_first_child
        element(_t)
        _t = self.attr__ret_tree
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(BLOCK) || (_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(SYNPRED) || (_t.get_type).equal?(RANGE) || (_t.get_type).equal?(CHAR_RANGE) || (_t.get_type).equal?(EPSILON) || (_t.get_type).equal?(FORCED_ACTION) || (_t.get_type).equal?(GATED_SEMPRED) || (_t.get_type).equal?(SYN_SEMPRED) || (_t.get_type).equal?(BACKTRACK_SEMPRED) || (_t.get_type).equal?(DOT) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(BANG) || (_t.get_type).equal?(PLUS_ASSIGN) || (_t.get_type).equal?(SEMPRED) || (_t.get_type).equal?(ROOT) || (_t.get_type).equal?(WILDCARD) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(NOT) || (_t.get_type).equal?(TREE_BEGIN)))
            element(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        _t = __t100
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def ast_suffix(_t)
      ast_suffix_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ROOT
          tmp74_ast_in = _t
          match(_t, ROOT)
          _t = _t.get_next_sibling
        when BANG
          tmp75_ast_in = _t
          match(_t, BANG)
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    class_module.module_eval {
      const_set_lazy(:_tokenNames) { Array.typed(String).new(["<0>", "EOF", "<2>", "NULL_TREE_LOOKAHEAD", "\"options\"", "\"tokens\"", "\"parser\"", "LEXER", "RULE", "BLOCK", "OPTIONAL", "CLOSURE", "POSITIVE_CLOSURE", "SYNPRED", "RANGE", "CHAR_RANGE", "EPSILON", "ALT", "EOR", "EOB", "EOA", "ID", "ARG", "ARGLIST", "RET", "LEXER_GRAMMAR", "PARSER_GRAMMAR", "TREE_GRAMMAR", "COMBINED_GRAMMAR", "INITACTION", "FORCED_ACTION", "LABEL", "TEMPLATE", "\"scope\"", "\"import\"", "GATED_SEMPRED", "SYN_SEMPRED", "BACKTRACK_SEMPRED", "\"fragment\"", "DOT", "ACTION", "DOC_COMMENT", "SEMI", "\"lexer\"", "\"tree\"", "\"grammar\"", "AMPERSAND", "COLON", "RCURLY", "ASSIGN", "STRING_LITERAL", "CHAR_LITERAL", "INT", "STAR", "COMMA", "TOKEN_REF", "\"protected\"", "\"public\"", "\"private\"", "BANG", "ARG_ACTION", "\"returns\"", "\"throws\"", "LPAREN", "OR", "RPAREN", "\"catch\"", "\"finally\"", "PLUS_ASSIGN", "SEMPRED", "IMPLIES", "ROOT", "WILDCARD", "RULE_REF", "NOT", "TREE_BEGIN", "QUESTION", "PLUS", "OPEN_ELEMENT_OPTION", "CLOSE_ELEMENT_OPTION", "REWRITE", "ETC", "DOLLAR", "DOUBLE_QUOTE_STRING_LITERAL", "DOUBLE_ANGLE_STRING_LITERAL", "WS", "COMMENT", "SL_COMMENT", "ML_COMMENT", "STRAY_BRACKET", "ESC", "DIGIT", "XDIGIT", "NESTED_ARG_ACTION", "NESTED_ACTION", "ACTION_CHAR_LITERAL", "ACTION_STRING_LITERAL", "ACTION_ESC", "WS_LOOP", "INTERNAL_RULE_REF", "WS_OPT", "SRC", "CHARSET"]) }
      const_attr_reader  :_tokenNames
    }
    
    private
    alias_method :initialize__assign_token_types_walker, :initialize
  end
  
end
