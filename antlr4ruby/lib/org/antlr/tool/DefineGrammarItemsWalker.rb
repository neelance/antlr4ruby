require "rjava"
 # $ANTLR 2.7.7 (2006-01-29): "define.g" -> "DefineGrammarItemsWalker.java"$
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
module Org::Antlr::Tool
  module DefineGrammarItemsWalkerImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Java::Util
      include ::Org::Antlr::Misc
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
  
  class DefineGrammarItemsWalker < Antlr::TreeParser
    include_class_members DefineGrammarItemsWalkerImports
    overload_protected {
      include DefineGrammarItemsWalkerTokenTypes
    }
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :root
    alias_method :attr_root, :root
    undef_method :root
    alias_method :attr_root=, :root=
    undef_method :root=
    
    attr_accessor :current_rule_name
    alias_method :attr_current_rule_name, :current_rule_name
    undef_method :current_rule_name
    alias_method :attr_current_rule_name=, :current_rule_name=
    undef_method :current_rule_name=
    
    attr_accessor :current_rewrite_block
    alias_method :attr_current_rewrite_block, :current_rewrite_block
    undef_method :current_rewrite_block
    alias_method :attr_current_rewrite_block=, :current_rewrite_block=
    undef_method :current_rewrite_block=
    
    attr_accessor :current_rewrite_rule
    alias_method :attr_current_rewrite_rule, :current_rewrite_rule
    undef_method :current_rewrite_rule
    alias_method :attr_current_rewrite_rule=, :current_rewrite_rule=
    undef_method :current_rewrite_rule=
    
    attr_accessor :outer_alt_num
    alias_method :attr_outer_alt_num, :outer_alt_num
    undef_method :outer_alt_num
    alias_method :attr_outer_alt_num=, :outer_alt_num=
    undef_method :outer_alt_num=
    
    attr_accessor :block_level
    alias_method :attr_block_level, :block_level
    undef_method :block_level
    alias_method :attr_block_level=, :block_level=
    undef_method :block_level=
    
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
      ErrorManager.syntax_error(ErrorManager::MSG_SYNTAX_ERROR, @grammar, token, "define: " + RJava.cast_to_string(ex.to_s), ex)
    end
    
    typesig { [] }
    def finish
      trim_grammar
    end
    
    typesig { [] }
    # Remove any lexer rules from a COMBINED; already passed to lexer
    def trim_grammar
      if (!(@grammar.attr_type).equal?(Grammar::COMBINED))
        return
      end
      # form is (header ... ) ( grammar ID (scope ...) ... ( rule ... ) ( rule ... ) ... )
      p = @root
      # find the grammar spec
      while (!(p.get_text == "grammar"))
        p = p.get_next_sibling
      end
      p = p.get_first_child # jump down to first child of grammar
      # look for first RULE def
      prev = p # points to the ID (grammar name)
      while (!(p.get_type).equal?(RULE))
        prev = p
        p = p.get_next_sibling
      end
      # prev points at last node before first rule subtree at this point
      while (!(p).nil?)
        rule_name = p.get_first_child.get_text
        # System.out.println("rule "+ruleName+" prev="+prev.getText());
        if (Character.is_upper_case(rule_name.char_at(0)))
          # remove lexer rule
          prev.set_next_sibling(p.get_next_sibling)
        else
          prev = p # non-lexer rule; move on
        end
        p = p.get_next_sibling
      end
      # System.out.println("root after removal is: "+root.toStringList());
    end
    
    typesig { [GrammarAST] }
    def track_inline_action(action_ast)
      r = @grammar.get_rule(@current_rule_name)
      if (!(r).nil?)
        r.track_inline_action(action_ast)
      end
    end
    
    typesig { [] }
    def initialize
      @grammar = nil
      @root = nil
      @current_rule_name = nil
      @current_rewrite_block = nil
      @current_rewrite_rule = nil
      @outer_alt_num = 0
      @block_level = 0
      super()
      @outer_alt_num = 0
      @block_level = 0
      self.attr_token_names = _tokenNames
    end
    
    typesig { [AST, Grammar] }
    def grammar(_t, g)
      grammar_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      @grammar = g
      @root = grammar_ast_in
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
          if ((self.attr_input_state.attr_guessing).equal?(0))
            @grammar.attr_type = Grammar::LEXER
          end
          grammar_spec(_t)
          _t = self.attr__ret_tree
          _t = __t3
          _t = _t.get_next_sibling
        when PARSER_GRAMMAR
          __t4 = _t
          tmp2_ast_in = _t
          match(_t, PARSER_GRAMMAR)
          _t = _t.get_first_child
          if ((self.attr_input_state.attr_guessing).equal?(0))
            @grammar.attr_type = Grammar::PARSER
          end
          grammar_spec(_t)
          _t = self.attr__ret_tree
          _t = __t4
          _t = _t.get_next_sibling
        when TREE_GRAMMAR
          __t5 = _t
          tmp3_ast_in = _t
          match(_t, TREE_GRAMMAR)
          _t = _t.get_first_child
          if ((self.attr_input_state.attr_guessing).equal?(0))
            @grammar.attr_type = Grammar::TREE_PARSER
          end
          grammar_spec(_t)
          _t = self.attr__ret_tree
          _t = __t5
          _t = _t.get_next_sibling
        when COMBINED_GRAMMAR
          __t6 = _t
          tmp4_ast_in = _t
          match(_t, COMBINED_GRAMMAR)
          _t = _t.get_first_child
          if ((self.attr_input_state.attr_guessing).equal?(0))
            @grammar.attr_type = Grammar::COMBINED
          end
          grammar_spec(_t)
          _t = self.attr__ret_tree
          _t = __t6
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
        if ((self.attr_input_state.attr_guessing).equal?(0))
          finish
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
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
      options_start_token = nil
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
          if ((self.attr_input_state.attr_guessing).equal?(0))
            options_start_token = (_t).get_token
          end
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
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when AMPERSAND
          actions(_t)
          _t = self.attr__ret_tree
        when RULE
        else
          raise NoViableAltException.new(_t)
        end
        rules(_t)
        _t = self.attr__ret_tree
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def attr_scope(_t)
      attr_scope_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      name = nil
      attrs = nil
      begin
        # for error handling
        __t8 = _t
        tmp5_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        name = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        attrs = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t8
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          scope = @grammar.define_global_scope(name.get_text, attrs.attr_token)
          scope.attr_is_dynamic_global_scope = true
          scope.add_attributes(attrs.get_text, Character.new(?;.ord))
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def options_spec(_t)
      options_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        tmp6_ast_in = _t
        match(_t, OPTIONS)
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def delegate_grammars(_t)
      delegate_grammars_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t25 = _t
        tmp7_ast_in = _t
        match(_t, IMPORT)
        _t = _t.get_first_child
        _cnt28 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when ASSIGN
            __t27 = _t
            tmp8_ast_in = _t
            match(_t, ASSIGN)
            _t = _t.get_first_child
            tmp9_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            tmp10_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            _t = __t27
            _t = _t.get_next_sibling
          when ID
            tmp11_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
          else
            if (_cnt28 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt28 += 1
        end while (true)
        _t = __t25
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def tokens_spec(_t)
      tokens_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t30 = _t
        tmp12_ast_in = _t
        match(_t, TOKENS)
        _t = _t.get_first_child
        _cnt32 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(TOKEN_REF)))
            token_spec(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt32 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt32 += 1
        end while (true)
        _t = __t30
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def actions(_t)
      actions_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        _cnt19 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            action(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt19 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt19 += 1
        end while (true)
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rules(_t)
      rules_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        _cnt38 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(RULE)))
            rule(_t)
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
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def action(_t)
      action_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      amp = nil
      id1 = nil
      id2 = nil
      a1 = nil
      a2 = nil
      scope = nil
      name_ast = nil
      action_ast = nil
      begin
        # for error handling
        __t21 = _t
        amp = (_t).equal?(ASTNULL) ? nil : _t
        match(_t, AMPERSAND)
        _t = _t.get_first_child
        id1 = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ID
          id2 = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          a1 = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            scope = RJava.cast_to_string(id1.get_text)
            name_ast = id2
            action_ast = a1
          end
        when ACTION
          a2 = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            scope = RJava.cast_to_string(nil)
            name_ast = id1
            action_ast = a2
          end
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t21
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          @grammar.define_named_action(amp, scope, name_ast, action_ast)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
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
        when ASSIGN
          __t34 = _t
          tmp13_ast_in = _t
          match(_t, ASSIGN)
          _t = _t.get_first_child
          t2 = _t
          match(_t, TOKEN_REF)
          _t = _t.get_next_sibling
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when STRING_LITERAL
            s = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_next_sibling
          when CHAR_LITERAL
            c = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
          else
            raise NoViableAltException.new(_t)
          end
          _t = __t34
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rule(_t)
      rule_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      args = nil
      ret = nil
      b = nil
      mod = nil
      name = nil
      opts = nil
      r = nil
      begin
        # for error handling
        __t40 = _t
        tmp14_ast_in = _t
        match(_t, RULE)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          opts = tmp14_ast_in.attr_block_options
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when FRAGMENT, LITERAL_protected, LITERAL_public, LITERAL_private
          mod = RJava.cast_to_string(modifier(_t))
          _t = self.attr__ret_tree
        when ARG
        else
          raise NoViableAltException.new(_t)
        end
        __t42 = _t
        tmp15_ast_in = _t
        match(_t, ARG)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ARG_ACTION
          args = _t
          match(_t, ARG_ACTION)
          _t = _t.get_next_sibling
        when 3
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t42
        _t = _t.get_next_sibling
        __t44 = _t
        tmp16_ast_in = _t
        match(_t, RET)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ARG_ACTION
          ret = _t
          match(_t, ARG_ACTION)
          _t = _t.get_next_sibling
        when 3
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t44
        _t = _t.get_next_sibling
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
        if ((self.attr_input_state.attr_guessing).equal?(0))
          name = RJava.cast_to_string(id.get_text)
          @current_rule_name = name
          if (Character.is_upper_case(name.char_at(0)) && (@grammar.attr_type).equal?(Grammar::COMBINED))
            # a merged grammar spec, track lexer rules and send to another grammar
            @grammar.define_lexer_rule_found_in_parser(id.get_token, rule_ast_in)
          else
            num_alts = count_alts_for_rule(rule_ast_in)
            @grammar.define_rule(id.get_token, mod, opts, rule_ast_in, args, num_alts)
            r = @grammar.get_rule(name)
            if (!(args).nil?)
              r.attr_parameter_scope = @grammar.create_parameter_scope(name, args.attr_token)
              r.attr_parameter_scope.add_attributes(args.get_text, Character.new(?,.ord))
            end
            if (!(ret).nil?)
              r.attr_return_scope = @grammar.create_return_scope(name, ret.attr_token)
              r.attr_return_scope.add_attributes(ret.get_text, Character.new(?,.ord))
            end
          end
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when SCOPE
          rule_scope_spec(_t, r)
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
            rule_action(_t, r)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        if ((self.attr_input_state.attr_guessing).equal?(0))
          @block_level = 0
        end
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
        tmp17_ast_in = _t
        match(_t, EOR)
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          # copy rule options into the block AST, which is where
          # the analysis will look for k option etc...
          b.attr_block_options = opts
        end
        _t = __t40
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def modifier(_t)
      mod = nil
      modifier_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      mod = RJava.cast_to_string(modifier_ast_in.get_text)
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_protected
          tmp18_ast_in = _t
          match(_t, LITERAL_protected)
          _t = _t.get_next_sibling
        when LITERAL_public
          tmp19_ast_in = _t
          match(_t, LITERAL_public)
          _t = _t.get_next_sibling
        when LITERAL_private
          tmp20_ast_in = _t
          match(_t, LITERAL_private)
          _t = _t.get_next_sibling
        when FRAGMENT
          tmp21_ast_in = _t
          match(_t, FRAGMENT)
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
      return mod
    end
    
    typesig { [AST, Rule] }
    def rule_scope_spec(_t, r)
      rule_scope_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      attrs = nil
      uses = nil
      begin
        # for error handling
        __t69 = _t
        tmp22_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ACTION
          attrs = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            r.attr_rule_scope = @grammar.create_rule_scope(r.attr_name, attrs.attr_token)
            r.attr_rule_scope.attr_is_dynamic_rule_scope = true
            r.attr_rule_scope.add_attributes(attrs.get_text, Character.new(?;.ord))
          end
        when 3, ID
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ID)))
            uses = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            if ((self.attr_input_state.attr_guessing).equal?(0))
              if ((@grammar.get_global_scope(uses.get_text)).nil?)
                ErrorManager.grammar_error(ErrorManager::MSG_UNKNOWN_DYNAMIC_SCOPE, @grammar, uses.attr_token, uses.get_text)
              else
                if ((r.attr_use_scopes).nil?)
                  r.attr_use_scopes = ArrayList.new
                end
                r.attr_use_scopes.add(uses.get_text)
              end
            end
          else
            break
          end
        end while (true)
        _t = __t69
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, Rule] }
    def rule_action(_t, r)
      rule_action_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      amp = nil
      id = nil
      a = nil
      begin
        # for error handling
        __t66 = _t
        amp = (_t).equal?(ASTNULL) ? nil : _t
        match(_t, AMPERSAND)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        a = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t66
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          if (!(r).nil?)
            r.define_named_action(amp, id, a)
          end
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def block(_t)
      block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      @block_level += 1
      if ((@block_level).equal?(1))
        @outer_alt_num = 1
      end
      begin
        # for error handling
        __t74 = _t
        tmp23_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          options_spec(_t)
          _t = self.attr__ret_tree
        when ALT, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            block_action(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        _cnt79 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            alternative(_t)
            _t = self.attr__ret_tree
            rewrite(_t)
            _t = self.attr__ret_tree
            if ((self.attr_input_state.attr_guessing).equal?(0))
              if ((@block_level).equal?(1))
                @outer_alt_num += 1
              end
            end
          else
            if (_cnt79 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt79 += 1
        end while (true)
        tmp24_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t74
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          @block_level -= 1
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
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
          _cnt88 = 0
          begin
            if ((_t).nil?)
              _t = ASTNULL
            end
            if (((_t.get_type).equal?(LITERAL_catch)))
              exception_handler(_t)
              _t = self.attr__ret_tree
            else
              if (_cnt88 >= 1)
                break
              else
                raise NoViableAltException.new(_t)
              end
            end
            _cnt88 += 1
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
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def count_alts_for_rule(_t)
      n = 0
      count_alts_for_rule_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      begin
        # for error handling
        __t52 = _t
        tmp25_ast_in = _t
        match(_t, RULE)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when FRAGMENT, LITERAL_protected, LITERAL_public, LITERAL_private
          modifier(_t)
          _t = self.attr__ret_tree
        when ARG
        else
          raise NoViableAltException.new(_t)
        end
        tmp26_ast_in = _t
        match(_t, ARG)
        _t = _t.get_next_sibling
        tmp27_ast_in = _t
        match(_t, RET)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          tmp28_ast_in = _t
          match(_t, OPTIONS)
          _t = _t.get_next_sibling
        when BLOCK, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when SCOPE
          tmp29_ast_in = _t
          match(_t, SCOPE)
          _t = _t.get_next_sibling
        when BLOCK, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            tmp30_ast_in = _t
            match(_t, AMPERSAND)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        __t58 = _t
        tmp31_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          tmp32_ast_in = _t
          match(_t, OPTIONS)
          _t = _t.get_next_sibling
        when ALT
        else
          raise NoViableAltException.new(_t)
        end
        _cnt63 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            tmp33_ast_in = _t
            match(_t, ALT)
            _t = _t.get_next_sibling
            begin
              if ((_t).nil?)
                _t = ASTNULL
              end
              if (((_t.get_type).equal?(REWRITE)))
                tmp34_ast_in = _t
                match(_t, REWRITE)
                _t = _t.get_next_sibling
              else
                break
              end
            end while (true)
            if ((self.attr_input_state.attr_guessing).equal?(0))
              n += 1
            end
          else
            if (_cnt63 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt63 += 1
        end while (true)
        tmp35_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t58
        _t = _t.get_next_sibling
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
        tmp36_ast_in = _t
        match(_t, EOR)
        _t = _t.get_next_sibling
        _t = __t52
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
      return n
    end
    
    typesig { [AST] }
    def block_action(_t)
      block_action_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      amp = nil
      id = nil
      a = nil
      begin
        # for error handling
        __t81 = _t
        amp = (_t).equal?(ASTNULL) ? nil : _t
        match(_t, AMPERSAND)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        a = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t81
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def alternative(_t)
      alternative_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      if (!(@grammar.attr_type).equal?(Grammar::LEXER) && !(@grammar.get_option("output")).nil? && (@block_level).equal?(1))
        a_rewrite_node = alternative_ast_in.find_first_type(REWRITE) # alt itself has rewrite?
        rewrite_ast = alternative_ast_in.get_next_sibling
        # we have a rewrite if alt uses it inside subrule or this alt has one
        # but don't count -> ... rewrites, which mean "do default auto construction"
        if (!(a_rewrite_node).nil? || (!(rewrite_ast).nil? && (rewrite_ast.get_type).equal?(REWRITE) && !(rewrite_ast.get_first_child).nil? && !(rewrite_ast.get_first_child.get_type).equal?(ETC)))
          r = @grammar.get_rule(@current_rule_name)
          r.track_alts_with_rewrites(alternative_ast_in, @outer_alt_num)
        end
      end
      begin
        # for error handling
        __t83 = _t
        tmp37_ast_in = _t
        match(_t, ALT)
        _t = _t.get_first_child
        _cnt85 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(BLOCK) || (_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(SYNPRED) || (_t.get_type).equal?(RANGE) || (_t.get_type).equal?(CHAR_RANGE) || (_t.get_type).equal?(EPSILON) || (_t.get_type).equal?(FORCED_ACTION) || (_t.get_type).equal?(GATED_SEMPRED) || (_t.get_type).equal?(SYN_SEMPRED) || (_t.get_type).equal?(BACKTRACK_SEMPRED) || (_t.get_type).equal?(DOT) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(BANG) || (_t.get_type).equal?(PLUS_ASSIGN) || (_t.get_type).equal?(SEMPRED) || (_t.get_type).equal?(ROOT) || (_t.get_type).equal?(WILDCARD) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(NOT) || (_t.get_type).equal?(TREE_BEGIN)))
            element(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt85 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt85 += 1
        end while (true)
        tmp38_ast_in = _t
        match(_t, EOA)
        _t = _t.get_next_sibling
        _t = __t83
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite(_t)
      rewrite_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      pred = nil
      @current_rewrite_rule = rewrite_ast_in # has to execute during guessing
      if (@grammar.build_ast)
        rewrite_ast_in.attr_rewrite_refs_deep = HashSet.new
      end
      begin
        # for error handling
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(REWRITE)))
            __t129 = _t
            tmp39_ast_in = _t
            match(_t, REWRITE)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when SEMPRED
              pred = _t
              match(_t, SEMPRED)
              _t = _t.get_next_sibling
            when ALT, TEMPLATE, ACTION, ETC
            else
              raise NoViableAltException.new(_t)
            end
            rewrite_alternative(_t)
            _t = self.attr__ret_tree
            _t = __t129
            _t = _t.get_next_sibling
            if ((self.attr_input_state.attr_guessing).equal?(0))
              if (!(pred).nil?)
                pred.attr_outer_alt_num = @outer_alt_num
                track_inline_action(pred)
              end
            end
          else
            break
          end
        end while (true)
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def element(_t)
      element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      el = nil
      id2 = nil
      a2 = nil
      act = nil
      act2 = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ROOT
          __t95 = _t
          tmp40_ast_in = _t
          match(_t, ROOT)
          _t = _t.get_first_child
          element(_t)
          _t = self.attr__ret_tree
          _t = __t95
          _t = _t.get_next_sibling
        when BANG
          __t96 = _t
          tmp41_ast_in = _t
          match(_t, BANG)
          _t = _t.get_first_child
          element(_t)
          _t = self.attr__ret_tree
          _t = __t96
          _t = _t.get_next_sibling
        when DOT, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, WILDCARD, RULE_REF
          atom(_t, nil)
          _t = self.attr__ret_tree
        when NOT
          __t97 = _t
          tmp42_ast_in = _t
          match(_t, NOT)
          _t = _t.get_first_child
          element(_t)
          _t = self.attr__ret_tree
          _t = __t97
          _t = _t.get_next_sibling
        when RANGE
          __t98 = _t
          tmp43_ast_in = _t
          match(_t, RANGE)
          _t = _t.get_first_child
          atom(_t, nil)
          _t = self.attr__ret_tree
          atom(_t, nil)
          _t = self.attr__ret_tree
          _t = __t98
          _t = _t.get_next_sibling
        when CHAR_RANGE
          __t99 = _t
          tmp44_ast_in = _t
          match(_t, CHAR_RANGE)
          _t = _t.get_first_child
          atom(_t, nil)
          _t = self.attr__ret_tree
          atom(_t, nil)
          _t = self.attr__ret_tree
          _t = __t99
          _t = _t.get_next_sibling
        when ASSIGN
          __t100 = _t
          tmp45_ast_in = _t
          match(_t, ASSIGN)
          _t = _t.get_first_child
          id = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          el = (_t).equal?(ASTNULL) ? nil : _t
          element(_t)
          _t = self.attr__ret_tree
          _t = __t100
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            if ((el.get_type).equal?(ANTLRParser::ROOT) || (el.get_type).equal?(ANTLRParser::BANG))
              el = el.get_first_child
            end
            if ((el.get_type).equal?(RULE_REF))
              @grammar.define_rule_ref_label(@current_rule_name, id.get_token, el)
            else
              @grammar.define_token_ref_label(@current_rule_name, id.get_token, el)
            end
          end
        when PLUS_ASSIGN
          __t101 = _t
          tmp46_ast_in = _t
          match(_t, PLUS_ASSIGN)
          _t = _t.get_first_child
          id2 = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          a2 = (_t).equal?(ASTNULL) ? nil : _t
          element(_t)
          _t = self.attr__ret_tree
          if ((self.attr_input_state.attr_guessing).equal?(0))
            if ((a2.get_type).equal?(ANTLRParser::ROOT) || (a2.get_type).equal?(ANTLRParser::BANG))
              a2 = a2.get_first_child
            end
            if ((a2.get_type).equal?(RULE_REF))
              @grammar.define_rule_list_label(@current_rule_name, id2.get_token, a2)
            else
              @grammar.define_token_list_label(@current_rule_name, id2.get_token, a2)
            end
          end
          _t = __t101
          _t = _t.get_next_sibling
        when BLOCK, OPTIONAL, CLOSURE, POSITIVE_CLOSURE
          ebnf(_t)
          _t = self.attr__ret_tree
        when TREE_BEGIN
          tree(_t)
          _t = self.attr__ret_tree
        when SYNPRED
          __t102 = _t
          tmp47_ast_in = _t
          match(_t, SYNPRED)
          _t = _t.get_first_child
          block(_t)
          _t = self.attr__ret_tree
          _t = __t102
          _t = _t.get_next_sibling
        when ACTION
          act = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            act.attr_outer_alt_num = @outer_alt_num
            track_inline_action(act)
          end
        when FORCED_ACTION
          act2 = _t
          match(_t, FORCED_ACTION)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            act2.attr_outer_alt_num = @outer_alt_num
            track_inline_action(act2)
          end
        when SEMPRED
          tmp48_ast_in = _t
          match(_t, SEMPRED)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            tmp48_ast_in.attr_outer_alt_num = @outer_alt_num
            track_inline_action(tmp48_ast_in)
          end
        when SYN_SEMPRED
          tmp49_ast_in = _t
          match(_t, SYN_SEMPRED)
          _t = _t.get_next_sibling
        when BACKTRACK_SEMPRED
          tmp50_ast_in = _t
          match(_t, BACKTRACK_SEMPRED)
          _t = _t.get_next_sibling
        when GATED_SEMPRED
          tmp51_ast_in = _t
          match(_t, GATED_SEMPRED)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            tmp51_ast_in.attr_outer_alt_num = @outer_alt_num
            track_inline_action(tmp51_ast_in)
          end
        when EPSILON
          tmp52_ast_in = _t
          match(_t, EPSILON)
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def exception_handler(_t)
      exception_handler_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t91 = _t
        tmp53_ast_in = _t
        match(_t, LITERAL_catch)
        _t = _t.get_first_child
        tmp54_ast_in = _t
        match(_t, ARG_ACTION)
        _t = _t.get_next_sibling
        tmp55_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t91
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          track_inline_action(tmp55_ast_in)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def finally_clause(_t)
      finally_clause_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t93 = _t
        tmp56_ast_in = _t
        match(_t, LITERAL_finally)
        _t = _t.get_first_child
        tmp57_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t93
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          track_inline_action(tmp57_ast_in)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, GrammarAST] }
    def atom(_t, scope)
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
          __t121 = _t
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
          _t = __t121
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            @grammar.alt_references_rule(@current_rule_name, scope, rr, @outer_alt_num)
            if (!(rarg).nil?)
              rarg.attr_outer_alt_num = @outer_alt_num
              track_inline_action(rarg)
            end
          end
        when TOKEN_REF
          __t123 = _t
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
          _t = __t123
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            if (!(targ).nil?)
              targ.attr_outer_alt_num = @outer_alt_num
              track_inline_action(targ)
            end
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              @grammar.alt_references_rule(@current_rule_name, scope, t, @outer_alt_num)
            else
              @grammar.alt_references_token_id(@current_rule_name, t, @outer_alt_num)
            end
          end
        when CHAR_LITERAL
          c = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            if (!(@grammar.attr_type).equal?(Grammar::LEXER))
              rule_ = @grammar.get_rule(@current_rule_name)
              if (!(rule_).nil?)
                rule_.track_token_reference_in_alt(c, @outer_alt_num)
              end
            end
          end
        when STRING_LITERAL
          s = _t
          match(_t, STRING_LITERAL)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            if (!(@grammar.attr_type).equal?(Grammar::LEXER))
              rule_ = @grammar.get_rule(@current_rule_name)
              if (!(rule_).nil?)
                rule_.track_token_reference_in_alt(s, @outer_alt_num)
              end
            end
          end
        when WILDCARD
          tmp58_ast_in = _t
          match(_t, WILDCARD)
          _t = _t.get_next_sibling
        when DOT
          __t125 = _t
          tmp59_ast_in = _t
          match(_t, DOT)
          _t = _t.get_first_child
          tmp60_ast_in = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          atom(_t, tmp60_ast_in)
          _t = self.attr__ret_tree
          _t = __t125
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
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
          __t106 = _t
          tmp61_ast_in = _t
          match(_t, OPTIONAL)
          _t = _t.get_first_child
          block(_t)
          _t = self.attr__ret_tree
          _t = __t106
          _t = _t.get_next_sibling
        else
          syn_pred_matched105 = false
          if ((_t).nil?)
            _t = ASTNULL
          end
          if ((((_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE))))
            __t105 = _t
            syn_pred_matched105 = true
            self.attr_input_state.attr_guessing += 1
            begin
              dot_loop(_t)
              _t = self.attr__ret_tree
            rescue RecognitionException => pe
              syn_pred_matched105 = false
            end
            _t = __t105
            self.attr_input_state.attr_guessing -= 1
          end
          if (syn_pred_matched105)
            dot_loop(_t)
            _t = self.attr__ret_tree
          else
            if (((_t.get_type).equal?(CLOSURE)))
              __t107 = _t
              tmp62_ast_in = _t
              match(_t, CLOSURE)
              _t = _t.get_first_child
              block(_t)
              _t = self.attr__ret_tree
              _t = __t107
              _t = _t.get_next_sibling
            else
              if (((_t.get_type).equal?(POSITIVE_CLOSURE)))
                __t108 = _t
                tmp63_ast_in = _t
                match(_t, POSITIVE_CLOSURE)
                _t = _t.get_first_child
                block(_t)
                _t = self.attr__ret_tree
                _t = __t108
                _t = _t.get_next_sibling
              else
                raise NoViableAltException.new(_t)
              end
            end
          end
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def tree(_t)
      tree_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t117 = _t
        tmp64_ast_in = _t
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
        _t = __t117
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    # Track the .* and .+ idioms and make them nongreedy by default.
    def dot_loop(_t)
      dot_loop_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      block_ = dot_loop_ast_in.get_first_child
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when CLOSURE
          __t111 = _t
          tmp65_ast_in = _t
          match(_t, CLOSURE)
          _t = _t.get_first_child
          dot_block(_t)
          _t = self.attr__ret_tree
          _t = __t111
          _t = _t.get_next_sibling
        when POSITIVE_CLOSURE
          __t112 = _t
          tmp66_ast_in = _t
          match(_t, POSITIVE_CLOSURE)
          _t = _t.get_first_child
          dot_block(_t)
          _t = self.attr__ret_tree
          _t = __t112
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
        if ((self.attr_input_state.attr_guessing).equal?(0))
          opts = HashMap.new
          opts.put("greedy", "false")
          if (!(@grammar.attr_type).equal?(Grammar::LEXER))
            # parser grammars assume k=1 for .* loops
            # otherwise they (analysis?) look til EOF!
            opts.put("k", Utils.integer(1))
          end
          block_.set_options(@grammar, opts)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def dot_block(_t)
      dot_block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t114 = _t
        tmp67_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        __t115 = _t
        tmp68_ast_in = _t
        match(_t, ALT)
        _t = _t.get_first_child
        tmp69_ast_in = _t
        match(_t, WILDCARD)
        _t = _t.get_next_sibling
        tmp70_ast_in = _t
        match(_t, EOA)
        _t = _t.get_next_sibling
        _t = __t115
        _t = _t.get_next_sibling
        tmp71_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t114
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
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
          tmp72_ast_in = _t
          match(_t, ROOT)
          _t = _t.get_next_sibling
        when BANG
          tmp73_ast_in = _t
          match(_t, BANG)
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite_alternative(_t)
      rewrite_alternative_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      a = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        if ((((_t.get_type).equal?(ALT))) && (@grammar.build_ast))
          __t135 = _t
          a = (_t).equal?(ASTNULL) ? nil : _t
          match(_t, ALT)
          _t = _t.get_first_child
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when OPTIONAL, CLOSURE, POSITIVE_CLOSURE, LABEL, ACTION, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, RULE_REF, TREE_BEGIN
            _cnt138 = 0
            begin
              if ((_t).nil?)
                _t = ASTNULL
              end
              if (((_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(LABEL) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(TREE_BEGIN)))
                rewrite_element(_t)
                _t = self.attr__ret_tree
              else
                if (_cnt138 >= 1)
                  break
                else
                  raise NoViableAltException.new(_t)
                end
              end
              _cnt138 += 1
            end while (true)
          when EPSILON
            tmp74_ast_in = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
          else
            raise NoViableAltException.new(_t)
          end
          tmp75_ast_in = _t
          match(_t, EOA)
          _t = _t.get_next_sibling
          _t = __t135
          _t = _t.get_next_sibling
        else
          if ((((_t.get_type).equal?(ALT) || (_t.get_type).equal?(TEMPLATE) || (_t.get_type).equal?(ACTION))) && (@grammar.build_template))
            rewrite_template(_t)
            _t = self.attr__ret_tree
          else
            if (((_t.get_type).equal?(ETC)))
              tmp76_ast_in = _t
              match(_t, ETC)
              _t = _t.get_next_sibling
              if (!((@block_level).equal?(1)))
                raise SemanticException.new("this.blockLevel==1")
              end
            else
              raise NoViableAltException.new(_t)
            end
          end
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite_block(_t)
      rewrite_block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      enclosing_block = @current_rewrite_block
      if ((self.attr_input_state.attr_guessing).equal?(0))
        # don't do if guessing
        @current_rewrite_block = rewrite_block_ast_in # pts to BLOCK node
        @current_rewrite_block.attr_rewrite_refs_shallow = HashSet.new
        @current_rewrite_block.attr_rewrite_refs_deep = HashSet.new
      end
      begin
        # for error handling
        __t133 = _t
        tmp77_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        rewrite_alternative(_t)
        _t = self.attr__ret_tree
        tmp78_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t133
        _t = _t.get_next_sibling
        if ((self.attr_input_state.attr_guessing).equal?(0))
          # copy the element refs in this block to the surrounding block
          if (!(enclosing_block).nil?)
            enclosing_block.attr_rewrite_refs_deep.add_all(@current_rewrite_block.attr_rewrite_refs_shallow)
          end
          @current_rewrite_block = enclosing_block # restore old BLOCK ptr
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite_element(_t)
      rewrite_element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LABEL, ACTION, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, RULE_REF
          rewrite_atom(_t)
          _t = self.attr__ret_tree
        when OPTIONAL, CLOSURE, POSITIVE_CLOSURE
          rewrite_ebnf(_t)
          _t = self.attr__ret_tree
        when TREE_BEGIN
          rewrite_tree(_t)
          _t = self.attr__ret_tree
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite_template(_t)
      rewrite_template_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      ind = nil
      arg = nil
      a = nil
      act = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ALT
          __t153 = _t
          tmp79_ast_in = _t
          match(_t, ALT)
          _t = _t.get_first_child
          tmp80_ast_in = _t
          match(_t, EPSILON)
          _t = _t.get_next_sibling
          tmp81_ast_in = _t
          match(_t, EOA)
          _t = _t.get_next_sibling
          _t = __t153
          _t = _t.get_next_sibling
        when TEMPLATE
          __t154 = _t
          tmp82_ast_in = _t
          match(_t, TEMPLATE)
          _t = _t.get_first_child
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when ID
            id = _t
            match(_t, ID)
            _t = _t.get_next_sibling
          when ACTION
            ind = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
          else
            raise NoViableAltException.new(_t)
          end
          __t156 = _t
          tmp83_ast_in = _t
          match(_t, ARGLIST)
          _t = _t.get_first_child
          begin
            if ((_t).nil?)
              _t = ASTNULL
            end
            if (((_t.get_type).equal?(ARG)))
              __t158 = _t
              tmp84_ast_in = _t
              match(_t, ARG)
              _t = _t.get_first_child
              arg = _t
              match(_t, ID)
              _t = _t.get_next_sibling
              a = _t
              match(_t, ACTION)
              _t = _t.get_next_sibling
              _t = __t158
              _t = _t.get_next_sibling
              if ((self.attr_input_state.attr_guessing).equal?(0))
                a.attr_outer_alt_num = @outer_alt_num
                track_inline_action(a)
              end
            else
              break
            end
          end while (true)
          _t = __t156
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            if (!(ind).nil?)
              ind.attr_outer_alt_num = @outer_alt_num
              track_inline_action(ind)
            end
          end
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when DOUBLE_QUOTE_STRING_LITERAL
            tmp85_ast_in = _t
            match(_t, DOUBLE_QUOTE_STRING_LITERAL)
            _t = _t.get_next_sibling
          when DOUBLE_ANGLE_STRING_LITERAL
            tmp86_ast_in = _t
            match(_t, DOUBLE_ANGLE_STRING_LITERAL)
            _t = _t.get_next_sibling
          when 3
          else
            raise NoViableAltException.new(_t)
          end
          _t = __t154
          _t = _t.get_next_sibling
        when ACTION
          act = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            act.attr_outer_alt_num = @outer_alt_num
            track_inline_action(act)
          end
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite_atom(_t)
      rewrite_atom_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      arg = nil
      r = @grammar.get_rule(@current_rule_name)
      token_refs_in_alt = r.get_token_refs_in_alt(@outer_alt_num)
      imaginary = (rewrite_atom_ast_in.get_type).equal?(TOKEN_REF) && !token_refs_in_alt.contains(rewrite_atom_ast_in.get_text)
      if (!imaginary && @grammar.build_ast && ((rewrite_atom_ast_in.get_type).equal?(RULE_REF) || (rewrite_atom_ast_in.get_type).equal?(LABEL) || (rewrite_atom_ast_in.get_type).equal?(TOKEN_REF) || (rewrite_atom_ast_in.get_type).equal?(CHAR_LITERAL) || (rewrite_atom_ast_in.get_type).equal?(STRING_LITERAL)))
        # track per block and for entire rewrite rule
        if (!(@current_rewrite_block).nil?)
          @current_rewrite_block.attr_rewrite_refs_shallow.add(rewrite_atom_ast_in)
          @current_rewrite_block.attr_rewrite_refs_deep.add(rewrite_atom_ast_in)
        end
        @current_rewrite_rule.attr_rewrite_refs_deep.add(rewrite_atom_ast_in)
      end
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when RULE_REF
          tmp87_ast_in = _t
          match(_t, RULE_REF)
          _t = _t.get_next_sibling
        when STRING_LITERAL, CHAR_LITERAL, TOKEN_REF
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when TOKEN_REF
            __t150 = _t
            tmp88_ast_in = _t
            match(_t, TOKEN_REF)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when ARG_ACTION
              arg = _t
              match(_t, ARG_ACTION)
              _t = _t.get_next_sibling
            when 3
            else
              raise NoViableAltException.new(_t)
            end
            _t = __t150
            _t = _t.get_next_sibling
          when CHAR_LITERAL
            tmp89_ast_in = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
          when STRING_LITERAL
            tmp90_ast_in = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_next_sibling
          else
            raise NoViableAltException.new(_t)
          end
          if ((self.attr_input_state.attr_guessing).equal?(0))
            if (!(arg).nil?)
              arg.attr_outer_alt_num = @outer_alt_num
              track_inline_action(arg)
            end
          end
        when LABEL
          tmp91_ast_in = _t
          match(_t, LABEL)
          _t = _t.get_next_sibling
        when ACTION
          tmp92_ast_in = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          if ((self.attr_input_state.attr_guessing).equal?(0))
            tmp92_ast_in.attr_outer_alt_num = @outer_alt_num
            track_inline_action(tmp92_ast_in)
          end
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite_ebnf(_t)
      rewrite_ebnf_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONAL
          __t141 = _t
          tmp93_ast_in = _t
          match(_t, OPTIONAL)
          _t = _t.get_first_child
          rewrite_block(_t)
          _t = self.attr__ret_tree
          _t = __t141
          _t = _t.get_next_sibling
        when CLOSURE
          __t142 = _t
          tmp94_ast_in = _t
          match(_t, CLOSURE)
          _t = _t.get_first_child
          rewrite_block(_t)
          _t = self.attr__ret_tree
          _t = __t142
          _t = _t.get_next_sibling
        when POSITIVE_CLOSURE
          __t143 = _t
          tmp95_ast_in = _t
          match(_t, POSITIVE_CLOSURE)
          _t = _t.get_first_child
          rewrite_block(_t)
          _t = self.attr__ret_tree
          _t = __t143
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite_tree(_t)
      rewrite_tree_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t145 = _t
        tmp96_ast_in = _t
        match(_t, TREE_BEGIN)
        _t = _t.get_first_child
        rewrite_atom(_t)
        _t = self.attr__ret_tree
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(LABEL) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(TREE_BEGIN)))
            rewrite_element(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        _t = __t145
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        if ((self.attr_input_state.attr_guessing).equal?(0))
          report_error(ex)
          if (!(_t).nil?)
            _t = _t.get_next_sibling
          end
        else
          raise ex
        end
      end
      self.attr__ret_tree = _t
    end
    
    class_module.module_eval {
      const_set_lazy(:_tokenNames) { Array.typed(String).new(["<0>", "EOF", "<2>", "NULL_TREE_LOOKAHEAD", "\"options\"", "\"tokens\"", "\"parser\"", "LEXER", "RULE", "BLOCK", "OPTIONAL", "CLOSURE", "POSITIVE_CLOSURE", "SYNPRED", "RANGE", "CHAR_RANGE", "EPSILON", "ALT", "EOR", "EOB", "EOA", "ID", "ARG", "ARGLIST", "RET", "LEXER_GRAMMAR", "PARSER_GRAMMAR", "TREE_GRAMMAR", "COMBINED_GRAMMAR", "INITACTION", "FORCED_ACTION", "LABEL", "TEMPLATE", "\"scope\"", "\"import\"", "GATED_SEMPRED", "SYN_SEMPRED", "BACKTRACK_SEMPRED", "\"fragment\"", "DOT", "ACTION", "DOC_COMMENT", "SEMI", "\"lexer\"", "\"tree\"", "\"grammar\"", "AMPERSAND", "COLON", "RCURLY", "ASSIGN", "STRING_LITERAL", "CHAR_LITERAL", "INT", "STAR", "COMMA", "TOKEN_REF", "\"protected\"", "\"public\"", "\"private\"", "BANG", "ARG_ACTION", "\"returns\"", "\"throws\"", "LPAREN", "OR", "RPAREN", "\"catch\"", "\"finally\"", "PLUS_ASSIGN", "SEMPRED", "IMPLIES", "ROOT", "WILDCARD", "RULE_REF", "NOT", "TREE_BEGIN", "QUESTION", "PLUS", "OPEN_ELEMENT_OPTION", "CLOSE_ELEMENT_OPTION", "REWRITE", "ETC", "DOLLAR", "DOUBLE_QUOTE_STRING_LITERAL", "DOUBLE_ANGLE_STRING_LITERAL", "WS", "COMMENT", "SL_COMMENT", "ML_COMMENT", "STRAY_BRACKET", "ESC", "DIGIT", "XDIGIT", "NESTED_ARG_ACTION", "NESTED_ACTION", "ACTION_CHAR_LITERAL", "ACTION_STRING_LITERAL", "ACTION_ESC", "WS_LOOP", "INTERNAL_RULE_REF", "WS_OPT", "SRC"]) }
      const_attr_reader  :_tokenNames
    }
    
    private
    alias_method :initialize__define_grammar_items_walker, :initialize
  end
  
end
