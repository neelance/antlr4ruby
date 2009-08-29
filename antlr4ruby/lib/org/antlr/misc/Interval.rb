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
module Org::Antlr::Misc
  module IntervalImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
    }
  end
  
  # An immutable inclusive interval a..b
  class Interval 
    include_class_members IntervalImports
    
    class_module.module_eval {
      const_set_lazy(:INTERVAL_POOL_MAX_VALUE) { 1000 }
      const_attr_reader  :INTERVAL_POOL_MAX_VALUE
      
      
      def cache
        defined?(@@cache) ? @@cache : @@cache= Array.typed(Interval).new(INTERVAL_POOL_MAX_VALUE + 1) { nil }
      end
      alias_method :attr_cache, :cache
      
      def cache=(value)
        @@cache = value
      end
      alias_method :attr_cache=, :cache=
    }
    
    attr_accessor :a
    alias_method :attr_a, :a
    undef_method :a
    alias_method :attr_a=, :a=
    undef_method :a=
    
    attr_accessor :b
    alias_method :attr_b, :b
    undef_method :b
    alias_method :attr_b=, :b=
    undef_method :b=
    
    class_module.module_eval {
      
      def creates
        defined?(@@creates) ? @@creates : @@creates= 0
      end
      alias_method :attr_creates, :creates
      
      def creates=(value)
        @@creates = value
      end
      alias_method :attr_creates=, :creates=
      
      
      def misses
        defined?(@@misses) ? @@misses : @@misses= 0
      end
      alias_method :attr_misses, :misses
      
      def misses=(value)
        @@misses = value
      end
      alias_method :attr_misses=, :misses=
      
      
      def hits
        defined?(@@hits) ? @@hits : @@hits= 0
      end
      alias_method :attr_hits, :hits
      
      def hits=(value)
        @@hits = value
      end
      alias_method :attr_hits=, :hits=
      
      
      def out_of_range
        defined?(@@out_of_range) ? @@out_of_range : @@out_of_range= 0
      end
      alias_method :attr_out_of_range, :out_of_range
      
      def out_of_range=(value)
        @@out_of_range = value
      end
      alias_method :attr_out_of_range=, :out_of_range=
    }
    
    typesig { [::Java::Int, ::Java::Int] }
    def initialize(a, b)
      @a = 0
      @b = 0
      @a = a
      @b = b
    end
    
    class_module.module_eval {
      typesig { [::Java::Int, ::Java::Int] }
      # Interval objects are used readonly so share all with the
      # same single value a==b up to some max size.  Use an array as a perfect hash.
      # Return shared object for 0..INTERVAL_POOL_MAX_VALUE or a new
      # Interval object with a..a in it.  On Java.g, 218623 IntervalSets
      # have a..a (set with 1 element).
      def create(a, b)
        # return new Interval(a,b);
        # cache just a..a
        if (!(a).equal?(b) || a < 0 || a > INTERVAL_POOL_MAX_VALUE)
          return Interval.new(a, b)
        end
        if ((self.attr_cache[a]).nil?)
          self.attr_cache[a] = Interval.new(a, a)
        end
        return self.attr_cache[a]
      end
    }
    
    typesig { [Object] }
    def ==(o)
      if ((o).nil?)
        return false
      end
      other = o
      return (@a).equal?(other.attr_a) && (@b).equal?(other.attr_b)
    end
    
    typesig { [Interval] }
    # Does this start completely before other? Disjoint
    def starts_before_disjoint(other)
      return @a < other.attr_a && @b < other.attr_a
    end
    
    typesig { [Interval] }
    # Does this start at or before other? Nondisjoint
    def starts_before_non_disjoint(other)
      return @a <= other.attr_a && @b >= other.attr_a
    end
    
    typesig { [Interval] }
    # Does this.a start after other.b? May or may not be disjoint
    def starts_after(other)
      return @a > other.attr_a
    end
    
    typesig { [Interval] }
    # Does this start completely after other? Disjoint
    def starts_after_disjoint(other)
      return @a > other.attr_b
    end
    
    typesig { [Interval] }
    # Does this start after other? NonDisjoint
    def starts_after_non_disjoint(other)
      return @a > other.attr_a && @a <= other.attr_b # this.b>=other.b implied
    end
    
    typesig { [Interval] }
    # Are both ranges disjoint? I.e., no overlap?
    def disjoint(other)
      return starts_before_disjoint(other) || starts_after_disjoint(other)
    end
    
    typesig { [Interval] }
    # Are two intervals adjacent such as 0..41 and 42..42?
    def adjacent(other)
      return (@a).equal?(other.attr_b + 1) || (@b).equal?(other.attr_a - 1)
    end
    
    typesig { [Interval] }
    def properly_contains(other)
      return other.attr_a >= @a && other.attr_b <= @b
    end
    
    typesig { [Interval] }
    # Return the interval computed from combining this and other
    def union(other)
      return Interval.create(Math.min(@a, other.attr_a), Math.max(@b, other.attr_b))
    end
    
    typesig { [Interval] }
    # Return the interval in common between this and o
    def intersection(other)
      return Interval.create(Math.max(@a, other.attr_a), Math.min(@b, other.attr_b))
    end
    
    typesig { [Interval] }
    # Return the interval with elements from this not in other;
    # other must not be totally enclosed (properly contained)
    # within this, which would result in two disjoint intervals
    # instead of the single one returned by this method.
    def difference_not_properly_contained(other)
      diff = nil
      # other.a to left of this.a (or same)
      if (other.starts_before_non_disjoint(self))
        diff = Interval.create(Math.max(@a, other.attr_b + 1), @b)
      # other.a to right of this.a
      else
        if (other.starts_after_non_disjoint(self))
          diff = Interval.create(@a, other.attr_a - 1)
        end
      end
      return diff
    end
    
    typesig { [] }
    def to_s
      return RJava.cast_to_string(@a) + ".." + RJava.cast_to_string(@b)
    end
    
    private
    alias_method :initialize__interval, :initialize
  end
  
end
