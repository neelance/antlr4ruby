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
  module CompositeGrammarTreeImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :JavaList
    }
  end
  
  # A tree of grammars
  class CompositeGrammarTree 
    include_class_members CompositeGrammarTreeImports
    
    attr_accessor :children
    alias_method :attr_children, :children
    undef_method :children
    alias_method :attr_children=, :children=
    undef_method :children=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    # Who is the parent node of this node; if null, implies node is root
    attr_accessor :parent
    alias_method :attr_parent, :parent
    undef_method :parent
    alias_method :attr_parent=, :parent=
    undef_method :parent=
    
    typesig { [Grammar] }
    def initialize(g)
      @children = nil
      @grammar = nil
      @parent = nil
      @grammar = g
    end
    
    typesig { [CompositeGrammarTree] }
    def add_child(t)
      # System.out.println("add "+t.toStringTree()+" as child to "+this.toStringTree());
      if ((t).nil?)
        return # do nothing upon addChild(null)
      end
      if ((@children).nil?)
        @children = ArrayList.new
      end
      @children.add(t)
      t.attr_parent = self
    end
    
    typesig { [String] }
    # Find a rule by looking in current grammar then down towards the
    # delegate grammars.
    def get_rule(rule_name)
      r = @grammar.get_locally_defined_rule(rule_name)
      i = 0
      while (r).nil? && !(@children).nil? && i < @children.size
        child = @children.get(i)
        r = child.get_rule(rule_name)
        i += 1
      end
      return r
    end
    
    typesig { [String] }
    # Find an option by looking up towards the root grammar rather than down
    def get_option(key)
      o = @grammar.get_locally_defined_option(key)
      if (!(o).nil?)
        return o
      end
      if (!(@parent).nil?)
        return @parent.get_option(key)
      end
      return nil # not found
    end
    
    typesig { [Grammar] }
    def find_node(g)
      if ((g).nil?)
        return nil
      end
      if ((@grammar).equal?(g))
        return self
      end
      n = nil
      i = 0
      while (n).nil? && !(@children).nil? && i < @children.size
        child = @children.get(i)
        n = child.find_node(g)
        i += 1
      end
      return n
    end
    
    typesig { [String] }
    def find_node(grammar_name)
      if ((grammar_name).nil?)
        return nil
      end
      if ((grammar_name == @grammar.attr_name))
        return self
      end
      n = nil
      i = 0
      while (n).nil? && !(@children).nil? && i < @children.size
        child = @children.get(i)
        n = child.find_node(grammar_name)
        i += 1
      end
      return n
    end
    
    typesig { [] }
    # Return a postorder list of grammars; root is last in list
    def get_post_ordered_grammar_list
      grammars = ArrayList.new
      __get_post_ordered_grammar_list(grammars)
      return grammars
    end
    
    typesig { [JavaList] }
    # work for getPostOrderedGrammarList
    def __get_post_ordered_grammar_list(grammars)
      i = 0
      while !(@children).nil? && i < @children.size
        child = @children.get(i)
        child.__get_post_ordered_grammar_list(grammars)
        i += 1
      end
      grammars.add(@grammar)
    end
    
    typesig { [] }
    # Return a postorder list of grammars; root is last in list
    def get_pre_ordered_grammar_list
      grammars = ArrayList.new
      __get_pre_ordered_grammar_list(grammars)
      return grammars
    end
    
    typesig { [JavaList] }
    def __get_pre_ordered_grammar_list(grammars)
      grammars.add(@grammar)
      i = 0
      while !(@children).nil? && i < @children.size
        child = @children.get(i)
        child.__get_post_ordered_grammar_list(grammars)
        i += 1
      end
    end
    
    typesig { [] }
    def trim_lexer_imports_into_combined
      p = self
      if ((p.attr_grammar.attr_type).equal?(Grammar::LEXER) && !(p.attr_parent).nil? && (p.attr_parent.attr_grammar.attr_type).equal?(Grammar::COMBINED))
        # System.out.println("wacking "+p.grammar.name+" from "+p.parent.grammar.name);
        p.attr_parent.attr_children.remove(self)
      end
      i = 0
      while !(@children).nil? && i < @children.size
        child = @children.get(i)
        child.trim_lexer_imports_into_combined
        i += 1
      end
    end
    
    private
    alias_method :initialize__composite_grammar_tree, :initialize
  end
  
end
