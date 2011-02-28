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
module Org::Antlr::Runtime::Misc
  module IntArrayImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Misc
    }
  end
  
  # A dynamic array that uses int not Integer objects. In principle this
  # is more efficient in time, but certainly in space.
  # 
  # This is simple enough that you can access the data array directly,
  # but make sure that you append elements only with add() so that you
  # get dynamic sizing.  Make sure to call ensureCapacity() when you are
  # manually adding new elements.
  # 
  # Doesn't impl List because it doesn't return objects and I mean this
  # really as just an array not a List per se.  Manipulate the elements
  # at will.  This has stack methods too.
  # 
  # When runtime can be 1.5, I'll make this generic.
  class IntArray 
    include_class_members IntArrayImports
    
    class_module.module_eval {
      const_set_lazy(:INITIAL_SIZE) { 10 }
      const_attr_reader  :INITIAL_SIZE
    }
    
    attr_accessor :data
    alias_method :attr_data, :data
    undef_method :data
    alias_method :attr_data=, :data=
    undef_method :data=
    
    attr_accessor :p
    alias_method :attr_p, :p
    undef_method :p
    alias_method :attr_p=, :p=
    undef_method :p=
    
    typesig { [::Java::Int] }
    def add(v)
      ensure_capacity(@p + 1)
      @data[(@p += 1)] = v
    end
    
    typesig { [::Java::Int] }
    def push(v)
      add(v)
    end
    
    typesig { [] }
    def pop
      v = @data[@p]
      @p -= 1
      return v
    end
    
    typesig { [] }
    # This only tracks elements added via push/add.
    def size
      return @p
    end
    
    typesig { [] }
    def clear
      @p = -1
    end
    
    typesig { [::Java::Int] }
    def ensure_capacity(index)
      if ((@data).nil?)
        @data = Array.typed(::Java::Int).new(INITIAL_SIZE) { 0 }
      else
        if ((index + 1) >= @data.attr_length)
          new_size = @data.attr_length * 2
          if (index > new_size)
            new_size = index + 1
          end
          new_data = Array.typed(::Java::Int).new(new_size) { 0 }
          System.arraycopy(@data, 0, new_data, 0, @data.attr_length)
          @data = new_data
        end
      end
    end
    
    typesig { [] }
    def initialize
      @data = nil
      @p = -1
    end
    
    private
    alias_method :initialize__int_array, :initialize
  end
  
end
