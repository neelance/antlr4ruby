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
module Org::Antlr::Analysis
  module DFAImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Misc, :IntSet
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Runtime, :IntStream
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include ::Org::Antlr::Tool
      include ::Java::Util
    }
  end
  
  #   * EOT (end of token) is a label that indicates when the DFA conversion
  #  *  algorithm would "fall off the end of a lexer rule".  It normally
  #  *  means the default clause.  So for ('a'..'z')+ you would see a DFA
  #  *  with a state that has a..z and EOT emanating from it.  a..z would
  #  *  jump to a state predicting alt 1 and EOT would jump to a state
  #  *  predicting alt 2 (the exit loop branch).  EOT implies anything other
  #  *  than a..z.  If for some reason, the set is "all char" such as with
  #  *  the wildcard '.', then EOT cannot match anything.  For example,
  #  *
  #  *     BLOCK : '{' (.)* '}'
  #  *
  #  *  consumes all char until EOF when greedy=true.  When all edges are
  #  *  combined for the DFA state after matching '}', you will find that
  #  *  it is all char.  The EOT transition has nothing to match and is
  #  *  unreachable.  The findNewDFAStatesAndAddDFATransitions() method
  #  *  must know to ignore the EOT, so we simply remove it from the
  #  *  reachable labels.  Later analysis will find that the exit branch
  #  *  is not predicted by anything.  For greedy=false, we leave only
  #  *  the EOT label indicating that the DFA should stop immediately
  #  *  and predict the exit branch. The reachable labels are often a
  #  *  set of disjoint values like: [<EOT>, 42, {0..41, 43..65534}]
  #  *  due to DFA conversion so must construct a pure set to see if
  #  *  it is same as Label.ALLCHAR.
  #  *
  #  *  Only do this for Lexers.
  #  *
  #  *  If EOT coexists with ALLCHAR:
  #  *  1. If not greedy, modify the labels parameter to be EOT
  #  *  2. If greedy, remove EOT from the labels set
  # protected boolean reachableLabelsEOTCoexistsWithAllChar(OrderedHashSet labels)
  # {
  #     Label eot = new Label(Label.EOT);
  #     if ( !labels.containsKey(eot) ) {
  #         return false;
  #     }
  #     System.out.println("### contains EOT");
  #     boolean containsAllChar = false;
  #     IntervalSet completeVocab = new IntervalSet();
  #     int n = labels.size();
  #     for (int i=0; i<n; i++) {
  #         Label rl = (Label)labels.get(i);
  #         if ( !rl.equals(eot) ) {
  #             completeVocab.addAll(rl.getSet());
  #         }
  #     }
  #     System.out.println("completeVocab="+completeVocab);
  #     if ( completeVocab.equals(Label.ALLCHAR) ) {
  #         System.out.println("all char");
  #         containsAllChar = true;
  #     }
  #     return containsAllChar;
  # }
  # A DFA (converted from a grammar's NFA).
  # DFAs are used as prediction machine for alternative blocks in all kinds
  # of recognizers (lexers, parsers, tree walkers).
  class DFA 
    include_class_members DFAImports
    
    class_module.module_eval {
      const_set_lazy(:REACHABLE_UNKNOWN) { -2 }
      const_attr_reader  :REACHABLE_UNKNOWN
      
      const_set_lazy(:REACHABLE_BUSY) { -1 }
      const_attr_reader  :REACHABLE_BUSY
      
      # in process of computing
      const_set_lazy(:REACHABLE_NO) { 0 }
      const_attr_reader  :REACHABLE_NO
      
      const_set_lazy(:REACHABLE_YES) { 1 }
      const_attr_reader  :REACHABLE_YES
      
      #   * Prevent explosion of DFA states during conversion. The max number
      #  *  of states per alt in a single decision's DFA.
      # public static final int MAX_STATES_PER_ALT_IN_DFA = 450;
      # Set to 0 to not terminate early (time in ms)
      
      def max_time_per_dfa_creation
        defined?(@@max_time_per_dfa_creation) ? @@max_time_per_dfa_creation : @@max_time_per_dfa_creation= 1 * 1000
      end
      alias_method :attr_max_time_per_dfa_creation, :max_time_per_dfa_creation
      
      def max_time_per_dfa_creation=(value)
        @@max_time_per_dfa_creation = value
      end
      alias_method :attr_max_time_per_dfa_creation=, :max_time_per_dfa_creation=
      
      # How many edges can each DFA state have before a "special" state
      # is created that uses IF expressions instead of a table?
      
      def max_state_transitions_for_table
        defined?(@@max_state_transitions_for_table) ? @@max_state_transitions_for_table : @@max_state_transitions_for_table= 65534
      end
      alias_method :attr_max_state_transitions_for_table, :max_state_transitions_for_table
      
      def max_state_transitions_for_table=(value)
        @@max_state_transitions_for_table = value
      end
      alias_method :attr_max_state_transitions_for_table=, :max_state_transitions_for_table=
    }
    
    # What's the start state for this DFA?
    attr_accessor :start_state
    alias_method :attr_start_state, :start_state
    undef_method :start_state
    alias_method :attr_start_state=, :start_state=
    undef_method :start_state=
    
    # This DFA is being built for which decision?
    attr_accessor :decision_number
    alias_method :attr_decision_number, :decision_number
    undef_method :decision_number
    alias_method :attr_decision_number=, :decision_number=
    undef_method :decision_number=
    
    # From what NFAState did we create the DFA?
    attr_accessor :decision_nfastart_state
    alias_method :attr_decision_nfastart_state, :decision_nfastart_state
    undef_method :decision_nfastart_state
    alias_method :attr_decision_nfastart_state=, :decision_nfastart_state=
    undef_method :decision_nfastart_state=
    
    # The printable grammar fragment associated with this DFA
    attr_accessor :description
    alias_method :attr_description, :description
    undef_method :description
    alias_method :attr_description=, :description=
    undef_method :description=
    
    # A set of all uniquely-numbered DFA states.  Maps hash of DFAState
    # to the actual DFAState object.  We use this to detect
    # existing DFA states.  Map<DFAState,DFAState>.  Use Map so
    # we can get old state back (Set only allows you to see if it's there).
    # Not used during fixed k lookahead as it's a waste to fill it with
    # a dup of states array.
    attr_accessor :unique_states
    alias_method :attr_unique_states, :unique_states
    undef_method :unique_states
    alias_method :attr_unique_states=, :unique_states=
    undef_method :unique_states=
    
    # Maps the state number to the actual DFAState.  Use a Vector as it
    # grows automatically when I set the ith element.  This contains all
    # states, but the states are not unique.  s3 might be same as s1 so
    # s3 -> s1 in this table.  This is how cycles occur.  If fixed k,
    # then these states will all be unique as states[i] always points
    # at state i when no cycles exist.
    # 
    # This is managed in parallel with uniqueStates and simply provides
    # a way to go from state number to DFAState rather than via a
    # hash lookup.
    attr_accessor :states
    alias_method :attr_states, :states
    undef_method :states
    alias_method :attr_states=, :states=
    undef_method :states=
    
    # Unique state numbers per DFA
    attr_accessor :state_counter
    alias_method :attr_state_counter, :state_counter
    undef_method :state_counter
    alias_method :attr_state_counter=, :state_counter=
    undef_method :state_counter=
    
    # count only new states not states that were rejected as already present
    attr_accessor :number_of_states
    alias_method :attr_number_of_states, :number_of_states
    undef_method :number_of_states
    alias_method :attr_number_of_states=, :number_of_states=
    undef_method :number_of_states=
    
    # User specified max fixed lookahead.  If 0, nothing specified.  -1
    # implies we have not looked at the options table yet to set k.
    attr_accessor :user_k
    alias_method :attr_user_k, :user_k
    undef_method :user_k
    alias_method :attr_user_k=, :user_k=
    undef_method :user_k=
    
    # While building the DFA, track max lookahead depth if not cyclic
    attr_accessor :max_k
    alias_method :attr_max_k, :max_k
    undef_method :max_k
    alias_method :attr_max_k=, :max_k=
    undef_method :max_k=
    
    # Is this DFA reduced?  I.e., can all states lead to an accept state?
    attr_accessor :reduced
    alias_method :attr_reduced, :reduced
    undef_method :reduced
    alias_method :attr_reduced=, :reduced=
    undef_method :reduced=
    
    # Are there any loops in this DFA?
    # Computed by doesStateReachAcceptState()
    attr_accessor :cyclic
    alias_method :attr_cyclic, :cyclic
    undef_method :cyclic
    alias_method :attr_cyclic=, :cyclic=
    undef_method :cyclic=
    
    # Track whether this DFA has at least one sem/syn pred encountered
    # during a closure operation.  This is useful for deciding whether
    # to retry a non-LL(*) with k=1.  If no pred, it will not work w/o
    # a pred so don't bother.  It would just give another error message.
    attr_accessor :predicate_visible
    alias_method :attr_predicate_visible, :predicate_visible
    undef_method :predicate_visible
    alias_method :attr_predicate_visible=, :predicate_visible=
    undef_method :predicate_visible=
    
    attr_accessor :has_predicate_blocked_by_action
    alias_method :attr_has_predicate_blocked_by_action, :has_predicate_blocked_by_action
    undef_method :has_predicate_blocked_by_action
    alias_method :attr_has_predicate_blocked_by_action=, :has_predicate_blocked_by_action=
    undef_method :has_predicate_blocked_by_action=
    
    # Each alt in an NFA derived from a grammar must have a DFA state that
    # predicts it lest the parser not know what to do.  Nondeterminisms can
    # lead to this situation (assuming no semantic predicates can resolve
    # the problem) and when for some reason, I cannot compute the lookahead
    # (which might arise from an error in the algorithm or from
    # left-recursion etc...).  This list starts out with all alts contained
    # and then in method doesStateReachAcceptState() I remove the alts I
    # know to be uniquely predicted.
    attr_accessor :unreachable_alts
    alias_method :attr_unreachable_alts, :unreachable_alts
    undef_method :unreachable_alts
    alias_method :attr_unreachable_alts=, :unreachable_alts=
    undef_method :unreachable_alts=
    
    attr_accessor :n_alts
    alias_method :attr_n_alts, :n_alts
    undef_method :n_alts
    alias_method :attr_n_alts=, :n_alts=
    undef_method :n_alts=
    
    # We only want one accept state per predicted alt; track here
    attr_accessor :alt_to_accept_state
    alias_method :attr_alt_to_accept_state, :alt_to_accept_state
    undef_method :alt_to_accept_state
    alias_method :attr_alt_to_accept_state=, :alt_to_accept_state=
    undef_method :alt_to_accept_state=
    
    # Track whether an alt discovers recursion for each alt during
    # NFA to DFA conversion; >1 alt with recursion implies nonregular.
    attr_accessor :recursive_alt_set
    alias_method :attr_recursive_alt_set, :recursive_alt_set
    undef_method :recursive_alt_set
    alias_method :attr_recursive_alt_set=, :recursive_alt_set=
    undef_method :recursive_alt_set=
    
    # Which NFA are we converting (well, which piece of the NFA)?
    attr_accessor :nfa
    alias_method :attr_nfa, :nfa
    undef_method :nfa
    alias_method :attr_nfa=, :nfa=
    undef_method :nfa=
    
    attr_accessor :nfa_converter
    alias_method :attr_nfa_converter, :nfa_converter
    undef_method :nfa_converter
    alias_method :attr_nfa_converter=, :nfa_converter=
    undef_method :nfa_converter=
    
    # This probe tells you a lot about a decision and is useful even
    # when there is no error such as when a syntactic nondeterminism
    # is solved via semantic predicates.  Perhaps a GUI would want
    # the ability to show that.
    attr_accessor :probe
    alias_method :attr_probe, :probe
    undef_method :probe
    alias_method :attr_probe=, :probe=
    undef_method :probe=
    
    # Track absolute time of the conversion so we can have a failsafe:
    # if it takes too long, then terminate.  Assume bugs are in the
    # analysis engine.
    attr_accessor :conversion_start_time
    alias_method :attr_conversion_start_time, :conversion_start_time
    undef_method :conversion_start_time
    alias_method :attr_conversion_start_time=, :conversion_start_time=
    undef_method :conversion_start_time=
    
    # Map an edge transition table to a unique set number; ordered so
    # we can push into the output template as an ordered list of sets
    # and then ref them from within the transition[][] table.  Like this
    # for C# target:
    #    public static readonly DFA30_transition0 =
    #        new short[] { 46, 46, -1, 46, 46, -1, -1, -1, -1, -1, -1, -1,...};
    #        public static readonly DFA30_transition1 =
    #        new short[] { 21 };
    #     public static readonly short[][] DFA30_transition = {
    #          DFA30_transition0,
    #          DFA30_transition0,
    #          DFA30_transition1,
    #          ...
    #     };
    attr_accessor :edge_transition_class_map
    alias_method :attr_edge_transition_class_map, :edge_transition_class_map
    undef_method :edge_transition_class_map
    alias_method :attr_edge_transition_class_map=, :edge_transition_class_map=
    undef_method :edge_transition_class_map=
    
    # The unique edge transition class number; every time we see a new
    # set of edges emanating from a state, we number it so we can reuse
    # if it's every seen again for another state.  For Java grammar,
    # some of the big edge transition tables are seen about 57 times.
    attr_accessor :edge_transition_class
    alias_method :attr_edge_transition_class, :edge_transition_class
    undef_method :edge_transition_class
    alias_method :attr_edge_transition_class=, :edge_transition_class=
    undef_method :edge_transition_class=
    
    # This DFA can be converted to a transition[state][char] table and
    # the following tables are filled by createStateTables upon request.
    # These are injected into the templates for code generation.
    # See March 25, 2006 entry for description:
    #   http://www.antlr.org/blog/antlr3/codegen.tml
    # Often using Vector as can't set ith position in a List and have
    # it extend list size; bizarre.
    # List of special DFAState objects
    attr_accessor :special_states
    alias_method :attr_special_states, :special_states
    undef_method :special_states
    alias_method :attr_special_states=, :special_states=
    undef_method :special_states=
    
    # List of ST for special states.
    attr_accessor :special_state_sts
    alias_method :attr_special_state_sts, :special_state_sts
    undef_method :special_state_sts
    alias_method :attr_special_state_sts=, :special_state_sts=
    undef_method :special_state_sts=
    
    attr_accessor :accept
    alias_method :attr_accept, :accept
    undef_method :accept
    alias_method :attr_accept=, :accept=
    undef_method :accept=
    
    attr_accessor :eot
    alias_method :attr_eot, :eot
    undef_method :eot
    alias_method :attr_eot=, :eot=
    undef_method :eot=
    
    attr_accessor :eof
    alias_method :attr_eof, :eof
    undef_method :eof
    alias_method :attr_eof=, :eof=
    undef_method :eof=
    
    attr_accessor :min
    alias_method :attr_min, :min
    undef_method :min
    alias_method :attr_min=, :min=
    undef_method :min=
    
    attr_accessor :max
    alias_method :attr_max, :max
    undef_method :max
    alias_method :attr_max=, :max=
    undef_method :max=
    
    attr_accessor :special
    alias_method :attr_special, :special
    undef_method :special
    alias_method :attr_special=, :special=
    undef_method :special=
    
    attr_accessor :transition
    alias_method :attr_transition, :transition
    undef_method :transition
    alias_method :attr_transition=, :transition=
    undef_method :transition=
    
    # just the Vector<Integer> indicating which unique edge table is at
    # position i.
    attr_accessor :transition_edge_tables
    alias_method :attr_transition_edge_tables, :transition_edge_tables
    undef_method :transition_edge_tables
    alias_method :attr_transition_edge_tables=, :transition_edge_tables=
    undef_method :transition_edge_tables=
    
    # not used by java yet
    attr_accessor :unique_compressed_special_state_num
    alias_method :attr_unique_compressed_special_state_num, :unique_compressed_special_state_num
    undef_method :unique_compressed_special_state_num
    alias_method :attr_unique_compressed_special_state_num=, :unique_compressed_special_state_num=
    undef_method :unique_compressed_special_state_num=
    
    # Which generator to use if we're building state tables
    attr_accessor :generator
    alias_method :attr_generator, :generator
    undef_method :generator
    alias_method :attr_generator=, :generator=
    undef_method :generator=
    
    typesig { [] }
    def initialize
      @start_state = nil
      @decision_number = 0
      @decision_nfastart_state = nil
      @description = nil
      @unique_states = HashMap.new
      @states = Vector.new
      @state_counter = 0
      @number_of_states = 0
      @user_k = -1
      @max_k = -1
      @reduced = true
      @cyclic = false
      @predicate_visible = false
      @has_predicate_blocked_by_action = false
      @unreachable_alts = nil
      @n_alts = 0
      @alt_to_accept_state = nil
      @recursive_alt_set = IntervalSet.new
      @nfa = nil
      @nfa_converter = nil
      @probe = DecisionProbe.new(self)
      @conversion_start_time = 0
      @edge_transition_class_map = LinkedHashMap.new
      @edge_transition_class = 0
      @special_states = nil
      @special_state_sts = nil
      @accept = nil
      @eot = nil
      @eof = nil
      @min = nil
      @max = nil
      @special = nil
      @transition = nil
      @transition_edge_tables = nil
      @unique_compressed_special_state_num = 0
      @generator = nil
    end
    
    typesig { [::Java::Int, NFAState] }
    def initialize(decision_number, decision_start_state)
      @start_state = nil
      @decision_number = 0
      @decision_nfastart_state = nil
      @description = nil
      @unique_states = HashMap.new
      @states = Vector.new
      @state_counter = 0
      @number_of_states = 0
      @user_k = -1
      @max_k = -1
      @reduced = true
      @cyclic = false
      @predicate_visible = false
      @has_predicate_blocked_by_action = false
      @unreachable_alts = nil
      @n_alts = 0
      @alt_to_accept_state = nil
      @recursive_alt_set = IntervalSet.new
      @nfa = nil
      @nfa_converter = nil
      @probe = DecisionProbe.new(self)
      @conversion_start_time = 0
      @edge_transition_class_map = LinkedHashMap.new
      @edge_transition_class = 0
      @special_states = nil
      @special_state_sts = nil
      @accept = nil
      @eot = nil
      @eof = nil
      @min = nil
      @max = nil
      @special = nil
      @transition = nil
      @transition_edge_tables = nil
      @unique_compressed_special_state_num = 0
      @generator = nil
      @decision_number = decision_number
      @decision_nfastart_state = decision_start_state
      @nfa = decision_start_state.attr_nfa
      @n_alts = @nfa.attr_grammar.get_number_of_alts_for_decision_nfa(decision_start_state)
      # setOptions( nfa.grammar.getDecisionOptions(getDecisionNumber()) );
      init_alt_related_info
      # long start = System.currentTimeMillis();
      @nfa_converter = NFAToDFAConverter.new(self)
      begin
        @nfa_converter.convert
        # figure out if there are problems with decision
        verify
        if (!@probe.is_deterministic || @probe.analysis_overflowed)
          @probe.issue_warnings
        end
        # must be after verify as it computes cyclic, needed by this routine
        # should be after warnings because early termination or something
        # will not allow the reset to operate properly in some cases.
        reset_state_numbers_to_be_contiguous
        # long stop = System.currentTimeMillis();
        # System.out.println("verify cost: "+(int)(stop-start)+" ms");
      rescue AnalysisTimeoutException => at
        @probe.report_analysis_timeout
        if (!ok_to_retry_dfawith_k1)
          @probe.issue_warnings
        end
      rescue NonLLStarDecisionException => non_ll
        @probe.report_non_llstar_decision(self)
        # >1 alt recurses, k=* and no auto backtrack nor manual sem/syn
        if (!ok_to_retry_dfawith_k1)
          @probe.issue_warnings
        end
      end
    end
    
    typesig { [] }
    # Walk all states and reset their numbers to be a contiguous sequence
    # of integers starting from 0.  Only cyclic DFA can have unused positions
    # in states list.  State i might be identical to a previous state j and
    # will result in states[i] == states[j].  We don't want to waste a state
    # number on this.  Useful mostly for code generation in tables.
    # 
    # At the start of this routine, states[i].stateNumber <= i by definition.
    # If states[50].stateNumber is 50 then a cycle during conversion may
    # try to add state 103, but we find that an identical DFA state, named
    # 50, already exists, hence, states[103]==states[50] and both have
    # stateNumber 50 as they point at same object.  Afterwards, the set
    # of state numbers from all states should represent a contiguous range
    # from 0..n-1 where n is the number of unique states.
    def reset_state_numbers_to_be_contiguous
      if (get_user_max_lookahead > 0)
        # all numbers are unique already; no states are thrown out.
        return
      end
      # walk list of DFAState objects by state number,
      # setting state numbers to 0..n-1
      snum = 0
      i = 0
      while i <= get_max_state_number
        s = get_state(i)
        # some states are unused after creation most commonly due to cycles
        # or conflict resolution.
        if ((s).nil?)
          i += 1
          next
        end
        # state i is mapped to DFAState with state number set to i originally
        # so if it's less than i, then we renumbered it already; that
        # happens when states have been merged or cycles occurred I think.
        # states[50] will point to DFAState with s50 in it but
        # states[103] might also point at this same DFAState.  Since
        # 50 < 103 then it's already been renumbered as it points downwards.
        already_renumbered = s.attr_state_number < i
        if (!already_renumbered)
          # state i is a valid state, reset it's state number
          s.attr_state_number = snum # rewrite state numbers to be 0..n-1
          snum += 1
        end
        i += 1
      end
      if (!(snum).equal?(get_number_of_states))
        ErrorManager.internal_error("DFA " + RJava.cast_to_string(@decision_number) + ": " + RJava.cast_to_string(@decision_nfastart_state.get_description) + " num unique states " + RJava.cast_to_string(get_number_of_states) + "!= num renumbered states " + RJava.cast_to_string(snum))
      end
    end
    
    typesig { [] }
    # JAVA-SPECIFIC Accessors!!!!!  It is so impossible to get arrays
    # or even consistently formatted strings acceptable to java that
    # I am forced to build the individual char elements here
    def get_java_compressed_accept
      return get_run_length_encoding(@accept)
    end
    
    typesig { [] }
    def get_java_compressed_eot
      return get_run_length_encoding(@eot)
    end
    
    typesig { [] }
    def get_java_compressed_eof
      return get_run_length_encoding(@eof)
    end
    
    typesig { [] }
    def get_java_compressed_min
      return get_run_length_encoding(@min)
    end
    
    typesig { [] }
    def get_java_compressed_max
      return get_run_length_encoding(@max)
    end
    
    typesig { [] }
    def get_java_compressed_special
      return get_run_length_encoding(@special)
    end
    
    typesig { [] }
    def get_java_compressed_transition
      if ((@transition).nil? || (@transition.size).equal?(0))
        return nil
      end
      encoded = ArrayList.new(@transition.size)
      # walk Vector<Vector<FormattedInteger>> which is the transition[][] table
      i = 0
      while i < @transition.size
        transitions_for_state = @transition.element_at(i)
        encoded.add(get_run_length_encoding(transitions_for_state))
        i += 1
      end
      return encoded
    end
    
    typesig { [JavaList] }
    # Compress the incoming data list so that runs of same number are
    # encoded as number,value pair sequences.  3 -1 -1 -1 28 is encoded
    # as 1 3 3 -1 1 28.  I am pretty sure this is the lossless compression
    # that GIF files use.  Transition tables are heavily compressed by
    # this technique.  I got the idea from JFlex http://jflex.de/
    # 
    # Return List<String> where each string is either \xyz for 8bit char
    # and \uFFFF for 16bit.  Hideous and specific to Java, but it is the
    # only target bad enough to need it.
    def get_run_length_encoding(data)
      if ((data).nil? || (data.size).equal?(0))
        # for states with no transitions we want an empty string ""
        # to hold its place in the transitions array.
        empty = ArrayList.new
        empty.add("")
        return empty
      end
      size_ = Math.max(2, data.size / 2)
      encoded = ArrayList.new(size_) # guess at size
      # scan values looking for runs
      i = 0
      empty_value = Utils.integer(-1)
      while (i < data.size)
        i_ = data.get(i)
        if ((i_).nil?)
          i_ = empty_value
        end
        # count how many v there are?
        n = 0
        j = i
        while j < data.size
          v = data.get(j)
          if ((v).nil?)
            v = empty_value
          end
          if ((i_ == v))
            n += 1
          else
            break
          end
          j += 1
        end
        encoded.add(@generator.attr_target.encode_int_as_char_escape(RJava.cast_to_char(n)))
        encoded.add(@generator.attr_target.encode_int_as_char_escape(RJava.cast_to_char(i_.int_value)))
        i += n
      end
      return encoded
    end
    
    typesig { [CodeGenerator] }
    def create_state_tables(generator)
      # System.out.println("createTables:\n"+this);
      @generator = generator
      @description = RJava.cast_to_string(get_nfadecision_start_state.get_description)
      @description = RJava.cast_to_string(generator.attr_target.get_target_string_literal_from_string(@description))
      # create all the tables
      @special = Vector.new(self.get_number_of_states) # Vector<short>
      @special.set_size(self.get_number_of_states)
      @special_states = ArrayList.new # List<DFAState>
      @special_state_sts = ArrayList.new # List<ST>
      @accept = Vector.new(self.get_number_of_states) # Vector<int>
      @accept.set_size(self.get_number_of_states)
      @eot = Vector.new(self.get_number_of_states) # Vector<int>
      @eot.set_size(self.get_number_of_states)
      @eof = Vector.new(self.get_number_of_states) # Vector<int>
      @eof.set_size(self.get_number_of_states)
      @min = Vector.new(self.get_number_of_states) # Vector<int>
      @min.set_size(self.get_number_of_states)
      @max = Vector.new(self.get_number_of_states) # Vector<int>
      @max.set_size(self.get_number_of_states)
      @transition = Vector.new(self.get_number_of_states) # Vector<Vector<int>>
      @transition.set_size(self.get_number_of_states)
      @transition_edge_tables = Vector.new(self.get_number_of_states) # Vector<Vector<int>>
      @transition_edge_tables.set_size(self.get_number_of_states)
      # for each state in the DFA, fill relevant tables.
      it = nil
      if (get_user_max_lookahead > 0)
        it = @states.iterator
      else
        it = get_unique_states.values.iterator
      end
      while (it.has_next)
        s = it.next_
        if ((s).nil?)
          # ignore null states; some acylic DFA see this condition
          # when inlining DFA (due to lacking of exit branch pruning?)
          next
        end
        if (s.is_accept_state)
          # can't compute min,max,special,transition on accepts
          @accept.set(s.attr_state_number, Utils.integer(s.get_uniquely_predicted_alt))
        else
          create_min_max_tables(s)
          create_transition_table_entry_for_state(s)
          create_special_table(s)
          create_eotand_eoftables(s)
        end
      end
      # now that we have computed list of specialStates, gen code for 'em
      i = 0
      while i < @special_states.size
        ss = @special_states.get(i)
        state_st = generator.generate_special_state(ss)
        @special_state_sts.add(state_st)
        i += 1
      end
      # check that the tables are not messed up by encode/decode
      # testEncodeDecode(min);
      # testEncodeDecode(max);
      # testEncodeDecode(accept);
      # testEncodeDecode(special);
      # System.out.println("min="+min);
      # System.out.println("max="+max);
      # System.out.println("eot="+eot);
      # System.out.println("eof="+eof);
      # System.out.println("accept="+accept);
      # System.out.println("special="+special);
      # System.out.println("transition="+transition);
    end
    
    typesig { [DFAState] }
    # private void testEncodeDecode(List data) {
    #     System.out.println("data="+data);
    #     List encoded = getRunLengthEncoding(data);
    #     StringBuffer buf = new StringBuffer();
    #     for (int i = 0; i < encoded.size(); i++) {
    #         String I = (String)encoded.get(i);
    #         int v = 0;
    #         if ( I.startsWith("\\u") ) {
    #             v = Integer.parseInt(I.substring(2,I.length()), 16);
    #         }
    #         else {
    #             v = Integer.parseInt(I.substring(1,I.length()), 8);
    #         }
    #         buf.append((char)v);
    #     }
    #     String encodedS = buf.toString();
    #     short[] decoded = org.antlr.runtime.DFA.unpackEncodedString(encodedS);
    #     //System.out.println("decoded:");
    #     for (int i = 0; i < decoded.length; i++) {
    #         short x = decoded[i];
    #         if ( x!=((Integer)data.get(i)).intValue() ) {
    #             System.err.println("problem with encoding");
    #         }
    #         //System.out.print(", "+x);
    #     }
    #     //System.out.println();
    # }
    def create_min_max_tables(s)
      smin = Label::MAX_CHAR_VALUE + 1
      smax = Label::MIN_ATOM_VALUE - 1
      j = 0
      while j < s.get_number_of_transitions
        edge = s.transition(j)
        label = edge.attr_label
        if (label.is_atom)
          if (label.get_atom >= Label::MIN_CHAR_VALUE)
            if (label.get_atom < smin)
              smin = label.get_atom
            end
            if (label.get_atom > smax)
              smax = label.get_atom
            end
          end
        else
          if (label.is_set)
            labels = label.get_set
            lmin = labels.get_min_element
            # if valid char (don't do EOF) and less than current min
            if (lmin < smin && lmin >= Label::MIN_CHAR_VALUE)
              smin = labels.get_min_element
            end
            if (labels.get_max_element > smax)
              smax = labels.get_max_element
            end
          end
        end
        j += 1
      end
      if (smax < 0)
        # must be predicates or pure EOT transition; just zero out min, max
        smin = Label::MIN_CHAR_VALUE
        smax = Label::MIN_CHAR_VALUE
      end
      @min.set(s.attr_state_number, Utils.integer(RJava.cast_to_char(smin)))
      @max.set(s.attr_state_number, Utils.integer(RJava.cast_to_char(smax)))
      if (smax < 0 || smin > Label::MAX_CHAR_VALUE || smin < 0)
        ErrorManager.internal_error("messed up: min=" + RJava.cast_to_string(@min) + ", max=" + RJava.cast_to_string(@max))
      end
    end
    
    typesig { [DFAState] }
    def create_transition_table_entry_for_state(s)
      # System.out.println("createTransitionTableEntryForState s"+s.stateNumber+
      #     " dec "+s.dfa.decisionNumber+" cyclic="+s.dfa.isCyclic());
      smax = (@max.get(s.attr_state_number)).int_value
      smin = (@min.get(s.attr_state_number)).int_value
      state_transitions = Vector.new(smax - smin + 1)
      state_transitions.set_size(smax - smin + 1)
      @transition.set(s.attr_state_number, state_transitions)
      j = 0
      while j < s.get_number_of_transitions
        edge = s.transition(j)
        label = edge.attr_label
        if (label.is_atom && label.get_atom >= Label::MIN_CHAR_VALUE)
          label_index = label.get_atom - smin # offset from 0
          state_transitions.set(label_index, Utils.integer(edge.attr_target.attr_state_number))
        else
          if (label.is_set)
            labels = label.get_set
            atoms = labels.to_array
            a = 0
            while a < atoms.attr_length
              # set the transition if the label is valid (don't do EOF)
              if (atoms[a] >= Label::MIN_CHAR_VALUE)
                label_index = atoms[a] - smin # offset from 0
                state_transitions.set(label_index, Utils.integer(edge.attr_target.attr_state_number))
              end
              a += 1
            end
          end
        end
        j += 1
      end
      # track unique state transition tables so we can reuse
      edge_class = @edge_transition_class_map.get(state_transitions)
      if (!(edge_class).nil?)
        # System.out.println("we've seen this array before; size="+stateTransitions.size());
        @transition_edge_tables.set(s.attr_state_number, edge_class)
      else
        edge_class = Utils.integer(@edge_transition_class)
        @transition_edge_tables.set(s.attr_state_number, edge_class)
        @edge_transition_class_map.put(state_transitions, edge_class)
        @edge_transition_class += 1
      end
    end
    
    typesig { [DFAState] }
    # Set up the EOT and EOF tables; we cannot put -1 min/max values so
    # we need another way to test that in the DFA transition function.
    def create_eotand_eoftables(s)
      j = 0
      while j < s.get_number_of_transitions
        edge = s.transition(j)
        label = edge.attr_label
        if (label.is_atom)
          if ((label.get_atom).equal?(Label::EOT))
            # eot[s] points to accept state
            @eot.set(s.attr_state_number, Utils.integer(edge.attr_target.attr_state_number))
          else
            if ((label.get_atom).equal?(Label::EOF))
              # eof[s] points to accept state
              @eof.set(s.attr_state_number, Utils.integer(edge.attr_target.attr_state_number))
            end
          end
        else
          if (label.is_set)
            labels = label.get_set
            atoms = labels.to_array
            a = 0
            while a < atoms.attr_length
              if ((atoms[a]).equal?(Label::EOT))
                # eot[s] points to accept state
                @eot.set(s.attr_state_number, Utils.integer(edge.attr_target.attr_state_number))
              else
                if ((atoms[a]).equal?(Label::EOF))
                  @eof.set(s.attr_state_number, Utils.integer(edge.attr_target.attr_state_number))
                end
              end
              a += 1
            end
          end
        end
        j += 1
      end
    end
    
    typesig { [DFAState] }
    def create_special_table(s)
      # number all special states from 0...n-1 instead of their usual numbers
      has_sem_pred = false
      # TODO this code is very similar to canGenerateSwitch.  Refactor to share
      j = 0
      while j < s.get_number_of_transitions
        edge = s.transition(j)
        label = edge.attr_label
        # can't do a switch if the edges have preds or are going to
        # require gated predicates
        if (label.is_semantic_predicate || !((edge.attr_target).get_gated_predicates_in_nfaconfigurations).nil?)
          has_sem_pred = true
          break
        end
        j += 1
      end
      # if has pred or too big for table, make it special
      smax = (@max.get(s.attr_state_number)).int_value
      smin = (@min.get(s.attr_state_number)).int_value
      if (has_sem_pred || smax - smin > self.attr_max_state_transitions_for_table)
        @special.set(s.attr_state_number, Utils.integer(@unique_compressed_special_state_num))
        @unique_compressed_special_state_num += 1
        @special_states.add(s)
      else
        @special.set(s.attr_state_number, Utils.integer(-1)) # not special
      end
    end
    
    typesig { [IntStream] }
    def predict(input)
      interp = Interpreter.new(@nfa.attr_grammar, input)
      return interp.predict(self)
    end
    
    typesig { [DFAState] }
    # Add a new DFA state to this DFA if not already present.
    # To force an acyclic, fixed maximum depth DFA, just always
    # return the incoming state.  By not reusing old states,
    # no cycles can be created.  If we're doing fixed k lookahead
    # don't updated uniqueStates, just return incoming state, which
    # indicates it's a new state.
    def add_state(d)
      if (get_user_max_lookahead > 0)
        return d
      end
      # does a DFA state exist already with everything the same
      # except its state number?
      existing = @unique_states.get(d)
      if (!(existing).nil?)
        # System.out.println("state "+d.stateNumber+" exists as state "+
        #     existing.stateNumber);
        # already there...get the existing DFA state
        return existing
      end
      # if not there, then add new state.
      @unique_states.put(d, d)
      @number_of_states += 1
      return d
    end
    
    typesig { [DFAState] }
    def remove_state(d)
      it = @unique_states.remove(d)
      if (!(it).nil?)
        @number_of_states -= 1
      end
    end
    
    typesig { [] }
    def get_unique_states
      return @unique_states
    end
    
    typesig { [] }
    # What is the max state number ever created?  This may be beyond
    # getNumberOfStates().
    def get_max_state_number
      return @states.size - 1
    end
    
    typesig { [::Java::Int] }
    def get_state(state_number)
      return @states.get(state_number)
    end
    
    typesig { [::Java::Int, DFAState] }
    def set_state(state_number, d)
      @states.set(state_number, d)
    end
    
    typesig { [] }
    # Is the DFA reduced?  I.e., does every state have a path to an accept
    # state?  If not, don't delete as we need to generate an error indicating
    # which paths are "dead ends".  Also tracks list of alts with no accept
    # state in the DFA.  Must call verify() first before this makes sense.
    def is_reduced
      return @reduced
    end
    
    typesig { [] }
    # Is this DFA cyclic?  That is, are there any loops?  If not, then
    # the DFA is essentially an LL(k) predictor for some fixed, max k value.
    # We can build a series of nested IF statements to match this.  In the
    # presence of cycles, we need to build a general DFA and interpret it
    # to distinguish between alternatives.
    def is_cyclic
      return @cyclic && (get_user_max_lookahead).equal?(0)
    end
    
    typesig { [] }
    def can_inline_decision
      return !is_cyclic && !@probe.is_non_llstar_decision && get_number_of_states < CodeGenerator::MAX_ACYCLIC_DFA_STATES_INLINE
    end
    
    typesig { [] }
    # Is this DFA derived from the NFA for the Tokens rule?
    def is_tokens_rule_decision
      if (!(@nfa.attr_grammar.attr_type).equal?(Grammar::LEXER))
        return false
      end
      nfa_start = get_nfadecision_start_state
      r = @nfa.attr_grammar.get_locally_defined_rule(Grammar::ARTIFICIAL_TOKENS_RULENAME)
      tokens_rule_start = r.attr_start_state
      tokens_decision_start = tokens_rule_start.attr_transition[0].attr_target
      return (nfa_start).equal?(tokens_decision_start)
    end
    
    typesig { [] }
    # The user may specify a max, acyclic lookahead for any decision.  No
    # DFA cycles are created when this value, k, is greater than 0.
    # If this decision has no k lookahead specified, then try the grammar.
    def get_user_max_lookahead
      if (@user_k >= 0)
        # cache for speed
        return @user_k
      end
      @user_k = @nfa.attr_grammar.get_user_max_lookahead(@decision_number)
      return @user_k
    end
    
    typesig { [] }
    def get_auto_backtrack_mode
      return @nfa.attr_grammar.get_auto_backtrack_mode(@decision_number)
    end
    
    typesig { [::Java::Int] }
    def set_user_max_lookahead(k)
      @user_k = k
    end
    
    typesig { [] }
    # Return k if decision is LL(k) for some k else return max int
    def get_max_lookahead_depth
      if (is_cyclic)
        return JavaInteger::MAX_VALUE
      end
      return @max_k
    end
    
    typesig { [] }
    # Return a list of Integer alt numbers for which no lookahead could
    # be computed or for which no single DFA accept state predicts those
    # alts.  Must call verify() first before this makes sense.
    def get_unreachable_alts
      return @unreachable_alts
    end
    
    typesig { [] }
    # Once this DFA has been built, need to verify that:
    # 
    # 1. it's reduced
    # 2. all alts have an accept state
    # 
    # Elsewhere, in the NFA converter, we need to verify that:
    # 
    # 3. alts i and j have disjoint lookahead if no sem preds
    # 4. if sem preds, nondeterministic alts must be sufficiently covered
    # 
    # This is avoided if analysis bails out for any reason.
    def verify
      does_state_reach_accept_state(@start_state)
    end
    
    typesig { [DFAState] }
    # figure out if this state eventually reaches an accept state and
    # modify the instance variable 'reduced' to indicate if we find
    # at least one state that cannot reach an accept state.  This implies
    # that the overall DFA is not reduced.  This algorithm should be
    # linear in the number of DFA states.
    # 
    # The algorithm also tracks which alternatives have no accept state,
    # indicating a nondeterminism.
    # 
    # Also computes whether the DFA is cyclic.
    # 
    # TODO: I call getUniquelyPredicatedAlt too much; cache predicted alt
    def does_state_reach_accept_state(d)
      if (d.is_accept_state)
        # accept states have no edges emanating from them so we can return
        d.set_accept_state_reachable(REACHABLE_YES)
        # this alt is uniquely predicted, remove from nondeterministic list
        predicts = d.get_uniquely_predicted_alt
        @unreachable_alts.remove(Utils.integer(predicts))
        return true
      end
      # avoid infinite loops
      d.set_accept_state_reachable(REACHABLE_BUSY)
      an_edge_reaches_accept_state = false
      # Visit every transition, track if at least one edge reaches stop state
      # Cannot terminate when we know this state reaches stop state since
      # all transitions must be traversed to set status of each DFA state.
      i = 0
      while i < d.get_number_of_transitions
        t = d.transition(i)
        edge_target = t.attr_target
        target_status = edge_target.get_accept_state_reachable
        if ((target_status).equal?(REACHABLE_BUSY))
          # avoid cycles; they say nothing
          @cyclic = true
          i += 1
          next
        end
        if ((target_status).equal?(REACHABLE_YES))
          # avoid unnecessary work
          an_edge_reaches_accept_state = true
          i += 1
          next
        end
        if ((target_status).equal?(REACHABLE_NO))
          # avoid unnecessary work
          i += 1
          next
        end
        # target must be REACHABLE_UNKNOWN (i.e., unvisited)
        if (does_state_reach_accept_state(edge_target))
          an_edge_reaches_accept_state = true
          # have to keep looking so don't break loop
          # must cover all states even if we find a path for this state
        end
        i += 1
      end
      if (an_edge_reaches_accept_state)
        d.set_accept_state_reachable(REACHABLE_YES)
      else
        d.set_accept_state_reachable(REACHABLE_NO)
        @reduced = false
      end
      return an_edge_reaches_accept_state
    end
    
    typesig { [] }
    # Walk all accept states and find the manually-specified synpreds.
    # Gated preds are not always hoisted
    # I used to do this in the code generator, but that is too late.
    # This converter tries to avoid computing DFA for decisions in
    # syntactic predicates that are not ever used such as those
    # created by autobacktrack mode.
    def find_all_gated_syn_preds_used_in_dfaaccept_states
      n_alts = get_number_of_alts
      i = 1
      while i <= n_alts
        a = get_accept_state(i)
        # System.out.println("alt "+i+": "+a);
        if (!(a).nil?)
          synpreds = a.get_gated_syntactic_predicates_in_nfaconfigurations
          if (!(synpreds).nil?)
            # add all the predicates we find (should be just one, right?)
            it = synpreds.iterator
            while it.has_next
              semctx = it.next_
              # System.out.println("synpreds: "+semctx);
              @nfa.attr_grammar.syn_pred_used_in_dfa(self, semctx)
            end
          end
        end
        i += 1
      end
    end
    
    typesig { [] }
    def get_nfadecision_start_state
      return @decision_nfastart_state
    end
    
    typesig { [::Java::Int] }
    def get_accept_state(alt)
      return @alt_to_accept_state[alt]
    end
    
    typesig { [::Java::Int, DFAState] }
    def set_accept_state(alt, accept_state)
      @alt_to_accept_state[alt] = accept_state
    end
    
    typesig { [] }
    def get_description
      return @description
    end
    
    typesig { [] }
    def get_decision_number
      return @decision_nfastart_state.get_decision_number
    end
    
    typesig { [] }
    # If this DFA failed to finish during construction, we might be
    # able to retry with k=1 but we need to know whether it will
    # potentially succeed.  Can only succeed if there is a predicate
    # to resolve the issue.  Don't try if k=1 already as it would
    # cycle forever.  Timeout can retry with k=1 even if no predicate
    # if k!=1.
    def ok_to_retry_dfawith_k1
      non_llstar_or_overflow_and_predicate_visible = (@probe.is_non_llstar_decision || @probe.analysis_overflowed) && @predicate_visible # auto backtrack or manual sem/syn
      return !(get_user_max_lookahead).equal?(1) && (analysis_timed_out || non_llstar_or_overflow_and_predicate_visible)
    end
    
    typesig { [] }
    def get_reason_for_failure
      buf = StringBuffer.new
      if (@probe.is_non_llstar_decision)
        buf.append("non-LL(*)")
        if (@predicate_visible)
          buf.append(" && predicate visible")
        end
      end
      if (@probe.analysis_overflowed)
        buf.append("recursion overflow")
        if (@predicate_visible)
          buf.append(" && predicate visible")
        end
      end
      if (analysis_timed_out)
        if (buf.length > 0)
          buf.append(" && ")
        end
        buf.append("timed out (>")
        buf.append(self.attr_max_time_per_dfa_creation)
        buf.append("ms)")
      end
      buf.append("\n")
      return buf.to_s
    end
    
    typesig { [] }
    # What GrammarAST node (derived from the grammar) is this DFA
    # associated with?  It will point to the start of a block or
    # the loop back of a (...)+ block etc...
    def get_decision_astnode
      return @decision_nfastart_state.attr_associated_astnode
    end
    
    typesig { [] }
    def is_greedy
      block_ast = @nfa.attr_grammar.get_decision_block_ast(@decision_number)
      v = @nfa.attr_grammar.get_block_option(block_ast, "greedy")
      if (!(v).nil? && (v == "false"))
        return false
      end
      return true
    end
    
    typesig { [] }
    def new_state
      n = DFAState.new(self)
      n.attr_state_number = @state_counter
      @state_counter += 1
      @states.set_size(n.attr_state_number + 1)
      @states.set(n.attr_state_number, n) # track state num to state
      return n
    end
    
    typesig { [] }
    def get_number_of_states
      if (get_user_max_lookahead > 0)
        # if using fixed lookahead then uniqueSets not set
        return @states.size
      end
      return @number_of_states
    end
    
    typesig { [] }
    def get_number_of_alts
      return @n_alts
    end
    
    typesig { [] }
    def analysis_timed_out
      return @probe.analysis_timed_out
    end
    
    typesig { [] }
    def init_alt_related_info
      @unreachable_alts = LinkedList.new
      i = 1
      while i <= @n_alts
        @unreachable_alts.add(Utils.integer(i))
        i += 1
      end
      @alt_to_accept_state = Array.typed(DFAState).new(@n_alts + 1) { nil }
    end
    
    typesig { [] }
    def to_s
      serializer = FASerializer.new(@nfa.attr_grammar)
      if ((@start_state).nil?)
        return ""
      end
      return serializer.serialize(@start_state, false)
    end
    
    private
    alias_method :initialize__dfa, :initialize
  end
  
end
