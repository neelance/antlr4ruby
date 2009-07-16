require "rjava"
 # $ANTLR 2.7.7 (2006-01-29): "buildnfa.g" -> "TreeToNFAConverter.java"$
# 
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
  module TreeToNFAConverterImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Java::Util
      include ::Org::Antlr::Analysis
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
  
  # Build an NFA from a tree representing an ANTLR grammar.
  class TreeToNFAConverter < Antlr::TreeParser
    include_class_members TreeToNFAConverterImports
    include TreeToNFAConverterTokenTypes
    
    # Factory used to create nodes and submachines
    attr_accessor :factory
    alias_method :attr_factory, :factory
    undef_method :factory
    alias_method :attr_factory=, :factory=
    undef_method :factory=
    
    # Which NFA object are we filling in?
    attr_accessor :nfa
    alias_method :attr_nfa, :nfa
    undef_method :nfa
    alias_method :attr_nfa=, :nfa=
    undef_method :nfa=
    
    # Which grammar are we converting an NFA for?
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
    
    typesig { [Grammar, NFA, NFAFactory] }
    def initialize(g, nfa, factory)
      initialize__tree_to_nfaconverter()
      @grammar = g
      @nfa = nfa
      @factory = factory
    end
    
    typesig { [String, NFAState] }
    # 
    # protected void init() {
    # // define all the rule begin/end NFAStates to solve forward reference issues
    # Collection rules = grammar.getRules();
    # for (Iterator itr = rules.iterator(); itr.hasNext();) {
    # Rule r = (Rule) itr.next();
    # String ruleName = r.name;
    # NFAState ruleBeginState = factory.newState();
    # ruleBeginState.setDescription("rule "+ruleName+" start");
    # ruleBeginState.enclosingRule = r;
    # r.startState = ruleBeginState;
    # NFAState ruleEndState = factory.newState();
    # ruleEndState.setDescription("rule "+ruleName+" end");
    # ruleEndState.setAcceptState(true);
    # ruleEndState.enclosingRule = r;
    # r.stopState = ruleEndState;
    # }
    # }
    def add_follow_transition(rule_name, following)
      # System.out.println("adding follow link to rule "+ruleName);
      # find last link in FOLLOW chain emanating from rule
      r = @grammar.get_rule(rule_name)
      end_ = r.attr_stop_state
      while (!(end_.transition(1)).nil?)
        end_ = end_.transition(1).attr_target
      end
      if (!(end_.transition(0)).nil?)
        # already points to a following node
        # gotta add another node to keep edges to a max of 2
        n = @factory.new_state
        e = Transition.new(Label::EPSILON, n)
        end_.add_transition(e)
        end_ = n
      end
      follow_edge = Transition.new(Label::EPSILON, following)
      end_.add_transition(follow_edge)
    end
    
    typesig { [] }
    def finish
      rules = LinkedList.new
      rules.add_all(@grammar.get_rules)
      num_entry_points = @factory.build__eofstates(rules)
      if ((num_entry_points).equal?(0))
        ErrorManager.grammar_warning(ErrorManager::MSG_NO_GRAMMAR_START_RULE, @grammar, nil, @grammar.attr_name)
      end
    end
    
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
      ErrorManager.syntax_error(ErrorManager::MSG_SYNTAX_ERROR, @grammar, token, "buildnfa: " + (ex.to_s).to_s, ex)
    end
    
    typesig { [] }
    def initialize
      @factory = nil
      @nfa = nil
      @grammar = nil
      @current_rule_name = nil
      @outer_alt_num = 0
      @block_level = 0
      super()
      @factory = nil
      @nfa = nil
      @grammar = nil
      @current_rule_name = nil
      @outer_alt_num = 0
      @block_level = 0
      self.attr_token_names = _tokenNames
    end
    
    typesig { [AST] }
    def grammar(_t)
      grammar_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
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
            throw :break_case, :thrown
            __t4 = _t
            tmp2_ast_in = _t
            match(_t, PARSER_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t4
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t5 = _t
            tmp3_ast_in = _t
            match(_t, TREE_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t5
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t6 = _t
            tmp4_ast_in = _t
            match(_t, COMBINED_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t6
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when PARSER_GRAMMAR
            __t4_ = _t
            tmp2_ast_in_ = _t
            match(_t, PARSER_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t4_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t5_ = _t
            tmp3_ast_in_ = _t
            match(_t, TREE_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t5_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t6_ = _t
            tmp4_ast_in_ = _t
            match(_t, COMBINED_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t6_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when TREE_GRAMMAR
            __t5__ = _t
            tmp3_ast_in__ = _t
            match(_t, TREE_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t5__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t6__ = _t
            tmp4_ast_in__ = _t
            match(_t, COMBINED_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t6__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when COMBINED_GRAMMAR
            __t6___ = _t
            tmp4_ast_in___ = _t
            match(_t, COMBINED_GRAMMAR)
            _t = _t.get_first_child
            grammar_spec(_t)
            _t = self.attr__ret_tree
            _t = __t6___
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        finish
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
      cmt = nil
      begin
        # for error handling
        tmp5_ast_in = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when DOC_COMMENT
            cmt = _t
            match(_t, DOC_COMMENT)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when OPTIONS, TOKENS, RULE, SCOPE, IMPORT, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when OPTIONS
            __t12 = _t
            tmp6_ast_in = _t
            match(_t, OPTIONS)
            _t = _t.get_first_child
            tmp7_ast_in = _t
            if ((_t).nil?)
              raise MismatchedTokenException.new
            end
            _t = _t.get_next_sibling
            _t = __t12
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when TOKENS, RULE, SCOPE, IMPORT, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when IMPORT
            __t14 = _t
            tmp8_ast_in = _t
            match(_t, IMPORT)
            _t = _t.get_first_child
            tmp9_ast_in = _t
            if ((_t).nil?)
              raise MismatchedTokenException.new
            end
            _t = _t.get_next_sibling
            _t = __t14
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when TOKENS, RULE, SCOPE, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when TOKENS
            __t16 = _t
            tmp10_ast_in = _t
            match(_t, TOKENS)
            _t = _t.get_first_child
            tmp11_ast_in = _t
            if ((_t).nil?)
              raise MismatchedTokenException.new
            end
            _t = _t.get_next_sibling
            _t = __t16
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when RULE, SCOPE, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
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
            tmp12_ast_in = _t
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
    def attr_scope(_t)
      attr_scope_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t8 = _t
        tmp13_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        tmp14_ast_in = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        tmp15_ast_in = _t
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
    
    typesig { [AST] }
    def rules(_t)
      rules_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        _cnt23 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(RULE)))
            rule(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt23 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          ((_cnt23 += 1) - 1)
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
      rule_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      g = nil
      b = nil
      r = nil
      begin
        # for error handling
        __t25 = _t
        tmp16_ast_in = _t
        match(_t, RULE)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        r = (id.get_text).to_s
        @current_rule_name = r
        @factory.attr_current_rule = @grammar.get_locally_defined_rule(r)
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when FRAGMENT, LITERAL_protected, LITERAL_public, LITERAL_private
            modifier(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when ARG
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        tmp17_ast_in = _t
        match(_t, ARG)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when ARG_ACTION
            tmp18_ast_in = _t
            match(_t, ARG_ACTION)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when RET
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        tmp19_ast_in = _t
        match(_t, RET)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when ARG_ACTION
            tmp20_ast_in = _t
            match(_t, ARG_ACTION)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when OPTIONS, BLOCK, SCOPE, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when OPTIONS
            tmp21_ast_in = _t
            match(_t, OPTIONS)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BLOCK, SCOPE, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when SCOPE
            rule_scope_spec(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BLOCK, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            tmp22_ast_in = _t
            match(_t, AMPERSAND)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        blk = _t
        b = block(_t)
        _t = self.attr__ret_tree
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when LITERAL_catch, LITERAL_finally
            exception_group(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when EOR
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        tmp23_ast_in = _t
        match(_t, EOR)
        _t = _t.get_next_sibling
        if (!(blk.attr_set_value).nil?)
          # if block comes back as a set not BLOCK, make it
          # a single ALT block
          b = @factory.build__alternative_block_from_set(b)
        end
        if (Character.is_lower_case(r.char_at(0)) || (@grammar.attr_type).equal?(Grammar::LEXER))
          # attach start node to block for this rule
          this_r = @grammar.get_locally_defined_rule(r)
          start = this_r.attr_start_state
          start.attr_associated_astnode = id
          start.add_transition(Transition.new(Label::EPSILON, b.attr_left))
          # track decision if > 1 alts
          if (@grammar.get_number_of_alts_for_decision_nfa(b.attr_left) > 1)
            b.attr_left.set_description(@grammar.grammar_tree_to_string(rule_ast_in, false))
            b.attr_left.set_decision_astnode(blk)
            d = @grammar.assign_decision_number(b.attr_left)
            @grammar.set_decision_nfa(d, b.attr_left)
            @grammar.set_decision_block_ast(d, blk)
          end
          # hook to end of rule node
          end_ = this_r.attr_stop_state
          b.attr_right.add_transition(Transition.new(Label::EPSILON, end_))
        end
        _t = __t25
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
        catch(:break_case) do
          case (_t.get_type)
          when LITERAL_protected
            tmp24_ast_in = _t
            match(_t, LITERAL_protected)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp25_ast_in = _t
            match(_t, LITERAL_public)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp26_ast_in = _t
            match(_t, LITERAL_private)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp27_ast_in = _t
            match(_t, FRAGMENT)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when LITERAL_public
            tmp25_ast_in_ = _t
            match(_t, LITERAL_public)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp26_ast_in_ = _t
            match(_t, LITERAL_private)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp27_ast_in_ = _t
            match(_t, FRAGMENT)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when LITERAL_private
            tmp26_ast_in__ = _t
            match(_t, LITERAL_private)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp27_ast_in__ = _t
            match(_t, FRAGMENT)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when FRAGMENT
            tmp27_ast_in___ = _t
            match(_t, FRAGMENT)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
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
    end
    
    typesig { [AST] }
    def rule_scope_spec(_t)
      rule_scope_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t38 = _t
        tmp28_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when ACTION
            tmp29_ast_in = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when 3, ID
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ID)))
            tmp30_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        _t = __t38
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
      g = nil
      block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      a = nil
      alts = LinkedList.new
      ((@block_level += 1) - 1)
      if ((@block_level).equal?(1))
        @outer_alt_num = 1
      end
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        if ((((_t.get_type).equal?(BLOCK))) && (@grammar.is_valid_set(self, block_ast_in) && !(@current_rule_name == Grammar::ARTIFICIAL_TOKENS_RULENAME)))
          g = set(_t)
          _t = self.attr__ret_tree
          ((@block_level -= 1) + 1)
        else
          if (((_t.get_type).equal?(BLOCK)))
            __t43 = _t
            tmp31_ast_in = _t
            match(_t, BLOCK)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when OPTIONS
                tmp32_ast_in = _t
                match(_t, OPTIONS)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when ALT
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _cnt46 = 0
            begin
              if ((_t).nil?)
                _t = ASTNULL
              end
              if (((_t.get_type).equal?(ALT)))
                a = alternative(_t)
                _t = self.attr__ret_tree
                rewrite(_t)
                _t = self.attr__ret_tree
                alts.add(a)
                if ((@block_level).equal?(1))
                  ((@outer_alt_num += 1) - 1)
                end
              else
                if (_cnt46 >= 1)
                  break
                else
                  raise NoViableAltException.new(_t)
                end
              end
              ((_cnt46 += 1) - 1)
            end while (true)
            tmp33_ast_in = _t
            match(_t, EOB)
            _t = _t.get_next_sibling
            _t = __t43
            _t = _t.get_next_sibling
            g = @factory.build__alternative_block(alts)
            ((@block_level -= 1) + 1)
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
      return g
    end
    
    typesig { [AST] }
    def exception_group(_t)
      exception_group_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when LITERAL_catch
            _cnt53 = 0
            begin
              if ((_t).nil?)
                _t = ASTNULL
              end
              if (((_t.get_type).equal?(LITERAL_catch)))
                exception_handler(_t)
                _t = self.attr__ret_tree
              else
                if (_cnt53 >= 1)
                  break
                else
                  raise NoViableAltException.new(_t)
                end
              end
              ((_cnt53 += 1) - 1)
            end while (true)
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when LITERAL_finally
                finally_clause(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when EOR
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            throw :break_case, :thrown
            finally_clause(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when LITERAL_finally
            finally_clause(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
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
    end
    
    typesig { [AST] }
    def set(_t)
      g = nil
      set_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      b = nil
      elements = IntervalSet.new
      set_ast_in.set_set_value(elements) # track set for use by code gen
      begin
        # for error handling
        __t102 = _t
        b = (_t).equal?(ASTNULL) ? nil : _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        _cnt106 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            __t104 = _t
            tmp34_ast_in = _t
            match(_t, ALT)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BACKTRACK_SEMPRED
                tmp35_ast_in = _t
                match(_t, BACKTRACK_SEMPRED)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when BLOCK, CHAR_RANGE, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, NOT
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end == :thrown or break
            set_element(_t, elements)
            _t = self.attr__ret_tree
            tmp36_ast_in = _t
            match(_t, EOA)
            _t = _t.get_next_sibling
            _t = __t104
            _t = _t.get_next_sibling
          else
            if (_cnt106 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          ((_cnt106 += 1) - 1)
        end while (true)
        tmp37_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t102
        _t = _t.get_next_sibling
        g = @factory.build__set(elements, b)
        b.attr_following_nfastate = g.attr_right
        b.attr_set_value = elements # track set value of this block
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return g
    end
    
    typesig { [AST] }
    def alternative(_t)
      g = nil
      alternative_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      e = nil
      begin
        # for error handling
        __t48 = _t
        tmp38_ast_in = _t
        match(_t, ALT)
        _t = _t.get_first_child
        _cnt50 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if ((_tokenSet_0.member(_t.get_type)))
            e = element(_t)
            _t = self.attr__ret_tree
            g = @factory.build__ab(g, e)
          else
            if (_cnt50 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          ((_cnt50 += 1) - 1)
        end while (true)
        _t = __t48
        _t = _t.get_next_sibling
        if ((g).nil?)
          # if alt was a list of actions or whatever
          g = @factory.build__epsilon
        else
          @factory.optimize_alternative(g)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return g
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
            if ((@grammar.get_option("output")).nil?)
              ErrorManager.grammar_error(ErrorManager::MSG_REWRITE_OR_OP_WITH_NO_OUTPUT_OPTION, @grammar, rewrite_ast_in.attr_token, @current_rule_name)
            end
            __t61 = _t
            tmp39_ast_in = _t
            match(_t, REWRITE)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when SEMPRED
                tmp40_ast_in = _t
                match(_t, SEMPRED)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when ALT, TEMPLATE, ACTION, ETC
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end == :thrown or break
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when ALT
                tmp41_ast_in = _t
                match(_t, ALT)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                tmp42_ast_in = _t
                match(_t, TEMPLATE)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                tmp43_ast_in = _t
                match(_t, ACTION)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                tmp44_ast_in = _t
                match(_t, ETC)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when TEMPLATE
                tmp42_ast_in_ = _t
                match(_t, TEMPLATE)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                tmp43_ast_in_ = _t
                match(_t, ACTION)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                tmp44_ast_in_ = _t
                match(_t, ETC)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when ACTION
                tmp43_ast_in__ = _t
                match(_t, ACTION)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                tmp44_ast_in__ = _t
                match(_t, ETC)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when ETC
                tmp44_ast_in___ = _t
                match(_t, ETC)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end == :thrown or break
            _t = __t61
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
      g = nil
      element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      a = nil
      b = nil
      c1 = nil
      c2 = nil
      pred = nil
      spred = nil
      bpred = nil
      gpred = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when ROOT
            __t66 = _t
            tmp45_ast_in = _t
            match(_t, ROOT)
            _t = _t.get_first_child
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t66
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t67 = _t
            tmp46_ast_in = _t
            match(_t, BANG)
            _t = _t.get_first_child
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t67
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t68 = _t
            tmp47_ast_in = _t
            match(_t, ASSIGN)
            _t = _t.get_first_child
            tmp48_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t68
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t69 = _t
            tmp49_ast_in = _t
            match(_t, PLUS_ASSIGN)
            _t = _t.get_first_child
            tmp50_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t69
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t70 = _t
            tmp51_ast_in = _t
            match(_t, RANGE)
            _t = _t.get_first_child
            a = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            b = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            _t = __t70
            _t = _t.get_next_sibling
            g = @factory.build__range(@grammar.get_token_type(a.get_text), @grammar.get_token_type(b.get_text))
            throw :break_case, :thrown
            __t71 = _t
            tmp52_ast_in = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t71
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_range(c1.get_text, c2.get_text)
            end
            throw :break_case, :thrown
            g = atom_or_notatom(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = ebnf(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72 = _t
            tmp53_ast_in = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in)
            throw :break_case, :thrown
            tmp55_ast_in = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BANG
            __t67_ = _t
            tmp46_ast_in_ = _t
            match(_t, BANG)
            _t = _t.get_first_child
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t67_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t68_ = _t
            tmp47_ast_in_ = _t
            match(_t, ASSIGN)
            _t = _t.get_first_child
            tmp48_ast_in_ = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t68_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t69_ = _t
            tmp49_ast_in_ = _t
            match(_t, PLUS_ASSIGN)
            _t = _t.get_first_child
            tmp50_ast_in_ = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t69_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t70_ = _t
            tmp51_ast_in_ = _t
            match(_t, RANGE)
            _t = _t.get_first_child
            a = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            b = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            _t = __t70_
            _t = _t.get_next_sibling
            g = @factory.build__range(@grammar.get_token_type(a.get_text), @grammar.get_token_type(b.get_text))
            throw :break_case, :thrown
            __t71_ = _t
            tmp52_ast_in_ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t71_
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_range(c1.get_text, c2.get_text)
            end
            throw :break_case, :thrown
            g = atom_or_notatom(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = ebnf(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72_ = _t
            tmp53_ast_in_ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in_ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in_)
            throw :break_case, :thrown
            tmp55_ast_in_ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in_)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in_ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when ASSIGN
            __t68__ = _t
            tmp47_ast_in__ = _t
            match(_t, ASSIGN)
            _t = _t.get_first_child
            tmp48_ast_in__ = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t68__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t69__ = _t
            tmp49_ast_in__ = _t
            match(_t, PLUS_ASSIGN)
            _t = _t.get_first_child
            tmp50_ast_in__ = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t69__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t70__ = _t
            tmp51_ast_in__ = _t
            match(_t, RANGE)
            _t = _t.get_first_child
            a = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            b = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            _t = __t70__
            _t = _t.get_next_sibling
            g = @factory.build__range(@grammar.get_token_type(a.get_text), @grammar.get_token_type(b.get_text))
            throw :break_case, :thrown
            __t71__ = _t
            tmp52_ast_in__ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t71__
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_range(c1.get_text, c2.get_text)
            end
            throw :break_case, :thrown
            g = atom_or_notatom(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = ebnf(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72__ = _t
            tmp53_ast_in__ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in__ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in__)
            throw :break_case, :thrown
            tmp55_ast_in__ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in__)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in__ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when PLUS_ASSIGN
            __t69___ = _t
            tmp49_ast_in___ = _t
            match(_t, PLUS_ASSIGN)
            _t = _t.get_first_child
            tmp50_ast_in___ = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = element(_t)
            _t = self.attr__ret_tree
            _t = __t69___
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            __t70___ = _t
            tmp51_ast_in___ = _t
            match(_t, RANGE)
            _t = _t.get_first_child
            a = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            b = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            _t = __t70___
            _t = _t.get_next_sibling
            g = @factory.build__range(@grammar.get_token_type(a.get_text), @grammar.get_token_type(b.get_text))
            throw :break_case, :thrown
            __t71___ = _t
            tmp52_ast_in___ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t71___
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_range(c1.get_text, c2.get_text)
            end
            throw :break_case, :thrown
            g = atom_or_notatom(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = ebnf(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72___ = _t
            tmp53_ast_in___ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72___
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in___ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in___)
            throw :break_case, :thrown
            tmp55_ast_in___ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in___)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in___ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when RANGE
            __t70____ = _t
            tmp51_ast_in____ = _t
            match(_t, RANGE)
            _t = _t.get_first_child
            a = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            b = (_t).equal?(ASTNULL) ? nil : _t
            atom(_t, nil)
            _t = self.attr__ret_tree
            _t = __t70____
            _t = _t.get_next_sibling
            g = @factory.build__range(@grammar.get_token_type(a.get_text), @grammar.get_token_type(b.get_text))
            throw :break_case, :thrown
            __t71____ = _t
            tmp52_ast_in____ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t71____
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_range(c1.get_text, c2.get_text)
            end
            throw :break_case, :thrown
            g = atom_or_notatom(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = ebnf(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72____ = _t
            tmp53_ast_in____ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72____
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in____ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in____)
            throw :break_case, :thrown
            tmp55_ast_in____ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in____)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in____ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when CHAR_RANGE
            __t71_____ = _t
            tmp52_ast_in_____ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t71_____
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_range(c1.get_text, c2.get_text)
            end
            throw :break_case, :thrown
            g = atom_or_notatom(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = ebnf(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72_____ = _t
            tmp53_ast_in_____ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72_____
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in_____ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in_____)
            throw :break_case, :thrown
            tmp55_ast_in_____ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in_____)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in_____ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when DOT, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, WILDCARD, RULE_REF, NOT
            g = atom_or_notatom(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = ebnf(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72______ = _t
            tmp53_ast_in______ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72______
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in______ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in______)
            throw :break_case, :thrown
            tmp55_ast_in______ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in______)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in______ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BLOCK, OPTIONAL, CLOSURE, POSITIVE_CLOSURE
            g = ebnf(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72_______ = _t
            tmp53_ast_in_______ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72_______
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in_______ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in_______)
            throw :break_case, :thrown
            tmp55_ast_in_______ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in_______)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in_______ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when TREE_BEGIN
            g = tree(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t72________ = _t
            tmp53_ast_in________ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72________
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in________ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in________)
            throw :break_case, :thrown
            tmp55_ast_in________ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in________)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when SYNPRED
            __t72_________ = _t
            tmp53_ast_in_________ = _t
            match(_t, SYNPRED)
            _t = _t.get_first_child
            block(_t)
            _t = self.attr__ret_tree
            _t = __t72_________
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp54_ast_in_________ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in_________)
            throw :break_case, :thrown
            tmp55_ast_in_________ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in_________)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in_________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when ACTION
            tmp54_ast_in__________ = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp54_ast_in__________)
            throw :break_case, :thrown
            tmp55_ast_in__________ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in__________)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in__________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when FORCED_ACTION
            tmp55_ast_in___________ = _t
            match(_t, FORCED_ACTION)
            _t = _t.get_next_sibling
            g = @factory.build__action(tmp55_ast_in___________)
            throw :break_case, :thrown
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in___________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when SEMPRED
            pred = _t
            match(_t, SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(pred)
            throw :break_case, :thrown
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in____________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when SYN_SEMPRED
            spred = _t
            match(_t, SYN_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(spred)
            throw :break_case, :thrown
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in_____________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BACKTRACK_SEMPRED
            bpred = _t
            match(_t, BACKTRACK_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(bpred)
            throw :break_case, :thrown
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in______________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when GATED_SEMPRED
            gpred = _t
            match(_t, GATED_SEMPRED)
            _t = _t.get_next_sibling
            g = @factory.build__semantic_predicate(gpred)
            throw :break_case, :thrown
            tmp56_ast_in_______________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when EPSILON
            tmp56_ast_in________________ = _t
            match(_t, EPSILON)
            _t = _t.get_next_sibling
            g = @factory.build__epsilon
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
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
      return g
    end
    
    typesig { [AST] }
    def exception_handler(_t)
      exception_handler_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t56 = _t
        tmp57_ast_in = _t
        match(_t, LITERAL_catch)
        _t = _t.get_first_child
        tmp58_ast_in = _t
        match(_t, ARG_ACTION)
        _t = _t.get_next_sibling
        tmp59_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t56
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
        __t58 = _t
        tmp60_ast_in = _t
        match(_t, LITERAL_finally)
        _t = _t.get_first_child
        tmp61_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t58
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, String] }
    def atom(_t, scope_name)
      g = nil
      atom_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      r = nil
      rarg = nil
      as1 = nil
      t = nil
      targ = nil
      as2 = nil
      c = nil
      as3 = nil
      s = nil
      as4 = nil
      w = nil
      as5 = nil
      scope = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when RULE_REF
            __t87 = _t
            r = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, RULE_REF)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when ARG_ACTION
                rarg = _t
                match(_t, ARG_ACTION)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3, BANG, ROOT
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as1 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t87
            _t = _t.get_next_sibling
            start = @grammar.get_rule_start_state(scope_name, r.get_text)
            if (!(start).nil?)
              rr = @grammar.get_rule(scope_name, r.get_text)
              g = @factory.build__rule_ref(rr, start)
              r.attr_following_nfastate = g.attr_right
              r.attr_nfastart_state = g.attr_left
              if (g.attr_left.transition(0).is_a?(RuleClosureTransition) && !(@grammar.attr_type).equal?(Grammar::LEXER))
                add_follow_transition(r.get_text, g.attr_right)
              end
              # else rule ref got inlined to a set
            end
            throw :break_case, :thrown
            __t90 = _t
            t = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, TOKEN_REF)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when ARG_ACTION
                targ = _t
                match(_t, ARG_ACTION)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3, BANG, ROOT
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as2 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t90
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              start_ = @grammar.get_rule_start_state(scope_name, t.get_text)
              if (!(start_).nil?)
                rr_ = @grammar.get_rule(scope_name, t.get_text)
                g = @factory.build__rule_ref(rr_, start_)
                t.attr_nfastart_state = g.attr_left
                # don't add FOLLOW transitions in the lexer;
                # only exact context should be used.
              end
            else
              g = @factory.build__atom(t)
              t.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t93 = _t
            c = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as3 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t93
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_literal_atom(c)
            else
              g = @factory.build__atom(c)
              c.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t95 = _t
            s = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, STRING_LITERAL)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as4 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t95
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__string_literal_atom(s)
            else
              g = @factory.build__atom(s)
              s.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t97 = _t
            w = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, WILDCARD)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as5 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t97
            _t = _t.get_next_sibling
            g = @factory.build__wildcard
            throw :break_case, :thrown
            __t99 = _t
            tmp62_ast_in = _t
            match(_t, DOT)
            _t = _t.get_first_child
            scope = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = atom(_t, scope.get_text)
            _t = self.attr__ret_tree
            _t = __t99
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when TOKEN_REF
            __t90_ = _t
            t = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, TOKEN_REF)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when ARG_ACTION
                targ = _t
                match(_t, ARG_ACTION)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3, BANG, ROOT
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as2 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t90_
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              start__ = @grammar.get_rule_start_state(scope_name, t.get_text)
              if (!(start__).nil?)
                rr__ = @grammar.get_rule(scope_name, t.get_text)
                g = @factory.build__rule_ref(rr__, start__)
                t.attr_nfastart_state = g.attr_left
                # don't add FOLLOW transitions in the lexer;
                # only exact context should be used.
              end
            else
              g = @factory.build__atom(t)
              t.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t93_ = _t
            c = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as3 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t93_
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_literal_atom(c)
            else
              g = @factory.build__atom(c)
              c.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t95_ = _t
            s = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, STRING_LITERAL)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as4 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t95_
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__string_literal_atom(s)
            else
              g = @factory.build__atom(s)
              s.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t97_ = _t
            w = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, WILDCARD)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as5 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t97_
            _t = _t.get_next_sibling
            g = @factory.build__wildcard
            throw :break_case, :thrown
            __t99_ = _t
            tmp62_ast_in_ = _t
            match(_t, DOT)
            _t = _t.get_first_child
            scope = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = atom(_t, scope.get_text)
            _t = self.attr__ret_tree
            _t = __t99_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when CHAR_LITERAL
            __t93__ = _t
            c = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as3 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t93__
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__char_literal_atom(c)
            else
              g = @factory.build__atom(c)
              c.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t95__ = _t
            s = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, STRING_LITERAL)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as4 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t95__
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__string_literal_atom(s)
            else
              g = @factory.build__atom(s)
              s.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t97__ = _t
            w = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, WILDCARD)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as5 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t97__
            _t = _t.get_next_sibling
            g = @factory.build__wildcard
            throw :break_case, :thrown
            __t99__ = _t
            tmp62_ast_in__ = _t
            match(_t, DOT)
            _t = _t.get_first_child
            scope = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = atom(_t, scope.get_text)
            _t = self.attr__ret_tree
            _t = __t99__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when STRING_LITERAL
            __t95___ = _t
            s = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, STRING_LITERAL)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as4 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t95___
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              g = @factory.build__string_literal_atom(s)
            else
              g = @factory.build__atom(s)
              s.attr_following_nfastate = g.attr_right
            end
            throw :break_case, :thrown
            __t97___ = _t
            w = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, WILDCARD)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as5 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t97___
            _t = _t.get_next_sibling
            g = @factory.build__wildcard
            throw :break_case, :thrown
            __t99___ = _t
            tmp62_ast_in___ = _t
            match(_t, DOT)
            _t = _t.get_first_child
            scope = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = atom(_t, scope.get_text)
            _t = self.attr__ret_tree
            _t = __t99___
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when WILDCARD
            __t97____ = _t
            w = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, WILDCARD)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BANG, ROOT
                as5 = (_t).equal?(ASTNULL) ? nil : _t
                ast_suffix(_t)
                _t = self.attr__ret_tree
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when 3
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            _t = __t97____
            _t = _t.get_next_sibling
            g = @factory.build__wildcard
            throw :break_case, :thrown
            __t99____ = _t
            tmp62_ast_in____ = _t
            match(_t, DOT)
            _t = _t.get_first_child
            scope = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = atom(_t, scope.get_text)
            _t = self.attr__ret_tree
            _t = __t99____
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when DOT
            __t99_____ = _t
            tmp62_ast_in_____ = _t
            match(_t, DOT)
            _t = _t.get_first_child
            scope = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            g = atom(_t, scope.get_text)
            _t = self.attr__ret_tree
            _t = __t99_____
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
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
      return g
    end
    
    typesig { [AST] }
    def atom_or_notatom(_t)
      g = nil
      atom_or_notatom_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      n = nil
      c = nil
      ast1 = nil
      t = nil
      ast3 = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when DOT, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, WILDCARD, RULE_REF
            g = atom(_t, nil)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t82 = _t
            n = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, NOT)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when CHAR_LITERAL
                c = _t
                match(_t, CHAR_LITERAL)
                _t = _t.get_next_sibling
                if ((_t).nil?)
                  _t = ASTNULL
                end
                catch(:break_case) do
                  case (_t.get_type)
                  when BANG, ROOT
                    ast1 = (_t).equal?(ASTNULL) ? nil : _t
                    ast_suffix(_t)
                    _t = self.attr__ret_tree
                    throw :break_case, :thrown
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  when 3
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  else
                    raise NoViableAltException.new(_t)
                  end
                end
                ttype = 0
                if ((@grammar.attr_type).equal?(Grammar::LEXER))
                  ttype = Grammar.get_char_value_from_grammar_char_literal(c.get_text)
                else
                  ttype = @grammar.get_token_type(c.get_text)
                end
                not_atom = @grammar.complement(ttype)
                if (not_atom.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, c.attr_token, c.get_text)
                end
                g = @factory.build__set(not_atom, n)
                throw :break_case, :thrown
                t = _t
                match(_t, TOKEN_REF)
                _t = _t.get_next_sibling
                if ((_t).nil?)
                  _t = ASTNULL
                end
                catch(:break_case) do
                  case (_t.get_type)
                  when BANG, ROOT
                    ast3 = (_t).equal?(ASTNULL) ? nil : _t
                    ast_suffix(_t)
                    _t = self.attr__ret_tree
                    throw :break_case, :thrown
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  when 3
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  else
                    raise NoViableAltException.new(_t)
                  end
                end
                ttype_ = 0
                not_atom_ = nil
                if ((@grammar.attr_type).equal?(Grammar::LEXER))
                  not_atom_ = @grammar.get_set_from_rule(self, t.get_text)
                  if ((not_atom_).nil?)
                    ErrorManager.grammar_error(ErrorManager::MSG_RULE_INVALID_SET, @grammar, t.attr_token, t.get_text)
                  else
                    not_atom_ = @grammar.complement(not_atom_)
                  end
                else
                  ttype_ = @grammar.get_token_type(t.get_text)
                  not_atom_ = @grammar.complement(ttype_)
                end
                if ((not_atom_).nil? || not_atom_.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, t.attr_token, t.get_text)
                end
                g = @factory.build__set(not_atom_, n)
                throw :break_case, :thrown
                g = set(_t)
                _t = self.attr__ret_tree
                st_node = n.get_first_child
                # IntSet notSet = grammar.complement(stNode.getSetValue());
                # let code generator complement the sets
                s = st_node.get_set_value
                st_node.set_set_value(s)
                # let code gen do the complement again; here we compute
                # for NFA construction
                s = @grammar.complement(s)
                if (s.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, n.attr_token)
                end
                g = @factory.build__set(s, n)
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when TOKEN_REF
                t = _t
                match(_t, TOKEN_REF)
                _t = _t.get_next_sibling
                if ((_t).nil?)
                  _t = ASTNULL
                end
                catch(:break_case) do
                  case (_t.get_type)
                  when BANG, ROOT
                    ast3 = (_t).equal?(ASTNULL) ? nil : _t
                    ast_suffix(_t)
                    _t = self.attr__ret_tree
                    throw :break_case, :thrown
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  when 3
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  else
                    raise NoViableAltException.new(_t)
                  end
                end
                ttype__ = 0
                not_atom__ = nil
                if ((@grammar.attr_type).equal?(Grammar::LEXER))
                  not_atom__ = @grammar.get_set_from_rule(self, t.get_text)
                  if ((not_atom__).nil?)
                    ErrorManager.grammar_error(ErrorManager::MSG_RULE_INVALID_SET, @grammar, t.attr_token, t.get_text)
                  else
                    not_atom__ = @grammar.complement(not_atom__)
                  end
                else
                  ttype__ = @grammar.get_token_type(t.get_text)
                  not_atom__ = @grammar.complement(ttype__)
                end
                if ((not_atom__).nil? || not_atom__.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, t.attr_token, t.get_text)
                end
                g = @factory.build__set(not_atom__, n)
                throw :break_case, :thrown
                g = set(_t)
                _t = self.attr__ret_tree
                st_node_ = n.get_first_child
                # IntSet notSet = grammar.complement(stNode.getSetValue());
                # let code generator complement the sets
                s_ = st_node_.get_set_value
                st_node_.set_set_value(s_)
                # let code gen do the complement again; here we compute
                # for NFA construction
                s_ = @grammar.complement(s_)
                if (s_.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, n.attr_token)
                end
                g = @factory.build__set(s_, n)
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when BLOCK
                g = set(_t)
                _t = self.attr__ret_tree
                st_node__ = n.get_first_child
                # IntSet notSet = grammar.complement(stNode.getSetValue());
                # let code generator complement the sets
                s__ = st_node__.get_set_value
                st_node__.set_set_value(s__)
                # let code gen do the complement again; here we compute
                # for NFA construction
                s__ = @grammar.complement(s__)
                if (s__.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, n.attr_token)
                end
                g = @factory.build__set(s__, n)
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            n.attr_following_nfastate = g.attr_right
            _t = __t82
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when NOT
            __t82_ = _t
            n = (_t).equal?(ASTNULL) ? nil : _t
            match(_t, NOT)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when CHAR_LITERAL
                c = _t
                match(_t, CHAR_LITERAL)
                _t = _t.get_next_sibling
                if ((_t).nil?)
                  _t = ASTNULL
                end
                catch(:break_case) do
                  case (_t.get_type)
                  when BANG, ROOT
                    ast1 = (_t).equal?(ASTNULL) ? nil : _t
                    ast_suffix(_t)
                    _t = self.attr__ret_tree
                    throw :break_case, :thrown
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  when 3
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  else
                    raise NoViableAltException.new(_t)
                  end
                end
                ttype___ = 0
                if ((@grammar.attr_type).equal?(Grammar::LEXER))
                  ttype___ = Grammar.get_char_value_from_grammar_char_literal(c.get_text)
                else
                  ttype___ = @grammar.get_token_type(c.get_text)
                end
                not_atom___ = @grammar.complement(ttype___)
                if (not_atom___.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, c.attr_token, c.get_text)
                end
                g = @factory.build__set(not_atom___, n)
                throw :break_case, :thrown
                t = _t
                match(_t, TOKEN_REF)
                _t = _t.get_next_sibling
                if ((_t).nil?)
                  _t = ASTNULL
                end
                catch(:break_case) do
                  case (_t.get_type)
                  when BANG, ROOT
                    ast3 = (_t).equal?(ASTNULL) ? nil : _t
                    ast_suffix(_t)
                    _t = self.attr__ret_tree
                    throw :break_case, :thrown
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  when 3
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  else
                    raise NoViableAltException.new(_t)
                  end
                end
                ttype____ = 0
                not_atom____ = nil
                if ((@grammar.attr_type).equal?(Grammar::LEXER))
                  not_atom____ = @grammar.get_set_from_rule(self, t.get_text)
                  if ((not_atom____).nil?)
                    ErrorManager.grammar_error(ErrorManager::MSG_RULE_INVALID_SET, @grammar, t.attr_token, t.get_text)
                  else
                    not_atom____ = @grammar.complement(not_atom____)
                  end
                else
                  ttype____ = @grammar.get_token_type(t.get_text)
                  not_atom____ = @grammar.complement(ttype____)
                end
                if ((not_atom____).nil? || not_atom____.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, t.attr_token, t.get_text)
                end
                g = @factory.build__set(not_atom____, n)
                throw :break_case, :thrown
                g = set(_t)
                _t = self.attr__ret_tree
                st_node___ = n.get_first_child
                # IntSet notSet = grammar.complement(stNode.getSetValue());
                # let code generator complement the sets
                s___ = st_node___.get_set_value
                st_node___.set_set_value(s___)
                # let code gen do the complement again; here we compute
                # for NFA construction
                s___ = @grammar.complement(s___)
                if (s___.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, n.attr_token)
                end
                g = @factory.build__set(s___, n)
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when TOKEN_REF
                t = _t
                match(_t, TOKEN_REF)
                _t = _t.get_next_sibling
                if ((_t).nil?)
                  _t = ASTNULL
                end
                catch(:break_case) do
                  case (_t.get_type)
                  when BANG, ROOT
                    ast3 = (_t).equal?(ASTNULL) ? nil : _t
                    ast_suffix(_t)
                    _t = self.attr__ret_tree
                    throw :break_case, :thrown
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  when 3
                    throw :break_case, :thrown
                    raise NoViableAltException.new(_t)
                  else
                    raise NoViableAltException.new(_t)
                  end
                end
                ttype_____ = 0
                not_atom_____ = nil
                if ((@grammar.attr_type).equal?(Grammar::LEXER))
                  not_atom_____ = @grammar.get_set_from_rule(self, t.get_text)
                  if ((not_atom_____).nil?)
                    ErrorManager.grammar_error(ErrorManager::MSG_RULE_INVALID_SET, @grammar, t.attr_token, t.get_text)
                  else
                    not_atom_____ = @grammar.complement(not_atom_____)
                  end
                else
                  ttype_____ = @grammar.get_token_type(t.get_text)
                  not_atom_____ = @grammar.complement(ttype_____)
                end
                if ((not_atom_____).nil? || not_atom_____.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, t.attr_token, t.get_text)
                end
                g = @factory.build__set(not_atom_____, n)
                throw :break_case, :thrown
                g = set(_t)
                _t = self.attr__ret_tree
                st_node____ = n.get_first_child
                # IntSet notSet = grammar.complement(stNode.getSetValue());
                # let code generator complement the sets
                s____ = st_node____.get_set_value
                st_node____.set_set_value(s____)
                # let code gen do the complement again; here we compute
                # for NFA construction
                s____ = @grammar.complement(s____)
                if (s____.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, n.attr_token)
                end
                g = @factory.build__set(s____, n)
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when BLOCK
                g = set(_t)
                _t = self.attr__ret_tree
                st_node_____ = n.get_first_child
                # IntSet notSet = grammar.complement(stNode.getSetValue());
                # let code generator complement the sets
                s_____ = st_node_____.get_set_value
                st_node_____.set_set_value(s_____)
                # let code gen do the complement again; here we compute
                # for NFA construction
                s_____ = @grammar.complement(s_____)
                if (s_____.is_nil)
                  ErrorManager.grammar_error(ErrorManager::MSG_EMPTY_COMPLEMENT, @grammar, n.attr_token)
                end
                g = @factory.build__set(s_____, n)
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end
            n.attr_following_nfastate = g.attr_right
            _t = __t82_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
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
      return g
    end
    
    typesig { [AST] }
    def ebnf(_t)
      g = nil
      ebnf_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      b = nil
      blk = ebnf_ast_in
      if (!(blk.get_type).equal?(BLOCK))
        blk = blk.get_first_child
      end
      eob = blk.get_last_child
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when OPTIONAL
            __t74 = _t
            tmp63_ast_in = _t
            match(_t, OPTIONAL)
            _t = _t.get_first_child
            b = block(_t)
            _t = self.attr__ret_tree
            _t = __t74
            _t = _t.get_next_sibling
            if (!(blk.attr_set_value).nil?)
              # if block comes back SET not BLOCK, make it
              # a single ALT block
              b = @factory.build__alternative_block_from_set(b)
            end
            g = @factory.build__aoptional(b)
            g.attr_left.set_description(@grammar.grammar_tree_to_string(ebnf_ast_in, false))
            # there is always at least one alt even if block has just 1 alt
            d = @grammar.assign_decision_number(g.attr_left)
            @grammar.set_decision_nfa(d, g.attr_left)
            @grammar.set_decision_block_ast(d, blk)
            g.attr_left.set_decision_astnode(ebnf_ast_in)
            throw :break_case, :thrown
            __t75 = _t
            tmp64_ast_in = _t
            match(_t, CLOSURE)
            _t = _t.get_first_child
            b = block(_t)
            _t = self.attr__ret_tree
            _t = __t75
            _t = _t.get_next_sibling
            if (!(blk.attr_set_value).nil?)
              b = @factory.build__alternative_block_from_set(b)
            end
            g = @factory.build__astar(b)
            # track the loop back / exit decision point
            b.attr_right.set_description("()* loopback of " + (@grammar.grammar_tree_to_string(ebnf_ast_in, false)).to_s)
            d_ = @grammar.assign_decision_number(b.attr_right)
            @grammar.set_decision_nfa(d_, b.attr_right)
            @grammar.set_decision_block_ast(d_, blk)
            b.attr_right.set_decision_astnode(eob)
            # make block entry state also have same decision for interpreting grammar
            alt_block_state = g.attr_left.transition(0).attr_target
            alt_block_state.set_decision_astnode(ebnf_ast_in)
            alt_block_state.set_decision_number(d_)
            g.attr_left.set_decision_number(d_) # this is the bypass decision (2 alts)
            g.attr_left.set_decision_astnode(ebnf_ast_in)
            throw :break_case, :thrown
            __t76 = _t
            tmp65_ast_in = _t
            match(_t, POSITIVE_CLOSURE)
            _t = _t.get_first_child
            b = block(_t)
            _t = self.attr__ret_tree
            _t = __t76
            _t = _t.get_next_sibling
            if (!(blk.attr_set_value).nil?)
              b = @factory.build__alternative_block_from_set(b)
            end
            g = @factory.build__aplus(b)
            # don't make a decision on left edge, can reuse loop end decision
            # track the loop back / exit decision point
            b.attr_right.set_description("()+ loopback of " + (@grammar.grammar_tree_to_string(ebnf_ast_in, false)).to_s)
            d__ = @grammar.assign_decision_number(b.attr_right)
            @grammar.set_decision_nfa(d__, b.attr_right)
            @grammar.set_decision_block_ast(d__, blk)
            b.attr_right.set_decision_astnode(eob)
            # make block entry state also have same decision for interpreting grammar
            alt_block_state_ = g.attr_left.transition(0).attr_target
            alt_block_state_.set_decision_astnode(ebnf_ast_in)
            alt_block_state_.set_decision_number(d__)
            throw :break_case, :thrown
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(BLOCK))) && (@grammar.is_valid_set(self, ebnf_ast_in)))
              g = set(_t)
              _t = self.attr__ret_tree
            else
              if (((_t.get_type).equal?(BLOCK)))
                b = block(_t)
                _t = self.attr__ret_tree
                # track decision if > 1 alts
                if (@grammar.get_number_of_alts_for_decision_nfa(b.attr_left) > 1)
                  b.attr_left.set_description(@grammar.grammar_tree_to_string(blk, false))
                  b.attr_left.set_decision_astnode(blk)
                  d___ = @grammar.assign_decision_number(b.attr_left)
                  @grammar.set_decision_nfa(d___, b.attr_left)
                  @grammar.set_decision_block_ast(d___, blk)
                end
                g = b
              else
                raise NoViableAltException.new(_t)
              end
            end
          when CLOSURE
            __t75_ = _t
            tmp64_ast_in_ = _t
            match(_t, CLOSURE)
            _t = _t.get_first_child
            b = block(_t)
            _t = self.attr__ret_tree
            _t = __t75_
            _t = _t.get_next_sibling
            if (!(blk.attr_set_value).nil?)
              b = @factory.build__alternative_block_from_set(b)
            end
            g = @factory.build__astar(b)
            # track the loop back / exit decision point
            b.attr_right.set_description("()* loopback of " + (@grammar.grammar_tree_to_string(ebnf_ast_in, false)).to_s)
            d____ = @grammar.assign_decision_number(b.attr_right)
            @grammar.set_decision_nfa(d____, b.attr_right)
            @grammar.set_decision_block_ast(d____, blk)
            b.attr_right.set_decision_astnode(eob)
            # make block entry state also have same decision for interpreting grammar
            alt_block_state__ = g.attr_left.transition(0).attr_target
            alt_block_state__.set_decision_astnode(ebnf_ast_in)
            alt_block_state__.set_decision_number(d____)
            g.attr_left.set_decision_number(d____) # this is the bypass decision (2 alts)
            g.attr_left.set_decision_astnode(ebnf_ast_in)
            throw :break_case, :thrown
            __t76_ = _t
            tmp65_ast_in_ = _t
            match(_t, POSITIVE_CLOSURE)
            _t = _t.get_first_child
            b = block(_t)
            _t = self.attr__ret_tree
            _t = __t76_
            _t = _t.get_next_sibling
            if (!(blk.attr_set_value).nil?)
              b = @factory.build__alternative_block_from_set(b)
            end
            g = @factory.build__aplus(b)
            # don't make a decision on left edge, can reuse loop end decision
            # track the loop back / exit decision point
            b.attr_right.set_description("()+ loopback of " + (@grammar.grammar_tree_to_string(ebnf_ast_in, false)).to_s)
            d_____ = @grammar.assign_decision_number(b.attr_right)
            @grammar.set_decision_nfa(d_____, b.attr_right)
            @grammar.set_decision_block_ast(d_____, blk)
            b.attr_right.set_decision_astnode(eob)
            # make block entry state also have same decision for interpreting grammar
            alt_block_state___ = g.attr_left.transition(0).attr_target
            alt_block_state___.set_decision_astnode(ebnf_ast_in)
            alt_block_state___.set_decision_number(d_____)
            throw :break_case, :thrown
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(BLOCK))) && (@grammar.is_valid_set(self, ebnf_ast_in)))
              g = set(_t)
              _t = self.attr__ret_tree
            else
              if (((_t.get_type).equal?(BLOCK)))
                b = block(_t)
                _t = self.attr__ret_tree
                # track decision if > 1 alts
                if (@grammar.get_number_of_alts_for_decision_nfa(b.attr_left) > 1)
                  b.attr_left.set_description(@grammar.grammar_tree_to_string(blk, false))
                  b.attr_left.set_decision_astnode(blk)
                  d______ = @grammar.assign_decision_number(b.attr_left)
                  @grammar.set_decision_nfa(d______, b.attr_left)
                  @grammar.set_decision_block_ast(d______, blk)
                end
                g = b
              else
                raise NoViableAltException.new(_t)
              end
            end
          when POSITIVE_CLOSURE
            __t76__ = _t
            tmp65_ast_in__ = _t
            match(_t, POSITIVE_CLOSURE)
            _t = _t.get_first_child
            b = block(_t)
            _t = self.attr__ret_tree
            _t = __t76__
            _t = _t.get_next_sibling
            if (!(blk.attr_set_value).nil?)
              b = @factory.build__alternative_block_from_set(b)
            end
            g = @factory.build__aplus(b)
            # don't make a decision on left edge, can reuse loop end decision
            # track the loop back / exit decision point
            b.attr_right.set_description("()+ loopback of " + (@grammar.grammar_tree_to_string(ebnf_ast_in, false)).to_s)
            d_______ = @grammar.assign_decision_number(b.attr_right)
            @grammar.set_decision_nfa(d_______, b.attr_right)
            @grammar.set_decision_block_ast(d_______, blk)
            b.attr_right.set_decision_astnode(eob)
            # make block entry state also have same decision for interpreting grammar
            alt_block_state____ = g.attr_left.transition(0).attr_target
            alt_block_state____.set_decision_astnode(ebnf_ast_in)
            alt_block_state____.set_decision_number(d_______)
            throw :break_case, :thrown
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(BLOCK))) && (@grammar.is_valid_set(self, ebnf_ast_in)))
              g = set(_t)
              _t = self.attr__ret_tree
            else
              if (((_t.get_type).equal?(BLOCK)))
                b = block(_t)
                _t = self.attr__ret_tree
                # track decision if > 1 alts
                if (@grammar.get_number_of_alts_for_decision_nfa(b.attr_left) > 1)
                  b.attr_left.set_description(@grammar.grammar_tree_to_string(blk, false))
                  b.attr_left.set_decision_astnode(blk)
                  d________ = @grammar.assign_decision_number(b.attr_left)
                  @grammar.set_decision_nfa(d________, b.attr_left)
                  @grammar.set_decision_block_ast(d________, blk)
                end
                g = b
              else
                raise NoViableAltException.new(_t)
              end
            end
          else
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(BLOCK))) && (@grammar.is_valid_set(self, ebnf_ast_in)))
              g = set(_t)
              _t = self.attr__ret_tree
            else
              if (((_t.get_type).equal?(BLOCK)))
                b = block(_t)
                _t = self.attr__ret_tree
                # track decision if > 1 alts
                if (@grammar.get_number_of_alts_for_decision_nfa(b.attr_left) > 1)
                  b.attr_left.set_description(@grammar.grammar_tree_to_string(blk, false))
                  b.attr_left.set_decision_astnode(blk)
                  d_________ = @grammar.assign_decision_number(b.attr_left)
                  @grammar.set_decision_nfa(d_________, b.attr_left)
                  @grammar.set_decision_block_ast(d_________, blk)
                end
                g = b
              else
                raise NoViableAltException.new(_t)
              end
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
      return g
    end
    
    typesig { [AST] }
    def tree(_t)
      g = nil
      tree_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      e = nil
      el = nil
      down = nil
      up = nil
      begin
        # for error handling
        __t78 = _t
        tmp66_ast_in = _t
        match(_t, TREE_BEGIN)
        _t = _t.get_first_child
        el = _t
        g = element(_t)
        _t = self.attr__ret_tree
        down = @factory.build__atom(Label::DOWN, el)
        # TODO set following states for imaginary nodes?
        # el.followingNFAState = down.right;
        g = @factory.build__ab(g, down)
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if ((_tokenSet_0.member(_t.get_type)))
            el = _t
            e = element(_t)
            _t = self.attr__ret_tree
            g = @factory.build__ab(g, e)
          else
            break
          end
        end while (true)
        up = @factory.build__atom(Label::UP, el)
        # el.followingNFAState = up.right;
        g = @factory.build__ab(g, up)
        # tree roots point at right edge of DOWN for LOOK computation later
        tree_ast_in.attr_nfatree_down_state = down.attr_left
        _t = __t78
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return g
    end
    
    typesig { [AST] }
    def ast_suffix(_t)
      ast_suffix_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when ROOT
            tmp67_ast_in = _t
            match(_t, ROOT)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            tmp68_ast_in = _t
            match(_t, BANG)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BANG
            tmp68_ast_in_ = _t
            match(_t, BANG)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
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
    end
    
    typesig { [AST, IntSet] }
    def set_element(_t, elements)
      set_element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      c = nil
      t = nil
      s = nil
      c1 = nil
      c2 = nil
      ttype = 0
      ns = nil
      gset = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when CHAR_LITERAL
            c = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              ttype = Grammar.get_char_value_from_grammar_char_literal(c.get_text)
            else
              ttype = @grammar.get_token_type(c.get_text)
            end
            if (elements.member(ttype))
              ErrorManager.grammar_error(ErrorManager::MSG_DUPLICATE_SET_ENTRY, @grammar, c.attr_token, c.get_text)
            end
            elements.add(ttype)
            throw :break_case, :thrown
            t = _t
            match(_t, TOKEN_REF)
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              # recursively will invoke this rule to match elements in target rule ref
              rule_set = @grammar.get_set_from_rule(self, t.get_text)
              if ((rule_set).nil?)
                ErrorManager.grammar_error(ErrorManager::MSG_RULE_INVALID_SET, @grammar, t.attr_token, t.get_text)
              else
                elements.add_all(rule_set)
              end
            else
              ttype = @grammar.get_token_type(t.get_text)
              if (elements.member(ttype))
                ErrorManager.grammar_error(ErrorManager::MSG_DUPLICATE_SET_ENTRY, @grammar, t.attr_token, t.get_text)
              end
              elements.add(ttype)
            end
            throw :break_case, :thrown
            s = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_next_sibling
            ttype = @grammar.get_token_type(s.get_text)
            if (elements.member(ttype))
              ErrorManager.grammar_error(ErrorManager::MSG_DUPLICATE_SET_ENTRY, @grammar, s.attr_token, s.get_text)
            end
            elements.add(ttype)
            throw :break_case, :thrown
            __t122 = _t
            tmp69_ast_in = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t122
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              a = Grammar.get_char_value_from_grammar_char_literal(c1.get_text)
              b = Grammar.get_char_value_from_grammar_char_literal(c2.get_text)
              elements.add_all(IntervalSet.of(a, b))
            end
            throw :break_case, :thrown
            gset = set(_t)
            _t = self.attr__ret_tree
            set_trans = gset.attr_left.transition(0)
            elements.add_all(set_trans.attr_label.get_set)
            throw :break_case, :thrown
            __t123 = _t
            tmp70_ast_in = _t
            match(_t, NOT)
            _t = _t.get_first_child
            ns = IntervalSet.new
            set_element(_t, ns)
            _t = self.attr__ret_tree
            not_ = @grammar.complement(ns)
            elements.add_all(not_)
            _t = __t123
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when TOKEN_REF
            t = _t
            match(_t, TOKEN_REF)
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              # recursively will invoke this rule to match elements in target rule ref
              rule_set_ = @grammar.get_set_from_rule(self, t.get_text)
              if ((rule_set_).nil?)
                ErrorManager.grammar_error(ErrorManager::MSG_RULE_INVALID_SET, @grammar, t.attr_token, t.get_text)
              else
                elements.add_all(rule_set_)
              end
            else
              ttype = @grammar.get_token_type(t.get_text)
              if (elements.member(ttype))
                ErrorManager.grammar_error(ErrorManager::MSG_DUPLICATE_SET_ENTRY, @grammar, t.attr_token, t.get_text)
              end
              elements.add(ttype)
            end
            throw :break_case, :thrown
            s = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_next_sibling
            ttype = @grammar.get_token_type(s.get_text)
            if (elements.member(ttype))
              ErrorManager.grammar_error(ErrorManager::MSG_DUPLICATE_SET_ENTRY, @grammar, s.attr_token, s.get_text)
            end
            elements.add(ttype)
            throw :break_case, :thrown
            __t122_ = _t
            tmp69_ast_in_ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t122_
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              a_ = Grammar.get_char_value_from_grammar_char_literal(c1.get_text)
              b_ = Grammar.get_char_value_from_grammar_char_literal(c2.get_text)
              elements.add_all(IntervalSet.of(a_, b_))
            end
            throw :break_case, :thrown
            gset = set(_t)
            _t = self.attr__ret_tree
            set_trans_ = gset.attr_left.transition(0)
            elements.add_all(set_trans_.attr_label.get_set)
            throw :break_case, :thrown
            __t123_ = _t
            tmp70_ast_in_ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            ns = IntervalSet.new
            set_element(_t, ns)
            _t = self.attr__ret_tree
            not__ = @grammar.complement(ns)
            elements.add_all(not__)
            _t = __t123_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when STRING_LITERAL
            s = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_next_sibling
            ttype = @grammar.get_token_type(s.get_text)
            if (elements.member(ttype))
              ErrorManager.grammar_error(ErrorManager::MSG_DUPLICATE_SET_ENTRY, @grammar, s.attr_token, s.get_text)
            end
            elements.add(ttype)
            throw :break_case, :thrown
            __t122__ = _t
            tmp69_ast_in__ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t122__
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              a__ = Grammar.get_char_value_from_grammar_char_literal(c1.get_text)
              b__ = Grammar.get_char_value_from_grammar_char_literal(c2.get_text)
              elements.add_all(IntervalSet.of(a__, b__))
            end
            throw :break_case, :thrown
            gset = set(_t)
            _t = self.attr__ret_tree
            set_trans__ = gset.attr_left.transition(0)
            elements.add_all(set_trans__.attr_label.get_set)
            throw :break_case, :thrown
            __t123__ = _t
            tmp70_ast_in__ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            ns = IntervalSet.new
            set_element(_t, ns)
            _t = self.attr__ret_tree
            not___ = @grammar.complement(ns)
            elements.add_all(not___)
            _t = __t123__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when CHAR_RANGE
            __t122___ = _t
            tmp69_ast_in___ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t122___
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              a___ = Grammar.get_char_value_from_grammar_char_literal(c1.get_text)
              b___ = Grammar.get_char_value_from_grammar_char_literal(c2.get_text)
              elements.add_all(IntervalSet.of(a___, b___))
            end
            throw :break_case, :thrown
            gset = set(_t)
            _t = self.attr__ret_tree
            set_trans___ = gset.attr_left.transition(0)
            elements.add_all(set_trans___.attr_label.get_set)
            throw :break_case, :thrown
            __t123___ = _t
            tmp70_ast_in___ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            ns = IntervalSet.new
            set_element(_t, ns)
            _t = self.attr__ret_tree
            not____ = @grammar.complement(ns)
            elements.add_all(not____)
            _t = __t123___
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BLOCK
            gset = set(_t)
            _t = self.attr__ret_tree
            set_trans____ = gset.attr_left.transition(0)
            elements.add_all(set_trans____.attr_label.get_set)
            throw :break_case, :thrown
            __t123____ = _t
            tmp70_ast_in____ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            ns = IntervalSet.new
            set_element(_t, ns)
            _t = self.attr__ret_tree
            not_____ = @grammar.complement(ns)
            elements.add_all(not_____)
            _t = __t123____
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when NOT
            __t123_____ = _t
            tmp70_ast_in_____ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            ns = IntervalSet.new
            set_element(_t, ns)
            _t = self.attr__ret_tree
            not______ = @grammar.complement(ns)
            elements.add_all(not______)
            _t = __t123_____
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
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
    end
    
    typesig { [AST] }
    def set_rule(_t)
      elements = IntervalSet.new
      set_rule_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      s = nil
      begin
        # for error handling
        __t108 = _t
        tmp71_ast_in = _t
        match(_t, RULE)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when FRAGMENT, LITERAL_protected, LITERAL_public, LITERAL_private
            modifier(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when ARG
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        tmp72_ast_in = _t
        match(_t, ARG)
        _t = _t.get_next_sibling
        tmp73_ast_in = _t
        match(_t, RET)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when OPTIONS
            tmp74_ast_in = _t
            match(_t, OPTIONS)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BLOCK, SCOPE, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when SCOPE
            rule_scope_spec(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BLOCK, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            tmp75_ast_in = _t
            match(_t, AMPERSAND)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        __t114 = _t
        tmp76_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when OPTIONS
            tmp77_ast_in = _t
            match(_t, OPTIONS)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when ALT
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        _cnt119 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            __t117 = _t
            tmp78_ast_in = _t
            match(_t, ALT)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BACKTRACK_SEMPRED
                tmp79_ast_in = _t
                match(_t, BACKTRACK_SEMPRED)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when BLOCK, CHAR_RANGE, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, NOT
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end == :thrown or break
            set_element(_t, elements)
            _t = self.attr__ret_tree
            tmp80_ast_in = _t
            match(_t, EOA)
            _t = _t.get_next_sibling
            _t = __t117
            _t = _t.get_next_sibling
          else
            if (_cnt119 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          ((_cnt119 += 1) - 1)
        end while (true)
        tmp81_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t114
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when LITERAL_catch, LITERAL_finally
            exception_group(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when EOR
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        tmp82_ast_in = _t
        match(_t, EOR)
        _t = _t.get_next_sibling
        _t = __t108
        _t = _t.get_next_sibling
      rescue RecognitionException => re
        raise re
      end
      self.attr__ret_tree = _t
      return elements
    end
    
    typesig { [AST] }
    # Check to see if this block can be a set.  Can't have actions
    # etc...  Also can't be in a rule with a rewrite as we need
    # to track what's inside set for use in rewrite.
    def test_block_as_set(_t)
      test_block_as_set_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      n_alts = 0
      r = @grammar.get_locally_defined_rule(@current_rule_name)
      begin
        # for error handling
        __t125 = _t
        tmp83_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        _cnt129 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            __t127 = _t
            tmp84_ast_in = _t
            match(_t, ALT)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BACKTRACK_SEMPRED
                tmp85_ast_in = _t
                match(_t, BACKTRACK_SEMPRED)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when BLOCK, CHAR_RANGE, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, NOT
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end == :thrown or break
            test_set_element(_t)
            _t = self.attr__ret_tree
            ((n_alts += 1) - 1)
            tmp86_ast_in = _t
            match(_t, EOA)
            _t = _t.get_next_sibling
            _t = __t127
            _t = _t.get_next_sibling
            if (!(!r.has_rewrite(@outer_alt_num)))
              raise SemanticException.new("!r.hasRewrite(outerAltNum)")
            end
          else
            if (_cnt129 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          ((_cnt129 += 1) - 1)
        end while (true)
        tmp87_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t125
        _t = _t.get_next_sibling
        if (!(n_alts > 1))
          raise SemanticException.new("nAlts>1")
        end
      rescue RecognitionException => re
        raise re
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    # Match just an element; no ast suffix etc..
    def test_set_element(_t)
      test_set_element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      c = nil
      t = nil
      s = nil
      c1 = nil
      c2 = nil
      r = _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when CHAR_LITERAL
            c = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            t = _t
            match(_t, TOKEN_REF)
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              rule_ = @grammar.get_rule(t.get_text)
              if ((rule_).nil?)
                raise RecognitionException.new("invalid rule")
              end
              # recursively will invoke this rule to match elements in target rule ref
              test_set_rule(rule_.attr_tree)
            end
            throw :break_case, :thrown
            __t144 = _t
            tmp88_ast_in = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t144
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            test_block_as_set(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t145 = _t
            tmp89_ast_in = _t
            match(_t, NOT)
            _t = _t.get_first_child
            test_set_element(_t)
            _t = self.attr__ret_tree
            _t = __t145
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(STRING_LITERAL))) && (!(@grammar.attr_type).equal?(Grammar::LEXER)))
              s = _t
              match(_t, STRING_LITERAL)
              _t = _t.get_next_sibling
            else
              raise NoViableAltException.new(_t)
            end
          when TOKEN_REF
            t = _t
            match(_t, TOKEN_REF)
            _t = _t.get_next_sibling
            if ((@grammar.attr_type).equal?(Grammar::LEXER))
              rule__ = @grammar.get_rule(t.get_text)
              if ((rule__).nil?)
                raise RecognitionException.new("invalid rule")
              end
              # recursively will invoke this rule to match elements in target rule ref
              test_set_rule(rule__.attr_tree)
            end
            throw :break_case, :thrown
            __t144_ = _t
            tmp88_ast_in_ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t144_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            test_block_as_set(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t145_ = _t
            tmp89_ast_in_ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            test_set_element(_t)
            _t = self.attr__ret_tree
            _t = __t145_
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(STRING_LITERAL))) && (!(@grammar.attr_type).equal?(Grammar::LEXER)))
              s = _t
              match(_t, STRING_LITERAL)
              _t = _t.get_next_sibling
            else
              raise NoViableAltException.new(_t)
            end
          when CHAR_RANGE
            __t144__ = _t
            tmp88_ast_in__ = _t
            match(_t, CHAR_RANGE)
            _t = _t.get_first_child
            c1 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            c2 = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
            _t = __t144__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            test_block_as_set(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t145__ = _t
            tmp89_ast_in__ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            test_set_element(_t)
            _t = self.attr__ret_tree
            _t = __t145__
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(STRING_LITERAL))) && (!(@grammar.attr_type).equal?(Grammar::LEXER)))
              s = _t
              match(_t, STRING_LITERAL)
              _t = _t.get_next_sibling
            else
              raise NoViableAltException.new(_t)
            end
          when BLOCK
            test_block_as_set(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            __t145___ = _t
            tmp89_ast_in___ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            test_set_element(_t)
            _t = self.attr__ret_tree
            _t = __t145___
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(STRING_LITERAL))) && (!(@grammar.attr_type).equal?(Grammar::LEXER)))
              s = _t
              match(_t, STRING_LITERAL)
              _t = _t.get_next_sibling
            else
              raise NoViableAltException.new(_t)
            end
          when NOT
            __t145____ = _t
            tmp89_ast_in____ = _t
            match(_t, NOT)
            _t = _t.get_first_child
            test_set_element(_t)
            _t = self.attr__ret_tree
            _t = __t145____
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(STRING_LITERAL))) && (!(@grammar.attr_type).equal?(Grammar::LEXER)))
              s = _t
              match(_t, STRING_LITERAL)
              _t = _t.get_next_sibling
            else
              raise NoViableAltException.new(_t)
            end
          else
            if ((_t).nil?)
              _t = ASTNULL
            end
            if ((((_t.get_type).equal?(STRING_LITERAL))) && (!(@grammar.attr_type).equal?(Grammar::LEXER)))
              s = _t
              match(_t, STRING_LITERAL)
              _t = _t.get_next_sibling
            else
              raise NoViableAltException.new(_t)
            end
          end
        end
      rescue RecognitionException => re
        raise re
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def test_set_rule(_t)
      test_set_rule_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      begin
        # for error handling
        __t131 = _t
        tmp90_ast_in = _t
        match(_t, RULE)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when FRAGMENT, LITERAL_protected, LITERAL_public, LITERAL_private
            modifier(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when ARG
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        tmp91_ast_in = _t
        match(_t, ARG)
        _t = _t.get_next_sibling
        tmp92_ast_in = _t
        match(_t, RET)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when OPTIONS
            tmp93_ast_in = _t
            match(_t, OPTIONS)
            _t = _t.get_next_sibling
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BLOCK, SCOPE, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when SCOPE
            rule_scope_spec(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when BLOCK, AMPERSAND
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            tmp94_ast_in = _t
            match(_t, AMPERSAND)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        __t137 = _t
        tmp95_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        _cnt141 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            __t139 = _t
            tmp96_ast_in = _t
            match(_t, ALT)
            _t = _t.get_first_child
            if ((_t).nil?)
              _t = ASTNULL
            end
            catch(:break_case) do
              case (_t.get_type)
              when BACKTRACK_SEMPRED
                tmp97_ast_in = _t
                match(_t, BACKTRACK_SEMPRED)
                _t = _t.get_next_sibling
                throw :break_case, :thrown
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              when BLOCK, CHAR_RANGE, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, NOT
                throw :break_case, :thrown
                raise NoViableAltException.new(_t)
              else
                raise NoViableAltException.new(_t)
              end
            end == :thrown or break
            test_set_element(_t)
            _t = self.attr__ret_tree
            tmp98_ast_in = _t
            match(_t, EOA)
            _t = _t.get_next_sibling
            _t = __t139
            _t = _t.get_next_sibling
          else
            if (_cnt141 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          ((_cnt141 += 1) - 1)
        end while (true)
        tmp99_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t137
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        catch(:break_case) do
          case (_t.get_type)
          when LITERAL_catch, LITERAL_finally
            exception_group(_t)
            _t = self.attr__ret_tree
            throw :break_case, :thrown
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          when EOR
            throw :break_case, :thrown
            raise NoViableAltException.new(_t)
          else
            raise NoViableAltException.new(_t)
          end
        end
        tmp100_ast_in = _t
        match(_t, EOR)
        _t = _t.get_next_sibling
        _t = __t131
        _t = _t.get_next_sibling
      rescue RecognitionException => re
        raise re
      end
      self.attr__ret_tree = _t
    end
    
    class_module.module_eval {
      const_set_lazy(:_tokenNames) { Array.typed(String).new(["<0>", "EOF", "<2>", "NULL_TREE_LOOKAHEAD", "\"options\"", "\"tokens\"", "\"parser\"", "LEXER", "RULE", "BLOCK", "OPTIONAL", "CLOSURE", "POSITIVE_CLOSURE", "SYNPRED", "RANGE", "CHAR_RANGE", "EPSILON", "ALT", "EOR", "EOB", "EOA", "ID", "ARG", "ARGLIST", "RET", "LEXER_GRAMMAR", "PARSER_GRAMMAR", "TREE_GRAMMAR", "COMBINED_GRAMMAR", "INITACTION", "FORCED_ACTION", "LABEL", "TEMPLATE", "\"scope\"", "\"import\"", "GATED_SEMPRED", "SYN_SEMPRED", "BACKTRACK_SEMPRED", "\"fragment\"", "DOT", "ACTION", "DOC_COMMENT", "SEMI", "\"lexer\"", "\"tree\"", "\"grammar\"", "AMPERSAND", "COLON", "RCURLY", "ASSIGN", "STRING_LITERAL", "CHAR_LITERAL", "INT", "STAR", "COMMA", "TOKEN_REF", "\"protected\"", "\"public\"", "\"private\"", "BANG", "ARG_ACTION", "\"returns\"", "\"throws\"", "LPAREN", "OR", "RPAREN", "\"catch\"", "\"finally\"", "PLUS_ASSIGN", "SEMPRED", "IMPLIES", "ROOT", "WILDCARD", "RULE_REF", "NOT", "TREE_BEGIN", "QUESTION", "PLUS", "OPEN_ELEMENT_OPTION", "CLOSE_ELEMENT_OPTION", "REWRITE", "ETC", "DOLLAR", "DOUBLE_QUOTE_STRING_LITERAL", "DOUBLE_ANGLE_STRING_LITERAL", "WS", "COMMENT", "SL_COMMENT", "ML_COMMENT", "STRAY_BRACKET", "ESC", "DIGIT", "XDIGIT", "NESTED_ARG_ACTION", "NESTED_ACTION", "ACTION_CHAR_LITERAL", "ACTION_STRING_LITERAL", "ACTION_ESC", "WS_LOOP", "INTERNAL_RULE_REF", "WS_OPT", "SRC"]) }
      const_attr_reader  :_tokenNames
      
      typesig { [] }
      def mk_token_set_0
        data = Array.typed(::Java::Long).new([616432089855819264, 4016, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_0) { BitSet.new(mk_token_set_0) }
      const_attr_reader  :_tokenSet_0
    }
    
    private
    alias_method :initialize__tree_to_nfaconverter, :initialize
  end
  
end
