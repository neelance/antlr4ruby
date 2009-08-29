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
  module ActionLabelImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :GrammarAST
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  class ActionLabel < ActionLabelImports.const_get :Label
    include_class_members ActionLabelImports
    
    attr_accessor :action_ast
    alias_method :attr_action_ast, :action_ast
    undef_method :action_ast
    alias_method :attr_action_ast=, :action_ast=
    undef_method :action_ast=
    
    typesig { [GrammarAST] }
    def initialize(action_ast)
      @action_ast = nil
      super(ACTION)
      @action_ast = action_ast
    end
    
    typesig { [] }
    def is_epsilon
      return true # we are to be ignored by analysis 'cept for predicates
    end
    
    typesig { [] }
    def is_action
      return true
    end
    
    typesig { [] }
    def to_s
      return "{" + RJava.cast_to_string(@action_ast) + "}"
    end
    
    typesig { [Grammar] }
    def to_s(g)
      return to_s
    end
    
    private
    alias_method :initialize__action_label, :initialize
  end
  
end
