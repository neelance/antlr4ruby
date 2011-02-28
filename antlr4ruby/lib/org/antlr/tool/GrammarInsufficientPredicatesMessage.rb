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
  module GrammarInsufficientPredicatesMessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include ::Org::Antlr::Analysis
      include_const ::Antlr, :Token
      include ::Java::Util
    }
  end
  
  class GrammarInsufficientPredicatesMessage < GrammarInsufficientPredicatesMessageImports.const_get :Message
    include_class_members GrammarInsufficientPredicatesMessageImports
    
    attr_accessor :probe
    alias_method :attr_probe, :probe
    undef_method :probe
    alias_method :attr_probe=, :probe=
    undef_method :probe=
    
    attr_accessor :alt_to_locations
    alias_method :attr_alt_to_locations, :alt_to_locations
    undef_method :alt_to_locations
    alias_method :attr_alt_to_locations=, :alt_to_locations=
    undef_method :alt_to_locations=
    
    attr_accessor :problem_state
    alias_method :attr_problem_state, :problem_state
    undef_method :problem_state
    alias_method :attr_problem_state=, :problem_state=
    undef_method :problem_state=
    
    typesig { [DecisionProbe, DFAState, Map] }
    def initialize(probe, problem_state, alt_to_locations)
      @probe = nil
      @alt_to_locations = nil
      @problem_state = nil
      super(ErrorManager::MSG_INSUFFICIENT_PREDICATES)
      @probe = probe
      @problem_state = problem_state
      @alt_to_locations = alt_to_locations
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
      # convert to string key to avoid 3.1 ST bug
      alt_to_locations_with_string_key = LinkedHashMap.new
      alts = ArrayList.new
      alts.add_all(@alt_to_locations.key_set)
      Collections.sort(alts)
      alts.each do |altI|
        alt_to_locations_with_string_key.put(alt_i.to_s, @alt_to_locations.get(alt_i))
      end
      st.set_attribute("altToLocations", alt_to_locations_with_string_key)
      sample_input_labels = @problem_state.attr_dfa.attr_probe.get_sample_non_deterministic_input_sequence(@problem_state)
      input = @problem_state.attr_dfa.attr_probe.get_input_sequence_display(sample_input_labels)
      st.set_attribute("upon", input)
      st.set_attribute("hasPredicateBlockedByAction", @problem_state.attr_dfa.attr_has_predicate_blocked_by_action)
      return super(st)
    end
    
    private
    alias_method :initialize__grammar_insufficient_predicates_message, :initialize
  end
  
end
