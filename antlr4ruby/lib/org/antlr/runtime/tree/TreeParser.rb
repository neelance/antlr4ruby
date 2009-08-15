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
  module TreeParserImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
      include ::Org::Antlr::Runtime
    }
  end
  
  # A parser for a stream of tree nodes.  "tree grammars" result in a subclass
  # of this.  All the error reporting and recovery is shared with Parser via
  # the BaseRecognizer superclass.
  class TreeParser < TreeParserImports.const_get :BaseRecognizer
    include_class_members TreeParserImports
    
    class_module.module_eval {
      const_set_lazy(:DOWN) { Token::DOWN }
      const_attr_reader  :DOWN
      
      const_set_lazy(:UP) { Token::UP }
      const_attr_reader  :UP
    }
    
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    typesig { [TreeNodeStream] }
    def initialize(input)
      @input = nil
      super() # highlight that we go to super to set state object
      set_tree_node_stream(input)
    end
    
    typesig { [TreeNodeStream, RecognizerSharedState] }
    def initialize(input, state)
      @input = nil
      super(state) # share the state object with another parser
      set_tree_node_stream(input)
    end
    
    typesig { [] }
    def reset
      super # reset all recognizer state variables
      if (!(@input).nil?)
        @input.seek(0) # rewind the input
      end
    end
    
    typesig { [TreeNodeStream] }
    # Set the input stream
    def set_tree_node_stream(input)
      @input = input
    end
    
    typesig { [] }
    def get_tree_node_stream
      return @input
    end
    
    typesig { [] }
    def get_source_name
      return @input.get_source_name
    end
    
    typesig { [IntStream] }
    def get_current_input_symbol(input)
      return (input)._lt(1)
    end
    
    typesig { [IntStream, RecognitionException, ::Java::Int, BitSet] }
    def get_missing_symbol(input, e, expected_token_type, follow)
      token_text = "<missing " + RJava.cast_to_string(get_token_names[expected_token_type]) + ">"
      return CommonTree.new(CommonToken.new(expected_token_type, token_text))
    end
    
    typesig { [IntStream] }
    # Match '.' in tree parser has special meaning.  Skip node or
    # entire tree if node has children.  If children, scan until
    # corresponding UP node.
    def match_any(ignore)
      # ignore stream, copy of input
      self.attr_state.attr_error_recovery = false
      self.attr_state.attr_failed = false
      look = @input._lt(1)
      if ((@input.get_tree_adaptor.get_child_count(look)).equal?(0))
        @input.consume # not subtree, consume 1 node and return
        return
      end
      # current node is a subtree, skip to corresponding UP.
      # must count nesting level to get right UP
      level = 0
      token_type = @input.get_tree_adaptor.get_type(look)
      while (!(token_type).equal?(Token::EOF) && !((token_type).equal?(UP) && (level).equal?(0)))
        @input.consume
        look = @input._lt(1)
        token_type = @input.get_tree_adaptor.get_type(look)
        if ((token_type).equal?(DOWN))
          level += 1
        else
          if ((token_type).equal?(UP))
            level -= 1
          end
        end
      end
      @input.consume # consume UP
    end
    
    typesig { [IntStream, ::Java::Int, BitSet] }
    # We have DOWN/UP nodes in the stream that have no line info; override.
    # plus we want to alter the exception type.  Don't try to recover
    # from tree parser errors inline...
    def mismatch(input, ttype, follow)
      raise MismatchedTreeNodeException.new(ttype, input)
    end
    
    typesig { [RecognitionException] }
    # Prefix error message with the grammar name because message is
    # always intended for the programmer because the parser built
    # the input tree not the user.
    def get_error_header(e)
      return RJava.cast_to_string(get_grammar_file_name) + ": node from " + RJava.cast_to_string((e.attr_approximate_line_info ? "after " : "")) + "line " + RJava.cast_to_string(e.attr_line) + ":" + RJava.cast_to_string(e.attr_char_position_in_line)
    end
    
    typesig { [RecognitionException, Array.typed(String)] }
    # Tree parsers parse nodes they usually have a token object as
    # payload. Set the exception token and do the default behavior.
    def get_error_message(e, token_names)
      if (self.is_a?(TreeParser))
        adaptor = (e.attr_input).get_tree_adaptor
        e.attr_token = adaptor.get_token(e.attr_node)
        if ((e.attr_token).nil?)
          # could be an UP/DOWN node
          e.attr_token = CommonToken.new(adaptor.get_type(e.attr_node), adaptor.get_text(e.attr_node))
        end
      end
      return super(e, token_names)
    end
    
    typesig { [String, ::Java::Int] }
    def trace_in(rule_name, rule_index)
      super(rule_name, rule_index, @input._lt(1))
    end
    
    typesig { [String, ::Java::Int] }
    def trace_out(rule_name, rule_index)
      super(rule_name, rule_index, @input._lt(1))
    end
    
    private
    alias_method :initialize__tree_parser, :initialize
  end
  
end
