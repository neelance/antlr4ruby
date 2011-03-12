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
module Org::Antlr::Runtime
  module DFAImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  # public int specialTransition(int state, int symbol) {
  #     return 0;
  # }
  # A DFA implemented as a set of transition tables.
  # 
  # Any state that has a semantic predicate edge is special; those states
  # are generated with if-then-else structures in a specialStateTransition()
  # which is generated by cyclicDFA template.
  # 
  # There are at most 32767 states (16-bit signed short).
  # Could get away with byte sometimes but would have to generate different
  # types and the simulation code too.  For a point of reference, the Java
  # lexer's Tokens rule DFA has 326 states roughly.
  class DFA 
    include_class_members DFAImports
    
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
    
    attr_accessor :accept
    alias_method :attr_accept, :accept
    undef_method :accept
    alias_method :attr_accept=, :accept=
    undef_method :accept=
    
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
    
    attr_accessor :decision_number
    alias_method :attr_decision_number, :decision_number
    undef_method :decision_number
    alias_method :attr_decision_number=, :decision_number=
    undef_method :decision_number=
    
    # Which recognizer encloses this DFA?  Needed to check backtracking
    attr_accessor :recognizer
    alias_method :attr_recognizer, :recognizer
    undef_method :recognizer
    alias_method :attr_recognizer=, :recognizer=
    undef_method :recognizer=
    
    class_module.module_eval {
      const_set_lazy(:DEBUG) { false }
      const_attr_reader  :DEBUG
    }
    
    typesig { [IntStream] }
    # From the input stream, predict what alternative will succeed
    # using this DFA (representing the covering regular approximation
    # to the underlying CFL).  Return an alternative number 1..n.  Throw
    # an exception upon error.
    def predict(input)
      if (DEBUG)
        System.err.println("Enter DFA.predict for decision " + RJava.cast_to_string(@decision_number))
      end
      mark_ = input.mark # remember where decision started in input
      s = 0 # we always start at s0
      begin
        while (true)
          if (DEBUG)
            System.err.println("DFA " + RJava.cast_to_string(@decision_number) + " state " + RJava.cast_to_string(s) + " LA(1)=" + RJava.cast_to_string(RJava.cast_to_char(input._la(1))) + "(" + RJava.cast_to_string(input._la(1)) + "), index=" + RJava.cast_to_string(input.index))
          end
          special_state = @special[s]
          if (special_state >= 0)
            if (DEBUG)
              System.err.println("DFA " + RJava.cast_to_string(@decision_number) + " state " + RJava.cast_to_string(s) + " is special state " + RJava.cast_to_string(special_state))
            end
            s = special_state_transition(special_state, input)
            if (DEBUG)
              System.err.println("DFA " + RJava.cast_to_string(@decision_number) + " returns from special state " + RJava.cast_to_string(special_state) + " to " + RJava.cast_to_string(s))
            end
            if ((s).equal?(-1))
              no_viable_alt(s, input)
              return 0
            end
            input.consume
            next
          end
          if (@accept[s] >= 1)
            if (DEBUG)
              System.err.println("accept; predict " + RJava.cast_to_string(@accept[s]) + " from state " + RJava.cast_to_string(s))
            end
            return @accept[s]
          end
          # look for a normal char transition
          c = RJava.cast_to_char(input._la(1)) # -1 == \uFFFF, all tokens fit in 65000 space
          if (c >= @min[s] && c <= @max[s])
            snext = @transition[s][c - @min[s]] # move to next state
            if (snext < 0)
              # was in range but not a normal transition
              # must check EOT, which is like the else clause.
              # eot[s]>=0 indicates that an EOT edge goes to another
              # state.
              if (@eot[s] >= 0)
                # EOT Transition to accept state?
                if (DEBUG)
                  System.err.println("EOT transition")
                end
                s = @eot[s]
                input.consume
                # TODO: I had this as return accept[eot[s]]
                # which assumed here that the EOT edge always
                # went to an accept...faster to do this, but
                # what about predicated edges coming from EOT
                # target?
                next
              end
              no_viable_alt(s, input)
              return 0
            end
            s = snext
            input.consume
            next
          end
          if (@eot[s] >= 0)
            # EOT Transition?
            if (DEBUG)
              System.err.println("EOT transition")
            end
            s = @eot[s]
            input.consume
            next
          end
          if ((c).equal?(RJava.cast_to_char(Token::EOF)) && @eof[s] >= 0)
            # EOF Transition to accept state?
            if (DEBUG)
              System.err.println("accept via EOF; predict " + RJava.cast_to_string(@accept[@eof[s]]) + " from " + RJava.cast_to_string(@eof[s]))
            end
            return @accept[@eof[s]]
          end
          # not in range and not EOF/EOT, must be invalid symbol
          if (DEBUG)
            System.err.println("min[" + RJava.cast_to_string(s) + "]=" + RJava.cast_to_string(@min[s]))
            System.err.println("max[" + RJava.cast_to_string(s) + "]=" + RJava.cast_to_string(@max[s]))
            System.err.println("eot[" + RJava.cast_to_string(s) + "]=" + RJava.cast_to_string(@eot[s]))
            System.err.println("eof[" + RJava.cast_to_string(s) + "]=" + RJava.cast_to_string(@eof[s]))
            p = 0
            while p < @transition[s].attr_length
              System.err.print(RJava.cast_to_string(@transition[s][p]) + " ")
              p += 1
            end
            System.err.println
          end
          no_viable_alt(s, input)
          return 0
        end
      ensure
        input.rewind(mark_)
      end
    end
    
    typesig { [::Java::Int, IntStream] }
    def no_viable_alt(s, input)
      if (@recognizer.attr_state.attr_backtracking > 0)
        @recognizer.attr_state.attr_failed = true
        return
      end
      nvae = NoViableAltException.new(get_description, @decision_number, s, input)
      error(nvae)
      raise nvae
    end
    
    typesig { [NoViableAltException] }
    # A hook for debugging interface
    def error(nvae)
    end
    
    typesig { [::Java::Int, IntStream] }
    def special_state_transition(s, input)
      return -1
    end
    
    typesig { [] }
    def get_description
      return "n/a"
    end
    
    class_module.module_eval {
      typesig { [String] }
      # Given a String that has a run-length-encoding of some unsigned shorts
      # like "\1\2\3\9", convert to short[] {2,9,9,9}.  We do this to avoid
      # static short[] which generates so much init code that the class won't
      # compile. :(
      def unpack_encoded_string(encoded_string)
        # walk first to find how big it is.
        size = 0
        i = 0
        while i < encoded_string.length
          size += encoded_string.char_at(i)
          i += 2
        end
        data = Array.typed(::Java::Short).new(size) { 0 }
        di = 0
        i_ = 0
        while i_ < encoded_string.length
          n = encoded_string.char_at(i_)
          v = encoded_string.char_at(i_ + 1)
          # add v n times to data
          j = 1
          while j <= n
            data[((di += 1) - 1)] = RJava.cast_to_short(v)
            j += 1
          end
          i_ += 2
        end
        return data
      end
      
      typesig { [String] }
      # Hideous duplication of code, but I need different typed arrays out :(
      def unpack_encoded_string_to_unsigned_chars(encoded_string)
        # walk first to find how big it is.
        size = 0
        i = 0
        while i < encoded_string.length
          size += encoded_string.char_at(i)
          i += 2
        end
        data = CharArray.new(size)
        di = 0
        i_ = 0
        while i_ < encoded_string.length
          n = encoded_string.char_at(i_)
          v = encoded_string.char_at(i_ + 1)
          # add v n times to data
          j = 1
          while j <= n
            data[((di += 1) - 1)] = v
            j += 1
          end
          i_ += 2
        end
        return data
      end
    }
    
    typesig { [] }
    def initialize
      @eot = nil
      @eof = nil
      @min = nil
      @max = nil
      @accept = nil
      @special = nil
      @transition = nil
      @decision_number = 0
      @recognizer = nil
    end
    
    private
    alias_method :initialize__dfa, :initialize
  end
  
end
