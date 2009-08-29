require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
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
  module RuleClosureTransitionImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Org::Antlr::Tool, :Rule
    }
  end
  
  # A transition used to reference another rule.  It tracks two targets
  # really: the actual transition target and the state following the
  # state that refers to the other rule.  Conversion of an NFA that
  # falls off the end of a rule will be able to figure out who invoked
  # that rule because of these special transitions.
  class RuleClosureTransition < RuleClosureTransitionImports.const_get :Transition
    include_class_members RuleClosureTransitionImports
    
    # Ptr to the rule definition object for this rule ref
    attr_accessor :rule
    alias_method :attr_rule, :rule
    undef_method :rule
    alias_method :attr_rule=, :rule=
    undef_method :rule=
    
    # What node to begin computations following ref to rule
    attr_accessor :follow_state
    alias_method :attr_follow_state, :follow_state
    undef_method :follow_state
    alias_method :attr_follow_state=, :follow_state=
    undef_method :follow_state=
    
    typesig { [Rule, NFAState, NFAState] }
    def initialize(rule, rule_start, follow_state)
      @rule = nil
      @follow_state = nil
      super(Label::EPSILON, rule_start)
      @rule = rule
      @follow_state = follow_state
    end
    
    private
    alias_method :initialize__rule_closure_transition, :initialize
  end
  
end
