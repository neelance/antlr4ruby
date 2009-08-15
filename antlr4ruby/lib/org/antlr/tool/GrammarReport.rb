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
  module GrammarReportImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Analysis, :DFA
      include_const ::Org::Antlr::Runtime::Misc, :Stats
      include_const ::Org::Antlr::Misc, :Utils
      include ::Java::Util
    }
  end
  
  class GrammarReport 
    include_class_members GrammarReportImports
    
    class_module.module_eval {
      # Because I may change the stats, I need to track that for later
      # computations to be consistent.
      const_set_lazy(:Version) { "4" }
      const_attr_reader  :Version
      
      const_set_lazy(:GRAMMAR_STATS_FILENAME) { "grammar.stats" }
      const_attr_reader  :GRAMMAR_STATS_FILENAME
      
      const_set_lazy(:NUM_GRAMMAR_STATS) { 41 }
      const_attr_reader  :NUM_GRAMMAR_STATS
      
      const_set_lazy(:Newline) { System.get_property("line.separator") }
      const_attr_reader  :Newline
    }
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    typesig { [Grammar] }
    def initialize(grammar)
      @grammar = nil
      @grammar = grammar
    end
    
    typesig { [] }
    # Create a single-line stats report about this grammar suitable to
    # send to the notify page at antlr.org
    def to_notify_string
      buf = StringBuffer.new
      buf.append(Version)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_name)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.get_grammar_type_string)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.get_option("language"))
      total_non_syn_pred_productions = 0
      total_non_syn_pred_rules = 0
      rules = @grammar.get_rules
      it = rules.iterator
      while it.has_next
        r = it.next_
        if (!r.attr_name.to_upper_case.starts_with(Grammar::SYNPRED_RULE_PREFIX.to_upper_case))
          total_non_syn_pred_productions += r.attr_number_of_alts
          total_non_syn_pred_rules += 1
        end
      end
      buf.append(Character.new(?\t.ord))
      buf.append(total_non_syn_pred_rules)
      buf.append(Character.new(?\t.ord))
      buf.append(total_non_syn_pred_productions)
      num_acyclic_decisions = @grammar.get_number_of_decisions - @grammar.get_number_of_cyclic_decisions
      depths = Array.typed(::Java::Int).new(num_acyclic_decisions) { 0 }
      acyclic_dfastates = Array.typed(::Java::Int).new(num_acyclic_decisions) { 0 }
      cyclic_dfastates = Array.typed(::Java::Int).new(@grammar.get_number_of_cyclic_decisions) { 0 }
      acyclic_index = 0
      cyclic_index = 0
      num_ll1 = 0
      num_dec = 0
      i = 1
      while i <= @grammar.get_number_of_decisions
        d = @grammar.get_decision(i)
        if ((d.attr_dfa).nil?)
          i += 1
          next
        end
        num_dec += 1
        if (!d.attr_dfa.is_cyclic)
          maxk = d.attr_dfa.get_max_lookahead_depth
          if ((maxk).equal?(1))
            num_ll1 += 1
          end
          depths[acyclic_index] = maxk
          acyclic_dfastates[acyclic_index] = d.attr_dfa.get_number_of_states
          acyclic_index += 1
        else
          cyclic_dfastates[cyclic_index] = d.attr_dfa.get_number_of_states
          cyclic_index += 1
        end
        i += 1
      end
      buf.append(Character.new(?\t.ord))
      buf.append(num_dec)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.get_number_of_cyclic_decisions)
      buf.append(Character.new(?\t.ord))
      buf.append(num_ll1)
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.min(depths))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.max(depths))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.avg(depths))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.stddev(depths))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.min(acyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.max(acyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.avg(acyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.stddev(acyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.sum(acyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.min(cyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.max(cyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.avg(cyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.stddev(cyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.sum(cyclic_dfastates))
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.get_token_types.size)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_dfacreation_wall_clock_time_in_ms)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_number_of_semantic_predicates)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_number_of_manual_lookahead_options)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_set_of_nondeterministic_decision_numbers.size)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_set_of_nondeterministic_decision_numbers_resolved_with_predicates.size)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_set_of_dfawhose_analysis_timed_out.size)
      buf.append(Character.new(?\t.ord))
      buf.append(ErrorManager.get_error_state.attr_errors)
      buf.append(Character.new(?\t.ord))
      buf.append(ErrorManager.get_error_state.attr_warnings)
      buf.append(Character.new(?\t.ord))
      buf.append(ErrorManager.get_error_state.attr_infos)
      buf.append(Character.new(?\t.ord))
      synpreds = @grammar.get_syntactic_predicates
      num_synpreds = !(synpreds).nil? ? synpreds.size : 0
      buf.append(num_synpreds)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_blocks_with_syn_preds.size)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_decisions_whose_dfas_uses_syn_preds.size)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_blocks_with_sem_preds.size)
      buf.append(Character.new(?\t.ord))
      buf.append(@grammar.attr_decisions_whose_dfas_uses_sem_preds.size)
      buf.append(Character.new(?\t.ord))
      output = @grammar.get_option("output")
      if ((output).nil?)
        output = "none"
      end
      buf.append(output)
      buf.append(Character.new(?\t.ord))
      k = @grammar.get_option("k")
      if ((k).nil?)
        k = "none"
      end
      buf.append(k)
      buf.append(Character.new(?\t.ord))
      backtrack = @grammar.get_option("backtrack")
      if ((backtrack).nil?)
        backtrack = "false"
      end
      buf.append(backtrack)
      return buf.to_s
    end
    
    typesig { [] }
    def get_backtracking_report
      buf = StringBuffer.new
      buf.append("Backtracking report:")
      buf.append(Newline)
      buf.append("Number of decisions that backtrack: ")
      buf.append(@grammar.attr_decisions_whose_dfas_uses_syn_preds.size)
      buf.append(Newline)
      buf.append(get_dfalocations(@grammar.attr_decisions_whose_dfas_uses_syn_preds))
      return buf.to_s
    end
    
    typesig { [] }
    def get_analysis_timeout_report
      buf = StringBuffer.new
      buf.append("NFA conversion early termination report:")
      buf.append(Newline)
      buf.append("Number of NFA conversions that terminated early: ")
      buf.append(@grammar.attr_set_of_dfawhose_analysis_timed_out.size)
      buf.append(Newline)
      buf.append(get_dfalocations(@grammar.attr_set_of_dfawhose_analysis_timed_out))
      return buf.to_s
    end
    
    typesig { [JavaSet] }
    def get_dfalocations(dfas)
      decisions = HashSet.new
      buf = StringBuffer.new
      it = dfas.iterator
      while (it.has_next)
        dfa = it.next_
        # if we aborted a DFA and redid with k=1, the backtrackin
        if (decisions.contains(Utils.integer(dfa.attr_decision_number)))
          next
        end
        decisions.add(Utils.integer(dfa.attr_decision_number))
        buf.append("Rule ")
        buf.append(dfa.attr_decision_nfastart_state.attr_enclosing_rule.attr_name)
        buf.append(" decision ")
        buf.append(dfa.attr_decision_number)
        buf.append(" location ")
        decision_ast = dfa.attr_decision_nfastart_state.attr_associated_astnode
        buf.append(decision_ast.get_line)
        buf.append(":")
        buf.append(decision_ast.get_column)
        buf.append(Newline)
      end
      return buf.to_s
    end
    
    typesig { [] }
    # Given a stats line suitable for sending to the antlr.org site,
    # return a human-readable version.  Return null if there is a
    # problem with the data.
    def to_s
      return to_s(to_notify_string)
    end
    
    class_module.module_eval {
      typesig { [String] }
      def decode_report_data(data)
        fields = Array.typed(String).new(NUM_GRAMMAR_STATS) { nil }
        st = StringTokenizer.new(data, "\t")
        i = 0
        while (st.has_more_tokens)
          fields[i] = st.next_token
          i += 1
        end
        if (!(i).equal?(NUM_GRAMMAR_STATS))
          return nil
        end
        return fields
      end
      
      typesig { [String] }
      def to_s(notify_data_line)
        fields = decode_report_data(notify_data_line)
        if ((fields).nil?)
          return nil
        end
        buf = StringBuffer.new
        buf.append("ANTLR Grammar Report; Stats Version ")
        buf.append(fields[0])
        buf.append(Character.new(?\n.ord))
        buf.append("Grammar: ")
        buf.append(fields[1])
        buf.append(Character.new(?\n.ord))
        buf.append("Type: ")
        buf.append(fields[2])
        buf.append(Character.new(?\n.ord))
        buf.append("Target language: ")
        buf.append(fields[3])
        buf.append(Character.new(?\n.ord))
        buf.append("Output: ")
        buf.append(fields[38])
        buf.append(Character.new(?\n.ord))
        buf.append("Grammar option k: ")
        buf.append(fields[39])
        buf.append(Character.new(?\n.ord))
        buf.append("Grammar option backtrack: ")
        buf.append(fields[40])
        buf.append(Character.new(?\n.ord))
        buf.append("Rules: ")
        buf.append(fields[4])
        buf.append(Character.new(?\n.ord))
        buf.append("Productions: ")
        buf.append(fields[5])
        buf.append(Character.new(?\n.ord))
        buf.append("Decisions: ")
        buf.append(fields[6])
        buf.append(Character.new(?\n.ord))
        buf.append("Cyclic DFA decisions: ")
        buf.append(fields[7])
        buf.append(Character.new(?\n.ord))
        buf.append("LL(1) decisions: ")
        buf.append(fields[8])
        buf.append(Character.new(?\n.ord))
        buf.append("Min fixed k: ")
        buf.append(fields[9])
        buf.append(Character.new(?\n.ord))
        buf.append("Max fixed k: ")
        buf.append(fields[10])
        buf.append(Character.new(?\n.ord))
        buf.append("Average fixed k: ")
        buf.append(fields[11])
        buf.append(Character.new(?\n.ord))
        buf.append("Standard deviation of fixed k: ")
        buf.append(fields[12])
        buf.append(Character.new(?\n.ord))
        buf.append("Min acyclic DFA states: ")
        buf.append(fields[13])
        buf.append(Character.new(?\n.ord))
        buf.append("Max acyclic DFA states: ")
        buf.append(fields[14])
        buf.append(Character.new(?\n.ord))
        buf.append("Average acyclic DFA states: ")
        buf.append(fields[15])
        buf.append(Character.new(?\n.ord))
        buf.append("Standard deviation of acyclic DFA states: ")
        buf.append(fields[16])
        buf.append(Character.new(?\n.ord))
        buf.append("Total acyclic DFA states: ")
        buf.append(fields[17])
        buf.append(Character.new(?\n.ord))
        buf.append("Min cyclic DFA states: ")
        buf.append(fields[18])
        buf.append(Character.new(?\n.ord))
        buf.append("Max cyclic DFA states: ")
        buf.append(fields[19])
        buf.append(Character.new(?\n.ord))
        buf.append("Average cyclic DFA states: ")
        buf.append(fields[20])
        buf.append(Character.new(?\n.ord))
        buf.append("Standard deviation of cyclic DFA states: ")
        buf.append(fields[21])
        buf.append(Character.new(?\n.ord))
        buf.append("Total cyclic DFA states: ")
        buf.append(fields[22])
        buf.append(Character.new(?\n.ord))
        buf.append("Vocabulary size: ")
        buf.append(fields[23])
        buf.append(Character.new(?\n.ord))
        buf.append("DFA creation time in ms: ")
        buf.append(fields[24])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of semantic predicates found: ")
        buf.append(fields[25])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of manual fixed lookahead k=value options: ")
        buf.append(fields[26])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of nondeterministic decisions: ")
        buf.append(fields[27])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of nondeterministic decisions resolved with predicates: ")
        buf.append(fields[28])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of DFA conversions terminated early: ")
        buf.append(fields[29])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of errors: ")
        buf.append(fields[30])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of warnings: ")
        buf.append(fields[31])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of infos: ")
        buf.append(fields[32])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of syntactic predicates found: ")
        buf.append(fields[33])
        buf.append(Character.new(?\n.ord))
        buf.append("Decisions with syntactic predicates: ")
        buf.append(fields[34])
        buf.append(Character.new(?\n.ord))
        buf.append("Decision DFAs using syntactic predicates: ")
        buf.append(fields[35])
        buf.append(Character.new(?\n.ord))
        buf.append("Decisions with semantic predicates: ")
        buf.append(fields[36])
        buf.append(Character.new(?\n.ord))
        buf.append("Decision DFAs using semantic predicates: ")
        buf.append(fields[37])
        buf.append(Character.new(?\n.ord))
        return buf.to_s
      end
    }
    
    private
    alias_method :initialize__grammar_report, :initialize
  end
  
end
