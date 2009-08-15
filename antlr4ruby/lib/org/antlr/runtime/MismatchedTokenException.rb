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
  module MismatchedTokenExceptionImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  # A mismatched char or Token or tree node
  class MismatchedTokenException < MismatchedTokenExceptionImports.const_get :RecognitionException
    include_class_members MismatchedTokenExceptionImports
    
    attr_accessor :expecting
    alias_method :attr_expecting, :expecting
    undef_method :expecting
    alias_method :attr_expecting=, :expecting=
    undef_method :expecting=
    
    typesig { [] }
    # Used for remote debugger deserialization
    def initialize
      @expecting = 0
      super()
      @expecting = Token::INVALID_TOKEN_TYPE
    end
    
    typesig { [::Java::Int, IntStream] }
    def initialize(expecting, input)
      @expecting = 0
      super(input)
      @expecting = Token::INVALID_TOKEN_TYPE
      @expecting = expecting
    end
    
    typesig { [] }
    def to_s
      return "MismatchedTokenException(" + RJava.cast_to_string(get_unexpected_type) + "!=" + RJava.cast_to_string(@expecting) + ")"
    end
    
    private
    alias_method :initialize__mismatched_token_exception, :initialize
  end
  
end
