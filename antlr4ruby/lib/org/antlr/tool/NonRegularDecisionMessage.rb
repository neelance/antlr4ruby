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
module Org::Antlr::Tool
  module NonRegularDecisionMessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Analysis, :DecisionProbe
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include ::Java::Util
    }
  end
  
  # More a single alternative recurses so this decision is not regular.
  class NonRegularDecisionMessage < NonRegularDecisionMessageImports.const_get :Message
    include_class_members NonRegularDecisionMessageImports
    
    attr_accessor :probe
    alias_method :attr_probe, :probe
    undef_method :probe
    alias_method :attr_probe=, :probe=
    undef_method :probe=
    
    attr_accessor :alts_with_recursion
    alias_method :attr_alts_with_recursion, :alts_with_recursion
    undef_method :alts_with_recursion
    alias_method :attr_alts_with_recursion=, :alts_with_recursion=
    undef_method :alts_with_recursion=
    
    typesig { [DecisionProbe, JavaSet] }
    def initialize(probe, alts_with_recursion)
      @probe = nil
      @alts_with_recursion = nil
      super(ErrorManager::MSG_NONREGULAR_DECISION)
      @probe = probe
      @alts_with_recursion = alts_with_recursion
    end
    
    typesig { [] }
    def to_s
      decision_astnode = @probe.attr_dfa.get_decision_astnode
      self.attr_line = decision_astnode.get_line
      self.attr_column = decision_astnode.get_column
      file_name = @probe.attr_dfa.attr_nfa.attr_grammar.get_file_name
      if (!(file_name).nil?)
        self.attr_file = file_name
      end
      st = get_message_template
      rule_name = @probe.attr_dfa.get_nfadecision_start_state.attr_enclosing_rule.attr_name
      st.set_attribute("ruleName", rule_name)
      sorted_alts = ArrayList.new
      sorted_alts.add_all(@alts_with_recursion)
      Collections.sort(sorted_alts) # make sure it's 1, 2, ...
      st.set_attribute("alts", sorted_alts)
      return super(st)
    end
    
    private
    alias_method :initialize__non_regular_decision_message, :initialize
  end
  
end
