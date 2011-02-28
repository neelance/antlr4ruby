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
  module CompositeGrammarImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Antlr, :RecognitionException
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Analysis, :NFAState
      include_const ::Org::Antlr::Misc, :Utils
      include ::Java::Util
    }
  end
  
  # 	public void minimizeRuleSet() {
  # 		Set<Rule> refs = _minimizeRuleSet(delegateGrammarTreeRoot);
  # 		System.out.println("all rule refs: "+refs);
  # 	}
  # 
  # 	public Set<Rule> _minimizeRuleSet(CompositeGrammarTree p) {
  # 		Set<Rule> refs = new HashSet<Rule>();
  # 		for (GrammarAST refAST : p.grammar.ruleRefs) {
  # 			System.out.println("ref "+refAST.getText()+": "+refAST.NFAStartState+
  # 							   " enclosing rule: "+refAST.NFAStartState.enclosingRule+
  # 							   " invoking rule: "+((NFAState)refAST.NFAStartState.transition[0].target).enclosingRule);
  # 			refs.add(((NFAState)refAST.NFAStartState.transition[0].target).enclosingRule);
  # 		}
  # 
  # 		if ( p.children!=null ) {
  # 			for (CompositeGrammarTree delegate : p.children) {
  # 				Set<Rule> delegateRuleRefs = _minimizeRuleSet(delegate);
  # 				refs.addAll(delegateRuleRefs);
  # 			}
  # 		}
  # 
  # 		return refs;
  # 	}
  # 	public void oldminimizeRuleSet() {
  # 		// first walk to remove all overridden rules
  # 		Set<String> ruleDefs = new HashSet<String>();
  # 		Set<String> ruleRefs = new HashSet<String>();
  # 		for (GrammarAST refAST : delegateGrammarTreeRoot.grammar.ruleRefs) {
  # 			String rname = refAST.getText();
  # 			ruleRefs.add(rname);
  # 		}
  # 		_minimizeRuleSet(ruleDefs,
  # 						 ruleRefs,
  # 						 delegateGrammarTreeRoot);
  # 		System.out.println("overall rule defs: "+ruleDefs);
  # 	}
  # 
  # 	public void _minimizeRuleSet(Set<String> ruleDefs,
  # 								 Set<String> ruleRefs,
  # 								 CompositeGrammarTree p) {
  # 		Set<String> localRuleDefs = new HashSet<String>();
  # 		for (Rule r : p.grammar.getRules()) {
  # 			if ( !ruleDefs.contains(r.name) ) {
  # 				localRuleDefs.add(r.name);
  # 				ruleDefs.add(r.name);
  # 			}
  # 		}
  # 		System.out.println("rule defs for "+p.grammar.name+": "+localRuleDefs);
  # 
  # 		// remove locally-defined rules not in ref set
  # 		// find intersection of local rules and references from delegator
  # 		// that is set of rules needed by delegator
  # 		Set<String> localRuleDefsSatisfyingRefsFromBelow = new HashSet<String>();
  # 		for (String r : ruleRefs) {
  # 			if ( localRuleDefs.contains(r) ) {
  # 				localRuleDefsSatisfyingRefsFromBelow.add(r);
  # 			}
  # 		}
  # 
  # 		// now get list of refs from localRuleDefsSatisfyingRefsFromBelow.
  # 		// Those rules are also allowed in this delegate
  # 		for (GrammarAST refAST : p.grammar.ruleRefs) {
  # 			if ( localRuleDefsSatisfyingRefsFromBelow.contains(refAST.enclosingRuleName) ) {
  # 				// found rule ref within needed rule
  # 			}
  # 		}
  # 
  # 		// remove rule refs not in the new rule def set
  # 
  # 		// walk all children, adding rules not already defined
  # 		if ( p.children!=null ) {
  # 			for (CompositeGrammarTree delegate : p.children) {
  # 				_minimizeRuleSet(ruleDefs, ruleRefs, delegate);
  # 			}
  # 		}
  # 	}
  # 	public void trackNFAStatesThatHaveLabeledEdge(Label label,
  # 												  NFAState stateWithLabeledEdge)
  # 	{
  # 		Set<NFAState> states = typeToNFAStatesWithEdgeOfTypeMap.get(label);
  # 		if ( states==null ) {
  # 			states = new HashSet<NFAState>();
  # 			typeToNFAStatesWithEdgeOfTypeMap.put(label, states);
  # 		}
  # 		states.add(stateWithLabeledEdge);
  # 	}
  # 
  # 	public Map<Label, Set<NFAState>> getTypeToNFAStatesWithEdgeOfTypeMap() {
  # 		return typeToNFAStatesWithEdgeOfTypeMap;
  # 	}
  # 
  # 	public Set<NFAState> getStatesWithEdge(Label label) {
  # 		return typeToNFAStatesWithEdgeOfTypeMap.get(label);
  # 	}
  # A tree of component (delegate) grammars.
  # 
  # Rules defined in delegates are "inherited" like multi-inheritance
  # so you can override them.  All token types must be consistent across
  # rules from all delegate grammars, so they must be stored here in one
  # central place.
  # 
  # We have to start out assuming a composite grammar situation as we can't
  # look into the grammar files a priori to see if there is a delegate
  # statement.  Because of this, and to avoid duplicating token type tracking
  # in each grammar, even single noncomposite grammars use one of these objects
  # to track token types.
  class CompositeGrammar 
    include_class_members CompositeGrammarImports
    
    class_module.module_eval {
      const_set_lazy(:MIN_RULE_INDEX) { 1 }
      const_attr_reader  :MIN_RULE_INDEX
    }
    
    attr_accessor :delegate_grammar_tree_root
    alias_method :attr_delegate_grammar_tree_root, :delegate_grammar_tree_root
    undef_method :delegate_grammar_tree_root
    alias_method :attr_delegate_grammar_tree_root=, :delegate_grammar_tree_root=
    undef_method :delegate_grammar_tree_root=
    
    # Used during getRuleReferenceClosure to detect computation cycles
    attr_accessor :ref_closure_busy
    alias_method :attr_ref_closure_busy, :ref_closure_busy
    undef_method :ref_closure_busy
    alias_method :attr_ref_closure_busy=, :ref_closure_busy=
    undef_method :ref_closure_busy=
    
    # Used to assign state numbers; all grammars in composite share common
    # NFA space.  This NFA tracks state numbers number to state mapping.
    attr_accessor :state_counter
    alias_method :attr_state_counter, :state_counter
    undef_method :state_counter
    alias_method :attr_state_counter=, :state_counter=
    undef_method :state_counter=
    
    # The NFA states in the NFA built from rules across grammars in composite.
    # Maps state number to NFAState object.
    # This is a Vector instead of a List because I need to be able to grow
    # this properly.  After talking to Josh Bloch, Collections guy at Sun,
    # I decided this was easiest solution.
    attr_accessor :number_to_state_list
    alias_method :attr_number_to_state_list, :number_to_state_list
    undef_method :number_to_state_list
    alias_method :attr_number_to_state_list=, :number_to_state_list=
    undef_method :number_to_state_list=
    
    # Token names and literal tokens like "void" are uniquely indexed.
    # with -1 implying EOF.  Characters are different; they go from
    # -1 (EOF) to \uFFFE.  For example, 0 could be a binary byte you
    # want to lexer.  Labels of DFA/NFA transitions can be both tokens
    # and characters.  I use negative numbers for bookkeeping labels
    # like EPSILON. Char/String literals and token types overlap in the same
    # space, however.
    attr_accessor :max_token_type
    alias_method :attr_max_token_type, :max_token_type
    undef_method :max_token_type
    alias_method :attr_max_token_type=, :max_token_type=
    undef_method :max_token_type=
    
    # Map token like ID (but not literals like "while") to its token type
    attr_accessor :token_idto_type_map
    alias_method :attr_token_idto_type_map, :token_idto_type_map
    undef_method :token_idto_type_map
    alias_method :attr_token_idto_type_map=, :token_idto_type_map=
    undef_method :token_idto_type_map=
    
    # Map token literals like "while" to its token type.  It may be that
    # WHILE="while"=35, in which case both tokenIDToTypeMap and this
    # field will have entries both mapped to 35.
    attr_accessor :string_literal_to_type_map
    alias_method :attr_string_literal_to_type_map, :string_literal_to_type_map
    undef_method :string_literal_to_type_map
    alias_method :attr_string_literal_to_type_map=, :string_literal_to_type_map=
    undef_method :string_literal_to_type_map=
    
    # Reverse index for stringLiteralToTypeMap
    attr_accessor :type_to_string_literal_list
    alias_method :attr_type_to_string_literal_list, :type_to_string_literal_list
    undef_method :type_to_string_literal_list
    alias_method :attr_type_to_string_literal_list=, :type_to_string_literal_list=
    undef_method :type_to_string_literal_list=
    
    # Map a token type to its token name.
    # Must subtract MIN_TOKEN_TYPE from index.
    attr_accessor :type_to_token_list
    alias_method :attr_type_to_token_list, :type_to_token_list
    undef_method :type_to_token_list
    alias_method :attr_type_to_token_list=, :type_to_token_list=
    undef_method :type_to_token_list=
    
    # If combined or lexer grammar, track the rules.
    # Track lexer rules so we can warn about undefined tokens.
    # This is combined set of lexer rules from all lexer grammars
    # seen in all imports.
    attr_accessor :lexer_rules
    alias_method :attr_lexer_rules, :lexer_rules
    undef_method :lexer_rules
    alias_method :attr_lexer_rules=, :lexer_rules=
    undef_method :lexer_rules=
    
    # Rules are uniquely labeled from 1..n among all grammars
    attr_accessor :rule_index
    alias_method :attr_rule_index, :rule_index
    undef_method :rule_index
    alias_method :attr_rule_index=, :rule_index=
    undef_method :rule_index=
    
    # Map a rule index to its name; use a Vector on purpose as new
    # collections stuff won't let me setSize and make it grow.  :(
    # I need a specific guaranteed index, which the Collections stuff
    # won't let me have.
    attr_accessor :rule_index_to_rule_list
    alias_method :attr_rule_index_to_rule_list, :rule_index_to_rule_list
    undef_method :rule_index_to_rule_list
    alias_method :attr_rule_index_to_rule_list=, :rule_index_to_rule_list=
    undef_method :rule_index_to_rule_list=
    
    attr_accessor :watch_nfaconversion
    alias_method :attr_watch_nfaconversion, :watch_nfaconversion
    undef_method :watch_nfaconversion
    alias_method :attr_watch_nfaconversion=, :watch_nfaconversion=
    undef_method :watch_nfaconversion=
    
    typesig { [] }
    def init_token_symbol_tables
      # the faux token types take first NUM_FAUX_LABELS positions
      # then we must have room for the predefined runtime token types
      # like DOWN/UP used for tree parsing.
      @type_to_token_list.set_size(Label::NUM_FAUX_LABELS + Label::MIN_TOKEN_TYPE - 1)
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::INVALID, "<INVALID>")
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::EOT, "<EOT>")
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::SEMPRED, "<SEMPRED>")
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::SET, "<SET>")
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::EPSILON, Label::EPSILON_STR)
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::EOF, "EOF")
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::EOR_TOKEN_TYPE - 1, "<EOR>")
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::DOWN - 1, "DOWN")
      @type_to_token_list.set(Label::NUM_FAUX_LABELS + Label::UP - 1, "UP")
      @token_idto_type_map.put("<INVALID>", Utils.integer(Label::INVALID))
      @token_idto_type_map.put("<EOT>", Utils.integer(Label::EOT))
      @token_idto_type_map.put("<SEMPRED>", Utils.integer(Label::SEMPRED))
      @token_idto_type_map.put("<SET>", Utils.integer(Label::SET))
      @token_idto_type_map.put("<EPSILON>", Utils.integer(Label::EPSILON))
      @token_idto_type_map.put("EOF", Utils.integer(Label::EOF))
      @token_idto_type_map.put("<EOR>", Utils.integer(Label::EOR_TOKEN_TYPE))
      @token_idto_type_map.put("DOWN", Utils.integer(Label::DOWN))
      @token_idto_type_map.put("UP", Utils.integer(Label::UP))
    end
    
    typesig { [] }
    def initialize
      @delegate_grammar_tree_root = nil
      @ref_closure_busy = HashSet.new
      @state_counter = 0
      @number_to_state_list = Vector.new(1000)
      @max_token_type = Label::MIN_TOKEN_TYPE - 1
      @token_idto_type_map = HashMap.new
      @string_literal_to_type_map = HashMap.new
      @type_to_string_literal_list = Vector.new
      @type_to_token_list = Vector.new
      @lexer_rules = HashSet.new
      @rule_index = MIN_RULE_INDEX
      @rule_index_to_rule_list = Vector.new
      @watch_nfaconversion = false
      init_token_symbol_tables
    end
    
    typesig { [Grammar] }
    def initialize(g)
      initialize__composite_grammar()
      set_delegation_root(g)
    end
    
    typesig { [Grammar] }
    def set_delegation_root(root)
      @delegate_grammar_tree_root = CompositeGrammarTree.new(root)
      root.attr_composite_tree_node = @delegate_grammar_tree_root
    end
    
    typesig { [String] }
    def get_rule(rule_name)
      return @delegate_grammar_tree_root.get_rule(rule_name)
    end
    
    typesig { [String] }
    def get_option(key)
      return @delegate_grammar_tree_root.get_option(key)
    end
    
    typesig { [Grammar, Grammar] }
    # Add delegate grammar as child of delegator
    def add_grammar(delegator, delegate)
      if ((delegator.attr_composite_tree_node).nil?)
        delegator.attr_composite_tree_node = CompositeGrammarTree.new(delegator)
      end
      delegator.attr_composite_tree_node.add_child(CompositeGrammarTree.new(delegate))
      # // find delegator in tree so we can add a child to it
      # 		CompositeGrammarTree t = delegateGrammarTreeRoot.findNode(delegator);
      # 		t.addChild();
      # make sure new grammar shares this composite
      delegate.attr_composite = self
    end
    
    typesig { [Grammar] }
    # Get parent of this grammar
    def get_delegator(g)
      me = @delegate_grammar_tree_root.find_node(g)
      if ((me).nil?)
        return nil # not found
      end
      if (!(me.attr_parent).nil?)
        return me.attr_parent.attr_grammar
      end
      return nil
    end
    
    typesig { [Grammar] }
    # Get list of all delegates from all grammars in the delegate subtree of g.
    # The grammars are in delegation tree preorder.  Don't include g itself
    # in list as it is not a delegate of itself.
    def get_delegates(g)
      t = @delegate_grammar_tree_root.find_node(g)
      if ((t).nil?)
        return nil # no delegates
      end
      grammars = t.get_post_ordered_grammar_list
      grammars.remove(grammars.size - 1) # remove g (last one)
      return grammars
    end
    
    typesig { [Grammar] }
    def get_direct_delegates(g)
      t = @delegate_grammar_tree_root.find_node(g)
      children = t.attr_children
      if ((children).nil?)
        return nil
      end
      grammars = ArrayList.new
      i = 0
      while !(children).nil? && i < children.size
        child = children.get(i)
        grammars.add(child.attr_grammar)
        i += 1
      end
      return grammars
    end
    
    typesig { [Grammar] }
    # Get delegates below direct delegates of g
    def get_indirect_delegates(g)
      direct = get_direct_delegates(g)
      delegates = get_delegates(g)
      delegates.remove_all(direct)
      return delegates
    end
    
    typesig { [Grammar] }
    # Return list of delegate grammars from root down to g.
    # Order is root, ..., g.parent.  (g not included).
    def get_delegators(g)
      if ((g).equal?(@delegate_grammar_tree_root.attr_grammar))
        return nil
      end
      grammars = ArrayList.new
      t = @delegate_grammar_tree_root.find_node(g)
      # walk backwards to root, collecting grammars
      p = t.attr_parent
      while (!(p).nil?)
        grammars.add(0, p.attr_grammar) # add to head so in order later
        p = p.attr_parent
      end
      return grammars
    end
    
    typesig { [Grammar] }
    # Get set of rules for grammar g that need to have manual delegation
    # methods.  This is the list of rules collected from all direct/indirect
    # delegates minus rules overridden in grammar g.
    # 
    # This returns null except for the delegate root because it is the only
    # one that has to have a complete grammar rule interface.  The delegates
    # should not be instantiated directly for use as parsers (you can create
    # them to pass to the root parser's ctor as arguments).
    def get_delegated_rules(g)
      if (!(g).equal?(@delegate_grammar_tree_root.attr_grammar))
        return nil
      end
      rules = get_all_imported_rules(g)
      it = rules.iterator
      while it.has_next
        r = it.next_
        local_rule = g.get_locally_defined_rule(r.attr_name)
        # if locally defined or it's not local but synpred, don't make
        # a delegation method
        if (!(local_rule).nil? || r.attr_is_syn_pred)
          it.remove # kill overridden rules
        end
      end
      return rules
    end
    
    typesig { [Grammar] }
    # Get all rule definitions from all direct/indirect delegate grammars
    # of g.
    def get_all_imported_rules(g)
      rule_names = HashSet.new
      rules = HashSet.new
      subtree_root = @delegate_grammar_tree_root.find_node(g)
      grammars = subtree_root.get_post_ordered_grammar_list
      # walk all grammars
      i = 0
      while i < grammars.size
        delegate = grammars.get(i)
        # for each rule in delegate, add to rules if no rule with that
        # name as been seen.  (can't use removeAll; wrong hashcode/equals on Rule)
        it = delegate.get_rules.iterator
        while it.has_next
          r = it.next_
          if (!rule_names.contains(r.attr_name))
            rule_names.add(r.attr_name) # track that we've seen this
            rules.add(r)
          end
        end
        i += 1
      end
      return rules
    end
    
    typesig { [] }
    def get_root_grammar
      if ((@delegate_grammar_tree_root).nil?)
        return nil
      end
      return @delegate_grammar_tree_root.attr_grammar
    end
    
    typesig { [String] }
    def get_grammar(grammar_name)
      t = @delegate_grammar_tree_root.find_node(grammar_name)
      if (!(t).nil?)
        return t.attr_grammar
      end
      return nil
    end
    
    typesig { [] }
    # NFA spans multiple grammars, must handle here
    def get_new_nfastate_number
      return ((@state_counter += 1) - 1)
    end
    
    typesig { [NFAState] }
    def add_state(state)
      @number_to_state_list.set_size(state.attr_state_number + 1) # make sure we have room
      @number_to_state_list.set(state.attr_state_number, state)
    end
    
    typesig { [::Java::Int] }
    def get_state(s)
      return @number_to_state_list.get(s)
    end
    
    typesig { [] }
    def assign_token_types
      # ASSIGN TOKEN TYPES for all delegates (same walker)
      # System.out.println("### assign types");
      ttypes_walker = AssignTokenTypesBehavior.new
      ttypes_walker.set_astnode_class("org.antlr.tool.GrammarAST")
      grammars = @delegate_grammar_tree_root.get_post_ordered_grammar_list
      i = 0
      while !(grammars).nil? && i < grammars.size
        g = grammars.get(i)
        begin
          # System.out.println("    walking "+g.name);
          ttypes_walker.grammar(g.get_grammar_tree, g)
        rescue RecognitionException => re
          ErrorManager.error(ErrorManager::MSG_BAD_AST_STRUCTURE, re)
        end
        i += 1
      end
      # the walker has filled literals, tokens, and alias tables.
      # now tell it to define them in the root grammar
      ttypes_walker.define_tokens(@delegate_grammar_tree_root.attr_grammar)
    end
    
    typesig { [] }
    def define_grammar_symbols
      @delegate_grammar_tree_root.trim_lexer_imports_into_combined
      grammars = @delegate_grammar_tree_root.get_post_ordered_grammar_list
      i = 0
      while !(grammars).nil? && i < grammars.size
        g = grammars.get(i)
        g.define_grammar_symbols
        i += 1
      end
      i_ = 0
      while !(grammars).nil? && i_ < grammars.size
        g = grammars.get(i_)
        g.check_name_space_and_actions
        i_ += 1
      end
      minimize_rule_set
    end
    
    typesig { [] }
    def create_nfas
      if (ErrorManager.do_not_attempt_analysis)
        return
      end
      grammars = @delegate_grammar_tree_root.get_post_ordered_grammar_list
      names = ArrayList.new
      i = 0
      while i < grammars.size
        g = grammars.get(i)
        names.add(g.attr_name)
        i += 1
      end
      # System.out.println("### createNFAs for composite; grammars: "+names);
      i_ = 0
      while !(grammars).nil? && i_ < grammars.size
        g = grammars.get(i_)
        g.create_rule_start_and_stop_nfastates
        i_ += 1
      end
      i__ = 0
      while !(grammars).nil? && i__ < grammars.size
        g = grammars.get(i__)
        g.build_nfa
        i__ += 1
      end
    end
    
    typesig { [] }
    def minimize_rule_set
      rule_defs = HashSet.new
      __minimize_rule_set(rule_defs, @delegate_grammar_tree_root)
    end
    
    typesig { [JavaSet, CompositeGrammarTree] }
    def __minimize_rule_set(rule_defs, p)
      local_rule_defs = HashSet.new
      overrides = HashSet.new
      # compute set of non-overridden rules for this delegate
      p.attr_grammar.get_rules.each do |r|
        if (!rule_defs.contains(r.attr_name))
          local_rule_defs.add(r.attr_name)
        else
          if (!(r.attr_name == Grammar::ARTIFICIAL_TOKENS_RULENAME))
            # record any overridden rule 'cept tokens rule
            overrides.add(r.attr_name)
          end
        end
      end
      # System.out.println("rule defs for "+p.grammar.name+": "+localRuleDefs);
      # System.out.println("overridden rule for "+p.grammar.name+": "+overrides);
      p.attr_grammar.attr_overridden_rules = overrides
      # make set of all rules defined thus far walking delegation tree.
      # the same rule in two delegates resolves in favor of first found
      # in tree therefore second must not be included
      rule_defs.add_all(local_rule_defs)
      # pass larger set of defined rules to delegates
      if (!(p.attr_children).nil?)
        p.attr_children.each do |delegate|
          __minimize_rule_set(rule_defs, delegate)
        end
      end
    end
    
    private
    alias_method :initialize__composite_grammar, :initialize
  end
  
end
