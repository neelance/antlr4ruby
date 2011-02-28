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
module Org::Antlr::Runtime
  module FailedPredicateExceptionImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  # A semantic predicate failed during validation.  Validation of predicates
  # occurs when normally parsing the alternative just like matching a token.
  # Disambiguating predicate evaluation occurs when we hoist a predicate into
  # a prediction decision.
  class FailedPredicateException < FailedPredicateExceptionImports.const_get :RecognitionException
    include_class_members FailedPredicateExceptionImports
    
    attr_accessor :rule_name
    alias_method :attr_rule_name, :rule_name
    undef_method :rule_name
    alias_method :attr_rule_name=, :rule_name=
    undef_method :rule_name=
    
    attr_accessor :predicate_text
    alias_method :attr_predicate_text, :predicate_text
    undef_method :predicate_text
    alias_method :attr_predicate_text=, :predicate_text=
    undef_method :predicate_text=
    
    typesig { [] }
    # Used for remote debugger deserialization
    def initialize
      @rule_name = nil
      @predicate_text = nil
      super()
    end
    
    typesig { [IntStream, String, String] }
    def initialize(input, rule_name, predicate_text)
      @rule_name = nil
      @predicate_text = nil
      super(input)
      @rule_name = rule_name
      @predicate_text = predicate_text
    end
    
    typesig { [] }
    def to_s
      return "FailedPredicateException(" + @rule_name + ",{" + @predicate_text + "}?)"
    end
    
    private
    alias_method :initialize__failed_predicate_exception, :initialize
  end
  
end
