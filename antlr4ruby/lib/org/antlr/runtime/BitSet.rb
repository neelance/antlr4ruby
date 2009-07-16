require "rjava"

# 
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
module Org::Antlr::Runtime
  module BitSetImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include_const ::Java::Util, :JavaList
    }
  end
  
  # A stripped-down version of org.antlr.misc.BitSet that is just
  # good enough to handle runtime requirements such as FOLLOW sets
  # for automatic error recovery.
  class BitSet 
    include_class_members BitSetImports
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
    
    typesig { [JavaList] }
    # Construction from a list of integers
    def initialize(items)
      initialize__bit_set()
      i = 0
      while i < items.size
        v = items.get(i)
        add(v.int_value)
        ((i += 1) - 1)
      end
    end
    
    typesig { [::Java::Int] }
    # Construct a bitset given the size
    # @param nbits The size of the bitset in bits
    def initialize(nbits)
      @bits = nil
      @bits = Array.typed(::Java::Long).new(((nbits - 1) >> LOG_BITS) + 1) { 0 }
    end
    
    class_module.module_eval {
      typesig { [::Java::Int] }
      def of(el)
        s = BitSet.new(el + 1)
        s.add(el)
        return s
      end
      
      typesig { [::Java::Int, ::Java::Int] }
      def of(a, b)
        s = BitSet.new(Math.max(a, b) + 1)
        s.add(a)
        s.add(b)
        return s
      end
      
      typesig { [::Java::Int, ::Java::Int, ::Java::Int] }
      def of(a, b, c)
        s = BitSet.new
        s.add(a)
        s.add(b)
        s.add(c)
        return s
      end
      
      typesig { [::Java::Int, ::Java::Int, ::Java::Int, ::Java::Int] }
      def of(a, b, c, d)
        s = BitSet.new
        s.add(a)
        s.add(b)
        s.add(c)
        s.add(d)
        return s
      end
    }
    
    typesig { [BitSet] }
    # return this | a in a new set
    def or(a)
      if ((a).nil?)
        return self
      end
      s = self.clone
      s.or_in_place(a)
      return s
    end
    
    typesig { [::Java::Int] }
    # or this element into this set (grow as necessary to accommodate)
    def add(el)
      n = word_number(el)
      if (n >= @bits.attr_length)
        grow_to_include(el)
      end
      @bits[n] |= bit_mask(el)
    end
    
    typesig { [::Java::Int] }
    # 
    # Grows the set to a larger number of bits.
    # @param bit element that must fit in set
    def grow_to_include(bit)
      new_size = Math.max(@bits.attr_length << 1, num_words_to_hold(bit))
      newbits = Array.typed(::Java::Long).new(new_size) { 0 }
      System.arraycopy(@bits, 0, newbits, 0, @bits.attr_length)
      @bits = newbits
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
        ((i -= 1) + 1)
      end
    end
    
    typesig { [::Java::Int] }
    # 
    # Sets the size of a set.
    # @param nwords how many words the new set should be
    def set_size(nwords)
      newbits = Array.typed(::Java::Long).new(nwords) { 0 }
      n = Math.min(nwords, @bits.attr_length)
      System.arraycopy(@bits, 0, newbits, 0, n)
      @bits = newbits
    end
    
    class_module.module_eval {
      typesig { [::Java::Int] }
      def bit_mask(bit_number)
        bit_position = bit_number & MOD_MASK # bitNumber mod BITS
        return 1 << bit_position
      end
    }
    
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
              ((deg += 1) - 1)
            end
            ((bit -= 1) + 1)
          end
        end
        ((i -= 1) + 1)
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
        ((i += 1) - 1)
      end
      # make sure any extra bits are off
      if (@bits.attr_length > n)
        i_ = n + 1
        while i_ < @bits.attr_length
          if (!(@bits[i_]).equal?(0))
            return false
          end
          ((i_ += 1) - 1)
        end
      else
        if (other_set.attr_bits.attr_length > n)
          i__ = n + 1
          while i__ < other_set.attr_bits.attr_length
            if (!(other_set.attr_bits[i__]).equal?(0))
              return false
            end
            ((i__ += 1) - 1)
          end
        end
      end
      return true
    end
    
    typesig { [::Java::Int] }
    def member(el)
      if (el < 0)
        return false
      end
      n = word_number(el)
      if (n >= @bits.attr_length)
        return false
      end
      return !((@bits[n] & bit_mask(el))).equal?(0)
    end
    
    typesig { [::Java::Int] }
    # remove this element from this set
    def remove(el)
      n = word_number(el)
      if (n < @bits.attr_length)
        @bits[n] &= ~bit_mask(el)
      end
    end
    
    typesig { [] }
    def is_nil
      i = @bits.attr_length - 1
      while i >= 0
        if (!(@bits[i]).equal?(0))
          return false
        end
        ((i -= 1) + 1)
      end
      return true
    end
    
    typesig { [::Java::Int] }
    def num_words_to_hold(el)
      return (el >> LOG_BITS) + 1
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
    
    typesig { [] }
    # Is this contained within a?
    # 
    # public boolean subset(BitSet a) {
    # if (a == null || !(a instanceof BitSet)) return false;
    # return this.and(a).equals(this);
    # }
    def to_array
      elems = Array.typed(::Java::Int).new(size) { 0 }
      en = 0
      i = 0
      while i < (@bits.attr_length << LOG_BITS)
        if (member(i))
          elems[((en += 1) - 1)] = i
        end
        ((i += 1) - 1)
      end
      return elems
    end
    
    typesig { [] }
    def to_packed_array
      return @bits
    end
    
    class_module.module_eval {
      typesig { [::Java::Int] }
      def word_number(bit)
        return bit >> LOG_BITS # bit / BITS
      end
    }
    
    typesig { [] }
    def to_s
      return to_s(nil)
    end
    
    typesig { [Array.typed(String)] }
    def to_s(token_names)
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
          if (!(token_names).nil?)
            buf.append(token_names[i])
          else
            buf.append(i)
          end
          have_printed_an_element = true
        end
        ((i += 1) - 1)
      end
      buf.append(Character.new(?}.ord))
      return buf.to_s
    end
    
    private
    alias_method :initialize__bit_set, :initialize
  end
  
end
