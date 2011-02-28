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
module Org::Antlr::Tool
  module AssignTokenTypesBehaviorImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Misc, :Utils
      include ::Java::Util
      include_const ::Antlr::Collections::Impl, :ASTArray
    }
  end
  
  # Move all of the functionality from assign.types.g grammar file.
  class AssignTokenTypesBehavior < AssignTokenTypesBehaviorImports.const_get :AssignTokenTypesWalker
    include_class_members AssignTokenTypesBehaviorImports
    
    class_module.module_eval {
      const_set_lazy(:UNASSIGNED) { Utils.integer(-1) }
      const_attr_reader  :UNASSIGNED
      
      const_set_lazy(:UNASSIGNED_IN_PARSER_RULE) { Utils.integer(-2) }
      const_attr_reader  :UNASSIGNED_IN_PARSER_RULE
    }
    
    attr_accessor :string_literals
    alias_method :attr_string_literals, :string_literals
    undef_method :string_literals
    alias_method :attr_string_literals=, :string_literals=
    undef_method :string_literals=
    
    attr_accessor :tokens
    alias_method :attr_tokens, :tokens
    undef_method :tokens
    alias_method :attr_tokens=, :tokens=
    undef_method :tokens=
    
    attr_accessor :aliases
    alias_method :attr_aliases, :aliases
    undef_method :aliases
    alias_method :attr_aliases=, :aliases=
    undef_method :aliases=
    
    attr_accessor :aliases_reverse_index
    alias_method :attr_aliases_reverse_index, :aliases_reverse_index
    undef_method :aliases_reverse_index
    alias_method :attr_aliases_reverse_index=, :aliases_reverse_index=
    undef_method :aliases_reverse_index=
    
    # Track actual lexer rule defs so we don't get repeated token defs in
    # generated lexer.
    attr_accessor :token_rule_defs
    alias_method :attr_token_rule_defs, :token_rule_defs
    undef_method :token_rule_defs
    alias_method :attr_token_rule_defs=, :token_rule_defs=
    undef_method :token_rule_defs=
    
    typesig { [Grammar] }
    def init(g)
      self.attr_grammar = g
      self.attr_current_rule_name = nil
      if ((self.attr_string_alias).nil?)
        # only init once; can't statically init since we need astFactory
        init_astpatterns
      end
    end
    
    typesig { [GrammarAST] }
    # Track string literals (could be in tokens{} section)
    def track_string(t)
      # if lexer, don't allow aliasing in tokens section
      if ((self.attr_current_rule_name).nil? && (self.attr_grammar.attr_type).equal?(Grammar::LEXER))
        ErrorManager.grammar_error(ErrorManager::MSG_CANNOT_ALIAS_TOKENS_IN_LEXER, self.attr_grammar, t.attr_token, t.get_text)
        return
      end
      # in a plain parser grammar rule, cannot reference literals
      # (unless defined previously via tokenVocab option)
      # don't warn until we hit root grammar as may be defined there.
      if (self.attr_grammar.get_grammar_is_root && (self.attr_grammar.attr_type).equal?(Grammar::PARSER) && (self.attr_grammar.get_token_type(t.get_text)).equal?(Label::INVALID))
        ErrorManager.grammar_error(ErrorManager::MSG_LITERAL_NOT_ASSOCIATED_WITH_LEXER_RULE, self.attr_grammar, t.attr_token, t.get_text)
      end
      # Don't record literals for lexers, they are things to match not tokens
      if ((self.attr_grammar.attr_type).equal?(Grammar::LEXER))
        return
      end
      # otherwise add literal to token types if referenced from parser rule
      # or in the tokens{} section
      if (((self.attr_current_rule_name).nil? || Character.is_lower_case(self.attr_current_rule_name.char_at(0))) && (self.attr_grammar.get_token_type(t.get_text)).equal?(Label::INVALID))
        @string_literals.put(t.get_text, UNASSIGNED_IN_PARSER_RULE)
      end
    end
    
    typesig { [GrammarAST] }
    def track_token(t)
      # imported token names might exist, only add if new
      # Might have ';'=4 in vocab import and SEMI=';'. Avoid
      # setting to UNASSIGNED if we have loaded ';'/SEMI
      if ((self.attr_grammar.get_token_type(t.get_text)).equal?(Label::INVALID) && (@tokens.get(t.get_text)).nil?)
        @tokens.put(t.get_text, UNASSIGNED)
      end
    end
    
    typesig { [GrammarAST, GrammarAST, GrammarAST] }
    def track_token_rule(t, modifier, block)
      # imported token names might exist, only add if new
      if ((self.attr_grammar.attr_type).equal?(Grammar::LEXER) || (self.attr_grammar.attr_type).equal?(Grammar::COMBINED))
        if (!Character.is_upper_case(t.get_text.char_at(0)))
          return
        end
        if ((t.get_text == Grammar::ARTIFICIAL_TOKENS_RULENAME))
          # don't add Tokens rule
          return
        end
        # track all lexer rules so we can look for token refs w/o
        # associated lexer rules.
        self.attr_grammar.attr_composite.attr_lexer_rules.add(t.get_text)
        existing = self.attr_grammar.get_token_type(t.get_text)
        if ((existing).equal?(Label::INVALID))
          @tokens.put(t.get_text, UNASSIGNED)
        end
        # look for "<TOKEN> : <literal> ;" pattern
        # (can have optional action last)
        if (block.has_same_tree_structure(self.attr_char_alias) || block.has_same_tree_structure(self.attr_string_alias) || block.has_same_tree_structure(self.attr_char_alias2) || block.has_same_tree_structure(self.attr_string_alias2))
          @token_rule_defs.add(t.get_text)
          # 			Grammar parent = grammar.composite.getDelegator(grammar);
          # 			boolean importedByParserOrCombined =
          # 				parent!=null &&
          # 				(parent.type==Grammar.LEXER||parent.type==Grammar.PARSER);
          if ((self.attr_grammar.attr_type).equal?(Grammar::COMBINED) || (self.attr_grammar.attr_type).equal?(Grammar::LEXER))
            # only call this rule an alias if combined or lexer
            alias_(t, block.get_first_child.get_first_child)
          end
        end
      end
      # else error
    end
    
    typesig { [GrammarAST, GrammarAST] }
    def alias_(t, s)
      token_id = t.get_text
      literal = s.get_text
      prev_alias_literal_id = @aliases_reverse_index.get(literal)
      if (!(prev_alias_literal_id).nil?)
        # we've seen this literal before
        if ((token_id == prev_alias_literal_id))
          # duplicate but identical alias; might be tokens {A='a'} and
          # lexer rule A : 'a' ;  Is ok, just return
          return
        end
        # give error unless both are rules (ok if one is in tokens section)
        if (!(@token_rule_defs.contains(token_id) && @token_rule_defs.contains(prev_alias_literal_id)))
          # don't allow alias if A='a' in tokens section and B : 'a'; is rule.
          # Allow if both are rules.  Will get DFA nondeterminism error later.
          ErrorManager.grammar_error(ErrorManager::MSG_TOKEN_ALIAS_CONFLICT, self.attr_grammar, t.attr_token, token_id + "=" + literal, prev_alias_literal_id)
        end
        return # don't do the alias
      end
      existing_literal_type = self.attr_grammar.get_token_type(literal)
      if (!(existing_literal_type).equal?(Label::INVALID))
        # we've seen this before from a tokenVocab most likely
        # don't assign a new token type; use existingLiteralType.
        @tokens.put(token_id, existing_literal_type)
      end
      prev_alias_token_id = @aliases.get(token_id)
      if (!(prev_alias_token_id).nil?)
        ErrorManager.grammar_error(ErrorManager::MSG_TOKEN_ALIAS_REASSIGNMENT, self.attr_grammar, t.attr_token, token_id + "=" + literal, prev_alias_token_id)
        return # don't do the alias
      end
      @aliases.put(token_id, literal)
      @aliases_reverse_index.put(literal, token_id)
    end
    
    typesig { [Grammar] }
    def define_tokens(root)
      # 	System.out.println("stringLiterals="+stringLiterals);
      # 	System.out.println("tokens="+tokens);
      # 	System.out.println("aliases="+aliases);
      # 	System.out.println("aliasesReverseIndex="+aliasesReverseIndex);
      assign_token_idtypes(root)
      alias_token_ids_and_literals(root)
      assign_string_types(root)
      # 	System.out.println("stringLiterals="+stringLiterals);
      # 	System.out.println("tokens="+tokens);
      # 	System.out.println("aliases="+aliases);
      define_token_names_and_literals_in_grammar(root)
    end
    
    typesig { [Grammar] }
    # protected void defineStringLiteralsFromDelegates() {
    # 	 if ( grammar.getGrammarIsMaster() && grammar.type==Grammar.COMBINED ) {
    # 		 List<Grammar> delegates = grammar.getDelegates();
    # 		 System.out.println("delegates in master combined: "+delegates);
    # 		 for (int i = 0; i < delegates.size(); i++) {
    # 			 Grammar d = (Grammar) delegates.get(i);
    # 			 Set<String> literals = d.getStringLiterals();
    # 			 for (Iterator it = literals.iterator(); it.hasNext();) {
    # 				 String literal = (String) it.next();
    # 				 System.out.println("literal "+literal);
    # 				 int ttype = grammar.getTokenType(literal);
    # 				 grammar.defineLexerRuleForStringLiteral(literal, ttype);
    # 			 }
    # 		 }
    # 	 }
    # }
    def assign_string_types(root)
      # walk string literals assigning types to unassigned ones
      s = @string_literals.key_set
      it = s.iterator
      while it.has_next
        lit = it.next_
        old_type_i = @string_literals.get(lit)
        old_type = old_type_i.int_value
        if (old_type < Label::MIN_TOKEN_TYPE)
          type_i = Utils.integer(root.get_new_token_type)
          @string_literals.put(lit, type_i)
          # if string referenced in combined grammar parser rule,
          # automatically define in the generated lexer
          root.define_lexer_rule_for_string_literal(lit, type_i.int_value)
        end
      end
    end
    
    typesig { [Grammar] }
    def alias_token_ids_and_literals(root)
      if ((root.attr_type).equal?(Grammar::LEXER))
        return # strings/chars are never token types in LEXER
      end
      # walk aliases if any and assign types to aliased literals if literal
      # was referenced
      s = @aliases.key_set
      it = s.iterator
      while it.has_next
        token_id = it.next_
        literal = @aliases.get(token_id)
        if ((literal.char_at(0)).equal?(Character.new(?\'.ord)) && !(@string_literals.get(literal)).nil?)
          @string_literals.put(literal, @tokens.get(token_id))
          # an alias still means you need a lexer rule for it
          type_i = @tokens.get(token_id)
          if (!@token_rule_defs.contains(token_id))
            root.define_lexer_rule_for_aliased_string_literal(token_id, literal, type_i.int_value)
          end
        end
      end
    end
    
    typesig { [Grammar] }
    def assign_token_idtypes(root)
      # walk token names, assigning values if unassigned
      s = @tokens.key_set
      it = s.iterator
      while it.has_next
        token_id = it.next_
        if ((@tokens.get(token_id)).equal?(UNASSIGNED))
          @tokens.put(token_id, Utils.integer(root.get_new_token_type))
        end
      end
    end
    
    typesig { [Grammar] }
    def define_token_names_and_literals_in_grammar(root)
      s = @tokens.key_set
      it = s.iterator
      while it.has_next
        token_id = it.next_
        ttype = (@tokens.get(token_id)).int_value
        root.define_token(token_id, ttype)
      end
      s = @string_literals.key_set
      it_ = s.iterator
      while it_.has_next
        lit = it_.next_
        ttype = (@string_literals.get(lit)).int_value
        root.define_token(lit, ttype)
      end
    end
    
    typesig { [] }
    def initialize
      @string_literals = nil
      @tokens = nil
      @aliases = nil
      @aliases_reverse_index = nil
      @token_rule_defs = nil
      super()
      @string_literals = LinkedHashMap.new
      @tokens = LinkedHashMap.new
      @aliases = LinkedHashMap.new
      @aliases_reverse_index = HashMap.new
      @token_rule_defs = HashSet.new
    end
    
    private
    alias_method :initialize__assign_token_types_behavior, :initialize
  end
  
end
