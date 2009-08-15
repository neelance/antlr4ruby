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
  module NFAConfigurationImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :Utils
    }
  end
  
  # An NFA state, predicted alt, and syntactic/semantic context.
  # The syntactic context is a pointer into the rule invocation
  # chain used to arrive at the state.  The semantic context is
  # the unordered set semantic predicates encountered before reaching
  # an NFA state.
  class NFAConfiguration 
    include_class_members NFAConfigurationImports
    
    # The NFA state associated with this configuration
    attr_accessor :state
    alias_method :attr_state, :state
    undef_method :state
    alias_method :attr_state=, :state=
    undef_method :state=
    
    # What alt is predicted by this configuration
    attr_accessor :alt
    alias_method :attr_alt, :alt
    undef_method :alt
    alias_method :attr_alt=, :alt=
    undef_method :alt=
    
    # What is the stack of rule invocations that got us to state?
    attr_accessor :context
    alias_method :attr_context, :context
    undef_method :context
    alias_method :attr_context=, :context=
    undef_method :context=
    
    # The set of semantic predicates associated with this NFA
    # configuration.  The predicates were found on the way to
    # the associated NFA state in this syntactic context.
    # Set<AST>: track nodes in grammar containing the predicate
    # for error messages and such (nice to know where the predicate
    # came from in case of duplicates etc...).  By using a set,
    # the equals() method will correctly show {pred1,pred2} as equals()
    # to {pred2,pred1}.
    attr_accessor :semantic_context
    alias_method :attr_semantic_context, :semantic_context
    undef_method :semantic_context
    alias_method :attr_semantic_context=, :semantic_context=
    undef_method :semantic_context=
    
    # Indicate that this configuration has been resolved and no further
    # DFA processing should occur with it.  Essentially, this is used
    # as an "ignore" bit so that upon a set of nondeterministic configurations
    # such as (s|2) and (s|3), I can set (s|3) to resolved=true (and any
    # other configuration associated with alt 3).
    attr_accessor :resolved
    alias_method :attr_resolved, :resolved
    undef_method :resolved
    alias_method :attr_resolved=, :resolved=
    undef_method :resolved=
    
    # This bit is used to indicate a semantic predicate will be
    # used to resolve the conflict.  Method
    # DFA.findNewDFAStatesAndAddDFATransitions will add edges for
    # the predicates after it performs the reach operation.  The
    # nondeterminism resolver sets this when it finds a set of
    # nondeterministic configurations (as it does for "resolved" field)
    # that have enough predicates to resolve the conflit.
    attr_accessor :resolve_with_predicate
    alias_method :attr_resolve_with_predicate, :resolve_with_predicate
    undef_method :resolve_with_predicate
    alias_method :attr_resolve_with_predicate=, :resolve_with_predicate=
    undef_method :resolve_with_predicate=
    
    # Lots of NFA states have only epsilon edges (1 or 2).  We can
    # safely consider only n>0 during closure.
    attr_accessor :number_epsilon_transitions_emanating_from_state
    alias_method :attr_number_epsilon_transitions_emanating_from_state, :number_epsilon_transitions_emanating_from_state
    undef_method :number_epsilon_transitions_emanating_from_state
    alias_method :attr_number_epsilon_transitions_emanating_from_state=, :number_epsilon_transitions_emanating_from_state=
    undef_method :number_epsilon_transitions_emanating_from_state=
    
    # Indicates that the NFA state associated with this configuration
    # has exactly one transition and it's an atom (not epsilon etc...).
    attr_accessor :single_atom_transition_emanating
    alias_method :attr_single_atom_transition_emanating, :single_atom_transition_emanating
    undef_method :single_atom_transition_emanating
    alias_method :attr_single_atom_transition_emanating=, :single_atom_transition_emanating=
    undef_method :single_atom_transition_emanating=
    
    typesig { [::Java::Int, ::Java::Int, NFAContext, SemanticContext] }
    # protected boolean addedDuringClosure = true;
    def initialize(state, alt, context, semantic_context)
      @state = 0
      @alt = 0
      @context = nil
      @semantic_context = SemanticContext::EMPTY_SEMANTIC_CONTEXT
      @resolved = false
      @resolve_with_predicate = false
      @number_epsilon_transitions_emanating_from_state = 0
      @single_atom_transition_emanating = false
      @state = state
      @alt = alt
      @context = context
      @semantic_context = semantic_context
    end
    
    typesig { [Object] }
    # An NFA configuration is equal to another if both have
    # the same state, the predict the same alternative, and
    # syntactic/semantic contexts are the same.  I don't think
    # the state|alt|ctx could be the same and have two different
    # semantic contexts, but might as well define equals to be
    # everything.
    def ==(o)
      if ((o).nil?)
        return false
      end
      other = o
      return (@state).equal?(other.attr_state) && (@alt).equal?(other.attr_alt) && (@context == other.attr_context) && (@semantic_context == other.attr_semantic_context)
    end
    
    typesig { [] }
    def hash_code
      h = @state + @alt + @context.hash_code
      return h
    end
    
    typesig { [] }
    def to_s
      return to_s(true)
    end
    
    typesig { [::Java::Boolean] }
    def to_s(show_alt)
      buf = StringBuffer.new
      buf.append(@state)
      if (show_alt)
        buf.append("|")
        buf.append(@alt)
      end
      if (!(@context.attr_parent).nil?)
        buf.append("|")
        buf.append(@context)
      end
      if (!(@semantic_context).nil? && !(@semantic_context).equal?(SemanticContext::EMPTY_SEMANTIC_CONTEXT))
        buf.append("|")
        esc_quote = Utils.replace(@semantic_context.to_s, "\"", "\\\"")
        buf.append(esc_quote)
      end
      if (@resolved)
        buf.append("|resolved")
      end
      if (@resolve_with_predicate)
        buf.append("|resolveWithPredicate")
      end
      return buf.to_s
    end
    
    private
    alias_method :initialize__nfaconfiguration, :initialize
  end
  
end
