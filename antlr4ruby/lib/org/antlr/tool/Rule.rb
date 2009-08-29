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
  module RuleImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Antlr, :CommonToken
      include_const ::Org::Antlr::Analysis, :NFAState
      include_const ::Org::Antlr::Analysis, :LookaheadSet
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include ::Java::Util
    }
  end
  
  # Combine the info associated with a rule.
  class Rule 
    include_class_members RuleImports
    
    attr_accessor :name
    alias_method :attr_name, :name
    undef_method :name
    alias_method :attr_name=, :name=
    undef_method :name=
    
    attr_accessor :index
    alias_method :attr_index, :index
    undef_method :index
    alias_method :attr_index=, :index=
    undef_method :index=
    
    attr_accessor :modifier
    alias_method :attr_modifier, :modifier
    undef_method :modifier
    alias_method :attr_modifier=, :modifier=
    undef_method :modifier=
    
    attr_accessor :start_state
    alias_method :attr_start_state, :start_state
    undef_method :start_state
    alias_method :attr_start_state=, :start_state=
    undef_method :start_state=
    
    attr_accessor :stop_state
    alias_method :attr_stop_state, :stop_state
    undef_method :stop_state
    alias_method :attr_stop_state=, :stop_state=
    undef_method :stop_state=
    
    # This rule's options
    attr_accessor :options
    alias_method :attr_options, :options
    undef_method :options
    alias_method :attr_options=, :options=
    undef_method :options=
    
    class_module.module_eval {
      add("k")
      add("greedy")
      add("memoize")
      add("backtrack")
      const_set_lazy(:LegalOptions) { Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members Rule
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :LegalOptions
    }
    
    # The AST representing the whole rule
    attr_accessor :tree
    alias_method :attr_tree, :tree
    undef_method :tree
    alias_method :attr_tree=, :tree=
    undef_method :tree=
    
    # To which grammar does this belong?
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    # For convenience, track the argument def AST action node if any
    attr_accessor :arg_action_ast
    alias_method :attr_arg_action_ast, :arg_action_ast
    undef_method :arg_action_ast
    alias_method :attr_arg_action_ast=, :arg_action_ast=
    undef_method :arg_action_ast=
    
    attr_accessor :eornode
    alias_method :attr_eornode, :eornode
    undef_method :eornode
    alias_method :attr_eornode=, :eornode=
    undef_method :eornode=
    
    # The set of all tokens reachable from the start state w/o leaving
    # via the accept state.  If it reaches the accept state, FIRST
    # includes EOR_TOKEN_TYPE.
    attr_accessor :first
    alias_method :attr_first, :first
    undef_method :first
    alias_method :attr_first=, :first=
    undef_method :first=
    
    # The return values of a rule and predefined rule attributes
    attr_accessor :return_scope
    alias_method :attr_return_scope, :return_scope
    undef_method :return_scope
    alias_method :attr_return_scope=, :return_scope=
    undef_method :return_scope=
    
    attr_accessor :parameter_scope
    alias_method :attr_parameter_scope, :parameter_scope
    undef_method :parameter_scope
    alias_method :attr_parameter_scope=, :parameter_scope=
    undef_method :parameter_scope=
    
    # the attributes defined with "scope {...}" inside a rule
    attr_accessor :rule_scope
    alias_method :attr_rule_scope, :rule_scope
    undef_method :rule_scope
    alias_method :attr_rule_scope=, :rule_scope=
    undef_method :rule_scope=
    
    # A list of scope names (String) used by this rule
    attr_accessor :use_scopes
    alias_method :attr_use_scopes, :use_scopes
    undef_method :use_scopes
    alias_method :attr_use_scopes=, :use_scopes=
    undef_method :use_scopes=
    
    # A list of all LabelElementPair attached to tokens like id=ID
    attr_accessor :token_labels
    alias_method :attr_token_labels, :token_labels
    undef_method :token_labels
    alias_method :attr_token_labels=, :token_labels=
    undef_method :token_labels=
    
    # A list of all LabelElementPair attached to single char literals like x='a'
    attr_accessor :char_labels
    alias_method :attr_char_labels, :char_labels
    undef_method :char_labels
    alias_method :attr_char_labels=, :char_labels=
    undef_method :char_labels=
    
    # A list of all LabelElementPair attached to rule references like f=field
    attr_accessor :rule_labels
    alias_method :attr_rule_labels, :rule_labels
    undef_method :rule_labels
    alias_method :attr_rule_labels=, :rule_labels=
    undef_method :rule_labels=
    
    # A list of all Token list LabelElementPair like ids+=ID
    attr_accessor :token_list_labels
    alias_method :attr_token_list_labels, :token_list_labels
    undef_method :token_list_labels
    alias_method :attr_token_list_labels=, :token_list_labels=
    undef_method :token_list_labels=
    
    # A list of all rule ref list LabelElementPair like ids+=expr
    attr_accessor :rule_list_labels
    alias_method :attr_rule_list_labels, :rule_list_labels
    undef_method :rule_list_labels
    alias_method :attr_rule_list_labels=, :rule_list_labels=
    undef_method :rule_list_labels=
    
    # All labels go in here (plus being split per the above lists) to
    # catch dup label and label type mismatches.
    attr_accessor :label_name_space
    alias_method :attr_label_name_space, :label_name_space
    undef_method :label_name_space
    alias_method :attr_label_name_space=, :label_name_space=
    undef_method :label_name_space=
    
    # Map a name to an action for this rule.  Currently init is only
    # one we use, but we can add more in future.
    # The code generator will use this to fill holes in the rule template.
    # I track the AST node for the action in case I need the line number
    # for errors.  A better name is probably namedActions, but I don't
    # want everyone to have to change their code gen templates now.
    attr_accessor :actions
    alias_method :attr_actions, :actions
    undef_method :actions
    alias_method :attr_actions=, :actions=
    undef_method :actions=
    
    # Track all executable actions other than named actions like @init.
    # Also tracks exception handlers, predicates, and rewrite rewrites.
    # We need to examine these actions before code generation so
    # that we can detect refs to $rule.attr etc...
    attr_accessor :inline_actions
    alias_method :attr_inline_actions, :inline_actions
    undef_method :inline_actions
    alias_method :attr_inline_actions=, :inline_actions=
    undef_method :inline_actions=
    
    attr_accessor :number_of_alts
    alias_method :attr_number_of_alts, :number_of_alts
    undef_method :number_of_alts
    alias_method :attr_number_of_alts=, :number_of_alts=
    undef_method :number_of_alts=
    
    # Each alt has a Map<tokenRefName,List<tokenRefAST>>; range 1..numberOfAlts.
    # So, if there are 3 ID refs in a rule's alt number 2, you'll have
    # altToTokenRef[2].get("ID").size()==3.  This is used to see if $ID is ok.
    # There must be only one ID reference in the alt for $ID to be ok in
    # an action--must be unique.
    # 
    # This also tracks '+' and "int" literal token references
    # (if not in LEXER).
    # 
    # Rewrite rules force tracking of all tokens.
    attr_accessor :alt_to_token_ref_map
    alias_method :attr_alt_to_token_ref_map, :alt_to_token_ref_map
    undef_method :alt_to_token_ref_map
    alias_method :attr_alt_to_token_ref_map=, :alt_to_token_ref_map=
    undef_method :alt_to_token_ref_map=
    
    # Each alt has a Map<ruleRefName,List<ruleRefAST>>; range 1..numberOfAlts
    # So, if there are 3 expr refs in a rule's alt number 2, you'll have
    # altToRuleRef[2].get("expr").size()==3.  This is used to see if $expr is ok.
    # There must be only one expr reference in the alt for $expr to be ok in
    # an action--must be unique.
    # 
    # Rewrite rules force tracking of all rule result ASTs. 1..n
    attr_accessor :alt_to_rule_ref_map
    alias_method :attr_alt_to_rule_ref_map, :alt_to_rule_ref_map
    undef_method :alt_to_rule_ref_map
    alias_method :attr_alt_to_rule_ref_map=, :alt_to_rule_ref_map=
    undef_method :alt_to_rule_ref_map=
    
    # Track which alts have rewrite rules associated with them. 1..n
    attr_accessor :alts_with_rewrites
    alias_method :attr_alts_with_rewrites, :alts_with_rewrites
    undef_method :alts_with_rewrites
    alias_method :attr_alts_with_rewrites=, :alts_with_rewrites=
    undef_method :alts_with_rewrites=
    
    # Do not generate start, stop etc... in a return value struct unless
    # somebody references $r.start somewhere.
    attr_accessor :referenced_predefined_rule_attributes
    alias_method :attr_referenced_predefined_rule_attributes, :referenced_predefined_rule_attributes
    undef_method :referenced_predefined_rule_attributes
    alias_method :attr_referenced_predefined_rule_attributes=, :referenced_predefined_rule_attributes=
    undef_method :referenced_predefined_rule_attributes=
    
    attr_accessor :is_syn_pred
    alias_method :attr_is_syn_pred, :is_syn_pred
    undef_method :is_syn_pred
    alias_method :attr_is_syn_pred=, :is_syn_pred=
    undef_method :is_syn_pred=
    
    attr_accessor :imported
    alias_method :attr_imported, :imported
    undef_method :imported
    alias_method :attr_imported=, :imported=
    undef_method :imported=
    
    typesig { [Grammar, String, ::Java::Int, ::Java::Int] }
    def initialize(grammar, rule_name, rule_index, number_of_alts)
      @name = nil
      @index = 0
      @modifier = nil
      @start_state = nil
      @stop_state = nil
      @options = nil
      @tree = nil
      @grammar = nil
      @arg_action_ast = nil
      @eornode = nil
      @first = nil
      @return_scope = nil
      @parameter_scope = nil
      @rule_scope = nil
      @use_scopes = nil
      @token_labels = nil
      @char_labels = nil
      @rule_labels = nil
      @token_list_labels = nil
      @rule_list_labels = nil
      @label_name_space = HashMap.new
      @actions = HashMap.new
      @inline_actions = ArrayList.new
      @number_of_alts = 0
      @alt_to_token_ref_map = nil
      @alt_to_rule_ref_map = nil
      @alts_with_rewrites = nil
      @referenced_predefined_rule_attributes = false
      @is_syn_pred = false
      @imported = false
      @name = rule_name
      @index = rule_index
      @number_of_alts = number_of_alts
      @grammar = grammar
      @alt_to_token_ref_map = Array.typed(Map).new(number_of_alts + 1) { nil }
      @alt_to_rule_ref_map = Array.typed(Map).new(number_of_alts + 1) { nil }
      @alts_with_rewrites = Array.typed(::Java::Boolean).new(number_of_alts + 1) { false }
      alt = 1
      while alt <= number_of_alts
        @alt_to_token_ref_map[alt] = HashMap.new
        @alt_to_rule_ref_map[alt] = HashMap.new
        alt += 1
      end
    end
    
    typesig { [Antlr::Token, GrammarAST, ::Java::Int] }
    def define_label(label, element_ref, type)
      pair = LabelElementPair.new(label, element_ref)
      pair.attr_type = type
      @label_name_space.put(label.get_text, pair)
      case (type)
      when Grammar::TOKEN_LABEL
        if ((@token_labels).nil?)
          @token_labels = LinkedHashMap.new
        end
        @token_labels.put(label.get_text, pair)
      when Grammar::RULE_LABEL
        if ((@rule_labels).nil?)
          @rule_labels = LinkedHashMap.new
        end
        @rule_labels.put(label.get_text, pair)
      when Grammar::TOKEN_LIST_LABEL
        if ((@token_list_labels).nil?)
          @token_list_labels = LinkedHashMap.new
        end
        @token_list_labels.put(label.get_text, pair)
      when Grammar::RULE_LIST_LABEL
        if ((@rule_list_labels).nil?)
          @rule_list_labels = LinkedHashMap.new
        end
        @rule_list_labels.put(label.get_text, pair)
      when Grammar::CHAR_LABEL
        if ((@char_labels).nil?)
          @char_labels = LinkedHashMap.new
        end
        @char_labels.put(label.get_text, pair)
      end
    end
    
    typesig { [String] }
    def get_label(name)
      return @label_name_space.get(name)
    end
    
    typesig { [String] }
    def get_token_label(name)
      pair = nil
      if (!(@token_labels).nil?)
        return @token_labels.get(name)
      end
      return pair
    end
    
    typesig { [] }
    def get_rule_labels
      return @rule_labels
    end
    
    typesig { [] }
    def get_rule_list_labels
      return @rule_list_labels
    end
    
    typesig { [String] }
    def get_rule_label(name)
      pair = nil
      if (!(@rule_labels).nil?)
        return @rule_labels.get(name)
      end
      return pair
    end
    
    typesig { [String] }
    def get_token_list_label(name)
      pair = nil
      if (!(@token_list_labels).nil?)
        return @token_list_labels.get(name)
      end
      return pair
    end
    
    typesig { [String] }
    def get_rule_list_label(name)
      pair = nil
      if (!(@rule_list_labels).nil?)
        return @rule_list_labels.get(name)
      end
      return pair
    end
    
    typesig { [GrammarAST, ::Java::Int] }
    # Track a token ID or literal like '+' and "void" as having been referenced
    # somewhere within the alts (not rewrite sections) of a rule.
    # 
    # This differs from Grammar.altReferencesTokenID(), which tracks all
    # token IDs to check for token IDs without corresponding lexer rules.
    def track_token_reference_in_alt(ref_ast, outer_alt_num)
      refs = @alt_to_token_ref_map[outer_alt_num].get(ref_ast.get_text)
      if ((refs).nil?)
        refs = ArrayList.new
        @alt_to_token_ref_map[outer_alt_num].put(ref_ast.get_text, refs)
      end
      refs.add(ref_ast)
    end
    
    typesig { [String, ::Java::Int] }
    def get_token_refs_in_alt(ref, outer_alt_num)
      if (!(@alt_to_token_ref_map[outer_alt_num]).nil?)
        token_ref_asts = @alt_to_token_ref_map[outer_alt_num].get(ref)
        return token_ref_asts
      end
      return nil
    end
    
    typesig { [GrammarAST, ::Java::Int] }
    def track_rule_reference_in_alt(ref_ast, outer_alt_num)
      refs = @alt_to_rule_ref_map[outer_alt_num].get(ref_ast.get_text)
      if ((refs).nil?)
        refs = ArrayList.new
        @alt_to_rule_ref_map[outer_alt_num].put(ref_ast.get_text, refs)
      end
      refs.add(ref_ast)
    end
    
    typesig { [String, ::Java::Int] }
    def get_rule_refs_in_alt(ref, outer_alt_num)
      if (!(@alt_to_rule_ref_map[outer_alt_num]).nil?)
        rule_ref_asts = @alt_to_rule_ref_map[outer_alt_num].get(ref)
        return rule_ref_asts
      end
      return nil
    end
    
    typesig { [::Java::Int] }
    def get_token_refs_in_alt(alt_num)
      return @alt_to_token_ref_map[alt_num].key_set
    end
    
    typesig { [] }
    # For use with rewrite rules, we must track all tokens matched on the
    # left-hand-side; so we need Lists.  This is a unique list of all
    # token types for which the rule needs a list of tokens.  This
    # is called from the rule template not directly by the code generator.
    def get_all_token_refs_in_alts_with_rewrites
      output = @grammar.get_option("output")
      tokens = HashSet.new
      if ((output).nil? || !(output == "AST"))
        # return nothing if not generating trees; i.e., don't do for templates
        return tokens
      end
      i = 1
      while i <= @number_of_alts
        if (@alts_with_rewrites[i])
          m = @alt_to_token_ref_map[i]
          s = m.key_set
          it = s.iterator
          while it.has_next
            # convert token name like ID to ID, "void" to 31
            token_name = it.next_
            ttype = @grammar.get_token_type(token_name)
            label = @grammar.attr_generator.get_token_type_as_target_label(ttype)
            tokens.add(label)
          end
        end
        i += 1
      end
      return tokens
    end
    
    typesig { [::Java::Int] }
    def get_rule_refs_in_alt(outer_alt_num)
      return @alt_to_rule_ref_map[outer_alt_num].key_set
    end
    
    typesig { [] }
    # For use with rewrite rules, we must track all rule AST results on the
    # left-hand-side; so we need Lists.  This is a unique list of all
    # rule results for which the rule needs a list of results.
    def get_all_rule_refs_in_alts_with_rewrites
      rules = HashSet.new
      i = 1
      while i <= @number_of_alts
        if (@alts_with_rewrites[i])
          m = @alt_to_rule_ref_map[i]
          rules.add_all(m.key_set)
        end
        i += 1
      end
      return rules
    end
    
    typesig { [] }
    def get_inline_actions
      return @inline_actions
    end
    
    typesig { [::Java::Int] }
    def has_rewrite(i)
      if (i >= @alts_with_rewrites.attr_length)
        ErrorManager.internal_error("alt " + RJava.cast_to_string(i) + " exceeds number of " + @name + "'s alts (" + RJava.cast_to_string(@alts_with_rewrites.attr_length) + ")")
        return false
      end
      return @alts_with_rewrites[i]
    end
    
    typesig { [GrammarAST, ::Java::Int] }
    # Track which rules have rewrite rules.  Pass in the ALT node
    # for the alt so we can check for problems when output=template,
    # rewrite=true, and grammar type is tree parser.
    def track_alts_with_rewrites(alt_ast, outer_alt_num)
      if ((@grammar.attr_type).equal?(Grammar::TREE_PARSER) && @grammar.build_template && !(@grammar.get_option("rewrite")).nil? && (@grammar.get_option("rewrite") == "true"))
        first_element_ast = alt_ast.get_first_child
        @grammar.attr_sanity.ensure_alt_is_simple_node_or_tree(alt_ast, first_element_ast, outer_alt_num)
      end
      @alts_with_rewrites[outer_alt_num] = true
    end
    
    typesig { [String] }
    # Return the scope containing name
    def get_attribute_scope(name)
      scope = get_local_attribute_scope(name)
      if (!(scope).nil?)
        return scope
      end
      if (!(@rule_scope).nil? && !(@rule_scope.get_attribute(name)).nil?)
        scope = @rule_scope
      end
      return scope
    end
    
    typesig { [String] }
    # Get the arg, return value, or predefined property for this rule
    def get_local_attribute_scope(name)
      scope = nil
      if (!(@return_scope).nil? && !(@return_scope.get_attribute(name)).nil?)
        scope = @return_scope
      else
        if (!(@parameter_scope).nil? && !(@parameter_scope.get_attribute(name)).nil?)
          scope = @parameter_scope
        else
          rule_properties_scope = RuleLabelScope.attr_grammar_type_to_rule_properties_scope[@grammar.attr_type]
          if (!(rule_properties_scope.get_attribute(name)).nil?)
            scope = rule_properties_scope
          end
        end
      end
      return scope
    end
    
    typesig { [String, ::Java::Int, CodeGenerator] }
    # For references to tokens rather than by label such as $ID, we
    # need to get the existing label for the ID ref or create a new
    # one.
    def get_element_label(refd_symbol, outer_alt_num, generator)
      unique_ref_ast = nil
      if (!(@grammar.attr_type).equal?(Grammar::LEXER) && Character.is_upper_case(refd_symbol.char_at(0)))
        # symbol is a token
        token_refs = get_token_refs_in_alt(refd_symbol, outer_alt_num)
        unique_ref_ast = token_refs.get(0)
      else
        # symbol is a rule
        rule_refs = get_rule_refs_in_alt(refd_symbol, outer_alt_num)
        unique_ref_ast = rule_refs.get(0)
      end
      if ((unique_ref_ast.attr_code).nil?)
        # no code?  must not have gen'd yet; forward ref
        return nil
      end
      label_name = nil
      existing_label_name = unique_ref_ast.attr_code.get_attribute("label")
      # reuse any label or list label if it exists
      if (!(existing_label_name).nil?)
        label_name = existing_label_name
      else
        # else create new label
        label_name = RJava.cast_to_string(generator.create_unique_label(refd_symbol))
        label = CommonToken.new(ANTLRParser::ID, label_name)
        if (!(@grammar.attr_type).equal?(Grammar::LEXER) && Character.is_upper_case(refd_symbol.char_at(0)))
          @grammar.define_token_ref_label(@name, label, unique_ref_ast)
        else
          @grammar.define_rule_ref_label(@name, label, unique_ref_ast)
        end
        unique_ref_ast.attr_code.set_attribute("label", label_name)
      end
      return label_name
    end
    
    typesig { [] }
    # If a rule has no user-defined return values and nobody references
    # it's start/stop (predefined attributes), then there is no need to
    # define a struct; otherwise for now we assume a struct.  A rule also
    # has multiple return values if you are building trees or templates.
    def get_has_multiple_return_values
      return @referenced_predefined_rule_attributes || @grammar.build_ast || @grammar.build_template || (!(@return_scope).nil? && @return_scope.attr_attributes.size > 1)
    end
    
    typesig { [] }
    def get_has_single_return_value
      return !(@referenced_predefined_rule_attributes || @grammar.build_ast || @grammar.build_template) && (!(@return_scope).nil? && (@return_scope.attr_attributes.size).equal?(1))
    end
    
    typesig { [] }
    def get_has_return_value
      return @referenced_predefined_rule_attributes || @grammar.build_ast || @grammar.build_template || (!(@return_scope).nil? && @return_scope.attr_attributes.size > 0)
    end
    
    typesig { [] }
    def get_single_value_return_type
      if (!(@return_scope).nil? && (@return_scope.attr_attributes.size).equal?(1))
        retval_attrs = @return_scope.attr_attributes.values
        java_sucks = retval_attrs.to_array
        return (java_sucks[0]).attr_type
      end
      return nil
    end
    
    typesig { [] }
    def get_single_value_return_name
      if (!(@return_scope).nil? && (@return_scope.attr_attributes.size).equal?(1))
        retval_attrs = @return_scope.attr_attributes.values
        java_sucks = retval_attrs.to_array
        return (java_sucks[0]).attr_name
      end
      return nil
    end
    
    typesig { [GrammarAST, GrammarAST, GrammarAST] }
    # Given @scope::name {action} define it for this grammar.  Later,
    # the code generator will ask for the actions table.
    def define_named_action(ampersand_ast, name_ast, action_ast)
      # System.out.println("rule @"+nameAST.getText()+"{"+actionAST.getText()+"}");
      action_name = name_ast.get_text
      a = @actions.get(action_name)
      if (!(a).nil?)
        ErrorManager.grammar_error(ErrorManager::MSG_ACTION_REDEFINITION, @grammar, name_ast.get_token, name_ast.get_text)
      else
        @actions.put(action_name, action_ast)
      end
    end
    
    typesig { [GrammarAST] }
    def track_inline_action(action_ast)
      @inline_actions.add(action_ast)
    end
    
    typesig { [] }
    def get_actions
      return @actions
    end
    
    typesig { [Map] }
    def set_actions(actions)
      @actions = actions
    end
    
    typesig { [String, Object, Antlr::Token] }
    # Save the option key/value pair and process it; return the key
    # or null if invalid option.
    def set_option(key, value, options_start_token)
      if (!LegalOptions.contains(key))
        ErrorManager.grammar_error(ErrorManager::MSG_ILLEGAL_OPTION, @grammar, options_start_token, key)
        return nil
      end
      if ((@options).nil?)
        @options = HashMap.new
      end
      if ((key == "memoize") && (value.to_s == "true"))
        @grammar.attr_at_least_one_rule_memoizes = true
      end
      if ((key == "k"))
        @grammar.attr_number_of_manual_lookahead_options += 1
      end
      @options.put(key, value)
      return key
    end
    
    typesig { [Map, Antlr::Token] }
    def set_options(options, options_start_token)
      if ((options).nil?)
        @options = nil
        return
      end
      keys = options.key_set
      it = keys.iterator
      while it.has_next
        option_name = it.next_
        option_value = options.get(option_name)
        stored = set_option(option_name, option_value, options_start_token)
        if ((stored).nil?)
          it.remove
        end
      end
    end
    
    typesig { [] }
    # Used during grammar imports to see if sets of rules intersect... This
    # method and hashCode use the String name as the key for Rule objects.
    # public boolean equals(Object other) {
    # return this.name.equals(((Rule)other).name);
    # }
    # 
    # Used during grammar imports to see if sets of rules intersect...
    # public int hashCode() {
    # return name.hashCode();
    # }
    def to_s
      # used for testing
      return "[" + RJava.cast_to_string(@grammar.attr_name) + "." + @name + ",index=" + RJava.cast_to_string(@index) + ",line=" + RJava.cast_to_string(@tree.get_token.get_line) + "]"
    end
    
    private
    alias_method :initialize__rule, :initialize
  end
  
end
