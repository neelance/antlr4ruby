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
  module IntSetImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Java::Util, :JavaList
    }
  end
  
  # A generic set of ints that has an efficient implementation, BitSet,
  # which is a compressed bitset and is useful for ints that
  # are small, for example less than 500 or so, and w/o many ranges.  For
  # ranges with large values like unicode char sets, this is not very efficient.
  # Consider using IntervalSet.  Not all methods in IntervalSet are implemented.
  # 
  # @see org.antlr.misc.BitSet
  # @see org.antlr.misc.IntervalSet
  module IntSet
    include_class_members IntSetImports
    
    typesig { [::Java::Int] }
    # Add an element to the set
    def add(el)
      raise NotImplementedError
    end
    
    typesig { [IntSet] }
    # Add all elements from incoming set to this set.  Can limit
    # to set of its own type.
    def add_all(set)
      raise NotImplementedError
    end
    
    typesig { [IntSet] }
    # Return the intersection of this set with the argument, creating
    # a new set.
    def and(a)
      raise NotImplementedError
    end
    
    typesig { [IntSet] }
    def complement(elements)
      raise NotImplementedError
    end
    
    typesig { [IntSet] }
    def or(a)
      raise NotImplementedError
    end
    
    typesig { [IntSet] }
    def subtract(a)
      raise NotImplementedError
    end
    
    typesig { [] }
    # Return the size of this set (not the underlying implementation's
    # allocated memory size, for example).
    def size
      raise NotImplementedError
    end
    
    typesig { [] }
    def is_nil
      raise NotImplementedError
    end
    
    typesig { [Object] }
    def equals(obj)
      raise NotImplementedError
    end
    
    typesig { [] }
    def get_single_element
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def member(el)
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    # remove this element from this set
    def remove(el)
      raise NotImplementedError
    end
    
    typesig { [] }
    def to_list
      raise NotImplementedError
    end
    
    typesig { [] }
    def to_s
      raise NotImplementedError
    end
    
    typesig { [Grammar] }
    def to_s(g)
      raise NotImplementedError
    end
  end
  
end
