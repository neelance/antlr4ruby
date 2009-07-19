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
module Org::Antlr::Analysis
  module LookaheadSetImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Org::Antlr::Misc, :IntSet
      include_const ::Org::Antlr::Tool, :Grammar
    }
  end
  
  # An LL(1) lookahead set; contains a set of token types and a "hasEOF"
  # condition when the set contains EOF.  Since EOF is -1 everywhere and -1
  # cannot be stored in my BitSet, I set a condition here.  There may be other
  # reasons in the future to abstract a LookaheadSet over a raw BitSet.
  class LookaheadSet 
    include_class_members LookaheadSetImports
    
    attr_accessor :token_type_set
    alias_method :attr_token_type_set, :token_type_set
    undef_method :token_type_set
    alias_method :attr_token_type_set=, :token_type_set=
    undef_method :token_type_set=
    
    typesig { [] }
    def initialize
      @token_type_set = nil
      @token_type_set = IntervalSet.new
    end
    
    typesig { [IntSet] }
    def initialize(s)
      initialize__lookahead_set()
      @token_type_set.add_all(s)
    end
    
    typesig { [::Java::Int] }
    def initialize(atom)
      @token_type_set = nil
      @token_type_set = IntervalSet.of(atom)
    end
    
    typesig { [LookaheadSet] }
    def initialize(other)
      initialize__lookahead_set()
      @token_type_set.add_all(other.attr_token_type_set)
    end
    
    typesig { [LookaheadSet] }
    def or_in_place(other)
      @token_type_set.add_all(other.attr_token_type_set)
    end
    
    typesig { [LookaheadSet] }
    def or(other)
      return LookaheadSet.new(@token_type_set.or(other.attr_token_type_set))
    end
    
    typesig { [LookaheadSet] }
    def subtract(other)
      return LookaheadSet.new(@token_type_set.subtract(other.attr_token_type_set))
    end
    
    typesig { [::Java::Int] }
    def member(a)
      return @token_type_set.member(a)
    end
    
    typesig { [LookaheadSet] }
    def intersection(s)
      i = @token_type_set.and(s.attr_token_type_set)
      intersection = LookaheadSet.new(i)
      return intersection
    end
    
    typesig { [] }
    def is_nil
      return @token_type_set.is_nil
    end
    
    typesig { [::Java::Int] }
    def remove(a)
      @token_type_set = @token_type_set.subtract(IntervalSet.of(a))
    end
    
    typesig { [] }
    def hash_code
      return @token_type_set.hash_code
    end
    
    typesig { [Object] }
    def equals(other)
      return (@token_type_set == (other).attr_token_type_set)
    end
    
    typesig { [Grammar] }
    def to_s(g)
      if ((@token_type_set).nil?)
        return ""
      end
      r = @token_type_set.to_s(g)
      return r
    end
    
    typesig { [] }
    def to_s
      return to_s(nil)
    end
    
    private
    alias_method :initialize__lookahead_set, :initialize
  end
  
end
