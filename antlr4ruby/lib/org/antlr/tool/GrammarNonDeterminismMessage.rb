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
  module GrammarNonDeterminismMessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Analysis, :DFAState
      include_const ::Org::Antlr::Analysis, :DecisionProbe
      include_const ::Org::Antlr::Analysis, :NFAState
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Java::Util, :Iterator
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :JavaSet
    }
  end
  
  # Reports a potential parsing issue with a decision; the decision is
  # nondeterministic in some way.
  class GrammarNonDeterminismMessage < GrammarNonDeterminismMessageImports.const_get :Message
    include_class_members GrammarNonDeterminismMessageImports
    
    attr_accessor :probe
    alias_method :attr_probe, :probe
    undef_method :probe
    alias_method :attr_probe=, :probe=
    undef_method :probe=
    
    attr_accessor :problem_state
    alias_method :attr_problem_state, :problem_state
    undef_method :problem_state
    alias_method :attr_problem_state=, :problem_state=
    undef_method :problem_state=
    
    typesig { [DecisionProbe, DFAState] }
    def initialize(probe, problem_state)
      @probe = nil
      @problem_state = nil
      super(ErrorManager::MSG_GRAMMAR_NONDETERMINISM)
      @probe = probe
      @problem_state = problem_state
      # flip msg ID if alts are actually token refs in Tokens rule
      if (probe.attr_dfa.is_tokens_rule_decision)
        set_message_id(ErrorManager::MSG_TOKEN_NONDETERMINISM)
      end
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
      # Now fill template with information about problemState
      labels = @probe.get_sample_non_deterministic_input_sequence(@problem_state)
      input = @probe.get_input_sequence_display(labels)
      st.set_attribute("input", input)
      if (@probe.attr_dfa.is_tokens_rule_decision)
        disabled_alts = @probe.get_disabled_alternatives(@problem_state)
        it = disabled_alts.iterator
        while it.has_next
          alt_i = it.next_
          token_name = @probe.get_token_name_for_tokens_rule_alt(alt_i.int_value)
          # reset the line/col to the token definition (pick last one)
          rule_start = @probe.attr_dfa.attr_nfa.attr_grammar.get_rule_start_state(token_name)
          self.attr_line = rule_start.attr_associated_astnode.get_line
          self.attr_column = rule_start.attr_associated_astnode.get_column
          st.set_attribute("disabled", token_name)
        end
      else
        st.set_attribute("disabled", @probe.get_disabled_alternatives(@problem_state))
      end
      nondet_alts = @probe.get_non_deterministic_alts_for_state(@problem_state)
      nfa_start = @probe.attr_dfa.get_nfadecision_start_state
      # all state paths have to begin with same NFA state
      first_alt = 0
      if (!(nondet_alts).nil?)
        iter = nondet_alts.iterator
        while iter.has_next
          display_alt_i = iter.next_
          if (DecisionProbe.attr_verbose)
            trace_path_alt = nfa_start.translate_display_alt_to_walk_alt(display_alt_i.int_value)
            if ((first_alt).equal?(0))
              first_alt = trace_path_alt
            end
            path = @probe.get_nfapath_states_for_alt(first_alt, trace_path_alt, labels)
            st.set_attribute("paths.{alt,states}", display_alt_i, path)
          else
            if (@probe.attr_dfa.is_tokens_rule_decision)
              # alts are token rules, convert to the names instead of numbers
              token_name = @probe.get_token_name_for_tokens_rule_alt(display_alt_i.int_value)
              st.set_attribute("conflictingTokens", token_name)
            else
              st.set_attribute("conflictingAlts", display_alt_i)
            end
          end
        end
      end
      st.set_attribute("hasPredicateBlockedByAction", @problem_state.attr_dfa.attr_has_predicate_blocked_by_action)
      return super(st)
    end
    
    private
    alias_method :initialize__grammar_non_determinism_message, :initialize
  end
  
end
