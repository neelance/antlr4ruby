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
  module IntArrayListImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
      include_const ::Java::Util, :AbstractList
    }
  end
  
  # An ArrayList based upon int members.  Not quite a real implementation of a
  # modifiable list as I don't do, for example, add(index,element).
  # TODO: unused?
  class IntArrayList < IntArrayListImports.const_get :AbstractList
    include_class_members IntArrayListImports
    include Cloneable
    
    class_module.module_eval {
      const_set_lazy(:DEFAULT_CAPACITY) { 10 }
      const_attr_reader  :DEFAULT_CAPACITY
    }
    
    attr_accessor :n
    alias_method :attr_n, :n
    undef_method :n
    alias_method :attr_n=, :n=
    undef_method :n=
    
    attr_accessor :elements
    alias_method :attr_elements, :elements
    undef_method :elements
    alias_method :attr_elements=, :elements=
    undef_method :elements=
    
    typesig { [] }
    def initialize
      initialize__int_array_list(DEFAULT_CAPACITY)
    end
    
    typesig { [::Java::Int] }
    def initialize(initial_capacity)
      @n = 0
      @elements = nil
      super()
      @n = 0
      @elements = nil
      @elements = Array.typed(::Java::Int).new(initial_capacity) { 0 }
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    # Set the ith element.  Like ArrayList, this does NOT affect size.
    def set(i, new_value)
      if (i >= @n)
        set_size(i) # unlike definition of set in ArrayList, set size
      end
      v = @elements[i]
      @elements[i] = new_value
      return v
    end
    
    typesig { [::Java::Int] }
    def add(o)
      if (@n >= @elements.attr_length)
        grow
      end
      @elements[@n] = o
      @n += 1
      return true
    end
    
    typesig { [::Java::Int] }
    def set_size(new_size)
      if (new_size >= @elements.attr_length)
        ensure_capacity(new_size)
      end
      @n = new_size
    end
    
    typesig { [] }
    def grow
      ensure_capacity((@elements.attr_length * 3) / 2 + 1)
    end
    
    typesig { [::Java::Int] }
    def contains(v)
      i = 0
      while i < @n
        element = @elements[i]
        if ((element).equal?(v))
          return true
        end
        i += 1
      end
      return false
    end
    
    typesig { [::Java::Int] }
    def ensure_capacity(new_capacity)
      old_capacity = @elements.attr_length
      if (@n >= old_capacity)
        old_data = @elements
        @elements = Array.typed(::Java::Int).new(new_capacity) { 0 }
        System.arraycopy(old_data, 0, @elements, 0, @n)
      end
    end
    
    typesig { [::Java::Int] }
    def get(i)
      return Utils.integer(element(i))
    end
    
    typesig { [::Java::Int] }
    def element(i)
      return @elements[i]
    end
    
    typesig { [] }
    def elements
      a = Array.typed(::Java::Int).new(@n) { 0 }
      System.arraycopy(@elements, 0, a, 0, @n)
      return a
    end
    
    typesig { [] }
    def size
      return @n
    end
    
    typesig { [] }
    def capacity
      return @elements.attr_length
    end
    
    typesig { [Object] }
    def equals(o)
      if ((o).nil?)
        return false
      end
      other = o
      if (!(self.size).equal?(other.size))
        return false
      end
      i = 0
      while i < @n
        if (!(@elements[i]).equal?(other.attr_elements[i]))
          return false
        end
        i += 1
      end
      return true
    end
    
    typesig { [] }
    def clone
      a = super
      a.attr_n = @n
      System.arraycopy(@elements, 0, a.attr_elements, 0, @elements.attr_length)
      return a
    end
    
    typesig { [] }
    def to_s
      buf = StringBuffer.new
      i = 0
      while i < @n
        if (i > 0)
          buf.append(", ")
        end
        buf.append(@elements[i])
        i += 1
      end
      return buf.to_s
    end
    
    private
    alias_method :initialize__int_array_list, :initialize
  end
  
end
