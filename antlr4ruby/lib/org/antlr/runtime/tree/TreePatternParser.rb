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
  module TreePatternParserImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :CommonToken
    }
  end
  
  class TreePatternParser 
    include_class_members TreePatternParserImports
    
    attr_accessor :tokenizer
    alias_method :attr_tokenizer, :tokenizer
    undef_method :tokenizer
    alias_method :attr_tokenizer=, :tokenizer=
    undef_method :tokenizer=
    
    attr_accessor :ttype
    alias_method :attr_ttype, :ttype
    undef_method :ttype
    alias_method :attr_ttype=, :ttype=
    undef_method :ttype=
    
    attr_accessor :wizard
    alias_method :attr_wizard, :wizard
    undef_method :wizard
    alias_method :attr_wizard=, :wizard=
    undef_method :wizard=
    
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    typesig { [TreePatternLexer, TreeWizard, TreeAdaptor] }
    def initialize(tokenizer, wizard, adaptor)
      @tokenizer = nil
      @ttype = 0
      @wizard = nil
      @adaptor = nil
      @tokenizer = tokenizer
      @wizard = wizard
      @adaptor = adaptor
      @ttype = tokenizer.next_token # kickstart
    end
    
    typesig { [] }
    def pattern
      if ((@ttype).equal?(TreePatternLexer::BEGIN_))
        return parse_tree
      else
        if ((@ttype).equal?(TreePatternLexer::ID))
          node = parse_node
          if ((@ttype).equal?(TreePatternLexer::EOF))
            return node
          end
          return nil # extra junk on end
        end
      end
      return nil
    end
    
    typesig { [] }
    def parse_tree
      if (!(@ttype).equal?(TreePatternLexer::BEGIN_))
        System.out.println("no BEGIN")
        return nil
      end
      @ttype = @tokenizer.next_token
      root = parse_node
      if ((root).nil?)
        return nil
      end
      while ((@ttype).equal?(TreePatternLexer::BEGIN_) || (@ttype).equal?(TreePatternLexer::ID) || (@ttype).equal?(TreePatternLexer::PERCENT) || (@ttype).equal?(TreePatternLexer::DOT))
        if ((@ttype).equal?(TreePatternLexer::BEGIN_))
          subtree = parse_tree
          @adaptor.add_child(root, subtree)
        else
          child = parse_node
          if ((child).nil?)
            return nil
          end
          @adaptor.add_child(root, child)
        end
      end
      if (!(@ttype).equal?(TreePatternLexer::END_))
        System.out.println("no END")
        return nil
      end
      @ttype = @tokenizer.next_token
      return root
    end
    
    typesig { [] }
    def parse_node
      # "%label:" prefix
      label = nil
      if ((@ttype).equal?(TreePatternLexer::PERCENT))
        @ttype = @tokenizer.next_token
        if (!(@ttype).equal?(TreePatternLexer::ID))
          return nil
        end
        label = RJava.cast_to_string(@tokenizer.attr_sval.to_s)
        @ttype = @tokenizer.next_token
        if (!(@ttype).equal?(TreePatternLexer::COLON))
          return nil
        end
        @ttype = @tokenizer.next_token # move to ID following colon
      end
      # Wildcard?
      if ((@ttype).equal?(TreePatternLexer::DOT))
        @ttype = @tokenizer.next_token
        wildcard_payload = CommonToken.new(0, ".")
        node = TreeWizard::WildcardTreePattern.new(wildcard_payload)
        if (!(label).nil?)
          node.attr_label = label
        end
        return node
      end
      # "ID" or "ID[arg]"
      if (!(@ttype).equal?(TreePatternLexer::ID))
        return nil
      end
      token_name = @tokenizer.attr_sval.to_s
      @ttype = @tokenizer.next_token
      if ((token_name == "nil"))
        return @adaptor.nil_
      end
      text = token_name
      # check for arg
      arg = nil
      if ((@ttype).equal?(TreePatternLexer::ARG))
        arg = RJava.cast_to_string(@tokenizer.attr_sval.to_s)
        text = arg
        @ttype = @tokenizer.next_token
      end
      # create node
      tree_node_type = @wizard.get_token_type(token_name)
      if ((tree_node_type).equal?(Token::INVALID_TOKEN_TYPE))
        return nil
      end
      node = nil
      node = @adaptor.create(tree_node_type, text)
      if (!(label).nil? && (node.get_class).equal?(TreeWizard::TreePattern))
        (node).attr_label = label
      end
      if (!(arg).nil? && (node.get_class).equal?(TreeWizard::TreePattern))
        (node).attr_has_text_arg = true
      end
      return node
    end
    
    private
    alias_method :initialize__tree_pattern_parser, :initialize
  end
  
end
