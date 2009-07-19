require "rjava"
 # $ANTLR 2.7.7 (2006-01-29): "antlr.g" -> "ANTLRParser.java"$
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
  module ANTLRParserImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Java::Util
      include ::Java::Io
      include ::Org::Antlr::Analysis
      include ::Org::Antlr::Misc
      include ::Antlr
      include_const ::Antlr, :TokenBuffer
      include_const ::Antlr, :TokenStreamException
      include_const ::Antlr, :TokenStreamIOException
      include_const ::Antlr, :ANTLRException
      include_const ::Antlr, :LLkParser
      include_const ::Antlr, :Token
      include_const ::Antlr, :TokenStream
      include_const ::Antlr, :RecognitionException
      include_const ::Antlr, :NoViableAltException
      include_const ::Antlr, :MismatchedTokenException
      include_const ::Antlr, :SemanticException
      include_const ::Antlr, :ParserSharedInputState
      include_const ::Antlr::Collections::Impl, :BitSet
      include_const ::Antlr::Collections, :AST
      include_const ::Java::Util, :Hashtable
      include_const ::Antlr, :ASTFactory
      include_const ::Antlr, :ASTPair
      include_const ::Antlr::Collections::Impl, :ASTArray
    }
  end
  
  # Read in an ANTLR grammar and build an AST.  Try not to do
  # any actions, just build the tree.
  # 
  # The phases are:
  # 
  # antlr.g (this file)
  # assign.types.g
  # define.g
  # buildnfa.g
  # antlr.print.g (optional)
  # codegen.g
  # 
  # Terence Parr
  # University of San Francisco
  # 2005
  class ANTLRParser < Antlr::LLkParser
    include_class_members ANTLRParserImports
    include ANTLRTokenTypes
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :gtype
    alias_method :attr_gtype, :gtype
    undef_method :gtype
    alias_method :attr_gtype=, :gtype=
    undef_method :gtype=
    
    attr_accessor :current_rule_name
    alias_method :attr_current_rule_name, :current_rule_name
    undef_method :current_rule_name
    alias_method :attr_current_rule_name=, :current_rule_name=
    undef_method :current_rule_name=
    
    attr_accessor :current_block_ast
    alias_method :attr_current_block_ast, :current_block_ast
    undef_method :current_block_ast
    alias_method :attr_current_block_ast=, :current_block_ast=
    undef_method :current_block_ast=
    
    typesig { [GrammarAST] }
    def set_to_block_with_set(b)
      alt = self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(ALT, "ALT")).add(b).add(self.attr_ast_factory.create(EOA, "<end-of-alt>")))
      prefix_with_syn_pred(alt)
      return self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(BLOCK, "BLOCK")).add(alt).add(self.attr_ast_factory.create(EOB, "<end-of-block>")))
    end
    
    typesig { [GrammarAST] }
    # Create a copy of the alt and make it into a BLOCK; all actions,
    # labels, tree operators, rewrites are removed.
    def create_block_from_dup_alt(alt)
      nalt = GrammarAST.dup_tree_no_actions(alt, nil)
      blk = self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(BLOCK, "BLOCK")).add(nalt).add(self.attr_ast_factory.create(EOB, "<end-of-block>")))
      return blk
    end
    
    typesig { [GrammarAST] }
    # Rewrite alt to have a synpred as first element;
    # (xxx)=>xxx
    # but only if they didn't specify one manually.
    def prefix_with_syn_pred(alt)
      # if they want backtracking and it's not a lexer rule in combined grammar
      auto_backtrack = @grammar.get_block_option(@current_block_ast, "backtrack")
      if ((auto_backtrack).nil?)
        auto_backtrack = (@grammar.get_option("backtrack")).to_s
      end
      if (!(auto_backtrack).nil? && (auto_backtrack == "true") && !((@gtype).equal?(COMBINED_GRAMMAR) && Character.is_upper_case(@current_rule_name.char_at(0))) && !(alt.get_first_child.get_type).equal?(SYN_SEMPRED))
        # duplicate alt and make a synpred block around that dup'd alt
        synpred_block_ast = create_block_from_dup_alt(alt)
        # Create a BACKTRACK_SEMPRED node as if user had typed this in
        # Effectively we replace (xxx)=>xxx with {synpredxxx}? xxx
        synpred_ast = create_syn_sem_pred_from_block(synpred_block_ast, BACKTRACK_SEMPRED)
        # insert BACKTRACK_SEMPRED as first element of alt
        synpred_ast.get_last_sibling.set_next_sibling(alt.get_first_child)
        alt.set_first_child(synpred_ast)
      end
    end
    
    typesig { [GrammarAST, ::Java::Int] }
    def create_syn_sem_pred_from_block(synpred_block_ast, synpred_token_type)
      # add grammar fragment to a list so we can make fake rules for them
      # later.
      pred_name = @grammar.define_syntactic_predicate(synpred_block_ast, @current_rule_name)
      # convert (alpha)=> into {synpredN}? where N is some pred count
      # during code gen we convert to function call with templates
      synpredinvoke = pred_name
      p = self.attr_ast_factory.create(synpred_token_type, synpredinvoke)
      # track how many decisions have synpreds
      @grammar.attr_blocks_with_syn_preds.add(@current_block_ast)
      return p
    end
    
    typesig { [String, GrammarAST, ::Java::Boolean] }
    def create_simple_rule_ast(name, block, fragment)
      modifier = nil
      if (fragment)
        modifier = self.attr_ast_factory.create(FRAGMENT, "fragment")
      end
      eorast = self.attr_ast_factory.create(EOR, "<end-of-rule>")
      eobast = block.get_last_child
      eorast.set_line(eobast.get_line)
      eorast.set_column(eobast.get_column)
      rule_ast = self.attr_ast_factory.make((ASTArray.new(8)).add(self.attr_ast_factory.create(RULE, "rule")).add(self.attr_ast_factory.create(ID, name)).add(modifier).add(self.attr_ast_factory.create(ARG, "ARG")).add(self.attr_ast_factory.create(RET, "RET")).add(self.attr_ast_factory.create(SCOPE, "scope")).add(block).add(eorast))
      rule_ast.set_line(block.get_line)
      rule_ast.set_column(block.get_column)
      return rule_ast
    end
    
    typesig { [RecognitionException] }
    def report_error(ex)
      token = nil
      begin
        token = _lt(1)
      rescue TokenStreamException => tse
        ErrorManager.internal_error("can't get token???", tse)
      end
      ErrorManager.syntax_error(ErrorManager::MSG_SYNTAX_ERROR, @grammar, token, "antlr: " + (ex.to_s).to_s, ex)
    end
    
    typesig { [GrammarAST] }
    def cleanup(root)
      if ((@gtype).equal?(LEXER_GRAMMAR))
        filter = @grammar.get_option("filter")
        tokens_rule_ast = @grammar.add_artificial_match_tokens_rule(root, @grammar.attr_lexer_rule_names_in_combined, @grammar.get_delegate_names, !(filter).nil? && (filter == "true"))
      end
    end
    
    typesig { [TokenBuffer, ::Java::Int] }
    def initialize(token_buf, k)
      @grammar = nil
      @gtype = 0
      @current_rule_name = nil
      @current_block_ast = nil
      super(token_buf, k)
      @grammar = nil
      @gtype = 0
      @current_rule_name = nil
      @current_block_ast = nil
      self.attr_token_names = _tokenNames
      build_token_type_astclass_map
      self.attr_ast_factory = ASTFactory.new(get_token_type_to_astclass_map)
    end
    
    typesig { [TokenBuffer] }
    def initialize(token_buf)
      initialize__antlrparser(token_buf, 3)
    end
    
    typesig { [TokenStream, ::Java::Int] }
    def initialize(lexer, k)
      @grammar = nil
      @gtype = 0
      @current_rule_name = nil
      @current_block_ast = nil
      super(lexer, k)
      @grammar = nil
      @gtype = 0
      @current_rule_name = nil
      @current_block_ast = nil
      self.attr_token_names = _tokenNames
      build_token_type_astclass_map
      self.attr_ast_factory = ASTFactory.new(get_token_type_to_astclass_map)
    end
    
    typesig { [TokenStream] }
    def initialize(lexer)
      initialize__antlrparser(lexer, 3)
    end
    
    typesig { [ParserSharedInputState] }
    def initialize(state)
      @grammar = nil
      @gtype = 0
      @current_rule_name = nil
      @current_block_ast = nil
      super(state, 3)
      @grammar = nil
      @gtype = 0
      @current_rule_name = nil
      @current_block_ast = nil
      self.attr_token_names = _tokenNames
      build_token_type_astclass_map
      self.attr_ast_factory = ASTFactory.new(get_token_type_to_astclass_map)
    end
    
    typesig { [Grammar] }
    def grammar(g)
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      grammar_ast = nil
      cmt = nil
      cmt_ast = nil
      gr_ast = nil
      gid_ast = nil
      ig_ast = nil
      ts_ast = nil
      scopes_ast = nil
      a_ast = nil
      r_ast = nil
      @grammar = g
      opt = nil
      options_start_token = nil
      opts = nil
      set_astnode_class(GrammarAST.class)
      set_astnode_class("org.antlr.tool.GrammarAST")
      self.attr_ast_factory = # set to factory that sets enclosing rule
      Class.new(ASTFactory.class == Class ? ASTFactory : Object) do
        extend LocalClass
        include_class_members ANTLRParser
        include ASTFactory if ASTFactory.class == Module
        
        typesig { [Token] }
        define_method :create do |token|
          t = super(token)
          (t).attr_enclosing_rule_name = self.attr_current_rule_name
          return t
        end
        
        typesig { [::Java::Int] }
        define_method :create do |i|
          t = super(i)
          (t).attr_enclosing_rule_name = self.attr_current_rule_name
          return t
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self)
      begin
        # for error handling
        case (_la(1))
        when ACTION
          tmp1_ast = nil
          tmp1_ast = self.attr_ast_factory.create(_lt(1))
          match(ACTION)
        when PARSER, DOC_COMMENT, LITERAL_lexer, LITERAL_tree, LITERAL_grammar
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when DOC_COMMENT
          cmt = _lt(1)
          cmt_ast = self.attr_ast_factory.create(cmt)
          match(DOC_COMMENT)
        when PARSER, LITERAL_lexer, LITERAL_tree, LITERAL_grammar
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        grammar_type
        gr_ast = self.attr_return_ast
        id
        gid_ast = self.attr_return_ast
        @grammar.set_name(gid_ast.get_text)
        tmp2_ast = nil
        tmp2_ast = self.attr_ast_factory.create(_lt(1))
        match(SEMI)
        case (_la(1))
        when OPTIONS
          options_start_token = _lt(1)
          opts = options_spec
          @grammar.set_options(opts, options_start_token)
          opt = self.attr_return_ast
        when TOKENS, SCOPE, IMPORT, FRAGMENT, DOC_COMMENT, AMPERSAND, TOKEN_REF, LITERAL_protected, LITERAL_public, LITERAL_private, RULE_REF
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when IMPORT
          delegate_grammars
          ig_ast = self.attr_return_ast
        when TOKENS, SCOPE, FRAGMENT, DOC_COMMENT, AMPERSAND, TOKEN_REF, LITERAL_protected, LITERAL_public, LITERAL_private, RULE_REF
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when TOKENS
          tokens_spec
          ts_ast = self.attr_return_ast
        when SCOPE, FRAGMENT, DOC_COMMENT, AMPERSAND, TOKEN_REF, LITERAL_protected, LITERAL_public, LITERAL_private, RULE_REF
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        attr_scopes
        scopes_ast = self.attr_return_ast
        case (_la(1))
        when AMPERSAND
          actions
          a_ast = self.attr_return_ast
        when FRAGMENT, DOC_COMMENT, TOKEN_REF, LITERAL_protected, LITERAL_public, LITERAL_private, RULE_REF
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        rules
        r_ast = self.attr_return_ast
        tmp3_ast = nil
        tmp3_ast = self.attr_ast_factory.create(_lt(1))
        match(Token::EOF_TYPE)
        grammar_ast = current_ast.attr_root
        grammar_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(nil).add(self.attr_ast_factory.make((ASTArray.new(9)).add(gr_ast).add(gid_ast).add(cmt_ast).add(opt).add(ig_ast).add(ts_ast).add(scopes_ast).add(a_ast).add(r_ast))))
        cleanup(grammar_ast)
        current_ast.attr_root = grammar_ast
        current_ast.attr_child = !(grammar_ast).nil? && !(grammar_ast.get_first_child).nil? ? grammar_ast.get_first_child : grammar_ast
        current_ast.advance_child_to_end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_0)
      end
      self.attr_return_ast = grammar_ast
    end
    
    typesig { [] }
    def grammar_type
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      grammar_type_ast = nil
      gr = nil
      gr_ast = nil
      begin
        # for error handling
        case (_la(1))
        when LITERAL_lexer
          match(LITERAL_lexer)
          @gtype = LEXER_GRAMMAR
          @grammar.attr_type = Grammar::LEXER
        when PARSER
          match(PARSER)
          @gtype = PARSER_GRAMMAR
          @grammar.attr_type = Grammar::PARSER
        when LITERAL_tree
          match(LITERAL_tree)
          @gtype = TREE_GRAMMAR
          @grammar.attr_type = Grammar::TREE_PARSER
        when LITERAL_grammar
          @gtype = COMBINED_GRAMMAR
          @grammar.attr_type = Grammar::COMBINED
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        gr = _lt(1)
        gr_ast = self.attr_ast_factory.create(gr)
        self.attr_ast_factory.add_astchild(current_ast, gr_ast)
        match(LITERAL_grammar)
        gr_ast.set_type(@gtype)
        grammar_type_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_1)
      end
      self.attr_return_ast = grammar_type_ast
    end
    
    typesig { [] }
    def id
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      id_ast = nil
      begin
        # for error handling
        case (_la(1))
        when TOKEN_REF
          tmp7_ast = nil
          tmp7_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.add_astchild(current_ast, tmp7_ast)
          match(TOKEN_REF)
          id_ast = current_ast.attr_root
          id_ast.set_type(ID)
          id_ast = current_ast.attr_root
        when RULE_REF
          tmp8_ast = nil
          tmp8_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.add_astchild(current_ast, tmp8_ast)
          match(RULE_REF)
          id_ast = current_ast.attr_root
          id_ast.set_type(ID)
          id_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_2)
      end
      self.attr_return_ast = id_ast
    end
    
    typesig { [] }
    def options_spec
      opts = HashMap.new
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      options_spec_ast = nil
      begin
        # for error handling
        tmp9_ast = nil
        tmp9_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp9_ast)
        match(OPTIONS)
        _cnt18 = 0
        begin
          if (((_la(1)).equal?(TOKEN_REF) || (_la(1)).equal?(RULE_REF)))
            option(opts)
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            match(SEMI)
          else
            if (_cnt18 >= 1)
              break
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
          ((_cnt18 += 1) - 1)
        end while (true)
        match(RCURLY)
        options_spec_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_3)
      end
      self.attr_return_ast = options_spec_ast
      return opts
    end
    
    typesig { [] }
    def delegate_grammars
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      delegate_grammars_ast = nil
      begin
        # for error handling
        tmp12_ast = nil
        tmp12_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp12_ast)
        match(IMPORT)
        delegate_grammar
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        begin
          if (((_la(1)).equal?(COMMA)))
            match(COMMA)
            delegate_grammar
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            break
          end
        end while (true)
        match(SEMI)
        delegate_grammars_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_4)
      end
      self.attr_return_ast = delegate_grammars_ast
    end
    
    typesig { [] }
    def tokens_spec
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      tokens_spec_ast = nil
      begin
        # for error handling
        tmp15_ast = nil
        tmp15_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp15_ast)
        match(TOKENS)
        _cnt27 = 0
        begin
          if (((_la(1)).equal?(TOKEN_REF)))
            token_spec
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            if (_cnt27 >= 1)
              break
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
          ((_cnt27 += 1) - 1)
        end while (true)
        match(RCURLY)
        tokens_spec_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_5)
      end
      self.attr_return_ast = tokens_spec_ast
    end
    
    typesig { [] }
    def attr_scopes
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      attr_scopes_ast = nil
      begin
        # for error handling
        begin
          if (((_la(1)).equal?(SCOPE)))
            attr_scope
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            break
          end
        end while (true)
        attr_scopes_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_6)
      end
      self.attr_return_ast = attr_scopes_ast
    end
    
    typesig { [] }
    def actions
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      actions_ast = nil
      begin
        # for error handling
        _cnt12 = 0
        begin
          if (((_la(1)).equal?(AMPERSAND)))
            action
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            if (_cnt12 >= 1)
              break
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
          ((_cnt12 += 1) - 1)
        end while (true)
        actions_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_7)
      end
      self.attr_return_ast = actions_ast
    end
    
    typesig { [] }
    def rules
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rules_ast = nil
      begin
        # for error handling
        _cnt37 = 0
        begin
          if ((_tokenSet_7.member(_la(1))))
            rule
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            if (_cnt37 >= 1)
              break
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
          ((_cnt37 += 1) - 1)
        end while (true)
        rules_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_0)
      end
      self.attr_return_ast = rules_ast
    end
    
    typesig { [] }
    # Match stuff like @parser::members {int i;}
    def action
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      action_ast = nil
      begin
        # for error handling
        tmp17_ast = nil
        tmp17_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp17_ast)
        match(AMPERSAND)
        if ((_tokenSet_8.member(_la(1))) && ((_la(2)).equal?(COLON)))
          action_scope_name
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          match(COLON)
          match(COLON)
        else
          if (((_la(1)).equal?(TOKEN_REF) || (_la(1)).equal?(RULE_REF)) && ((_la(2)).equal?(ACTION)))
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
        end
        id
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        tmp20_ast = nil
        tmp20_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp20_ast)
        match(ACTION)
        action_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_6)
      end
      self.attr_return_ast = action_ast
    end
    
    typesig { [] }
    # Sometimes the scope names will collide with keywords; allow them as
    # ids for action scopes.
    def action_scope_name
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      action_scope_name_ast = nil
      l = nil
      l_ast = nil
      p = nil
      p_ast = nil
      begin
        # for error handling
        case (_la(1))
        when TOKEN_REF, RULE_REF
          id
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          action_scope_name_ast = current_ast.attr_root
        when LITERAL_lexer
          l = _lt(1)
          l_ast = self.attr_ast_factory.create(l)
          self.attr_ast_factory.add_astchild(current_ast, l_ast)
          match(LITERAL_lexer)
          l_ast.set_type(ID)
          action_scope_name_ast = current_ast.attr_root
        when PARSER
          p = _lt(1)
          p_ast = self.attr_ast_factory.create(p)
          self.attr_ast_factory.add_astchild(current_ast, p_ast)
          match(PARSER)
          p_ast.set_type(ID)
          action_scope_name_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_9)
      end
      self.attr_return_ast = action_scope_name_ast
    end
    
    typesig { [Map] }
    def option(opts)
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      option_ast = nil
      o_ast = nil
      value = nil
      begin
        # for error handling
        id
        o_ast = self.attr_return_ast
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        tmp21_ast = nil
        tmp21_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp21_ast)
        match(ASSIGN)
        value = option_value
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        opts.put(o_ast.get_text, value)
        option_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_10)
      end
      self.attr_return_ast = option_ast
    end
    
    typesig { [] }
    def option_value
      value = nil
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      option_value_ast = nil
      x_ast = nil
      s = nil
      s_ast = nil
      c = nil
      c_ast = nil
      i = nil
      i_ast = nil
      ss = nil
      ss_ast = nil
      begin
        # for error handling
        case (_la(1))
        when TOKEN_REF, RULE_REF
          id
          x_ast = self.attr_return_ast
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          value = x_ast.get_text
          option_value_ast = current_ast.attr_root
        when STRING_LITERAL
          s = _lt(1)
          s_ast = self.attr_ast_factory.create(s)
          self.attr_ast_factory.add_astchild(current_ast, s_ast)
          match(STRING_LITERAL)
          vs = s_ast.get_text
          value = vs.substring(1, vs.length - 1)
          option_value_ast = current_ast.attr_root
        when CHAR_LITERAL
          c = _lt(1)
          c_ast = self.attr_ast_factory.create(c)
          self.attr_ast_factory.add_astchild(current_ast, c_ast)
          match(CHAR_LITERAL)
          vs = c_ast.get_text
          value = vs.substring(1, vs.length - 1)
          option_value_ast = current_ast.attr_root
        when INT
          i = _lt(1)
          i_ast = self.attr_ast_factory.create(i)
          self.attr_ast_factory.add_astchild(current_ast, i_ast)
          match(INT)
          value = i_ast.get_text
          option_value_ast = current_ast.attr_root
        when STAR
          ss = _lt(1)
          ss_ast = self.attr_ast_factory.create(ss)
          self.attr_ast_factory.add_astchild(current_ast, ss_ast)
          match(STAR)
          ss_ast.set_type(STRING_LITERAL)
          value = "*"
          option_value_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_10)
      end
      self.attr_return_ast = option_value_ast
      return value
    end
    
    typesig { [] }
    def delegate_grammar
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      delegate_grammar_ast = nil
      lab_ast = nil
      g_ast = nil
      g2_ast = nil
      begin
        # for error handling
        if (((_la(1)).equal?(TOKEN_REF) || (_la(1)).equal?(RULE_REF)) && ((_la(2)).equal?(ASSIGN)))
          id
          lab_ast = self.attr_return_ast
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          tmp22_ast = nil
          tmp22_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.make_astroot(current_ast, tmp22_ast)
          match(ASSIGN)
          id
          g_ast = self.attr_return_ast
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          @grammar.import_grammar(g_ast, lab_ast.get_text)
          delegate_grammar_ast = current_ast.attr_root
        else
          if (((_la(1)).equal?(TOKEN_REF) || (_la(1)).equal?(RULE_REF)) && ((_la(2)).equal?(SEMI) || (_la(2)).equal?(COMMA)))
            id
            g2_ast = self.attr_return_ast
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            @grammar.import_grammar(g2_ast, nil)
            delegate_grammar_ast = current_ast.attr_root
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_11)
      end
      self.attr_return_ast = delegate_grammar_ast
    end
    
    typesig { [] }
    def token_spec
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      token_spec_ast = nil
      begin
        # for error handling
        tmp23_ast = nil
        tmp23_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp23_ast)
        match(TOKEN_REF)
        case (_la(1))
        when ASSIGN
          tmp24_ast = nil
          tmp24_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.make_astroot(current_ast, tmp24_ast)
          match(ASSIGN)
          case (_la(1))
          when STRING_LITERAL
            tmp25_ast = nil
            tmp25_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.add_astchild(current_ast, tmp25_ast)
            match(STRING_LITERAL)
          when CHAR_LITERAL
            tmp26_ast = nil
            tmp26_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.add_astchild(current_ast, tmp26_ast)
            match(CHAR_LITERAL)
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
        when SEMI
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        match(SEMI)
        token_spec_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_12)
      end
      self.attr_return_ast = token_spec_ast
    end
    
    typesig { [] }
    def attr_scope
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      attr_scope_ast = nil
      begin
        # for error handling
        tmp28_ast = nil
        tmp28_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp28_ast)
        match(SCOPE)
        id
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        tmp29_ast = nil
        tmp29_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp29_ast)
        match(ACTION)
        attr_scope_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_5)
      end
      self.attr_return_ast = attr_scope_ast
    end
    
    typesig { [] }
    def rule
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rule_ast = nil
      d = nil
      d_ast = nil
      p1 = nil
      p1_ast = nil
      p2 = nil
      p2_ast = nil
      p3 = nil
      p3_ast = nil
      p4 = nil
      p4_ast = nil
      rule_name_ast = nil
      aa = nil
      aa_ast = nil
      rt = nil
      rt_ast = nil
      scopes_ast = nil
      a_ast = nil
      colon = nil
      colon_ast = nil
      b_ast = nil
      semi = nil
      semi_ast = nil
      ex_ast = nil
      modifier = nil
      blk = nil
      blk_root = nil
      eob = nil
      start = (_lt(1)).get_index
      start_line = _lt(1).get_line
      opt = nil
      opts = nil
      begin
        # for error handling
        case (_la(1))
        when DOC_COMMENT
          d = _lt(1)
          d_ast = self.attr_ast_factory.create(d)
          match(DOC_COMMENT)
        when FRAGMENT, TOKEN_REF, LITERAL_protected, LITERAL_public, LITERAL_private, RULE_REF
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when LITERAL_protected
          p1 = _lt(1)
          p1_ast = self.attr_ast_factory.create(p1)
          match(LITERAL_protected)
          modifier = p1_ast
        when LITERAL_public
          p2 = _lt(1)
          p2_ast = self.attr_ast_factory.create(p2)
          match(LITERAL_public)
          modifier = p2_ast
        when LITERAL_private
          p3 = _lt(1)
          p3_ast = self.attr_ast_factory.create(p3)
          match(LITERAL_private)
          modifier = p3_ast
        when FRAGMENT
          p4 = _lt(1)
          p4_ast = self.attr_ast_factory.create(p4)
          match(FRAGMENT)
          modifier = p4_ast
        when TOKEN_REF, RULE_REF
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        id
        rule_name_ast = self.attr_return_ast
        @current_rule_name = (rule_name_ast.get_text).to_s
        if ((@gtype).equal?(LEXER_GRAMMAR) && (p4_ast).nil?)
          @grammar.attr_lexer_rule_names_in_combined.add(@current_rule_name)
        end
        case (_la(1))
        when BANG
          tmp30_ast = nil
          tmp30_ast = self.attr_ast_factory.create(_lt(1))
          match(BANG)
        when OPTIONS, SCOPE, AMPERSAND, COLON, ARG_ACTION, LITERAL_returns, LITERAL_throws
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when ARG_ACTION
          aa = _lt(1)
          aa_ast = self.attr_ast_factory.create(aa)
          match(ARG_ACTION)
        when OPTIONS, SCOPE, AMPERSAND, COLON, LITERAL_returns, LITERAL_throws
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when LITERAL_returns
          match(LITERAL_returns)
          rt = _lt(1)
          rt_ast = self.attr_ast_factory.create(rt)
          match(ARG_ACTION)
        when OPTIONS, SCOPE, AMPERSAND, COLON, LITERAL_throws
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when LITERAL_throws
          throws_spec
        when OPTIONS, SCOPE, AMPERSAND, COLON
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when OPTIONS
          opts = options_spec
          opt = self.attr_return_ast
        when SCOPE, AMPERSAND, COLON
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        rule_scope_spec
        scopes_ast = self.attr_return_ast
        case (_la(1))
        when AMPERSAND
          rule_actions
          a_ast = self.attr_return_ast
        when COLON
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        colon = _lt(1)
        colon_ast = self.attr_ast_factory.create(colon)
        match(COLON)
        blk_root = self.attr_ast_factory.create(BLOCK, "BLOCK")
        blk_root.attr_block_options = opts
        blk_root.set_line(colon.get_line)
        blk_root.set_column(colon.get_column)
        eob = self.attr_ast_factory.create(EOB, "<end-of-block>")
        alt_list(opts)
        b_ast = self.attr_return_ast
        blk = b_ast
        semi = _lt(1)
        semi_ast = self.attr_ast_factory.create(semi)
        match(SEMI)
        case (_la(1))
        when LITERAL_catch, LITERAL_finally
          exception_group
          ex_ast = self.attr_return_ast
        when EOF, FRAGMENT, DOC_COMMENT, TOKEN_REF, LITERAL_protected, LITERAL_public, LITERAL_private, RULE_REF
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        rule_ast = current_ast.attr_root
        stop = (_lt(1)).get_index - 1 # point at the semi or exception thingie
        eob.set_line(semi.get_line)
        eob.set_column(semi.get_column)
        eor = self.attr_ast_factory.create(EOR, "<end-of-rule>")
        eor.set_line(semi.get_line)
        eor.set_column(semi.get_column)
        root = self.attr_ast_factory.create(RULE, "rule")
        root.attr_rule_start_token_index = start
        root.attr_rule_stop_token_index = stop
        root.set_line(start_line)
        root.attr_block_options = opts
        rule_ast = self.attr_ast_factory.make((ASTArray.new(11)).add(root).add(rule_name_ast).add(modifier).add(self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(ARG, "ARG")).add(aa_ast))).add(self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(RET, "RET")).add(rt_ast))).add(opt).add(scopes_ast).add(a_ast).add(blk).add(ex_ast).add(eor))
        @current_rule_name = (nil).to_s
        current_ast.attr_root = rule_ast
        current_ast.attr_child = !(rule_ast).nil? && !(rule_ast.get_first_child).nil? ? rule_ast.get_first_child : rule_ast
        current_ast.advance_child_to_end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_13)
      end
      self.attr_return_ast = rule_ast
    end
    
    typesig { [] }
    def throws_spec
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      throws_spec_ast = nil
      begin
        # for error handling
        tmp32_ast = nil
        tmp32_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp32_ast)
        match(LITERAL_throws)
        id
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        begin
          if (((_la(1)).equal?(COMMA)))
            tmp33_ast = nil
            tmp33_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.add_astchild(current_ast, tmp33_ast)
            match(COMMA)
            id
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            break
          end
        end while (true)
        throws_spec_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_14)
      end
      self.attr_return_ast = throws_spec_ast
    end
    
    typesig { [] }
    def rule_scope_spec
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rule_scope_spec_ast = nil
      a = nil
      a_ast = nil
      ids_ast = nil
      line = _lt(1).get_line
      column = _lt(1).get_column
      begin
        # for error handling
        if (((_la(1)).equal?(SCOPE)) && ((_la(2)).equal?(ACTION)) && ((_la(3)).equal?(SCOPE) || (_la(3)).equal?(AMPERSAND) || (_la(3)).equal?(COLON)))
          match(SCOPE)
          a = _lt(1)
          a_ast = self.attr_ast_factory.create(a)
          match(ACTION)
        else
          if (((_la(1)).equal?(SCOPE) || (_la(1)).equal?(AMPERSAND) || (_la(1)).equal?(COLON)) && (_tokenSet_15.member(_la(2))) && (_tokenSet_16.member(_la(3))))
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
        end
        begin
          if (((_la(1)).equal?(SCOPE)))
            match(SCOPE)
            id_list
            ids_ast = self.attr_return_ast
            match(SEMI)
          else
            break
          end
        end while (true)
        rule_scope_spec_ast = current_ast.attr_root
        scope_root = self.attr_ast_factory.create(SCOPE, "scope")
        scope_root.set_line(line)
        scope_root.set_column(column)
        rule_scope_spec_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(scope_root).add(a_ast).add(ids_ast))
        current_ast.attr_root = rule_scope_spec_ast
        current_ast.attr_child = !(rule_scope_spec_ast).nil? && !(rule_scope_spec_ast.get_first_child).nil? ? rule_scope_spec_ast.get_first_child : rule_scope_spec_ast
        current_ast.advance_child_to_end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_17)
      end
      self.attr_return_ast = rule_scope_spec_ast
    end
    
    typesig { [] }
    def rule_actions
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rule_actions_ast = nil
      begin
        # for error handling
        _cnt50 = 0
        begin
          if (((_la(1)).equal?(AMPERSAND)))
            rule_action
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            if (_cnt50 >= 1)
              break
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
          ((_cnt50 += 1) - 1)
        end while (true)
        rule_actions_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_9)
      end
      self.attr_return_ast = rule_actions_ast
    end
    
    typesig { [Map] }
    def alt_list(opts)
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      alt_list_ast = nil
      a1_ast = nil
      a2_ast = nil
      blk_root = self.attr_ast_factory.create(BLOCK, "BLOCK")
      blk_root.attr_block_options = opts
      blk_root.set_line(_lt(0).get_line) # set to : or (
      blk_root.set_column(_lt(0).get_column)
      save = @current_block_ast
      @current_block_ast = blk_root
      begin
        # for error handling
        alternative
        a1_ast = self.attr_return_ast
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        rewrite
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        if ((_la(1)).equal?(OR) || ((_la(2)).equal?(QUESTION) || (_la(2)).equal?(PLUS) || (_la(2)).equal?(STAR)))
          prefix_with_syn_pred(a1_ast)
        end
        begin
          if (((_la(1)).equal?(OR)))
            match(OR)
            alternative
            a2_ast = self.attr_return_ast
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            rewrite
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            if ((_la(1)).equal?(OR) || ((_la(2)).equal?(QUESTION) || (_la(2)).equal?(PLUS) || (_la(2)).equal?(STAR)))
              prefix_with_syn_pred(a2_ast)
            end
          else
            break
          end
        end while (true)
        alt_list_ast = current_ast.attr_root
        alt_list_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(blk_root).add(alt_list_ast).add(self.attr_ast_factory.create(EOB, "<end-of-block>")))
        @current_block_ast = save
        current_ast.attr_root = alt_list_ast
        current_ast.attr_child = !(alt_list_ast).nil? && !(alt_list_ast.get_first_child).nil? ? alt_list_ast.get_first_child : alt_list_ast
        current_ast.advance_child_to_end
        alt_list_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_10)
      end
      self.attr_return_ast = alt_list_ast
    end
    
    typesig { [] }
    def exception_group
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      exception_group_ast = nil
      begin
        # for error handling
        case (_la(1))
        when LITERAL_catch
          _cnt73 = 0
          begin
            if (((_la(1)).equal?(LITERAL_catch)))
              exception_handler
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            else
              if (_cnt73 >= 1)
                break
              else
                raise NoViableAltException.new(_lt(1), get_filename)
              end
            end
            ((_cnt73 += 1) - 1)
          end while (true)
          case (_la(1))
          when LITERAL_finally
            finally_clause
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          when EOF, FRAGMENT, DOC_COMMENT, TOKEN_REF, LITERAL_protected, LITERAL_public, LITERAL_private, RULE_REF
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          exception_group_ast = current_ast.attr_root
        when LITERAL_finally
          finally_clause
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          exception_group_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_13)
      end
      self.attr_return_ast = exception_group_ast
    end
    
    typesig { [] }
    # Match stuff like @init {int i;}
    def rule_action
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rule_action_ast = nil
      begin
        # for error handling
        tmp38_ast = nil
        tmp38_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp38_ast)
        match(AMPERSAND)
        id
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        tmp39_ast = nil
        tmp39_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp39_ast)
        match(ACTION)
        rule_action_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_17)
      end
      self.attr_return_ast = rule_action_ast
    end
    
    typesig { [] }
    def id_list
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      id_list_ast = nil
      begin
        # for error handling
        id
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        begin
          if (((_la(1)).equal?(COMMA)))
            match(COMMA)
            id
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            break
          end
        end while (true)
        id_list_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_10)
      end
      self.attr_return_ast = id_list_ast
    end
    
    typesig { [] }
    # Build #(BLOCK ( #(ALT ...) EOB )+ )
    def block
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      block_ast = nil
      lp = nil
      lp_ast = nil
      a1_ast = nil
      a2_ast = nil
      rp = nil
      rp_ast = nil
      save = @current_block_ast
      opts = nil
      begin
        # for error handling
        lp = _lt(1)
        lp_ast = self.attr_ast_factory.create(lp)
        self.attr_ast_factory.make_astroot(current_ast, lp_ast)
        match(LPAREN)
        lp_ast.set_type(BLOCK)
        lp_ast.set_text("BLOCK")
        if (((_la(1)).equal?(OPTIONS) || (_la(1)).equal?(AMPERSAND) || (_la(1)).equal?(COLON)))
          case (_la(1))
          when OPTIONS
            opts = options_spec
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            block_ast = current_ast.attr_root
            block_ast.set_options(@grammar, opts)
          when AMPERSAND, COLON
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          case (_la(1))
          when AMPERSAND
            rule_actions
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          when COLON
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          match(COLON)
        else
          if (((_la(1)).equal?(ACTION)) && ((_la(2)).equal?(COLON)) && (_tokenSet_18.member(_la(3))))
            tmp42_ast = nil
            tmp42_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.add_astchild(current_ast, tmp42_ast)
            match(ACTION)
            match(COLON)
          else
            if ((_tokenSet_18.member(_la(1))) && (_tokenSet_19.member(_la(2))) && (_tokenSet_20.member(_la(3))))
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
        end
        @current_block_ast = lp_ast
        alternative
        a1_ast = self.attr_return_ast
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        rewrite
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        if ((_la(1)).equal?(OR) || ((_la(2)).equal?(QUESTION) || (_la(2)).equal?(PLUS) || (_la(2)).equal?(STAR)))
          prefix_with_syn_pred(a1_ast)
        end
        begin
          if (((_la(1)).equal?(OR)))
            match(OR)
            alternative
            a2_ast = self.attr_return_ast
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            rewrite
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            if ((_la(1)).equal?(OR) || ((_la(2)).equal?(QUESTION) || (_la(2)).equal?(PLUS) || (_la(2)).equal?(STAR)))
              prefix_with_syn_pred(a2_ast)
            end
          else
            break
          end
        end while (true)
        rp = _lt(1)
        rp_ast = self.attr_ast_factory.create(rp)
        match(RPAREN)
        block_ast = current_ast.attr_root
        @current_block_ast = save
        eob = self.attr_ast_factory.create(EOB, "<end-of-block>")
        eob.set_line(rp.get_line)
        eob.set_column(rp.get_column)
        block_ast.add_child(eob)
        block_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_21)
      end
      self.attr_return_ast = block_ast
    end
    
    typesig { [] }
    def alternative
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      alternative_ast = nil
      el_ast = nil
      eoa = self.attr_ast_factory.create(EOA, "<end-of-alt>")
      alt_root = self.attr_ast_factory.create(ALT, "ALT")
      alt_root.set_line(_lt(1).get_line)
      alt_root.set_column(_lt(1).get_column)
      begin
        # for error handling
        case (_la(1))
        when FORCED_ACTION, ACTION, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, LPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN
          _cnt70 = 0
          begin
            if ((_tokenSet_22.member(_la(1))))
              element
              el_ast = self.attr_return_ast
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            else
              if (_cnt70 >= 1)
                break
              else
                raise NoViableAltException.new(_lt(1), get_filename)
              end
            end
            ((_cnt70 += 1) - 1)
          end while (true)
          alternative_ast = current_ast.attr_root
          if ((alternative_ast).nil?)
            alternative_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(alt_root).add(self.attr_ast_factory.create(EPSILON, "epsilon")).add(eoa))
          else
            # we have a real list of stuff
            alternative_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(alt_root).add(alternative_ast).add(eoa))
          end
          current_ast.attr_root = alternative_ast
          current_ast.attr_child = !(alternative_ast).nil? && !(alternative_ast.get_first_child).nil? ? alternative_ast.get_first_child : alternative_ast
          current_ast.advance_child_to_end
          alternative_ast = current_ast.attr_root
        when SEMI, OR, RPAREN, REWRITE
          alternative_ast = current_ast.attr_root
          eps = self.attr_ast_factory.create(EPSILON, "epsilon")
          eps.set_line(_lt(0).get_line) # get line/col of '|' or ':' (prev token)
          eps.set_column(_lt(0).get_column)
          alternative_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(alt_root).add(eps).add(eoa))
          current_ast.attr_root = alternative_ast
          current_ast.attr_child = !(alternative_ast).nil? && !(alternative_ast.get_first_child).nil? ? alternative_ast.get_first_child : alternative_ast
          current_ast.advance_child_to_end
          alternative_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_23)
      end
      self.attr_return_ast = alternative_ast
    end
    
    typesig { [] }
    def rewrite
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_ast = nil
      rew = nil
      rew_ast = nil
      pred = nil
      pred_ast = nil
      alt_ast = nil
      rew2 = nil
      rew2_ast = nil
      alt2_ast = nil
      root = GrammarAST.new
      begin
        # for error handling
        case (_la(1))
        when REWRITE
          begin
            if (((_la(1)).equal?(REWRITE)) && ((_la(2)).equal?(SEMPRED)))
              rew = _lt(1)
              rew_ast = self.attr_ast_factory.create(rew)
              match(REWRITE)
              pred = _lt(1)
              pred_ast = self.attr_ast_factory.create(pred)
              match(SEMPRED)
              rewrite_alternative
              alt_ast = self.attr_return_ast
              root.add_child(self.attr_ast_factory.make((ASTArray.new(3)).add(rew_ast).add(pred_ast).add(alt_ast)))
            else
              break
            end
          end while (true)
          rew2 = _lt(1)
          rew2_ast = self.attr_ast_factory.create(rew2)
          match(REWRITE)
          rewrite_alternative
          alt2_ast = self.attr_return_ast
          rewrite_ast = current_ast.attr_root
          root.add_child(self.attr_ast_factory.make((ASTArray.new(2)).add(rew2_ast).add(alt2_ast)))
          rewrite_ast = root.get_first_child
          current_ast.attr_root = rewrite_ast
          current_ast.attr_child = !(rewrite_ast).nil? && !(rewrite_ast.get_first_child).nil? ? rewrite_ast.get_first_child : rewrite_ast
          current_ast.advance_child_to_end
        when SEMI, OR, RPAREN
          rewrite_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_24)
      end
      self.attr_return_ast = rewrite_ast
    end
    
    typesig { [] }
    def element
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      element_ast = nil
      begin
        # for error handling
        element_no_option_spec
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        element_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_25)
      end
      self.attr_return_ast = element_ast
    end
    
    typesig { [] }
    def exception_handler
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      exception_handler_ast = nil
      begin
        # for error handling
        tmp45_ast = nil
        tmp45_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp45_ast)
        match(LITERAL_catch)
        tmp46_ast = nil
        tmp46_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp46_ast)
        match(ARG_ACTION)
        tmp47_ast = nil
        tmp47_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp47_ast)
        match(ACTION)
        exception_handler_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_26)
      end
      self.attr_return_ast = exception_handler_ast
    end
    
    typesig { [] }
    def finally_clause
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      finally_clause_ast = nil
      begin
        # for error handling
        tmp48_ast = nil
        tmp48_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp48_ast)
        match(LITERAL_finally)
        tmp49_ast = nil
        tmp49_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp49_ast)
        match(ACTION)
        finally_clause_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_13)
      end
      self.attr_return_ast = finally_clause_ast
    end
    
    typesig { [] }
    def element_no_option_spec
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      element_no_option_spec_ast = nil
      p = nil
      p_ast = nil
      t3_ast = nil
      elements = nil
      sub = nil
      sub2 = nil
      begin
        # for error handling
        case (_la(1))
        when LPAREN
          ebnf
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        when FORCED_ACTION
          tmp50_ast = nil
          tmp50_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.add_astchild(current_ast, tmp50_ast)
          match(FORCED_ACTION)
        when ACTION
          tmp51_ast = nil
          tmp51_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.add_astchild(current_ast, tmp51_ast)
          match(ACTION)
        when SEMPRED
          p = _lt(1)
          p_ast = self.attr_ast_factory.create(p)
          self.attr_ast_factory.add_astchild(current_ast, p_ast)
          match(SEMPRED)
          case (_la(1))
          when IMPLIES
            match(IMPLIES)
            p_ast.set_type(GATED_SEMPRED)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          @grammar.attr_blocks_with_sem_preds.add(@current_block_ast)
        when TREE_BEGIN
          tree
          t3_ast = self.attr_return_ast
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        else
          if (((_la(1)).equal?(TOKEN_REF) || (_la(1)).equal?(RULE_REF)) && ((_la(2)).equal?(ASSIGN) || (_la(2)).equal?(PLUS_ASSIGN)))
            id
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            case (_la(1))
            when ASSIGN
              tmp53_ast = nil
              tmp53_ast = self.attr_ast_factory.create(_lt(1))
              self.attr_ast_factory.make_astroot(current_ast, tmp53_ast)
              match(ASSIGN)
            when PLUS_ASSIGN
              tmp54_ast = nil
              tmp54_ast = self.attr_ast_factory.create(_lt(1))
              self.attr_ast_factory.make_astroot(current_ast, tmp54_ast)
              match(PLUS_ASSIGN)
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
            case (_la(1))
            when STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, WILDCARD, RULE_REF, NOT
              atom
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            when LPAREN
              block
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
            case (_la(1))
            when STAR, QUESTION, PLUS
              sub = ebnf_suffix(current_ast.attr_root, false)
              element_no_option_spec_ast = current_ast.attr_root
              element_no_option_spec_ast = sub
              current_ast.attr_root = element_no_option_spec_ast
              current_ast.attr_child = !(element_no_option_spec_ast).nil? && !(element_no_option_spec_ast.get_first_child).nil? ? element_no_option_spec_ast.get_first_child : element_no_option_spec_ast
              current_ast.advance_child_to_end
            when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, REWRITE
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          else
            if ((_tokenSet_27.member(_la(1))) && (_tokenSet_28.member(_la(2))))
              atom
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              case (_la(1))
              when STAR, QUESTION, PLUS
                sub2 = ebnf_suffix(current_ast.attr_root, false)
                element_no_option_spec_ast = current_ast.attr_root
                element_no_option_spec_ast = sub2
                current_ast.attr_root = element_no_option_spec_ast
                current_ast.attr_child = !(element_no_option_spec_ast).nil? && !(element_no_option_spec_ast.get_first_child).nil? ? element_no_option_spec_ast.get_first_child : element_no_option_spec_ast
                current_ast.advance_child_to_end
              when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, REWRITE
              else
                raise NoViableAltException.new(_lt(1), get_filename)
              end
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
        end
        element_no_option_spec_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_25)
      end
      self.attr_return_ast = element_no_option_spec_ast
    end
    
    typesig { [] }
    def atom
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      atom_ast = nil
      w = nil
      w_ast = nil
      begin
        # for error handling
        if (((_la(1)).equal?(CHAR_LITERAL)) && ((_la(2)).equal?(RANGE)))
          range
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          case (_la(1))
          when ROOT
            tmp55_ast = nil
            tmp55_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp55_ast)
            match(ROOT)
          when BANG
            tmp56_ast = nil
            tmp56_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp56_ast)
            match(BANG)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          atom_ast = current_ast.attr_root
        else
          if ((_tokenSet_29.member(_la(1))) && (_tokenSet_30.member(_la(2))))
            if ((((_la(1)).equal?(TOKEN_REF) || (_la(1)).equal?(RULE_REF)) && ((_la(2)).equal?(WILDCARD)) && (_tokenSet_29.member(_la(3)))) && ((_lt(1).get_column + _lt(1).get_text.length).equal?(_lt(2).get_column) && (_lt(2).get_column + 1).equal?(_lt(3).get_column)))
              id
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              w = _lt(1)
              w_ast = self.attr_ast_factory.create(w)
              self.attr_ast_factory.make_astroot(current_ast, w_ast)
              match(WILDCARD)
              case (_la(1))
              when STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, WILDCARD
                terminal
                self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              when RULE_REF
                ruleref
                self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              else
                raise NoViableAltException.new(_lt(1), get_filename)
              end
              w_ast.set_type(DOT)
            else
              if ((_tokenSet_31.member(_la(1))) && (_tokenSet_30.member(_la(2))) && (_tokenSet_20.member(_la(3))))
                terminal
                self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              else
                if (((_la(1)).equal?(RULE_REF)) && (_tokenSet_32.member(_la(2))) && (_tokenSet_20.member(_la(3))))
                  ruleref
                  self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
                else
                  raise NoViableAltException.new(_lt(1), get_filename)
                end
              end
            end
            atom_ast = current_ast.attr_root
          else
            if (((_la(1)).equal?(NOT)))
              not_set
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              case (_la(1))
              when ROOT
                tmp57_ast = nil
                tmp57_ast = self.attr_ast_factory.create(_lt(1))
                self.attr_ast_factory.make_astroot(current_ast, tmp57_ast)
                match(ROOT)
              when BANG
                tmp58_ast = nil
                tmp58_ast = self.attr_ast_factory.create(_lt(1))
                self.attr_ast_factory.make_astroot(current_ast, tmp58_ast)
                match(BANG)
              when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
              else
                raise NoViableAltException.new(_lt(1), get_filename)
              end
              atom_ast = current_ast.attr_root
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_33)
      end
      self.attr_return_ast = atom_ast
    end
    
    typesig { [GrammarAST, ::Java::Boolean] }
    def ebnf_suffix(elem_ast, in_rewrite)
      subrule = nil
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      ebnf_suffix_ast = nil
      ebnf_root = nil
      begin
        # for error handling
        case (_la(1))
        when QUESTION
          tmp59_ast = nil
          tmp59_ast = self.attr_ast_factory.create(_lt(1))
          match(QUESTION)
          ebnf_root = self.attr_ast_factory.create(OPTIONAL, "?")
        when STAR
          tmp60_ast = nil
          tmp60_ast = self.attr_ast_factory.create(_lt(1))
          match(STAR)
          ebnf_root = self.attr_ast_factory.create(CLOSURE, "*")
        when PLUS
          tmp61_ast = nil
          tmp61_ast = self.attr_ast_factory.create(_lt(1))
          match(PLUS)
          ebnf_root = self.attr_ast_factory.create(POSITIVE_CLOSURE, "+")
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        save = @current_block_ast
        ebnf_root.set_line(elem_ast.get_line)
        ebnf_root.set_column(elem_ast.get_column)
        blk_root = self.attr_ast_factory.create(BLOCK, "BLOCK")
        @current_block_ast = blk_root
        eob = self.attr_ast_factory.create(EOB, "<end-of-block>")
        eob.set_line(elem_ast.get_line)
        eob.set_column(elem_ast.get_column)
        alt = self.attr_ast_factory.make((ASTArray.new(3)).add(self.attr_ast_factory.create(ALT, "ALT")).add(elem_ast).add(self.attr_ast_factory.create(EOA, "<end-of-alt>")))
        if (!in_rewrite)
          prefix_with_syn_pred(alt)
        end
        subrule = self.attr_ast_factory.make((ASTArray.new(2)).add(ebnf_root).add(self.attr_ast_factory.make((ASTArray.new(3)).add(blk_root).add(alt).add(eob))))
        @current_block_ast = save
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_34)
      end
      self.attr_return_ast = ebnf_suffix_ast
      return subrule
    end
    
    typesig { [] }
    # matches ENBF blocks (and sets via block rule)
    def ebnf
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      ebnf_ast = nil
      b_ast = nil
      line = _lt(1).get_line
      col = _lt(1).get_column
      begin
        # for error handling
        block
        b_ast = self.attr_return_ast
        case (_la(1))
        when QUESTION
          tmp62_ast = nil
          tmp62_ast = self.attr_ast_factory.create(_lt(1))
          match(QUESTION)
          ebnf_ast = current_ast.attr_root
          ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(OPTIONAL, "?")).add(b_ast))
          current_ast.attr_root = ebnf_ast
          current_ast.attr_child = !(ebnf_ast).nil? && !(ebnf_ast.get_first_child).nil? ? ebnf_ast.get_first_child : ebnf_ast
          current_ast.advance_child_to_end
        when STAR
          tmp63_ast = nil
          tmp63_ast = self.attr_ast_factory.create(_lt(1))
          match(STAR)
          ebnf_ast = current_ast.attr_root
          ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(CLOSURE, "*")).add(b_ast))
          current_ast.attr_root = ebnf_ast
          current_ast.attr_child = !(ebnf_ast).nil? && !(ebnf_ast.get_first_child).nil? ? ebnf_ast.get_first_child : ebnf_ast
          current_ast.advance_child_to_end
        when PLUS
          tmp64_ast = nil
          tmp64_ast = self.attr_ast_factory.create(_lt(1))
          match(PLUS)
          ebnf_ast = current_ast.attr_root
          ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(POSITIVE_CLOSURE, "+")).add(b_ast))
          current_ast.attr_root = ebnf_ast
          current_ast.attr_child = !(ebnf_ast).nil? && !(ebnf_ast.get_first_child).nil? ? ebnf_ast.get_first_child : ebnf_ast
          current_ast.advance_child_to_end
        when IMPLIES
          match(IMPLIES)
          ebnf_ast = current_ast.attr_root
          if ((@gtype).equal?(COMBINED_GRAMMAR) && Character.is_upper_case(@current_rule_name.char_at(0)))
            # ignore for lexer rules in combined
            ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(SYNPRED, "=>")).add(b_ast))
          else
            # create manually specified (...)=> predicate;
            # convert to sempred
            ebnf_ast = create_syn_sem_pred_from_block(b_ast, SYN_SEMPRED)
          end
          current_ast.attr_root = ebnf_ast
          current_ast.attr_child = !(ebnf_ast).nil? && !(ebnf_ast.get_first_child).nil? ? ebnf_ast.get_first_child : ebnf_ast
          current_ast.advance_child_to_end
        when ROOT
          tmp66_ast = nil
          tmp66_ast = self.attr_ast_factory.create(_lt(1))
          match(ROOT)
          ebnf_ast = current_ast.attr_root
          ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(tmp66_ast).add(b_ast))
          current_ast.attr_root = ebnf_ast
          current_ast.attr_child = !(ebnf_ast).nil? && !(ebnf_ast.get_first_child).nil? ? ebnf_ast.get_first_child : ebnf_ast
          current_ast.advance_child_to_end
        when BANG
          tmp67_ast = nil
          tmp67_ast = self.attr_ast_factory.create(_lt(1))
          match(BANG)
          ebnf_ast = current_ast.attr_root
          ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(tmp67_ast).add(b_ast))
          current_ast.attr_root = ebnf_ast
          current_ast.attr_child = !(ebnf_ast).nil? && !(ebnf_ast.get_first_child).nil? ? ebnf_ast.get_first_child : ebnf_ast
          current_ast.advance_child_to_end
        when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, REWRITE
          ebnf_ast = current_ast.attr_root
          ebnf_ast = b_ast
          current_ast.attr_root = ebnf_ast
          current_ast.attr_child = !(ebnf_ast).nil? && !(ebnf_ast.get_first_child).nil? ? ebnf_ast.get_first_child : ebnf_ast
          current_ast.advance_child_to_end
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        ebnf_ast = current_ast.attr_root
        ebnf_ast.set_line(line)
        ebnf_ast.set_column(col)
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_25)
      end
      self.attr_return_ast = ebnf_ast
    end
    
    typesig { [] }
    def tree
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      tree_ast = nil
      begin
        # for error handling
        tmp68_ast = nil
        tmp68_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp68_ast)
        match(TREE_BEGIN)
        element
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        _cnt97 = 0
        begin
          if ((_tokenSet_22.member(_la(1))))
            element
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            if (_cnt97 >= 1)
              break
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
          ((_cnt97 += 1) - 1)
        end while (true)
        match(RPAREN)
        tree_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_25)
      end
      self.attr_return_ast = tree_ast
    end
    
    typesig { [] }
    def range
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      range_ast = nil
      c1 = nil
      c1_ast = nil
      c2 = nil
      c2_ast = nil
      subrule = nil
      root = nil
      begin
        # for error handling
        c1 = _lt(1)
        c1_ast = self.attr_ast_factory.create(c1)
        match(CHAR_LITERAL)
        tmp70_ast = nil
        tmp70_ast = self.attr_ast_factory.create(_lt(1))
        match(RANGE)
        c2 = _lt(1)
        c2_ast = self.attr_ast_factory.create(c2)
        match(CHAR_LITERAL)
        range_ast = current_ast.attr_root
        r = self.attr_ast_factory.create(CHAR_RANGE, "..")
        r.set_line(c1.get_line)
        r.set_column(c1.get_column)
        range_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(r).add(c1_ast).add(c2_ast))
        root = range_ast
        current_ast.attr_root = range_ast
        current_ast.attr_child = !(range_ast).nil? && !(range_ast.get_first_child).nil? ? range_ast.get_first_child : range_ast
        current_ast.advance_child_to_end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_35)
      end
      self.attr_return_ast = range_ast
    end
    
    typesig { [] }
    def terminal
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      terminal_ast = nil
      cl = nil
      cl_ast = nil
      tr = nil
      tr_ast = nil
      sl = nil
      sl_ast = nil
      wi = nil
      wi_ast = nil
      ebnf_root = nil
      subrule = nil
      begin
        # for error handling
        case (_la(1))
        when CHAR_LITERAL
          cl = _lt(1)
          cl_ast = self.attr_ast_factory.create(cl)
          self.attr_ast_factory.make_astroot(current_ast, cl_ast)
          match(CHAR_LITERAL)
          case (_la(1))
          when OPEN_ELEMENT_OPTION
            element_options(cl_ast)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, BANG, LPAREN, OR, RPAREN, SEMPRED, ROOT, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          case (_la(1))
          when ROOT
            tmp71_ast = nil
            tmp71_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp71_ast)
            match(ROOT)
          when BANG
            tmp72_ast = nil
            tmp72_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp72_ast)
            match(BANG)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          terminal_ast = current_ast.attr_root
        when TOKEN_REF
          tr = _lt(1)
          tr_ast = self.attr_ast_factory.create(tr)
          self.attr_ast_factory.make_astroot(current_ast, tr_ast)
          match(TOKEN_REF)
          case (_la(1))
          when OPEN_ELEMENT_OPTION
            element_options(tr_ast)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, BANG, ARG_ACTION, LPAREN, OR, RPAREN, SEMPRED, ROOT, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          case (_la(1))
          when ARG_ACTION
            tmp73_ast = nil
            tmp73_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.add_astchild(current_ast, tmp73_ast)
            match(ARG_ACTION)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, BANG, LPAREN, OR, RPAREN, SEMPRED, ROOT, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          case (_la(1))
          when ROOT
            tmp74_ast = nil
            tmp74_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp74_ast)
            match(ROOT)
          when BANG
            tmp75_ast = nil
            tmp75_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp75_ast)
            match(BANG)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          terminal_ast = current_ast.attr_root
        when STRING_LITERAL
          sl = _lt(1)
          sl_ast = self.attr_ast_factory.create(sl)
          self.attr_ast_factory.make_astroot(current_ast, sl_ast)
          match(STRING_LITERAL)
          case (_la(1))
          when OPEN_ELEMENT_OPTION
            element_options(sl_ast)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, BANG, LPAREN, OR, RPAREN, SEMPRED, ROOT, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          case (_la(1))
          when ROOT
            tmp76_ast = nil
            tmp76_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp76_ast)
            match(ROOT)
          when BANG
            tmp77_ast = nil
            tmp77_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp77_ast)
            match(BANG)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          terminal_ast = current_ast.attr_root
        when WILDCARD
          wi = _lt(1)
          wi_ast = self.attr_ast_factory.create(wi)
          self.attr_ast_factory.add_astchild(current_ast, wi_ast)
          match(WILDCARD)
          case (_la(1))
          when ROOT
            tmp78_ast = nil
            tmp78_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp78_ast)
            match(ROOT)
          when BANG
            tmp79_ast = nil
            tmp79_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp79_ast)
            match(BANG)
          when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          terminal_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_33)
      end
      self.attr_return_ast = terminal_ast
    end
    
    typesig { [] }
    def ruleref
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      ruleref_ast = nil
      rr = nil
      rr_ast = nil
      begin
        # for error handling
        rr = _lt(1)
        rr_ast = self.attr_ast_factory.create(rr)
        self.attr_ast_factory.make_astroot(current_ast, rr_ast)
        match(RULE_REF)
        case (_la(1))
        when ARG_ACTION
          tmp80_ast = nil
          tmp80_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.add_astchild(current_ast, tmp80_ast)
          match(ARG_ACTION)
        when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, BANG, LPAREN, OR, RPAREN, SEMPRED, ROOT, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        case (_la(1))
        when ROOT
          tmp81_ast = nil
          tmp81_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.make_astroot(current_ast, tmp81_ast)
          match(ROOT)
        when BANG
          tmp82_ast = nil
          tmp82_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.make_astroot(current_ast, tmp82_ast)
          match(BANG)
        when FORCED_ACTION, ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, SEMPRED, WILDCARD, RULE_REF, NOT, TREE_BEGIN, QUESTION, PLUS, REWRITE
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        ruleref_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_33)
      end
      self.attr_return_ast = ruleref_ast
    end
    
    typesig { [] }
    def not_set
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      not_set_ast = nil
      n = nil
      n_ast = nil
      line = _lt(1).get_line
      col = _lt(1).get_column
      subrule = nil
      begin
        # for error handling
        n = _lt(1)
        n_ast = self.attr_ast_factory.create(n)
        self.attr_ast_factory.make_astroot(current_ast, n_ast)
        match(NOT)
        case (_la(1))
        when STRING_LITERAL, CHAR_LITERAL, TOKEN_REF
          not_terminal
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        when LPAREN
          block
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        not_set_ast = current_ast.attr_root
        not_set_ast.set_line(line)
        not_set_ast.set_column(col)
        not_set_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_35)
      end
      self.attr_return_ast = not_set_ast
    end
    
    typesig { [] }
    def not_terminal
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      not_terminal_ast = nil
      cl = nil
      cl_ast = nil
      tr = nil
      tr_ast = nil
      begin
        # for error handling
        case (_la(1))
        when CHAR_LITERAL
          cl = _lt(1)
          cl_ast = self.attr_ast_factory.create(cl)
          self.attr_ast_factory.add_astchild(current_ast, cl_ast)
          match(CHAR_LITERAL)
          not_terminal_ast = current_ast.attr_root
        when TOKEN_REF
          tr = _lt(1)
          tr_ast = self.attr_ast_factory.create(tr)
          self.attr_ast_factory.add_astchild(current_ast, tr_ast)
          match(TOKEN_REF)
          not_terminal_ast = current_ast.attr_root
        when STRING_LITERAL
          tmp83_ast = nil
          tmp83_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.add_astchild(current_ast, tmp83_ast)
          match(STRING_LITERAL)
          not_terminal_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_35)
      end
      self.attr_return_ast = not_terminal_ast
    end
    
    typesig { [GrammarAST] }
    def element_options(terminal_ast)
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      element_options_ast = nil
      begin
        # for error handling
        if (((_la(1)).equal?(OPEN_ELEMENT_OPTION)) && ((_la(2)).equal?(TOKEN_REF) || (_la(2)).equal?(RULE_REF)) && ((_la(3)).equal?(WILDCARD) || (_la(3)).equal?(CLOSE_ELEMENT_OPTION)))
          tmp84_ast = nil
          tmp84_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.make_astroot(current_ast, tmp84_ast)
          match(OPEN_ELEMENT_OPTION)
          default_node_option(terminal_ast)
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          match(CLOSE_ELEMENT_OPTION)
          element_options_ast = current_ast.attr_root
        else
          if (((_la(1)).equal?(OPEN_ELEMENT_OPTION)) && ((_la(2)).equal?(TOKEN_REF) || (_la(2)).equal?(RULE_REF)) && ((_la(3)).equal?(ASSIGN)))
            tmp86_ast = nil
            tmp86_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.make_astroot(current_ast, tmp86_ast)
            match(OPEN_ELEMENT_OPTION)
            element_option(terminal_ast)
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            begin
              if (((_la(1)).equal?(SEMI)))
                match(SEMI)
                element_option(terminal_ast)
                self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              else
                break
              end
            end while (true)
            match(CLOSE_ELEMENT_OPTION)
            element_options_ast = current_ast.attr_root
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_36)
      end
      self.attr_return_ast = element_options_ast
    end
    
    typesig { [GrammarAST] }
    def default_node_option(terminal_ast)
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      default_node_option_ast = nil
      i_ast = nil
      i2_ast = nil
      buf = StringBuffer.new
      begin
        # for error handling
        id
        i_ast = self.attr_return_ast
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        buf.append(i_ast.get_text)
        begin
          if (((_la(1)).equal?(WILDCARD)))
            tmp89_ast = nil
            tmp89_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.add_astchild(current_ast, tmp89_ast)
            match(WILDCARD)
            id
            i2_ast = self.attr_return_ast
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            buf.append("." + (i2_ast.get_text).to_s)
          else
            break
          end
        end while (true)
        terminal_ast.set_terminal_option(@grammar, Grammar.attr_default_token_option, buf.to_s)
        default_node_option_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_37)
      end
      self.attr_return_ast = default_node_option_ast
    end
    
    typesig { [GrammarAST] }
    def element_option(terminal_ast)
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      element_option_ast = nil
      a_ast = nil
      b_ast = nil
      s = nil
      s_ast = nil
      begin
        # for error handling
        id
        a_ast = self.attr_return_ast
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        tmp90_ast = nil
        tmp90_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp90_ast)
        match(ASSIGN)
        case (_la(1))
        when TOKEN_REF, RULE_REF
          id
          b_ast = self.attr_return_ast
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        when STRING_LITERAL
          s = _lt(1)
          s_ast = self.attr_ast_factory.create(s)
          self.attr_ast_factory.add_astchild(current_ast, s_ast)
          match(STRING_LITERAL)
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        v = (!(b_ast).nil?) ? b_ast.get_text : s_ast.get_text
        terminal_ast.set_terminal_option(@grammar, a_ast.get_text, v)
        element_option_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_38)
      end
      self.attr_return_ast = element_option_ast
    end
    
    typesig { [] }
    def rewrite_alternative
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_alternative_ast = nil
      eoa = self.attr_ast_factory.create(EOA, "<end-of-alt>")
      alt_root = self.attr_ast_factory.create(ALT, "ALT")
      alt_root.set_line(_lt(1).get_line)
      alt_root.set_column(_lt(1).get_column)
      begin
        # for error handling
        if (((_tokenSet_39.member(_la(1))) && (_tokenSet_40.member(_la(2))) && (_tokenSet_41.member(_la(3)))) && (@grammar.build_template))
          rewrite_template
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          rewrite_alternative_ast = current_ast.attr_root
        else
          if (((_tokenSet_42.member(_la(1))) && (_tokenSet_43.member(_la(2))) && (_tokenSet_44.member(_la(3)))) && (@grammar.build_ast))
            _cnt131 = 0
            begin
              if ((_tokenSet_42.member(_la(1))))
                rewrite_element
                self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              else
                if (_cnt131 >= 1)
                  break
                else
                  raise NoViableAltException.new(_lt(1), get_filename)
                end
              end
              ((_cnt131 += 1) - 1)
            end while (true)
            rewrite_alternative_ast = current_ast.attr_root
            if ((rewrite_alternative_ast).nil?)
              rewrite_alternative_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(alt_root).add(self.attr_ast_factory.create(EPSILON, "epsilon")).add(eoa))
            else
              rewrite_alternative_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(alt_root).add(rewrite_alternative_ast).add(eoa))
            end
            current_ast.attr_root = rewrite_alternative_ast
            current_ast.attr_child = !(rewrite_alternative_ast).nil? && !(rewrite_alternative_ast.get_first_child).nil? ? rewrite_alternative_ast.get_first_child : rewrite_alternative_ast
            current_ast.advance_child_to_end
            rewrite_alternative_ast = current_ast.attr_root
          else
            if ((_tokenSet_23.member(_la(1))))
              rewrite_alternative_ast = current_ast.attr_root
              rewrite_alternative_ast = self.attr_ast_factory.make((ASTArray.new(3)).add(alt_root).add(self.attr_ast_factory.create(EPSILON, "epsilon")).add(eoa))
              current_ast.attr_root = rewrite_alternative_ast
              current_ast.attr_child = !(rewrite_alternative_ast).nil? && !(rewrite_alternative_ast.get_first_child).nil? ? rewrite_alternative_ast.get_first_child : rewrite_alternative_ast
              current_ast.advance_child_to_end
              rewrite_alternative_ast = current_ast.attr_root
            else
              if ((((_la(1)).equal?(ETC))) && (@grammar.build_ast))
                tmp91_ast = nil
                tmp91_ast = self.attr_ast_factory.create(_lt(1))
                self.attr_ast_factory.add_astchild(current_ast, tmp91_ast)
                match(ETC)
                rewrite_alternative_ast = current_ast.attr_root
              else
                raise NoViableAltException.new(_lt(1), get_filename)
              end
            end
          end
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_23)
      end
      self.attr_return_ast = rewrite_alternative_ast
    end
    
    typesig { [] }
    def rewrite_block
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_block_ast = nil
      lp = nil
      lp_ast = nil
      begin
        # for error handling
        lp = _lt(1)
        lp_ast = self.attr_ast_factory.create(lp)
        self.attr_ast_factory.make_astroot(current_ast, lp_ast)
        match(LPAREN)
        lp_ast.set_type(BLOCK)
        lp_ast.set_text("BLOCK")
        rewrite_alternative
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        match(RPAREN)
        rewrite_block_ast = current_ast.attr_root
        eob = self.attr_ast_factory.create(EOB, "<end-of-block>")
        eob.set_line(lp.get_line)
        eob.set_column(lp.get_column)
        rewrite_block_ast.add_child(eob)
        rewrite_block_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_45)
      end
      self.attr_return_ast = rewrite_block_ast
    end
    
    typesig { [] }
    # Build a tree for a template rewrite:
    # ^(TEMPLATE (ID|ACTION) ^(ARGLIST ^(ARG ID ACTION) ...) )
    # where ARGLIST is always there even if no args exist.
    # ID can be "template" keyword.  If first child is ACTION then it's
    # an indirect template ref
    # 
    # -> foo(a={...}, b={...})
    # -> ({string-e})(a={...}, b={...})  // e evaluates to template name
    # -> {%{$ID.text}} // create literal template from string (done in ActionTranslator)
    # -> {st-expr} // st-expr evaluates to ST
    def rewrite_template
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_template_ast = nil
      st = nil
      begin
        # for error handling
        case (_la(1))
        when LPAREN
          rewrite_indirect_template_head
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          rewrite_template_ast = current_ast.attr_root
        when ACTION
          tmp93_ast = nil
          tmp93_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.add_astchild(current_ast, tmp93_ast)
          match(ACTION)
          rewrite_template_ast = current_ast.attr_root
        else
          if ((((_la(1)).equal?(TOKEN_REF) || (_la(1)).equal?(RULE_REF)) && ((_la(2)).equal?(LPAREN)) && ((_la(3)).equal?(TOKEN_REF) || (_la(3)).equal?(RPAREN) || (_la(3)).equal?(RULE_REF))) && ((_lt(1).get_text == "template")))
            rewrite_template_head
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            st = _lt(1)
            case (_la(1))
            when DOUBLE_QUOTE_STRING_LITERAL
              match(DOUBLE_QUOTE_STRING_LITERAL)
            when DOUBLE_ANGLE_STRING_LITERAL
              match(DOUBLE_ANGLE_STRING_LITERAL)
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
            rewrite_template_ast = current_ast.attr_root
            rewrite_template_ast.add_child(self.attr_ast_factory.create(st))
            rewrite_template_ast = current_ast.attr_root
          else
            if (((_la(1)).equal?(TOKEN_REF) || (_la(1)).equal?(RULE_REF)) && ((_la(2)).equal?(LPAREN)) && ((_la(3)).equal?(TOKEN_REF) || (_la(3)).equal?(RPAREN) || (_la(3)).equal?(RULE_REF)))
              rewrite_template_head
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
              rewrite_template_ast = current_ast.attr_root
            else
              raise NoViableAltException.new(_lt(1), get_filename)
            end
          end
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_23)
      end
      self.attr_return_ast = rewrite_template_ast
    end
    
    typesig { [] }
    def rewrite_element
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_element_ast = nil
      t_ast = nil
      tr_ast = nil
      subrule = nil
      begin
        # for error handling
        case (_la(1))
        when ACTION, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, RULE_REF, DOLLAR
          rewrite_atom
          t_ast = self.attr_return_ast
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          case (_la(1))
          when STAR, QUESTION, PLUS
            subrule = ebnf_suffix(t_ast, true)
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            rewrite_element_ast = current_ast.attr_root
            rewrite_element_ast = subrule
            current_ast.attr_root = rewrite_element_ast
            current_ast.attr_child = !(rewrite_element_ast).nil? && !(rewrite_element_ast.get_first_child).nil? ? rewrite_element_ast.get_first_child : rewrite_element_ast
            current_ast.advance_child_to_end
          when ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, LPAREN, OR, RPAREN, RULE_REF, TREE_BEGIN, REWRITE, DOLLAR
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          rewrite_element_ast = current_ast.attr_root
        when LPAREN
          rewrite_ebnf
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          rewrite_element_ast = current_ast.attr_root
        when TREE_BEGIN
          rewrite_tree
          tr_ast = self.attr_return_ast
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          case (_la(1))
          when STAR, QUESTION, PLUS
            subrule = ebnf_suffix(tr_ast, true)
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            rewrite_element_ast = current_ast.attr_root
            rewrite_element_ast = subrule
            current_ast.attr_root = rewrite_element_ast
            current_ast.attr_child = !(rewrite_element_ast).nil? && !(rewrite_element_ast.get_first_child).nil? ? rewrite_element_ast.get_first_child : rewrite_element_ast
            current_ast.advance_child_to_end
          when ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, LPAREN, OR, RPAREN, RULE_REF, TREE_BEGIN, REWRITE, DOLLAR
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          rewrite_element_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_46)
      end
      self.attr_return_ast = rewrite_element_ast
    end
    
    typesig { [] }
    def rewrite_atom
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_atom_ast = nil
      tr = nil
      tr_ast = nil
      rr = nil
      rr_ast = nil
      cl = nil
      cl_ast = nil
      sl = nil
      sl_ast = nil
      d = nil
      d_ast = nil
      i_ast = nil
      subrule = nil
      begin
        # for error handling
        case (_la(1))
        when TOKEN_REF
          tr = _lt(1)
          tr_ast = self.attr_ast_factory.create(tr)
          self.attr_ast_factory.make_astroot(current_ast, tr_ast)
          match(TOKEN_REF)
          case (_la(1))
          when OPEN_ELEMENT_OPTION
            element_options(tr_ast)
          when ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, ARG_ACTION, LPAREN, OR, RPAREN, RULE_REF, TREE_BEGIN, QUESTION, PLUS, REWRITE, DOLLAR
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          case (_la(1))
          when ARG_ACTION
            tmp96_ast = nil
            tmp96_ast = self.attr_ast_factory.create(_lt(1))
            self.attr_ast_factory.add_astchild(current_ast, tmp96_ast)
            match(ARG_ACTION)
          when ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, RULE_REF, TREE_BEGIN, QUESTION, PLUS, REWRITE, DOLLAR
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          rewrite_atom_ast = current_ast.attr_root
        when RULE_REF
          rr = _lt(1)
          rr_ast = self.attr_ast_factory.create(rr)
          self.attr_ast_factory.add_astchild(current_ast, rr_ast)
          match(RULE_REF)
          rewrite_atom_ast = current_ast.attr_root
        when CHAR_LITERAL
          cl = _lt(1)
          cl_ast = self.attr_ast_factory.create(cl)
          self.attr_ast_factory.make_astroot(current_ast, cl_ast)
          match(CHAR_LITERAL)
          case (_la(1))
          when OPEN_ELEMENT_OPTION
            element_options(cl_ast)
          when ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, RULE_REF, TREE_BEGIN, QUESTION, PLUS, REWRITE, DOLLAR
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          rewrite_atom_ast = current_ast.attr_root
        when STRING_LITERAL
          sl = _lt(1)
          sl_ast = self.attr_ast_factory.create(sl)
          self.attr_ast_factory.make_astroot(current_ast, sl_ast)
          match(STRING_LITERAL)
          case (_la(1))
          when OPEN_ELEMENT_OPTION
            element_options(sl_ast)
          when ACTION, SEMI, STRING_LITERAL, CHAR_LITERAL, STAR, TOKEN_REF, LPAREN, OR, RPAREN, RULE_REF, TREE_BEGIN, QUESTION, PLUS, REWRITE, DOLLAR
          else
            raise NoViableAltException.new(_lt(1), get_filename)
          end
          rewrite_atom_ast = current_ast.attr_root
        when DOLLAR
          d = _lt(1)
          d_ast = self.attr_ast_factory.create(d)
          match(DOLLAR)
          id
          i_ast = self.attr_return_ast
          rewrite_atom_ast = current_ast.attr_root
          rewrite_atom_ast = self.attr_ast_factory.create(LABEL, i_ast.get_text)
          rewrite_atom_ast.set_line(d_ast.get_line)
          rewrite_atom_ast.set_column(d_ast.get_column)
          current_ast.attr_root = rewrite_atom_ast
          current_ast.attr_child = !(rewrite_atom_ast).nil? && !(rewrite_atom_ast.get_first_child).nil? ? rewrite_atom_ast.get_first_child : rewrite_atom_ast
          current_ast.advance_child_to_end
        when ACTION
          tmp97_ast = nil
          tmp97_ast = self.attr_ast_factory.create(_lt(1))
          self.attr_ast_factory.add_astchild(current_ast, tmp97_ast)
          match(ACTION)
          rewrite_atom_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_47)
      end
      self.attr_return_ast = rewrite_atom_ast
    end
    
    typesig { [] }
    def rewrite_ebnf
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_ebnf_ast = nil
      b_ast = nil
      line = _lt(1).get_line
      col = _lt(1).get_column
      begin
        # for error handling
        rewrite_block
        b_ast = self.attr_return_ast
        case (_la(1))
        when QUESTION
          tmp98_ast = nil
          tmp98_ast = self.attr_ast_factory.create(_lt(1))
          match(QUESTION)
          rewrite_ebnf_ast = current_ast.attr_root
          rewrite_ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(OPTIONAL, "?")).add(b_ast))
          current_ast.attr_root = rewrite_ebnf_ast
          current_ast.attr_child = !(rewrite_ebnf_ast).nil? && !(rewrite_ebnf_ast.get_first_child).nil? ? rewrite_ebnf_ast.get_first_child : rewrite_ebnf_ast
          current_ast.advance_child_to_end
        when STAR
          tmp99_ast = nil
          tmp99_ast = self.attr_ast_factory.create(_lt(1))
          match(STAR)
          rewrite_ebnf_ast = current_ast.attr_root
          rewrite_ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(CLOSURE, "*")).add(b_ast))
          current_ast.attr_root = rewrite_ebnf_ast
          current_ast.attr_child = !(rewrite_ebnf_ast).nil? && !(rewrite_ebnf_ast.get_first_child).nil? ? rewrite_ebnf_ast.get_first_child : rewrite_ebnf_ast
          current_ast.advance_child_to_end
        when PLUS
          tmp100_ast = nil
          tmp100_ast = self.attr_ast_factory.create(_lt(1))
          match(PLUS)
          rewrite_ebnf_ast = current_ast.attr_root
          rewrite_ebnf_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(POSITIVE_CLOSURE, "+")).add(b_ast))
          current_ast.attr_root = rewrite_ebnf_ast
          current_ast.attr_child = !(rewrite_ebnf_ast).nil? && !(rewrite_ebnf_ast.get_first_child).nil? ? rewrite_ebnf_ast.get_first_child : rewrite_ebnf_ast
          current_ast.advance_child_to_end
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
        rewrite_ebnf_ast = current_ast.attr_root
        rewrite_ebnf_ast.set_line(line)
        rewrite_ebnf_ast.set_column(col)
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_46)
      end
      self.attr_return_ast = rewrite_ebnf_ast
    end
    
    typesig { [] }
    def rewrite_tree
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_tree_ast = nil
      begin
        # for error handling
        tmp101_ast = nil
        tmp101_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.make_astroot(current_ast, tmp101_ast)
        match(TREE_BEGIN)
        rewrite_atom
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        begin
          if ((_tokenSet_42.member(_la(1))))
            rewrite_element
            self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          else
            break
          end
        end while (true)
        match(RPAREN)
        rewrite_tree_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_47)
      end
      self.attr_return_ast = rewrite_tree_ast
    end
    
    typesig { [] }
    # -> foo(a={...}, ...)
    def rewrite_template_head
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_template_head_ast = nil
      lp = nil
      lp_ast = nil
      begin
        # for error handling
        id
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        lp = _lt(1)
        lp_ast = self.attr_ast_factory.create(lp)
        self.attr_ast_factory.make_astroot(current_ast, lp_ast)
        match(LPAREN)
        lp_ast.set_type(TEMPLATE)
        lp_ast.set_text("TEMPLATE")
        rewrite_template_args
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        match(RPAREN)
        rewrite_template_head_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_48)
      end
      self.attr_return_ast = rewrite_template_head_ast
    end
    
    typesig { [] }
    # -> ({expr})(a={...}, ...)
    def rewrite_indirect_template_head
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_indirect_template_head_ast = nil
      lp = nil
      lp_ast = nil
      begin
        # for error handling
        lp = _lt(1)
        lp_ast = self.attr_ast_factory.create(lp)
        self.attr_ast_factory.make_astroot(current_ast, lp_ast)
        match(LPAREN)
        lp_ast.set_type(TEMPLATE)
        lp_ast.set_text("TEMPLATE")
        tmp104_ast = nil
        tmp104_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp104_ast)
        match(ACTION)
        match(RPAREN)
        match(LPAREN)
        rewrite_template_args
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        match(RPAREN)
        rewrite_indirect_template_head_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_23)
      end
      self.attr_return_ast = rewrite_indirect_template_head_ast
    end
    
    typesig { [] }
    def rewrite_template_args
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_template_args_ast = nil
      begin
        # for error handling
        case (_la(1))
        when TOKEN_REF, RULE_REF
          rewrite_template_arg
          self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
          begin
            if (((_la(1)).equal?(COMMA)))
              match(COMMA)
              rewrite_template_arg
              self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
            else
              break
            end
          end while (true)
          rewrite_template_args_ast = current_ast.attr_root
          rewrite_template_args_ast = self.attr_ast_factory.make((ASTArray.new(2)).add(self.attr_ast_factory.create(ARGLIST, "ARGLIST")).add(rewrite_template_args_ast))
          current_ast.attr_root = rewrite_template_args_ast
          current_ast.attr_child = !(rewrite_template_args_ast).nil? && !(rewrite_template_args_ast.get_first_child).nil? ? rewrite_template_args_ast.get_first_child : rewrite_template_args_ast
          current_ast.advance_child_to_end
          rewrite_template_args_ast = current_ast.attr_root
        when RPAREN
          rewrite_template_args_ast = current_ast.attr_root
          rewrite_template_args_ast = self.attr_ast_factory.create(ARGLIST, "ARGLIST")
          current_ast.attr_root = rewrite_template_args_ast
          current_ast.attr_child = !(rewrite_template_args_ast).nil? && !(rewrite_template_args_ast.get_first_child).nil? ? rewrite_template_args_ast.get_first_child : rewrite_template_args_ast
          current_ast.advance_child_to_end
          rewrite_template_args_ast = current_ast.attr_root
        else
          raise NoViableAltException.new(_lt(1), get_filename)
        end
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_49)
      end
      self.attr_return_ast = rewrite_template_args_ast
    end
    
    typesig { [] }
    def rewrite_template_arg
      self.attr_return_ast = nil
      current_ast = ASTPair.new
      rewrite_template_arg_ast = nil
      a = nil
      a_ast = nil
      begin
        # for error handling
        id
        self.attr_ast_factory.add_astchild(current_ast, self.attr_return_ast)
        a = _lt(1)
        a_ast = self.attr_ast_factory.create(a)
        self.attr_ast_factory.make_astroot(current_ast, a_ast)
        match(ASSIGN)
        a_ast.set_type(ARG)
        a_ast.set_text("ARG")
        tmp109_ast = nil
        tmp109_ast = self.attr_ast_factory.create(_lt(1))
        self.attr_ast_factory.add_astchild(current_ast, tmp109_ast)
        match(ACTION)
        rewrite_template_arg_ast = current_ast.attr_root
      rescue RecognitionException => ex
        report_error(ex)
        recover(ex, _tokenSet_50)
      end
      self.attr_return_ast = rewrite_template_arg_ast
    end
    
    class_module.module_eval {
      const_set_lazy(:_tokenNames) { Array.typed(String).new(["<0>", "EOF", "<2>", "NULL_TREE_LOOKAHEAD", "\"options\"", "\"tokens\"", "\"parser\"", "LEXER", "RULE", "BLOCK", "OPTIONAL", "CLOSURE", "POSITIVE_CLOSURE", "SYNPRED", "RANGE", "CHAR_RANGE", "EPSILON", "ALT", "EOR", "EOB", "EOA", "ID", "ARG", "ARGLIST", "RET", "LEXER_GRAMMAR", "PARSER_GRAMMAR", "TREE_GRAMMAR", "COMBINED_GRAMMAR", "INITACTION", "FORCED_ACTION", "LABEL", "TEMPLATE", "\"scope\"", "\"import\"", "GATED_SEMPRED", "SYN_SEMPRED", "BACKTRACK_SEMPRED", "\"fragment\"", "DOT", "ACTION", "DOC_COMMENT", "SEMI", "\"lexer\"", "\"tree\"", "\"grammar\"", "AMPERSAND", "COLON", "RCURLY", "ASSIGN", "STRING_LITERAL", "CHAR_LITERAL", "INT", "STAR", "COMMA", "TOKEN_REF", "\"protected\"", "\"public\"", "\"private\"", "BANG", "ARG_ACTION", "\"returns\"", "\"throws\"", "LPAREN", "OR", "RPAREN", "\"catch\"", "\"finally\"", "PLUS_ASSIGN", "SEMPRED", "IMPLIES", "ROOT", "WILDCARD", "RULE_REF", "NOT", "TREE_BEGIN", "QUESTION", "PLUS", "OPEN_ELEMENT_OPTION", "CLOSE_ELEMENT_OPTION", "REWRITE", "ETC", "DOLLAR", "DOUBLE_QUOTE_STRING_LITERAL", "DOUBLE_ANGLE_STRING_LITERAL", "WS", "COMMENT", "SL_COMMENT", "ML_COMMENT", "STRAY_BRACKET", "ESC", "DIGIT", "XDIGIT", "NESTED_ARG_ACTION", "NESTED_ACTION", "ACTION_CHAR_LITERAL", "ACTION_STRING_LITERAL", "ACTION_ESC", "WS_LOOP", "INTERNAL_RULE_REF", "WS_OPT", "SRC"]) }
      const_attr_reader  :_tokenNames
    }
    
    typesig { [] }
    def build_token_type_astclass_map
      self.attr_token_type_to_astclass_map = nil
    end
    
    class_module.module_eval {
      typesig { [] }
      def mk_token_set_0
        data = Array.typed(::Java::Long).new([2, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_0) { BitSet.new(mk_token_set_0) }
      const_attr_reader  :_tokenSet_0
      
      typesig { [] }
      def mk_token_set_1
        data = Array.typed(::Java::Long).new([36028797018963968, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_1) { BitSet.new(mk_token_set_1) }
      const_attr_reader  :_tokenSet_1
      
      typesig { [] }
      def mk_token_set_2
        data = Array.typed(::Java::Long).new([-509253095465680880, 375571, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_2) { BitSet.new(mk_token_set_2) }
      const_attr_reader  :_tokenSet_2
      
      typesig { [] }
      def mk_token_set_3
        data = Array.typed(::Java::Long).new([540645561187958816, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_3) { BitSet.new(mk_token_set_3) }
      const_attr_reader  :_tokenSet_3
      
      typesig { [] }
      def mk_token_set_4
        data = Array.typed(::Java::Long).new([540504806519734304, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_4) { BitSet.new(mk_token_set_4) }
      const_attr_reader  :_tokenSet_4
      
      typesig { [] }
      def mk_token_set_5
        data = Array.typed(::Java::Long).new([540504806519734272, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_5) { BitSet.new(mk_token_set_5) }
      const_attr_reader  :_tokenSet_5
      
      typesig { [] }
      def mk_token_set_6
        data = Array.typed(::Java::Long).new([540504797929799680, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_6) { BitSet.new(mk_token_set_6) }
      const_attr_reader  :_tokenSet_6
      
      typesig { [] }
      def mk_token_set_7
        data = Array.typed(::Java::Long).new([540434429185622016, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_7) { BitSet.new(mk_token_set_7) }
      const_attr_reader  :_tokenSet_7
      
      typesig { [] }
      def mk_token_set_8
        data = Array.typed(::Java::Long).new([36037593111986240, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_8) { BitSet.new(mk_token_set_8) }
      const_attr_reader  :_tokenSet_8
      
      typesig { [] }
      def mk_token_set_9
        data = Array.typed(::Java::Long).new([140737488355328, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_9) { BitSet.new(mk_token_set_9) }
      const_attr_reader  :_tokenSet_9
      
      typesig { [] }
      def mk_token_set_10
        data = Array.typed(::Java::Long).new([4398046511104, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_10) { BitSet.new(mk_token_set_10) }
      const_attr_reader  :_tokenSet_10
      
      typesig { [] }
      def mk_token_set_11
        data = Array.typed(::Java::Long).new([18018796555993088, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_11) { BitSet.new(mk_token_set_11) }
      const_attr_reader  :_tokenSet_11
      
      typesig { [] }
      def mk_token_set_12
        data = Array.typed(::Java::Long).new([36310271995674624, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_12) { BitSet.new(mk_token_set_12) }
      const_attr_reader  :_tokenSet_12
      
      typesig { [] }
      def mk_token_set_13
        data = Array.typed(::Java::Long).new([540434429185622018, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_13) { BitSet.new(mk_token_set_13) }
      const_attr_reader  :_tokenSet_13
      
      typesig { [] }
      def mk_token_set_14
        data = Array.typed(::Java::Long).new([211114822467600, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_14) { BitSet.new(mk_token_set_14) }
      const_attr_reader  :_tokenSet_14
      
      typesig { [] }
      def mk_token_set_15
        data = Array.typed(::Java::Long).new([-9183960041483403264, 69409, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_15) { BitSet.new(mk_token_set_15) }
      const_attr_reader  :_tokenSet_15
      
      typesig { [] }
      def mk_token_set_16
        data = Array.typed(::Java::Long).new([-6922376498456281070, 491519, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_16) { BitSet.new(mk_token_set_16) }
      const_attr_reader  :_tokenSet_16
      
      typesig { [] }
      def mk_token_set_17
        data = Array.typed(::Java::Long).new([211106232532992, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_17) { BitSet.new(mk_token_set_17) }
      const_attr_reader  :_tokenSet_17
      
      typesig { [] }
      def mk_token_set_18
        data = Array.typed(::Java::Long).new([-9183964439529914368, 69411, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_18) { BitSet.new(mk_token_set_18) }
      const_attr_reader  :_tokenSet_18
      
      typesig { [] }
      def mk_token_set_19
        data = Array.typed(::Java::Long).new([-7444796529132421104, 491507, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_19) { BitSet.new(mk_token_set_19) }
      const_attr_reader  :_tokenSet_19
      
      typesig { [] }
      def mk_token_set_20
        data = Array.typed(::Java::Long).new([-6940390896965763054, 491519, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_20) { BitSet.new(mk_token_set_20) }
      const_attr_reader  :_tokenSet_20
      
      typesig { [] }
      def mk_token_set_21
        data = Array.typed(::Java::Long).new([-8598492089925238784, 81891, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_21) { BitSet.new(mk_token_set_21) }
      const_attr_reader  :_tokenSet_21
      
      typesig { [] }
      def mk_token_set_22
        data = Array.typed(::Java::Long).new([-9183964439529914368, 3872, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_22) { BitSet.new(mk_token_set_22) }
      const_attr_reader  :_tokenSet_22
      
      typesig { [] }
      def mk_token_set_23
        data = Array.typed(::Java::Long).new([4398046511104, 65539, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_23) { BitSet.new(mk_token_set_23) }
      const_attr_reader  :_tokenSet_23
      
      typesig { [] }
      def mk_token_set_24
        data = Array.typed(::Java::Long).new([4398046511104, 3, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_24) { BitSet.new(mk_token_set_24) }
      const_attr_reader  :_tokenSet_24
      
      typesig { [] }
      def mk_token_set_25
        data = Array.typed(::Java::Long).new([-9183960041483403264, 69411, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_25) { BitSet.new(mk_token_set_25) }
      const_attr_reader  :_tokenSet_25
      
      typesig { [] }
      def mk_token_set_26
        data = Array.typed(::Java::Long).new([540434429185622018, 524, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_26) { BitSet.new(mk_token_set_26) }
      const_attr_reader  :_tokenSet_26
      
      typesig { [] }
      def mk_token_set_27
        data = Array.typed(::Java::Long).new([39406496739491840, 1792, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_27) { BitSet.new(mk_token_set_27) }
      const_attr_reader  :_tokenSet_27
      
      typesig { [] }
      def mk_token_set_28
        data = Array.typed(::Java::Long).new([-7445570585318375424, 98211, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_28) { BitSet.new(mk_token_set_28) }
      const_attr_reader  :_tokenSet_28
      
      typesig { [] }
      def mk_token_set_29
        data = Array.typed(::Java::Long).new([39406496739491840, 768, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_29) { BitSet.new(mk_token_set_29) }
      const_attr_reader  :_tokenSet_29
      
      typesig { [] }
      def mk_token_set_30
        data = Array.typed(::Java::Long).new([-7445570585318391808, 98211, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_30) { BitSet.new(mk_token_set_30) }
      const_attr_reader  :_tokenSet_30
      
      typesig { [] }
      def mk_token_set_31
        data = Array.typed(::Java::Long).new([39406496739491840, 256, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_31) { BitSet.new(mk_token_set_31) }
      const_attr_reader  :_tokenSet_31
      
      typesig { [] }
      def mk_token_set_32
        data = Array.typed(::Java::Long).new([-7445570585318391808, 81827, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_32) { BitSet.new(mk_token_set_32) }
      const_attr_reader  :_tokenSet_32
      
      typesig { [] }
      def mk_token_set_33
        data = Array.typed(::Java::Long).new([-9174952842228662272, 81699, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_33) { BitSet.new(mk_token_set_33) }
      const_attr_reader  :_tokenSet_33
      
      typesig { [] }
      def mk_token_set_34
        data = Array.typed(::Java::Long).new([-9183960041483403264, 331555, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_34) { BitSet.new(mk_token_set_34) }
      const_attr_reader  :_tokenSet_34
      
      typesig { [] }
      def mk_token_set_35
        data = Array.typed(::Java::Long).new([-8598492089925238784, 81827, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_35) { BitSet.new(mk_token_set_35) }
      const_attr_reader  :_tokenSet_35
      
      typesig { [] }
      def mk_token_set_36
        data = Array.typed(::Java::Long).new([-7445570585318391808, 343971, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_36) { BitSet.new(mk_token_set_36) }
      const_attr_reader  :_tokenSet_36
      
      typesig { [] }
      def mk_token_set_37
        data = Array.typed(::Java::Long).new([0, 32768, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_37) { BitSet.new(mk_token_set_37) }
      const_attr_reader  :_tokenSet_37
      
      typesig { [] }
      def mk_token_set_38
        data = Array.typed(::Java::Long).new([4398046511104, 32768, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_38) { BitSet.new(mk_token_set_38) }
      const_attr_reader  :_tokenSet_38
      
      typesig { [] }
      def mk_token_set_39
        data = Array.typed(::Java::Long).new([-9187342140324184064, 512, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_39) { BitSet.new(mk_token_set_39) }
      const_attr_reader  :_tokenSet_39
      
      typesig { [] }
      def mk_token_set_40
        data = Array.typed(::Java::Long).new([-9223366539296636928, 65539, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_40) { BitSet.new(mk_token_set_40) }
      const_attr_reader  :_tokenSet_40
      
      typesig { [] }
      def mk_token_set_41
        data = Array.typed(::Java::Long).new([-8094086457758580734, 475119, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_41) { BitSet.new(mk_token_set_41) }
      const_attr_reader  :_tokenSet_41
      
      typesig { [] }
      def mk_token_set_42
        data = Array.typed(::Java::Long).new([-9183964440603656192, 264704, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_42) { BitSet.new(mk_token_set_42) }
      const_attr_reader  :_tokenSet_42
      
      typesig { [] }
      def mk_token_set_43
        data = Array.typed(::Java::Long).new([-8022031338695557120, 489987, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_43) { BitSet.new(mk_token_set_43) }
      const_attr_reader  :_tokenSet_43
      
      typesig { [] }
      def mk_token_set_44
        data = Array.typed(::Java::Long).new([-6941164953151733758, 491503, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_44) { BitSet.new(mk_token_set_44) }
      const_attr_reader  :_tokenSet_44
      
      typesig { [] }
      def mk_token_set_45
        data = Array.typed(::Java::Long).new([9007199254740992, 12288, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_45) { BitSet.new(mk_token_set_45) }
      const_attr_reader  :_tokenSet_45
      
      typesig { [] }
      def mk_token_set_46
        data = Array.typed(::Java::Long).new([-9183960042557145088, 330243, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_46) { BitSet.new(mk_token_set_46) }
      const_attr_reader  :_tokenSet_46
      
      typesig { [] }
      def mk_token_set_47
        data = Array.typed(::Java::Long).new([-9174952843302404096, 342531, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_47) { BitSet.new(mk_token_set_47) }
      const_attr_reader  :_tokenSet_47
      
      typesig { [] }
      def mk_token_set_48
        data = Array.typed(::Java::Long).new([4398046511104, 1638403, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_48) { BitSet.new(mk_token_set_48) }
      const_attr_reader  :_tokenSet_48
      
      typesig { [] }
      def mk_token_set_49
        data = Array.typed(::Java::Long).new([0, 2, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_49) { BitSet.new(mk_token_set_49) }
      const_attr_reader  :_tokenSet_49
      
      typesig { [] }
      def mk_token_set_50
        data = Array.typed(::Java::Long).new([18014398509481984, 2, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_50) { BitSet.new(mk_token_set_50) }
      const_attr_reader  :_tokenSet_50
    }
    
    private
    alias_method :initialize__antlrparser, :initialize
  end
  
end
