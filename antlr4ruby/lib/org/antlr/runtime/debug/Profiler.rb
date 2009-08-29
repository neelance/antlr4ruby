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
module Org::Antlr::Runtime::Debug
  module ProfilerImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include ::Org::Antlr::Runtime
      include_const ::Org::Antlr::Runtime::Misc, :Stats
      include ::Java::Util
      include_const ::Java::Io, :IOException
    }
  end
  
  # Using the debug event interface, track what is happening in the parser
  # and record statistics about the runtime.
  class Profiler < ProfilerImports.const_get :BlankDebugEventListener
    include_class_members ProfilerImports
    
    class_module.module_eval {
      # Because I may change the stats, I need to track that for later
      # computations to be consistent.
      const_set_lazy(:Version) { "2" }
      const_attr_reader  :Version
      
      const_set_lazy(:RUNTIME_STATS_FILENAME) { "runtime.stats" }
      const_attr_reader  :RUNTIME_STATS_FILENAME
      
      const_set_lazy(:NUM_RUNTIME_STATS) { 29 }
      const_attr_reader  :NUM_RUNTIME_STATS
    }
    
    attr_accessor :parser
    alias_method :attr_parser, :parser
    undef_method :parser
    alias_method :attr_parser=, :parser=
    undef_method :parser=
    
    # working variables
    attr_accessor :rule_level
    alias_method :attr_rule_level, :rule_level
    undef_method :rule_level
    alias_method :attr_rule_level=, :rule_level=
    undef_method :rule_level=
    
    attr_accessor :decision_level
    alias_method :attr_decision_level, :decision_level
    undef_method :decision_level
    alias_method :attr_decision_level=, :decision_level=
    undef_method :decision_level=
    
    attr_accessor :max_lookahead_in_current_decision
    alias_method :attr_max_lookahead_in_current_decision, :max_lookahead_in_current_decision
    undef_method :max_lookahead_in_current_decision
    alias_method :attr_max_lookahead_in_current_decision=, :max_lookahead_in_current_decision=
    undef_method :max_lookahead_in_current_decision=
    
    attr_accessor :last_token_consumed
    alias_method :attr_last_token_consumed, :last_token_consumed
    undef_method :last_token_consumed
    alias_method :attr_last_token_consumed=, :last_token_consumed=
    undef_method :last_token_consumed=
    
    attr_accessor :lookahead_stack
    alias_method :attr_lookahead_stack, :lookahead_stack
    undef_method :lookahead_stack
    alias_method :attr_lookahead_stack=, :lookahead_stack=
    undef_method :lookahead_stack=
    
    # stats variables
    attr_accessor :num_rule_invocations
    alias_method :attr_num_rule_invocations, :num_rule_invocations
    undef_method :num_rule_invocations
    alias_method :attr_num_rule_invocations=, :num_rule_invocations=
    undef_method :num_rule_invocations=
    
    attr_accessor :num_guessing_rule_invocations
    alias_method :attr_num_guessing_rule_invocations, :num_guessing_rule_invocations
    undef_method :num_guessing_rule_invocations
    alias_method :attr_num_guessing_rule_invocations=, :num_guessing_rule_invocations=
    undef_method :num_guessing_rule_invocations=
    
    attr_accessor :max_rule_invocation_depth
    alias_method :attr_max_rule_invocation_depth, :max_rule_invocation_depth
    undef_method :max_rule_invocation_depth
    alias_method :attr_max_rule_invocation_depth=, :max_rule_invocation_depth=
    undef_method :max_rule_invocation_depth=
    
    attr_accessor :num_fixed_decisions
    alias_method :attr_num_fixed_decisions, :num_fixed_decisions
    undef_method :num_fixed_decisions
    alias_method :attr_num_fixed_decisions=, :num_fixed_decisions=
    undef_method :num_fixed_decisions=
    
    attr_accessor :num_cyclic_decisions
    alias_method :attr_num_cyclic_decisions, :num_cyclic_decisions
    undef_method :num_cyclic_decisions
    alias_method :attr_num_cyclic_decisions=, :num_cyclic_decisions=
    undef_method :num_cyclic_decisions=
    
    attr_accessor :num_backtrack_decisions
    alias_method :attr_num_backtrack_decisions, :num_backtrack_decisions
    undef_method :num_backtrack_decisions
    alias_method :attr_num_backtrack_decisions=, :num_backtrack_decisions=
    undef_method :num_backtrack_decisions=
    
    attr_accessor :decision_max_fixed_lookaheads
    alias_method :attr_decision_max_fixed_lookaheads, :decision_max_fixed_lookaheads
    undef_method :decision_max_fixed_lookaheads
    alias_method :attr_decision_max_fixed_lookaheads=, :decision_max_fixed_lookaheads=
    undef_method :decision_max_fixed_lookaheads=
    
    # TODO: make List
    attr_accessor :decision_max_cyclic_lookaheads
    alias_method :attr_decision_max_cyclic_lookaheads, :decision_max_cyclic_lookaheads
    undef_method :decision_max_cyclic_lookaheads
    alias_method :attr_decision_max_cyclic_lookaheads=, :decision_max_cyclic_lookaheads=
    undef_method :decision_max_cyclic_lookaheads=
    
    attr_accessor :decision_max_syn_pred_lookaheads
    alias_method :attr_decision_max_syn_pred_lookaheads, :decision_max_syn_pred_lookaheads
    undef_method :decision_max_syn_pred_lookaheads
    alias_method :attr_decision_max_syn_pred_lookaheads=, :decision_max_syn_pred_lookaheads=
    undef_method :decision_max_syn_pred_lookaheads=
    
    attr_accessor :num_hidden_tokens
    alias_method :attr_num_hidden_tokens, :num_hidden_tokens
    undef_method :num_hidden_tokens
    alias_method :attr_num_hidden_tokens=, :num_hidden_tokens=
    undef_method :num_hidden_tokens=
    
    attr_accessor :num_chars_matched
    alias_method :attr_num_chars_matched, :num_chars_matched
    undef_method :num_chars_matched
    alias_method :attr_num_chars_matched=, :num_chars_matched=
    undef_method :num_chars_matched=
    
    attr_accessor :num_hidden_chars_matched
    alias_method :attr_num_hidden_chars_matched, :num_hidden_chars_matched
    undef_method :num_hidden_chars_matched
    alias_method :attr_num_hidden_chars_matched=, :num_hidden_chars_matched=
    undef_method :num_hidden_chars_matched=
    
    attr_accessor :num_semantic_predicates
    alias_method :attr_num_semantic_predicates, :num_semantic_predicates
    undef_method :num_semantic_predicates
    alias_method :attr_num_semantic_predicates=, :num_semantic_predicates=
    undef_method :num_semantic_predicates=
    
    attr_accessor :num_syntactic_predicates
    alias_method :attr_num_syntactic_predicates, :num_syntactic_predicates
    undef_method :num_syntactic_predicates
    alias_method :attr_num_syntactic_predicates=, :num_syntactic_predicates=
    undef_method :num_syntactic_predicates=
    
    attr_accessor :number_reported_errors
    alias_method :attr_number_reported_errors, :number_reported_errors
    undef_method :number_reported_errors
    alias_method :attr_number_reported_errors=, :number_reported_errors=
    undef_method :number_reported_errors=
    
    attr_accessor :num_memoization_cache_misses
    alias_method :attr_num_memoization_cache_misses, :num_memoization_cache_misses
    undef_method :num_memoization_cache_misses
    alias_method :attr_num_memoization_cache_misses=, :num_memoization_cache_misses=
    undef_method :num_memoization_cache_misses=
    
    attr_accessor :num_memoization_cache_hits
    alias_method :attr_num_memoization_cache_hits, :num_memoization_cache_hits
    undef_method :num_memoization_cache_hits
    alias_method :attr_num_memoization_cache_hits=, :num_memoization_cache_hits=
    undef_method :num_memoization_cache_hits=
    
    attr_accessor :num_memoization_cache_entries
    alias_method :attr_num_memoization_cache_entries, :num_memoization_cache_entries
    undef_method :num_memoization_cache_entries
    alias_method :attr_num_memoization_cache_entries=, :num_memoization_cache_entries=
    undef_method :num_memoization_cache_entries=
    
    typesig { [] }
    def initialize
      @parser = nil
      @rule_level = 0
      @decision_level = 0
      @max_lookahead_in_current_decision = 0
      @last_token_consumed = nil
      @lookahead_stack = nil
      @num_rule_invocations = 0
      @num_guessing_rule_invocations = 0
      @max_rule_invocation_depth = 0
      @num_fixed_decisions = 0
      @num_cyclic_decisions = 0
      @num_backtrack_decisions = 0
      @decision_max_fixed_lookaheads = nil
      @decision_max_cyclic_lookaheads = nil
      @decision_max_syn_pred_lookaheads = nil
      @num_hidden_tokens = 0
      @num_chars_matched = 0
      @num_hidden_chars_matched = 0
      @num_semantic_predicates = 0
      @num_syntactic_predicates = 0
      @number_reported_errors = 0
      @num_memoization_cache_misses = 0
      @num_memoization_cache_hits = 0
      @num_memoization_cache_entries = 0
      super()
      @parser = nil
      @rule_level = 0
      @decision_level = 0
      @max_lookahead_in_current_decision = 0
      @last_token_consumed = nil
      @lookahead_stack = ArrayList.new
      @num_rule_invocations = 0
      @num_guessing_rule_invocations = 0
      @max_rule_invocation_depth = 0
      @num_fixed_decisions = 0
      @num_cyclic_decisions = 0
      @num_backtrack_decisions = 0
      @decision_max_fixed_lookaheads = Array.typed(::Java::Int).new(200) { 0 }
      @decision_max_cyclic_lookaheads = Array.typed(::Java::Int).new(200) { 0 }
      @decision_max_syn_pred_lookaheads = ArrayList.new
      @num_hidden_tokens = 0
      @num_chars_matched = 0
      @num_hidden_chars_matched = 0
      @num_semantic_predicates = 0
      @num_syntactic_predicates = 0
      @number_reported_errors = 0
      @num_memoization_cache_misses = 0
      @num_memoization_cache_hits = 0
      @num_memoization_cache_entries = 0
    end
    
    typesig { [DebugParser] }
    def initialize(parser)
      @parser = nil
      @rule_level = 0
      @decision_level = 0
      @max_lookahead_in_current_decision = 0
      @last_token_consumed = nil
      @lookahead_stack = nil
      @num_rule_invocations = 0
      @num_guessing_rule_invocations = 0
      @max_rule_invocation_depth = 0
      @num_fixed_decisions = 0
      @num_cyclic_decisions = 0
      @num_backtrack_decisions = 0
      @decision_max_fixed_lookaheads = nil
      @decision_max_cyclic_lookaheads = nil
      @decision_max_syn_pred_lookaheads = nil
      @num_hidden_tokens = 0
      @num_chars_matched = 0
      @num_hidden_chars_matched = 0
      @num_semantic_predicates = 0
      @num_syntactic_predicates = 0
      @number_reported_errors = 0
      @num_memoization_cache_misses = 0
      @num_memoization_cache_hits = 0
      @num_memoization_cache_entries = 0
      super()
      @parser = nil
      @rule_level = 0
      @decision_level = 0
      @max_lookahead_in_current_decision = 0
      @last_token_consumed = nil
      @lookahead_stack = ArrayList.new
      @num_rule_invocations = 0
      @num_guessing_rule_invocations = 0
      @max_rule_invocation_depth = 0
      @num_fixed_decisions = 0
      @num_cyclic_decisions = 0
      @num_backtrack_decisions = 0
      @decision_max_fixed_lookaheads = Array.typed(::Java::Int).new(200) { 0 }
      @decision_max_cyclic_lookaheads = Array.typed(::Java::Int).new(200) { 0 }
      @decision_max_syn_pred_lookaheads = ArrayList.new
      @num_hidden_tokens = 0
      @num_chars_matched = 0
      @num_hidden_chars_matched = 0
      @num_semantic_predicates = 0
      @num_syntactic_predicates = 0
      @number_reported_errors = 0
      @num_memoization_cache_misses = 0
      @num_memoization_cache_hits = 0
      @num_memoization_cache_entries = 0
      @parser = parser
    end
    
    typesig { [String, String] }
    def enter_rule(grammar_file_name, rule_name)
      # System.out.println("enterRule "+ruleName);
      @rule_level += 1
      @num_rule_invocations += 1
      if (@rule_level > @max_rule_invocation_depth)
        @max_rule_invocation_depth = @rule_level
      end
    end
    
    typesig { [IntStream, ::Java::Int, String] }
    # Track memoization; this is not part of standard debug interface
    # but is triggered by profiling.  Code gen inserts an override
    # for this method in the recognizer, which triggers this method.
    def examine_rule_memoization(input, rule_index, rule_name)
      # System.out.println("examine memo "+ruleName);
      stop_index = @parser.get_rule_memoization(rule_index, input.index)
      if ((stop_index).equal?(BaseRecognizer::MEMO_RULE_UNKNOWN))
        # System.out.println("rule "+ruleIndex+" missed @ "+input.index());
        @num_memoization_cache_misses += 1
        @num_guessing_rule_invocations += 1 # we'll have to enter
      else
        # regardless of rule success/failure, if in cache, we have a cache hit
        # System.out.println("rule "+ruleIndex+" hit @ "+input.index());
        @num_memoization_cache_hits += 1
      end
    end
    
    typesig { [IntStream, ::Java::Int, ::Java::Int, String] }
    def memoize(input, rule_index, rule_start_index, rule_name)
      # count how many entries go into table
      # System.out.println("memoize "+ruleName);
      @num_memoization_cache_entries += 1
    end
    
    typesig { [String, String] }
    def exit_rule(grammar_file_name, rule_name)
      @rule_level -= 1
    end
    
    typesig { [::Java::Int] }
    def enter_decision(decision_number)
      @decision_level += 1
      starting_lookahead_index = @parser.get_token_stream.index
      # System.out.println("enterDecision "+decisionNumber+" @ index "+startingLookaheadIndex);
      @lookahead_stack.add(starting_lookahead_index)
    end
    
    typesig { [::Java::Int] }
    def exit_decision(decision_number)
      # System.out.println("exitDecision "+decisionNumber);
      # track how many of acyclic, cyclic here as we don't know what kind
      # yet in enterDecision event.
      if (@parser.attr_is_cyclic_decision)
        @num_cyclic_decisions += 1
      else
        @num_fixed_decisions += 1
      end
      @lookahead_stack.remove(@lookahead_stack.size - 1) # pop lookahead depth counter
      @decision_level -= 1
      if (@parser.attr_is_cyclic_decision)
        if (@num_cyclic_decisions >= @decision_max_cyclic_lookaheads.attr_length)
          bigger = Array.typed(::Java::Int).new(@decision_max_cyclic_lookaheads.attr_length * 2) { 0 }
          System.arraycopy(@decision_max_cyclic_lookaheads, 0, bigger, 0, @decision_max_cyclic_lookaheads.attr_length)
          @decision_max_cyclic_lookaheads = bigger
        end
        @decision_max_cyclic_lookaheads[@num_cyclic_decisions - 1] = @max_lookahead_in_current_decision
      else
        if (@num_fixed_decisions >= @decision_max_fixed_lookaheads.attr_length)
          bigger = Array.typed(::Java::Int).new(@decision_max_fixed_lookaheads.attr_length * 2) { 0 }
          System.arraycopy(@decision_max_fixed_lookaheads, 0, bigger, 0, @decision_max_fixed_lookaheads.attr_length)
          @decision_max_fixed_lookaheads = bigger
        end
        @decision_max_fixed_lookaheads[@num_fixed_decisions - 1] = @max_lookahead_in_current_decision
      end
      @parser.attr_is_cyclic_decision = false # can't nest so just reset to false
      @max_lookahead_in_current_decision = 0
    end
    
    typesig { [Token] }
    def consume_token(token)
      # System.out.println("consume token "+token);
      @last_token_consumed = token
    end
    
    typesig { [] }
    # The parser is in a decision if the decision depth > 0.  This
    # works for backtracking also, which can have nested decisions.
    def in_decision
      return @decision_level > 0
    end
    
    typesig { [Token] }
    def consume_hidden_token(token)
      # System.out.println("consume hidden token "+token);
      @last_token_consumed = token
    end
    
    typesig { [::Java::Int, Token] }
    # Track refs to lookahead if in a fixed/nonfixed decision.
    def _lt(i, t)
      if (in_decision)
        # get starting index off stack
        stack_top = @lookahead_stack.size - 1
        starting_index = @lookahead_stack.get(stack_top)
        # compute lookahead depth
        this_ref_index = @parser.get_token_stream.index
        num_hidden = get_number_of_hidden_tokens(starting_index.int_value, this_ref_index)
        depth = i + this_ref_index - starting_index.int_value - num_hidden
        # System.out.println("LT("+i+") @ index "+thisRefIndex+" is depth "+depth+
        # " max is "+maxLookaheadInCurrentDecision);
        if (depth > @max_lookahead_in_current_decision)
          @max_lookahead_in_current_decision = depth
        end
      end
    end
    
    typesig { [::Java::Int] }
    # Track backtracking decisions.  You'll see a fixed or cyclic decision
    # and then a backtrack.
    # 
    # enter rule
    # ...
    # enter decision
    # LA and possibly consumes (for cyclic DFAs)
    # begin backtrack level
    # mark m
    # rewind m
    # end backtrack level, success
    # exit decision
    # ...
    # exit rule
    def begin_backtrack(level)
      # System.out.println("enter backtrack "+level);
      @num_backtrack_decisions += 1
    end
    
    typesig { [::Java::Int, ::Java::Boolean] }
    # Successful or not, track how much lookahead synpreds use
    def end_backtrack(level, successful)
      # System.out.println("exit backtrack "+level+": "+successful);
      @decision_max_syn_pred_lookaheads.add(@max_lookahead_in_current_decision)
    end
    
    typesig { [RecognitionException] }
    # public void mark(int marker) {
    # int i = parser.getTokenStream().index();
    # System.out.println("mark @ index "+i);
    # synPredLookaheadStack.add(new Integer(i));
    # }
    # 
    # public void rewind(int marker) {
    # // pop starting index off stack
    # int stackTop = synPredLookaheadStack.size()-1;
    # Integer startingIndex = (Integer)synPredLookaheadStack.get(stackTop);
    # synPredLookaheadStack.remove(synPredLookaheadStack.size()-1);
    # // compute lookahead depth
    # int stopIndex = parser.getTokenStream().index();
    # System.out.println("rewind @ index "+stopIndex);
    # int depth = stopIndex - startingIndex.intValue();
    # System.out.println("depth of lookahead for synpred: "+depth);
    # decisionMaxSynPredLookaheads.add(
    # new Integer(depth)
    # );
    # }
    def recognition_exception(e)
      @number_reported_errors += 1
    end
    
    typesig { [::Java::Boolean, String] }
    def semantic_predicate(result, predicate)
      if (in_decision)
        @num_semantic_predicates += 1
      end
    end
    
    typesig { [] }
    def terminate
      stats = to_notify_string
      begin
        Stats.write_report(RUNTIME_STATS_FILENAME, stats)
      rescue IOException => ioe
        System.err.println(ioe)
        ioe.print_stack_trace(System.err)
      end
      System.out.println(to_s(stats))
    end
    
    typesig { [DebugParser] }
    def set_parser(parser)
      @parser = parser
    end
    
    typesig { [] }
    # R E P O R T I N G
    def to_notify_string
      input = @parser.get_token_stream
      i = 0
      while i < input.size && !(@last_token_consumed).nil? && i <= @last_token_consumed.get_token_index
        t = input.get(i)
        if (!(t.get_channel).equal?(Token::DEFAULT_CHANNEL))
          @num_hidden_tokens += 1
          @num_hidden_chars_matched += t.get_text.length
        end
        i += 1
      end
      @num_chars_matched = @last_token_consumed.get_stop_index + 1
      @decision_max_fixed_lookaheads = trim(@decision_max_fixed_lookaheads, @num_fixed_decisions)
      @decision_max_cyclic_lookaheads = trim(@decision_max_cyclic_lookaheads, @num_cyclic_decisions)
      buf = StringBuffer.new
      buf.append(Version)
      buf.append(Character.new(?\t.ord))
      buf.append(@parser.get_class.get_name)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_rule_invocations)
      buf.append(Character.new(?\t.ord))
      buf.append(@max_rule_invocation_depth)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_fixed_decisions)
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.min(@decision_max_fixed_lookaheads))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.max(@decision_max_fixed_lookaheads))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.avg(@decision_max_fixed_lookaheads))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.stddev(@decision_max_fixed_lookaheads))
      buf.append(Character.new(?\t.ord))
      buf.append(@num_cyclic_decisions)
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.min(@decision_max_cyclic_lookaheads))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.max(@decision_max_cyclic_lookaheads))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.avg(@decision_max_cyclic_lookaheads))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.stddev(@decision_max_cyclic_lookaheads))
      buf.append(Character.new(?\t.ord))
      buf.append(@num_backtrack_decisions)
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.min(to_array(@decision_max_syn_pred_lookaheads)))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.max(to_array(@decision_max_syn_pred_lookaheads)))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.avg(to_array(@decision_max_syn_pred_lookaheads)))
      buf.append(Character.new(?\t.ord))
      buf.append(Stats.stddev(to_array(@decision_max_syn_pred_lookaheads)))
      buf.append(Character.new(?\t.ord))
      buf.append(@num_semantic_predicates)
      buf.append(Character.new(?\t.ord))
      buf.append(@parser.get_token_stream.size)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_hidden_tokens)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_chars_matched)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_hidden_chars_matched)
      buf.append(Character.new(?\t.ord))
      buf.append(@number_reported_errors)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_memoization_cache_hits)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_memoization_cache_misses)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_guessing_rule_invocations)
      buf.append(Character.new(?\t.ord))
      buf.append(@num_memoization_cache_entries)
      return buf.to_s
    end
    
    typesig { [] }
    def to_s
      return to_s(to_notify_string)
    end
    
    class_module.module_eval {
      typesig { [String] }
      def decode_report_data(data)
        fields = Array.typed(String).new(NUM_RUNTIME_STATS) { nil }
        st = StringTokenizer.new(data, "\t")
        i = 0
        while (st.has_more_tokens)
          fields[i] = st.next_token
          i += 1
        end
        if (!(i).equal?(NUM_RUNTIME_STATS))
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
        buf.append("ANTLR Runtime Report; Profile Version ")
        buf.append(fields[0])
        buf.append(Character.new(?\n.ord))
        buf.append("parser name ")
        buf.append(fields[1])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of rule invocations ")
        buf.append(fields[2])
        buf.append(Character.new(?\n.ord))
        buf.append("Number of rule invocations in \"guessing\" mode ")
        buf.append(fields[27])
        buf.append(Character.new(?\n.ord))
        buf.append("max rule invocation nesting depth ")
        buf.append(fields[3])
        buf.append(Character.new(?\n.ord))
        buf.append("number of fixed lookahead decisions ")
        buf.append(fields[4])
        buf.append(Character.new(?\n.ord))
        buf.append("min lookahead used in a fixed lookahead decision ")
        buf.append(fields[5])
        buf.append(Character.new(?\n.ord))
        buf.append("max lookahead used in a fixed lookahead decision ")
        buf.append(fields[6])
        buf.append(Character.new(?\n.ord))
        buf.append("average lookahead depth used in fixed lookahead decisions ")
        buf.append(fields[7])
        buf.append(Character.new(?\n.ord))
        buf.append("standard deviation of depth used in fixed lookahead decisions ")
        buf.append(fields[8])
        buf.append(Character.new(?\n.ord))
        buf.append("number of arbitrary lookahead decisions ")
        buf.append(fields[9])
        buf.append(Character.new(?\n.ord))
        buf.append("min lookahead used in an arbitrary lookahead decision ")
        buf.append(fields[10])
        buf.append(Character.new(?\n.ord))
        buf.append("max lookahead used in an arbitrary lookahead decision ")
        buf.append(fields[11])
        buf.append(Character.new(?\n.ord))
        buf.append("average lookahead depth used in arbitrary lookahead decisions ")
        buf.append(fields[12])
        buf.append(Character.new(?\n.ord))
        buf.append("standard deviation of depth used in arbitrary lookahead decisions ")
        buf.append(fields[13])
        buf.append(Character.new(?\n.ord))
        buf.append("number of evaluated syntactic predicates ")
        buf.append(fields[14])
        buf.append(Character.new(?\n.ord))
        buf.append("min lookahead used in a syntactic predicate ")
        buf.append(fields[15])
        buf.append(Character.new(?\n.ord))
        buf.append("max lookahead used in a syntactic predicate ")
        buf.append(fields[16])
        buf.append(Character.new(?\n.ord))
        buf.append("average lookahead depth used in syntactic predicates ")
        buf.append(fields[17])
        buf.append(Character.new(?\n.ord))
        buf.append("standard deviation of depth used in syntactic predicates ")
        buf.append(fields[18])
        buf.append(Character.new(?\n.ord))
        buf.append("rule memoization cache size ")
        buf.append(fields[28])
        buf.append(Character.new(?\n.ord))
        buf.append("number of rule memoization cache hits ")
        buf.append(fields[25])
        buf.append(Character.new(?\n.ord))
        buf.append("number of rule memoization cache misses ")
        buf.append(fields[26])
        buf.append(Character.new(?\n.ord))
        buf.append("number of evaluated semantic predicates ")
        buf.append(fields[19])
        buf.append(Character.new(?\n.ord))
        buf.append("number of tokens ")
        buf.append(fields[20])
        buf.append(Character.new(?\n.ord))
        buf.append("number of hidden tokens ")
        buf.append(fields[21])
        buf.append(Character.new(?\n.ord))
        buf.append("number of char ")
        buf.append(fields[22])
        buf.append(Character.new(?\n.ord))
        buf.append("number of hidden char ")
        buf.append(fields[23])
        buf.append(Character.new(?\n.ord))
        buf.append("number of syntax errors ")
        buf.append(fields[24])
        buf.append(Character.new(?\n.ord))
        return buf.to_s
      end
    }
    
    typesig { [Array.typed(::Java::Int), ::Java::Int] }
    def trim(x, n)
      if (n < x.attr_length)
        trimmed = Array.typed(::Java::Int).new(n) { 0 }
        System.arraycopy(x, 0, trimmed, 0, n)
        x = trimmed
      end
      return x
    end
    
    typesig { [JavaList] }
    def to_array(a)
      x = Array.typed(::Java::Int).new(a.size) { 0 }
      i = 0
      while i < a.size
        i_ = a.get(i)
        x[i] = i_.int_value
        i += 1
      end
      return x
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # Get num hidden tokens between i..j inclusive
    def get_number_of_hidden_tokens(i, j)
      n = 0
      input = @parser.get_token_stream
      ti = i
      while ti < input.size && ti <= j
        t = input.get(ti)
        if (!(t.get_channel).equal?(Token::DEFAULT_CHANNEL))
          n += 1
        end
        ti += 1
      end
      return n
    end
    
    private
    alias_method :initialize__profiler, :initialize
  end
  
end
