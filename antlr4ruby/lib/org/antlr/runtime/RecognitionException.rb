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
module Org::Antlr::Runtime
  module RecognitionExceptionImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include ::Org::Antlr::Runtime::Tree
    }
  end
  
  # The root of the ANTLR exception hierarchy.
  # 
  # To avoid English-only error messages and to generally make things
  # as flexible as possible, these exceptions are not created with strings,
  # but rather the information necessary to generate an error.  Then
  # the various reporting methods in Parser and Lexer can be overridden
  # to generate a localized error message.  For example, MismatchedToken
  # exceptions are built with the expected token type.
  # So, don't expect getMessage() to return anything.
  # 
  # Note that as of Java 1.4, you can access the stack trace, which means
  # that you can compute the complete trace of rules from the start symbol.
  # This gives you considerable context information with which to generate
  # useful error messages.
  # 
  # ANTLR generates code that throws exceptions upon recognition error and
  # also generates code to catch these exceptions in each rule.  If you
  # want to quit upon first error, you can turn off the automatic error
  # handling mechanism using rulecatch action, but you still need to
  # override methods mismatch and recoverFromMismatchSet.
  # 
  # In general, the recognition exceptions can track where in a grammar a
  # problem occurred and/or what was the expected input.  While the parser
  # knows its state (such as current input symbol and line info) that
  # state can change before the exception is reported so current token index
  # is computed and stored at exception time.  From this info, you can
  # perhaps print an entire line of input not just a single token, for example.
  # Better to just say the recognizer had a problem and then let the parser
  # figure out a fancy report.
  class RecognitionException < RecognitionExceptionImports.const_get :JavaException
    include_class_members RecognitionExceptionImports
    
    # What input stream did the error occur in?
    attr_accessor :input
    alias_method :attr_input, :input
    undef_method :input
    alias_method :attr_input=, :input=
    undef_method :input=
    
    # What is index of token/char were we looking at when the error occurred?
    attr_accessor :index
    alias_method :attr_index, :index
    undef_method :index
    alias_method :attr_index=, :index=
    undef_method :index=
    
    # The current Token when an error occurred.  Since not all streams
    # can retrieve the ith Token, we have to track the Token object.
    # For parsers.  Even when it's a tree parser, token might be set.
    attr_accessor :token
    alias_method :attr_token, :token
    undef_method :token
    alias_method :attr_token=, :token=
    undef_method :token=
    
    # If this is a tree parser exception, node is set to the node with
    # the problem.
    attr_accessor :node
    alias_method :attr_node, :node
    undef_method :node
    alias_method :attr_node=, :node=
    undef_method :node=
    
    # The current char when an error occurred. For lexers.
    attr_accessor :c
    alias_method :attr_c, :c
    undef_method :c
    alias_method :attr_c=, :c=
    undef_method :c=
    
    # Track the line at which the error occurred in case this is
    # generated from a lexer.  We need to track this since the
    # unexpected char doesn't carry the line info.
    attr_accessor :line
    alias_method :attr_line, :line
    undef_method :line
    alias_method :attr_line=, :line=
    undef_method :line=
    
    attr_accessor :char_position_in_line
    alias_method :attr_char_position_in_line, :char_position_in_line
    undef_method :char_position_in_line
    alias_method :attr_char_position_in_line=, :char_position_in_line=
    undef_method :char_position_in_line=
    
    # If you are parsing a tree node stream, you will encounter som
    # imaginary nodes w/o line/col info.  We now search backwards looking
    # for most recent token with line/col info, but notify getErrorHeader()
    # that info is approximate.
    attr_accessor :approximate_line_info
    alias_method :attr_approximate_line_info, :approximate_line_info
    undef_method :approximate_line_info
    alias_method :attr_approximate_line_info=, :approximate_line_info=
    undef_method :approximate_line_info=
    
    typesig { [] }
    # Used for remote debugger deserialization
    def initialize
      @input = nil
      @index = 0
      @token = nil
      @node = nil
      @c = 0
      @line = 0
      @char_position_in_line = 0
      @approximate_line_info = false
      super()
    end
    
    typesig { [IntStream] }
    def initialize(input)
      @input = nil
      @index = 0
      @token = nil
      @node = nil
      @c = 0
      @line = 0
      @char_position_in_line = 0
      @approximate_line_info = false
      super()
      @input = input
      @index = input.index
      if (input.is_a?(TokenStream))
        @token = (input)._lt(1)
        @line = @token.get_line
        @char_position_in_line = @token.get_char_position_in_line
      end
      if (input.is_a?(TreeNodeStream))
        extract_information_from_tree_node_stream(input)
      else
        if (input.is_a?(CharStream))
          @c = input._la(1)
          @line = (input).get_line
          @char_position_in_line = (input).get_char_position_in_line
        else
          @c = input._la(1)
        end
      end
    end
    
    typesig { [IntStream] }
    def extract_information_from_tree_node_stream(input)
      nodes = input
      @node = nodes._lt(1)
      adaptor = nodes.get_tree_adaptor
      payload = adaptor.get_token(@node)
      if (!(payload).nil?)
        @token = payload
        if (payload.get_line <= 0)
          # imaginary node; no line/pos info; scan backwards
          i = -1
          prior_node = nodes._lt(i)
          while (!(prior_node).nil?)
            prior_payload = adaptor.get_token(prior_node)
            if (!(prior_payload).nil? && prior_payload.get_line > 0)
              # we found the most recent real line / pos info
              @line = prior_payload.get_line
              @char_position_in_line = prior_payload.get_char_position_in_line
              @approximate_line_info = true
              break
            end
            (i -= 1)
            prior_node = nodes._lt(i)
          end
        else
          # node created from real token
          @line = payload.get_line
          @char_position_in_line = payload.get_char_position_in_line
        end
      else
        if (@node.is_a?(Tree))
          @line = (@node).get_line
          @char_position_in_line = (@node).get_char_position_in_line
          if (@node.is_a?(CommonTree))
            @token = (@node).attr_token
          end
        else
          type = adaptor.get_type(@node)
          text = adaptor.get_text(@node)
          @token = CommonToken.new(type, text)
        end
      end
    end
    
    typesig { [] }
    # Return the token type or char of the unexpected input element
    def get_unexpected_type
      if (@input.is_a?(TokenStream))
        return @token.get_type
      else
        if (@input.is_a?(TreeNodeStream))
          nodes = @input
          adaptor = nodes.get_tree_adaptor
          return adaptor.get_type(@node)
        else
          return @c
        end
      end
    end
    
    private
    alias_method :initialize__recognition_exception, :initialize
  end
  
end
