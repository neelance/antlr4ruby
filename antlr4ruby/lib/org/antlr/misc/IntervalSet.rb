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
  module IntervalSetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Tool, :Grammar
      include ::Java::Util
    }
  end
  
  # protected void finalize() throws Throwable {
  # super.finalize();
  # System.out.println("size "+intervals.size()+" "+size());
  # }
  # 
  # A set of integers that relies on ranges being common to do
  # "run-length-encoded" like compression (if you view an IntSet like
  # a BitSet with runs of 0s and 1s).  Only ranges are recorded so that
  # a few ints up near value 1000 don't cause massive bitsets, just two
  # integer intervals.
  # 
  # element values may be negative.  Useful for sets of EPSILON and EOF.
  # 
  # 0..9 char range is index pair ['\u0030','\u0039'].
  # Multiple ranges are encoded with multiple index pairs.  Isolated
  # elements are encoded with an index pair where both intervals are the same.
  # 
  # The ranges are ordered and disjoint so that 2..6 appears before 101..103.
  class IntervalSet 
    include_class_members IntervalSetImports
    include IntSet
    
    class_module.module_eval {
      const_set_lazy(:COMPLETE_SET) { IntervalSet.of(0, Label::MAX_CHAR_VALUE) }
      const_attr_reader  :COMPLETE_SET
    }
    
    # The list of sorted, disjoint intervals.
    attr_accessor :intervals
    alias_method :attr_intervals, :intervals
    undef_method :intervals
    alias_method :attr_intervals=, :intervals=
    undef_method :intervals=
    
    typesig { [] }
    # Create a set with no elements
    def initialize
      @intervals = nil
      @intervals = ArrayList.new(2) # most sets are 1 or 2 elements
    end
    
    typesig { [JavaList] }
    def initialize(intervals)
      @intervals = nil
      @intervals = intervals
    end
    
    class_module.module_eval {
      typesig { [::Java::Int] }
      # Create a set with a single element, el.
      def of(a)
        s = IntervalSet.new
        s.add(a)
        return s
      end
      
      typesig { [::Java::Int, ::Java::Int] }
      # Create a set with all ints within range [a..b] (inclusive)
      def of(a, b)
        s = IntervalSet.new
        s.add(a, b)
        return s
      end
    }
    
    typesig { [::Java::Int] }
    # Add a single element to the set.  An isolated element is stored
    # as a range el..el.
    def add(el)
      add(el, el)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # Add interval; i.e., add all integers from a to b to set.
    # If b<a, do nothing.
    # Keep list in sorted order (by left range value).
    # If overlap, combine ranges.  For example,
    # If this is {1..5, 10..20}, adding 6..7 yields
    # {1..5, 6..7, 10..20}.  Adding 4..8 yields {1..8, 10..20}.
    def add(a, b)
      add(Interval.create(a, b))
    end
    
    typesig { [Interval] }
    # copy on write so we can cache a..a intervals and sets of that
    def add(addition)
      # System.out.println("add "+addition+" to "+intervals.toString());
      if (addition.attr_b < addition.attr_a)
        return
      end
      # find position in list
      # Use iterators as we modify list in place
      iter = @intervals.list_iterator
      while iter.has_next
        r = iter.next_
        if ((addition == r))
          return
        end
        if (addition.adjacent(r) || !addition.disjoint(r))
          # next to each other, make a single larger interval
          bigger = addition.union(r)
          iter.set(bigger)
          # make sure we didn't just create an interval that
          # should be merged with next interval in list
          if (iter.has_next)
            next__ = iter.next_
            if (bigger.adjacent(next__) || !bigger.disjoint(next__))
              # if we bump up against or overlap next, merge
              iter.remove # remove this one
              iter.previous # move backwards to what we just set
              iter.set(bigger.union(next__)) # set to 3 merged ones
            end
          end
          return
        end
        if (addition.starts_before_disjoint(r))
          # insert before r
          iter.previous
          iter.add(addition)
          return
        end
      end
      # ok, must be after last interval (and disjoint from last interval)
      # just add it
      @intervals.add(addition)
    end
    
    typesig { [IntSet] }
    # protected void add(Interval addition) {
    # //System.out.println("add "+addition+" to "+intervals.toString());
    # if ( addition.b<addition.a ) {
    # return;
    # }
    # // find position in list
    # //for (ListIterator iter = intervals.listIterator(); iter.hasNext();) {
    # int n = intervals.size();
    # for (int i=0; i<n; i++) {
    # Interval r = (Interval)intervals.get(i);
    # if ( addition.equals(r) ) {
    # return;
    # }
    # if ( addition.adjacent(r) || !addition.disjoint(r) ) {
    # // next to each other, make a single larger interval
    # Interval bigger = addition.union(r);
    # intervals.set(i, bigger);
    # // make sure we didn't just create an interval that
    # // should be merged with next interval in list
    # if ( (i+1)<n ) {
    # i++;
    # Interval next = (Interval)intervals.get(i);
    # if ( bigger.adjacent(next)||!bigger.disjoint(next) ) {
    # // if we bump up against or overlap next, merge
    # intervals.remove(i); // remove next one
    # i--;
    # intervals.set(i, bigger.union(next)); // set to 3 merged ones
    # }
    # }
    # return;
    # }
    # if ( addition.startsBeforeDisjoint(r) ) {
    # // insert before r
    # intervals.add(i, addition);
    # return;
    # }
    # // if disjoint and after r, a future iteration will handle it
    # }
    # // ok, must be after last interval (and disjoint from last interval)
    # // just add it
    # intervals.add(addition);
    # }
    def add_all(set_)
      if ((set_).nil?)
        return
      end
      if (!(set_.is_a?(IntervalSet)))
        raise IllegalArgumentException.new("can't add non IntSet (" + RJava.cast_to_string(set_.get_class.get_name) + ") to IntervalSet")
      end
      other = set_
      # walk set and add each interval
      n = other.attr_intervals.size
      i = 0
      while i < n
        i_ = other.attr_intervals.get(i)
        self.add(i_.attr_a, i_.attr_b)
        i += 1
      end
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def complement(min_element, max_element)
      return self.complement(IntervalSet.of(min_element, max_element))
    end
    
    typesig { [IntSet] }
    # Given the set of possible values (rather than, say UNICODE or MAXINT),
    # return a new set containing all elements in vocabulary, but not in
    # this.  The computation is (vocabulary - this).
    # 
    # 'this' is assumed to be either a subset or equal to vocabulary.
    def complement(vocabulary)
      if ((vocabulary).nil?)
        return nil # nothing in common with null set
      end
      if (!(vocabulary.is_a?(IntervalSet)))
        raise IllegalArgumentException.new("can't complement with non IntervalSet (" + RJava.cast_to_string(vocabulary.get_class.get_name) + ")")
      end
      vocabulary_is = (vocabulary)
      max_element = vocabulary_is.get_max_element
      compl = IntervalSet.new
      n = @intervals.size
      if ((n).equal?(0))
        return compl
      end
      first = @intervals.get(0)
      # add a range from 0 to first.a constrained to vocab
      if (first.attr_a > 0)
        s = IntervalSet.of(0, first.attr_a - 1)
        a = s.and_(vocabulary_is)
        compl.add_all(a)
      end
      i = 1
      while i < n
        # from 2nd interval .. nth
        previous_ = @intervals.get(i - 1)
        current = @intervals.get(i)
        s = IntervalSet.of(previous_.attr_b + 1, current.attr_a - 1)
        a = s.and_(vocabulary_is)
        compl.add_all(a)
        i += 1
      end
      last = @intervals.get(n - 1)
      # add a range from last.b to maxElement constrained to vocab
      if (last.attr_b < max_element)
        s = IntervalSet.of(last.attr_b + 1, max_element)
        a = s.and_(vocabulary_is)
        compl.add_all(a)
      end
      return compl
    end
    
    typesig { [IntSet] }
    # Compute this-other via this&~other.
    # Return a new set containing all elements in this but not in other.
    # other is assumed to be a subset of this;
    # anything that is in other but not in this will be ignored.
    def subtract(other)
      # assume the whole unicode range here for the complement
      # because it doesn't matter.  Anything beyond the max of this' set
      # will be ignored since we are doing this & ~other.  The intersection
      # will be empty.  The only problem would be when this' set max value
      # goes beyond MAX_CHAR_VALUE, but hopefully the constant MAX_CHAR_VALUE
      # will prevent this.
      return self.and_((other).complement(COMPLETE_SET))
    end
    
    typesig { [IntSet] }
    # return a new set containing all elements in this but not in other.
    # Intervals may have to be broken up when ranges in this overlap
    # with ranges in other.  other is assumed to be a subset of this;
    # anything that is in other but not in this will be ignored.
    # 
    # Keep around, but 10-20-2005, I decided to make complement work w/o
    # subtract and so then subtract can simply be a&~b
    # 
    # public IntSet subtract(IntSet other) {
    # if ( other==null || !(other instanceof IntervalSet) ) {
    # return null; // nothing in common with null set
    # }
    # 
    # IntervalSet diff = new IntervalSet();
    # 
    # // iterate down both interval lists
    # ListIterator thisIter = this.intervals.listIterator();
    # ListIterator otherIter = ((IntervalSet)other).intervals.listIterator();
    # Interval mine=null;
    # Interval theirs=null;
    # if ( thisIter.hasNext() ) {
    # mine = (Interval)thisIter.next();
    # }
    # if ( otherIter.hasNext() ) {
    # theirs = (Interval)otherIter.next();
    # }
    # while ( mine!=null ) {
    # //System.out.println("mine="+mine+", theirs="+theirs);
    # // CASE 1: nothing in theirs removes a chunk from mine
    # if ( theirs==null || mine.disjoint(theirs) ) {
    # // SUBCASE 1a: finished traversing theirs; keep adding mine now
    # if ( theirs==null ) {
    # // add everything in mine to difference since theirs done
    # diff.add(mine);
    # mine = null;
    # if ( thisIter.hasNext() ) {
    # mine = (Interval)thisIter.next();
    # }
    # }
    # else {
    # // SUBCASE 1b: mine is completely to the left of theirs
    # // so we can add to difference; move mine, but not theirs
    # if ( mine.startsBeforeDisjoint(theirs) ) {
    # diff.add(mine);
    # mine = null;
    # if ( thisIter.hasNext() ) {
    # mine = (Interval)thisIter.next();
    # }
    # }
    # // SUBCASE 1c: theirs is completely to the left of mine
    # else {
    # // keep looking in theirs
    # theirs = null;
    # if ( otherIter.hasNext() ) {
    # theirs = (Interval)otherIter.next();
    # }
    # }
    # }
    # }
    # else {
    # // CASE 2: theirs breaks mine into two chunks
    # if ( mine.properlyContains(theirs) ) {
    # // must add two intervals: stuff to left and stuff to right
    # diff.add(mine.a, theirs.a-1);
    # // don't actually add stuff to right yet as next 'theirs'
    # // might overlap with it
    # // The stuff to the right might overlap with next "theirs".
    # // so it is considered next
    # Interval right = new Interval(theirs.b+1, mine.b);
    # mine = right;
    # // move theirs forward
    # theirs = null;
    # if ( otherIter.hasNext() ) {
    # theirs = (Interval)otherIter.next();
    # }
    # }
    # 
    # // CASE 3: theirs covers mine; nothing to add to diff
    # else if ( theirs.properlyContains(mine) ) {
    # // nothing to add, theirs forces removal totally of mine
    # // just move mine looking for an overlapping interval
    # mine = null;
    # if ( thisIter.hasNext() ) {
    # mine = (Interval)thisIter.next();
    # }
    # }
    # 
    # // CASE 4: non proper overlap
    # else {
    # // overlap, but not properly contained
    # diff.add(mine.differenceNotProperlyContained(theirs));
    # // update iterators
    # boolean moveTheirs = true;
    # if ( mine.startsBeforeNonDisjoint(theirs) ||
    # theirs.b > mine.b )
    # {
    # // uh oh, right of theirs extends past right of mine
    # // therefore could overlap with next of mine so don't
    # // move theirs iterator yet
    # moveTheirs = false;
    # }
    # // always move mine
    # mine = null;
    # if ( thisIter.hasNext() ) {
    # mine = (Interval)thisIter.next();
    # }
    # if ( moveTheirs ) {
    # theirs = null;
    # if ( otherIter.hasNext() ) {
    # theirs = (Interval)otherIter.next();
    # }
    # }
    # }
    # }
    # }
    # return diff;
    # }
    # 
    # TODO: implement this!
    def or_(a)
      o = IntervalSet.new
      o.add_all(self)
      o.add_all(a)
      # throw new NoSuchMethodError();
      return o
    end
    
    typesig { [IntSet] }
    # Return a new set with the intersection of this set with other.  Because
    # the intervals are sorted, we can use an iterator for each list and
    # just walk them together.  This is roughly O(min(n,m)) for interval
    # list lengths n and m.
    def and_(other)
      if ((other).nil?)
        # || !(other instanceof IntervalSet) ) {
        return nil # nothing in common with null set
      end
      my_intervals = @intervals
      their_intervals = (other).attr_intervals
      intersection = nil
      my_size = my_intervals.size
      their_size = their_intervals.size
      i = 0
      j = 0
      # iterate down both interval lists looking for nondisjoint intervals
      while (i < my_size && j < their_size)
        mine = my_intervals.get(i)
        theirs = their_intervals.get(j)
        # System.out.println("mine="+mine+" and theirs="+theirs);
        if (mine.starts_before_disjoint(theirs))
          # move this iterator looking for interval that might overlap
          i += 1
        else
          if (theirs.starts_before_disjoint(mine))
            # move other iterator looking for interval that might overlap
            j += 1
          else
            if (mine.properly_contains(theirs))
              # overlap, add intersection, get next theirs
              if ((intersection).nil?)
                intersection = IntervalSet.new
              end
              intersection.add(mine.intersection(theirs))
              j += 1
            else
              if (theirs.properly_contains(mine))
                # overlap, add intersection, get next mine
                if ((intersection).nil?)
                  intersection = IntervalSet.new
                end
                intersection.add(mine.intersection(theirs))
                i += 1
              else
                if (!mine.disjoint(theirs))
                  # overlap, add intersection
                  if ((intersection).nil?)
                    intersection = IntervalSet.new
                  end
                  intersection.add(mine.intersection(theirs))
                  # Move the iterator of lower range [a..b], but not
                  # the upper range as it may contain elements that will collide
                  # with the next iterator. So, if mine=[0..115] and
                  # theirs=[115..200], then intersection is 115 and move mine
                  # but not theirs as theirs may collide with the next range
                  # in thisIter.
                  # move both iterators to next ranges
                  if (mine.starts_after_non_disjoint(theirs))
                    j += 1
                  else
                    if (theirs.starts_after_non_disjoint(mine))
                      i += 1
                    end
                  end
                end
              end
            end
          end
        end
      end
      if ((intersection).nil?)
        return IntervalSet.new
      end
      return intersection
    end
    
    typesig { [::Java::Int] }
    # Is el in any range of this set?
    def member(el)
      n = @intervals.size
      i = 0
      while i < n
        i_ = @intervals.get(i)
        a = i_.attr_a
        b = i_.attr_b
        if (el < a)
          break # list is sorted and el is before this interval; not here
        end
        if (el >= a && el <= b)
          return true # found in this interval
        end
        i += 1
      end
      return false
      # for (ListIterator iter = intervals.listIterator(); iter.hasNext();) {
      # Interval I = (Interval) iter.next();
      # if ( el<I.a ) {
      # break; // list is sorted and el is before this interval; not here
      # }
      # if ( el>=I.a && el<=I.b ) {
      # return true; // found in this interval
      # }
      # }
      # return false;
    end
    
    typesig { [] }
    # return true if this set has no members
    def is_nil
      return (@intervals).nil? || (@intervals.size).equal?(0)
    end
    
    typesig { [] }
    # If this set is a single integer, return it otherwise Label.INVALID
    def get_single_element
      if (!(@intervals).nil? && (@intervals.size).equal?(1))
        i = @intervals.get(0)
        if ((i.attr_a).equal?(i.attr_b))
          return i.attr_a
        end
      end
      return Label::INVALID
    end
    
    typesig { [] }
    def get_max_element
      if (is_nil)
        return Label::INVALID
      end
      last = @intervals.get(@intervals.size - 1)
      return last.attr_b
    end
    
    typesig { [] }
    # Return minimum element >= 0
    def get_min_element
      if (is_nil)
        return Label::INVALID
      end
      n = @intervals.size
      i = 0
      while i < n
        i_ = @intervals.get(i)
        a = i_.attr_a
        b = i_.attr_b
        v = a
        while v <= b
          if (v >= 0)
            return v
          end
          v += 1
        end
        i += 1
      end
      return Label::INVALID
    end
    
    typesig { [] }
    # Return a list of Interval objects.
    def get_intervals
      return @intervals
    end
    
    typesig { [Object] }
    # Are two IntervalSets equal?  Because all intervals are sorted
    # and disjoint, equals is a simple linear walk over both lists
    # to make sure they are the same.  Interval.equals() is used
    # by the List.equals() method to check the ranges.
    def ==(obj)
      if ((obj).nil? || !(obj.is_a?(IntervalSet)))
        return false
      end
      other = obj
      return (@intervals == other.attr_intervals)
    end
    
    typesig { [] }
    def to_s
      return to_s(nil)
    end
    
    typesig { [Grammar] }
    def to_s(g)
      buf = StringBuffer.new
      if ((@intervals).nil? || (@intervals.size).equal?(0))
        return "{}"
      end
      if (@intervals.size > 1)
        buf.append("{")
      end
      iter = @intervals.iterator
      while (iter.has_next)
        i = iter.next_
        a = i.attr_a
        b = i.attr_b
        if ((a).equal?(b))
          if (!(g).nil?)
            buf.append(g.get_token_display_name(a))
          else
            buf.append(a)
          end
        else
          if (!(g).nil?)
            buf.append(RJava.cast_to_string(g.get_token_display_name(a)) + ".." + RJava.cast_to_string(g.get_token_display_name(b)))
          else
            buf.append(RJava.cast_to_string(a) + ".." + RJava.cast_to_string(b))
          end
        end
        if (iter.has_next)
          buf.append(", ")
        end
      end
      if (@intervals.size > 1)
        buf.append("}")
      end
      return buf.to_s
    end
    
    typesig { [] }
    def size
      n = 0
      num_intervals = @intervals.size
      if ((num_intervals).equal?(1))
        first_interval = @intervals.get(0)
        return first_interval.attr_b - first_interval.attr_a + 1
      end
      i = 0
      while i < num_intervals
        i_ = @intervals.get(i)
        n += (i_.attr_b - i_.attr_a + 1)
        i += 1
      end
      return n
    end
    
    typesig { [] }
    def to_list
      values = ArrayList.new
      n = @intervals.size
      i = 0
      while i < n
        i_ = @intervals.get(i)
        a = i_.attr_a
        b = i_.attr_b
        v = a
        while v <= b
          values.add(Utils.integer(v))
          v += 1
        end
        i += 1
      end
      return values
    end
    
    typesig { [::Java::Int] }
    # Get the ith element of ordered set.  Used only by RandomPhrase so
    # don't bother to implement if you're not doing that for a new
    # ANTLR code gen target.
    def get(i)
      n = @intervals.size
      index = 0
      j = 0
      while j < n
        i_ = @intervals.get(j)
        a = i_.attr_a
        b = i_.attr_b
        v = a
        while v <= b
          if ((index).equal?(i))
            return v
          end
          index += 1
          v += 1
        end
        j += 1
      end
      return -1
    end
    
    typesig { [] }
    def to_array
      values = Array.typed(::Java::Int).new(size) { 0 }
      n = @intervals.size
      j = 0
      i = 0
      while i < n
        i_ = @intervals.get(i)
        a = i_.attr_a
        b = i_.attr_b
        v = a
        while v <= b
          values[j] = v
          j += 1
          v += 1
        end
        i += 1
      end
      return values
    end
    
    typesig { [] }
    def to_runtime_bit_set
      s = Org::Antlr::Runtime::BitSet.new(get_max_element + 1)
      n = @intervals.size
      i = 0
      while i < n
        i_ = @intervals.get(i)
        a = i_.attr_a
        b = i_.attr_b
        v = a
        while v <= b
          s.add(v)
          v += 1
        end
        i += 1
      end
      return s
    end
    
    typesig { [::Java::Int] }
    def remove(el)
      raise NoSuchMethodError.new("IntervalSet.remove() unimplemented")
    end
    
    private
    alias_method :initialize__interval_set, :initialize
  end
  
end
