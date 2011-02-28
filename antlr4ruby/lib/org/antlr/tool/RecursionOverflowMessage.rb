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
  module RecursionOverflowMessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include ::Org::Antlr::Analysis
      include_const ::Antlr, :Token
      include ::Java::Util
    }
  end
  
  # Indicates recursion overflow.  A DFA state tried add an NFA configuration
  # with NFA state p that was mentioned in its stack context too many times.
  class RecursionOverflowMessage < RecursionOverflowMessageImports.const_get :Message
    include_class_members RecursionOverflowMessageImports
    
    attr_accessor :probe
    alias_method :attr_probe, :probe
    undef_method :probe
    alias_method :attr_probe=, :probe=
    undef_method :probe=
    
    attr_accessor :sample_bad_state
    alias_method :attr_sample_bad_state, :sample_bad_state
    undef_method :sample_bad_state
    alias_method :attr_sample_bad_state=, :sample_bad_state=
    undef_method :sample_bad_state=
    
    attr_accessor :alt
    alias_method :attr_alt, :alt
    undef_method :alt
    alias_method :attr_alt=, :alt=
    undef_method :alt=
    
    attr_accessor :target_rules
    alias_method :attr_target_rules, :target_rules
    undef_method :target_rules
    alias_method :attr_target_rules=, :target_rules=
    undef_method :target_rules=
    
    attr_accessor :call_site_states
    alias_method :attr_call_site_states, :call_site_states
    undef_method :call_site_states
    alias_method :attr_call_site_states=, :call_site_states=
    undef_method :call_site_states=
    
    typesig { [DecisionProbe, DFAState, ::Java::Int, Collection, Collection] }
    def initialize(probe, sample_bad_state, alt, target_rules, call_site_states)
      @probe = nil
      @sample_bad_state = nil
      @alt = 0
      @target_rules = nil
      @call_site_states = nil
      super(ErrorManager::MSG_RECURSION_OVERLOW)
      @probe = probe
      @sample_bad_state = sample_bad_state
      @alt = alt
      @target_rules = target_rules
      @call_site_states = call_site_states
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
      st.set_attribute("targetRules", @target_rules)
      st.set_attribute("alt", @alt)
      st.set_attribute("callSiteStates", @call_site_states)
      labels = @probe.get_sample_non_deterministic_input_sequence(@sample_bad_state)
      input = @probe.get_input_sequence_display(labels)
      st.set_attribute("input", input)
      return super(st)
    end
    
    private
    alias_method :initialize__recursion_overflow_message, :initialize
  end
  
end
