require "rjava"

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
  module GrammarASTImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Antlr, :BaseAST
      include_const ::Antlr, :Token
      include_const ::Antlr, :TokenWithIndex
      include_const ::Antlr::Collections, :AST
      include_const ::Org::Antlr::Analysis, :DFA
      include_const ::Org::Antlr::Analysis, :NFAState
      include_const ::Org::Antlr::Misc, :IntSet
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include ::Java::Util
    }
  end
  
  # Grammars are first converted to ASTs using this class and then are
  # converted to NFAs via a tree walker.
  # 
  # The reader may notice that I have made a very non-OO decision in this
  # class to track variables for many different kinds of nodes.  It wastes
  # space for nodes that don't need the values and OO principles cry out
  # for a new class type for each kind of node in my tree.  I am doing this
  # on purpose for a variety of reasons.  I don't like using the type
  # system for different node types; it yields too many damn class files
  # which I hate.  Perhaps if I put them all in one file.  Most importantly
  # though I hate all the type casting that would have to go on.  I would
  # have all sorts of extra work to do.  Ick.  Anyway, I'm doing all this
  # on purpose, not out of ignorance. ;)
  class GrammarAST < GrammarASTImports.const_get :BaseAST
    include_class_members GrammarASTImports
    
    class_module.module_eval {
      
      def count
        defined?(@@count) ? @@count : @@count= 0
      end
      alias_method :attr_count, :count
      
      def count=(value)
        @@count = value
      end
      alias_method :attr_count=, :count=
    }
    
    attr_accessor :id
    alias_method :attr_id, :id
    undef_method :id
    alias_method :attr_id=, :id=
    undef_method :id=
    
    # This AST node was created from what token?
    attr_accessor :token
    alias_method :attr_token, :token
    undef_method :token
    alias_method :attr_token=, :token=
    undef_method :token=
    
    attr_accessor :enclosing_rule_name
    alias_method :attr_enclosing_rule_name, :enclosing_rule_name
    undef_method :enclosing_rule_name
    alias_method :attr_enclosing_rule_name=, :enclosing_rule_name=
    undef_method :enclosing_rule_name=
    
    # If this is a RULE node then track rule's start, stop tokens' index.
    attr_accessor :rule_start_token_index
    alias_method :attr_rule_start_token_index, :rule_start_token_index
    undef_method :rule_start_token_index
    alias_method :attr_rule_start_token_index=, :rule_start_token_index=
    undef_method :rule_start_token_index=
    
    attr_accessor :rule_stop_token_index
    alias_method :attr_rule_stop_token_index, :rule_stop_token_index
    undef_method :rule_stop_token_index
    alias_method :attr_rule_stop_token_index=, :rule_stop_token_index=
    undef_method :rule_stop_token_index=
    
    # If this is a decision node, what is the lookahead DFA?
    attr_accessor :lookahead_dfa
    alias_method :attr_lookahead_dfa, :lookahead_dfa
    undef_method :lookahead_dfa
    alias_method :attr_lookahead_dfa=, :lookahead_dfa=
    undef_method :lookahead_dfa=
    
    # What NFA start state was built from this node?
    attr_accessor :nfastart_state
    alias_method :attr_nfastart_state, :nfastart_state
    undef_method :nfastart_state
    alias_method :attr_nfastart_state=, :nfastart_state=
    undef_method :nfastart_state=
    
    # This is used for TREE_BEGIN nodes to point into
    # the NFA.  TREE_BEGINs point at left edge of DOWN for LOOK computation
    # purposes (Nullable tree child list needs special code gen when matching).
    attr_accessor :nfatree_down_state
    alias_method :attr_nfatree_down_state, :nfatree_down_state
    undef_method :nfatree_down_state
    alias_method :attr_nfatree_down_state=, :nfatree_down_state=
    undef_method :nfatree_down_state=
    
    # Rule ref nodes, token refs, set, and NOT set refs need to track their
    # location in the generated NFA so that local FOLLOW sets can be
    # computed during code gen for automatic error recovery.
    attr_accessor :following_nfastate
    alias_method :attr_following_nfastate, :following_nfastate
    undef_method :following_nfastate
    alias_method :attr_following_nfastate=, :following_nfastate=
    undef_method :following_nfastate=
    
    # If this is a SET node, what are the elements?
    attr_accessor :set_value
    alias_method :attr_set_value, :set_value
    undef_method :set_value
    alias_method :attr_set_value=, :set_value=
    undef_method :set_value=
    
    # If this is a BLOCK node, track options here
    attr_accessor :block_options
    alias_method :attr_block_options, :block_options
    undef_method :block_options
    alias_method :attr_block_options=, :block_options=
    undef_method :block_options=
    
    # If this is a BLOCK node for a rewrite rule, track referenced
    # elements here.  Don't track elements in nested subrules.
    attr_accessor :rewrite_refs_shallow
    alias_method :attr_rewrite_refs_shallow, :rewrite_refs_shallow
    undef_method :rewrite_refs_shallow
    alias_method :attr_rewrite_refs_shallow=, :rewrite_refs_shallow=
    undef_method :rewrite_refs_shallow=
    
    # If REWRITE node, track EVERY element and label ref to right of ->
    # for this rewrite rule.  There could be multiple of these per
    # rule:
    # 
    # a : ( ... -> ... | ... -> ... ) -> ... ;
    # 
    # We may need a list of all refs to do definitions for whole rewrite
    # later.
    # 
    # If BLOCK then tracks every element at that level and below.
    attr_accessor :rewrite_refs_deep
    alias_method :attr_rewrite_refs_deep, :rewrite_refs_deep
    undef_method :rewrite_refs_deep
    alias_method :attr_rewrite_refs_deep=, :rewrite_refs_deep=
    undef_method :rewrite_refs_deep=
    
    attr_accessor :terminal_options
    alias_method :attr_terminal_options, :terminal_options
    undef_method :terminal_options
    alias_method :attr_terminal_options=, :terminal_options=
    undef_method :terminal_options=
    
    # if this is an ACTION node, this is the outermost enclosing
    # alt num in rule.  For actions, define.g sets these (used to
    # be codegen.g).  We need these set so we can examine actions
    # early, before code gen, for refs to rule predefined properties
    # and rule labels.  For most part define.g sets outerAltNum, but
    # codegen.g does the ones for %foo(a={$ID.text}) type refs as
    # the {$ID...} is not seen as an action until code gen pulls apart.
    attr_accessor :outer_alt_num
    alias_method :attr_outer_alt_num, :outer_alt_num
    undef_method :outer_alt_num
    alias_method :attr_outer_alt_num=, :outer_alt_num=
    undef_method :outer_alt_num=
    
    # if this is a TOKEN_REF or RULE_REF node, this is the code StringTemplate
    # generated for this node.  We need to update it later to add
    # a label if someone does $tokenref or $ruleref in an action.
    attr_accessor :code
    alias_method :attr_code, :code
    undef_method :code
    alias_method :attr_code=, :code=
    undef_method :code=
    
    typesig { [] }
    def initialize
      @id = 0
      @token = nil
      @enclosing_rule_name = nil
      @rule_start_token_index = 0
      @rule_stop_token_index = 0
      @lookahead_dfa = nil
      @nfastart_state = nil
      @nfatree_down_state = nil
      @following_nfastate = nil
      @set_value = nil
      @block_options = nil
      @rewrite_refs_shallow = nil
      @rewrite_refs_deep = nil
      @terminal_options = nil
      @outer_alt_num = 0
      @code = nil
      super()
      @id = (self.attr_count += 1)
      @token = nil
      @lookahead_dfa = nil
      @nfastart_state = nil
      @nfatree_down_state = nil
      @following_nfastate = nil
      @set_value = nil
    end
    
    typesig { [::Java::Int, String] }
    def initialize(t, txt)
      @id = 0
      @token = nil
      @enclosing_rule_name = nil
      @rule_start_token_index = 0
      @rule_stop_token_index = 0
      @lookahead_dfa = nil
      @nfastart_state = nil
      @nfatree_down_state = nil
      @following_nfastate = nil
      @set_value = nil
      @block_options = nil
      @rewrite_refs_shallow = nil
      @rewrite_refs_deep = nil
      @terminal_options = nil
      @outer_alt_num = 0
      @code = nil
      super()
      @id = (self.attr_count += 1)
      @token = nil
      @lookahead_dfa = nil
      @nfastart_state = nil
      @nfatree_down_state = nil
      @following_nfastate = nil
      @set_value = nil
      initialize_(t, txt)
    end
    
    typesig { [::Java::Int, String] }
    def initialize_(i, s)
      @token = TokenWithIndex.new(i, s)
    end
    
    typesig { [AST] }
    def initialize_(ast)
      t = (ast)
      @token = t.attr_token
      @enclosing_rule_name = t.attr_enclosing_rule_name
      @rule_start_token_index = t.attr_rule_start_token_index
      @rule_stop_token_index = t.attr_rule_stop_token_index
      @set_value = t.attr_set_value
      @block_options = t.attr_block_options
      @outer_alt_num = t.attr_outer_alt_num
    end
    
    typesig { [Token] }
    def initialize_(token)
      @token = token
    end
    
    typesig { [] }
    def get_lookahead_dfa
      return @lookahead_dfa
    end
    
    typesig { [DFA] }
    def set_lookahead_dfa(lookahead_dfa)
      @lookahead_dfa = lookahead_dfa
    end
    
    typesig { [] }
    def get_token
      return @token
    end
    
    typesig { [] }
    def get_nfastart_state
      return @nfastart_state
    end
    
    typesig { [NFAState] }
    def set_nfastart_state(nfa_start_state)
      @nfastart_state = nfa_start_state
    end
    
    typesig { [Grammar, String, Object] }
    # Save the option key/value pair and process it; return the key
    # or null if invalid option.
    def set_block_option(grammar, key, value)
      if ((@block_options).nil?)
        @block_options = HashMap.new
      end
      return set_option(@block_options, Grammar.attr_legal_block_options, grammar, key, value)
    end
    
    typesig { [Grammar, String, Object] }
    def set_terminal_option(grammar, key, value)
      if ((@terminal_options).nil?)
        @terminal_options = HashMap.new
      end
      return set_option(@terminal_options, Grammar.attr_legal_token_options, grammar, key, value)
    end
    
    typesig { [Map, JavaSet, Grammar, String, Object] }
    def set_option(options, legal_options, grammar, key, value)
      if (!legal_options.contains(key))
        ErrorManager.grammar_error(ErrorManager::MSG_ILLEGAL_OPTION, grammar, @token, key)
        return nil
      end
      if (value.is_a?(String))
        vs = value
        if ((vs.char_at(0)).equal?(Character.new(?".ord)))
          value = vs.substring(1, vs.length - 1) # strip quotes
        end
      end
      if ((key == "k"))
        ((grammar.attr_number_of_manual_lookahead_options += 1) - 1)
      end
      options.put(key, value)
      return key
    end
    
    typesig { [String] }
    def get_block_option(key)
      value = nil
      if (!(@block_options).nil?)
        value = @block_options.get(key)
      end
      return value
    end
    
    typesig { [Grammar, Map] }
    def set_options(grammar, options)
      if ((options).nil?)
        @block_options = nil
        return
      end
      keys = options.key_set
      it = keys.iterator
      while it.has_next
        option_name = it.next
        stored = set_block_option(grammar, option_name, options.get(option_name))
        if ((stored).nil?)
          it.remove
        end
      end
    end
    
    typesig { [] }
    def get_text
      if (!(@token).nil?)
        return @token.get_text
      end
      return ""
    end
    
    typesig { [::Java::Int] }
    def set_type(type)
      @token.set_type(type)
    end
    
    typesig { [String] }
    def set_text(text)
      @token.set_text(text)
    end
    
    typesig { [] }
    def get_type
      if (!(@token).nil?)
        return @token.get_type
      end
      return -1
    end
    
    typesig { [] }
    def get_line
      line = 0
      if (!(@token).nil?)
        line = @token.get_line
      end
      if ((line).equal?(0))
        child = get_first_child
        if (!(child).nil?)
          line = child.get_line
        end
      end
      return line
    end
    
    typesig { [] }
    def get_column
      col = 0
      if (!(@token).nil?)
        col = @token.get_column
      end
      if ((col).equal?(0))
        child = get_first_child
        if (!(child).nil?)
          col = child.get_column
        end
      end
      return col
    end
    
    typesig { [::Java::Int] }
    def set_line(line)
      @token.set_line(line)
    end
    
    typesig { [::Java::Int] }
    def set_column(col)
      @token.set_column(col)
    end
    
    typesig { [] }
    def get_set_value
      return @set_value
    end
    
    typesig { [IntSet] }
    def set_set_value(set_value)
      @set_value = set_value
    end
    
    typesig { [] }
    def get_last_child
      return (get_first_child).get_last_sibling
    end
    
    typesig { [] }
    def get_last_sibling
      t = self
      last = nil
      while (!(t).nil?)
        last = t
        t = t.get_next_sibling
      end
      return last
    end
    
    typesig { [::Java::Int] }
    # Get the ith child from 0
    def get_child(i)
      n = 0
      t = get_first_child
      while (!(t).nil?)
        if ((n).equal?(i))
          return t
        end
        ((n += 1) - 1)
        t = t.get_next_sibling
      end
      return nil
    end
    
    typesig { [::Java::Int] }
    def get_first_child_with_type(ttype)
      t = get_first_child
      while (!(t).nil?)
        if ((t.get_type).equal?(ttype))
          return t
        end
        t = t.get_next_sibling
      end
      return nil
    end
    
    typesig { [] }
    def get_children_as_array
      t = get_first_child
      array = Array.typed(GrammarAST).new(get_number_of_children) { nil }
      i = 0
      while (!(t).nil?)
        array[i] = t
        t = t.get_next_sibling
        ((i += 1) - 1)
      end
      return array
    end
    
    typesig { [::Java::Int] }
    # Return a reference to the first node (depth-first) that has
    # token type ttype.  Assume 'this' is a root node; don't visit siblings
    # of root.  Return null if no node found with ttype.
    def find_first_type(ttype)
      # check this node (the root) first
      if ((self.get_type).equal?(ttype))
        return self
      end
      # else check children
      child = self.get_first_child
      while (!(child).nil?)
        result = child.find_first_type(ttype)
        if (!(result).nil?)
          return result
        end
        child = child.get_next_sibling
      end
      return nil
    end
    
    typesig { [Object] }
    # Make nodes unique based upon Token so we can add them to a Set; if
    # not a GrammarAST, check type.
    def equals(ast)
      if ((self).equal?(ast))
        return true
      end
      if (!(ast.is_a?(GrammarAST)))
        return (self.get_type).equal?((ast).get_type)
      end
      t = ast
      return (@token.get_line).equal?(t.get_line) && (@token.get_column).equal?(t.get_column)
    end
    
    typesig { [AST] }
    # See if tree has exact token types and structure; no text
    def has_same_tree_structure(t)
      # check roots first.
      if (!(self.get_type).equal?(t.get_type))
        return false
      end
      # if roots match, do full list match test on children.
      if (!(self.get_first_child).nil?)
        if (!((self.get_first_child).has_same_list_structure(t.get_first_child)))
          return false
        end
      # sibling has no kids, make sure t doesn't either
      else
        if (!(t.get_first_child).nil?)
          return false
        end
      end
      return true
    end
    
    typesig { [AST] }
    def has_same_list_structure(t)
      sibling = nil
      # the empty tree is not a match of any non-null tree.
      if ((t).nil?)
        return false
      end
      # Otherwise, start walking sibling lists.  First mismatch, return false.
      sibling = self
      while !(sibling).nil? && !(t).nil?
        # as a quick optimization, check roots first.
        if (!(sibling.get_type).equal?(t.get_type))
          return false
        end
        # if roots match, do full list match test on children.
        if (!(sibling.get_first_child).nil?)
          if (!(sibling.get_first_child).has_same_list_structure(t.get_first_child))
            return false
          end
        # sibling has no kids, make sure t doesn't either
        else
          if (!(t.get_first_child).nil?)
            return false
          end
        end
        sibling = sibling.get_next_sibling
        t = t.get_next_sibling
      end
      if ((sibling).nil? && (t).nil?)
        return true
      end
      # one sibling list has more than the other
      return false
    end
    
    class_module.module_eval {
      typesig { [AST] }
      def dup(t)
        if ((t).nil?)
          return nil
        end
        dup_t = GrammarAST.new
        dup_t.initialize_(t)
        return dup_t
      end
      
      typesig { [GrammarAST, GrammarAST] }
      # Duplicate tree including siblings of root.
      def dup_list_no_actions(t, parent)
        result = dup_tree_no_actions(t, parent) # if t == null, then result==null
        nt = result
        while (!(t).nil?)
          # for each sibling of the root
          t = t.get_next_sibling
          if (!(t).nil? && (t.get_type).equal?(ANTLRParser::ACTION))
            next
          end
          d = dup_tree_no_actions(t, parent)
          if (!(d).nil?)
            if (!(nt).nil?)
              nt.set_next_sibling(d) # dup each subtree, building new tree
            end
            nt = d
          end
        end
        return result
      end
      
      typesig { [GrammarAST, GrammarAST] }
      # Duplicate a tree, assuming this is a root node of a tree--
      # duplicate that node and what's below; ignore siblings of root node.
      def dup_tree_no_actions(t, parent)
        if ((t).nil?)
          return nil
        end
        ttype = t.get_type
        if ((ttype).equal?(ANTLRParser::REWRITE))
          return nil
        end
        if ((ttype).equal?(ANTLRParser::BANG) || (ttype).equal?(ANTLRParser::ROOT))
          # return x from ^(ROOT x)
          return dup_list_no_actions(t.get_first_child, t)
        end
        # DOH!  Must allow labels for sem preds
        # if ( (ttype==ANTLRParser.ASSIGN||ttype==ANTLRParser.PLUS_ASSIGN) &&
        # (parent==null||parent.getType()!=ANTLRParser.OPTIONS) )
        # {
        # return dupTreeNoActions(t.getChild(1), t); // return x from ^(ASSIGN label x)
        # }
        result = dup(t) # make copy of root
        # copy all children of root.
        kids = dup_list_no_actions(t.get_first_child, t)
        result.set_first_child(kids)
        return result
      end
    }
    
    typesig { [String] }
    def set_tree_enclosing_rule_name_deeply(rname)
      t = self
      t.attr_enclosing_rule_name = rname
      t = t.get_child(0)
      while (!(t).nil?)
        # for each sibling of the root
        t.set_tree_enclosing_rule_name_deeply(rname)
        t = t.get_next_sibling
      end
    end
    
    private
    alias_method :initialize__grammar_ast, :initialize
  end
  
end
