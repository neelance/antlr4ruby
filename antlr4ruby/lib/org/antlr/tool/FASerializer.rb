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
  module FASerializerImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :Utils
      include ::Java::Util
    }
  end
  
  # An aspect of FA (finite automata) that knows how to dump them to serialized
  # strings.
  class FASerializer 
    include_class_members FASerializerImports
    
    # To prevent infinite recursion when walking state machines, record
    # which states we've visited.  Make a new set every time you start
    # walking in case you reuse this object.  Multiple threads will trash
    # this shared variable.  Use a different FASerializer per thread.
    attr_accessor :marked_states
    alias_method :attr_marked_states, :marked_states
    undef_method :marked_states
    alias_method :attr_marked_states=, :marked_states=
    undef_method :marked_states=
    
    # Each state we walk will get a new state number for serialization
    # purposes.  This is the variable that tracks state numbers.
    attr_accessor :state_counter
    alias_method :attr_state_counter, :state_counter
    undef_method :state_counter
    alias_method :attr_state_counter=, :state_counter=
    undef_method :state_counter=
    
    # Rather than add a new instance variable to NFA and DFA just for
    # serializing machines, map old state numbers to new state numbers
    # by a State object -> Integer new state number HashMap.
    attr_accessor :state_number_translator
    alias_method :attr_state_number_translator, :state_number_translator
    undef_method :state_number_translator
    alias_method :attr_state_number_translator=, :state_number_translator=
    undef_method :state_number_translator=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    typesig { [Grammar] }
    # This aspect is associated with a grammar; used to get token names
    def initialize(grammar)
      @marked_states = nil
      @state_counter = 0
      @state_number_translator = nil
      @grammar = nil
      @grammar = grammar
    end
    
    typesig { [State] }
    def serialize(s)
      if ((s).nil?)
        return "<no automaton>"
      end
      return serialize(s, true)
    end
    
    typesig { [State, ::Java::Boolean] }
    # Return a string representation of a state machine.  Two identical
    # NFAs or DFAs will have identical serialized representations.  The
    # state numbers inside the state are not used; instead, a new number
    # is computed and because the serialization will walk the two
    # machines using the same specific algorithm, then the state numbers
    # will be identical.  Accept states are distinguished from regular
    # states.
    def serialize(s, renumber)
      @marked_states = HashSet.new
      @state_counter = 0
      if (renumber)
        @state_number_translator = HashMap.new
        walk_fanormalizing_state_numbers(s)
      end
      lines = ArrayList.new
      if (s.get_number_of_transitions > 0)
        walk_serializing_fa(lines, s)
      else
        # special case: s0 is an accept
        s0 = get_state_string(0, s)
        lines.add(s0 + "\n")
      end
      buf = StringBuffer.new(0)
      # sort lines to normalize; makes states come out ordered
      # and then ordered by edge labels then by target state number :)
      Collections.sort(lines)
      i = 0
      while i < lines.size
        line = lines.get(i)
        buf.append(line)
        i += 1
      end
      return buf.to_s
    end
    
    typesig { [State] }
    # In stateNumberTranslator, get a map from State to new, normalized
    # state number.  Used by walkSerializingFA to make sure any two
    # identical state machines will serialize the same way.
    def walk_fanormalizing_state_numbers(s)
      if ((s).nil?)
        ErrorManager.internal_error("null state s")
        return
      end
      if (!(@state_number_translator.get(s)).nil?)
        return # already did this state
      end
      # assign a new state number for this node if there isn't one
      @state_number_translator.put(s, Utils.integer(@state_counter))
      @state_counter += 1
      # visit nodes pointed to by each transition;
      i = 0
      while i < s.get_number_of_transitions
        edge = s.transition(i)
        walk_fanormalizing_state_numbers(edge.attr_target) # keep walkin'
        # if this transition is a rule reference, the node "following" this state
        # will not be found and appear to be not in graph.  Must explicitly jump
        # to it, but don't "draw" an edge.
        if (edge.is_a?(RuleClosureTransition))
          walk_fanormalizing_state_numbers((edge).attr_follow_state)
        end
        i += 1
      end
    end
    
    typesig { [JavaList, State] }
    def walk_serializing_fa(lines, s)
      if (@marked_states.contains(s))
        return # already visited this node
      end
      @marked_states.add(s) # mark this node as completed.
      normalized_state_number = s.attr_state_number
      if (!(@state_number_translator).nil?)
        normalized_state_number_i = @state_number_translator.get(s)
        normalized_state_number = normalized_state_number_i.int_value
      end
      state_str = get_state_string(normalized_state_number, s)
      # depth first walk each transition, printing its edge first
      i = 0
      while i < s.get_number_of_transitions
        edge = s.transition(i)
        buf = StringBuffer.new
        buf.append(state_str)
        if (edge.is_action)
          buf.append("-{}->")
        else
          if (edge.is_epsilon)
            buf.append("->")
          else
            if (edge.is_semantic_predicate)
              buf.append("-{" + RJava.cast_to_string(edge.attr_label.get_semantic_context) + "}?->")
            else
              preds_str = ""
              if (edge.attr_target.is_a?(DFAState))
                # look for gated predicates; don't add gated to simple sempred edges
                preds = (edge.attr_target).get_gated_predicates_in_nfaconfigurations
                if (!(preds).nil?)
                  preds_str = "&&{" + RJava.cast_to_string(preds.gen_expr(@grammar.attr_generator, @grammar.attr_generator.get_templates, nil).to_s) + "}?"
                end
              end
              buf.append("-" + RJava.cast_to_string(edge.attr_label.to_s(@grammar)) + preds_str + "->")
            end
          end
        end
        normalized_target_state_number = edge.attr_target.attr_state_number
        if (!(@state_number_translator).nil?)
          normalized_target_state_number_i = @state_number_translator.get(edge.attr_target)
          normalized_target_state_number = normalized_target_state_number_i.int_value
        end
        buf.append(get_state_string(normalized_target_state_number, edge.attr_target))
        buf.append("\n")
        lines.add(buf.to_s)
        # walk this transition
        walk_serializing_fa(lines, edge.attr_target)
        # if this transition is a rule reference, the node "following" this state
        # will not be found and appear to be not in graph.  Must explicitly jump
        # to it, but don't "draw" an edge.
        if (edge.is_a?(RuleClosureTransition))
          walk_serializing_fa(lines, (edge).attr_follow_state)
        end
        i += 1
      end
    end
    
    typesig { [::Java::Int, State] }
    def get_state_string(n, s)
      state_str = ".s" + RJava.cast_to_string(n)
      if (s.is_accept_state)
        if (s.is_a?(DFAState))
          state_str = ":s" + RJava.cast_to_string(n) + "=>" + RJava.cast_to_string((s).get_uniquely_predicted_alt)
        else
          state_str = ":s" + RJava.cast_to_string(n)
        end
      end
      return state_str
    end
    
    private
    alias_method :initialize__faserializer, :initialize
  end
  
end
