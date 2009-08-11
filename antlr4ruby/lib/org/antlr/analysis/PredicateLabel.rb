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
module Org::Antlr::Analysis
  module PredicateLabelImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :GrammarAST
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  class PredicateLabel < PredicateLabelImports.const_get :Label
    include_class_members PredicateLabelImports
    
    # A tree of semantic predicates from the grammar AST if label==SEMPRED.
    # In the NFA, labels will always be exactly one predicate, but the DFA
    # may have to combine a bunch of them as it collects predicates from
    # multiple NFA configurations into a single DFA state.
    attr_accessor :semantic_context
    alias_method :attr_semantic_context, :semantic_context
    undef_method :semantic_context
    alias_method :attr_semantic_context=, :semantic_context=
    undef_method :semantic_context=
    
    typesig { [GrammarAST] }
    # Make a semantic predicate label
    def initialize(predicate_astnode)
      @semantic_context = nil
      super(SEMPRED)
      @semantic_context = SemanticContext::Predicate.new(predicate_astnode)
    end
    
    typesig { [SemanticContext] }
    # Make a semantic predicates label
    def initialize(sem_ctx)
      @semantic_context = nil
      super(SEMPRED)
      @semantic_context = sem_ctx
    end
    
    typesig { [] }
    def hash_code
      return @semantic_context.hash_code
    end
    
    typesig { [Object] }
    def equals(o)
      if ((o).nil?)
        return false
      end
      if ((self).equal?(o))
        return true # equals if same object
      end
      if (!(o.is_a?(PredicateLabel)))
        return false
      end
      return (@semantic_context == (o).attr_semantic_context)
    end
    
    typesig { [] }
    def is_semantic_predicate
      return true
    end
    
    typesig { [] }
    def get_semantic_context
      return @semantic_context
    end
    
    typesig { [] }
    def to_s
      return "{" + (@semantic_context).to_s + "}?"
    end
    
    typesig { [Grammar] }
    def to_s(g)
      return to_s
    end
    
    private
    alias_method :initialize__predicate_label, :initialize
  end
  
end
