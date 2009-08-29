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
module Org::Antlr::Runtime::Tree
  module DOTTreeGeneratorImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Java::Util, :HashMap
    }
  end
  
  # A utility class to generate DOT diagrams (graphviz) from
  # arbitrary trees.  You can pass in your own templates and
  # can pass in any kind of tree or use Tree interface method.
  # I wanted this separator so that you don't have to include
  # ST just to use the org.antlr.runtime.tree.* package.
  # This is a set of non-static methods so you can subclass
  # to override.  For example, here is an invocation:
  # 
  # CharStream input = new ANTLRInputStream(System.in);
  # TLexer lex = new TLexer(input);
  # CommonTokenStream tokens = new CommonTokenStream(lex);
  # TParser parser = new TParser(tokens);
  # TParser.e_return r = parser.e();
  # Tree t = (Tree)r.tree;
  # System.out.println(t.toStringTree());
  # DOTTreeGenerator gen = new DOTTreeGenerator();
  # StringTemplate st = gen.toDOT(t);
  # System.out.println(st);
  class DOTTreeGenerator 
    include_class_members DOTTreeGeneratorImports
    
    class_module.module_eval {
      
      def _tree_st
        defined?(@@_tree_st) ? @@_tree_st : @@_tree_st= StringTemplate.new("digraph {\n" + "  ordering=out;\n" + "  ranksep=.4;\n" + "  node [shape=plaintext, fixedsize=true, fontsize=11, fontname=\"Courier\",\n" + "        width=.25, height=.25];\n" + "  edge [arrowsize=.5]\n" + "  $nodes$\n" + "  $edges$\n" + "}\n")
      end
      alias_method :attr__tree_st, :_tree_st
      
      def _tree_st=(value)
        @@_tree_st = value
      end
      alias_method :attr__tree_st=, :_tree_st=
      
      
      def _node_st
        defined?(@@_node_st) ? @@_node_st : @@_node_st= StringTemplate.new("$name$ [label=\"$text$\"];\n")
      end
      alias_method :attr__node_st, :_node_st
      
      def _node_st=(value)
        @@_node_st = value
      end
      alias_method :attr__node_st=, :_node_st=
      
      
      def _edge_st
        defined?(@@_edge_st) ? @@_edge_st : @@_edge_st= StringTemplate.new("$parent$ -> $child$ // \"$parentText$\" -> \"$childText$\"\n")
      end
      alias_method :attr__edge_st, :_edge_st
      
      def _edge_st=(value)
        @@_edge_st = value
      end
      alias_method :attr__edge_st=, :_edge_st=
    }
    
    # Track node to number mapping so we can get proper node name back
    attr_accessor :node_to_number_map
    alias_method :attr_node_to_number_map, :node_to_number_map
    undef_method :node_to_number_map
    alias_method :attr_node_to_number_map=, :node_to_number_map=
    undef_method :node_to_number_map=
    
    # Track node number so we can get unique node names
    attr_accessor :node_number
    alias_method :attr_node_number, :node_number
    undef_method :node_number
    alias_method :attr_node_number=, :node_number=
    undef_method :node_number=
    
    typesig { [Object, TreeAdaptor, StringTemplate, StringTemplate] }
    def to_dot(tree, adaptor, _tree_st, _edge_st)
      tree_st = _tree_st.get_instance_of
      @node_number = 0
      to_dotdefine_nodes(tree, adaptor, tree_st)
      @node_number = 0
      to_dotdefine_edges(tree, adaptor, tree_st)
      # if ( adaptor.getChildCount(tree)==0 ) {
      # // single node, don't do edge.
      # treeST.setAttribute("nodes", adaptor.getText(tree));
      # }
      return tree_st
    end
    
    typesig { [Object, TreeAdaptor] }
    def to_dot(tree, adaptor)
      return to_dot(tree, adaptor, self.attr__tree_st, self.attr__edge_st)
    end
    
    typesig { [Tree] }
    # Generate DOT (graphviz) for a whole tree not just a node.
    # For example, 3+4*5 should generate:
    # 
    # digraph {
    # node [shape=plaintext, fixedsize=true, fontsize=11, fontname="Courier",
    # width=.4, height=.2];
    # edge [arrowsize=.7]
    # "+"->3
    # "+"->"*"
    # "*"->4
    # "*"->5
    # }
    # 
    # Return the ST not a string in case people want to alter.
    # 
    # Takes a Tree interface object.
    def to_dot(tree)
      return to_dot(tree, CommonTreeAdaptor.new)
    end
    
    typesig { [Object, TreeAdaptor, StringTemplate] }
    def to_dotdefine_nodes(tree, adaptor, tree_st)
      if ((tree).nil?)
        return
      end
      n = adaptor.get_child_count(tree)
      if ((n).equal?(0))
        # must have already dumped as child from previous
        # invocation; do nothing
        return
      end
      # define parent node
      parent_node_st = get_node_st(adaptor, tree)
      tree_st.set_attribute("nodes", parent_node_st)
      # for each child, do a "<unique-name> [label=text]" node def
      i = 0
      while i < n
        child = adaptor.get_child(tree, i)
        node_st = get_node_st(adaptor, child)
        tree_st.set_attribute("nodes", node_st)
        to_dotdefine_nodes(child, adaptor, tree_st)
        i += 1
      end
    end
    
    typesig { [Object, TreeAdaptor, StringTemplate] }
    def to_dotdefine_edges(tree, adaptor, tree_st)
      if ((tree).nil?)
        return
      end
      n = adaptor.get_child_count(tree)
      if ((n).equal?(0))
        # must have already dumped as child from previous
        # invocation; do nothing
        return
      end
      parent_name = "n" + RJava.cast_to_string(get_node_number(tree))
      # for each child, do a parent -> child edge using unique node names
      parent_text = adaptor.get_text(tree)
      i = 0
      while i < n
        child = adaptor.get_child(tree, i)
        child_text = adaptor.get_text(child)
        child_name = "n" + RJava.cast_to_string(get_node_number(child))
        edge_st = self.attr__edge_st.get_instance_of
        edge_st.set_attribute("parent", parent_name)
        edge_st.set_attribute("child", child_name)
        edge_st.set_attribute("parentText", parent_text)
        edge_st.set_attribute("childText", child_text)
        tree_st.set_attribute("edges", edge_st)
        to_dotdefine_edges(child, adaptor, tree_st)
        i += 1
      end
    end
    
    typesig { [TreeAdaptor, Object] }
    def get_node_st(adaptor, t)
      text = adaptor.get_text(t)
      node_st = self.attr__node_st.get_instance_of
      unique_name = "n" + RJava.cast_to_string(get_node_number(t))
      node_st.set_attribute("name", unique_name)
      if (!(text).nil?)
        text = RJava.cast_to_string(text.replace_all("\"", "\\\\\""))
      end
      node_st.set_attribute("text", text)
      return node_st
    end
    
    typesig { [Object] }
    def get_node_number(t)
      n_i = @node_to_number_map.get(t)
      if (!(n_i).nil?)
        return n_i.int_value
      else
        @node_to_number_map.put(t, @node_number)
        @node_number += 1
        return @node_number - 1
      end
    end
    
    typesig { [] }
    def initialize
      @node_to_number_map = HashMap.new
      @node_number = 0
    end
    
    private
    alias_method :initialize__dottree_generator, :initialize
  end
  
end
