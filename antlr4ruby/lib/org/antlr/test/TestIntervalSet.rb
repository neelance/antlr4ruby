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
module Org::Antlr::Test
  module TestIntervalSetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :JavaList
    }
  end
  
  class TestIntervalSet < TestIntervalSetImports.const_get :BaseTest
    include_class_members TestIntervalSetImports
    
    typesig { [] }
    # Public default constructor used by TestRig
    def initialize
      super()
    end
    
    typesig { [] }
    def test_single_element
      s = IntervalSet.of(99)
      expecting = "99"
      assert_equals(s.to_s, expecting)
    end
    
    typesig { [] }
    def test_isolated_elements
      s = IntervalSet.new
      s.add(1)
      s.add(Character.new(?z.ord))
      s.add(Character.new(0xFFF0))
      expecting = "{1, 122, 65520}"
      assert_equals(s.to_s, expecting)
    end
    
    typesig { [] }
    def test_mixed_ranges_and_elements
      s = IntervalSet.new
      s.add(1)
      s.add(Character.new(?a.ord), Character.new(?z.ord))
      s.add(Character.new(?0.ord), Character.new(?9.ord))
      expecting = "{1, 48..57, 97..122}"
      assert_equals(s.to_s, expecting)
    end
    
    typesig { [] }
    def test_simple_and
      s = IntervalSet.of(10, 20)
      s2 = IntervalSet.of(13, 15)
      expecting = "13..15"
      result = (s.and_(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_range_and_isolated_element
      s = IntervalSet.of(Character.new(?a.ord), Character.new(?z.ord))
      s2 = IntervalSet.of(Character.new(?d.ord))
      expecting = "100"
      result = (s.and_(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_empty_intersection
      s = IntervalSet.of(Character.new(?a.ord), Character.new(?z.ord))
      s2 = IntervalSet.of(Character.new(?0.ord), Character.new(?9.ord))
      expecting = "{}"
      result = (s.and_(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_empty_intersection_single_elements
      s = IntervalSet.of(Character.new(?a.ord))
      s2 = IntervalSet.of(Character.new(?d.ord))
      expecting = "{}"
      result = (s.and_(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_not_single_element
      vocabulary = IntervalSet.of(1, 1000)
      vocabulary.add(2000, 3000)
      s = IntervalSet.of(50, 50)
      expecting = "{1..49, 51..1000, 2000..3000}"
      result = (s.complement(vocabulary)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_not_set
      vocabulary = IntervalSet.of(1, 1000)
      s = IntervalSet.of(50, 60)
      s.add(5)
      s.add(250, 300)
      expecting = "{1..4, 6..49, 61..249, 301..1000}"
      result = (s.complement(vocabulary)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_not_equal_set
      vocabulary = IntervalSet.of(1, 1000)
      s = IntervalSet.of(1, 1000)
      expecting = "{}"
      result = (s.complement(vocabulary)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_not_set_edge_element
      vocabulary = IntervalSet.of(1, 2)
      s = IntervalSet.of(1)
      expecting = "2"
      result = (s.complement(vocabulary)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_not_set_fragmented_vocabulary
      vocabulary = IntervalSet.of(1, 255)
      vocabulary.add(1000, 2000)
      vocabulary.add(9999)
      s = IntervalSet.of(50, 60)
      s.add(3)
      s.add(250, 300)
      s.add(10000) # this is outside range of vocab and should be ignored
      expecting = "{1..2, 4..49, 61..249, 1000..2000, 9999}"
      result = (s.complement(vocabulary)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_subtract_of_completely_contained_range
      s = IntervalSet.of(10, 20)
      s2 = IntervalSet.of(12, 15)
      expecting = "{10..11, 16..20}"
      result = (s.subtract(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_subtract_of_overlapping_range_from_left
      s = IntervalSet.of(10, 20)
      s2 = IntervalSet.of(5, 11)
      expecting = "12..20"
      result = (s.subtract(s2)).to_s
      assert_equals(result, expecting)
      s3 = IntervalSet.of(5, 10)
      expecting = "11..20"
      result = RJava.cast_to_string((s.subtract(s3)).to_s)
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_subtract_of_overlapping_range_from_right
      s = IntervalSet.of(10, 20)
      s2 = IntervalSet.of(15, 25)
      expecting = "10..14"
      result = (s.subtract(s2)).to_s
      assert_equals(result, expecting)
      s3 = IntervalSet.of(20, 25)
      expecting = "10..19"
      result = RJava.cast_to_string((s.subtract(s3)).to_s)
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_subtract_of_completely_covered_range
      s = IntervalSet.of(10, 20)
      s2 = IntervalSet.of(1, 25)
      expecting = "{}"
      result = (s.subtract(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_subtract_of_range_spanning_multiple_ranges
      s = IntervalSet.of(10, 20)
      s.add(30, 40)
      s.add(50, 60) # s has 3 ranges now: 10..20, 30..40, 50..60
      s2 = IntervalSet.of(5, 55) # covers one and touches 2nd range
      expecting = "56..60"
      result = (s.subtract(s2)).to_s
      assert_equals(result, expecting)
      s3 = IntervalSet.of(15, 55) # touches both
      expecting = "{10..14, 56..60}"
      result = RJava.cast_to_string((s.subtract(s3)).to_s)
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    # The following was broken:
    # 	 	{0..113, 115..65534}-{0..115, 117..65534}=116..65534
    def test_subtract_of_wacky_range
      s = IntervalSet.of(0, 113)
      s.add(115, 200)
      s2 = IntervalSet.of(0, 115)
      s2.add(117, 200)
      expecting = "116"
      result = (s.subtract(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_simple_equals
      s = IntervalSet.of(10, 20)
      s2 = IntervalSet.of(10, 20)
      expecting = Boolean.new(true)
      result = Boolean.new((s == s2))
      assert_equals(result, expecting)
      s3 = IntervalSet.of(15, 55)
      expecting = Boolean.new(false)
      result = Boolean.new((s == s3))
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_equals
      s = IntervalSet.of(10, 20)
      s.add(2)
      s.add(499, 501)
      s2 = IntervalSet.of(10, 20)
      s2.add(2)
      s2.add(499, 501)
      expecting = Boolean.new(true)
      result = Boolean.new((s == s2))
      assert_equals(result, expecting)
      s3 = IntervalSet.of(10, 20)
      s3.add(2)
      expecting = Boolean.new(false)
      result = Boolean.new((s == s3))
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_single_element_minus_disjoint_set
      s = IntervalSet.of(15, 15)
      s2 = IntervalSet.of(1, 5)
      s2.add(10, 20)
      expecting = "{}" # 15 - {1..5, 10..20} = {}
      result = s.subtract(s2).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_membership
      s = IntervalSet.of(15, 15)
      s.add(50, 60)
      assert_true(!s.member(0))
      assert_true(!s.member(20))
      assert_true(!s.member(100))
      assert_true(s.member(15))
      assert_true(s.member(55))
      assert_true(s.member(50))
      assert_true(s.member(60))
    end
    
    typesig { [] }
    # {2,15,18} & 10..20
    def test_intersection_with_two_contained_elements
      s = IntervalSet.of(10, 20)
      s2 = IntervalSet.of(2, 2)
      s2.add(15)
      s2.add(18)
      expecting = "{15, 18}"
      result = (s.and_(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_intersection_with_two_contained_elements_reversed
      s = IntervalSet.of(10, 20)
      s2 = IntervalSet.of(2, 2)
      s2.add(15)
      s2.add(18)
      expecting = "{15, 18}"
      result = (s2.and_(s)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_complement
      s = IntervalSet.of(100, 100)
      s.add(101, 101)
      s2 = IntervalSet.of(100, 102)
      expecting = "102"
      result = (s.complement(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_complement2
      s = IntervalSet.of(100, 101)
      s2 = IntervalSet.of(100, 102)
      expecting = "102"
      result = (s.complement(s2)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_complement3
      s = IntervalSet.of(1, 96)
      s.add(99, 65534)
      expecting = "97..98"
      result = (s.complement(1, Label::MAX_CHAR_VALUE)).to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_merge_of_ranges_and_single_values
      # {0..41, 42, 43..65534}
      s = IntervalSet.of(0, 41)
      s.add(42)
      s.add(43, 65534)
      expecting = "0..65534"
      result = s.to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_merge_of_ranges_and_single_values_reverse
      s = IntervalSet.of(43, 65534)
      s.add(42)
      s.add(0, 41)
      expecting = "0..65534"
      result = s.to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_merge_where_addition_merges_two_existing_intervals
      # 42, 10, {0..9, 11..41, 43..65534}
      s = IntervalSet.of(42)
      s.add(10)
      s.add(0, 9)
      s.add(43, 65534)
      s.add(11, 41)
      expecting = "0..65534"
      result = s.to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_merge_with_double_overlap
      s = IntervalSet.of(1, 10)
      s.add(20, 30)
      s.add(5, 25) # overlaps two!
      expecting = "1..30"
      result = s.to_s
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_size
      s = IntervalSet.of(20, 30)
      s.add(50, 55)
      s.add(5, 19)
      expecting = "32"
      result = String.value_of(s.size)
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    def test_to_list
      s = IntervalSet.of(20, 25)
      s.add(50, 55)
      s.add(5, 5)
      expecting = "[5, 20, 21, 22, 23, 24, 25, 50, 51, 52, 53, 54, 55]"
      foo = ArrayList.new
      result = String.value_of(s.to_list)
      assert_equals(result, expecting)
    end
    
    typesig { [] }
    # The following was broken:
    # 	    {'\u0000'..'s', 'u'..'\uFFFE'} & {'\u0000'..'q', 's'..'\uFFFE'}=
    # 	    {'\u0000'..'q', 's'}!!!! broken...
    # 	 	'q' is 113 ascii
    # 	 	'u' is 117
    def test_not_rintersection_not_t
      s = IntervalSet.of(0, Character.new(?s.ord))
      s.add(Character.new(?u.ord), 200)
      s2 = IntervalSet.of(0, Character.new(?q.ord))
      s2.add(Character.new(?s.ord), 200)
      expecting = "{0..113, 115, 117..200}"
      result = (s.and_(s2)).to_s
      assert_equals(result, expecting)
    end
    
    private
    alias_method :initialize__test_interval_set, :initialize
  end
  
end
