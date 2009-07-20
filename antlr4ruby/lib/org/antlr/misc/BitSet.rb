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
  module BitSetImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Java::Util, :Collection
      include_const ::Java::Util, :Iterator
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :Map
    }
  end
  
  # A BitSet to replace java.util.BitSet.
  # 
  # Primary differences are that most set operators return new sets
  # as opposed to oring and anding "in place".  Further, a number of
  # operations were added.  I cannot contain a BitSet because there
  # is no way to access the internal bits (which I need for speed)
  # and, because it is final, I cannot subclass to add functionality.
  # Consider defining set degree.  Without access to the bits, I must
  # call a method n times to test the ith bit...ack!
  # 
  # Also seems like or() from util is wrong when size of incoming set is bigger
  # than this.bits.length.
  # 
  # @author Terence Parr
  class BitSet 
    include_class_members BitSetImports
    include IntSet
    include Cloneable
    
    class_module.module_eval {
      const_set_lazy(:BITS) { 64 }
      const_attr_reader  :BITS
      
      # number of bits / long
      const_set_lazy(:LOG_BITS) { 6 }
      const_attr_reader  :LOG_BITS
      
      # 2^6 == 64
      # We will often need to do a mod operator (i mod nbits).  Its
      # turns out that, for powers of two, this mod operation is
      # same as (i & (nbits-1)).  Since mod is slow, we use a
      # precomputed mod mask to do the mod instead.
      const_set_lazy(:MOD_MASK) { BITS - 1 }
      const_attr_reader  :MOD_MASK
    }
    
    # The actual data bits
    attr_accessor :bits
    alias_method :attr_bits, :bits
    undef_method :bits
    alias_method :attr_bits=, :bits=
    undef_method :bits=
    
    typesig { [] }
    # Construct a bitset of size one word (64 bits)
    def initialize
      initialize__bit_set(BITS)
    end
    
    typesig { [Array.typed(::Java::Long)] }
    # Construction from a static array of longs
    def initialize(bits_)
      @bits = nil
      @bits = bits_
    end
    
    typesig { [::Java::Int] }
    # Construct a bitset given the size
    # @param nbits The size of the bitset in bits
    def initialize(nbits)
      @bits = nil
      @bits = Array.typed(::Java::Long).new(((nbits - 1) >> LOG_BITS) + 1) { 0 }
    end
    
    typesig { [::Java::Int] }
    # or this element into this set (grow as necessary to accommodate)
    def add(el)
      # System.out.println("add("+el+")");
      n = word_number(el)
      # System.out.println("word number is "+n);
      # System.out.println("bits.length "+bits.length);
      if (n >= @bits.attr_length)
        grow_to_include(el)
      end
      @bits[n] |= bit_mask(el)
    end
    
    typesig { [IntSet] }
    def add_all(set)
      if (set.is_a?(BitSet))
        self.or_in_place(set)
      else
        if (set.is_a?(IntervalSet))
          other = set
          # walk set and add each interval
          iter = other.attr_intervals.iterator
          while iter.has_next
            i = iter.next
            self.or_in_place(BitSet.range(i.attr_a, i.attr_b))
          end
        else
          raise IllegalArgumentException.new("can't add " + (set.get_class.get_name).to_s + " to BitSet")
        end
      end
    end
    
    typesig { [Array.typed(::Java::Int)] }
    def add_all(elements)
      if ((elements).nil?)
        return
      end
      i = 0
      while i < elements.attr_length
        e = elements[i]
        add(e)
        i += 1
      end
    end
    
    typesig { [Iterable] }
    def add_all(elements)
      if ((elements).nil?)
        return
      end
      it = elements.iterator
      while (it.has_next)
        o = it.next
        if (!(o.is_a?(JavaInteger)))
          raise IllegalArgumentException.new
        end
        e_i = o
        add(e_i.int_value)
      end
      # int n = elements.size();
      # for (int i = 0; i < n; i++) {
      # Object o = elements.get(i);
      # if ( !(o instanceof Integer) ) {
      # throw new IllegalArgumentException();
      # }
      # Integer eI = (Integer)o;
      # add(eI.intValue());
      # }
    end
    
    typesig { [IntSet] }
    def and(a)
      s = self.clone
      s.and_in_place(a)
      return s
    end
    
    typesig { [BitSet] }
    def and_in_place(a)
      min_ = Math.min(@bits.attr_length, a.attr_bits.attr_length)
      i = min_ - 1
      while i >= 0
        @bits[i] &= a.attr_bits[i]
        i -= 1
      end
      # clear all bits in this not present in a (if this bigger than a).
      i_ = min_
      while i_ < @bits.attr_length
        @bits[i_] = 0
        i_ += 1
      end
    end
    
    class_module.module_eval {
      typesig { [::Java::Int] }
      def bit_mask(bit_number)
        bit_position = bit_number & MOD_MASK # bitNumber mod BITS
        return 1 << bit_position
      end
    }
    
    typesig { [] }
    def clear
      i = @bits.attr_length - 1
      while i >= 0
        @bits[i] = 0
        i -= 1
      end
    end
    
    typesig { [::Java::Int] }
    def clear(el)
      n = word_number(el)
      if (n >= @bits.attr_length)
        # grow as necessary to accommodate
        grow_to_include(el)
      end
      @bits[n] &= ~bit_mask(el)
    end
    
    typesig { [] }
    def clone
      s = nil
      begin
        s = super
        s.attr_bits = Array.typed(::Java::Long).new(@bits.attr_length) { 0 }
        System.arraycopy(@bits, 0, s.attr_bits, 0, @bits.attr_length)
      rescue CloneNotSupportedException => e
        raise InternalError.new
      end
      return s
    end
    
    typesig { [] }
    def size
      deg = 0
      i = @bits.attr_length - 1
      while i >= 0
        word = @bits[i]
        if (!(word).equal?(0))
          bit = BITS - 1
          while bit >= 0
            if (!((word & (1 << bit))).equal?(0))
              deg += 1
            end
            bit -= 1
          end
        end
        i -= 1
      end
      return deg
    end
    
    typesig { [Object] }
    def equals(other)
      if ((other).nil? || !(other.is_a?(BitSet)))
        return false
      end
      other_set = other
      n = Math.min(@bits.attr_length, other_set.attr_bits.attr_length)
      # for any bits in common, compare
      i = 0
      while i < n
        if (!(@bits[i]).equal?(other_set.attr_bits[i]))
          return false
        end
        i += 1
      end
      # make sure any extra bits are off
      if (@bits.attr_length > n)
        i_ = n + 1
        while i_ < @bits.attr_length
          if (!(@bits[i_]).equal?(0))
            return false
          end
          i_ += 1
        end
      else
        if (other_set.attr_bits.attr_length > n)
          i_ = n + 1
          while i_ < other_set.attr_bits.attr_length
            if (!(other_set.attr_bits[i_]).equal?(0))
              return false
            end
            i_ += 1
          end
        end
      end
      return true
    end
    
    typesig { [::Java::Int] }
    # Grows the set to a larger number of bits.
    # @param bit element that must fit in set
    def grow_to_include(bit)
      new_size = Math.max(@bits.attr_length << 1, num_words_to_hold(bit))
      newbits = Array.typed(::Java::Long).new(new_size) { 0 }
      System.arraycopy(@bits, 0, newbits, 0, @bits.attr_length)
      @bits = newbits
    end
    
    typesig { [::Java::Int] }
    def member(el)
      n = word_number(el)
      if (n >= @bits.attr_length)
        return false
      end
      return !((@bits[n] & bit_mask(el))).equal?(0)
    end
    
    typesig { [] }
    # Get the first element you find and return it.  Return Label.INVALID
    # otherwise.
    def get_single_element
      i = 0
      while i < (@bits.attr_length << LOG_BITS)
        if (member(i))
          return i
        end
        i += 1
      end
      return Label::INVALID
    end
    
    typesig { [] }
    def is_nil
      i = @bits.attr_length - 1
      while i >= 0
        if (!(@bits[i]).equal?(0))
          return false
        end
        i -= 1
      end
      return true
    end
    
    typesig { [] }
    def complement
      s = self.clone
      s.not_in_place
      return s
    end
    
    typesig { [IntSet] }
    def complement(set)
      if ((set).nil?)
        return self.complement
      end
      return set.subtract(self)
    end
    
    typesig { [] }
    def not_in_place
      i = @bits.attr_length - 1
      while i >= 0
        @bits[i] = ~@bits[i]
        i -= 1
      end
    end
    
    typesig { [::Java::Int] }
    # complement bits in the range 0..maxBit.
    def not_in_place(max_bit)
      not_in_place(0, max_bit)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # complement bits in the range minBit..maxBit.
    def not_in_place(min_bit, max_bit)
      # make sure that we have room for maxBit
      grow_to_include(max_bit)
      i = min_bit
      while i <= max_bit
        n = word_number(i)
        @bits[n] ^= bit_mask(i)
        i += 1
      end
    end
    
    typesig { [::Java::Int] }
    def num_words_to_hold(el)
      return (el >> LOG_BITS) + 1
    end
    
    class_module.module_eval {
      typesig { [::Java::Int] }
      def of(el)
        s = BitSet.new(el + 1)
        s.add(el)
        return s
      end
      
      typesig { [Collection] }
      def of(elements)
        s = BitSet.new
        iter = elements.iterator
        while (iter.has_next)
          el = iter.next
          s.add(el.int_value)
        end
        return s
      end
      
      typesig { [IntSet] }
      def of(set)
        if ((set).nil?)
          return nil
        end
        if (set.is_a?(BitSet))
          return set
        end
        if (set.is_a?(IntervalSet))
          s = BitSet.new
          s.add_all(set)
          return s
        end
        raise IllegalArgumentException.new("can't create BitSet from " + (set.get_class.get_name).to_s)
      end
      
      typesig { [Map] }
      def of(elements)
        return BitSet.of(elements.key_set)
      end
      
      typesig { [::Java::Int, ::Java::Int] }
      def range(a, b)
        s = BitSet.new(b + 1)
        i = a
        while i <= b
          n = word_number(i)
          s.attr_bits[n] |= bit_mask(i)
          i += 1
        end
        return s
      end
    }
    
    typesig { [IntSet] }
    # return this | a in a new set
    def or(a)
      if ((a).nil?)
        return self
      end
      s = self.clone
      s.or_in_place(a)
      return s
    end
    
    typesig { [BitSet] }
    def or_in_place(a)
      if ((a).nil?)
        return
      end
      # If this is smaller than a, grow this first
      if (a.attr_bits.attr_length > @bits.attr_length)
        set_size(a.attr_bits.attr_length)
      end
      min_ = Math.min(@bits.attr_length, a.attr_bits.attr_length)
      i = min_ - 1
      while i >= 0
        @bits[i] |= a.attr_bits[i]
        i -= 1
      end
    end
    
    typesig { [::Java::Int] }
    # remove this element from this set
    def remove(el)
      n = word_number(el)
      if (n >= @bits.attr_length)
        grow_to_include(el)
      end
      @bits[n] &= ~bit_mask(el)
    end
    
    typesig { [::Java::Int] }
    # Sets the size of a set.
    # @param nwords how many words the new set should be
    def set_size(nwords)
      newbits = Array.typed(::Java::Long).new(nwords) { 0 }
      n = Math.min(nwords, @bits.attr_length)
      System.arraycopy(@bits, 0, newbits, 0, n)
      @bits = newbits
    end
    
    typesig { [] }
    def num_bits
      return @bits.attr_length << LOG_BITS # num words * bits per word
    end
    
    typesig { [] }
    # return how much space is being used by the bits array not
    # how many actually have member bits on.
    def length_in_long_words
      return @bits.attr_length
    end
    
    typesig { [BitSet] }
    # Is this contained within a?
    def subset(a)
      if ((a).nil?)
        return false
      end
      return (self.and(a) == self)
    end
    
    typesig { [BitSet] }
    # Subtract the elements of 'a' from 'this' in-place.
    # Basically, just turn off all bits of 'this' that are in 'a'.
    def subtract_in_place(a)
      if ((a).nil?)
        return
      end
      # for all words of 'a', turn off corresponding bits of 'this'
      i = 0
      while i < @bits.attr_length && i < a.attr_bits.attr_length
        @bits[i] &= ~a.attr_bits[i]
        i += 1
      end
    end
    
    typesig { [IntSet] }
    def subtract(a)
      if ((a).nil? || !(a.is_a?(BitSet)))
        return nil
      end
      s = self.clone
      s.subtract_in_place(a)
      return s
    end
    
    typesig { [] }
    def to_list
      raise NoSuchMethodError.new("BitSet.toList() unimplemented")
    end
    
    typesig { [] }
    def to_array
      elems = Array.typed(::Java::Int).new(size) { 0 }
      en = 0
      i = 0
      while i < (@bits.attr_length << LOG_BITS)
        if (member(i))
          elems[((en += 1) - 1)] = i
        end
        i += 1
      end
      return elems
    end
    
    typesig { [] }
    def to_packed_array
      return @bits
    end
    
    typesig { [] }
    def to_s
      return to_s(nil)
    end
    
    typesig { [Grammar] }
    # Transform a bit set into a string by formatting each element as an integer
    # separator The string to put in between elements
    # @return A commma-separated list of values
    def to_s(g)
      buf = StringBuffer.new
      separator = ","
      have_printed_an_element = false
      buf.append(Character.new(?{.ord))
      i = 0
      while i < (@bits.attr_length << LOG_BITS)
        if (member(i))
          if (i > 0 && have_printed_an_element)
            buf.append(separator)
          end
          if (!(g).nil?)
            buf.append(g.get_token_display_name(i))
          else
            buf.append(i)
          end
          have_printed_an_element = true
        end
        i += 1
      end
      buf.append(Character.new(?}.ord))
      return buf.to_s
    end
    
    typesig { [String, JavaList] }
    # Create a string representation where instead of integer elements, the
    # ith element of vocabulary is displayed instead.  Vocabulary is a Vector
    # of Strings.
    # separator The string to put in between elements
    # @return A commma-separated list of character constants.
    def to_s(separator, vocabulary)
      if ((vocabulary).nil?)
        return to_s(nil)
      end
      str = ""
      i = 0
      while i < (@bits.attr_length << LOG_BITS)
        if (member(i))
          if (str.length > 0)
            str += separator
          end
          if (i >= vocabulary.size)
            str += "'" + (RJava.cast_to_char(i)).to_s + "'"
          else
            if ((vocabulary.get(i)).nil?)
              str += "'" + (RJava.cast_to_char(i)).to_s + "'"
            else
              str += (vocabulary.get(i)).to_s
            end
          end
        end
        i += 1
      end
      return str
    end
    
    typesig { [] }
    # Dump a comma-separated list of the words making up the bit set.
    # Split each 64 bit number into two more manageable 32 bit numbers.
    # This generates a comma-separated list of C++-like unsigned long constants.
    def to_string_of_half_words
      s = StringBuffer.new
      i = 0
      while i < @bits.attr_length
        if (!(i).equal?(0))
          s.append(", ")
        end
        tmp = @bits[i]
        tmp &= 0xffffffff
        s.append(tmp)
        s.append("UL")
        s.append(", ")
        tmp = @bits[i] >> 32
        tmp &= 0xffffffff
        s.append(tmp)
        s.append("UL")
        i += 1
      end
      return s.to_s
    end
    
    typesig { [] }
    # Dump a comma-separated list of the words making up the bit set.
    # This generates a comma-separated list of Java-like long int constants.
    def to_string_of_words
      s = StringBuffer.new
      i = 0
      while i < @bits.attr_length
        if (!(i).equal?(0))
          s.append(", ")
        end
        s.append(@bits[i])
        s.append("L")
        i += 1
      end
      return s.to_s
    end
    
    typesig { [] }
    def to_string_with_ranges
      return to_s
    end
    
    class_module.module_eval {
      typesig { [::Java::Int] }
      def word_number(bit)
        return bit >> LOG_BITS # bit / BITS
      end
    }
    
    private
    alias_method :initialize__bit_set, :initialize
  end
  
end
