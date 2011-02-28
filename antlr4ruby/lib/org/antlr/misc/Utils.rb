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
  module UtilsImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
    }
  end
  
  class Utils 
    include_class_members UtilsImports
    
    class_module.module_eval {
      const_set_lazy(:INTEGER_POOL_MAX_VALUE) { 1000 }
      const_attr_reader  :INTEGER_POOL_MAX_VALUE
      
      
      def ints
        defined?(@@ints) ? @@ints : @@ints= Array.typed(JavaInteger).new(INTEGER_POOL_MAX_VALUE + 1) { nil }
      end
      alias_method :attr_ints, :ints
      
      def ints=(value)
        @@ints = value
      end
      alias_method :attr_ints=, :ints=
      
      typesig { [::Java::Int] }
      # Integer objects are immutable so share all Integers with the
      # same value up to some max size.  Use an array as a perfect hash.
      # Return shared object for 0..INTEGER_POOL_MAX_VALUE or a new
      # Integer object with x in it.
      def integer(x)
        if (x < 0 || x > INTEGER_POOL_MAX_VALUE)
          return x
        end
        if ((self.attr_ints[x]).nil?)
          self.attr_ints[x] = x
        end
        return self.attr_ints[x]
      end
      
      typesig { [String, String, String] }
      # Given a source string, src,
      # 		a string to replace, replacee,
      # 		and a string to replace with, replacer,
      # 		return a new string w/ the replacing done.
      # 		You can use replacer==null to remove replacee from the string.
      # 
      # 		This should be faster than Java's String.replaceAll as that one
      # 		uses regex (I only want to play with strings anyway).
      def replace(src, replacee, replacer)
        result = StringBuffer.new(src.length + 50)
        start_index = 0
        end_index = src.index_of(replacee)
        while (!(end_index).equal?(-1))
          result.append(src.substring(start_index, end_index))
          if (!(replacer).nil?)
            result.append(replacer)
          end
          start_index = end_index + replacee.length
          end_index = src.index_of(replacee, start_index)
        end
        result.append(src.substring(start_index, src.length))
        return result.to_s
      end
    }
    
    typesig { [] }
    def initialize
    end
    
    private
    alias_method :initialize__utils, :initialize
  end
  
end
