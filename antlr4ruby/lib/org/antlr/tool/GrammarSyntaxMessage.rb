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
  module GrammarSyntaxMessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Antlr, :Token
    }
  end
  
  # A problem with the syntax of your antlr grammar such as
  # "The '{' came as a complete surprise to me at this point in your program"
  class GrammarSyntaxMessage < GrammarSyntaxMessageImports.const_get :Message
    include_class_members GrammarSyntaxMessageImports
    
    attr_accessor :g
    alias_method :attr_g, :g
    undef_method :g
    alias_method :attr_g=, :g=
    undef_method :g=
    
    # Most of the time, we'll have a token and so this will be set.
    attr_accessor :offending_token
    alias_method :attr_offending_token, :offending_token
    undef_method :offending_token
    alias_method :attr_offending_token=, :offending_token=
    undef_method :offending_token=
    
    attr_accessor :exception
    alias_method :attr_exception, :exception
    undef_method :exception
    alias_method :attr_exception=, :exception=
    undef_method :exception=
    
    typesig { [::Java::Int, Grammar, Token, Antlr::RecognitionException] }
    def initialize(msg_id, grammar, offending_token, exception)
      initialize__grammar_syntax_message(msg_id, grammar, offending_token, nil, exception)
    end
    
    typesig { [::Java::Int, Grammar, Token, Object, Antlr::RecognitionException] }
    def initialize(msg_id, grammar, offending_token, arg, exception)
      @g = nil
      @offending_token = nil
      @exception = nil
      super(msg_id, arg, nil)
      @offending_token = offending_token
      @exception = exception
      @g = grammar
    end
    
    typesig { [] }
    def to_s
      self.attr_line = 0
      self.attr_column = 0
      if (!(@offending_token).nil?)
        self.attr_line = @offending_token.get_line
        self.attr_column = @offending_token.get_column
      end
      # TODO: actually set the right Grammar instance to get the filename
      # TODO: have to update all v2 grammar files for this. or use errormanager and tool to get the current grammar
      if (!(@g).nil?)
        self.attr_file = @g.get_file_name
      end
      st = get_message_template
      if (!(self.attr_arg).nil?)
        st.set_attribute("arg", self.attr_arg)
      end
      return super(st)
    end
    
    private
    alias_method :initialize__grammar_syntax_message, :initialize
  end
  
end
