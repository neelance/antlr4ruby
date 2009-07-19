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
  module NameSpaceCheckerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Antlr, :Token
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Java::Util, :Iterator
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :JavaSet
    }
  end
  
  class NameSpaceChecker 
    include_class_members NameSpaceCheckerImports
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    typesig { [Grammar] }
    def initialize(grammar)
      @grammar = nil
      @grammar = grammar
    end
    
    typesig { [] }
    def check_conflicts
      i = CompositeGrammar::MIN_RULE_INDEX
      while i < @grammar.attr_composite.attr_rule_index_to_rule_list.size
        r = @grammar.attr_composite.attr_rule_index_to_rule_list.element_at(i)
        if ((r).nil?)
          ((i += 1) - 1)
          next
        end
        # walk all labels for Rule r
        if (!(r.attr_label_name_space).nil?)
          it = r.attr_label_name_space.values.iterator
          while (it.has_next)
            pair = it.next
            check_for_label_conflict(r, pair.attr_label)
          end
        end
        # walk rule scope attributes for Rule r
        if (!(r.attr_rule_scope).nil?)
          attributes = r.attr_rule_scope.get_attributes
          j = 0
          while j < attributes.size
            attribute = attributes.get(j)
            check_for_rule_scope_attribute_conflict(r, attribute)
            ((j += 1) - 1)
          end
        end
        check_for_rule_definition_problems(r)
        check_for_rule_argument_and_return_value_conflicts(r)
        ((i += 1) - 1)
      end
      # check all global scopes against tokens
      it = @grammar.get_global_scopes.values.iterator
      while (it.has_next)
        scope = it.next
        check_for_global_scope_token_conflict(scope)
      end
      # check for missing rule, tokens
      look_for_references_to_undefined_symbols
    end
    
    typesig { [Rule] }
    def check_for_rule_argument_and_return_value_conflicts(r)
      if (!(r.attr_return_scope).nil?)
        conflicting_keys = r.attr_return_scope.intersection(r.attr_parameter_scope)
        if (!(conflicting_keys).nil?)
          it = conflicting_keys.iterator
          while it.has_next
            key = it.next
            ErrorManager.grammar_error(ErrorManager::MSG_ARG_RETVAL_CONFLICT, @grammar, r.attr_tree.get_token, key, r.attr_name)
          end
        end
      end
    end
    
    typesig { [Rule] }
    def check_for_rule_definition_problems(r)
      rule_name = r.attr_name
      rule_token = r.attr_tree.get_token
      msg_id = 0
      if (((@grammar.attr_type).equal?(Grammar::PARSER) || (@grammar.attr_type).equal?(Grammar::TREE_PARSER)) && Character.is_upper_case(rule_name.char_at(0)))
        msg_id = ErrorManager::MSG_LEXER_RULES_NOT_ALLOWED
      else
        if ((@grammar.attr_type).equal?(Grammar::LEXER) && Character.is_lower_case(rule_name.char_at(0)) && !r.attr_is_syn_pred)
          msg_id = ErrorManager::MSG_PARSER_RULES_NOT_ALLOWED
        else
          if (!(@grammar.get_global_scope(rule_name)).nil?)
            msg_id = ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
          end
        end
      end
      if (!(msg_id).equal?(0))
        ErrorManager.grammar_error(msg_id, @grammar, rule_token, rule_name)
      end
    end
    
    typesig { [] }
    # If ref to undefined rule, give error at first occurrence.
    # 
    # Give error if you cannot find the scope override on a rule reference.
    # 
    # If you ref ID in a combined grammar and don't define ID as a lexer rule
    # it is an error.
    def look_for_references_to_undefined_symbols
      # for each rule ref, ask if there is a rule definition
      iter = @grammar.attr_rule_refs.iterator
      while iter.has_next
        ref_ast = iter.next
        tok = ref_ast.attr_token
        rule_name = tok.get_text
        local_rule = @grammar.get_locally_defined_rule(rule_name)
        rule = @grammar.get_rule(rule_name)
        if ((local_rule).nil? && !(rule).nil?)
          # imported rule?
          @grammar.attr_delegated_rule_references.add(rule)
          rule.attr_imported = true
        end
        if ((rule).nil? && !(@grammar.get_token_type(rule_name)).equal?(Label::EOF))
          ErrorManager.grammar_error(ErrorManager::MSG_UNDEFINED_RULE_REF, @grammar, tok, rule_name)
        end
      end
      if ((@grammar.attr_type).equal?(Grammar::COMBINED))
        # if we're a combined grammar, we know which token IDs have no
        # associated lexer rule.
        iter_ = @grammar.attr_token_idrefs.iterator
        while iter_.has_next
          tok = iter_.next
          token_id = tok.get_text
          if (!@grammar.attr_composite.attr_lexer_rules.contains(token_id) && !(@grammar.get_token_type(token_id)).equal?(Label::EOF))
            ErrorManager.grammar_warning(ErrorManager::MSG_NO_TOKEN_DEFINITION, @grammar, tok, token_id)
          end
        end
      end
      # check scopes and scoped rule refs
      it = @grammar.attr_scoped_rule_refs.iterator
      while it.has_next
        scope_ast = it.next # ^(DOT ID atom)
        scope_g = @grammar.attr_composite.get_grammar(scope_ast.get_text)
        ref_ast = scope_ast.get_child(1)
        rule_name = ref_ast.get_text
        if ((scope_g).nil?)
          ErrorManager.grammar_error(ErrorManager::MSG_NO_SUCH_GRAMMAR_SCOPE, @grammar, scope_ast.get_token, scope_ast.get_text, rule_name)
        else
          rule = @grammar.get_rule(scope_g.attr_name, rule_name)
          if ((rule).nil?)
            ErrorManager.grammar_error(ErrorManager::MSG_NO_SUCH_RULE_IN_SCOPE, @grammar, scope_ast.get_token, scope_ast.get_text, rule_name)
          end
        end
      end
    end
    
    typesig { [AttributeScope] }
    def check_for_global_scope_token_conflict(scope)
      if (!(@grammar.get_token_type(scope.get_name)).equal?(Label::INVALID))
        ErrorManager.grammar_error(ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE, @grammar, nil, scope.get_name)
      end
    end
    
    typesig { [Rule, Attribute] }
    # Check for collision of a rule-scope dynamic attribute with:
    # arg, return value, rule name itself.  Labels are checked elsewhere.
    def check_for_rule_scope_attribute_conflict(r, attribute)
      msg_id = 0
      arg2 = nil
      attr_name = attribute.attr_name
      if ((r.attr_name == attr_name))
        msg_id = ErrorManager::MSG_ATTRIBUTE_CONFLICTS_WITH_RULE
        arg2 = r.attr_name
      else
        if ((!(r.attr_return_scope).nil? && !(r.attr_return_scope.get_attribute(attr_name)).nil?) || (!(r.attr_parameter_scope).nil? && !(r.attr_parameter_scope.get_attribute(attr_name)).nil?))
          msg_id = ErrorManager::MSG_ATTRIBUTE_CONFLICTS_WITH_RULE_ARG_RETVAL
          arg2 = r.attr_name
        end
      end
      if (!(msg_id).equal?(0))
        ErrorManager.grammar_error(msg_id, @grammar, r.attr_tree.get_token, attr_name, arg2)
      end
    end
    
    typesig { [Rule, Antlr::Token] }
    # Make sure a label doesn't conflict with another symbol.
    # Labels must not conflict with: rules, tokens, scope names,
    # return values, parameters, and rule-scope dynamic attributes
    # defined in surrounding rule.
    def check_for_label_conflict(r, label)
      msg_id = 0
      arg2 = nil
      if (!(@grammar.get_global_scope(label.get_text)).nil?)
        msg_id = ErrorManager::MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
      else
        if (!(@grammar.get_rule(label.get_text)).nil?)
          msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_RULE
        else
          if (!(@grammar.get_token_type(label.get_text)).equal?(Label::INVALID))
            msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_TOKEN
          else
            if (!(r.attr_rule_scope).nil? && !(r.attr_rule_scope.get_attribute(label.get_text)).nil?)
              msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_RULE_SCOPE_ATTRIBUTE
              arg2 = r.attr_name
            else
              if ((!(r.attr_return_scope).nil? && !(r.attr_return_scope.get_attribute(label.get_text)).nil?) || (!(r.attr_parameter_scope).nil? && !(r.attr_parameter_scope.get_attribute(label.get_text)).nil?))
                msg_id = ErrorManager::MSG_LABEL_CONFLICTS_WITH_RULE_ARG_RETVAL
                arg2 = r.attr_name
              end
            end
          end
        end
      end
      if (!(msg_id).equal?(0))
        ErrorManager.grammar_error(msg_id, @grammar, label, label.get_text, arg2)
      end
    end
    
    typesig { [Rule, Antlr::Token, ::Java::Int] }
    # If type of previous label differs from new label's type, that's an error.
    def check_for_label_type_mismatch(r, label, type)
      prev_label_pair = r.attr_label_name_space.get(label.get_text)
      if (!(prev_label_pair).nil?)
        # label already defined; if same type, no problem
        if (!(prev_label_pair.attr_type).equal?(type))
          type_mismatch_expr = (Grammar::LabelTypeToString[type]).to_s + "!=" + (Grammar::LabelTypeToString[prev_label_pair.attr_type]).to_s
          ErrorManager.grammar_error(ErrorManager::MSG_LABEL_TYPE_CONFLICT, @grammar, label, label.get_text, type_mismatch_expr)
          return true
        end
      end
      return false
    end
    
    private
    alias_method :initialize__name_space_checker, :initialize
  end
  
end
