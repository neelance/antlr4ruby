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
module Org::Antlr::Misc
  module OrderedHashSetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :HashSet
      include_const ::Java::Util, :JavaList
    }
  end
  
  # A HashMap that remembers the order that the elements were added.
  # You can alter the ith element with set(i,value) too :)  Unique list.
  # I need the replace/set-element-i functionality so I'm subclassing
  # OrderedHashSet.
  class OrderedHashSet < OrderedHashSetImports.const_get :HashSet
    include_class_members OrderedHashSetImports
    
    # Track the elements as they are added to the set
    attr_accessor :elements
    alias_method :attr_elements, :elements
    undef_method :elements
    alias_method :attr_elements=, :elements=
    undef_method :elements=
    
    typesig { [::Java::Int] }
    def get(i)
      return @elements.get(i)
    end
    
    typesig { [::Java::Int, Object] }
    # Replace an existing value with a new value; updates the element
    # list and the hash table, but not the key as that has not changed.
    def set(i, value)
      old_element = @elements.get(i)
      @elements.set(i, value) # update list
      HashSet.instance_method(:remove).bind(self).call(old_element) # now update the set: remove/add
      HashSet.instance_method(:add).bind(self).call(value)
      return old_element
    end
    
    typesig { [Object] }
    # Add a value to list; keep in hashtable for consistency also;
    # Key is object itself.  Good for say asking if a certain string is in
    # a list of strings.
    def add(value)
      result = super(value)
      if (result)
        # only track if new element not in set
        @elements.add(value)
      end
      return result
    end
    
    typesig { [Object] }
    def remove(o)
      raise UnsupportedOperationException.new
      # elements.remove(o);
      # return super.remove(o);
    end
    
    typesig { [] }
    def clear
      @elements.clear
      super
    end
    
    typesig { [] }
    # Return the List holding list of table elements.  Note that you are
    # NOT getting a copy so don't write to the list.
    def elements
      return @elements
    end
    
    typesig { [] }
    def size
      # if ( elements.size()!=super.size() ) {
      #     ErrorManager.internalError("OrderedHashSet: elements and set size differs; "+
      #                                elements.size()+"!="+super.size());
      # }
      return @elements.size
    end
    
    typesig { [] }
    def to_s
      return @elements.to_s
    end
    
    typesig { [] }
    def initialize
      @elements = nil
      super()
      @elements = ArrayList.new
    end
    
    private
    alias_method :initialize__ordered_hash_set, :initialize
  end
  
end
