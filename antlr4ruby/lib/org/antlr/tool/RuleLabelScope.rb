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
  module RuleLabelScopeImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Antlr, :Token
    }
  end
  
  class RuleLabelScope < RuleLabelScopeImports.const_get :AttributeScope
    include_class_members RuleLabelScopeImports
    
    class_module.module_eval {
      add_attribute("text", nil)
      add_attribute("start", nil)
      add_attribute("stop", nil)
      add_attribute("tree", nil)
      add_attribute("st", nil)
      self.attr_is_predefined_rule_scope = true
      
      def predefined_rule_properties_scope
        defined?(@@predefined_rule_properties_scope) ? @@predefined_rule_properties_scope : @@predefined_rule_properties_scope= # Rules have a predefined set of attributes as well as
        # the return values.  'text' needs to be computed though so.
        Class.new(AttributeScope.class == Class ? AttributeScope : Object) do
          local_class_in RuleLabelScope
          include_class_members RuleLabelScope
          include AttributeScope if AttributeScope.class == Module
          
          typesig { [Vararg.new(Object)] }
          define_method :initialize do |*args|
            super(*args)
          end
          
          private
          alias_method :initialize_anonymous, :initialize
        end.new_local(self, "RulePredefined", nil)
      end
      alias_method :attr_predefined_rule_properties_scope, :predefined_rule_properties_scope
      
      def predefined_rule_properties_scope=(value)
        @@predefined_rule_properties_scope = value
      end
      alias_method :attr_predefined_rule_properties_scope=, :predefined_rule_properties_scope=
      
      add_attribute("text", nil)
      add_attribute("start", nil) # note: no stop; not meaningful
      add_attribute("tree", nil)
      add_attribute("st", nil)
      self.attr_is_predefined_rule_scope = true
      
      def predefined_tree_rule_properties_scope
        defined?(@@predefined_tree_rule_properties_scope) ? @@predefined_tree_rule_properties_scope : @@predefined_tree_rule_properties_scope= Class.new(AttributeScope.class == Class ? AttributeScope : Object) do
          local_class_in RuleLabelScope
          include_class_members RuleLabelScope
          include AttributeScope if AttributeScope.class == Module
          
          typesig { [Vararg.new(Object)] }
          define_method :initialize do |*args|
            super(*args)
          end
          
          private
          alias_method :initialize_anonymous, :initialize
        end.new_local(self, "RulePredefined", nil)
      end
      alias_method :attr_predefined_tree_rule_properties_scope, :predefined_tree_rule_properties_scope
      
      def predefined_tree_rule_properties_scope=(value)
        @@predefined_tree_rule_properties_scope = value
      end
      alias_method :attr_predefined_tree_rule_properties_scope=, :predefined_tree_rule_properties_scope=
      
      add_attribute("text", nil)
      add_attribute("type", nil)
      add_attribute("line", nil)
      add_attribute("index", nil)
      add_attribute("pos", nil)
      add_attribute("channel", nil)
      add_attribute("start", nil)
      add_attribute("stop", nil)
      add_attribute("int", nil)
      self.attr_is_predefined_lexer_rule_scope = true
      
      def predefined_lexer_rule_properties_scope
        defined?(@@predefined_lexer_rule_properties_scope) ? @@predefined_lexer_rule_properties_scope : @@predefined_lexer_rule_properties_scope= Class.new(AttributeScope.class == Class ? AttributeScope : Object) do
          local_class_in RuleLabelScope
          include_class_members RuleLabelScope
          include AttributeScope if AttributeScope.class == Module
          
          typesig { [Vararg.new(Object)] }
          define_method :initialize do |*args|
            super(*args)
          end
          
          private
          alias_method :initialize_anonymous, :initialize
        end.new_local(self, "LexerRulePredefined", nil)
      end
      alias_method :attr_predefined_lexer_rule_properties_scope, :predefined_lexer_rule_properties_scope
      
      def predefined_lexer_rule_properties_scope=(value)
        @@predefined_lexer_rule_properties_scope = value
      end
      alias_method :attr_predefined_lexer_rule_properties_scope=, :predefined_lexer_rule_properties_scope=
      
      # LEXER
      # PARSER
      # TREE_PARSER
      # COMBINED
      
      def grammar_type_to_rule_properties_scope
        defined?(@@grammar_type_to_rule_properties_scope) ? @@grammar_type_to_rule_properties_scope : @@grammar_type_to_rule_properties_scope= Array.typed(AttributeScope).new([nil, self.attr_predefined_lexer_rule_properties_scope, self.attr_predefined_rule_properties_scope, self.attr_predefined_tree_rule_properties_scope, self.attr_predefined_rule_properties_scope, ])
      end
      alias_method :attr_grammar_type_to_rule_properties_scope, :grammar_type_to_rule_properties_scope
      
      def grammar_type_to_rule_properties_scope=(value)
        @@grammar_type_to_rule_properties_scope = value
      end
      alias_method :attr_grammar_type_to_rule_properties_scope=, :grammar_type_to_rule_properties_scope=
    }
    
    attr_accessor :referenced_rule
    alias_method :attr_referenced_rule, :referenced_rule
    undef_method :referenced_rule
    alias_method :attr_referenced_rule=, :referenced_rule=
    undef_method :referenced_rule=
    
    typesig { [Rule, Token] }
    def initialize(referenced_rule, action_token)
      @referenced_rule = nil
      super("ref_" + RJava.cast_to_string(referenced_rule.attr_name), action_token)
      @referenced_rule = referenced_rule
    end
    
    typesig { [String] }
    # If you label a rule reference, you can access that rule's
    # return values as well as any predefined attributes.
    def get_attribute(name)
      rule_properties_scope = self.attr_grammar_type_to_rule_properties_scope[self.attr_grammar.attr_type]
      if (!(rule_properties_scope.get_attribute(name)).nil?)
        return rule_properties_scope.get_attribute(name)
      end
      if (!(@referenced_rule.attr_return_scope).nil?)
        return @referenced_rule.attr_return_scope.get_attribute(name)
      end
      return nil
    end
    
    private
    alias_method :initialize__rule_label_scope, :initialize
  end
  
end
