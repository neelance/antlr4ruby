require "rjava"

# 
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
  module MissingTokenExceptionImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  # We were expecting a token but it's not found.  The current token
  # is actually what we wanted next.  Used for tree node errors too.
  class MissingTokenException < MissingTokenExceptionImports.const_get :MismatchedTokenException
    include_class_members MissingTokenExceptionImports
    
    attr_accessor :inserted
    alias_method :attr_inserted, :inserted
    undef_method :inserted
    alias_method :attr_inserted=, :inserted=
    undef_method :inserted=
    
    typesig { [] }
    # Used for remote debugger deserialization
    def initialize
      @inserted = nil
      super()
    end
    
    typesig { [::Java::Int, IntStream, Object] }
    def initialize(expecting, input, inserted)
      @inserted = nil
      super(expecting, input)
      @inserted = inserted
    end
    
    typesig { [] }
    def get_missing_type
      return self.attr_expecting
    end
    
    typesig { [] }
    def to_s
      if (!(@inserted).nil? && !(self.attr_token).nil?)
        return "MissingTokenException(inserted " + (@inserted).to_s + " at " + (self.attr_token.get_text).to_s + ")"
      end
      if (!(self.attr_token).nil?)
        return "MissingTokenException(at " + (self.attr_token.get_text).to_s + ")"
      end
      return "MissingTokenException"
    end
    
    private
    alias_method :initialize__missing_token_exception, :initialize
  end
  
end
