require "rjava"
 # $ANTLR 2.7.7 (2006-01-29): "codegen.g" -> "CodeGenTreeWalker.java"$
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
module Org::Antlr::Codegen
  module CodeGenTreeWalkerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include ::Org::Antlr::Tool
      include ::Org::Antlr::Analysis
      include ::Org::Antlr::Misc
      include ::Java::Util
      include ::Org::Antlr::Stringtemplate
      include_const ::Antlr, :TokenWithIndex
      include_const ::Antlr, :CommonToken
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
  
  # Walk a grammar and generate code by gradually building up
  # a bigger and bigger StringTemplate.
  # 
  # Terence Parr
  # University of San Francisco
  # June 15, 2004
  class CodeGenTreeWalker < Antlr::TreeParser
    include_class_members CodeGenTreeWalkerImports
    include CodeGenTreeWalkerTokenTypes
    
    class_module.module_eval {
      const_set_lazy(:RULE_BLOCK_NESTING_LEVEL) { 0 }
      const_attr_reader  :RULE_BLOCK_NESTING_LEVEL
      
      const_set_lazy(:OUTER_REWRITE_NESTING_LEVEL) { 0 }
      const_attr_reader  :OUTER_REWRITE_NESTING_LEVEL
    }
    
    attr_accessor :current_rule_name
    alias_method :attr_current_rule_name, :current_rule_name
    undef_method :current_rule_name
    alias_method :attr_current_rule_name=, :current_rule_name=
    undef_method :current_rule_name=
    
    attr_accessor :block_nesting_level
    alias_method :attr_block_nesting_level, :block_nesting_level
    undef_method :block_nesting_level
    alias_method :attr_block_nesting_level=, :block_nesting_level=
    undef_method :block_nesting_level=
    
    attr_accessor :rewrite_block_nesting_level
    alias_method :attr_rewrite_block_nesting_level, :rewrite_block_nesting_level
    undef_method :rewrite_block_nesting_level
    alias_method :attr_rewrite_block_nesting_level=, :rewrite_block_nesting_level=
    undef_method :rewrite_block_nesting_level=
    
    attr_accessor :outer_alt_num
    alias_method :attr_outer_alt_num, :outer_alt_num
    undef_method :outer_alt_num
    alias_method :attr_outer_alt_num=, :outer_alt_num=
    undef_method :outer_alt_num=
    
    attr_accessor :current_block_st
    alias_method :attr_current_block_st, :current_block_st
    undef_method :current_block_st
    alias_method :attr_current_block_st=, :current_block_st=
    undef_method :current_block_st=
    
    attr_accessor :current_alt_has_astrewrite
    alias_method :attr_current_alt_has_astrewrite, :current_alt_has_astrewrite
    undef_method :current_alt_has_astrewrite
    alias_method :attr_current_alt_has_astrewrite=, :current_alt_has_astrewrite=
    undef_method :current_alt_has_astrewrite=
    
    attr_accessor :rewrite_tree_nesting_level
    alias_method :attr_rewrite_tree_nesting_level, :rewrite_tree_nesting_level
    undef_method :rewrite_tree_nesting_level
    alias_method :attr_rewrite_tree_nesting_level=, :rewrite_tree_nesting_level=
    undef_method :rewrite_tree_nesting_level=
    
    attr_accessor :rewrite_rule_refs
    alias_method :attr_rewrite_rule_refs, :rewrite_rule_refs
    undef_method :rewrite_rule_refs
    alias_method :attr_rewrite_rule_refs=, :rewrite_rule_refs=
    undef_method :rewrite_rule_refs=
    
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
      ErrorManager.syntax_error(ErrorManager::MSG_SYNTAX_ERROR, @grammar, token, "codegen: " + (ex.to_s).to_s, ex)
    end
    
    typesig { [String] }
    def report_error(s)
      System.out.println("codegen: error: " + s)
    end
    
    attr_accessor :generator
    alias_method :attr_generator, :generator
    undef_method :generator
    alias_method :attr_generator=, :generator=
    undef_method :generator=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :templates
    alias_method :attr_templates, :templates
    undef_method :templates
    alias_method :attr_templates=, :templates=
    undef_method :templates=
    
    # The overall lexer/parser template; simulate dynamically scoped
    # attributes by making this an instance var of the walker.
    attr_accessor :recognizer_st
    alias_method :attr_recognizer_st, :recognizer_st
    undef_method :recognizer_st
    alias_method :attr_recognizer_st=, :recognizer_st=
    undef_method :recognizer_st=
    
    attr_accessor :output_file_st
    alias_method :attr_output_file_st, :output_file_st
    undef_method :output_file_st
    alias_method :attr_output_file_st=, :output_file_st=
    undef_method :output_file_st=
    
    attr_accessor :header_file_st
    alias_method :attr_header_file_st, :header_file_st
    undef_method :header_file_st
    alias_method :attr_header_file_st=, :header_file_st=
    undef_method :header_file_st=
    
    attr_accessor :output_option
    alias_method :attr_output_option, :output_option
    undef_method :output_option
    alias_method :attr_output_option=, :output_option=
    undef_method :output_option=
    
    typesig { [GrammarAST, GrammarAST, String] }
    def get_wildcard_st(element_ast, ast_suffix, label)
      name = "wildcard"
      if ((@grammar.attr_type).equal?(Grammar::LEXER))
        name = "wildcardChar"
      end
      return get_token_element_st(name, name, element_ast, ast_suffix, label)
    end
    
    typesig { [String, String, GrammarAST, GrammarAST, String] }
    def get_rule_element_st(name, rule_target_name, element_ast, ast_suffix, label)
      suffix = get_stsuffix(ast_suffix, label)
      name += suffix
      # if we're building trees and there is no label, gen a label
      # unless we're in a synpred rule.
      r = @grammar.get_rule(@current_rule_name)
      if ((@grammar.build_ast || suffix.length > 0) && (label).nil? && ((r).nil? || !r.attr_is_syn_pred))
        # we will need a label to do the AST or tracking, make one
        label = (@generator.create_unique_label(rule_target_name)).to_s
        label_tok = CommonToken.new(ANTLRParser::ID, label)
        @grammar.define_rule_ref_label(@current_rule_name, label_tok, element_ast)
      end
      element_st = @templates.get_instance_of(name)
      if (!(label).nil?)
        element_st.set_attribute("label", label)
      end
      return element_st
    end
    
    typesig { [String, String, GrammarAST, GrammarAST, String] }
    def get_token_element_st(name, element_name, element_ast, ast_suffix, label)
      suffix = get_stsuffix(ast_suffix, label)
      name += suffix
      # if we're building trees and there is no label, gen a label
      # unless we're in a synpred rule.
      r = @grammar.get_rule(@current_rule_name)
      if ((@grammar.build_ast || suffix.length > 0) && (label).nil? && ((r).nil? || !r.attr_is_syn_pred))
        label = (@generator.create_unique_label(element_name)).to_s
        label_tok = CommonToken.new(ANTLRParser::ID, label)
        @grammar.define_token_ref_label(@current_rule_name, label_tok, element_ast)
      end
      element_st = @templates.get_instance_of(name)
      if (!(label).nil?)
        element_st.set_attribute("label", label)
      end
      return element_st
    end
    
    typesig { [String] }
    def is_list_label(label)
      has_list_label = false
      if (!(label).nil?)
        r = @grammar.get_rule(@current_rule_name)
        st_name = nil
        if (!(r).nil?)
          pair = r.get_label(label)
          if (!(pair).nil? && ((pair.attr_type).equal?(Grammar::TOKEN_LIST_LABEL) || (pair.attr_type).equal?(Grammar::RULE_LIST_LABEL)))
            has_list_label = true
          end
        end
      end
      return has_list_label
    end
    
    typesig { [GrammarAST, String] }
    # Return a non-empty template name suffix if the token is to be
    # tracked, added to a tree, or both.
    def get_stsuffix(ast_suffix, label)
      if ((@grammar.attr_type).equal?(Grammar::LEXER))
        return ""
      end
      # handle list label stuff; make element use "Track"
      operator_part = ""
      rewrite_part = ""
      list_label_part = ""
      rule_descr = @grammar.get_rule(@current_rule_name)
      if (!(ast_suffix).nil? && !rule_descr.attr_is_syn_pred)
        if ((ast_suffix.get_type).equal?(ANTLRParser::ROOT))
          operator_part = "RuleRoot"
        else
          if ((ast_suffix.get_type).equal?(ANTLRParser::BANG))
            operator_part = "Bang"
          end
        end
      end
      if (@current_alt_has_astrewrite)
        rewrite_part = "Track"
      end
      if (is_list_label(label))
        list_label_part = "AndListLabel"
      end
      stsuffix = operator_part + rewrite_part + list_label_part
      # System.out.println("suffix = "+STsuffix);
      return stsuffix
    end
    
    typesig { [JavaSet] }
    # Convert rewrite AST lists to target labels list
    def get_token_types_as_target_labels(refs)
      if ((refs).nil? || (refs.size).equal?(0))
        return nil
      end
      labels = ArrayList.new(refs.size)
      refs.each do |t|
        label = nil
        if ((t.get_type).equal?(ANTLRParser::RULE_REF))
          label = (t.get_text).to_s
        else
          if ((t.get_type).equal?(ANTLRParser::LABEL))
            label = (t.get_text).to_s
          else
            # must be char or string literal
            label = (@generator.get_token_type_as_target_label(@grammar.get_token_type(t.get_text))).to_s
          end
        end
        labels.add(label)
      end
      return labels
    end
    
    typesig { [Grammar] }
    def init(g)
      @grammar = g
      @generator = @grammar.get_code_generator
      @templates = @generator.get_templates
    end
    
    typesig { [] }
    def initialize
      @current_rule_name = nil
      @block_nesting_level = 0
      @rewrite_block_nesting_level = 0
      @outer_alt_num = 0
      @current_block_st = nil
      @current_alt_has_astrewrite = false
      @rewrite_tree_nesting_level = 0
      @rewrite_rule_refs = nil
      @generator = nil
      @grammar = nil
      @templates = nil
      @recognizer_st = nil
      @output_file_st = nil
      @header_file_st = nil
      @output_option = nil
      super()
      @current_rule_name = nil
      @block_nesting_level = 0
      @rewrite_block_nesting_level = 0
      @outer_alt_num = 0
      @current_block_st = nil
      @current_alt_has_astrewrite = false
      @rewrite_tree_nesting_level = 0
      @rewrite_rule_refs = nil
      @output_option = ""
      self.attr_token_names = _tokenNames
    end
    
    typesig { [AST, Grammar, StringTemplate, StringTemplate, StringTemplate] }
    def grammar(_t, g, recognizer_st, output_file_st, header_file_st)
      grammar_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      init(g)
      @recognizer_st = recognizer_st
      @output_file_st = output_file_st
      @header_file_st = header_file_st
      super_class = g.get_option("superClass")
      @output_option = (g.get_option("output")).to_s
      recognizer_st.set_attribute("superClass", super_class)
      if (!(g.attr_type).equal?(Grammar::LEXER))
        recognizer_st.set_attribute("ASTLabelType", g.get_option("ASTLabelType"))
      end
      if ((g.attr_type).equal?(Grammar::TREE_PARSER) && (g.get_option("ASTLabelType")).nil?)
        ErrorManager.grammar_warning(ErrorManager::MSG_MISSING_AST_TYPE_IN_TREE_GRAMMAR, g, nil, g.attr_name)
      end
      if (!(g.attr_type).equal?(Grammar::TREE_PARSER))
        recognizer_st.set_attribute("labelType", g.get_option("TokenLabelType"))
      end
      recognizer_st.set_attribute("numRules", @grammar.get_rules.size)
      output_file_st.set_attribute("numRules", @grammar.get_rules.size)
      header_file_st.set_attribute("numRules", @grammar.get_rules.size)
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
      name = nil
      cmt = nil
      begin
        # for error handling
        name = _t
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
          @output_file_st.set_attribute("docComment", cmt.get_text)
          @header_file_st.set_attribute("docComment", cmt.get_text)
        when OPTIONS, TOKENS, RULE, SCOPE, IMPORT, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        @recognizer_st.set_attribute("name", @grammar.get_recognizer_name)
        @output_file_st.set_attribute("name", @grammar.get_recognizer_name)
        @header_file_st.set_attribute("name", @grammar.get_recognizer_name)
        @recognizer_st.set_attribute("scopes", @grammar.get_global_scopes)
        @header_file_st.set_attribute("scopes", @grammar.get_global_scopes)
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          __t12 = _t
          tmp5_ast_in = _t
          match(_t, OPTIONS)
          _t = _t.get_first_child
          tmp6_ast_in = _t
          if ((_t).nil?)
            raise MismatchedTokenException.new
          end
          _t = _t.get_next_sibling
          _t = __t12
          _t = _t.get_next_sibling
        when TOKENS, RULE, SCOPE, IMPORT, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when IMPORT
          __t14 = _t
          tmp7_ast_in = _t
          match(_t, IMPORT)
          _t = _t.get_first_child
          tmp8_ast_in = _t
          if ((_t).nil?)
            raise MismatchedTokenException.new
          end
          _t = _t.get_next_sibling
          _t = __t14
          _t = _t.get_next_sibling
        when TOKENS, RULE, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when TOKENS
          __t16 = _t
          tmp9_ast_in = _t
          match(_t, TOKENS)
          _t = _t.get_first_child
          tmp10_ast_in = _t
          if ((_t).nil?)
            raise MismatchedTokenException.new
          end
          _t = _t.get_next_sibling
          _t = __t16
          _t = _t.get_next_sibling
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
            tmp11_ast_in = _t
            match(_t, AMPERSAND)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        rules(_t, @recognizer_st)
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
    def attr_scope(_t)
      attr_scope_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t8 = _t
        tmp12_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        tmp13_ast_in = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        tmp14_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t8
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, StringTemplate] }
    def rules(_t, recognizer_st)
      rules_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      r_st = nil
      begin
        # for error handling
        _cnt24 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(RULE)))
            rule_name = _t.get_first_child.get_text
            r = @grammar.get_rule(rule_name)
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(RULE))) && (@grammar.generate_method_for_rule(rule_name)))
              r_st = rule(_t)
              _t = self.attr__ret_tree
              if (!(r_st).nil?)
                recognizer_st.set_attribute("rules", r_st)
                @output_file_st.set_attribute("rules", r_st)
                @header_file_st.set_attribute("rules", r_st)
              end
            else
              if (((_t.get_type).equal?(RULE)))
                tmp15_ast_in = _t
                match(_t, RULE)
                _t = _t.get_next_sibling
              else
                raise NoViableAltException.new(_t)
              end
            end
          else
            if (_cnt24 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          ((_cnt24 += 1) - 1)
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
    def rule(_t)
      code = nil
      rule_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      mod = nil
      r = nil
      init_action = nil
      b = nil
      # get the dfa for the BLOCK
      block = rule_ast_in.get_first_child_with_type(BLOCK)
      dfa = block.get_lookahead_dfa
      # init blockNestingLevel so it's block level RULE_BLOCK_NESTING_LEVEL
      # for alts of rule
      @block_nesting_level = RULE_BLOCK_NESTING_LEVEL - 1
      rule_descr = @grammar.get_rule(rule_ast_in.get_first_child.get_text)
      # For syn preds, we don't want any AST code etc... in there.
      # Save old templates ptr and restore later.  Base templates include Dbg.
      save_group = @templates
      if (rule_descr.attr_is_syn_pred)
        @templates = @generator.get_base_templates
      end
      begin
        # for error handling
        __t26 = _t
        tmp16_ast_in = _t
        match(_t, RULE)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        r = (id.get_text).to_s
        @current_rule_name = r
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when FRAGMENT, LITERAL_protected, LITERAL_public, LITERAL_private
          mod = (_t).equal?(ASTNULL) ? nil : _t
          modifier(_t)
          _t = self.attr__ret_tree
        when ARG
        else
          raise NoViableAltException.new(_t)
        end
        __t28 = _t
        tmp17_ast_in = _t
        match(_t, ARG)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ARG_ACTION
          tmp18_ast_in = _t
          match(_t, ARG_ACTION)
          _t = _t.get_next_sibling
        when 3
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t28
        _t = _t.get_next_sibling
        __t30 = _t
        tmp19_ast_in = _t
        match(_t, RET)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ARG_ACTION
          tmp20_ast_in = _t
          match(_t, ARG_ACTION)
          _t = _t.get_next_sibling
        when 3
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t30
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          __t33 = _t
          tmp21_ast_in = _t
          match(_t, OPTIONS)
          _t = _t.get_first_child
          tmp22_ast_in = _t
          if ((_t).nil?)
            raise MismatchedTokenException.new
          end
          _t = _t.get_next_sibling
          _t = __t33
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
            tmp23_ast_in = _t
            match(_t, AMPERSAND)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        b = block(_t, "ruleBlock", dfa)
        _t = self.attr__ret_tree
        description = @grammar.grammar_tree_to_string(rule_ast_in.get_first_child_with_type(BLOCK), false)
        description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
        b.set_attribute("description", description)
        # do not generate lexer rules in combined grammar
        st_name = nil
        if (rule_descr.attr_is_syn_pred)
          st_name = "synpredRule"
        else
          if ((@grammar.attr_type).equal?(Grammar::LEXER))
            if ((r == Grammar::ARTIFICIAL_TOKENS_RULENAME))
              st_name = "tokensRule"
            else
              st_name = "lexerRule"
            end
          else
            if (!((@grammar.attr_type).equal?(Grammar::COMBINED) && Character.is_upper_case(r.char_at(0))))
              st_name = "rule"
            end
          end
        end
        code = @templates.get_instance_of(st_name)
        if ((code.get_name == "rule"))
          code.set_attribute("emptyRule", Boolean.value_of(@grammar.is_empty_rule(block)))
        end
        code.set_attribute("ruleDescriptor", rule_descr)
        memo = @grammar.get_block_option(rule_ast_in, "memoize")
        if ((memo).nil?)
          memo = (@grammar.get_option("memoize")).to_s
        end
        if (!(memo).nil? && (memo == "true") && ((st_name == "rule") || (st_name == "lexerRule")))
          code.set_attribute("memoize", Boolean.value_of(!(memo).nil? && (memo == "true")))
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_catch, LITERAL_finally
          exception_group(_t, code)
          _t = self.attr__ret_tree
        when EOR
        else
          raise NoViableAltException.new(_t)
        end
        tmp24_ast_in = _t
        match(_t, EOR)
        _t = _t.get_next_sibling
        _t = __t26
        _t = _t.get_next_sibling
        if (!(code).nil?)
          if ((@grammar.attr_type).equal?(Grammar::LEXER))
            naked = (r == Grammar::ARTIFICIAL_TOKENS_RULENAME) || (!(mod).nil? && (mod.get_text == Grammar::FRAGMENT_RULE_MODIFIER))
            code.set_attribute("nakedBlock", Boolean.value_of(naked))
          else
            description = (@grammar.grammar_tree_to_string(rule_ast_in, false)).to_s
            description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
            code.set_attribute("description", description)
          end
          the_rule = @grammar.get_rule(r)
          @generator.translate_action_attribute_references_for_single_scope(the_rule, the_rule.get_actions)
          code.set_attribute("ruleName", r)
          code.set_attribute("block", b)
          if (!(init_action).nil?)
            code.set_attribute("initAction", init_action)
          end
        end
        @templates = save_group
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
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
          tmp25_ast_in = _t
          match(_t, LITERAL_protected)
          _t = _t.get_next_sibling
        when LITERAL_public
          tmp26_ast_in = _t
          match(_t, LITERAL_public)
          _t = _t.get_next_sibling
        when LITERAL_private
          tmp27_ast_in = _t
          match(_t, LITERAL_private)
          _t = _t.get_next_sibling
        when FRAGMENT
          tmp28_ast_in = _t
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
        __t40 = _t
        tmp29_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ACTION
          tmp30_ast_in = _t
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
            tmp31_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        _t = __t40
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, String, DFA] }
    def block(_t, block_template_name, dfa)
      code = nil
      block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      decision = nil
      if (!(dfa).nil?)
        code = @templates.get_instance_of(block_template_name)
        decision = @generator.gen_lookahead_decision(@recognizer_st, dfa)
        code.set_attribute("decision", decision)
        code.set_attribute("decisionNumber", dfa.get_decision_number)
        code.set_attribute("maxK", dfa.get_max_lookahead_depth)
        code.set_attribute("maxAlt", dfa.get_number_of_alts)
      else
        code = @templates.get_instance_of(block_template_name + "SingleAlt")
      end
      ((@block_nesting_level += 1) - 1)
      code.set_attribute("blockLevel", @block_nesting_level)
      code.set_attribute("enclosingBlockLevel", @block_nesting_level - 1)
      alt = nil
      rew = nil
      sb = nil
      r = nil
      alt_num = 1
      if ((@block_nesting_level).equal?(RULE_BLOCK_NESTING_LEVEL))
        @outer_alt_num = 1
      end
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        if ((((_t.get_type).equal?(BLOCK))) && (!(block_ast_in.get_set_value).nil?))
          sb = set_block(_t)
          _t = self.attr__ret_tree
          code.set_attribute("alts", sb)
          ((@block_nesting_level -= 1) + 1)
        else
          if (((_t.get_type).equal?(BLOCK)))
            __t45 = _t
            tmp32_ast_in = _t
            match(_t, BLOCK)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when OPTIONS
              tmp33_ast_in = _t
              match(_t, OPTIONS)
              _t = _t.get_next_sibling
            when ALT
            else
              raise NoViableAltException.new(_t)
            end
            _cnt48 = 0
            begin
              if ((_t).nil?)
                _t = ASTNULL
              end
              if (((_t.get_type).equal?(ALT)))
                alt = alternative(_t)
                _t = self.attr__ret_tree
                r = _t
                rew = rewrite(_t)
                _t = self.attr__ret_tree
                if ((@block_nesting_level).equal?(RULE_BLOCK_NESTING_LEVEL))
                  ((@outer_alt_num += 1) - 1)
                end
                # add the rewrite code as just another element in the alt :)
                # (unless it's a " -> ..." rewrite
                # ( -> ... )
                etc = (r.get_type).equal?(REWRITE) && !(r.get_first_child).nil? && (r.get_first_child.get_type).equal?(ETC)
                if (!(rew).nil? && !etc)
                  alt.set_attribute("rew", rew)
                end
                # add this alt to the list of alts for this block
                code.set_attribute("alts", alt)
                alt.set_attribute("altNum", Utils.integer(alt_num))
                alt.set_attribute("outerAlt", Boolean.value_of((@block_nesting_level).equal?(RULE_BLOCK_NESTING_LEVEL)))
                ((alt_num += 1) - 1)
              else
                if (_cnt48 >= 1)
                  break
                else
                  raise NoViableAltException.new(_t)
                end
              end
              ((_cnt48 += 1) - 1)
            end while (true)
            tmp34_ast_in = _t
            match(_t, EOB)
            _t = _t.get_next_sibling
            _t = __t45
            _t = _t.get_next_sibling
            ((@block_nesting_level -= 1) + 1)
          else
            raise NoViableAltException.new(_t)
          end
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST, StringTemplate] }
    def exception_group(_t, rule_st)
      exception_group_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_catch
          _cnt52 = 0
          begin
            if ((_t).nil?)
              _t = ASTNULL
            end
            if (((_t.get_type).equal?(LITERAL_catch)))
              exception_handler(_t, rule_st)
              _t = self.attr__ret_tree
            else
              if (_cnt52 >= 1)
                break
              else
                raise NoViableAltException.new(_t)
              end
            end
            ((_cnt52 += 1) - 1)
          end while (true)
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when LITERAL_finally
            finally_clause(_t, rule_st)
            _t = self.attr__ret_tree
          when EOR
          else
            raise NoViableAltException.new(_t)
          end
        when LITERAL_finally
          finally_clause(_t, rule_st)
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
    def set_block(_t)
      code = nil
      set_block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      s = nil
      setcode = nil
      if ((@block_nesting_level).equal?(RULE_BLOCK_NESTING_LEVEL) && @grammar.build_ast)
        r = @grammar.get_rule(@current_rule_name)
        @current_alt_has_astrewrite = r.has_rewrite(@outer_alt_num)
        if (@current_alt_has_astrewrite)
          r.track_token_reference_in_alt(set_block_ast_in, @outer_alt_num)
        end
      end
      begin
        # for error handling
        s = _t
        match(_t, BLOCK)
        _t = _t.get_next_sibling
        i = (s.get_token).get_index
        if ((@block_nesting_level).equal?(RULE_BLOCK_NESTING_LEVEL))
          setcode = get_token_element_st("matchRuleBlockSet", "set", s, nil, nil)
        else
          setcode = get_token_element_st("matchSet", "set", s, nil, nil)
        end
        setcode.set_attribute("elementIndex", i)
        if (!(@grammar.attr_type).equal?(Grammar::LEXER))
          @generator.generate_local_follow(s, "set", @current_rule_name, i)
        end
        setcode.set_attribute("s", @generator.gen_set_expr(@templates, s.get_set_value, 1, false))
        altcode = @templates.get_instance_of("alt")
        altcode.set_attribute("elements.{el,line,pos}", setcode, Utils.integer(s.get_line), Utils.integer(s.get_column))
        altcode.set_attribute("altNum", Utils.integer(1))
        altcode.set_attribute("outerAlt", Boolean.value_of((@block_nesting_level).equal?(RULE_BLOCK_NESTING_LEVEL)))
        if (!@current_alt_has_astrewrite && @grammar.build_ast)
          altcode.set_attribute("autoAST", Boolean.value_of(true))
        end
        altcode.set_attribute("treeLevel", @rewrite_tree_nesting_level)
        code = altcode
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST] }
    def alternative(_t)
      code = @templates.get_instance_of("alt")
      alternative_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      a = nil
      # // TODO: can we use Rule.altsWithRewrites???
      # if ( blockNestingLevel==RULE_BLOCK_NESTING_LEVEL ) {
      # GrammarAST aRewriteNode = #alternative.findFirstType(REWRITE);
      # if ( grammar.buildAST() &&
      # (aRewriteNode!=null||
      # (#alternative.getNextSibling()!=null &&
      # #alternative.getNextSibling().getType()==REWRITE)) )
      # {
      # currentAltHasASTRewrite = true;
      # }
      # else {
      # currentAltHasASTRewrite = false;
      # }
      # }
      if ((@block_nesting_level).equal?(RULE_BLOCK_NESTING_LEVEL) && @grammar.build_ast)
        r = @grammar.get_rule(@current_rule_name)
        @current_alt_has_astrewrite = r.has_rewrite(@outer_alt_num)
      end
      description = @grammar.grammar_tree_to_string(alternative_ast_in, false)
      description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
      code.set_attribute("description", description)
      code.set_attribute("treeLevel", @rewrite_tree_nesting_level)
      if (!@current_alt_has_astrewrite && @grammar.build_ast)
        code.set_attribute("autoAST", Boolean.value_of(true))
      end
      e = nil
      begin
        # for error handling
        __t59 = _t
        a = (_t).equal?(ASTNULL) ? nil : _t
        match(_t, ALT)
        _t = _t.get_first_child
        _cnt61 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(BLOCK) || (_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(CHAR_RANGE) || (_t.get_type).equal?(EPSILON) || (_t.get_type).equal?(FORCED_ACTION) || (_t.get_type).equal?(GATED_SEMPRED) || (_t.get_type).equal?(SYN_SEMPRED) || (_t.get_type).equal?(BACKTRACK_SEMPRED) || (_t.get_type).equal?(DOT) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(BANG) || (_t.get_type).equal?(PLUS_ASSIGN) || (_t.get_type).equal?(SEMPRED) || (_t.get_type).equal?(ROOT) || (_t.get_type).equal?(WILDCARD) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(NOT) || (_t.get_type).equal?(TREE_BEGIN)))
            el_ast = _t
            e = element(_t, nil, nil)
            _t = self.attr__ret_tree
            if (!(e).nil?)
              code.set_attribute("elements.{el,line,pos}", e, Utils.integer(el_ast.get_line), Utils.integer(el_ast.get_column))
            end
          else
            if (_cnt61 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          ((_cnt61 += 1) - 1)
        end while (true)
        tmp35_ast_in = _t
        match(_t, EOA)
        _t = _t.get_next_sibling
        _t = __t59
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST] }
    def rewrite(_t)
      code = nil
      rewrite_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      r = nil
      pred = nil
      alt = nil
      if ((rewrite_ast_in.get_type).equal?(REWRITE))
        if (@generator.attr_grammar.build_template)
          code = @templates.get_instance_of("rewriteTemplate")
        else
          code = @templates.get_instance_of("rewriteCode")
          code.set_attribute("treeLevel", Utils.integer(OUTER_REWRITE_NESTING_LEVEL))
          code.set_attribute("rewriteBlockLevel", Utils.integer(OUTER_REWRITE_NESTING_LEVEL))
          code.set_attribute("referencedElementsDeep", get_token_types_as_target_labels(rewrite_ast_in.attr_rewrite_refs_deep))
          token_labels = @grammar.get_labels(rewrite_ast_in.attr_rewrite_refs_deep, Grammar::TOKEN_LABEL)
          token_list_labels = @grammar.get_labels(rewrite_ast_in.attr_rewrite_refs_deep, Grammar::TOKEN_LIST_LABEL)
          rule_labels = @grammar.get_labels(rewrite_ast_in.attr_rewrite_refs_deep, Grammar::RULE_LABEL)
          rule_list_labels = @grammar.get_labels(rewrite_ast_in.attr_rewrite_refs_deep, Grammar::RULE_LIST_LABEL)
          # just in case they ref $r for "previous value", make a stream
          # from retval.tree
          retval_st = @templates.get_instance_of("prevRuleRootRef")
          rule_labels.add(retval_st.to_s)
          code.set_attribute("referencedTokenLabels", token_labels)
          code.set_attribute("referencedTokenListLabels", token_list_labels)
          code.set_attribute("referencedRuleLabels", rule_labels)
          code.set_attribute("referencedRuleListLabels", rule_list_labels)
        end
      else
        code = @templates.get_instance_of("noRewrite")
        code.set_attribute("treeLevel", Utils.integer(OUTER_REWRITE_NESTING_LEVEL))
        code.set_attribute("rewriteBlockLevel", Utils.integer(OUTER_REWRITE_NESTING_LEVEL))
      end
      begin
        # for error handling
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(REWRITE)))
            @rewrite_rule_refs = HashSet.new
            __t96 = _t
            r = (_t).equal?(ASTNULL) ? nil : _t
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
            alt = rewrite_alternative(_t)
            _t = self.attr__ret_tree
            _t = __t96
            _t = _t.get_next_sibling
            @rewrite_block_nesting_level = OUTER_REWRITE_NESTING_LEVEL
            pred_chunks = nil
            if (!(pred).nil?)
              # predText = #pred.getText();
              pred_chunks = @generator.translate_action(@current_rule_name, pred)
            end
            description = @grammar.grammar_tree_to_string(r, false)
            description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
            code.set_attribute("alts.{pred,alt,description}", pred_chunks, alt, description)
            pred = nil
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
      return code
    end
    
    typesig { [AST, StringTemplate] }
    def exception_handler(_t, rule_st)
      exception_handler_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t55 = _t
        tmp36_ast_in = _t
        match(_t, LITERAL_catch)
        _t = _t.get_first_child
        tmp37_ast_in = _t
        match(_t, ARG_ACTION)
        _t = _t.get_next_sibling
        tmp38_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t55
        _t = _t.get_next_sibling
        chunks = @generator.translate_action(@current_rule_name, tmp38_ast_in)
        rule_st.set_attribute("exceptions.{decl,action}", tmp37_ast_in.get_text, chunks)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, StringTemplate] }
    def finally_clause(_t, rule_st)
      finally_clause_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t57 = _t
        tmp39_ast_in = _t
        match(_t, LITERAL_finally)
        _t = _t.get_first_child
        tmp40_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t57
        _t = _t.get_next_sibling
        chunks = @generator.translate_action(@current_rule_name, tmp40_ast_in)
        rule_st.set_attribute("finally", chunks)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, GrammarAST, GrammarAST] }
    def element(_t, label, ast_suffix)
      code = nil
      element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      n = nil
      alabel = nil
      label2 = nil
      a = nil
      b = nil
      sp = nil
      gsp = nil
      elements = nil
      ast = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ROOT
          __t63 = _t
          tmp41_ast_in = _t
          match(_t, ROOT)
          _t = _t.get_first_child
          code = element(_t, label, tmp41_ast_in)
          _t = self.attr__ret_tree
          _t = __t63
          _t = _t.get_next_sibling
        when BANG
          __t64 = _t
          tmp42_ast_in = _t
          match(_t, BANG)
          _t = _t.get_first_child
          code = element(_t, label, tmp42_ast_in)
          _t = self.attr__ret_tree
          _t = __t64
          _t = _t.get_next_sibling
        when NOT
          __t65 = _t
          n = (_t).equal?(ASTNULL) ? nil : _t
          match(_t, NOT)
          _t = _t.get_first_child
          code = not_element(_t, n, label, ast_suffix)
          _t = self.attr__ret_tree
          _t = __t65
          _t = _t.get_next_sibling
        when ASSIGN
          __t66 = _t
          tmp43_ast_in = _t
          match(_t, ASSIGN)
          _t = _t.get_first_child
          alabel = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          code = element(_t, alabel, ast_suffix)
          _t = self.attr__ret_tree
          _t = __t66
          _t = _t.get_next_sibling
        when PLUS_ASSIGN
          __t67 = _t
          tmp44_ast_in = _t
          match(_t, PLUS_ASSIGN)
          _t = _t.get_first_child
          label2 = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          code = element(_t, label2, ast_suffix)
          _t = self.attr__ret_tree
          _t = __t67
          _t = _t.get_next_sibling
        when CHAR_RANGE
          __t68 = _t
          tmp45_ast_in = _t
          match(_t, CHAR_RANGE)
          _t = _t.get_first_child
          a = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          b = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          _t = __t68
          _t = _t.get_next_sibling
          code = @templates.get_instance_of("charRangeRef")
          low = @generator.attr_target.get_target_char_literal_from_antlrchar_literal(@generator, a.get_text)
          high = @generator.attr_target.get_target_char_literal_from_antlrchar_literal(@generator, b.get_text)
          code.set_attribute("a", low)
          code.set_attribute("b", high)
          if (!(label).nil?)
            code.set_attribute("label", label.get_text)
          end
        when TREE_BEGIN
          code = tree(_t)
          _t = self.attr__ret_tree
        when FORCED_ACTION, ACTION
          code = element_action(_t)
          _t = self.attr__ret_tree
        when GATED_SEMPRED, SEMPRED
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when SEMPRED
            sp = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
          when GATED_SEMPRED
            gsp = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            sp = gsp
          else
            raise NoViableAltException.new(_t)
          end
          code = @templates.get_instance_of("validateSemanticPredicate")
          code.set_attribute("pred", @generator.translate_action(@current_rule_name, sp))
          description = @generator.attr_target.get_target_string_literal_from_string(sp.get_text)
          code.set_attribute("description", description)
        when SYN_SEMPRED
          tmp46_ast_in = _t
          match(_t, SYN_SEMPRED)
          _t = _t.get_next_sibling
        when BACKTRACK_SEMPRED
          tmp47_ast_in = _t
          match(_t, BACKTRACK_SEMPRED)
          _t = _t.get_next_sibling
        when EPSILON
          tmp48_ast_in = _t
          match(_t, EPSILON)
          _t = _t.get_next_sibling
        else
          if ((_t).nil?)
            _t = ASTNULL
          end
          if ((((_t.get_type >= BLOCK && _t.get_type <= POSITIVE_CLOSURE))) && ((element_ast_in.get_set_value).nil?))
            code = ebnf(_t)
            _t = self.attr__ret_tree
          else
            if (((_t.get_type).equal?(BLOCK) || (_t.get_type).equal?(DOT) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(WILDCARD) || (_t.get_type).equal?(RULE_REF)))
              code = atom(_t, nil, label, ast_suffix)
              _t = self.attr__ret_tree
            else
              raise NoViableAltException.new(_t)
            end
          end
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST, GrammarAST, GrammarAST, GrammarAST] }
    def not_element(_t, n, label, ast_suffix)
      code = nil
      not_element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      assign_c = nil
      assign_s = nil
      assign_t = nil
      assign_st = nil
      elements = nil
      label_text = nil
      if (!(label).nil?)
        label_text = (label.get_text).to_s
      end
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when CHAR_LITERAL
          assign_c = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          ttype = 0
          if ((@grammar.attr_type).equal?(Grammar::LEXER))
            ttype = Grammar.get_char_value_from_grammar_char_literal(assign_c.get_text)
          else
            ttype = @grammar.get_token_type(assign_c.get_text)
          end
          elements = @grammar.complement(ttype)
        when STRING_LITERAL
          assign_s = _t
          match(_t, STRING_LITERAL)
          _t = _t.get_next_sibling
          ttype = 0
          if ((@grammar.attr_type).equal?(Grammar::LEXER))
            # TODO: error!
          else
            ttype = @grammar.get_token_type(assign_s.get_text)
          end
          elements = @grammar.complement(ttype)
        when TOKEN_REF
          assign_t = _t
          match(_t, TOKEN_REF)
          _t = _t.get_next_sibling
          ttype = @grammar.get_token_type(assign_t.get_text)
          elements = @grammar.complement(ttype)
        when BLOCK
          assign_st = _t
          match(_t, BLOCK)
          _t = _t.get_next_sibling
          elements = assign_st.get_set_value
          elements = @grammar.complement(elements)
        else
          raise NoViableAltException.new(_t)
        end
        code = get_token_element_st("matchSet", "set", n.get_first_child, ast_suffix, label_text)
        code.set_attribute("s", @generator.gen_set_expr(@templates, elements, 1, false))
        i = (n.get_token).get_index
        code.set_attribute("elementIndex", i)
        if (!(@grammar.attr_type).equal?(Grammar::LEXER))
          @generator.generate_local_follow(n, "set", @current_rule_name, i)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST] }
    def ebnf(_t)
      code = nil
      ebnf_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      dfa = nil
      b = ebnf_ast_in.get_first_child
      eob = b.get_last_child # loops will use EOB DFA
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when BLOCK
          dfa = ebnf_ast_in.get_lookahead_dfa
          code = block(_t, "block", dfa)
          _t = self.attr__ret_tree
        when OPTIONAL
          dfa = ebnf_ast_in.get_lookahead_dfa
          __t75 = _t
          tmp49_ast_in = _t
          match(_t, OPTIONAL)
          _t = _t.get_first_child
          code = block(_t, "optionalBlock", dfa)
          _t = self.attr__ret_tree
          _t = __t75
          _t = _t.get_next_sibling
        when CLOSURE
          dfa = eob.get_lookahead_dfa
          __t76 = _t
          tmp50_ast_in = _t
          match(_t, CLOSURE)
          _t = _t.get_first_child
          code = block(_t, "closureBlock", dfa)
          _t = self.attr__ret_tree
          _t = __t76
          _t = _t.get_next_sibling
        when POSITIVE_CLOSURE
          dfa = eob.get_lookahead_dfa
          __t77 = _t
          tmp51_ast_in = _t
          match(_t, POSITIVE_CLOSURE)
          _t = _t.get_first_child
          code = block(_t, "positiveClosureBlock", dfa)
          _t = self.attr__ret_tree
          _t = __t77
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
        description = @grammar.grammar_tree_to_string(ebnf_ast_in, false)
        description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
        code.set_attribute("description", description)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST, GrammarAST, GrammarAST, GrammarAST] }
    def atom(_t, scope, label, ast_suffix)
      code = nil
      atom_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      r = nil
      rarg = nil
      t = nil
      targ = nil
      c = nil
      s = nil
      w = nil
      label_text = nil
      if (!(label).nil?)
        label_text = (label.get_text).to_s
      end
      if (!(@grammar.attr_type).equal?(Grammar::LEXER) && ((atom_ast_in.get_type).equal?(RULE_REF) || (atom_ast_in.get_type).equal?(TOKEN_REF) || (atom_ast_in.get_type).equal?(CHAR_LITERAL) || (atom_ast_in.get_type).equal?(STRING_LITERAL)))
        enc_rule = @grammar.get_rule((atom_ast_in).attr_enclosing_rule_name)
        if (!(enc_rule).nil? && enc_rule.has_rewrite(@outer_alt_num) && !(ast_suffix).nil?)
          ErrorManager.grammar_error(ErrorManager::MSG_AST_OP_IN_ALT_WITH_REWRITE, @grammar, (atom_ast_in).get_token, (atom_ast_in).attr_enclosing_rule_name, @outer_alt_num)
          ast_suffix = nil
        end
      end
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when RULE_REF
          __t85 = _t
          r = (_t).equal?(ASTNULL) ? nil : _t
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
          _t = __t85
          _t = _t.get_next_sibling
          @grammar.check_rule_reference(scope, r, rarg, @current_rule_name)
          scope_name = nil
          if (!(scope).nil?)
            scope_name = (scope.get_text).to_s
          end
          rdef = @grammar.get_rule(scope_name, r.get_text)
          # don't insert label=r() if $label.attr not used, no ret value, ...
          if (!rdef.get_has_return_value)
            label_text = (nil).to_s
          end
          code = get_rule_element_st("ruleRef", r.get_text, r, ast_suffix, label_text)
          code.set_attribute("rule", rdef)
          if (!(scope).nil?)
            # scoped rule ref
            scope_g = @grammar.attr_composite.get_grammar(scope.get_text)
            code.set_attribute("scope", scope_g)
          else
            if (!(rdef.attr_grammar).equal?(@grammar))
              # nonlocal
              # if rule definition is not in this grammar, it's nonlocal
              rdef_delegates = rdef.attr_grammar.get_delegates
              if (rdef_delegates.contains(@grammar))
                code.set_attribute("scope", rdef.attr_grammar)
              else
                # defining grammar is not a delegate, scope all the
                # back to root, which has delegate methods for all
                # rules.  Don't use scope if we are root.
                if (!(@grammar).equal?(rdef.attr_grammar.attr_composite.attr_delegate_grammar_tree_root.attr_grammar))
                  code.set_attribute("scope", rdef.attr_grammar.attr_composite.attr_delegate_grammar_tree_root.attr_grammar)
                end
              end
            end
          end
          if (!(rarg).nil?)
            args = @generator.translate_action(@current_rule_name, rarg)
            code.set_attribute("args", args)
          end
          i = (r.get_token).get_index
          code.set_attribute("elementIndex", i)
          @generator.generate_local_follow(r, r.get_text, @current_rule_name, i)
          r.attr_code = code
        when TOKEN_REF
          __t87 = _t
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
          _t = __t87
          _t = _t.get_next_sibling
          if (@current_alt_has_astrewrite && !(t.attr_terminal_options).nil? && !(t.attr_terminal_options.get(Grammar.attr_default_token_option)).nil?)
            ErrorManager.grammar_error(ErrorManager::MSG_HETERO_ILLEGAL_IN_REWRITE_ALT, @grammar, ((t)).get_token, t.get_text)
          end
          @grammar.check_rule_reference(scope, t, targ, @current_rule_name)
          if ((@grammar.attr_type).equal?(Grammar::LEXER))
            if ((@grammar.get_token_type(t.get_text)).equal?(Label::EOF))
              code = @templates.get_instance_of("lexerMatchEOF")
            else
              code = @templates.get_instance_of("lexerRuleRef")
              if (is_list_label(label_text))
                code = @templates.get_instance_of("lexerRuleRefAndListLabel")
              end
              scope_name = nil
              if (!(scope).nil?)
                scope_name = (scope.get_text).to_s
              end
              rdef2 = @grammar.get_rule(scope_name, t.get_text)
              code.set_attribute("rule", rdef2)
              if (!(scope).nil?)
                # scoped rule ref
                scope_g = @grammar.attr_composite.get_grammar(scope.get_text)
                code.set_attribute("scope", scope_g)
              else
                if (!(rdef2.attr_grammar).equal?(@grammar))
                  # nonlocal
                  # if rule definition is not in this grammar, it's nonlocal
                  code.set_attribute("scope", rdef2.attr_grammar)
                end
              end
              if (!(targ).nil?)
                args = @generator.translate_action(@current_rule_name, targ)
                code.set_attribute("args", args)
              end
            end
            i = (t.get_token).get_index
            code.set_attribute("elementIndex", i)
            if (!(label).nil?)
              code.set_attribute("label", label_text)
            end
          else
            code = get_token_element_st("tokenRef", t.get_text, t, ast_suffix, label_text)
            token_label = @generator.get_token_type_as_target_label(@grammar.get_token_type(t.get_text))
            code.set_attribute("token", token_label)
            if (!@current_alt_has_astrewrite && !(t.attr_terminal_options).nil?)
              code.set_attribute("hetero", t.attr_terminal_options.get(Grammar.attr_default_token_option))
            end
            i = (t.get_token).get_index
            code.set_attribute("elementIndex", i)
            @generator.generate_local_follow(t, token_label, @current_rule_name, i)
          end
          t.attr_code = code
        when CHAR_LITERAL
          c = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          if ((@grammar.attr_type).equal?(Grammar::LEXER))
            code = @templates.get_instance_of("charRef")
            code.set_attribute("char", @generator.attr_target.get_target_char_literal_from_antlrchar_literal(@generator, c.get_text))
            if (!(label).nil?)
              code.set_attribute("label", label_text)
            end
          else
            # else it's a token type reference
            code = get_token_element_st("tokenRef", "char_literal", c, ast_suffix, label_text)
            token_label = @generator.get_token_type_as_target_label(@grammar.get_token_type(c.get_text))
            code.set_attribute("token", token_label)
            if (!(c.attr_terminal_options).nil?)
              code.set_attribute("hetero", c.attr_terminal_options.get(Grammar.attr_default_token_option))
            end
            i = (c.get_token).get_index
            code.set_attribute("elementIndex", i)
            @generator.generate_local_follow(c, token_label, @current_rule_name, i)
          end
        when STRING_LITERAL
          s = _t
          match(_t, STRING_LITERAL)
          _t = _t.get_next_sibling
          if ((@grammar.attr_type).equal?(Grammar::LEXER))
            code = @templates.get_instance_of("lexerStringRef")
            code.set_attribute("string", @generator.attr_target.get_target_string_literal_from_antlrstring_literal(@generator, s.get_text))
            if (!(label).nil?)
              code.set_attribute("label", label_text)
            end
          else
            # else it's a token type reference
            code = get_token_element_st("tokenRef", "string_literal", s, ast_suffix, label_text)
            token_label = @generator.get_token_type_as_target_label(@grammar.get_token_type(s.get_text))
            code.set_attribute("token", token_label)
            if (!(s.attr_terminal_options).nil?)
              code.set_attribute("hetero", s.attr_terminal_options.get(Grammar.attr_default_token_option))
            end
            i = (s.get_token).get_index
            code.set_attribute("elementIndex", i)
            @generator.generate_local_follow(s, token_label, @current_rule_name, i)
          end
        when WILDCARD
          w = _t
          match(_t, WILDCARD)
          _t = _t.get_next_sibling
          code = get_wildcard_st(w, ast_suffix, label_text)
          code.set_attribute("elementIndex", (w.get_token).get_index)
        when DOT
          __t89 = _t
          tmp52_ast_in = _t
          match(_t, DOT)
          _t = _t.get_first_child
          tmp53_ast_in = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          code = atom(_t, tmp53_ast_in, label, ast_suffix)
          _t = self.attr__ret_tree
          _t = __t89
          _t = _t.get_next_sibling
        when BLOCK
          code = set(_t, label, ast_suffix)
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
      return code
    end
    
    typesig { [AST] }
    def tree(_t)
      code = @templates.get_instance_of("tree")
      tree_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      el = nil
      act = nil
      el_ast = nil
      act_ast = nil
      after_down = tree_ast_in.attr_nfatree_down_state.transition(0).attr_target
      s = @grammar._look(after_down)
      if (s.member(Label::UP))
        # nullable child list if we can see the UP as the next token
        # we need an "if ( input.LA(1)==Token.DOWN )" gate around
        # the child list.
        code.set_attribute("nullableChildList", "true")
      end
      ((@rewrite_tree_nesting_level += 1) - 1)
      code.set_attribute("enclosingTreeLevel", @rewrite_tree_nesting_level - 1)
      code.set_attribute("treeLevel", @rewrite_tree_nesting_level)
      r = @grammar.get_rule(@current_rule_name)
      root_suffix = nil
      if (@grammar.build_ast && !r.has_rewrite(@outer_alt_num))
        root_suffix = GrammarAST.new(ROOT, "ROOT")
      end
      begin
        # for error handling
        __t79 = _t
        tmp54_ast_in = _t
        match(_t, TREE_BEGIN)
        _t = _t.get_first_child
        el_ast = _t
        el = element(_t, nil, root_suffix)
        _t = self.attr__ret_tree
        code.set_attribute("root.{el,line,pos}", el, Utils.integer(el_ast.get_line), Utils.integer(el_ast.get_column))
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(FORCED_ACTION) || (_t.get_type).equal?(ACTION)))
            act_ast = _t
            act = element_action(_t)
            _t = self.attr__ret_tree
            code.set_attribute("actionsAfterRoot.{el,line,pos}", act, Utils.integer(act_ast.get_line), Utils.integer(act_ast.get_column))
          else
            break
          end
        end while (true)
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(BLOCK) || (_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(CHAR_RANGE) || (_t.get_type).equal?(EPSILON) || (_t.get_type).equal?(FORCED_ACTION) || (_t.get_type).equal?(GATED_SEMPRED) || (_t.get_type).equal?(SYN_SEMPRED) || (_t.get_type).equal?(BACKTRACK_SEMPRED) || (_t.get_type).equal?(DOT) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(BANG) || (_t.get_type).equal?(PLUS_ASSIGN) || (_t.get_type).equal?(SEMPRED) || (_t.get_type).equal?(ROOT) || (_t.get_type).equal?(WILDCARD) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(NOT) || (_t.get_type).equal?(TREE_BEGIN)))
            el_ast = _t
            el = element(_t, nil, nil)
            _t = self.attr__ret_tree
            code.set_attribute("children.{el,line,pos}", el, Utils.integer(el_ast.get_line), Utils.integer(el_ast.get_column))
          else
            break
          end
        end while (true)
        _t = __t79
        _t = _t.get_next_sibling
        ((@rewrite_tree_nesting_level -= 1) + 1)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST] }
    def element_action(_t)
      code = nil
      element_action_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      act = nil
      act2 = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ACTION
          act = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          code = @templates.get_instance_of("execAction")
          code.set_attribute("action", @generator.translate_action(@current_rule_name, act))
        when FORCED_ACTION
          act2 = _t
          match(_t, FORCED_ACTION)
          _t = _t.get_next_sibling
          code = @templates.get_instance_of("execForcedAction")
          code.set_attribute("action", @generator.translate_action(@current_rule_name, act2))
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
      return code
    end
    
    typesig { [AST, GrammarAST, GrammarAST] }
    def set(_t, label, ast_suffix)
      code = nil
      set_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      s = nil
      label_text = nil
      if (!(label).nil?)
        label_text = (label.get_text).to_s
      end
      begin
        # for error handling
        s = _t
        match(_t, BLOCK)
        _t = _t.get_next_sibling
        code = get_token_element_st("matchSet", "set", s, ast_suffix, label_text)
        i = (s.get_token).get_index
        code.set_attribute("elementIndex", i)
        if (!(@grammar.attr_type).equal?(Grammar::LEXER))
          @generator.generate_local_follow(s, "set", @current_rule_name, i)
        end
        code.set_attribute("s", @generator.gen_set_expr(@templates, s.get_set_value, 1, false))
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
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
          tmp55_ast_in = _t
          match(_t, ROOT)
          _t = _t.get_next_sibling
        when BANG
          tmp56_ast_in = _t
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
    
    typesig { [AST] }
    def set_element(_t)
      set_element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      c = nil
      t = nil
      s = nil
      c1 = nil
      c2 = nil
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
        when TOKEN_REF
          t = _t
          match(_t, TOKEN_REF)
          _t = _t.get_next_sibling
        when STRING_LITERAL
          s = _t
          match(_t, STRING_LITERAL)
          _t = _t.get_next_sibling
        when CHAR_RANGE
          __t93 = _t
          tmp57_ast_in = _t
          match(_t, CHAR_RANGE)
          _t = _t.get_first_child
          c1 = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          c2 = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          _t = __t93
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
    def rewrite_alternative(_t)
      code = nil
      rewrite_alternative_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      a = nil
      el = nil
      st = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        if ((((_t.get_type).equal?(ALT))) && (@generator.attr_grammar.build_ast))
          __t102 = _t
          a = (_t).equal?(ASTNULL) ? nil : _t
          match(_t, ALT)
          _t = _t.get_first_child
          code = @templates.get_instance_of("rewriteElementList")
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when OPTIONAL, CLOSURE, POSITIVE_CLOSURE, LABEL, ACTION, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, RULE_REF, TREE_BEGIN
            _cnt105 = 0
            begin
              if ((_t).nil?)
                _t = ASTNULL
              end
              if (((_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(LABEL) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(TREE_BEGIN)))
                el_ast = _t
                el = rewrite_element(_t)
                _t = self.attr__ret_tree
                code.set_attribute("elements.{el,line,pos}", el, Utils.integer(el_ast.get_line), Utils.integer(el_ast.get_column))
              else
                if (_cnt105 >= 1)
                  break
                else
                  raise NoViableAltException.new(_t)
                end
              end
              ((_cnt105 += 1) - 1)
            end while (true)
          when EPSILON
            tmp58_ast_in = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            code.set_attribute("elements.{el,line,pos}", @templates.get_instance_of("rewriteEmptyAlt"), Utils.integer(a.get_line), Utils.integer(a.get_column))
          else
            raise NoViableAltException.new(_t)
          end
          tmp59_ast_in = _t
          match(_t, EOA)
          _t = _t.get_next_sibling
          _t = __t102
          _t = _t.get_next_sibling
        else
          if ((((_t.get_type).equal?(ALT) || (_t.get_type).equal?(TEMPLATE) || (_t.get_type).equal?(ACTION))) && (@generator.attr_grammar.build_template))
            code = rewrite_template(_t)
            _t = self.attr__ret_tree
          else
            if (((_t.get_type).equal?(ETC)))
              tmp60_ast_in = _t
              match(_t, ETC)
              _t = _t.get_next_sibling
            else
              raise NoViableAltException.new(_t)
            end
          end
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST, String] }
    def rewrite_block(_t, block_template_name)
      code = nil
      rewrite_block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      ((@rewrite_block_nesting_level += 1) - 1)
      code = @templates.get_instance_of(block_template_name)
      save_current_block_st = @current_block_st
      @current_block_st = code
      code.set_attribute("rewriteBlockLevel", @rewrite_block_nesting_level)
      alt = nil
      begin
        # for error handling
        __t100 = _t
        tmp61_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        @current_block_st.set_attribute("referencedElementsDeep", get_token_types_as_target_labels(tmp61_ast_in.attr_rewrite_refs_deep))
        @current_block_st.set_attribute("referencedElements", get_token_types_as_target_labels(tmp61_ast_in.attr_rewrite_refs_shallow))
        alt = rewrite_alternative(_t)
        _t = self.attr__ret_tree
        tmp62_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t100
        _t = _t.get_next_sibling
        code.set_attribute("alt", alt)
        ((@rewrite_block_nesting_level -= 1) + 1)
        @current_block_st = save_current_block_st
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    typesig { [AST] }
    def rewrite_element(_t)
      code = nil
      rewrite_element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      elements = nil
      ast = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LABEL, ACTION, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, RULE_REF
          code = rewrite_atom(_t, false)
          _t = self.attr__ret_tree
        when OPTIONAL, CLOSURE, POSITIVE_CLOSURE
          code = rewrite_ebnf(_t)
          _t = self.attr__ret_tree
        when TREE_BEGIN
          code = rewrite_tree(_t)
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
      return code
    end
    
    typesig { [AST] }
    def rewrite_template(_t)
      code = nil
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
          __t120 = _t
          tmp63_ast_in = _t
          match(_t, ALT)
          _t = _t.get_first_child
          tmp64_ast_in = _t
          match(_t, EPSILON)
          _t = _t.get_next_sibling
          tmp65_ast_in = _t
          match(_t, EOA)
          _t = _t.get_next_sibling
          _t = __t120
          _t = _t.get_next_sibling
          code = @templates.get_instance_of("rewriteEmptyTemplate")
        when TEMPLATE
          __t121 = _t
          tmp66_ast_in = _t
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
          if (!(id).nil? && (id.get_text == "template"))
            code = @templates.get_instance_of("rewriteInlineTemplate")
          else
            if (!(id).nil?)
              code = @templates.get_instance_of("rewriteExternalTemplate")
              code.set_attribute("name", id.get_text)
            else
              if (!(ind).nil?)
                # must be %({expr})(args)
                code = @templates.get_instance_of("rewriteIndirectTemplate")
                chunks = @generator.translate_action(@current_rule_name, ind)
                code.set_attribute("expr", chunks)
              end
            end
          end
          __t123 = _t
          tmp67_ast_in = _t
          match(_t, ARGLIST)
          _t = _t.get_first_child
          begin
            if ((_t).nil?)
              _t = ASTNULL
            end
            if (((_t.get_type).equal?(ARG)))
              __t125 = _t
              tmp68_ast_in = _t
              match(_t, ARG)
              _t = _t.get_first_child
              arg = _t
              match(_t, ID)
              _t = _t.get_next_sibling
              a = _t
              match(_t, ACTION)
              _t = _t.get_next_sibling
              # must set alt num here rather than in define.g
              # because actions like %foo(name={$ID.text}) aren't
              # broken up yet into trees.
              a.attr_outer_alt_num = @outer_alt_num
              chunks = @generator.translate_action(@current_rule_name, a)
              code.set_attribute("args.{name,value}", arg.get_text, chunks)
              _t = __t125
              _t = _t.get_next_sibling
            else
              break
            end
          end while (true)
          _t = __t123
          _t = _t.get_next_sibling
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when DOUBLE_QUOTE_STRING_LITERAL
            tmp69_ast_in = _t
            match(_t, DOUBLE_QUOTE_STRING_LITERAL)
            _t = _t.get_next_sibling
            sl = tmp69_ast_in.get_text
            t = sl.substring(1, sl.length - 1) # strip quotes
            t = (@generator.attr_target.get_target_string_literal_from_string(t)).to_s
            code.set_attribute("template", t)
          when DOUBLE_ANGLE_STRING_LITERAL
            tmp70_ast_in = _t
            match(_t, DOUBLE_ANGLE_STRING_LITERAL)
            _t = _t.get_next_sibling
            sl = tmp70_ast_in.get_text
            t = sl.substring(2, sl.length - 2) # strip double angle quotes
            t = (@generator.attr_target.get_target_string_literal_from_string(t)).to_s
            code.set_attribute("template", t)
          when 3
          else
            raise NoViableAltException.new(_t)
          end
          _t = __t121
          _t = _t.get_next_sibling
        when ACTION
          act = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          # set alt num for same reason as ARGLIST above
          act.attr_outer_alt_num = @outer_alt_num
          code = @templates.get_instance_of("rewriteAction")
          code.set_attribute("action", @generator.translate_action(@current_rule_name, act))
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
      return code
    end
    
    typesig { [AST, ::Java::Boolean] }
    def rewrite_atom(_t, is_root)
      code = nil
      rewrite_atom_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      r = nil
      tk = nil
      arg = nil
      cl = nil
      sl = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when RULE_REF
          r = _t
          match(_t, RULE_REF)
          _t = _t.get_next_sibling
          rule_ref_name = r.get_text
          st_name = "rewriteRuleRef"
          if (is_root)
            st_name += "Root"
          end
          code = @templates.get_instance_of(st_name)
          code.set_attribute("rule", rule_ref_name)
          if ((@grammar.get_rule(rule_ref_name)).nil?)
            ErrorManager.grammar_error(ErrorManager::MSG_UNDEFINED_RULE_REF, @grammar, ((r)).get_token, rule_ref_name)
            code = StringTemplate.new # blank; no code gen
          else
            if ((@grammar.get_rule(@current_rule_name).get_rule_refs_in_alt(rule_ref_name, @outer_alt_num)).nil?)
              ErrorManager.grammar_error(ErrorManager::MSG_REWRITE_ELEMENT_NOT_PRESENT_ON_LHS, @grammar, ((r)).get_token, rule_ref_name)
              code = StringTemplate.new # blank; no code gen
            else
              # track all rule refs as we must copy 2nd ref to rule and beyond
              if (!@rewrite_rule_refs.contains(rule_ref_name))
                @rewrite_rule_refs.add(rule_ref_name)
              end
            end
          end
        when STRING_LITERAL, CHAR_LITERAL, TOKEN_REF
          term = _t
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when TOKEN_REF
            __t117 = _t
            tk = (_t).equal?(ASTNULL) ? nil : _t
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
            _t = __t117
            _t = _t.get_next_sibling
          when CHAR_LITERAL
            cl = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
          when STRING_LITERAL
            sl = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_next_sibling
          else
            raise NoViableAltException.new(_t)
          end
          token_name = rewrite_atom_ast_in.get_text
          st_name = "rewriteTokenRef"
          rule_ = @grammar.get_rule(@current_rule_name)
          token_refs_in_alt = rule_.get_token_refs_in_alt(@outer_alt_num)
          create_new_node = !token_refs_in_alt.contains(token_name) || !(arg).nil?
          hetero = nil
          if (!(term.attr_terminal_options).nil?)
            hetero = term.attr_terminal_options.get(Grammar.attr_default_token_option)
          end
          if (create_new_node)
            st_name = "rewriteImaginaryTokenRef"
          end
          if (is_root)
            st_name += "Root"
          end
          code = @templates.get_instance_of(st_name)
          code.set_attribute("hetero", hetero)
          if (!(arg).nil?)
            args = @generator.translate_action(@current_rule_name, arg)
            code.set_attribute("args", args)
          end
          code.set_attribute("elementIndex", (rewrite_atom_ast_in.get_token).get_index)
          ttype = @grammar.get_token_type(token_name)
          tok = @generator.get_token_type_as_target_label(ttype)
          code.set_attribute("token", tok)
          if ((@grammar.get_token_type(token_name)).equal?(Label::INVALID))
            ErrorManager.grammar_error(ErrorManager::MSG_UNDEFINED_TOKEN_REF_IN_REWRITE, @grammar, ((rewrite_atom_ast_in)).get_token, token_name)
            code = StringTemplate.new # blank; no code gen
          end
        when LABEL
          tmp71_ast_in = _t
          match(_t, LABEL)
          _t = _t.get_next_sibling
          label_name = tmp71_ast_in.get_text
          rule_ = @grammar.get_rule(@current_rule_name)
          pair = rule_.get_label(label_name)
          if ((label_name == @current_rule_name))
            # special case; ref to old value via $rule
            if (rule_.has_rewrite(@outer_alt_num) && rule_.get_rule_refs_in_alt(@outer_alt_num).contains(label_name))
              ErrorManager.grammar_error(ErrorManager::MSG_RULE_REF_AMBIG_WITH_RULE_IN_ALT, @grammar, ((tmp71_ast_in)).get_token, label_name)
            end
            label_st = @templates.get_instance_of("prevRuleRootRef")
            code = @templates.get_instance_of("rewriteRuleLabelRef" + ((is_root ? "Root" : "")).to_s)
            code.set_attribute("label", label_st)
          else
            if ((pair).nil?)
              ErrorManager.grammar_error(ErrorManager::MSG_UNDEFINED_LABEL_REF_IN_REWRITE, @grammar, ((tmp71_ast_in)).get_token, label_name)
              code = StringTemplate.new
            else
              st_name = nil
              case (pair.attr_type)
              when Grammar::TOKEN_LABEL
                st_name = "rewriteTokenLabelRef"
              when Grammar::RULE_LABEL
                st_name = "rewriteRuleLabelRef"
              when Grammar::TOKEN_LIST_LABEL
                st_name = "rewriteTokenListLabelRef"
              when Grammar::RULE_LIST_LABEL
                st_name = "rewriteRuleListLabelRef"
              end
              if (is_root)
                st_name += "Root"
              end
              code = @templates.get_instance_of(st_name)
              code.set_attribute("label", label_name)
            end
          end
        when ACTION
          tmp72_ast_in = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          # actions in rewrite rules yield a tree object
          act_text = tmp72_ast_in.get_text
          chunks = @generator.translate_action(@current_rule_name, tmp72_ast_in)
          code = @templates.get_instance_of("rewriteNodeAction" + ((is_root ? "Root" : "")).to_s)
          code.set_attribute("action", chunks)
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
      return code
    end
    
    typesig { [AST] }
    def rewrite_ebnf(_t)
      code = nil
      rewrite_ebnf_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONAL
          __t108 = _t
          tmp73_ast_in = _t
          match(_t, OPTIONAL)
          _t = _t.get_first_child
          code = rewrite_block(_t, "rewriteOptionalBlock")
          _t = self.attr__ret_tree
          _t = __t108
          _t = _t.get_next_sibling
          description = @grammar.grammar_tree_to_string(rewrite_ebnf_ast_in, false)
          description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
          code.set_attribute("description", description)
        when CLOSURE
          __t109 = _t
          tmp74_ast_in = _t
          match(_t, CLOSURE)
          _t = _t.get_first_child
          code = rewrite_block(_t, "rewriteClosureBlock")
          _t = self.attr__ret_tree
          _t = __t109
          _t = _t.get_next_sibling
          description = @grammar.grammar_tree_to_string(rewrite_ebnf_ast_in, false)
          description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
          code.set_attribute("description", description)
        when POSITIVE_CLOSURE
          __t110 = _t
          tmp75_ast_in = _t
          match(_t, POSITIVE_CLOSURE)
          _t = _t.get_first_child
          code = rewrite_block(_t, "rewritePositiveClosureBlock")
          _t = self.attr__ret_tree
          _t = __t110
          _t = _t.get_next_sibling
          description = @grammar.grammar_tree_to_string(rewrite_ebnf_ast_in, false)
          description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
          code.set_attribute("description", description)
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
      return code
    end
    
    typesig { [AST] }
    def rewrite_tree(_t)
      code = @templates.get_instance_of("rewriteTree")
      rewrite_tree_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      ((@rewrite_tree_nesting_level += 1) - 1)
      code.set_attribute("treeLevel", @rewrite_tree_nesting_level)
      code.set_attribute("enclosingTreeLevel", @rewrite_tree_nesting_level - 1)
      r = nil
      el = nil
      el_ast = nil
      begin
        # for error handling
        __t112 = _t
        tmp76_ast_in = _t
        match(_t, TREE_BEGIN)
        _t = _t.get_first_child
        el_ast = _t
        r = rewrite_atom(_t, true)
        _t = self.attr__ret_tree
        code.set_attribute("root.{el,line,pos}", r, Utils.integer(el_ast.get_line), Utils.integer(el_ast.get_column))
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(LABEL) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(TREE_BEGIN)))
            el_ast = _t
            el = rewrite_element(_t)
            _t = self.attr__ret_tree
            code.set_attribute("children.{el,line,pos}", el, Utils.integer(el_ast.get_line), Utils.integer(el_ast.get_column))
          else
            break
          end
        end while (true)
        _t = __t112
        _t = _t.get_next_sibling
        description = @grammar.grammar_tree_to_string(rewrite_tree_ast_in, false)
        description = (@generator.attr_target.get_target_string_literal_from_string(description)).to_s
        code.set_attribute("description", description)
        ((@rewrite_tree_nesting_level -= 1) + 1)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return code
    end
    
    class_module.module_eval {
      const_set_lazy(:_tokenNames) { Array.typed(String).new(["<0>", "EOF", "<2>", "NULL_TREE_LOOKAHEAD", "\"options\"", "\"tokens\"", "\"parser\"", "LEXER", "RULE", "BLOCK", "OPTIONAL", "CLOSURE", "POSITIVE_CLOSURE", "SYNPRED", "RANGE", "CHAR_RANGE", "EPSILON", "ALT", "EOR", "EOB", "EOA", "ID", "ARG", "ARGLIST", "RET", "LEXER_GRAMMAR", "PARSER_GRAMMAR", "TREE_GRAMMAR", "COMBINED_GRAMMAR", "INITACTION", "FORCED_ACTION", "LABEL", "TEMPLATE", "\"scope\"", "\"import\"", "GATED_SEMPRED", "SYN_SEMPRED", "BACKTRACK_SEMPRED", "\"fragment\"", "DOT", "ACTION", "DOC_COMMENT", "SEMI", "\"lexer\"", "\"tree\"", "\"grammar\"", "AMPERSAND", "COLON", "RCURLY", "ASSIGN", "STRING_LITERAL", "CHAR_LITERAL", "INT", "STAR", "COMMA", "TOKEN_REF", "\"protected\"", "\"public\"", "\"private\"", "BANG", "ARG_ACTION", "\"returns\"", "\"throws\"", "LPAREN", "OR", "RPAREN", "\"catch\"", "\"finally\"", "PLUS_ASSIGN", "SEMPRED", "IMPLIES", "ROOT", "WILDCARD", "RULE_REF", "NOT", "TREE_BEGIN", "QUESTION", "PLUS", "OPEN_ELEMENT_OPTION", "CLOSE_ELEMENT_OPTION", "REWRITE", "ETC", "DOLLAR", "DOUBLE_QUOTE_STRING_LITERAL", "DOUBLE_ANGLE_STRING_LITERAL", "WS", "COMMENT", "SL_COMMENT", "ML_COMMENT", "STRAY_BRACKET", "ESC", "DIGIT", "XDIGIT", "NESTED_ARG_ACTION", "NESTED_ACTION", "ACTION_CHAR_LITERAL", "ACTION_STRING_LITERAL", "ACTION_ESC", "WS_LOOP", "INTERNAL_RULE_REF", "WS_OPT", "SRC"]) }
      const_attr_reader  :_tokenNames
    }
    
    private
    alias_method :initialize__code_gen_tree_walker, :initialize
  end
  
end
