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
  module TreeWizardImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
      include ::Java::Util
    }
  end
  
  # TODO: next stuff taken from CommonTreeNodeStream
  # Given a node, add this to the reverse index tokenTypeToStreamIndexesMap.
  # You can override this method to alter how indexing occurs.  The
  # default is to create a
  # 
  # Map<Integer token type,ArrayList<Integer stream index>>
  # 
  # This data structure allows you to find all nodes with type INT in order.
  # 
  # If you really need to find a node of type, say, FUNC quickly then perhaps
  # 
  # Map<Integertoken type,Map<Object tree node,Integer stream index>>
  # 
  # would be better for you.  The interior maps map a tree node to
  # the index so you don't have to search linearly for a specific node.
  # 
  # If you change this method, you will likely need to change
  # getNodeIndex(), which extracts information.
  # protected void fillReverseIndex(Object node, int streamIndex) {
  # //System.out.println("revIndex "+node+"@"+streamIndex);
  # if ( tokenTypesToReverseIndex==null ) {
  # return; // no indexing if this is empty (nothing of interest)
  # }
  # if ( tokenTypeToStreamIndexesMap==null ) {
  # tokenTypeToStreamIndexesMap = new HashMap(); // first indexing op
  # }
  # int tokenType = adaptor.getType(node);
  # Integer tokenTypeI = new Integer(tokenType);
  # if ( !(tokenTypesToReverseIndex==INDEX_ALL ||
  # tokenTypesToReverseIndex.contains(tokenTypeI)) )
  # {
  # return; // tokenType not of interest
  # }
  # Integer streamIndexI = new Integer(streamIndex);
  # ArrayList indexes = (ArrayList)tokenTypeToStreamIndexesMap.get(tokenTypeI);
  # if ( indexes==null ) {
  # indexes = new ArrayList(); // no list yet for this token type
  # indexes.add(streamIndexI); // not there yet, add
  # tokenTypeToStreamIndexesMap.put(tokenTypeI, indexes);
  # }
  # else {
  # if ( !indexes.contains(streamIndexI) ) {
  # indexes.add(streamIndexI); // not there yet, add
  # }
  # }
  # }
  # 
  # Track the indicated token type in the reverse index.  Call this
  # repeatedly for each type or use variant with Set argument to
  # set all at once.
  # @param tokenType
  # public void reverseIndex(int tokenType) {
  # if ( tokenTypesToReverseIndex==null ) {
  # tokenTypesToReverseIndex = new HashSet();
  # }
  # else if ( tokenTypesToReverseIndex==INDEX_ALL ) {
  # return;
  # }
  # tokenTypesToReverseIndex.add(new Integer(tokenType));
  # }
  # 
  # Track the indicated token types in the reverse index. Set
  # to INDEX_ALL to track all token types.
  # public void reverseIndex(Set tokenTypes) {
  # tokenTypesToReverseIndex = tokenTypes;
  # }
  # 
  # Given a node pointer, return its index into the node stream.
  # This is not its Token stream index.  If there is no reverse map
  # from node to stream index or the map does not contain entries
  # for node's token type, a linear search of entire stream is used.
  # 
  # Return -1 if exact node pointer not in stream.
  # public int getNodeIndex(Object node) {
  # //System.out.println("get "+node);
  # if ( tokenTypeToStreamIndexesMap==null ) {
  # return getNodeIndexLinearly(node);
  # }
  # int tokenType = adaptor.getType(node);
  # Integer tokenTypeI = new Integer(tokenType);
  # ArrayList indexes = (ArrayList)tokenTypeToStreamIndexesMap.get(tokenTypeI);
  # if ( indexes==null ) {
  # //System.out.println("found linearly; stream index = "+getNodeIndexLinearly(node));
  # return getNodeIndexLinearly(node);
  # }
  # for (int i = 0; i < indexes.size(); i++) {
  # Integer streamIndexI = (Integer)indexes.get(i);
  # Object n = get(streamIndexI.intValue());
  # if ( n==node ) {
  # //System.out.println("found in index; stream index = "+streamIndexI);
  # return streamIndexI.intValue(); // found it!
  # }
  # }
  # return -1;
  # }
  # 
  # 
  # Build and navigate trees with this object.  Must know about the names
  # of tokens so you have to pass in a map or array of token names (from which
  # this class can build the map).  I.e., Token DECL means nothing unless the
  # class can translate it to a token type.
  # 
  # In order to create nodes and navigate, this class needs a TreeAdaptor.
  # 
  # This class can build a token type -> node index for repeated use or for
  # iterating over the various nodes with a particular type.
  # 
  # This class works in conjunction with the TreeAdaptor rather than moving
  # all this functionality into the adaptor.  An adaptor helps build and
  # navigate trees using methods.  This class helps you do it with string
  # patterns like "(A B C)".  You can create a tree from that pattern or
  # match subtrees against it.
  class TreeWizard 
    include_class_members TreeWizardImports
    
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    attr_accessor :token_name_to_type_map
    alias_method :attr_token_name_to_type_map, :token_name_to_type_map
    undef_method :token_name_to_type_map
    alias_method :attr_token_name_to_type_map=, :token_name_to_type_map=
    undef_method :token_name_to_type_map=
    
    class_module.module_eval {
      const_set_lazy(:ContextVisitor) { Module.new do
        include_class_members TreeWizard
        
        typesig { [Object, Object, ::Java::Int, Map] }
        # TODO: should this be called visit or something else?
        def visit(t, parent, child_index, labels)
          raise NotImplementedError
        end
      end }
      
      const_set_lazy(:Visitor) { Class.new do
        include_class_members TreeWizard
        include ContextVisitor
        
        typesig { [Object, Object, ::Java::Int, Map] }
        def visit(t, parent, child_index, labels)
          visit(t)
        end
        
        typesig { [Object] }
        def visit(t)
          raise NotImplementedError
        end
        
        typesig { [] }
        def initialize
        end
        
        private
        alias_method :initialize__visitor, :initialize
      end }
      
      # When using %label:TOKENNAME in a tree for parse(), we must
      # track the label.
      const_set_lazy(:TreePattern) { Class.new(CommonTree) do
        include_class_members TreeWizard
        
        attr_accessor :label
        alias_method :attr_label, :label
        undef_method :label
        alias_method :attr_label=, :label=
        undef_method :label=
        
        attr_accessor :has_text_arg
        alias_method :attr_has_text_arg, :has_text_arg
        undef_method :has_text_arg
        alias_method :attr_has_text_arg=, :has_text_arg=
        undef_method :has_text_arg=
        
        typesig { [Token] }
        def initialize(payload)
          @label = nil
          @has_text_arg = false
          super(payload)
        end
        
        typesig { [] }
        def to_s
          if (!(@label).nil?)
            return "%" + @label + ":" + (super).to_s
          else
            return super
          end
        end
        
        private
        alias_method :initialize__tree_pattern, :initialize
      end }
      
      const_set_lazy(:WildcardTreePattern) { Class.new(TreePattern) do
        include_class_members TreeWizard
        
        typesig { [Token] }
        def initialize(payload)
          super(payload)
        end
        
        private
        alias_method :initialize__wildcard_tree_pattern, :initialize
      end }
      
      # This adaptor creates TreePattern objects for use during scan()
      const_set_lazy(:TreePatternTreeAdaptor) { Class.new(CommonTreeAdaptor) do
        include_class_members TreeWizard
        
        typesig { [Token] }
        def create(payload)
          return TreePattern.new(payload)
        end
        
        typesig { [] }
        def initialize
          super()
        end
        
        private
        alias_method :initialize__tree_pattern_tree_adaptor, :initialize
      end }
    }
    
    typesig { [TreeAdaptor] }
    # TODO: build indexes for the wizard
    # During fillBuffer(), we can make a reverse index from a set
    # of token types of interest to the list of indexes into the
    # node stream.  This lets us convert a node pointer to a
    # stream index semi-efficiently for a list of interesting
    # nodes such as function definition nodes (you'll want to seek
    # to their bodies for an interpreter).  Also useful for doing
    # dynamic searches; i.e., go find me all PLUS nodes.
    # protected Map tokenTypeToStreamIndexesMap;
    # 
    # If tokenTypesToReverseIndex set to INDEX_ALL then indexing
    # occurs for all token types.
    # public static final Set INDEX_ALL = new HashSet();
    # 
    # A set of token types user would like to index for faster lookup.
    # If this is INDEX_ALL, then all token types are tracked.  If null,
    # then none are indexed.
    # protected Set tokenTypesToReverseIndex = null;
    def initialize(adaptor)
      @adaptor = nil
      @token_name_to_type_map = nil
      @adaptor = adaptor
    end
    
    typesig { [TreeAdaptor, Map] }
    def initialize(adaptor, token_name_to_type_map)
      @adaptor = nil
      @token_name_to_type_map = nil
      @adaptor = adaptor
      @token_name_to_type_map = token_name_to_type_map
    end
    
    typesig { [TreeAdaptor, Array.typed(String)] }
    def initialize(adaptor, token_names)
      @adaptor = nil
      @token_name_to_type_map = nil
      @adaptor = adaptor
      @token_name_to_type_map = compute_token_types(token_names)
    end
    
    typesig { [Array.typed(String)] }
    def initialize(token_names)
      initialize__tree_wizard(nil, token_names)
    end
    
    typesig { [Array.typed(String)] }
    # Compute a Map<String, Integer> that is an inverted index of
    # tokenNames (which maps int token types to names).
    def compute_token_types(token_names)
      m = HashMap.new
      if ((token_names).nil?)
        return m
      end
      ttype = Token::MIN_TOKEN_TYPE
      while ttype < token_names.attr_length
        name = token_names[ttype]
        m.put(name, ttype)
        ((ttype += 1) - 1)
      end
      return m
    end
    
    typesig { [String] }
    # Using the map of token names to token types, return the type.
    def get_token_type(token_name)
      if ((@token_name_to_type_map).nil?)
        return Token::INVALID_TOKEN_TYPE
      end
      ttype_i = @token_name_to_type_map.get(token_name)
      if (!(ttype_i).nil?)
        return ttype_i.int_value
      end
      return Token::INVALID_TOKEN_TYPE
    end
    
    typesig { [Object] }
    # Walk the entire tree and make a node name to nodes mapping.
    # For now, use recursion but later nonrecursive version may be
    # more efficient.  Returns Map<Integer, List> where the List is
    # of your AST node type.  The Integer is the token type of the node.
    # 
    # TODO: save this index so that find and visit are faster
    def index(t)
      m = HashMap.new
      __index(t, m)
      return m
    end
    
    typesig { [Object, Map] }
    # Do the work for index
    def __index(t, m)
      if ((t).nil?)
        return
      end
      ttype = @adaptor.get_type(t)
      elements = m.get(ttype)
      if ((elements).nil?)
        elements = ArrayList.new
        m.put(ttype, elements)
      end
      elements.add(t)
      n = @adaptor.get_child_count(t)
      i = 0
      while i < n
        child = @adaptor.get_child(t, i)
        __index(child, m)
        ((i += 1) - 1)
      end
    end
    
    typesig { [Object, ::Java::Int] }
    # Return a List of tree nodes with token type ttype
    def find(t, ttype)
      nodes = ArrayList.new
      visit(t, ttype, Class.new(TreeWizard::Visitor.class == Class ? TreeWizard::Visitor : Object) do
        extend LocalClass
        include_class_members TreeWizard
        include TreeWizard::Visitor if TreeWizard::Visitor.class == Module
        
        typesig { [Object] }
        define_method :visit do |t|
          nodes.add(t)
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      return nodes
    end
    
    typesig { [Object, String] }
    # Return a List of subtrees matching pattern.
    def find(t, pattern)
      subtrees = ArrayList.new
      # Create a TreePattern from the pattern
      tokenizer = TreePatternLexer.new(pattern)
      parser = TreePatternParser.new(tokenizer, self, TreePatternTreeAdaptor.new)
      tpattern = parser.pattern
      # don't allow invalid patterns
      if ((tpattern).nil? || tpattern.is_nil || (tpattern.get_class).equal?(WildcardTreePattern.class))
        return nil
      end
      root_token_type = tpattern.get_type
      visit(t, root_token_type, Class.new(TreeWizard::ContextVisitor.class == Class ? TreeWizard::ContextVisitor : Object) do
        extend LocalClass
        include_class_members TreeWizard
        include TreeWizard::ContextVisitor if TreeWizard::ContextVisitor.class == Module
        
        typesig { [Object, Object, ::Java::Int, Map] }
        define_method :visit do |t, parent, child_index, labels|
          if (__parse(t, tpattern, nil))
            subtrees.add(t)
          end
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
      return subtrees
    end
    
    typesig { [Object, ::Java::Int] }
    def find_first(t, ttype)
      return nil
    end
    
    typesig { [Object, String] }
    def find_first(t, pattern_)
      return nil
    end
    
    typesig { [Object, ::Java::Int, ContextVisitor] }
    # Visit every ttype node in t, invoking the visitor.  This is a quicker
    # version of the general visit(t, pattern) method.  The labels arg
    # of the visitor action method is never set (it's null) since using
    # a token type rather than a pattern doesn't let us set a label.
    def visit(t, ttype, visitor)
      __visit(t, nil, 0, ttype, visitor)
    end
    
    typesig { [Object, Object, ::Java::Int, ::Java::Int, ContextVisitor] }
    # Do the recursive work for visit
    def __visit(t, parent, child_index, ttype, visitor)
      if ((t).nil?)
        return
      end
      if ((@adaptor.get_type(t)).equal?(ttype))
        visitor.visit(t, parent, child_index, nil)
      end
      n = @adaptor.get_child_count(t)
      i = 0
      while i < n
        child = @adaptor.get_child(t, i)
        __visit(child, t, i, ttype, visitor)
        ((i += 1) - 1)
      end
    end
    
    typesig { [Object, String, ContextVisitor] }
    # For all subtrees that match the pattern, execute the visit action.
    # The implementation uses the root node of the pattern in combination
    # with visit(t, ttype, visitor) so nil-rooted patterns are not allowed.
    # Patterns with wildcard roots are also not allowed.
    def visit(t, pattern_, visitor)
      # Create a TreePattern from the pattern
      tokenizer = TreePatternLexer.new(pattern_)
      parser = TreePatternParser.new(tokenizer, self, TreePatternTreeAdaptor.new)
      tpattern = parser.pattern
      # don't allow invalid patterns
      if ((tpattern).nil? || tpattern.is_nil || (tpattern.get_class).equal?(WildcardTreePattern.class))
        return
      end
      labels = HashMap.new # reused for each _parse
      root_token_type = tpattern.get_type
      visit(t, root_token_type, Class.new(TreeWizard::ContextVisitor.class == Class ? TreeWizard::ContextVisitor : Object) do
        extend LocalClass
        include_class_members TreeWizard
        include TreeWizard::ContextVisitor if TreeWizard::ContextVisitor.class == Module
        
        typesig { [Object, Object, ::Java::Int, Map] }
        define_method :visit do |t, parent, child_index, unusedlabels|
          # the unusedlabels arg is null as visit on token type doesn't set.
          labels.clear
          if (__parse(t, tpattern, labels))
            visitor.visit(t, parent, child_index, labels)
          end
        end
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self))
    end
    
    typesig { [Object, String, Map] }
    # Given a pattern like (ASSIGN %lhs:ID %rhs:.) with optional labels
    # on the various nodes and '.' (dot) as the node/subtree wildcard,
    # return true if the pattern matches and fill the labels Map with
    # the labels pointing at the appropriate nodes.  Return false if
    # the pattern is malformed or the tree does not match.
    # 
    # If a node specifies a text arg in pattern, then that must match
    # for that node in t.
    # 
    # TODO: what's a better way to indicate bad pattern? Exceptions are a hassle
    def parse(t, pattern_, labels)
      tokenizer = TreePatternLexer.new(pattern_)
      parser = TreePatternParser.new(tokenizer, self, TreePatternTreeAdaptor.new)
      tpattern = parser.pattern
      # System.out.println("t="+((Tree)t).toStringTree());
      # System.out.println("scant="+tpattern.toStringTree());
      matched = __parse(t, tpattern, labels)
      return matched
    end
    
    typesig { [Object, String] }
    def parse(t, pattern_)
      return parse(t, pattern_, nil)
    end
    
    typesig { [Object, TreePattern, Map] }
    # Do the work for parse. Check to see if the t2 pattern fits the
    # structure and token types in t1.  Check text if the pattern has
    # text arguments on nodes.  Fill labels map with pointers to nodes
    # in tree matched against nodes in pattern with labels.
    def __parse(t1, t2, labels)
      # make sure both are non-null
      if ((t1).nil? || (t2).nil?)
        return false
      end
      # check roots (wildcard matches anything)
      if (!(t2.get_class).equal?(WildcardTreePattern.class))
        if (!(@adaptor.get_type(t1)).equal?(t2.get_type))
          return false
        end
        if (t2.attr_has_text_arg && !(@adaptor.get_text(t1) == t2.get_text))
          return false
        end
      end
      if (!(t2.attr_label).nil? && !(labels).nil?)
        # map label in pattern to node in t1
        labels.put(t2.attr_label, t1)
      end
      # check children
      n1 = @adaptor.get_child_count(t1)
      n2 = t2.get_child_count
      if (!(n1).equal?(n2))
        return false
      end
      i = 0
      while i < n1
        child1 = @adaptor.get_child(t1, i)
        child2 = t2.get_child(i)
        if (!__parse(child1, child2, labels))
          return false
        end
        ((i += 1) - 1)
      end
      return true
    end
    
    typesig { [String] }
    # Create a tree or node from the indicated tree pattern that closely
    # follows ANTLR tree grammar tree element syntax:
    # 
    # (root child1 ... child2).
    # 
    # You can also just pass in a node: ID
    # 
    # Any node can have a text argument: ID[foo]
    # (notice there are no quotes around foo--it's clear it's a string).
    # 
    # nil is a special name meaning "give me a nil node".  Useful for
    # making lists: (nil A B C) is a list of A B C.
    def create(pattern_)
      tokenizer = TreePatternLexer.new(pattern_)
      parser = TreePatternParser.new(tokenizer, self, @adaptor)
      t = parser.pattern
      return t
    end
    
    class_module.module_eval {
      typesig { [Object, Object, TreeAdaptor] }
      # Compare t1 and t2; return true if token types/text, structure match exactly.
      # The trees are examined in their entirety so that (A B) does not match
      # (A B C) nor (A (B C)).
      # // TODO: allow them to pass in a comparator
      # TODO: have a version that is nonstatic so it can use instance adaptor
      # 
      # I cannot rely on the tree node's equals() implementation as I make
      # no constraints at all on the node types nor interface etc...
      def equals(t1, t2, adaptor)
        return __equals(t1, t2, adaptor)
      end
    }
    
    typesig { [Object, Object] }
    # Compare type, structure, and text of two trees, assuming adaptor in
    # this instance of a TreeWizard.
    def equals(t1, t2)
      return __equals(t1, t2, @adaptor)
    end
    
    class_module.module_eval {
      typesig { [Object, Object, TreeAdaptor] }
      def __equals(t1, t2, adaptor)
        # make sure both are non-null
        if ((t1).nil? || (t2).nil?)
          return false
        end
        # check roots
        if (!(adaptor.get_type(t1)).equal?(adaptor.get_type(t2)))
          return false
        end
        if (!(adaptor.get_text(t1) == adaptor.get_text(t2)))
          return false
        end
        # check children
        n1 = adaptor.get_child_count(t1)
        n2 = adaptor.get_child_count(t2)
        if (!(n1).equal?(n2))
          return false
        end
        i = 0
        while i < n1
          child1 = adaptor.get_child(t1, i)
          child2 = adaptor.get_child(t2, i)
          if (!__equals(child1, child2, adaptor))
            return false
          end
          ((i += 1) - 1)
        end
        return true
      end
    }
    
    private
    alias_method :initialize__tree_wizard, :initialize
  end
  
end
