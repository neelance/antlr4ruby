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
  module GrammarDanglingStateMessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Analysis, :DFAState
      include_const ::Org::Antlr::Analysis, :DecisionProbe
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :Collections
      include_const ::Java::Util, :JavaList
    }
  end
  
  # Reports a potential parsing issue with a decision; the decision is
  # nondeterministic in some way.
  class GrammarDanglingStateMessage < GrammarDanglingStateMessageImports.const_get :Message
    include_class_members GrammarDanglingStateMessageImports
    
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
      super(ErrorManager::MSG_DANGLING_STATE)
      @probe = probe
      @problem_state = problem_state
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
      labels = @probe.get_sample_non_deterministic_input_sequence(@problem_state)
      input = @probe.get_input_sequence_display(labels)
      st = get_message_template
      alts = ArrayList.new
      alts.add_all(@problem_state.get_alt_set)
      Collections.sort(alts)
      st.set_attribute("danglingAlts", alts)
      st.set_attribute("input", input)
      return super(st)
    end
    
    private
    alias_method :initialize__grammar_dangling_state_message, :initialize
  end
  
end
