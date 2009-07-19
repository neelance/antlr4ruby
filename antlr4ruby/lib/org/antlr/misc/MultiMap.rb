require "rjava"

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
module Org::Antlr::Misc
  module MultiMapImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
      include_const ::Java::Util, :HashMap
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :ArrayList
    }
  end
  
  # A hash table that maps a key to a list of elements not just a single.
  class MultiMap < MultiMapImports.const_get :HashMap
    include_class_members MultiMapImports
    
    typesig { [Object, Object] }
    def map(key, value)
      elements_for_key = get(key)
      if ((elements_for_key).nil?)
        elements_for_key = ArrayList.new
        HashMap.instance_method(:put).bind(self).call(key, elements_for_key)
      end
      elements_for_key.add(value)
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__multi_map, :initialize
  end
  
end
