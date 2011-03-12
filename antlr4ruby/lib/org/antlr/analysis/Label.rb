require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
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
module Org::Antlr::Analysis
  module LabelImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :GrammarAST
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Org::Antlr::Misc, :IntSet
    }
  end
  
  # A state machine transition label.  A label can be either a simple
  # label such as a token or character.  A label can be a set of char or
  # tokens.  It can be an epsilon transition.  It can be a semantic predicate
  # (which assumes an epsilon transition) or a tree of predicates (in a DFA).
  class Label 
    include_class_members LabelImports
    include JavaComparable
    include Cloneable
    
    class_module.module_eval {
      const_set_lazy(:INVALID) { -7 }
      const_attr_reader  :INVALID
      
      const_set_lazy(:ACTION) { -6 }
      const_attr_reader  :ACTION
      
      const_set_lazy(:EPSILON) { -5 }
      const_attr_reader  :EPSILON
      
      const_set_lazy(:EPSILON_STR) { "<EPSILON>" }
      const_attr_reader  :EPSILON_STR
      
      # label is a semantic predicate; implies label is epsilon also
      const_set_lazy(:SEMPRED) { -4 }
      const_attr_reader  :SEMPRED
      
      # label is a set of tokens or char
      const_set_lazy(:SET) { -3 }
      const_attr_reader  :SET
      
      # End of Token is like EOF for lexer rules.  It implies that no more
      # characters are available and that NFA conversion should terminate
      # for this path.  For example
      # 
      # A : 'a' 'b' | 'a' ;
      # 
      # yields a DFA predictor:
      # 
      # o-a->o-b->1   predict alt 1
      #      |
      #      |-EOT->o predict alt 2
      # 
      # To generate code for EOT, treat it as the "default" path, which
      # implies there is no way to mismatch a char for the state from
      # which the EOT emanates.
      const_set_lazy(:EOT) { -2 }
      const_attr_reader  :EOT
      
      const_set_lazy(:EOF) { -1 }
      const_attr_reader  :EOF
      
      # We have labels like EPSILON that are below 0; it's hard to
      # store them in an array with negative index so use this
      # constant as an index shift when accessing arrays based upon
      # token type.  If real token type is i, then array index would be
      # NUM_FAUX_LABELS + i.
      const_set_lazy(:NUM_FAUX_LABELS) { -INVALID }
      const_attr_reader  :NUM_FAUX_LABELS
      
      # Anything at this value or larger can be considered a simple atom int
      # for easy comparison during analysis only; faux labels are not used
      # during parse time for real token types or char values.
      const_set_lazy(:MIN_ATOM_VALUE) { EOT }
      const_attr_reader  :MIN_ATOM_VALUE
      
      # TODO: is 0 a valid unicode char? max is FFFF -1, right?
      const_set_lazy(:MIN_CHAR_VALUE) { Character.new(0x0000) }
      const_attr_reader  :MIN_CHAR_VALUE
      
      const_set_lazy(:MAX_CHAR_VALUE) { Character.new(0xFFFF) }
      const_attr_reader  :MAX_CHAR_VALUE
      
      # End of rule token type; imaginary token type used only for
      # local, partial FOLLOW sets to indicate that the local FOLLOW
      # hit the end of rule.  During error recovery, the local FOLLOW
      # of a token reference may go beyond the end of the rule and have
      # to use FOLLOW(rule).  I have to just shift the token types to 2..n
      # rather than 1..n to accommodate this imaginary token in my bitsets.
      # If I didn't use a bitset implementation for runtime sets, I wouldn't
      # need this.  EOF is another candidate for a run time token type for
      # parsers.  Follow sets are not computed for lexers so we do not have
      # this issue.
      const_set_lazy(:EOR_TOKEN_TYPE) { Org::Antlr::Runtime::Token::EOR_TOKEN_TYPE }
      const_attr_reader  :EOR_TOKEN_TYPE
      
      const_set_lazy(:DOWN) { Org::Antlr::Runtime::Token::DOWN }
      const_attr_reader  :DOWN
      
      const_set_lazy(:UP) { Org::Antlr::Runtime::Token::UP }
      const_attr_reader  :UP
      
      # tokens and char range overlap; tokens are MIN_TOKEN_TYPE..n
      const_set_lazy(:MIN_TOKEN_TYPE) { Org::Antlr::Runtime::Token::MIN_TOKEN_TYPE }
      const_attr_reader  :MIN_TOKEN_TYPE
    }
    
    # The wildcard '.' char atom implies all valid characters==UNICODE
    # public static final IntSet ALLCHAR = IntervalSet.of(MIN_CHAR_VALUE,MAX_CHAR_VALUE);
    # The token type or character value; or, signifies special label.
    attr_accessor :label
    alias_method :attr_label, :label
    undef_method :label
    alias_method :attr_label=, :label=
    undef_method :label=
    
    # A set of token types or character codes if label==SET
    # TODO: try IntervalSet for everything
    attr_accessor :label_set
    alias_method :attr_label_set, :label_set
    undef_method :label_set
    alias_method :attr_label_set=, :label_set=
    undef_method :label_set=
    
    typesig { [::Java::Int] }
    def initialize(label)
      @label = 0
      @label_set = nil
      @label = label
    end
    
    typesig { [IntSet] }
    # Make a set label
    def initialize(label_set)
      @label = 0
      @label_set = nil
      if ((label_set).nil?)
        @label = SET
        @label_set = IntervalSet.of(INVALID)
        return
      end
      single_atom = label_set.get_single_element
      if (!(single_atom).equal?(INVALID))
        # convert back to a single atomic element if |labelSet|==1
        @label = single_atom
        return
      end
      @label = SET
      @label_set = label_set
    end
    
    typesig { [] }
    def clone
      l = nil
      begin
        l = super
        l.attr_label = @label
        l.attr_label_set = IntervalSet.new
        l.attr_label_set.add_all(@label_set)
      rescue CloneNotSupportedException => e
        raise InternalError.new
      end
      return l
    end
    
    typesig { [Label] }
    def add(a)
      if (is_atom)
        @label_set = IntervalSet.of(@label)
        @label = SET
        if (a.is_atom)
          @label_set.add(a.get_atom)
        else
          if (a.is_set)
            @label_set.add_all(a.get_set)
          else
            raise IllegalStateException.new("can't add element to Label of type " + RJava.cast_to_string(@label))
          end
        end
        return
      end
      if (is_set)
        if (a.is_atom)
          @label_set.add(a.get_atom)
        else
          if (a.is_set)
            @label_set.add_all(a.get_set)
          else
            raise IllegalStateException.new("can't add element to Label of type " + RJava.cast_to_string(@label))
          end
        end
        return
      end
      raise IllegalStateException.new("can't add element to Label of type " + RJava.cast_to_string(@label))
    end
    
    typesig { [] }
    def is_atom
      return @label >= MIN_ATOM_VALUE
    end
    
    typesig { [] }
    def is_epsilon
      return (@label).equal?(EPSILON)
    end
    
    typesig { [] }
    def is_semantic_predicate
      return false
    end
    
    typesig { [] }
    def is_action
      return false
    end
    
    typesig { [] }
    def is_set
      return (@label).equal?(SET)
    end
    
    typesig { [] }
    # return the single atom label or INVALID if not a single atom
    def get_atom
      if (is_atom)
        return @label
      end
      return INVALID
    end
    
    typesig { [] }
    def get_set
      if (!(@label).equal?(SET))
        # convert single element to a set if they ask for it.
        return IntervalSet.of(@label)
      end
      return @label_set
    end
    
    typesig { [IntSet] }
    def set_set(set)
      @label = SET
      @label_set = set
    end
    
    typesig { [] }
    def get_semantic_context
      return nil
    end
    
    typesig { [::Java::Int] }
    def matches(atom)
      if ((@label).equal?(atom))
        return true # handle the single atom case efficiently
      end
      if (is_set)
        return @label_set.member(atom)
      end
      return false
    end
    
    typesig { [IntSet] }
    def matches(set)
      if (is_atom)
        return set.member(get_atom)
      end
      if (is_set)
        # matches if intersection non-nil
        return !get_set.and_(set).is_nil
      end
      return false
    end
    
    typesig { [Label] }
    def matches(other)
      if (other.is_set)
        return matches(other.get_set)
      end
      if (other.is_atom)
        return matches(other.get_atom)
      end
      return false
    end
    
    typesig { [] }
    def hash_code
      if ((@label).equal?(SET))
        return @label_set.hash_code
      else
        return @label
      end
    end
    
    typesig { [Object] }
    # TODO: do we care about comparing set {A} with atom A? Doesn't now.
    def ==(o)
      if ((o).nil?)
        return false
      end
      if ((self).equal?(o))
        return true # equals if same object
      end
      # labels must be the same even if epsilon or set or sempred etc...
      if (!(@label).equal?((o).attr_label))
        return false
      end
      if ((@label).equal?(SET))
        return (@label_set == (o).attr_label_set)
      end
      return true # label values are same, so true
    end
    
    typesig { [Object] }
    def compare_to(o)
      return @label - (o).attr_label
    end
    
    typesig { [] }
    # Predicates are lists of AST nodes from the NFA created from the
    # grammar, but the same predicate could be cut/paste into multiple
    # places in the grammar.  I must compare the text of all the
    # predicates to truly answer whether {p1,p2} .equals {p1,p2}.
    # Unfortunately, I cannot rely on the AST.equals() to work properly
    # so I must do a brute force O(n^2) nested traversal of the Set
    # doing a String compare.
    # 
    # At this point, Labels are not compared for equals when they are
    # predicates, but here's the code for future use.
    # protected boolean predicatesEquals(Set others) {
    #     Iterator iter = semanticContext.iterator();
    #     while (iter.hasNext()) {
    #         AST predAST = (AST) iter.next();
    #         Iterator inner = semanticContext.iterator();
    #         while (inner.hasNext()) {
    #             AST otherPredAST = (AST) inner.next();
    #             if ( !predAST.getText().equals(otherPredAST.getText()) ) {
    #                 return false;
    #             }
    #         }
    #     }
    #     return true;
    # }
    def to_s
      case (@label)
      when SET
        return @label_set.to_s
      else
        return String.value_of(@label)
      end
    end
    
    typesig { [Grammar] }
    def to_s(g)
      case (@label)
      when SET
        return @label_set.to_s(g)
      else
        return g.get_token_display_name(@label)
      end
    end
    
    class_module.module_eval {
      typesig { [Label, Label] }
      # public String predicatesToString() {
      #     if ( semanticContext==NFAConfiguration.DEFAULT_CLAUSE_SEMANTIC_CONTEXT ) {
      #         return "!other preds";
      #     }
      #     StringBuffer buf = new StringBuffer();
      #     Iterator iter = semanticContext.iterator();
      #     while (iter.hasNext()) {
      #         AST predAST = (AST) iter.next();
      #         buf.append(predAST.getText());
      #         if ( iter.hasNext() ) {
      #             buf.append("&");
      #         }
      #     }
      #     return buf.toString();
      # }
      def intersect(label, edge_label)
        has_intersection = false
        label_is_set = label.is_set
        edge_is_set = edge_label.is_set
        if (!label_is_set && !edge_is_set && (edge_label.attr_label).equal?(label.attr_label))
          has_intersection = true
        else
          if (label_is_set && edge_is_set && !edge_label.get_set.and_(label.get_set).is_nil)
            has_intersection = true
          else
            if (label_is_set && !edge_is_set && label.get_set.member(edge_label.attr_label))
              has_intersection = true
            else
              if (!label_is_set && edge_is_set && edge_label.get_set.member(label.attr_label))
                has_intersection = true
              end
            end
          end
        end
        return has_intersection
      end
    }
    
    private
    alias_method :initialize__label, :initialize
  end
  
end
