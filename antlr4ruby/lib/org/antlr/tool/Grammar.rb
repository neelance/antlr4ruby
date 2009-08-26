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
  module GrammarImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Org::Antlr::Misc
      include_const ::Org::Antlr::Misc, :Utils
      include ::Antlr
      include_const ::Antlr::Collections, :AST
      include_const ::Org::Antlr, :Tool
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate::Language, :AngleBracketTemplateLexer
      include ::Java::Io
      include ::Java::Util
    }
  end
  
  # Represents a grammar in memory.
  class Grammar 
    include_class_members GrammarImports
    
    class_module.module_eval {
      const_set_lazy(:SYNPRED_RULE_PREFIX) { "synpred" }
      const_attr_reader  :SYNPRED_RULE_PREFIX
      
      const_set_lazy(:GRAMMAR_FILE_EXTENSION) { ".g" }
      const_attr_reader  :GRAMMAR_FILE_EXTENSION
      
      # used for generating lexer temp files
      const_set_lazy(:LEXER_GRAMMAR_FILE_EXTENSION) { ".g" }
      const_attr_reader  :LEXER_GRAMMAR_FILE_EXTENSION
      
      const_set_lazy(:INITIAL_DECISION_LIST_SIZE) { 300 }
      const_attr_reader  :INITIAL_DECISION_LIST_SIZE
      
      const_set_lazy(:INVALID_RULE_INDEX) { -1 }
      const_attr_reader  :INVALID_RULE_INDEX
      
      # the various kinds of labels. t=type, id=ID, types+=type ids+=ID
      const_set_lazy(:RULE_LABEL) { 1 }
      const_attr_reader  :RULE_LABEL
      
      const_set_lazy(:TOKEN_LABEL) { 2 }
      const_attr_reader  :TOKEN_LABEL
      
      const_set_lazy(:RULE_LIST_LABEL) { 3 }
      const_attr_reader  :RULE_LIST_LABEL
      
      const_set_lazy(:TOKEN_LIST_LABEL) { 4 }
      const_attr_reader  :TOKEN_LIST_LABEL
      
      const_set_lazy(:CHAR_LABEL) { 5 }
      const_attr_reader  :CHAR_LABEL
      
      # used in lexer for x='a'
      
      def label_type_to_string
        defined?(@@label_type_to_string) ? @@label_type_to_string : @@label_type_to_string= Array.typed(String).new(["<invalid>", "rule", "token", "rule-list", "token-list"])
      end
      alias_method :attr_label_type_to_string, :label_type_to_string
      
      def label_type_to_string=(value)
        @@label_type_to_string = value
      end
      alias_method :attr_label_type_to_string=, :label_type_to_string=
      
      const_set_lazy(:ARTIFICIAL_TOKENS_RULENAME) { "Tokens" }
      const_attr_reader  :ARTIFICIAL_TOKENS_RULENAME
      
      const_set_lazy(:FRAGMENT_RULE_MODIFIER) { "fragment" }
      const_attr_reader  :FRAGMENT_RULE_MODIFIER
      
      const_set_lazy(:SYNPREDGATE_ACTION_NAME) { "synpredgate" }
      const_attr_reader  :SYNPREDGATE_ACTION_NAME
      
      # When converting ANTLR char and string literals, here is the
      # value set of escape chars.
      
      def antlrliteral_escaped_char_value
        defined?(@@antlrliteral_escaped_char_value) ? @@antlrliteral_escaped_char_value : @@antlrliteral_escaped_char_value= Array.typed(::Java::Int).new(255) { 0 }
      end
      alias_method :attr_antlrliteral_escaped_char_value, :antlrliteral_escaped_char_value
      
      def antlrliteral_escaped_char_value=(value)
        @@antlrliteral_escaped_char_value = value
      end
      alias_method :attr_antlrliteral_escaped_char_value=, :antlrliteral_escaped_char_value=
      
      # Given a char, we need to be able to show as an ANTLR literal.
      
      def antlrliteral_char_value_escape
        defined?(@@antlrliteral_char_value_escape) ? @@antlrliteral_char_value_escape : @@antlrliteral_char_value_escape= Array.typed(String).new(255) { nil }
      end
      alias_method :attr_antlrliteral_char_value_escape, :antlrliteral_char_value_escape
      
      def antlrliteral_char_value_escape=(value)
        @@antlrliteral_char_value_escape = value
      end
      alias_method :attr_antlrliteral_char_value_escape=, :antlrliteral_char_value_escape=
      
      when_class_loaded do
        self.attr_antlrliteral_escaped_char_value[Character.new(?n.ord)] = Character.new(?\n.ord)
        self.attr_antlrliteral_escaped_char_value[Character.new(?r.ord)] = Character.new(?\r.ord)
        self.attr_antlrliteral_escaped_char_value[Character.new(?t.ord)] = Character.new(?\t.ord)
        self.attr_antlrliteral_escaped_char_value[Character.new(?b.ord)] = Character.new(?\b.ord)
        self.attr_antlrliteral_escaped_char_value[Character.new(?f.ord)] = Character.new(?\f.ord)
        self.attr_antlrliteral_escaped_char_value[Character.new(?\\.ord)] = Character.new(?\\.ord)
        self.attr_antlrliteral_escaped_char_value[Character.new(?\'.ord)] = Character.new(?\'.ord)
        self.attr_antlrliteral_escaped_char_value[Character.new(?".ord)] = Character.new(?".ord)
        self.attr_antlrliteral_char_value_escape[Character.new(?\n.ord)] = "\\n"
        self.attr_antlrliteral_char_value_escape[Character.new(?\r.ord)] = "\\r"
        self.attr_antlrliteral_char_value_escape[Character.new(?\t.ord)] = "\\t"
        self.attr_antlrliteral_char_value_escape[Character.new(?\b.ord)] = "\\b"
        self.attr_antlrliteral_char_value_escape[Character.new(?\f.ord)] = "\\f"
        self.attr_antlrliteral_char_value_escape[Character.new(?\\.ord)] = "\\\\"
        self.attr_antlrliteral_char_value_escape[Character.new(?\'.ord)] = "\\'"
      end
      
      const_set_lazy(:LEXER) { 1 }
      const_attr_reader  :LEXER
      
      const_set_lazy(:PARSER) { 2 }
      const_attr_reader  :PARSER
      
      const_set_lazy(:TREE_PARSER) { 3 }
      const_attr_reader  :TREE_PARSER
      
      const_set_lazy(:COMBINED) { 4 }
      const_attr_reader  :COMBINED
      
      const_set_lazy(:GrammarTypeToString) { Array.typed(String).new(["<invalid>", "lexer", "parser", "tree", "combined"]) }
      const_attr_reader  :GrammarTypeToString
      
      # no suffix for tree grammars
      # if combined grammar, gen Parser and Lexer will be done later
      const_set_lazy(:GrammarTypeToFileNameSuffix) { Array.typed(String).new(["<invalid>", "Lexer", "Parser", "", "Parser"]) }
      const_attr_reader  :GrammarTypeToFileNameSuffix
      
      map(LEXER, LEXER)
      map(LEXER, PARSER)
      map(LEXER, COMBINED)
      map(PARSER, PARSER)
      map(PARSER, COMBINED)
      map(TREE_PARSER, TREE_PARSER)
      # TODO: allow COMBINED
      # map(COMBINED, COMBINED);
      
      def valid_delegations
        defined?(@@valid_delegations) ? @@valid_delegations : @@valid_delegations= # Set of valid imports.  E.g., can only import a tree parser into
        # another tree parser.  Maps delegate to set of delegator grammar types.
        # validDelegations.get(LEXER) gives list of the kinds of delegators
        # that can import lexers.
        Class.new(MultiMap.class == Class ? MultiMap : Object) do
          extend LocalClass
          include_class_members Grammar
          include MultiMap if MultiMap.class == Module
          
          typesig { [] }
          define_method :initialize do
            super()
          end
          
          private
          alias_method :initialize_anonymous, :initialize
        end.new_local(self)
      end
      alias_method :attr_valid_delegations, :valid_delegations
      
      def valid_delegations=(value)
        @@valid_delegations = value
      end
      alias_method :attr_valid_delegations=, :valid_delegations=
    }
    
    # This is the buffer of *all* tokens found in the grammar file
    # including whitespace tokens etc...  I use this to extract
    # lexer rules from combined grammars.
    attr_accessor :token_buffer
    alias_method :attr_token_buffer, :token_buffer
    undef_method :token_buffer
    alias_method :attr_token_buffer=, :token_buffer=
    undef_method :token_buffer=
    
    class_module.module_eval {
      const_set_lazy(:IGNORE_STRING_IN_GRAMMAR_FILE_NAME) { "__" }
      const_attr_reader  :IGNORE_STRING_IN_GRAMMAR_FILE_NAME
      
      const_set_lazy(:AUTO_GENERATED_TOKEN_NAME_PREFIX) { "T__" }
      const_attr_reader  :AUTO_GENERATED_TOKEN_NAME_PREFIX
      
      const_set_lazy(:Decision) { Class.new do
        include_class_members Grammar
        
        attr_accessor :decision
        alias_method :attr_decision, :decision
        undef_method :decision
        alias_method :attr_decision=, :decision=
        undef_method :decision=
        
        attr_accessor :start_state
        alias_method :attr_start_state, :start_state
        undef_method :start_state
        alias_method :attr_start_state=, :start_state=
        undef_method :start_state=
        
        attr_accessor :block_ast
        alias_method :attr_block_ast, :block_ast
        undef_method :block_ast
        alias_method :attr_block_ast=, :block_ast=
        undef_method :block_ast=
        
        attr_accessor :dfa
        alias_method :attr_dfa, :dfa
        undef_method :dfa
        alias_method :attr_dfa=, :dfa=
        undef_method :dfa=
        
        typesig { [] }
        def initialize
          @decision = 0
          @start_state = nil
          @block_ast = nil
          @dfa = nil
        end
        
        private
        alias_method :initialize__decision, :initialize
      end }
      
      const_set_lazy(:LabelElementPair) { Class.new do
        extend LocalClass
        include_class_members Grammar
        
        attr_accessor :label
        alias_method :attr_label, :label
        undef_method :label
        alias_method :attr_label=, :label=
        undef_method :label=
        
        attr_accessor :element_ref
        alias_method :attr_element_ref, :element_ref
        undef_method :element_ref
        alias_method :attr_element_ref=, :element_ref=
        undef_method :element_ref=
        
        attr_accessor :referenced_rule_name
        alias_method :attr_referenced_rule_name, :referenced_rule_name
        undef_method :referenced_rule_name
        alias_method :attr_referenced_rule_name=, :referenced_rule_name=
        undef_method :referenced_rule_name=
        
        # Has an action referenced the label?  Set by ActionAnalysis.g
        # Currently only set for rule labels.
        attr_accessor :action_references_label
        alias_method :attr_action_references_label, :action_references_label
        undef_method :action_references_label
        alias_method :attr_action_references_label=, :action_references_label=
        undef_method :action_references_label=
        
        attr_accessor :type
        alias_method :attr_type, :type
        undef_method :type
        alias_method :attr_type=, :type=
        undef_method :type=
        
        typesig { [Antlr::Token, class_self::GrammarAST] }
        # in {RULE_LABEL,TOKEN_LABEL,RULE_LIST_LABEL,TOKEN_LIST_LABEL}
        def initialize(label, element_ref)
          @label = nil
          @element_ref = nil
          @referenced_rule_name = nil
          @action_references_label = false
          @type = 0
          @label = label
          @element_ref = element_ref
          @referenced_rule_name = element_ref.get_text
        end
        
        typesig { [] }
        def get_referenced_rule
          return get_rule(@referenced_rule_name)
        end
        
        typesig { [] }
        def to_s
          return @element_ref.to_s
        end
        
        private
        alias_method :initialize__label_element_pair, :initialize
      end }
    }
    
    # What name did the user provide for this grammar?
    attr_accessor :name
    alias_method :attr_name, :name
    undef_method :name
    alias_method :attr_name=, :name=
    undef_method :name=
    
    # What type of grammar is this: lexer, parser, tree walker
    attr_accessor :type
    alias_method :attr_type, :type
    undef_method :type
    alias_method :attr_type=, :type=
    undef_method :type=
    
    # A list of options specified at the grammar level such as language=Java.
    # The value can be an AST for complicated values such as character sets.
    # There may be code generator specific options in here.  I do no
    # interpretation of the key/value pairs...they are simply available for
    # who wants them.
    attr_accessor :options
    alias_method :attr_options, :options
    undef_method :options
    alias_method :attr_options=, :options=
    undef_method :options=
    
    class_module.module_eval {
      add("language")
      add("tokenVocab")
      add("TokenLabelType")
      add("superClass")
      add("filter")
      add("k")
      add("backtrack")
      add("memoize")
      const_set_lazy(:LegalLexerOptions) { Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :LegalLexerOptions
      
      add("language")
      add("tokenVocab")
      add("output")
      add("rewrite")
      add("ASTLabelType")
      add("TokenLabelType")
      add("superClass")
      add("k")
      add("backtrack")
      add("memoize")
      const_set_lazy(:LegalParserOptions) { Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :LegalParserOptions
      
      add("language")
      add("tokenVocab")
      add("output")
      add("rewrite")
      add("ASTLabelType")
      add("TokenLabelType")
      add("superClass")
      add("filter")
      add("k")
      add("backtrack")
      add("memoize")
      const_set_lazy(:LegalTreeParserOptions) { Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :LegalTreeParserOptions
      
      add("output")
      add("ASTLabelType")
      add("superClass")
      add("k")
      add("backtrack")
      add("memoize")
      add("rewrite")
      const_set_lazy(:DoNotCopyOptionsToLexer) { Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :DoNotCopyOptionsToLexer
      
      put("language", "Java")
      const_set_lazy(:DefaultOptions) { Class.new(HashMap.class == Class ? HashMap : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashMap if HashMap.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :DefaultOptions
      
      add("k")
      add("greedy")
      add("backtrack")
      add("memoize")
      const_set_lazy(:LegalBlockOptions) { Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :LegalBlockOptions
      
      put("greedy", "true")
      const_set_lazy(:DefaultBlockOptions) { # What are the default options for a subrule?
      Class.new(HashMap.class == Class ? HashMap : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashMap if HashMap.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :DefaultBlockOptions
      
      put("greedy", "true")
      const_set_lazy(:DefaultLexerBlockOptions) { Class.new(HashMap.class == Class ? HashMap : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashMap if HashMap.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :DefaultLexerBlockOptions
      
      add(DefaultTokenOption)
      const_set_lazy(:LegalTokenOptions) { # Token options are here to avoid contaminating Token object in runtime
      # Legal options for terminal refs like ID<node=MyVarNode>
      Class.new(HashSet.class == Class ? HashSet : Object) do
        extend LocalClass
        include_class_members Grammar
        include HashSet if HashSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :LegalTokenOptions
      
      const_set_lazy(:DefaultTokenOption) { "node" }
      const_attr_reader  :DefaultTokenOption
    }
    
    # Is there a global fixed lookahead set for this grammar?
    # If 0, nothing specified.  -1 implies we have not looked at
    # the options table yet to set k.
    attr_accessor :global_k
    alias_method :attr_global_k, :global_k
    undef_method :global_k
    alias_method :attr_global_k=, :global_k=
    undef_method :global_k=
    
    # Map a scope to a map of name:action pairs.
    # Map<String, Map<String,GrammarAST>>
    # The code generator will use this to fill holes in the output files.
    # I track the AST node for the action in case I need the line number
    # for errors.
    attr_accessor :actions
    alias_method :attr_actions, :actions
    undef_method :actions
    alias_method :attr_actions=, :actions=
    undef_method :actions=
    
    # The NFA that represents the grammar with edges labelled with tokens
    # or epsilon.  It is more suitable to analysis than an AST representation.
    attr_accessor :nfa
    alias_method :attr_nfa, :nfa
    undef_method :nfa
    alias_method :attr_nfa=, :nfa=
    undef_method :nfa=
    
    attr_accessor :factory
    alias_method :attr_factory, :factory
    undef_method :factory
    alias_method :attr_factory=, :factory=
    undef_method :factory=
    
    # If this grammar is part of a larger composite grammar via delegate
    # statement, then this points at the composite.  The composite holds
    # a global list of rules, token types, decision numbers, etc...
    attr_accessor :composite
    alias_method :attr_composite, :composite
    undef_method :composite
    alias_method :attr_composite=, :composite=
    undef_method :composite=
    
    # A pointer back into grammar tree.  Needed so we can add delegates.
    attr_accessor :composite_tree_node
    alias_method :attr_composite_tree_node, :composite_tree_node
    undef_method :composite_tree_node
    alias_method :attr_composite_tree_node=, :composite_tree_node=
    undef_method :composite_tree_node=
    
    # If this is a delegate of another grammar, this is the label used
    # as an instance var by that grammar to point at this grammar. null
    # if no label was specified in the delegate statement.
    attr_accessor :label
    alias_method :attr_label, :label
    undef_method :label
    alias_method :attr_label=, :label=
    undef_method :label=
    
    # TODO: hook this to the charVocabulary option
    attr_accessor :char_vocabulary
    alias_method :attr_char_vocabulary, :char_vocabulary
    undef_method :char_vocabulary
    alias_method :attr_char_vocabulary=, :char_vocabulary=
    undef_method :char_vocabulary=
    
    # For ANTLRWorks, we want to be able to map a line:col to a specific
    # decision DFA so it can display DFA.
    attr_accessor :line_column_to_lookahead_dfamap
    alias_method :attr_line_column_to_lookahead_dfamap, :line_column_to_lookahead_dfamap
    undef_method :line_column_to_lookahead_dfamap
    alias_method :attr_line_column_to_lookahead_dfamap=, :line_column_to_lookahead_dfamap=
    undef_method :line_column_to_lookahead_dfamap=
    
    attr_accessor :tool
    alias_method :attr_tool, :tool
    undef_method :tool
    alias_method :attr_tool=, :tool=
    undef_method :tool=
    
    # The unique set of all rule references in any rule; set of tree node
    # objects so two refs to same rule can exist but at different line/position.
    attr_accessor :rule_refs
    alias_method :attr_rule_refs, :rule_refs
    undef_method :rule_refs
    alias_method :attr_rule_refs=, :rule_refs=
    undef_method :rule_refs=
    
    attr_accessor :scoped_rule_refs
    alias_method :attr_scoped_rule_refs, :scoped_rule_refs
    undef_method :scoped_rule_refs
    alias_method :attr_scoped_rule_refs=, :scoped_rule_refs=
    undef_method :scoped_rule_refs=
    
    # The unique set of all token ID references in any rule
    attr_accessor :token_idrefs
    alias_method :attr_token_idrefs, :token_idrefs
    undef_method :token_idrefs
    alias_method :attr_token_idrefs=, :token_idrefs=
    undef_method :token_idrefs=
    
    # Be able to assign a number to every decision in grammar;
    # decisions in 1..n
    attr_accessor :decision_count
    alias_method :attr_decision_count, :decision_count
    undef_method :decision_count
    alias_method :attr_decision_count=, :decision_count=
    undef_method :decision_count=
    
    # A list of all rules that are in any left-recursive cycle.  There
    # could be multiple cycles, but this is a flat list of all problematic
    # rules.
    attr_accessor :left_recursive_rules
    alias_method :attr_left_recursive_rules, :left_recursive_rules
    undef_method :left_recursive_rules
    alias_method :attr_left_recursive_rules=, :left_recursive_rules=
    undef_method :left_recursive_rules=
    
    # An external tool requests that DFA analysis abort prematurely.  Stops
    # at DFA granularity, which are limited to a DFA size and time computation
    # as failsafe.
    attr_accessor :external_analysis_abort
    alias_method :attr_external_analysis_abort, :external_analysis_abort
    undef_method :external_analysis_abort
    alias_method :attr_external_analysis_abort=, :external_analysis_abort=
    undef_method :external_analysis_abort=
    
    # When we read in a grammar, we track the list of syntactic predicates
    # and build faux rules for them later.  See my blog entry Dec 2, 2005:
    # http://www.antlr.org/blog/antlr3/lookahead.tml
    # This maps the name (we make up) for a pred to the AST grammar fragment.
    attr_accessor :name_to_synpred_astmap
    alias_method :attr_name_to_synpred_astmap, :name_to_synpred_astmap
    undef_method :name_to_synpred_astmap
    alias_method :attr_name_to_synpred_astmap=, :name_to_synpred_astmap=
    undef_method :name_to_synpred_astmap=
    
    # At least one rule has memoize=true
    attr_accessor :at_least_one_rule_memoizes
    alias_method :attr_at_least_one_rule_memoizes, :at_least_one_rule_memoizes
    undef_method :at_least_one_rule_memoizes
    alias_method :attr_at_least_one_rule_memoizes=, :at_least_one_rule_memoizes=
    undef_method :at_least_one_rule_memoizes=
    
    # Was this created from a COMBINED grammar?
    attr_accessor :implicit_lexer
    alias_method :attr_implicit_lexer, :implicit_lexer
    undef_method :implicit_lexer
    alias_method :attr_implicit_lexer=, :implicit_lexer=
    undef_method :implicit_lexer=
    
    # Map a rule to it's Rule object
    attr_accessor :name_to_rule_map
    alias_method :attr_name_to_rule_map, :name_to_rule_map
    undef_method :name_to_rule_map
    alias_method :attr_name_to_rule_map=, :name_to_rule_map=
    undef_method :name_to_rule_map=
    
    # If this rule is a delegate, some rules might be overridden; don't
    # want to gen code for them.
    attr_accessor :overridden_rules
    alias_method :attr_overridden_rules, :overridden_rules
    undef_method :overridden_rules
    alias_method :attr_overridden_rules=, :overridden_rules=
    undef_method :overridden_rules=
    
    # The list of all rules referenced in this grammar, not defined here,
    # and defined in a delegate grammar.  Not all of these will be generated
    # in the recognizer for this file; only those that are affected by rule
    # definitions in this grammar.  I am not sure the Java target will need
    # this but I'm leaving in case other targets need it.
    # @see NameSpaceChecker.lookForReferencesToUndefinedSymbols()
    attr_accessor :delegated_rule_references
    alias_method :attr_delegated_rule_references, :delegated_rule_references
    undef_method :delegated_rule_references
    alias_method :attr_delegated_rule_references=, :delegated_rule_references=
    undef_method :delegated_rule_references=
    
    # The ANTLRParser tracks lexer rules when reading combined grammars
    # so we can build the Tokens rule.
    attr_accessor :lexer_rule_names_in_combined
    alias_method :attr_lexer_rule_names_in_combined, :lexer_rule_names_in_combined
    undef_method :lexer_rule_names_in_combined
    alias_method :attr_lexer_rule_names_in_combined=, :lexer_rule_names_in_combined=
    undef_method :lexer_rule_names_in_combined=
    
    # Track the scopes defined outside of rules and the scopes associated
    # with all rules (even if empty).
    attr_accessor :scopes
    alias_method :attr_scopes, :scopes
    undef_method :scopes
    alias_method :attr_scopes=, :scopes=
    undef_method :scopes=
    
    # An AST that records entire input grammar with all rules.  A simple
    # grammar with one rule, "grammar t; a : A | B ;", looks like:
    # ( grammar t ( rule a ( BLOCK ( ALT A ) ( ALT B ) ) <end-of-rule> ) )
    attr_accessor :grammar_tree
    alias_method :attr_grammar_tree, :grammar_tree
    undef_method :grammar_tree
    alias_method :attr_grammar_tree=, :grammar_tree=
    undef_method :grammar_tree=
    
    # Each subrule/rule is a decision point and we must track them so we
    # can go back later and build DFA predictors for them.  This includes
    # all the rules, subrules, optional blocks, ()+, ()* etc...
    attr_accessor :index_to_decision
    alias_method :attr_index_to_decision, :index_to_decision
    undef_method :index_to_decision
    alias_method :attr_index_to_decision=, :index_to_decision=
    undef_method :index_to_decision=
    
    # If non-null, this is the code generator we will use to generate
    # recognizers in the target language.
    attr_accessor :generator
    alias_method :attr_generator, :generator
    undef_method :generator
    alias_method :attr_generator=, :generator=
    undef_method :generator=
    
    attr_accessor :name_space_checker
    alias_method :attr_name_space_checker, :name_space_checker
    undef_method :name_space_checker
    alias_method :attr_name_space_checker=, :name_space_checker=
    undef_method :name_space_checker=
    
    attr_accessor :ll1analyzer
    alias_method :attr_ll1analyzer, :ll1analyzer
    undef_method :ll1analyzer
    alias_method :attr_ll1analyzer=, :ll1analyzer=
    undef_method :ll1analyzer=
    
    # For merged lexer/parsers, we must construct a separate lexer spec.
    # This is the template for lexer; put the literals first then the
    # regular rules.  We don't need to specify a token vocab import as
    # I make the new grammar import from the old all in memory; don't want
    # to force it to read from the disk.  Lexer grammar will have same
    # name as original grammar but will be in different filename.  Foo.g
    # with combined grammar will have FooParser.java generated and
    # Foo__.g with again Foo inside.  It will however generate FooLexer.java
    # as it's a lexer grammar.  A bit odd, but autogenerated.  Can tweak
    # later if we want.
    attr_accessor :lexer_grammar_st
    alias_method :attr_lexer_grammar_st, :lexer_grammar_st
    undef_method :lexer_grammar_st
    alias_method :attr_lexer_grammar_st=, :lexer_grammar_st=
    undef_method :lexer_grammar_st=
    
    # What file name holds this grammar?
    attr_accessor :file_name
    alias_method :attr_file_name, :file_name
    undef_method :file_name
    alias_method :attr_file_name=, :file_name=
    undef_method :file_name=
    
    # How long in ms did it take to build DFAs for this grammar?
    # If this grammar is a combined grammar, it only records time for
    # the parser grammar component.  This only records the time to
    # do the LL(*) work; NFA->DFA conversion.
    attr_accessor :dfacreation_wall_clock_time_in_ms
    alias_method :attr_dfacreation_wall_clock_time_in_ms, :dfacreation_wall_clock_time_in_ms
    undef_method :dfacreation_wall_clock_time_in_ms
    alias_method :attr_dfacreation_wall_clock_time_in_ms=, :dfacreation_wall_clock_time_in_ms=
    undef_method :dfacreation_wall_clock_time_in_ms=
    
    attr_accessor :number_of_semantic_predicates
    alias_method :attr_number_of_semantic_predicates, :number_of_semantic_predicates
    undef_method :number_of_semantic_predicates
    alias_method :attr_number_of_semantic_predicates=, :number_of_semantic_predicates=
    undef_method :number_of_semantic_predicates=
    
    attr_accessor :number_of_manual_lookahead_options
    alias_method :attr_number_of_manual_lookahead_options, :number_of_manual_lookahead_options
    undef_method :number_of_manual_lookahead_options
    alias_method :attr_number_of_manual_lookahead_options=, :number_of_manual_lookahead_options=
    undef_method :number_of_manual_lookahead_options=
    
    attr_accessor :set_of_nondeterministic_decision_numbers
    alias_method :attr_set_of_nondeterministic_decision_numbers, :set_of_nondeterministic_decision_numbers
    undef_method :set_of_nondeterministic_decision_numbers
    alias_method :attr_set_of_nondeterministic_decision_numbers=, :set_of_nondeterministic_decision_numbers=
    undef_method :set_of_nondeterministic_decision_numbers=
    
    attr_accessor :set_of_nondeterministic_decision_numbers_resolved_with_predicates
    alias_method :attr_set_of_nondeterministic_decision_numbers_resolved_with_predicates, :set_of_nondeterministic_decision_numbers_resolved_with_predicates
    undef_method :set_of_nondeterministic_decision_numbers_resolved_with_predicates
    alias_method :attr_set_of_nondeterministic_decision_numbers_resolved_with_predicates=, :set_of_nondeterministic_decision_numbers_resolved_with_predicates=
    undef_method :set_of_nondeterministic_decision_numbers_resolved_with_predicates=
    
    attr_accessor :set_of_dfawhose_analysis_timed_out
    alias_method :attr_set_of_dfawhose_analysis_timed_out, :set_of_dfawhose_analysis_timed_out
    undef_method :set_of_dfawhose_analysis_timed_out
    alias_method :attr_set_of_dfawhose_analysis_timed_out=, :set_of_dfawhose_analysis_timed_out=
    undef_method :set_of_dfawhose_analysis_timed_out=
    
    # Track decisions with syn preds specified for reporting.
    # This is the a set of BLOCK type AST nodes.
    attr_accessor :blocks_with_syn_preds
    alias_method :attr_blocks_with_syn_preds, :blocks_with_syn_preds
    undef_method :blocks_with_syn_preds
    alias_method :attr_blocks_with_syn_preds=, :blocks_with_syn_preds=
    undef_method :blocks_with_syn_preds=
    
    # Track decisions that actually use the syn preds in the DFA.
    # Computed during NFA to DFA conversion.
    attr_accessor :decisions_whose_dfas_uses_syn_preds
    alias_method :attr_decisions_whose_dfas_uses_syn_preds, :decisions_whose_dfas_uses_syn_preds
    undef_method :decisions_whose_dfas_uses_syn_preds
    alias_method :attr_decisions_whose_dfas_uses_syn_preds=, :decisions_whose_dfas_uses_syn_preds=
    undef_method :decisions_whose_dfas_uses_syn_preds=
    
    # Track names of preds so we can avoid generating preds that aren't used
    # Computed during NFA to DFA conversion.  Just walk accept states
    # and look for synpreds because that is the only state target whose
    # incident edges can have synpreds.  Same is try for
    # decisionsWhoseDFAsUsesSynPreds.
    attr_accessor :syn_pred_names_used_in_dfa
    alias_method :attr_syn_pred_names_used_in_dfa, :syn_pred_names_used_in_dfa
    undef_method :syn_pred_names_used_in_dfa
    alias_method :attr_syn_pred_names_used_in_dfa=, :syn_pred_names_used_in_dfa=
    undef_method :syn_pred_names_used_in_dfa=
    
    # Track decisions with syn preds specified for reporting.
    # This is the a set of BLOCK type AST nodes.
    attr_accessor :blocks_with_sem_preds
    alias_method :attr_blocks_with_sem_preds, :blocks_with_sem_preds
    undef_method :blocks_with_sem_preds
    alias_method :attr_blocks_with_sem_preds=, :blocks_with_sem_preds=
    undef_method :blocks_with_sem_preds=
    
    # Track decisions that actually use the syn preds in the DFA.
    attr_accessor :decisions_whose_dfas_uses_sem_preds
    alias_method :attr_decisions_whose_dfas_uses_sem_preds, :decisions_whose_dfas_uses_sem_preds
    undef_method :decisions_whose_dfas_uses_sem_preds
    alias_method :attr_decisions_whose_dfas_uses_sem_preds=, :decisions_whose_dfas_uses_sem_preds=
    undef_method :decisions_whose_dfas_uses_sem_preds=
    
    attr_accessor :all_decision_dfacreated
    alias_method :attr_all_decision_dfacreated, :all_decision_dfacreated
    undef_method :all_decision_dfacreated
    alias_method :attr_all_decision_dfacreated=, :all_decision_dfacreated=
    undef_method :all_decision_dfacreated=
    
    # We need a way to detect when a lexer grammar is autogenerated from
    # another grammar or we are just sending in a string representing a
    # grammar.  We don't want to generate a .tokens file, for example,
    # in such cases.
    attr_accessor :built_from_string
    alias_method :attr_built_from_string, :built_from_string
    undef_method :built_from_string
    alias_method :attr_built_from_string=, :built_from_string=
    undef_method :built_from_string=
    
    # Factored out the sanity checking code; delegate to it.
    attr_accessor :sanity
    alias_method :attr_sanity, :sanity
    undef_method :sanity
    alias_method :attr_sanity=, :sanity=
    undef_method :sanity=
    
    typesig { [Tool, String, CompositeGrammar] }
    # Create a grammar from file name.
    def initialize(tool, file_name, composite)
      @token_buffer = nil
      @name = nil
      @type = 0
      @options = nil
      @global_k = -1
      @actions = HashMap.new
      @nfa = nil
      @factory = nil
      @composite = nil
      @composite_tree_node = nil
      @label = nil
      @char_vocabulary = nil
      @line_column_to_lookahead_dfamap = HashMap.new
      @tool = nil
      @rule_refs = HashSet.new
      @scoped_rule_refs = HashSet.new
      @token_idrefs = HashSet.new
      @decision_count = 0
      @left_recursive_rules = nil
      @external_analysis_abort = false
      @name_to_synpred_astmap = nil
      @at_least_one_rule_memoizes = false
      @implicit_lexer = false
      @name_to_rule_map = LinkedHashMap.new
      @overridden_rules = HashSet.new
      @delegated_rule_references = HashSet.new
      @lexer_rule_names_in_combined = ArrayList.new
      @scopes = HashMap.new
      @grammar_tree = nil
      @index_to_decision = Vector.new(INITIAL_DECISION_LIST_SIZE)
      @generator = nil
      @name_space_checker = NameSpaceChecker.new(self)
      @ll1analyzer = LL1Analyzer.new(self)
      @lexer_grammar_st = StringTemplate.new("lexer grammar <name>;\n" + "<if(options)>" + "options {\n" + "  <options:{<it.name>=<it.value>;<\\n>}>\n" + "}<\\n>\n" + "<endif>\n" + "<if(imports)>import <imports; separator=\", \">;<endif>\n" + "<actionNames,actions:{n,a|@<n> {<a>}\n}>\n" + "<literals:{<it.ruleName> : <it.literal> ;\n}>\n" + "<rules>", AngleBracketTemplateLexer)
      @file_name = nil
      @dfacreation_wall_clock_time_in_ms = 0
      @number_of_semantic_predicates = 0
      @number_of_manual_lookahead_options = 0
      @set_of_nondeterministic_decision_numbers = HashSet.new
      @set_of_nondeterministic_decision_numbers_resolved_with_predicates = HashSet.new
      @set_of_dfawhose_analysis_timed_out = HashSet.new
      @blocks_with_syn_preds = HashSet.new
      @decisions_whose_dfas_uses_syn_preds = HashSet.new
      @syn_pred_names_used_in_dfa = HashSet.new
      @blocks_with_sem_preds = HashSet.new
      @decisions_whose_dfas_uses_sem_preds = HashSet.new
      @all_decision_dfacreated = false
      @built_from_string = false
      @sanity = GrammarSanity.new(self)
      @composite = composite
      set_tool(tool)
      set_file_name(file_name)
      # ensure we have the composite set to something
      if ((composite.attr_delegate_grammar_tree_root).nil?)
        composite.set_delegation_root(self)
      end
    end
    
    typesig { [] }
    # Useful for when you are sure that you are not part of a composite
    # already.  Used in Interp/RandomPhrase and testing.
    def initialize
      @token_buffer = nil
      @name = nil
      @type = 0
      @options = nil
      @global_k = -1
      @actions = HashMap.new
      @nfa = nil
      @factory = nil
      @composite = nil
      @composite_tree_node = nil
      @label = nil
      @char_vocabulary = nil
      @line_column_to_lookahead_dfamap = HashMap.new
      @tool = nil
      @rule_refs = HashSet.new
      @scoped_rule_refs = HashSet.new
      @token_idrefs = HashSet.new
      @decision_count = 0
      @left_recursive_rules = nil
      @external_analysis_abort = false
      @name_to_synpred_astmap = nil
      @at_least_one_rule_memoizes = false
      @implicit_lexer = false
      @name_to_rule_map = LinkedHashMap.new
      @overridden_rules = HashSet.new
      @delegated_rule_references = HashSet.new
      @lexer_rule_names_in_combined = ArrayList.new
      @scopes = HashMap.new
      @grammar_tree = nil
      @index_to_decision = Vector.new(INITIAL_DECISION_LIST_SIZE)
      @generator = nil
      @name_space_checker = NameSpaceChecker.new(self)
      @ll1analyzer = LL1Analyzer.new(self)
      @lexer_grammar_st = StringTemplate.new("lexer grammar <name>;\n" + "<if(options)>" + "options {\n" + "  <options:{<it.name>=<it.value>;<\\n>}>\n" + "}<\\n>\n" + "<endif>\n" + "<if(imports)>import <imports; separator=\", \">;<endif>\n" + "<actionNames,actions:{n,a|@<n> {<a>}\n}>\n" + "<literals:{<it.ruleName> : <it.literal> ;\n}>\n" + "<rules>", AngleBracketTemplateLexer)
      @file_name = nil
      @dfacreation_wall_clock_time_in_ms = 0
      @number_of_semantic_predicates = 0
      @number_of_manual_lookahead_options = 0
      @set_of_nondeterministic_decision_numbers = HashSet.new
      @set_of_nondeterministic_decision_numbers_resolved_with_predicates = HashSet.new
      @set_of_dfawhose_analysis_timed_out = HashSet.new
      @blocks_with_syn_preds = HashSet.new
      @decisions_whose_dfas_uses_syn_preds = HashSet.new
      @syn_pred_names_used_in_dfa = HashSet.new
      @blocks_with_sem_preds = HashSet.new
      @decisions_whose_dfas_uses_sem_preds = HashSet.new
      @all_decision_dfacreated = false
      @built_from_string = false
      @sanity = GrammarSanity.new(self)
      @built_from_string = true
      @composite = CompositeGrammar.new(self)
    end
    
    typesig { [String] }
    # Used for testing; only useful on noncomposite grammars.
    def initialize(grammar_string)
      initialize__grammar(nil, grammar_string)
    end
    
    typesig { [Tool, String] }
    # Used for testing and Interp/RandomPhrase.  Only useful on
    # noncomposite grammars.
    def initialize(tool, grammar_string)
      initialize__grammar()
      set_tool(tool)
      set_file_name("<string>")
      r = StringReader.new(grammar_string)
      parse_and_build_ast(r)
      @composite.assign_token_types
      define_grammar_symbols
      check_name_space_and_actions
    end
    
    typesig { [String] }
    def set_file_name(file_name)
      @file_name = file_name
    end
    
    typesig { [] }
    def get_file_name
      return @file_name
    end
    
    typesig { [String] }
    def set_name(name)
      if ((name).nil?)
        return
      end
      # don't error check autogenerated files (those with '__' in them)
      sane_file = @file_name.replace(Character.new(?\\.ord), Character.new(?/.ord))
      last_slash = sane_file.last_index_of(Character.new(?/.ord))
      only_file_name = sane_file.substring(last_slash + 1, @file_name.length)
      if (!@built_from_string)
        last_dot = only_file_name.last_index_of(Character.new(?..ord))
        only_file_name_no_suffix = nil
        if (last_dot < 0)
          ErrorManager.error(ErrorManager::MSG_FILENAME_EXTENSION_ERROR, @file_name)
          only_file_name_no_suffix = only_file_name + GRAMMAR_FILE_EXTENSION
        else
          only_file_name_no_suffix = RJava.cast_to_string(only_file_name.substring(0, last_dot))
        end
        if (!(name == only_file_name_no_suffix))
          ErrorManager.error(ErrorManager::MSG_FILE_AND_GRAMMAR_NAME_DIFFER, name, @file_name)
        end
      end
      @name = name
    end
    
    typesig { [String] }
    def set_grammar_content(grammar_string)
      r = StringReader.new(grammar_string)
      parse_and_build_ast(r)
      @composite.assign_token_types
      @composite.define_grammar_symbols
    end
    
    typesig { [] }
    def parse_and_build_ast
      fr = nil
      br = nil
      begin
        fr = FileReader.new(@file_name)
        br = BufferedReader.new(fr)
        parse_and_build_ast(br)
        br.close
        br = nil
      ensure
        if (!(br).nil?)
          br.close
        end
      end
    end
    
    typesig { [Reader] }
    def parse_and_build_ast(r)
      # BUILD AST FROM GRAMMAR
      lexer = ANTLRLexer.new(r)
      lexer.set_filename(self.get_file_name)
      # use the rewrite engine because we want to buffer up all tokens
      # in case they have a merged lexer/parser, send lexer rules to
      # new grammar.
      lexer.set_token_object_class("antlr.TokenWithIndex")
      @token_buffer = TokenStreamRewriteEngine.new(lexer)
      @token_buffer.discard(ANTLRParser::WS)
      @token_buffer.discard(ANTLRParser::ML_COMMENT)
      @token_buffer.discard(ANTLRParser::COMMENT)
      @token_buffer.discard(ANTLRParser::SL_COMMENT)
      parser = ANTLRParser.new(@token_buffer)
      parser.set_filename(self.get_file_name)
      begin
        parser.grammar(self)
      rescue TokenStreamException => tse
        ErrorManager.internal_error("unexpected stream error from parsing " + @file_name, tse)
      rescue RecognitionException => re
        ErrorManager.internal_error("unexpected parser recognition error from " + @file_name, re)
      end
      if (lexer.attr_has_astoperator && !build_ast)
        value = get_option("output")
        if ((value).nil?)
          ErrorManager.grammar_warning(ErrorManager::MSG_REWRITE_OR_OP_WITH_NO_OUTPUT_OPTION, self, nil)
          set_option("output", "AST", nil)
        else
          ErrorManager.grammar_error(ErrorManager::MSG_AST_OP_WITH_NON_AST_OUTPUT_OPTION, self, nil, value)
        end
      end
      @grammar_tree = parser.get_ast
      set_file_name(lexer.get_filename) # the lexer #src might change name
      if ((@grammar_tree).nil? || (@grammar_tree.find_first_type(ANTLRParser::RULE)).nil?)
        ErrorManager.error(ErrorManager::MSG_NO_RULES, get_file_name)
        return
      end
      # Get syn pred rules and add to existing tree
      synpred_rules = get_artificial_rules_for_syntactic_predicates(parser, @name_to_synpred_astmap)
      i = 0
      while i < synpred_rules.size
        r_ast = synpred_rules.get(i)
        @grammar_tree.add_child(r_ast)
        i += 1
      end
    end
    
    typesig { [] }
    def define_grammar_symbols
      if (Tool.attr_internal_option_print_grammar_tree)
        System.out.println(@grammar_tree.to_string_list)
      end
      # DEFINE RULES
      # System.out.println("### define "+name+" rules");
      define_items_walker = DefineGrammarItemsWalker.new
      define_items_walker.set_astnode_class("org.antlr.tool.GrammarAST")
      begin
        define_items_walker.grammar(@grammar_tree, self)
      rescue RecognitionException => re
        ErrorManager.error(ErrorManager::MSG_BAD_AST_STRUCTURE, re)
      end
    end
    
    typesig { [] }
    # ANALYZE ACTIONS, LOOKING FOR LABEL AND ATTR REFS, sanity check
    def check_name_space_and_actions
      examine_all_executable_actions
      check_all_rules_for_useless_labels
      @name_space_checker.check_conflicts
    end
    
    typesig { [Grammar] }
    # Many imports are illegal such as lexer into a tree grammar
    def valid_import(delegate)
      valid_delegators = self.attr_valid_delegations.get(delegate.attr_type)
      return !(valid_delegators).nil? && valid_delegators.contains(@type)
    end
    
    typesig { [] }
    # If the grammar is a combined grammar, return the text of the implicit
    # lexer grammar.
    def get_lexer_grammar
      if ((@lexer_grammar_st.get_attribute("literals")).nil? && (@lexer_grammar_st.get_attribute("rules")).nil?)
        # if no rules, return nothing
        return nil
      end
      @lexer_grammar_st.set_attribute("name", @name)
      # if there are any actions set for lexer, pass them in
      if (!(@actions.get("lexer")).nil?)
        @lexer_grammar_st.set_attribute("actionNames", (@actions.get("lexer")).key_set)
        @lexer_grammar_st.set_attribute("actions", (@actions.get("lexer")).values)
      end
      # make sure generated grammar has the same options
      if (!(@options).nil?)
        option_names = @options.key_set.iterator
        while (option_names.has_next)
          option_name = option_names.next_
          if (!DoNotCopyOptionsToLexer.contains(option_name))
            value = @options.get(option_name)
            @lexer_grammar_st.set_attribute("options.{name,value}", option_name, value)
          end
        end
      end
      return @lexer_grammar_st.to_s
    end
    
    typesig { [] }
    def get_implicitly_generated_lexer_file_name
      return @name + IGNORE_STRING_IN_GRAMMAR_FILE_NAME + LEXER_GRAMMAR_FILE_EXTENSION
    end
    
    typesig { [] }
    # Get the name of the generated recognizer; may or may not be same
    # as grammar name.
    # Recognizer is TParser and TLexer from T if combined, else
    # just use T regardless of grammar type.
    def get_recognizer_name
      suffix = ""
      grammars_from_root_to_me = @composite.get_delegators(self)
      # System.out.println("grammarsFromRootToMe="+grammarsFromRootToMe);
      qualified_name = @name
      if (!(grammars_from_root_to_me).nil?)
        buf = StringBuffer.new
        grammars_from_root_to_me.each do |g|
          buf.append(g.attr_name)
          buf.append(Character.new(?_.ord))
        end
        buf.append(@name)
        qualified_name = RJava.cast_to_string(buf.to_s)
      end
      if ((@type).equal?(Grammar::COMBINED) || ((@type).equal?(Grammar::LEXER) && @implicit_lexer))
        suffix = RJava.cast_to_string(Grammar.attr_grammar_type_to_file_name_suffix[@type])
      end
      return qualified_name + suffix
    end
    
    typesig { [GrammarAST, JavaList, JavaList, ::Java::Boolean] }
    # Parse a rule we add artificially that is a list of the other lexer
    # rules like this: "Tokens : ID | INT | SEMI ;"  nextToken() will invoke
    # this to set the current token.  Add char literals before
    # the rule references.
    # 
    # If in filter mode, we want every alt to backtrack and we need to
    # do k=1 to force the "first token def wins" rule.  Otherwise, the
    # longest-match rule comes into play with LL(*).
    # 
    # The ANTLRParser antlr.g file now invokes this when parsing a lexer
    # grammar, which I think is proper even though it peeks at the info
    # that later phases will (re)compute.  It gets a list of lexer rules
    # and builds a string representing the rule; then it creates a parser
    # and adds the resulting tree to the grammar's tree.
    def add_artificial_match_tokens_rule(grammar_ast, rule_names, delegate_names, filter_mode)
      match_token_rule_st = nil
      if (filter_mode)
        match_token_rule_st = StringTemplate.new(ARTIFICIAL_TOKENS_RULENAME + " options {k=1; backtrack=true;} : <rules; separator=\"|\">;", AngleBracketTemplateLexer)
      else
        match_token_rule_st = StringTemplate.new(ARTIFICIAL_TOKENS_RULENAME + " : <rules; separator=\"|\">;", AngleBracketTemplateLexer)
      end
      # Now add token rule references
      i = 0
      while i < rule_names.size
        rname = rule_names.get(i)
        match_token_rule_st.set_attribute("rules", rname)
        i += 1
      end
      i_ = 0
      while i_ < delegate_names.size
        dname = delegate_names.get(i_)
        match_token_rule_st.set_attribute("rules", dname + ".Tokens")
        i_ += 1
      end
      # System.out.println("tokens rule: "+matchTokenRuleST.toString());
      lexer = ANTLRLexer.new(StringReader.new(match_token_rule_st.to_s))
      lexer.set_token_object_class("antlr.TokenWithIndex")
      tokbuf = TokenStreamRewriteEngine.new(lexer)
      tokbuf.discard(ANTLRParser::WS)
      tokbuf.discard(ANTLRParser::ML_COMMENT)
      tokbuf.discard(ANTLRParser::COMMENT)
      tokbuf.discard(ANTLRParser::SL_COMMENT)
      parser = ANTLRParser.new(tokbuf)
      parser.attr_grammar = self
      parser.attr_gtype = ANTLRParser::LEXER_GRAMMAR
      parser.set_astnode_class("org.antlr.tool.GrammarAST")
      begin
        parser.rule
        if (Tool.attr_internal_option_print_grammar_tree)
          System.out.println("Tokens rule: " + RJava.cast_to_string(parser.get_ast.to_string_tree))
        end
        p = grammar_ast
        while (!(p.get_type).equal?(ANTLRParser::LEXER_GRAMMAR))
          p = p.get_next_sibling
        end
        p.add_child(parser.get_ast)
      rescue JavaException => e
        ErrorManager.error(ErrorManager::MSG_ERROR_CREATING_ARTIFICIAL_RULE, e)
      end
      return parser.get_ast
    end
    
    typesig { [ANTLRParser, LinkedHashMap] }
    # for any syntactic predicates, we need to define rules for them; they will get
    # defined automatically like any other rule. :)
    def get_artificial_rules_for_syntactic_predicates(parser, name_to_synpred_astmap)
      rules = ArrayList.new
      if ((name_to_synpred_astmap).nil?)
        return rules
      end
      pred_names = name_to_synpred_astmap.key_set
      is_lexer = (@grammar_tree.get_type).equal?(ANTLRParser::LEXER_GRAMMAR)
      it = pred_names.iterator
      while it.has_next
        synpred_name = it.next_
        fragment_ast = name_to_synpred_astmap.get(synpred_name)
        rule_ast = parser.create_simple_rule_ast(synpred_name, fragment_ast, is_lexer)
        rules.add(rule_ast)
      end
      return rules
    end
    
    typesig { [] }
    # Walk the list of options, altering this Grammar object according
    # to any I recognize.
    # protected void processOptions() {
    # Iterator optionNames = options.keySet().iterator();
    # while (optionNames.hasNext()) {
    # String optionName = (String) optionNames.next();
    # Object value = options.get(optionName);
    # if ( optionName.equals("tokenVocab") ) {
    # 
    # }
    # }
    # }
    # 
    # Define all the rule begin/end NFAStates to solve forward reference
    # issues.  Critical for composite grammars too.
    # This is normally called on all root/delegates manually and then
    # buildNFA() is called afterwards because the NFA construction needs
    # to see rule start/stop states from potentially every grammar. Has
    # to be have these created a priori.  Testing routines will often
    # just call buildNFA(), which forces a call to this method if not
    # done already. Works ONLY for single noncomposite grammars.
    def create_rule_start_and_stop_nfastates
      # System.out.println("### createRuleStartAndStopNFAStates "+getGrammarTypeString()+" grammar "+name+" NFAs");
      if (!(@nfa).nil?)
        return
      end
      @nfa = NFA.new(self)
      @factory = NFAFactory.new(@nfa)
      rules = get_rules
      itr = rules.iterator
      while itr.has_next
        r = itr.next_
        rule_name = r.attr_name
        rule_begin_state = @factory.new_state
        rule_begin_state.set_description("rule " + rule_name + " start")
        rule_begin_state.attr_enclosing_rule = r
        r.attr_start_state = rule_begin_state
        rule_end_state = @factory.new_state
        rule_end_state.set_description("rule " + rule_name + " end")
        rule_end_state.set_accept_state(true)
        rule_end_state.attr_enclosing_rule = r
        r.attr_stop_state = rule_end_state
      end
    end
    
    typesig { [] }
    def build_nfa
      if ((@nfa).nil?)
        create_rule_start_and_stop_nfastates
      end
      if (@nfa.attr_complete)
        # don't let it create more than once; has side-effects
        return
      end
      # System.out.println("### build "+getGrammarTypeString()+" grammar "+name+" NFAs");
      if ((get_rules.size).equal?(0))
        return
      end
      nfa_builder = TreeToNFAConverter.new(self, @nfa, @factory)
      begin
        nfa_builder.grammar(@grammar_tree)
      rescue RecognitionException => re
        ErrorManager.error(ErrorManager::MSG_BAD_AST_STRUCTURE, @name, re)
      end
      @nfa.attr_complete = true
    end
    
    typesig { [] }
    # For each decision in this grammar, compute a single DFA using the
    # NFA states associated with the decision.  The DFA construction
    # determines whether or not the alternatives in the decision are
    # separable using a regular lookahead language.
    # 
    # Store the lookahead DFAs in the AST created from the user's grammar
    # so the code generator or whoever can easily access it.
    # 
    # This is a separate method because you might want to create a
    # Grammar without doing the expensive analysis.
    def create_lookahead_dfas
      create_lookahead_dfas(true)
    end
    
    typesig { [::Java::Boolean] }
    def create_lookahead_dfas(wack_temp_structures)
      if ((@nfa).nil?)
        build_nfa
      end
      # CHECK FOR LEFT RECURSION; Make sure we can actually do analysis
      check_all_rules_for_left_recursion
      # // was there a severe problem while sniffing the grammar?
      # if ( ErrorManager.doNotAttemptAnalysis() ) {
      # return;
      # }
      start = System.current_time_millis
      # System.out.println("### create DFAs");
      num_decisions = get_number_of_decisions
      if (NFAToDFAConverter::SINGLE_THREADED_NFA_CONVERSION)
        decision = 1
        while decision <= num_decisions
          decision_start_state = get_decision_nfastart_state(decision)
          if (@left_recursive_rules.contains(decision_start_state.attr_enclosing_rule))
            # don't bother to process decisions within left recursive rules.
            if (@composite.attr_watch_nfaconversion)
              System.out.println("ignoring decision " + RJava.cast_to_string(decision) + " within left-recursive rule " + RJava.cast_to_string(decision_start_state.attr_enclosing_rule.attr_name))
            end
            decision += 1
            next
          end
          if (!@external_analysis_abort && decision_start_state.get_number_of_transitions > 1)
            r = decision_start_state.attr_enclosing_rule
            if (r.attr_is_syn_pred && !@syn_pred_names_used_in_dfa.contains(r.attr_name))
              decision += 1
              next
            end
            dfa = nil
            # if k=* or k=1, try LL(1)
            if ((get_user_max_lookahead(decision)).equal?(0) || (get_user_max_lookahead(decision)).equal?(1))
              dfa = create_ll_1_lookahead_dfa(decision)
            end
            if ((dfa).nil?)
              if (@composite.attr_watch_nfaconversion)
                System.out.println("decision " + RJava.cast_to_string(decision) + " not suitable for LL(1)-optimized DFA analysis")
              end
              dfa = create_lookahead_dfa(decision, wack_temp_structures)
            end
            if ((dfa.attr_start_state).nil?)
              # something went wrong; wipe out DFA
              set_lookahead_dfa(decision, nil)
            end
            if (Tool.attr_internal_option_print_dfa)
              System.out.println("DFA d=" + RJava.cast_to_string(decision))
              serializer = FASerializer.new(@nfa.attr_grammar)
              result = serializer.serialize(dfa.attr_start_state)
              System.out.println(result)
            end
          end
          decision += 1
        end
      else
        ErrorManager.info("two-threaded DFA conversion")
        # create a barrier expecting n DFA and this main creation thread
        barrier = Barrier.new(3)
        # assume 2 CPU for now
        midpoint = num_decisions / 2
        t1 = NFAConversionThread.new(self, barrier, 1, midpoint)
        JavaThread.new(t1).start
        if ((midpoint).equal?((num_decisions / 2)))
          midpoint += 1
        end
        t2 = NFAConversionThread.new(self, barrier, midpoint, num_decisions)
        JavaThread.new(t2).start
        # wait for these two threads to finish
        begin
          barrier.wait_for_release
        rescue InterruptedException => e
          ErrorManager.internal_error("what the hell? DFA interruptus", e)
        end
      end
      stop = System.current_time_millis
      @dfacreation_wall_clock_time_in_ms = stop - start
      # indicate that we've finished building DFA (even if #decisions==0)
      @all_decision_dfacreated = true
    end
    
    typesig { [::Java::Int] }
    def create_ll_1_lookahead_dfa(decision)
      d = get_decision(decision)
      enclosing_rule = d.attr_start_state.attr_enclosing_rule.attr_name
      r = d.attr_start_state.attr_enclosing_rule
      decision_start_state = get_decision_nfastart_state(decision)
      if (@composite.attr_watch_nfaconversion)
        System.out.println("--------------------\nattempting LL(1) DFA (d=" + RJava.cast_to_string(decision_start_state.get_decision_number) + ") for " + RJava.cast_to_string(decision_start_state.get_description))
      end
      if (r.attr_is_syn_pred && !@syn_pred_names_used_in_dfa.contains(enclosing_rule))
        return nil
      end
      # compute lookahead for each alt
      num_alts = get_number_of_alts_for_decision_nfa(decision_start_state)
      alt_look = Array.typed(LookaheadSet).new(num_alts + 1) { nil }
      alt = 1
      while alt <= num_alts
        walk_alt = decision_start_state.translate_display_alt_to_walk_alt(alt)
        alt_left_edge = get_nfastate_for_alt_of_decision(decision_start_state, walk_alt)
        alt_start_state = alt_left_edge.attr_transition[0].attr_target
        # System.out.println("alt "+alt+" start state = "+altStartState.stateNumber);
        alt_look[alt] = @ll1analyzer._look(alt_start_state)
        alt += 1
      end
      # compare alt i with alt j for disjointness
      decision_is_ll_1 = true
      catch(:break_outer) do
        i = 1
        while i <= num_alts
          j = i + 1
          while j <= num_alts
            # System.out.println("compare "+i+", "+j+": "+
            # altLook[i].toString(this)+" with "+
            # altLook[j].toString(this));
            collision = alt_look[i].intersection(alt_look[j])
            if (!collision.is_nil)
              # System.out.println("collision (non-LL(1)): "+collision.toString(this));
              decision_is_ll_1 = false
              throw :break_outer, :thrown
            end
            j += 1
          end
          i += 1
        end
      end
      found_confounding_predicate = @ll1analyzer.detect_confounding_predicates(decision_start_state)
      if (decision_is_ll_1 && !found_confounding_predicate)
        # build an LL(1) optimized DFA with edge for each altLook[i]
        if (NFAToDFAConverter.attr_debug)
          System.out.println("decision " + RJava.cast_to_string(decision) + " is simple LL(1)")
        end
        lookahead_dfa = LL1DFA.new(decision, decision_start_state, alt_look)
        set_lookahead_dfa(decision, lookahead_dfa)
        update_line_column_to_lookahead_dfamap(lookahead_dfa)
        return lookahead_dfa
      end
      # not LL(1) but perhaps we can solve with simplified predicate search
      # even if k=1 set manually, only resolve here if we have preds; i.e.,
      # don't resolve etc...
      # 
      # SemanticContext visiblePredicates =
      # ll1Analyzer.getPredicates(decisionStartState);
      # boolean foundConfoundingPredicate =
      # ll1Analyzer.detectConfoundingPredicates(decisionStartState);
      # 
      # exit if not forced k=1 or we found a predicate situation we
      # can't handle: predicates in rules invoked from this decision.
      # not manually set to k=1
      if (!(get_user_max_lookahead(decision)).equal?(1) || !get_auto_backtrack_mode(decision) || found_confounding_predicate)
        # System.out.println("trying LL(*)");
        return nil
      end
      edges = ArrayList.new
      i_ = 1
      while i_ < alt_look.attr_length
        s = alt_look[i_]
        edges.add(s.attr_token_type_set)
        i_ += 1
      end
      disjoint = make_edge_sets_disjoint(edges)
      # System.out.println("disjoint="+disjoint);
      edge_map = MultiMap.new
      i__ = 0
      while i__ < disjoint.size
        ds = disjoint.get(i__)
        alt_ = 1
        while alt_ < alt_look.attr_length
          look = alt_look[alt_]
          if (!ds.and_(look.attr_token_type_set).is_nil)
            edge_map.map(ds, alt_)
          end
          alt_ += 1
        end
        i__ += 1
      end
      # System.out.println("edge map: "+edgeMap);
      # TODO: how do we know we covered stuff?
      # build an LL(1) optimized DFA with edge for each altLook[i]
      lookahead_dfa = LL1DFA.new(decision, decision_start_state, edge_map)
      set_lookahead_dfa(decision, lookahead_dfa)
      # create map from line:col to decision DFA (for ANTLRWorks)
      update_line_column_to_lookahead_dfamap(lookahead_dfa)
      return lookahead_dfa
    end
    
    typesig { [DFA] }
    def update_line_column_to_lookahead_dfamap(lookahead_dfa)
      decision_ast = @nfa.attr_grammar.get_decision_block_ast(lookahead_dfa.attr_decision_number)
      line = decision_ast.get_line
      col = decision_ast.get_column
      @line_column_to_lookahead_dfamap.put(StringBuffer.new.append(RJava.cast_to_string(line) + ":").append(col).to_s, lookahead_dfa)
    end
    
    typesig { [JavaList] }
    def make_edge_sets_disjoint(edges)
      disjoint_sets = OrderedHashSet.new
      # walk each incoming edge label/set and add to disjoint set
      num_edges = edges.size
      e = 0
      while e < num_edges
        t = edges.get(e)
        if (disjoint_sets.contains(t))
          # exact set present
          e += 1
          next
        end
        # compare t with set i for disjointness
        remainder = t # remainder starts out as whole set to add
        num_disjoint_elements = disjoint_sets.size
        i = 0
        while i < num_disjoint_elements
          s_i = disjoint_sets.get(i)
          if (t.and_(s_i).is_nil)
            # nothing in common
            i += 1
            next
          end
          # System.out.println(label+" collides with "+rl);
          # For any (s_i, t) with s_i&t!=nil replace with (s_i-t, s_i&t)
          # (ignoring s_i-t if nil; don't put in list)
          # Replace existing s_i with intersection since we
          # know that will always be a non nil character class
          intersection = s_i.and_(t)
          disjoint_sets.set(i, intersection)
          # Compute s_i-t to see what is in current set and not in incoming
          existing_minus_new_elements = s_i.subtract(t)
          # System.out.println(s_i+"-"+t+"="+existingMinusNewElements);
          if (!existing_minus_new_elements.is_nil)
            # found a new character class, add to the end (doesn't affect
            # outer loop duration due to n computation a priori.
            disjoint_sets.add(existing_minus_new_elements)
          end
          # anything left to add to the reachableLabels?
          remainder = t.subtract(s_i)
          if (remainder.is_nil)
            break # nothing left to add to set.  done!
          end
          t = remainder
          i += 1
        end
        if (!remainder.is_nil)
          disjoint_sets.add(remainder)
        end
        e += 1
      end
      return disjoint_sets.elements
    end
    
    typesig { [::Java::Int, ::Java::Boolean] }
    def create_lookahead_dfa(decision, wack_temp_structures)
      d = get_decision(decision)
      enclosing_rule = d.attr_start_state.attr_enclosing_rule.attr_name
      r = d.attr_start_state.attr_enclosing_rule
      # System.out.println("createLookaheadDFA(): "+enclosingRule+" dec "+decision+"; synprednames prev used "+synPredNamesUsedInDFA);
      decision_start_state = get_decision_nfastart_state(decision)
      start_dfa = 0
      stop_dfa = 0
      if (@composite.attr_watch_nfaconversion)
        System.out.println("--------------------\nbuilding lookahead DFA (d=" + RJava.cast_to_string(decision_start_state.get_decision_number) + ") for " + RJava.cast_to_string(decision_start_state.get_description))
        start_dfa = System.current_time_millis
      end
      lookahead_dfa = DFA.new(decision, decision_start_state)
      # Retry to create a simpler DFA if analysis failed (non-LL(*),
      # recursion overflow, or time out).
      failed = lookahead_dfa.analysis_timed_out || lookahead_dfa.attr_probe.is_non_llstar_decision || lookahead_dfa.attr_probe.analysis_overflowed
      if (failed && lookahead_dfa.ok_to_retry_dfawith_k1)
        # set k=1 option and try again.
        # First, clean up tracking stuff
        @decisions_whose_dfas_uses_syn_preds.remove(lookahead_dfa)
        # TODO: clean up synPredNamesUsedInDFA also (harder)
        d.attr_block_ast.set_block_option(self, "k", Utils.integer(1))
        if (@composite.attr_watch_nfaconversion)
          System.out.print("trying decision " + RJava.cast_to_string(decision) + " again with k=1; reason: " + RJava.cast_to_string(lookahead_dfa.get_reason_for_failure))
        end
        lookahead_dfa = nil # make sure other memory is "free" before redoing
        lookahead_dfa = DFA.new(decision, decision_start_state)
      end
      if (lookahead_dfa.analysis_timed_out)
        # did analysis bug out?
        ErrorManager.internal_error("could not even do k=1 for decision " + RJava.cast_to_string(decision) + "; reason: " + RJava.cast_to_string(lookahead_dfa.get_reason_for_failure))
      end
      set_lookahead_dfa(decision, lookahead_dfa)
      if (wack_temp_structures)
        lookahead_dfa.get_unique_states.values.each do |s|
          s.reset
        end
      end
      # create map from line:col to decision DFA (for ANTLRWorks)
      update_line_column_to_lookahead_dfamap(lookahead_dfa)
      if (@composite.attr_watch_nfaconversion)
        stop_dfa = System.current_time_millis
        System.out.println("cost: " + RJava.cast_to_string(lookahead_dfa.get_number_of_states) + " states, " + RJava.cast_to_string(RJava.cast_to_int((stop_dfa - start_dfa))) + " ms")
      end
      # System.out.println("after create DFA; synPredNamesUsedInDFA="+synPredNamesUsedInDFA);
      return lookahead_dfa
    end
    
    typesig { [] }
    # Terminate DFA creation (grammar analysis).
    def externally_abort_nfato_dfaconversion
      @external_analysis_abort = true
    end
    
    typesig { [] }
    def _nfato_dfaconversion_externally_aborted
      return @external_analysis_abort
    end
    
    typesig { [] }
    # Return a new unique integer in the token type space
    def get_new_token_type
      @composite.attr_max_token_type += 1
      return @composite.attr_max_token_type
    end
    
    typesig { [String, ::Java::Int] }
    # Define a token at a particular token type value.  Blast an
    # old value with a new one.  This is called normal grammar processsing
    # and during import vocab operations to set tokens with specific values.
    def define_token(text, token_type)
      # System.out.println("defineToken("+text+", "+tokenType+")");
      if (!(@composite.attr_token_idto_type_map.get(text)).nil?)
        # already defined?  Must be predefined one like EOF;
        # do nothing
        return
      end
      # the index in the typeToTokenList table is actually shifted to
      # hold faux labels as you cannot have negative indices.
      if ((text.char_at(0)).equal?(Character.new(?\'.ord)))
        @composite.attr_string_literal_to_type_map.put(text, Utils.integer(token_type))
        # track in reverse index too
        if (token_type >= @composite.attr_type_to_string_literal_list.size)
          @composite.attr_type_to_string_literal_list.set_size(token_type + 1)
        end
        @composite.attr_type_to_string_literal_list.set(token_type, text)
      else
        # must be a label like ID
        @composite.attr_token_idto_type_map.put(text, Utils.integer(token_type))
      end
      index = Label::NUM_FAUX_LABELS + token_type - 1
      # System.out.println("defining "+name+" token "+text+" at type="+tokenType+", index="+index);
      @composite.attr_max_token_type = Math.max(@composite.attr_max_token_type, token_type)
      if (index >= @composite.attr_type_to_token_list.size)
        @composite.attr_type_to_token_list.set_size(index + 1)
      end
      prev_token = @composite.attr_type_to_token_list.get(index)
      if ((prev_token).nil? || (prev_token.char_at(0)).equal?(Character.new(?\'.ord)))
        # only record if nothing there before or if thing before was a literal
        @composite.attr_type_to_token_list.set(index, text)
      end
    end
    
    typesig { [Antlr::Token, String, Map, GrammarAST, GrammarAST, ::Java::Int] }
    # Define a new rule.  A new rule index is created by incrementing
    # ruleIndex.
    def define_rule(rule_token, modifier, options, tree, arg_action_ast, num_alts)
      rule_name = rule_token.get_text
      if (!(get_locally_defined_rule(rule_name)).nil?)
        ErrorManager.grammar_error(ErrorManager::MSG_RULE_REDEFINITION, self, rule_token, rule_name)
        return
      end
      if (((@type).equal?(Grammar::PARSER) || (@type).equal?(Grammar::TREE_PARSER)) && Character.is_upper_case(rule_name.char_at(0)))
        ErrorManager.grammar_error(ErrorManager::MSG_LEXER_RULES_NOT_ALLOWED, self, rule_token, rule_name)
        return
      end
      r = Rule.new(self, rule_name, @composite.attr_rule_index, num_alts)
      # System.out.println("defineRule("+ruleName+",modifier="+modifier+
      # "): index="+r.index+", nalts="+numAlts);
      r.attr_modifier = modifier
      @name_to_rule_map.put(rule_name, r)
      set_rule_ast(rule_name, tree)
      r.set_options(options, rule_token)
      r.attr_arg_action_ast = arg_action_ast
      @composite.attr_rule_index_to_rule_list.set_size(@composite.attr_rule_index + 1)
      @composite.attr_rule_index_to_rule_list.set(@composite.attr_rule_index, r)
      @composite.attr_rule_index += 1
      if (rule_name.starts_with(SYNPRED_RULE_PREFIX))
        r.attr_is_syn_pred = true
      end
    end
    
    typesig { [GrammarAST, String] }
    # Define a new predicate and get back its name for use in building
    # a semantic predicate reference to the syn pred.
    def define_syntactic_predicate(block_ast, current_rule_name)
      if ((@name_to_synpred_astmap).nil?)
        @name_to_synpred_astmap = LinkedHashMap.new
      end
      pred_name = SYNPRED_RULE_PREFIX + RJava.cast_to_string((@name_to_synpred_astmap.size + 1)) + "_" + @name
      block_ast.set_tree_enclosing_rule_name_deeply(pred_name)
      @name_to_synpred_astmap.put(pred_name, block_ast)
      return pred_name
    end
    
    typesig { [] }
    def get_syntactic_predicates
      return @name_to_synpred_astmap
    end
    
    typesig { [String] }
    def get_syntactic_predicate(name)
      if ((@name_to_synpred_astmap).nil?)
        return nil
      end
      return @name_to_synpred_astmap.get(name)
    end
    
    typesig { [DFA, SemanticContext] }
    def syn_pred_used_in_dfa(dfa, sem_ctx)
      @decisions_whose_dfas_uses_syn_preds.add(dfa)
      sem_ctx.track_use_of_syntactic_predicates(self) # walk ctx looking for preds
    end
    
    typesig { [GrammarAST, String, GrammarAST, GrammarAST] }
    # public Set<Rule> getRuleNamesVisitedDuringLOOK() {
    # return rulesSensitiveToOtherRules;
    # }
    # 
    # Given @scope::name {action} define it for this grammar.  Later,
    # the code generator will ask for the actions table.  For composite
    # grammars, make sure header action propogates down to all delegates.
    def define_named_action(ampersand_ast, scope, name_ast, action_ast)
      if ((scope).nil?)
        scope = RJava.cast_to_string(get_default_action_scope(@type))
      end
      # System.out.println("@"+scope+"::"+nameAST.getText()+"{"+actionAST.getText()+"}");
      action_name = name_ast.get_text
      scope_actions = @actions.get(scope)
      if ((scope_actions).nil?)
        scope_actions = HashMap.new
        @actions.put(scope, scope_actions)
      end
      a = scope_actions.get(action_name)
      if (!(a).nil?)
        ErrorManager.grammar_error(ErrorManager::MSG_ACTION_REDEFINITION, self, name_ast.get_token, name_ast.get_text)
      else
        scope_actions.put(action_name, action_ast)
      end
      # propogate header (regardless of scope (lexer, parser, ...) ?
      if ((self).equal?(@composite.get_root_grammar) && (action_name == "header"))
        allgrammars = @composite.get_root_grammar.get_delegates
        allgrammars.each do |g|
          g.define_named_action(ampersand_ast, scope, name_ast, action_ast)
        end
      end
    end
    
    typesig { [] }
    def get_actions
      return @actions
    end
    
    typesig { [::Java::Int] }
    # Given a grammar type, what should be the default action scope?
    # If I say @members in a COMBINED grammar, for example, the
    # default scope should be "parser".
    def get_default_action_scope(grammar_type)
      case (grammar_type)
      when Grammar::LEXER
        return "lexer"
      when Grammar::PARSER, Grammar::COMBINED
        return "parser"
      when Grammar::TREE_PARSER
        return "treeparser"
      end
      return nil
    end
    
    typesig { [Antlr::Token, GrammarAST] }
    def define_lexer_rule_found_in_parser(rule_token, rule_ast)
      # System.out.println("rule tree is:\n"+ruleAST.toStringTree());
      # 
      # String ruleText = tokenBuffer.toOriginalString(ruleAST.ruleStartTokenIndex,
      # ruleAST.ruleStopTokenIndex);
      # 
      # first, create the text of the rule
      buf = StringBuffer.new
      buf.append("// $ANTLR src \"")
      buf.append(get_file_name)
      buf.append("\" ")
      buf.append(rule_ast.get_line)
      buf.append("\n")
      i = rule_ast.attr_rule_start_token_index
      while i <= rule_ast.attr_rule_stop_token_index && i < @token_buffer.size
        t = @token_buffer.get_token(i)
        # undo the text deletions done by the lexer (ugh)
        if ((t.get_type).equal?(ANTLRParser::BLOCK))
          buf.append("(")
        else
          if ((t.get_type).equal?(ANTLRParser::ACTION))
            buf.append("{")
            buf.append(t.get_text)
            buf.append("}")
          else
            if ((t.get_type).equal?(ANTLRParser::SEMPRED) || (t.get_type).equal?(ANTLRParser::SYN_SEMPRED) || (t.get_type).equal?(ANTLRParser::GATED_SEMPRED) || (t.get_type).equal?(ANTLRParser::BACKTRACK_SEMPRED))
              buf.append("{")
              buf.append(t.get_text)
              buf.append("}?")
            else
              if ((t.get_type).equal?(ANTLRParser::ARG_ACTION))
                buf.append("[")
                buf.append(t.get_text)
                buf.append("]")
              else
                buf.append(t.get_text)
              end
            end
          end
        end
        i += 1
      end
      rule_text = buf.to_s
      # System.out.println("[["+ruleText+"]]");
      # now put the rule into the lexer grammar template
      if (get_grammar_is_root)
        # don't build lexers for delegates
        @lexer_grammar_st.set_attribute("rules", rule_text)
      end
      # track this lexer rule's name
      @composite.attr_lexer_rules.add(rule_token.get_text)
    end
    
    typesig { [String, String, ::Java::Int] }
    # If someone does PLUS='+' in the parser, must make sure we get
    # "PLUS : '+' ;" in lexer not "T73 : '+';"
    def define_lexer_rule_for_aliased_string_literal(token_id, literal, token_type)
      if (get_grammar_is_root)
        # don't build lexers for delegates
        # System.out.println("defineLexerRuleForAliasedStringLiteral: "+literal+" "+tokenType);
        @lexer_grammar_st.set_attribute("literals.{ruleName,type,literal}", token_id, Utils.integer(token_type), literal)
      end
      # track this lexer rule's name
      @composite.attr_lexer_rules.add(token_id)
    end
    
    typesig { [String, ::Java::Int] }
    def define_lexer_rule_for_string_literal(literal, token_type)
      # System.out.println("defineLexerRuleForStringLiteral: "+literal+" "+tokenType);
      # compute new token name like T237 and define it as having tokenType
      token_id = compute_token_name_from_literal(token_type, literal)
      define_token(token_id, token_type)
      # tell implicit lexer to define a rule to match the literal
      if (get_grammar_is_root)
        # don't build lexers for delegates
        @lexer_grammar_st.set_attribute("literals.{ruleName,type,literal}", token_id, Utils.integer(token_type), literal)
      end
    end
    
    typesig { [String] }
    def get_locally_defined_rule(rule_name)
      r = @name_to_rule_map.get(rule_name)
      return r
    end
    
    typesig { [String] }
    def get_rule(rule_name)
      r = @composite.get_rule(rule_name)
      # if ( r!=null && r.grammar != this ) {
      # System.out.println(name+".getRule("+ruleName+")="+r);
      # }
      return r
    end
    
    typesig { [String, String] }
    def get_rule(scope_name, rule_name)
      if (!(scope_name).nil?)
        # scope override
        scope = @composite.get_grammar(scope_name)
        if ((scope).nil?)
          return nil
        end
        return scope.get_locally_defined_rule(rule_name)
      end
      return get_rule(rule_name)
    end
    
    typesig { [String, String] }
    def get_rule_index(scope_name, rule_name)
      r = get_rule(scope_name, rule_name)
      if (!(r).nil?)
        return r.attr_index
      end
      return INVALID_RULE_INDEX
    end
    
    typesig { [String] }
    def get_rule_index(rule_name)
      return get_rule_index(nil, rule_name)
    end
    
    typesig { [::Java::Int] }
    def get_rule_name(rule_index)
      r = @composite.attr_rule_index_to_rule_list.get(rule_index)
      if (!(r).nil?)
        return r.attr_name
      end
      return nil
    end
    
    typesig { [String] }
    # Should codegen.g gen rule for ruleName?
    # If synpred, only gen if used in a DFA.
    # If regular rule, only gen if not overridden in delegator
    # Always gen Tokens rule though.
    def generate_method_for_rule(rule_name)
      if ((rule_name == ARTIFICIAL_TOKENS_RULENAME))
        # always generate Tokens rule to satisfy lexer interface
        # but it may have no alternatives.
        return true
      end
      if (@overridden_rules.contains(rule_name))
        # don't generate any overridden rules
        return false
      end
      # generate if non-synpred or synpred used in a DFA
      r = get_locally_defined_rule(rule_name)
      return !r.attr_is_syn_pred || (r.attr_is_syn_pred && @syn_pred_names_used_in_dfa.contains(rule_name))
    end
    
    typesig { [String, Token] }
    def define_global_scope(name, scope_action)
      scope = AttributeScope.new(self, name, scope_action)
      @scopes.put(name, scope)
      return scope
    end
    
    typesig { [String, Token] }
    def create_return_scope(rule_name, ret_action)
      scope = AttributeScope.new(self, rule_name, ret_action)
      scope.attr_is_return_scope = true
      return scope
    end
    
    typesig { [String, Token] }
    def create_rule_scope(rule_name, scope_action)
      scope = AttributeScope.new(self, rule_name, scope_action)
      scope.attr_is_dynamic_rule_scope = true
      return scope
    end
    
    typesig { [String, Token] }
    def create_parameter_scope(rule_name, arg_action)
      scope = AttributeScope.new(self, rule_name, arg_action)
      scope.attr_is_parameter_scope = true
      return scope
    end
    
    typesig { [String] }
    # Get a global scope
    def get_global_scope(name)
      return @scopes.get(name)
    end
    
    typesig { [] }
    def get_global_scopes
      return @scopes
    end
    
    typesig { [Rule, Antlr::Token, GrammarAST, ::Java::Int] }
    # Define a label defined in a rule r; check the validity then ask the
    # Rule object to actually define it.
    def define_label(r, label, element, type)
      err = @name_space_checker.check_for_label_type_mismatch(r, label, type)
      if (err)
        return
      end
      r.define_label(label, element, type)
    end
    
    typesig { [String, Antlr::Token, GrammarAST] }
    def define_token_ref_label(rule_name, label, token_ref)
      r = get_locally_defined_rule(rule_name)
      if (!(r).nil?)
        if ((@type).equal?(LEXER) && ((token_ref.get_type).equal?(ANTLRParser::CHAR_LITERAL) || (token_ref.get_type).equal?(ANTLRParser::BLOCK) || (token_ref.get_type).equal?(ANTLRParser::NOT) || (token_ref.get_type).equal?(ANTLRParser::CHAR_RANGE) || (token_ref.get_type).equal?(ANTLRParser::WILDCARD)))
          define_label(r, label, token_ref, CHAR_LABEL)
        else
          define_label(r, label, token_ref, TOKEN_LABEL)
        end
      end
    end
    
    typesig { [String, Antlr::Token, GrammarAST] }
    def define_rule_ref_label(rule_name, label, rule_ref)
      r = get_locally_defined_rule(rule_name)
      if (!(r).nil?)
        define_label(r, label, rule_ref, RULE_LABEL)
      end
    end
    
    typesig { [String, Antlr::Token, GrammarAST] }
    def define_token_list_label(rule_name, label, element)
      r = get_locally_defined_rule(rule_name)
      if (!(r).nil?)
        define_label(r, label, element, TOKEN_LIST_LABEL)
      end
    end
    
    typesig { [String, Antlr::Token, GrammarAST] }
    def define_rule_list_label(rule_name, label, element)
      r = get_locally_defined_rule(rule_name)
      if (!(r).nil?)
        if (!r.get_has_multiple_return_values)
          ErrorManager.grammar_error(ErrorManager::MSG_LIST_LABEL_INVALID_UNLESS_RETVAL_STRUCT, self, label, label.get_text)
        end
        define_label(r, label, element, RULE_LIST_LABEL)
      end
    end
    
    typesig { [JavaSet, ::Java::Int] }
    # Given a set of all rewrite elements on right of ->, filter for
    # label types such as Grammar.TOKEN_LABEL, Grammar.TOKEN_LIST_LABEL, ...
    # Return a displayable token type name computed from the GrammarAST.
    def get_labels(rewrite_elements, label_type)
      labels = HashSet.new
      it = rewrite_elements.iterator
      while it.has_next
        el = it.next_
        if ((el.get_type).equal?(ANTLRParser::LABEL))
          label_name = el.get_text
          enclosing_rule = get_locally_defined_rule(el.attr_enclosing_rule_name)
          pair = enclosing_rule.get_label(label_name)
          # if valid label and type is what we're looking for
          # and not ref to old value val $rule, add to list
          if (!(pair).nil? && (pair.attr_type).equal?(label_type) && !(label_name == el.attr_enclosing_rule_name))
            labels.add(label_name)
          end
        end
      end
      return labels
    end
    
    typesig { [] }
    # Before generating code, we examine all actions that can have
    # $x.y and $y stuff in them because some code generation depends on
    # Rule.referencedPredefinedRuleAttributes.  I need to remove unused
    # rule labels for example.
    def examine_all_executable_actions
      rules = get_rules
      it = rules.iterator
      while it.has_next
        r = it.next_
        # walk all actions within the rule elements, args, and exceptions
        actions = r.get_inline_actions
        i = 0
        while i < actions.size
          action_ast = actions.get(i)
          sniffer = ActionAnalysisLexer.new(self, r.attr_name, action_ast)
          sniffer.analyze
          i += 1
        end
        # walk any named actions like @init, @after
        named_actions = r.get_actions.values
        it2 = named_actions.iterator
        while it2.has_next
          action_ast = it2.next_
          sniffer = ActionAnalysisLexer.new(self, r.attr_name, action_ast)
          sniffer.analyze
        end
      end
    end
    
    typesig { [] }
    # Remove all labels on rule refs whose target rules have no return value.
    # Do this for all rules in grammar.
    def check_all_rules_for_useless_labels
      if ((@type).equal?(LEXER))
        return
      end
      rules = @name_to_rule_map.key_set
      it = rules.iterator
      while it.has_next
        rule_name = it.next_
        r = get_rule(rule_name)
        remove_useless_labels(r.get_rule_labels)
        remove_useless_labels(r.get_rule_list_labels)
      end
    end
    
    typesig { [Map] }
    # A label on a rule is useless if the rule has no return value, no
    # tree or template output, and it is not referenced in an action.
    def remove_useless_labels(rule_to_element_label_pair_map)
      if ((rule_to_element_label_pair_map).nil?)
        return
      end
      labels = rule_to_element_label_pair_map.values
      kill = ArrayList.new
      labelit = labels.iterator
      while labelit.has_next
        pair = labelit.next_
        refd_rule = get_rule(pair.attr_element_ref.get_text)
        if (!(refd_rule).nil? && !refd_rule.get_has_return_value && !pair.attr_action_references_label)
          # System.out.println(pair.label.getText()+" is useless");
          kill.add(pair.attr_label.get_text)
        end
      end
      i = 0
      while i < kill.size
        label_to_kill = kill.get(i)
        # System.out.println("kill "+labelToKill);
        rule_to_element_label_pair_map.remove(label_to_kill)
        i += 1
      end
    end
    
    typesig { [String, GrammarAST, GrammarAST, ::Java::Int] }
    # Track a rule reference within an outermost alt of a rule.  Used
    # at the moment to decide if $ruleref refers to a unique rule ref in
    # the alt.  Rewrite rules force tracking of all rule AST results.
    # 
    # This data is also used to verify that all rules have been defined.
    def alt_references_rule(enclosing_rule_name, ref_scope_ast, ref_ast, outer_alt_num)
      # Do nothing for now; not sure need; track S.x as x
      # String scope = null;
      # Grammar scopeG = null;
      # if ( refScopeAST!=null ) {
      # if ( !scopedRuleRefs.contains(refScopeAST) ) {
      # scopedRuleRefs.add(refScopeAST);
      # }
      # scope = refScopeAST.getText();
      # }
      r = get_rule(enclosing_rule_name)
      if ((r).nil?)
        return # no error here; see NameSpaceChecker
      end
      r.track_rule_reference_in_alt(ref_ast, outer_alt_num)
      ref_token = ref_ast.get_token
      if (!@rule_refs.contains(ref_ast))
        @rule_refs.add(ref_ast)
      end
    end
    
    typesig { [String, GrammarAST, ::Java::Int] }
    # Track a token reference within an outermost alt of a rule.  Used
    # to decide if $tokenref refers to a unique token ref in
    # the alt. Does not track literals!
    # 
    # Rewrite rules force tracking of all tokens.
    def alt_references_token_id(rule_name, ref_ast, outer_alt_num)
      r = get_locally_defined_rule(rule_name)
      if ((r).nil?)
        return
      end
      r.track_token_reference_in_alt(ref_ast, outer_alt_num)
      if (!@token_idrefs.contains(ref_ast.get_token))
        @token_idrefs.add(ref_ast.get_token)
      end
    end
    
    typesig { [String] }
    # To yield smaller, more readable code, track which rules have their
    # predefined attributes accessed.  If the rule has no user-defined
    # return values, then don't generate the return value scope classes
    # etc...  Make the rule have void return value.  Don't track for lexer
    # rules.
    def reference_rule_label_predefined_attribute(rule_name)
      r = get_rule(rule_name)
      if (!(r).nil? && !(@type).equal?(LEXER))
        # indicate that an action ref'd an attr unless it's in a lexer
        # so that $ID.text refs don't force lexer rules to define
        # return values...Token objects are created by the caller instead.
        r.attr_referenced_predefined_rule_attributes = true
      end
    end
    
    typesig { [] }
    def check_all_rules_for_left_recursion
      return @sanity.check_all_rules_for_left_recursion
    end
    
    typesig { [] }
    # Return a list of left-recursive rules; no analysis can be done
    # successfully on these.  Useful to skip these rules then and also
    # for ANTLRWorks to highlight them.
    def get_left_recursive_rules
      if ((@nfa).nil?)
        build_nfa
      end
      if (!(@left_recursive_rules).nil?)
        return @left_recursive_rules
      end
      @sanity.check_all_rules_for_left_recursion
      return @left_recursive_rules
    end
    
    typesig { [GrammarAST, GrammarAST, GrammarAST, String] }
    def check_rule_reference(scope_ast, ref_ast, args_ast, current_rule_name)
      @sanity.check_rule_reference(scope_ast, ref_ast, args_ast, current_rule_name)
    end
    
    typesig { [GrammarAST] }
    # Rules like "a : ;" and "a : {...} ;" should not generate
    # try/catch blocks for RecognitionException.  To detect this
    # it's probably ok to just look for any reference to an atom
    # that can match some input.  W/o that, the rule is unlikey to have
    # any else.
    def is_empty_rule(block)
      a_token_ref_node = block.find_first_type(ANTLRParser::TOKEN_REF)
      a_string_literal_ref_node = block.find_first_type(ANTLRParser::STRING_LITERAL)
      a_char_literal_ref_node = block.find_first_type(ANTLRParser::CHAR_LITERAL)
      a_wildcard_ref_node = block.find_first_type(ANTLRParser::WILDCARD)
      a_rule_ref_node = block.find_first_type(ANTLRParser::RULE_REF)
      if ((a_token_ref_node).nil? && (a_string_literal_ref_node).nil? && (a_char_literal_ref_node).nil? && (a_wildcard_ref_node).nil? && (a_rule_ref_node).nil?)
        return true
      end
      return false
    end
    
    typesig { [::Java::Int] }
    def is_atom_token_type(ttype)
      return (ttype).equal?(ANTLRParser::WILDCARD) || (ttype).equal?(ANTLRParser::CHAR_LITERAL) || (ttype).equal?(ANTLRParser::CHAR_RANGE) || (ttype).equal?(ANTLRParser::STRING_LITERAL) || (ttype).equal?(ANTLRParser::NOT) || (!(@type).equal?(LEXER) && (ttype).equal?(ANTLRParser::TOKEN_REF))
    end
    
    typesig { [String] }
    def get_token_type(token_name)
      i = nil
      if ((token_name.char_at(0)).equal?(Character.new(?\'.ord)))
        i = @composite.attr_string_literal_to_type_map.get(token_name)
      else
        # must be a label like ID
        i = @composite.attr_token_idto_type_map.get(token_name)
      end
      i_ = (!(i).nil?) ? i.int_value : Label::INVALID
      # System.out.println("grammar type "+type+" "+tokenName+"->"+i);
      return i_
    end
    
    typesig { [] }
    # Get the list of tokens that are IDs like BLOCK and LPAREN
    def get_token_ids
      return @composite.attr_token_idto_type_map.key_set
    end
    
    typesig { [] }
    # Return an ordered integer list of token types that have no
    # corresponding token ID like INT or KEYWORD_BEGIN; for stuff
    # like 'begin'.
    def get_token_types_without_id
      types = ArrayList.new
      t = Label::MIN_TOKEN_TYPE
      while t <= get_max_token_type
        name = get_token_display_name(t)
        if ((name.char_at(0)).equal?(Character.new(?\'.ord)))
          types.add(Utils.integer(t))
        end
        t += 1
      end
      return types
    end
    
    typesig { [] }
    # Get a list of all token IDs and literals that have an associated
    # token type.
    def get_token_display_names
      names = HashSet.new
      t = Label::MIN_TOKEN_TYPE
      while t <= get_max_token_type
        names.add(get_token_display_name(t))
        t += 1
      end
      return names
    end
    
    class_module.module_eval {
      typesig { [String] }
      # Given a literal like (the 3 char sequence with single quotes) 'a',
      # return the int value of 'a'. Convert escape sequences here also.
      # ANTLR's antlr.g parser does not convert escape sequences.
      # 
      # 11/26/2005: I changed literals to always be '...' even for strings.
      # This routine still works though.
      def get_char_value_from_grammar_char_literal(literal)
        case (literal.length)
        # no escape char
        when 3
          # 'x'
          return literal.char_at(1)
        when 4
          # '\x'  (antlr lexer will catch invalid char)
          if (Character.is_digit(literal.char_at(2)))
            ErrorManager.error(ErrorManager::MSG_SYNTAX_ERROR, "invalid char literal: " + literal)
            return -1
          end
          esc_char = literal.char_at(2)
          char_val = self.attr_antlrliteral_escaped_char_value[esc_char]
          if ((char_val).equal?(0))
            # Unnecessary escapes like '\{' should just yield {
            return esc_char
          end
          return char_val
        when 8
          # '\u1234'
          unicode_chars = literal.substring(3, literal.length - 1)
          return JavaInteger.parse_int(unicode_chars, 16)
        else
          ErrorManager.error(ErrorManager::MSG_SYNTAX_ERROR, "invalid char literal: " + literal)
          return -1
        end
      end
      
      typesig { [String] }
      # ANTLR does not convert escape sequences during the parse phase because
      # it could not know how to print String/char literals back out when
      # printing grammars etc...  Someone in China might use the real unicode
      # char in a literal as it will display on their screen; when printing
      # back out, I could not know whether to display or use a unicode escape.
      # 
      # This routine converts a string literal with possible escape sequences
      # into a pure string of 16-bit char values.  Escapes and unicode \u0000
      # specs are converted to pure chars.  return in a buffer; people may
      # want to walk/manipulate further.
      # 
      # The NFA construction routine must know the actual char values.
      def get_unescaped_string_from_grammar_string_literal(literal)
        # System.out.println("escape: ["+literal+"]");
        buf = StringBuffer.new
        last = literal.length - 1 # skip quotes on outside
        i = 1
        while i < last
          c = literal.char_at(i)
          if ((c).equal?(Character.new(?\\.ord)))
            i += 1
            c = literal.char_at(i)
            if ((Character.to_upper_case(c)).equal?(Character.new(?U.ord)))
              # \u0000
              i += 1
              unicode_chars = literal.substring(i, i + 4)
              # parse the unicode 16 bit hex value
              val = JavaInteger.parse_int(unicode_chars, 16)
              i += 4 - 1 # loop will inc by 1; only jump 3 then
              buf.append(RJava.cast_to_char(val))
            else
              if (Character.is_digit(c))
                ErrorManager.error(ErrorManager::MSG_SYNTAX_ERROR, "invalid char literal: " + literal)
                buf.append("\\" + RJava.cast_to_string(RJava.cast_to_char(c)))
              else
                buf.append(RJava.cast_to_char(self.attr_antlrliteral_escaped_char_value[c])) # normal \x escape
              end
            end
          else
            buf.append(c) # simple char x
          end
          i += 1
        end
        # System.out.println("string: ["+buf.toString()+"]");
        return buf
      end
    }
    
    typesig { [Grammar] }
    # Pull your token definitions from an existing grammar in memory.
    # You must use Grammar() ctor then this method then setGrammarContent()
    # to make this work.  This was useful primarily for testing and
    # interpreting grammars until I added import grammar functionality.
    # When you import a grammar you implicitly import its vocabulary as well
    # and keep the same token type values.
    # 
    # Returns the max token type found.
    def import_token_vocabulary(import_from_gr)
      imported_token_ids = import_from_gr.get_token_ids
      it = imported_token_ids.iterator
      while it.has_next
        token_id = it.next_
        token_type = import_from_gr.get_token_type(token_id)
        @composite.attr_max_token_type = Math.max(@composite.attr_max_token_type, token_type)
        if (token_type >= Label::MIN_TOKEN_TYPE)
          # System.out.println("import token from grammar "+tokenID+"="+tokenType);
          define_token(token_id, token_type)
        end
      end
      return @composite.attr_max_token_type # return max found
    end
    
    typesig { [GrammarAST, String] }
    # Import the rules/tokens of a delegate grammar. All delegate grammars are
    # read during the ctor of first Grammar created.
    # 
    # Do not create NFA here because NFA construction needs to hook up with
    # overridden rules in delegation root grammar.
    def import_grammar(grammar_name_ast, label)
      grammar_name = grammar_name_ast.get_text
      # System.out.println("import "+gfile.getName());
      gname = grammar_name + GRAMMAR_FILE_EXTENSION
      br = nil
      begin
        full_name = @tool.get_library_file(gname)
        fr = FileReader.new(full_name)
        br = BufferedReader.new(fr)
        delegate_grammar = nil
        delegate_grammar = Grammar.new(@tool, gname, @composite)
        delegate_grammar.attr_label = label
        add_delegate_grammar(delegate_grammar)
        delegate_grammar.parse_and_build_ast(br)
        if (!valid_import(delegate_grammar))
          ErrorManager.grammar_error(ErrorManager::MSG_INVALID_IMPORT, self, grammar_name_ast.attr_token, self, delegate_grammar)
          return
        end
        if ((@type).equal?(COMBINED) && ((delegate_grammar.attr_name == @name + GrammarTypeToFileNameSuffix[LEXER]) || (delegate_grammar.attr_name == @name + GrammarTypeToFileNameSuffix[PARSER])))
          ErrorManager.grammar_error(ErrorManager::MSG_IMPORT_NAME_CLASH, self, grammar_name_ast.attr_token, self, delegate_grammar)
          return
        end
        if (!(delegate_grammar.attr_grammar_tree).nil?)
          # we have a valid grammar
          # deal with combined grammars
          if ((delegate_grammar.attr_type).equal?(LEXER) && (@type).equal?(COMBINED))
            # ooops, we wasted some effort; tell lexer to read it in
            # later
            @lexer_grammar_st.set_attribute("imports", grammar_name)
            # but, this parser grammar will need the vocab
            # so add to composite anyway so we suck in the tokens later
          end
        end
        # System.out.println("Got grammar:\n"+delegateGrammar);
      rescue IOException => ioe
        ErrorManager.error(ErrorManager::MSG_CANNOT_OPEN_FILE, gname, ioe)
      ensure
        if (!(br).nil?)
          begin
            br.close
          rescue IOException => ioe
            ErrorManager.error(ErrorManager::MSG_CANNOT_CLOSE_FILE, gname, ioe)
          end
        end
      end
    end
    
    typesig { [Grammar] }
    # add new delegate to composite tree
    def add_delegate_grammar(delegate_grammar)
      t = @composite.attr_delegate_grammar_tree_root.find_node(self)
      t.add_child(CompositeGrammarTree.new(delegate_grammar))
      # make sure new grammar shares this composite
      delegate_grammar.attr_composite = @composite
    end
    
    typesig { [GrammarAST, String] }
    # Load a vocab file <vocabName>.tokens and return max token type found.
    def import_token_vocabulary(token_vocab_option_ast, vocab_name)
      if (!get_grammar_is_root)
        ErrorManager.grammar_warning(ErrorManager::MSG_TOKEN_VOCAB_IN_DELEGATE, self, token_vocab_option_ast.attr_token, @name)
        return @composite.attr_max_token_type
      end
      full_file = @tool.get_imported_vocab_file(vocab_name)
      begin
        fr = FileReader.new(full_file)
        br = BufferedReader.new(fr)
        tokenizer = StreamTokenizer.new(br)
        tokenizer.parse_numbers
        tokenizer.word_chars(Character.new(?_.ord), Character.new(?_.ord))
        tokenizer.eol_is_significant(true)
        tokenizer.slash_slash_comments(true)
        tokenizer.slash_star_comments(true)
        tokenizer.ordinary_char(Character.new(?=.ord))
        tokenizer.quote_char(Character.new(?\'.ord))
        tokenizer.whitespace_chars(Character.new(?\s.ord), Character.new(?\s.ord))
        tokenizer.whitespace_chars(Character.new(?\t.ord), Character.new(?\t.ord))
        line_num = 1
        token = tokenizer.next_token
        while (!(token).equal?(StreamTokenizer::TT_EOF))
          token_id = nil
          if ((token).equal?(StreamTokenizer::TT_WORD))
            token_id = RJava.cast_to_string(tokenizer.attr_sval)
          else
            if ((token).equal?(Character.new(?\'.ord)))
              token_id = "'" + RJava.cast_to_string(tokenizer.attr_sval) + "'"
            else
              ErrorManager.error(ErrorManager::MSG_TOKENS_FILE_SYNTAX_ERROR, vocab_name + RJava.cast_to_string(CodeGenerator::VOCAB_FILE_EXTENSION), Utils.integer(line_num))
              while (!(tokenizer.next_token).equal?(StreamTokenizer::TT_EOL))
              end
              token = tokenizer.next_token
              next
            end
          end
          token = tokenizer.next_token
          if (!(token).equal?(Character.new(?=.ord)))
            ErrorManager.error(ErrorManager::MSG_TOKENS_FILE_SYNTAX_ERROR, vocab_name + RJava.cast_to_string(CodeGenerator::VOCAB_FILE_EXTENSION), Utils.integer(line_num))
            while (!(tokenizer.next_token).equal?(StreamTokenizer::TT_EOL))
            end
            token = tokenizer.next_token
            next
          end
          token = tokenizer.next_token # skip '='
          if (!(token).equal?(StreamTokenizer::TT_NUMBER))
            ErrorManager.error(ErrorManager::MSG_TOKENS_FILE_SYNTAX_ERROR, vocab_name + RJava.cast_to_string(CodeGenerator::VOCAB_FILE_EXTENSION), Utils.integer(line_num))
            while (!(tokenizer.next_token).equal?(StreamTokenizer::TT_EOL))
            end
            token = tokenizer.next_token
            next
          end
          token_type = RJava.cast_to_int(tokenizer.attr_nval)
          token = tokenizer.next_token
          # System.out.println("import "+tokenID+"="+tokenType);
          @composite.attr_max_token_type = Math.max(@composite.attr_max_token_type, token_type)
          define_token(token_id, token_type)
          line_num += 1
          if (!(token).equal?(StreamTokenizer::TT_EOL))
            ErrorManager.error(ErrorManager::MSG_TOKENS_FILE_SYNTAX_ERROR, vocab_name + RJava.cast_to_string(CodeGenerator::VOCAB_FILE_EXTENSION), Utils.integer(line_num))
            while (!(tokenizer.next_token).equal?(StreamTokenizer::TT_EOL))
            end
            token = tokenizer.next_token
            next
          end
          token = tokenizer.next_token # skip newline
        end
        br.close
      rescue FileNotFoundException => fnfe
        ErrorManager.error(ErrorManager::MSG_CANNOT_FIND_TOKENS_FILE, full_file)
      rescue IOException => ioe
        ErrorManager.error(ErrorManager::MSG_ERROR_READING_TOKENS_FILE, full_file, ioe)
      rescue JavaException => e
        ErrorManager.error(ErrorManager::MSG_ERROR_READING_TOKENS_FILE, full_file, e)
      end
      return @composite.attr_max_token_type
    end
    
    typesig { [::Java::Int] }
    # Given a token type, get a meaningful name for it such as the ID
    # or string literal.  If this is a lexer and the ttype is in the
    # char vocabulary, compute an ANTLR-valid (possibly escaped) char literal.
    def get_token_display_name(ttype)
      token_name = nil
      index = 0
      # inside any target's char range and is lexer grammar?
      if ((@type).equal?(LEXER) && ttype >= Label::MIN_CHAR_VALUE && ttype <= Label::MAX_CHAR_VALUE)
        return get_antlrchar_literal_for_char(ttype)
      # faux label?
      else
        if (ttype < 0)
          token_name = RJava.cast_to_string(@composite.attr_type_to_token_list.get(Label::NUM_FAUX_LABELS + ttype))
        else
          # compute index in typeToTokenList for ttype
          index = ttype - 1 # normalize to 0..n-1
          index += Label::NUM_FAUX_LABELS # jump over faux tokens
          if (index < @composite.attr_type_to_token_list.size)
            token_name = RJava.cast_to_string(@composite.attr_type_to_token_list.get(index))
            if (!(token_name).nil? && token_name.starts_with(AUTO_GENERATED_TOKEN_NAME_PREFIX))
              token_name = RJava.cast_to_string(@composite.attr_type_to_string_literal_list.get(ttype))
            end
          else
            token_name = RJava.cast_to_string(String.value_of(ttype))
          end
        end
      end
      # System.out.println("getTokenDisplayName ttype="+ttype+", index="+index+", name="+tokenName);
      return token_name
    end
    
    typesig { [] }
    # Get the list of ANTLR String literals
    def get_string_literals
      return @composite.attr_string_literal_to_type_map.key_set
    end
    
    typesig { [] }
    def get_grammar_type_string
      return GrammarTypeToString[@type]
    end
    
    typesig { [] }
    def get_grammar_max_lookahead
      if (@global_k >= 0)
        return @global_k
      end
      k = get_option("k")
      if ((k).nil?)
        @global_k = 0
      else
        if (k.is_a?(JavaInteger))
          k_i = k
          @global_k = k_i.int_value
        else
          # must be String "*"
          if ((k == "*"))
            # this the default anyway
            @global_k = 0
          end
        end
      end
      return @global_k
    end
    
    typesig { [String, Object, Antlr::Token] }
    # Save the option key/value pair and process it; return the key
    # or null if invalid option.
    def set_option(key, value, options_start_token)
      if (legal_option(key))
        ErrorManager.grammar_error(ErrorManager::MSG_ILLEGAL_OPTION, self, options_start_token, key)
        return nil
      end
      if (!option_is_valid(key, value))
        return nil
      end
      if ((@options).nil?)
        @options = HashMap.new
      end
      @options.put(key, value)
      return key
    end
    
    typesig { [String] }
    def legal_option(key)
      case (@type)
      when LEXER
        return !LegalLexerOptions.contains(key)
      when PARSER
        return !LegalParserOptions.contains(key)
      when TREE_PARSER
        return !LegalTreeParserOptions.contains(key)
      else
        return !LegalParserOptions.contains(key)
      end
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
    
    typesig { [String] }
    def get_option(key)
      return @composite.get_option(key)
    end
    
    typesig { [String] }
    def get_locally_defined_option(key)
      value = nil
      if (!(@options).nil?)
        value = @options.get(key)
      end
      if ((value).nil?)
        value = DefaultOptions.get(key)
      end
      return value
    end
    
    typesig { [GrammarAST, String] }
    def get_block_option(block_ast, key)
      v = block_ast.get_block_option(key)
      if (!(v).nil?)
        return v
      end
      if ((@type).equal?(Grammar::LEXER))
        return DefaultLexerBlockOptions.get(key)
      end
      return DefaultBlockOptions.get(key)
    end
    
    typesig { [::Java::Int] }
    def get_user_max_lookahead(decision)
      user_k = 0
      block_ast = @nfa.attr_grammar.get_decision_block_ast(decision)
      k = block_ast.get_block_option("k")
      if ((k).nil?)
        user_k = @nfa.attr_grammar.get_grammar_max_lookahead
        return user_k
      end
      if (k.is_a?(JavaInteger))
        k_i = k
        user_k = k_i.int_value
      else
        # must be String "*"
        if ((k == "*"))
          user_k = 0
        end
      end
      return user_k
    end
    
    typesig { [::Java::Int] }
    def get_auto_backtrack_mode(decision)
      decision_nfastart_state = get_decision_nfastart_state(decision)
      auto_backtrack = get_block_option(decision_nfastart_state.attr_associated_astnode, "backtrack")
      if ((auto_backtrack).nil?)
        auto_backtrack = RJava.cast_to_string(@nfa.attr_grammar.get_option("backtrack"))
      end
      return !(auto_backtrack).nil? && (auto_backtrack == "true")
    end
    
    typesig { [String, Object] }
    def option_is_valid(key, value)
      return true
    end
    
    typesig { [] }
    def build_ast
      output_type = get_option("output")
      if (!(output_type).nil?)
        return (output_type == "AST")
      end
      return false
    end
    
    typesig { [] }
    def rewrite_mode
      output_type = get_option("rewrite")
      if (!(output_type).nil?)
        return (output_type == "true")
      end
      return false
    end
    
    typesig { [] }
    def is_built_from_string
      return @built_from_string
    end
    
    typesig { [] }
    def build_template
      output_type = get_option("output")
      if (!(output_type).nil?)
        return (output_type == "template")
      end
      return false
    end
    
    typesig { [] }
    def get_rules
      return @name_to_rule_map.values
    end
    
    typesig { [] }
    # Get the set of Rules that need to have manual delegations
    # like "void rule() { importedGrammar.rule(); }"
    # 
    # If this grammar is master, get list of all rule definitions from all
    # delegate grammars.  Only master has complete interface from combined
    # grammars...we will generated delegates as helper objects.
    # 
    # Composite grammars that are not the root/master do not have complete
    # interfaces.  It is not my intention that people use subcomposites.
    # Only the outermost grammar should be used from outside code.  The
    # other grammar components are specifically generated to work only
    # with the master/root.
    # 
    # delegatedRules = imported - overridden
    def get_delegated_rules
      return @composite.get_delegated_rules(self)
    end
    
    typesig { [] }
    # Get set of all rules imported from all delegate grammars even if
    # indirectly delegated.
    def get_all_imported_rules
      return @composite.get_all_imported_rules(self)
    end
    
    typesig { [] }
    # Get list of all delegates from all grammars directly or indirectly
    # imported into this grammar.
    def get_delegates
      return @composite.get_delegates(self)
    end
    
    typesig { [] }
    def get_delegate_names
      # compute delegates:{Grammar g | return g.name;}
      names = ArrayList.new
      delegates = @composite.get_delegates(self)
      if (!(delegates).nil?)
        delegates.each do |g|
          names.add(g.attr_name)
        end
      end
      return names
    end
    
    typesig { [] }
    def get_direct_delegates
      return @composite.get_direct_delegates(self)
    end
    
    typesig { [] }
    # Get delegates below direct delegates
    def get_indirect_delegates
      return @composite.get_indirect_delegates(self)
    end
    
    typesig { [] }
    # Get list of all delegators.  This amounts to the grammars on the path
    # to the root of the delegation tree.
    def get_delegators
      return @composite.get_delegators(self)
    end
    
    typesig { [] }
    # Who's my direct parent grammar?
    def get_delegator
      return @composite.get_delegator(self)
    end
    
    typesig { [] }
    def get_delegated_rule_references
      return @delegated_rule_references
    end
    
    typesig { [] }
    def get_grammar_is_root
      return (@composite.attr_delegate_grammar_tree_root.attr_grammar).equal?(self)
    end
    
    typesig { [String, GrammarAST] }
    def set_rule_ast(rule_name, t)
      r = get_locally_defined_rule(rule_name)
      if (!(r).nil?)
        r.attr_tree = t
        r.attr_eornode = t.get_last_child
      end
    end
    
    typesig { [String] }
    def get_rule_start_state(rule_name)
      return get_rule_start_state(nil, rule_name)
    end
    
    typesig { [String, String] }
    def get_rule_start_state(scope_name, rule_name)
      r = get_rule(scope_name, rule_name)
      if (!(r).nil?)
        # System.out.println("getRuleStartState("+scopeName+", "+ruleName+")="+r.startState);
        return r.attr_start_state
      end
      # System.out.println("getRuleStartState("+scopeName+", "+ruleName+")=null");
      return nil
    end
    
    typesig { [String] }
    def get_rule_modifier(rule_name)
      r = get_rule(rule_name)
      if (!(r).nil?)
        return r.attr_modifier
      end
      return nil
    end
    
    typesig { [String] }
    def get_rule_stop_state(rule_name)
      r = get_rule(rule_name)
      if (!(r).nil?)
        return r.attr_stop_state
      end
      return nil
    end
    
    typesig { [NFAState] }
    def assign_decision_number(state)
      @decision_count += 1
      state.set_decision_number(@decision_count)
      return @decision_count
    end
    
    typesig { [::Java::Int] }
    def get_decision(decision)
      index = decision - 1
      if (index >= @index_to_decision.size)
        return nil
      end
      d = @index_to_decision.get(index)
      return d
    end
    
    typesig { [::Java::Int] }
    def create_decision(decision)
      index = decision - 1
      if (index < @index_to_decision.size)
        return get_decision(decision) # don't recreate
      end
      d = Decision.new
      d.attr_decision = decision
      @index_to_decision.set_size(get_number_of_decisions)
      @index_to_decision.set(index, d)
      return d
    end
    
    typesig { [] }
    def get_decision_nfastart_state_list
      states = ArrayList.new(100)
      d = 0
      while d < @index_to_decision.size
        dec = @index_to_decision.get(d)
        states.add(dec.attr_start_state)
        d += 1
      end
      return states
    end
    
    typesig { [::Java::Int] }
    def get_decision_nfastart_state(decision)
      d = get_decision(decision)
      if ((d).nil?)
        return nil
      end
      return d.attr_start_state
    end
    
    typesig { [::Java::Int] }
    def get_lookahead_dfa(decision)
      d = get_decision(decision)
      if ((d).nil?)
        return nil
      end
      return d.attr_dfa
    end
    
    typesig { [::Java::Int] }
    def get_decision_block_ast(decision)
      d = get_decision(decision)
      if ((d).nil?)
        return nil
      end
      return d.attr_block_ast
    end
    
    typesig { [::Java::Int] }
    # returns a list of column numbers for all decisions
    # on a particular line so ANTLRWorks choose the decision
    # depending on the location of the cursor (otherwise,
    # ANTLRWorks has to give the *exact* location which
    # is not easy from the user point of view).
    # 
    # This is not particularly fast as it walks entire line:col->DFA map
    # looking for a prefix of "line:".
    def get_lookahead_dfacolumns_for_line_in_file(line)
      prefix = RJava.cast_to_string(line) + ":"
      columns = ArrayList.new
      iter = @line_column_to_lookahead_dfamap.key_set.iterator
      while iter.has_next
        key = iter.next_
        if (key.starts_with(prefix))
          columns.add(JavaInteger.value_of(key.substring(prefix.length)))
        end
      end
      return columns
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # Useful for ANTLRWorks to map position in file to the DFA for display
    def get_lookahead_dfafrom_position_in_file(line, col)
      return @line_column_to_lookahead_dfamap.get(StringBuffer.new.append(RJava.cast_to_string(line) + ":").append(col).to_s)
    end
    
    typesig { [] }
    def get_line_column_to_lookahead_dfamap
      return @line_column_to_lookahead_dfamap
    end
    
    typesig { [] }
    # public void setDecisionOptions(int decision, Map options) {
    # Decision d = createDecision(decision);
    # d.options = options;
    # }
    # 
    # public void setDecisionOption(int decision, String name, Object value) {
    # Decision d = getDecision(decision);
    # if ( d!=null ) {
    # if ( d.options==null ) {
    # d.options = new HashMap();
    # }
    # d.options.put(name,value);
    # }
    # }
    # 
    # public Map getDecisionOptions(int decision) {
    # Decision d = getDecision(decision);
    # if ( d==null ) {
    # return null;
    # }
    # return d.options;
    # }
    def get_number_of_decisions
      return @decision_count
    end
    
    typesig { [] }
    def get_number_of_cyclic_decisions
      n = 0
      i = 1
      while i <= get_number_of_decisions
        d = get_decision(i)
        if (!(d.attr_dfa).nil? && d.attr_dfa.is_cyclic)
          n += 1
        end
        i += 1
      end
      return n
    end
    
    typesig { [::Java::Int, DFA] }
    # Set the lookahead DFA for a particular decision.  This means
    # that the appropriate AST node must updated to have the new lookahead
    # DFA.  This method could be used to properly set the DFAs without
    # using the createLookaheadDFAs() method.  You could do this
    # 
    # Grammar g = new Grammar("...");
    # g.setLookahead(1, dfa1);
    # g.setLookahead(2, dfa2);
    # ...
    def set_lookahead_dfa(decision, lookahead_dfa)
      d = create_decision(decision)
      d.attr_dfa = lookahead_dfa
      ast = d.attr_start_state.attr_associated_astnode
      ast.set_lookahead_dfa(lookahead_dfa)
    end
    
    typesig { [::Java::Int, NFAState] }
    def set_decision_nfa(decision, state)
      d = create_decision(decision)
      d.attr_start_state = state
    end
    
    typesig { [::Java::Int, GrammarAST] }
    def set_decision_block_ast(decision, block_ast)
      # System.out.println("setDecisionBlockAST("+decision+", "+blockAST.token);
      d = create_decision(decision)
      d.attr_block_ast = block_ast
    end
    
    typesig { [] }
    def all_decision_dfahave_been_created
      return @all_decision_dfacreated
    end
    
    typesig { [] }
    # How many token types have been allocated so far?
    def get_max_token_type
      return @composite.attr_max_token_type
    end
    
    typesig { [] }
    # What is the max char value possible for this grammar's target?  Use
    # unicode max if no target defined.
    def get_max_char_value
      if (!(@generator).nil?)
        return @generator.attr_target.get_max_char_value(@generator)
      else
        return Label::MAX_CHAR_VALUE
      end
    end
    
    typesig { [] }
    # Return a set of all possible token or char types for this grammar
    def get_token_types
      if ((@type).equal?(LEXER))
        return get_all_char_values
      end
      return IntervalSet.of(Label::MIN_TOKEN_TYPE, get_max_token_type)
    end
    
    typesig { [] }
    # If there is a char vocabulary, use it; else return min to max char
    # as defined by the target.  If no target, use max unicode char value.
    def get_all_char_values
      if (!(@char_vocabulary).nil?)
        return @char_vocabulary
      end
      all_char = IntervalSet.of(Label::MIN_CHAR_VALUE, get_max_char_value)
      return all_char
    end
    
    class_module.module_eval {
      typesig { [::Java::Int] }
      # Return a string representing the escaped char for code c.  E.g., If c
      # has value 0x100, you will get "\u0100".  ASCII gets the usual
      # char (non-hex) representation.  Control characters are spit out
      # as unicode.  While this is specially set up for returning Java strings,
      # it can be used by any language target that has the same syntax. :)
      # 
      # 11/26/2005: I changed this to use double quotes, consistent with antlr.g
      # 12/09/2005: I changed so everything is single quotes
      def get_antlrchar_literal_for_char(c)
        if (c < Label::MIN_CHAR_VALUE)
          ErrorManager.internal_error("invalid char value " + RJava.cast_to_string(c))
          return "'<INVALID>'"
        end
        if (c < self.attr_antlrliteral_char_value_escape.attr_length && !(self.attr_antlrliteral_char_value_escape[c]).nil?)
          return Character.new(?\'.ord) + self.attr_antlrliteral_char_value_escape[c] + Character.new(?\'.ord)
        end
        if ((Character::UnicodeBlock.of(RJava.cast_to_char(c))).equal?(Character::UnicodeBlock::BASIC_LATIN) && !Character.is_isocontrol(RJava.cast_to_char(c)))
          if ((c).equal?(Character.new(?\\.ord)))
            return "'\\\\'"
          end
          if ((c).equal?(Character.new(?\'.ord)))
            return "'\\''"
          end
          return Character.new(?\'.ord) + Character.to_s(RJava.cast_to_char(c)) + Character.new(?\'.ord)
        end
        # turn on the bit above max "\uFFFF" value so that we pad with zeros
        # then only take last 4 digits
        hex = JavaInteger.to_hex_string(c | 0x10000).to_upper_case.substring(1, 5)
        unicode_str = "'\\u" + hex + "'"
        return unicode_str
      end
    }
    
    typesig { [IntSet] }
    # For lexer grammars, return everything in unicode not in set.
    # For parser and tree grammars, return everything in token space
    # from MIN_TOKEN_TYPE to last valid token type or char value.
    def complement(set_)
      # System.out.println("complement "+set.toString(this));
      # System.out.println("vocabulary "+getTokenTypes().toString(this));
      c = set_.complement(get_token_types)
      # System.out.println("result="+c.toString(this));
      return c
    end
    
    typesig { [::Java::Int] }
    def complement(atom)
      return complement(IntervalSet.of(atom))
    end
    
    typesig { [TreeToNFAConverter, GrammarAST] }
    # Given set tree like ( SET A B ), check that A and B
    # are both valid sets themselves, else we must tree like a BLOCK
    def is_valid_set(nfabuilder, t)
      valid = true
      begin
        # System.out.println("parse BLOCK as set tree: "+t.toStringTree());
        nfabuilder.test_block_as_set(t)
      rescue RecognitionException => re
        # The rule did not parse as a set, return null; ignore exception
        valid = false
      end
      # System.out.println("valid? "+valid);
      return valid
    end
    
    typesig { [TreeToNFAConverter, String] }
    # Get the set equivalent (if any) of the indicated rule from this
    # grammar.  Mostly used in the lexer to do ~T for some fragment rule
    # T.  If the rule AST has a SET use that.  If the rule is a single char
    # convert it to a set and return.  If rule is not a simple set (w/o actions)
    # then return null.
    # Rules have AST form:
    # 
    # ^( RULE ID modifier ARG RET SCOPE block EOR )
    def get_set_from_rule(nfabuilder, rule_name)
      r = get_rule(rule_name)
      if ((r).nil?)
        return nil
      end
      elements_ = nil
      # System.out.println("parsed tree: "+r.tree.toStringTree());
      elements_ = nfabuilder.set_rule(r.attr_tree)
      # System.out.println("elements="+elements);
      return elements_
    end
    
    typesig { [NFAState] }
    # Decisions are linked together with transition(1).  Count how
    # many there are.  This is here rather than in NFAState because
    # a grammar decides how NFAs are put together to form a decision.
    def get_number_of_alts_for_decision_nfa(decision_state)
      if ((decision_state).nil?)
        return 0
      end
      n = 1
      p = decision_state
      while (!(p.attr_transition[1]).nil?)
        n += 1
        p = p.attr_transition[1].attr_target
      end
      return n
    end
    
    typesig { [NFAState, ::Java::Int] }
    # Get the ith alternative (1..n) from a decision; return null when
    # an invalid alt is requested.  I must count in to find the right
    # alternative number.  For (A|B), you get NFA structure (roughly):
    # 
    # o->o-A->o
    # |
    # o->o-B->o
    # 
    # This routine returns the leftmost state for each alt.  So alt=1, returns
    # the upperleft most state in this structure.
    def get_nfastate_for_alt_of_decision(decision_state, alt)
      if ((decision_state).nil? || alt <= 0)
        return nil
      end
      n = 1
      p = decision_state
      while (!(p).nil?)
        if ((n).equal?(alt))
          return p
        end
        n += 1
        next__ = p.attr_transition[1]
        p = nil
        if (!(next__).nil?)
          p = next__.attr_target
        end
      end
      return nil
    end
    
    typesig { [NFAState] }
    # public void computeRuleFOLLOWSets() {
    # if ( getNumberOfDecisions()==0 ) {
    # createNFAs();
    # }
    # for (Iterator it = getRules().iterator(); it.hasNext();) {
    # Rule r = (Rule)it.next();
    # if ( r.isSynPred ) {
    # continue;
    # }
    # LookaheadSet s = ll1Analyzer.FOLLOW(r);
    # System.out.println("FOLLOW("+r.name+")="+s);
    # }
    # }
    def _first(s)
      return @ll1analyzer._first(s)
    end
    
    typesig { [NFAState] }
    def _look(s)
      return @ll1analyzer._look(s)
    end
    
    typesig { [CodeGenerator] }
    def set_code_generator(generator)
      @generator = generator
    end
    
    typesig { [] }
    def get_code_generator
      return @generator
    end
    
    typesig { [] }
    def get_grammar_tree
      return @grammar_tree
    end
    
    typesig { [] }
    def get_tool
      return @tool
    end
    
    typesig { [Tool] }
    def set_tool(tool)
      @tool = tool
    end
    
    typesig { [::Java::Int, String] }
    # given a token type and the text of the literal, come up with a
    # decent token type label.  For now it's just T<type>.  Actually,
    # if there is an aliased name from tokens like PLUS='+', use it.
    def compute_token_name_from_literal(token_type, literal)
      return AUTO_GENERATED_TOKEN_NAME_PREFIX + RJava.cast_to_string(token_type)
    end
    
    typesig { [] }
    def to_s
      return grammar_tree_to_string(@grammar_tree)
    end
    
    typesig { [GrammarAST] }
    def grammar_tree_to_string(t)
      return grammar_tree_to_string(t, true)
    end
    
    typesig { [GrammarAST, ::Java::Boolean] }
    def grammar_tree_to_string(t, show_actions)
      s = nil
      begin
        s = RJava.cast_to_string(t.get_line) + ":" + RJava.cast_to_string(t.get_column) + ": "
        s += RJava.cast_to_string(ANTLRTreePrinter.new.to_s(t, self, show_actions))
      rescue JavaException => e
        s = "<invalid or missing tree structure>"
      end
      return s
    end
    
    typesig { [PrintStream] }
    def print_grammar(output)
      printer = ANTLRTreePrinter.new
      printer.set_astnode_class("org.antlr.tool.GrammarAST")
      begin
        g = printer.to_s(@grammar_tree, self, false)
        output.println(g)
      rescue RecognitionException => re
        ErrorManager.error(ErrorManager::MSG_SYNTAX_ERROR, re)
      end
    end
    
    private
    alias_method :initialize__grammar, :initialize
  end
  
end
