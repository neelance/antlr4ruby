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
  module DOTGeneratorImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr, :Tool
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateGroup
      include_const ::Org::Antlr::Stringtemplate::Language, :AngleBracketTemplateLexer
      include ::Java::Util
    }
  end
  
  # The DOT (part of graphviz) generation aspect.
  class DOTGenerator 
    include_class_members DOTGeneratorImports
    
    class_module.module_eval {
      const_set_lazy(:STRIP_NONREDUCED_STATES) { false }
      const_attr_reader  :STRIP_NONREDUCED_STATES
    }
    
    attr_accessor :arrowhead
    alias_method :attr_arrowhead, :arrowhead
    undef_method :arrowhead
    alias_method :attr_arrowhead=, :arrowhead=
    undef_method :arrowhead=
    
    attr_accessor :rankdir
    alias_method :attr_rankdir, :rankdir
    undef_method :rankdir
    alias_method :attr_rankdir=, :rankdir=
    undef_method :rankdir=
    
    class_module.module_eval {
      # Library of output templates; use <attrname> format
      
      def stlib
        defined?(@@stlib) ? @@stlib : @@stlib= StringTemplateGroup.new("toollib", AngleBracketTemplateLexer)
      end
      alias_method :attr_stlib, :stlib
      
      def stlib=(value)
        @@stlib = value
      end
      alias_method :attr_stlib=, :stlib=
    }
    
    # To prevent infinite recursion when walking state machines, record
    # which states we've visited.  Make a new set every time you start
    # walking in case you reuse this object.
    attr_accessor :marked_states
    alias_method :attr_marked_states, :marked_states
    undef_method :marked_states
    alias_method :attr_marked_states=, :marked_states=
    undef_method :marked_states=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    typesig { [Grammar] }
    # This aspect is associated with a grammar
    def initialize(grammar)
      @arrowhead = "normal"
      @rankdir = "LR"
      @marked_states = nil
      @grammar = nil
      @grammar = grammar
    end
    
    typesig { [State] }
    # Return a String containing a DOT description that, when displayed,
    # will show the incoming state machine visually.  All nodes reachable
    # from startState will be included.
    def get_dot(start_state)
      if ((start_state).nil?)
        return nil
      end
      # The output DOT graph for visualization
      dot = nil
      @marked_states = HashSet.new
      if (start_state.is_a?(DFAState))
        dot = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/dfa")
        dot.set_attribute("startState", Utils.integer(start_state.attr_state_number))
        dot.set_attribute("useBox", Boolean.value_of(Tool.attr_internal_option_show_nfaconfigs_in_dfa))
        walk_creating_dfadot(dot, start_state)
      else
        dot = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/nfa")
        dot.set_attribute("startState", Utils.integer(start_state.attr_state_number))
        walk_rule_nfacreating_dot(dot, start_state)
      end
      dot.set_attribute("rankdir", @rankdir)
      return dot.to_s
    end
    
    typesig { [StringTemplate, DFAState] }
    # Return a String containing a DOT description that, when displayed,
    # will show the incoming state machine visually.  All nodes reachable
    # from startState will be included.
    # public String getRuleNFADOT(State startState) {
    # // The output DOT graph for visualization
    # StringTemplate dot = stlib.getInstanceOf("org/antlr/tool/templates/dot/nfa");
    # 
    # markedStates = new HashSet();
    # dot.setAttribute("startState",
    # Utils.integer(startState.stateNumber));
    # walkRuleNFACreatingDOT(dot, startState);
    # return dot.toString();
    # }
    # 
    # Do a depth-first walk of the state machine graph and
    # fill a DOT description template.  Keep filling the
    # states and edges attributes.
    def walk_creating_dfadot(dot, s)
      if (@marked_states.contains(Utils.integer(s.attr_state_number)))
        return # already visited this node
      end
      @marked_states.add(Utils.integer(s.attr_state_number)) # mark this node as completed.
      # first add this node
      st = nil
      if (s.is_accept_state)
        st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/stopstate")
      else
        st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/state")
      end
      st.set_attribute("name", get_state_label(s))
      dot.set_attribute("states", st)
      # make a DOT edge for each transition
      i = 0
      while i < s.get_number_of_transitions
        edge = s.transition(i)
        # System.out.println("dfa "+s.dfa.decisionNumber+
        # " edge from s"+s.stateNumber+" ["+i+"] of "+s.getNumberOfTransitions());
        if (STRIP_NONREDUCED_STATES)
          if (edge.attr_target.is_a?(DFAState) && !((edge.attr_target).get_accept_state_reachable).equal?(DFA::REACHABLE_YES))
            i += 1
            next # don't generate nodes for terminal states
          end
        end
        st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/edge")
        st.set_attribute("label", get_edge_label(edge))
        st.set_attribute("src", get_state_label(s))
        st.set_attribute("target", get_state_label(edge.attr_target))
        st.set_attribute("arrowhead", @arrowhead)
        dot.set_attribute("edges", st)
        walk_creating_dfadot(dot, edge.attr_target) # keep walkin'
        i += 1
      end
    end
    
    typesig { [StringTemplate, State] }
    # Do a depth-first walk of the state machine graph and
    # fill a DOT description template.  Keep filling the
    # states and edges attributes.  We know this is an NFA
    # for a rule so don't traverse edges to other rules and
    # don't go past rule end state.
    def walk_rule_nfacreating_dot(dot, s)
      if (@marked_states.contains(s))
        return # already visited this node
      end
      @marked_states.add(s) # mark this node as completed.
      # first add this node
      state_st = nil
      if (s.is_accept_state)
        state_st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/stopstate")
      else
        state_st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/state")
      end
      state_st.set_attribute("name", get_state_label(s))
      dot.set_attribute("states", state_st)
      if (s.is_accept_state)
        return # don't go past end of rule node to the follow states
      end
      # special case: if decision point, then line up the alt start states
      # unless it's an end of block
      if ((s).is_decision_state)
        n = (s).attr_associated_astnode
        if (!(n).nil? && !(n.get_type).equal?(ANTLRParser::EOB))
          rank_st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/decision-rank")
          alt = s
          while (!(alt).nil?)
            rank_st.set_attribute("states", get_state_label(alt))
            if (!(alt.attr_transition[1]).nil?)
              alt = alt.attr_transition[1].attr_target
            else
              alt = nil
            end
          end
          dot.set_attribute("decisionRanks", rank_st)
        end
      end
      # make a DOT edge for each transition
      edge_st = nil
      i = 0
      while i < s.get_number_of_transitions
        edge = s.transition(i)
        if (edge.is_a?(RuleClosureTransition))
          rr = (edge)
          # don't jump to other rules, but display edge to follow node
          edge_st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/edge")
          if (!(rr.attr_rule.attr_grammar).equal?(@grammar))
            edge_st.set_attribute("label", "<" + RJava.cast_to_string(rr.attr_rule.attr_grammar.attr_name) + "." + RJava.cast_to_string(rr.attr_rule.attr_name) + ">")
          else
            edge_st.set_attribute("label", "<" + RJava.cast_to_string(rr.attr_rule.attr_name) + ">")
          end
          edge_st.set_attribute("src", get_state_label(s))
          edge_st.set_attribute("target", get_state_label(rr.attr_follow_state))
          edge_st.set_attribute("arrowhead", @arrowhead)
          dot.set_attribute("edges", edge_st)
          walk_rule_nfacreating_dot(dot, rr.attr_follow_state)
          i += 1
          next
        end
        if (edge.is_action)
          edge_st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/action-edge")
        else
          if (edge.is_epsilon)
            edge_st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/epsilon-edge")
          else
            edge_st = self.attr_stlib.get_instance_of("org/antlr/tool/templates/dot/edge")
          end
        end
        edge_st.set_attribute("label", get_edge_label(edge))
        edge_st.set_attribute("src", get_state_label(s))
        edge_st.set_attribute("target", get_state_label(edge.attr_target))
        edge_st.set_attribute("arrowhead", @arrowhead)
        dot.set_attribute("edges", edge_st)
        walk_rule_nfacreating_dot(dot, edge.attr_target) # keep walkin'
        i += 1
      end
    end
    
    typesig { [Transition] }
    # public void writeDOTFilesForAllRuleNFAs() throws IOException {
    # Collection rules = grammar.getRules();
    # for (Iterator itr = rules.iterator(); itr.hasNext();) {
    # Grammar.Rule r = (Grammar.Rule) itr.next();
    # String ruleName = r.name;
    # writeDOTFile(
    # ruleName,
    # getRuleNFADOT(grammar.getRuleStartState(ruleName)));
    # }
    # }
    # 
    # 
    # public void writeDOTFilesForAllDecisionDFAs() throws IOException {
    # // for debugging, create a DOT file for each decision in
    # // a directory named for the grammar.
    # File grammarDir = new File(grammar.name+"_DFAs");
    # grammarDir.mkdirs();
    # List decisionList = grammar.getDecisionNFAStartStateList();
    # if ( decisionList==null ) {
    # return;
    # }
    # int i = 1;
    # Iterator iter = decisionList.iterator();
    # while (iter.hasNext()) {
    # NFAState decisionState = (NFAState)iter.next();
    # DFA dfa = decisionState.getDecisionASTNode().getLookaheadDFA();
    # if ( dfa!=null ) {
    # String dot = getDOT( dfa.startState );
    # writeDOTFile(grammarDir+"/dec-"+i, dot);
    # }
    # i++;
    # }
    # }
    # 
    # Fix edge strings so they print out in DOT properly;
    # generate any gated predicates on edge too.
    def get_edge_label(edge)
      label = edge.attr_label.to_s(@grammar)
      label = RJava.cast_to_string(Utils.replace(label, "\\", "\\\\"))
      label = RJava.cast_to_string(Utils.replace(label, "\"", "\\\""))
      label = RJava.cast_to_string(Utils.replace(label, "\n", "\\\\n"))
      label = RJava.cast_to_string(Utils.replace(label, "\r", ""))
      if ((label == Label::EPSILON_STR))
        label = "e"
      end
      target = edge.attr_target
      if (!edge.is_semantic_predicate && target.is_a?(DFAState))
        # look for gated predicates; don't add gated to simple sempred edges
        preds = (target).get_gated_predicates_in_nfaconfigurations
        if (!(preds).nil?)
          preds_str = ""
          preds_str = "&&{" + RJava.cast_to_string(preds.gen_expr(@grammar.attr_generator, @grammar.attr_generator.get_templates, nil).to_s) + "}?"
          label += preds_str
        end
      end
      return label
    end
    
    typesig { [State] }
    def get_state_label(s)
      if ((s).nil?)
        return "null"
      end
      state_label = String.value_of(s.attr_state_number)
      if (s.is_a?(DFAState))
        buf = StringBuffer.new(250)
        buf.append(Character.new(?s.ord))
        buf.append(s.attr_state_number)
        if (Tool.attr_internal_option_show_nfaconfigs_in_dfa)
          if (s.is_a?(DFAState))
            if ((s).attr_aborted_due_to_recursion_overflow)
              buf.append("\\n")
              buf.append("abortedDueToRecursionOverflow")
            end
          end
          alts = (s).get_alt_set
          if (!(alts).nil?)
            buf.append("\\n")
            # separate alts
            alt_list = ArrayList.new
            alt_list.add_all(alts)
            Collections.sort(alt_list)
            configurations = (s).attr_nfa_configurations
            alt_index = 0
            while alt_index < alt_list.size
              alt_i = alt_list.get(alt_index)
              alt = alt_i.int_value
              if (alt_index > 0)
                buf.append("\\n")
              end
              buf.append("alt")
              buf.append(alt)
              buf.append(Character.new(?:.ord))
              # get a list of configs for just this alt
              # it will help us print better later
              configs_in_alt = ArrayList.new
              it = configurations.iterator
              while it.has_next
                c = it.next_
                if (!(c.attr_alt).equal?(alt))
                  next
                end
                configs_in_alt.add(c)
              end
              n = 0
              c_index = 0
              while c_index < configs_in_alt.size
                c = configs_in_alt.get(c_index)
                n += 1
                buf.append(c.to_s(false))
                if ((c_index + 1) < configs_in_alt.size)
                  buf.append(", ")
                end
                if ((n % 5).equal?(0) && (configs_in_alt.size - c_index) > 3)
                  buf.append("\\n")
                end
                c_index += 1
              end
              alt_index += 1
            end
          end
        end
        state_label = RJava.cast_to_string(buf.to_s)
      end
      if ((s.is_a?(NFAState)) && (s).is_decision_state)
        state_label = state_label + ",d=" + RJava.cast_to_string((s).get_decision_number)
        if (!((s).attr_end_of_block_state_number).equal?(State::INVALID_STATE_NUMBER))
          state_label += ",eob=" + RJava.cast_to_string((s).attr_end_of_block_state_number)
        end
      else
        if ((s.is_a?(NFAState)) && !((s).attr_end_of_block_state_number).equal?(State::INVALID_STATE_NUMBER))
          n = (s)
          state_label = state_label + ",eob=" + RJava.cast_to_string(n.attr_end_of_block_state_number)
        else
          if (s.is_a?(DFAState) && (s).is_accept_state)
            state_label = state_label + "=>" + RJava.cast_to_string((s).get_uniquely_predicted_alt)
          end
        end
      end
      return RJava.cast_to_string(Character.new(?".ord)) + state_label + RJava.cast_to_string(Character.new(?".ord))
    end
    
    typesig { [] }
    def get_arrowhead_type
      return @arrowhead
    end
    
    typesig { [String] }
    def set_arrowhead_type(arrowhead)
      @arrowhead = arrowhead
    end
    
    typesig { [] }
    def get_rankdir
      return @rankdir
    end
    
    typesig { [String] }
    def set_rankdir(rankdir)
      @rankdir = rankdir
    end
    
    private
    alias_method :initialize__dotgenerator, :initialize
  end
  
end
