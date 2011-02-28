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
  module AttributeScopeImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Antlr, :Token
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include ::Java::Util
    }
  end
  
  # Track the attributes within a scope.  A named scoped has just its list
  # of attributes.  Each rule has potentially 3 scopes: return values,
  # parameters, and an implicitly-named scope (i.e., a scope defined in a rule).
  # Implicitly-defined scopes are named after the rule; rules and scopes then
  # must live in the same name space--no collisions allowed.
  class AttributeScope 
    include_class_members AttributeScopeImports
    
    class_module.module_eval {
      # All token scopes (token labels) share the same fixed scope of
      # of predefined attributes.  I keep this out of the runtime.Token
      # object to avoid a runtime space burden.
      
      def token_scope
        defined?(@@token_scope) ? @@token_scope : @@token_scope= AttributeScope.new("Token", nil)
      end
      alias_method :attr_token_scope, :token_scope
      
      def token_scope=(value)
        @@token_scope = value
      end
      alias_method :attr_token_scope=, :token_scope=
      
      when_class_loaded do
        self.attr_token_scope.add_attribute("text", nil)
        self.attr_token_scope.add_attribute("type", nil)
        self.attr_token_scope.add_attribute("line", nil)
        self.attr_token_scope.add_attribute("index", nil)
        self.attr_token_scope.add_attribute("pos", nil)
        self.attr_token_scope.add_attribute("channel", nil)
        self.attr_token_scope.add_attribute("tree", nil)
        self.attr_token_scope.add_attribute("int", nil)
      end
    }
    
    # This scope is associated with which input token (for error handling)?
    attr_accessor :derived_from_token
    alias_method :attr_derived_from_token, :derived_from_token
    undef_method :derived_from_token
    alias_method :attr_derived_from_token=, :derived_from_token=
    undef_method :derived_from_token=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    # The scope name
    attr_accessor :name
    alias_method :attr_name, :name
    undef_method :name
    alias_method :attr_name=, :name=
    undef_method :name=
    
    # Not a rule scope, but visible to all rules "scope symbols { ...}"
    attr_accessor :is_dynamic_global_scope
    alias_method :attr_is_dynamic_global_scope, :is_dynamic_global_scope
    undef_method :is_dynamic_global_scope
    alias_method :attr_is_dynamic_global_scope=, :is_dynamic_global_scope=
    undef_method :is_dynamic_global_scope=
    
    # Visible to all rules, but defined in rule "scope { int i; }"
    attr_accessor :is_dynamic_rule_scope
    alias_method :attr_is_dynamic_rule_scope, :is_dynamic_rule_scope
    undef_method :is_dynamic_rule_scope
    alias_method :attr_is_dynamic_rule_scope=, :is_dynamic_rule_scope=
    undef_method :is_dynamic_rule_scope=
    
    attr_accessor :is_parameter_scope
    alias_method :attr_is_parameter_scope, :is_parameter_scope
    undef_method :is_parameter_scope
    alias_method :attr_is_parameter_scope=, :is_parameter_scope=
    undef_method :is_parameter_scope=
    
    attr_accessor :is_return_scope
    alias_method :attr_is_return_scope, :is_return_scope
    undef_method :is_return_scope
    alias_method :attr_is_return_scope=, :is_return_scope=
    undef_method :is_return_scope=
    
    attr_accessor :is_predefined_rule_scope
    alias_method :attr_is_predefined_rule_scope, :is_predefined_rule_scope
    undef_method :is_predefined_rule_scope
    alias_method :attr_is_predefined_rule_scope=, :is_predefined_rule_scope=
    undef_method :is_predefined_rule_scope=
    
    attr_accessor :is_predefined_lexer_rule_scope
    alias_method :attr_is_predefined_lexer_rule_scope, :is_predefined_lexer_rule_scope
    undef_method :is_predefined_lexer_rule_scope
    alias_method :attr_is_predefined_lexer_rule_scope=, :is_predefined_lexer_rule_scope=
    undef_method :is_predefined_lexer_rule_scope=
    
    # The list of Attribute objects
    attr_accessor :attributes
    alias_method :attr_attributes, :attributes
    undef_method :attributes
    alias_method :attr_attributes=, :attributes=
    undef_method :attributes=
    
    typesig { [String, Token] }
    def initialize(name, derived_from_token)
      initialize__attribute_scope(nil, name, derived_from_token)
    end
    
    typesig { [Grammar, String, Token] }
    def initialize(grammar, name, derived_from_token)
      @derived_from_token = nil
      @grammar = nil
      @name = nil
      @is_dynamic_global_scope = false
      @is_dynamic_rule_scope = false
      @is_parameter_scope = false
      @is_return_scope = false
      @is_predefined_rule_scope = false
      @is_predefined_lexer_rule_scope = false
      @attributes = LinkedHashMap.new
      @grammar = grammar
      @name = name
      @derived_from_token = derived_from_token
    end
    
    typesig { [] }
    def get_name
      if (@is_parameter_scope)
        return @name + "_parameter"
      else
        if (@is_return_scope)
          return @name + "_return"
        end
      end
      return @name
    end
    
    typesig { [String, ::Java::Int] }
    # From a chunk of text holding the definitions of the attributes,
    # pull them apart and create an Attribute for each one.  Add to
    # the list of attributes for this scope.  Pass in the character
    # that terminates a definition such as ',' or ';'.  For example,
    # 
    # scope symbols {
    # int n;
    # List names;
    # }
    # 
    # would pass in definitions equal to the text in between {...} and
    # separator=';'.  It results in two Attribute objects.
    def add_attributes(definitions, separator)
      attrs = ArrayList.new
      CodeGenerator.get_list_of_arguments_from_action(definitions, 0, -1, separator, attrs)
      attrs.each do |a|
        attr = Attribute.new(a)
        if (!@is_return_scope && !(attr.attr_init_value).nil?)
          ErrorManager.grammar_error(ErrorManager::MSG_ARG_INIT_VALUES_ILLEGAL, @grammar, @derived_from_token, attr.attr_name)
          attr.attr_init_value = nil # wipe it out
        end
        @attributes.put(attr.attr_name, attr)
      end
    end
    
    typesig { [String, String] }
    def add_attribute(name, decl)
      @attributes.put(name, Attribute.new(name, decl))
    end
    
    typesig { [String] }
    def get_attribute(name)
      return @attributes.get(name)
    end
    
    typesig { [] }
    # Used by templates to get all attributes
    def get_attributes
      a = ArrayList.new
      a.add_all(@attributes.values)
      return a
    end
    
    typesig { [AttributeScope] }
    # Return the set of keys that collide from
    # this and other.
    def intersection(other)
      if ((other).nil? || (other.size).equal?(0) || (size).equal?(0))
        return nil
      end
      inter = HashSet.new
      this_keys = @attributes.key_set
      it = this_keys.iterator
      while it.has_next
        key = it.next_
        if (!(other.attr_attributes.get(key)).nil?)
          inter.add(key)
        end
      end
      if ((inter.size).equal?(0))
        return nil
      end
      return inter
    end
    
    typesig { [] }
    def size
      return (@attributes).nil? ? 0 : @attributes.size
    end
    
    typesig { [] }
    def to_s
      return RJava.cast_to_string((@is_dynamic_global_scope ? "global " : "") + get_name) + ":" + RJava.cast_to_string(@attributes)
    end
    
    private
    alias_method :initialize__attribute_scope, :initialize
  end
  
end
