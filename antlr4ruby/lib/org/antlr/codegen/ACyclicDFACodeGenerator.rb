require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
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
module Org::Antlr::Codegen
  module ACyclicDFACodeGeneratorImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateGroup
      include_const ::Java::Util, :JavaList
    }
  end
  
  class ACyclicDFACodeGenerator 
    include_class_members ACyclicDFACodeGeneratorImports
    
    attr_accessor :parent_generator
    alias_method :attr_parent_generator, :parent_generator
    undef_method :parent_generator
    alias_method :attr_parent_generator=, :parent_generator=
    undef_method :parent_generator=
    
    typesig { [CodeGenerator] }
    def initialize(parent)
      @parent_generator = nil
      @parent_generator = parent
    end
    
    typesig { [StringTemplateGroup, DFA] }
    def gen_fixed_lookahead_decision(templates, dfa)
      return walk_fixed_dfagenerating_state_machine(templates, dfa, dfa.attr_start_state, 1)
    end
    
    typesig { [StringTemplateGroup, DFA, DFAState, ::Java::Int] }
    def walk_fixed_dfagenerating_state_machine(templates, dfa, s, k)
      # System.out.println("walk "+s.stateNumber+" in dfa for decision "+dfa.decisionNumber);
      if (s.is_accept_state)
        dfa_st = templates.get_instance_of("dfaAcceptState")
        dfa_st.set_attribute("alt", Utils.integer(s.get_uniquely_predicted_alt))
        return dfa_st
      end
      # the default templates for generating a state and its edges
      # can be an if-then-else structure or a switch
      dfa_state_name = "dfaState"
      dfa_loopback_state_name = "dfaLoopbackState"
      dfa_optional_block_state_name = "dfaOptionalBlockState"
      dfa_edge_name = "dfaEdge"
      if (@parent_generator.can_generate_switch(s))
        dfa_state_name = "dfaStateSwitch"
        dfa_loopback_state_name = "dfaLoopbackStateSwitch"
        dfa_optional_block_state_name = "dfaOptionalBlockStateSwitch"
        dfa_edge_name = "dfaEdgeSwitch"
      end
      dfa_st = templates.get_instance_of(dfa_state_name)
      if ((dfa.get_nfadecision_start_state.attr_decision_state_type).equal?(NFAState::LOOPBACK))
        dfa_st = templates.get_instance_of(dfa_loopback_state_name)
      else
        if ((dfa.get_nfadecision_start_state.attr_decision_state_type).equal?(NFAState::OPTIONAL_BLOCK_START))
          dfa_st = templates.get_instance_of(dfa_optional_block_state_name)
        end
      end
      dfa_st.set_attribute("k", Utils.integer(k))
      dfa_st.set_attribute("stateNumber", Utils.integer(s.attr_state_number))
      dfa_st.set_attribute("semPredState", Boolean.value_of(s.is_resolved_with_predicates))
      # 		String description = dfa.getNFADecisionStartState().getDescription();
      # 		description = parentGenerator.target.getTargetStringLiteralFromString(description);
      # 		//System.out.println("DFA: "+description+" associated with AST "+dfa.getNFADecisionStartState());
      # 		if ( description!=null ) {
      # 			dfaST.setAttribute("description", description);
      # 		}
      eotpredicts = NFA::INVALID_ALT_NUMBER
      eottarget = nil
      # System.out.println("DFA state "+s.stateNumber);
      i = 0
      while i < s.get_number_of_transitions
        edge = s.transition(i)
        # System.out.println("edge "+s.stateNumber+"-"+edge.label.toString()+"->"+edge.target.stateNumber);
        if ((edge.attr_label.get_atom).equal?(Label::EOT))
          # don't generate a real edge for EOT; track alt EOT predicts
          # generate that prediction in the else clause as default case
          eottarget = edge.attr_target
          eotpredicts = eottarget.get_uniquely_predicted_alt
          # 				System.out.println("DFA s"+s.stateNumber+" EOT goes to s"+
          # 								   edge.target.stateNumber+" predicates alt "+
          # 								   EOTPredicts);
          i += 1
          next
        end
        edge_st = templates.get_instance_of(dfa_edge_name)
        # If the template wants all the label values delineated, do that
        if (!(edge_st.get_formal_argument("labels")).nil?)
          labels = edge.attr_label.get_set.to_list
          j = 0
          while j < labels.size
            v_i = labels.get(j)
            label = @parent_generator.get_token_type_as_target_label(v_i.int_value)
            labels.set(j, label) # rewrite List element to be name
            j += 1
          end
          edge_st.set_attribute("labels", labels)
        else
          # else create an expression to evaluate (the general case)
          edge_st.set_attribute("labelExpr", @parent_generator.gen_label_expr(templates, edge, k))
        end
        # stick in any gated predicates for any edge if not already a pred
        if (!edge.attr_label.is_semantic_predicate)
          target = edge.attr_target
          preds = target.get_gated_predicates_in_nfaconfigurations
          if (!(preds).nil?)
            # System.out.println("preds="+target.getGatedPredicatesInNFAConfigurations());
            pred_st = preds.gen_expr(@parent_generator, @parent_generator.get_templates, dfa)
            edge_st.set_attribute("predicates", pred_st)
          end
        end
        target_st = walk_fixed_dfagenerating_state_machine(templates, dfa, edge.attr_target, k + 1)
        edge_st.set_attribute("targetState", target_st)
        dfa_st.set_attribute("edges", edge_st)
        i += 1
      end
      # HANDLE EOT EDGE
      if (!(eotpredicts).equal?(NFA::INVALID_ALT_NUMBER))
        # EOT unique predicts an alt
        dfa_st.set_attribute("eotPredictsAlt", Utils.integer(eotpredicts))
      else
        if (!(eottarget).nil? && eottarget.get_number_of_transitions > 0)
          # EOT state has transitions so must split on predicates.
          # Generate predicate else-if clauses and then generate
          # NoViableAlt exception as else clause.
          # Note: these predicates emanate from the EOT target state
          # rather than the current DFAState s so the error message
          # might be slightly misleading if you are looking at the
          # state number.  Predicates emanating from EOT targets are
          # hoisted up to the state that has the EOT edge.
          i_ = 0
          while i_ < eottarget.get_number_of_transitions
            pred_edge = eottarget.transition(i_)
            edge_st = templates.get_instance_of(dfa_edge_name)
            edge_st.set_attribute("labelExpr", @parent_generator.gen_semantic_predicate_expr(templates, pred_edge))
            # the target must be an accept state
            # System.out.println("EOT edge");
            target_st = walk_fixed_dfagenerating_state_machine(templates, dfa, pred_edge.attr_target, k + 1)
            edge_st.set_attribute("targetState", target_st)
            dfa_st.set_attribute("edges", edge_st)
            i_ += 1
          end
        end
      end
      return dfa_st
    end
    
    private
    alias_method :initialize__acyclic_dfacode_generator, :initialize
  end
  
end
