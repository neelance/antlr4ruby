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
module Org::Antlr::Runtime::Misc
  module StatsImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Misc
      include ::Java::Io
    }
  end
  
  # Stats routines needed by profiler etc...
  # 
  # // note that these routines return 0.0 if no values exist in the X[]
  # // which is not "correct", but it is useful so I don't generate NaN
  # // in my output
  class Stats 
    include_class_members StatsImports
    
    class_module.module_eval {
      const_set_lazy(:ANTLRWORKS_DIR) { "antlrworks" }
      const_attr_reader  :ANTLRWORKS_DIR
      
      typesig { [Array.typed(::Java::Int)] }
      # Compute the sample (unbiased estimator) standard deviation following:
      # 
      # Computing Deviations: Standard Accuracy
      # Tony F. Chan and John Gregg Lewis
      # Stanford University
      # Communications of ACM September 1979 of Volume 22 the ACM Number 9
      # 
      # The "two-pass" method from the paper; supposed to have better
      # numerical properties than the textbook summation/sqrt.  To me
      # this looks like the textbook method, but I ain't no numerical
      # methods guy.
      def stddev(x)
        m = x.attr_length
        if (m <= 1)
          return 0
        end
        xbar = avg(x)
        s2 = 0.0
        i = 0
        while i < m
          s2 += (x[i] - xbar) * (x[i] - xbar)
          i += 1
        end
        s2 = s2 / (m - 1)
        return Math.sqrt(s2)
      end
      
      typesig { [Array.typed(::Java::Int)] }
      # Compute the sample mean
      def avg(x)
        xbar = 0.0
        m = x.attr_length
        if ((m).equal?(0))
          return 0
        end
        i = 0
        while i < m
          xbar += x[i]
          i += 1
        end
        if (xbar >= 0.0)
          return xbar / m
        end
        return 0.0
      end
      
      typesig { [Array.typed(::Java::Int)] }
      def min(x)
        min = JavaInteger::MAX_VALUE
        m = x.attr_length
        if ((m).equal?(0))
          return 0
        end
        i = 0
        while i < m
          if (x[i] < min)
            min = x[i]
          end
          i += 1
        end
        return min
      end
      
      typesig { [Array.typed(::Java::Int)] }
      def max(x)
        max = JavaInteger::MIN_VALUE
        m = x.attr_length
        if ((m).equal?(0))
          return 0
        end
        i = 0
        while i < m
          if (x[i] > max)
            max = x[i]
          end
          i += 1
        end
        return max
      end
      
      typesig { [Array.typed(::Java::Int)] }
      def sum(x)
        s = 0
        m = x.attr_length
        if ((m).equal?(0))
          return 0
        end
        i = 0
        while i < m
          s += x[i]
          i += 1
        end
        return s
      end
      
      typesig { [String, String] }
      def write_report(filename, data)
        absolute_filename = get_absolute_file_name(filename)
        f = JavaFile.new(absolute_filename)
        parent = f.get_parent_file
        parent.mkdirs # ensure parent dir exists
        # write file
        fos = FileOutputStream.new(f, true) # append
        bos = BufferedOutputStream.new(fos)
        ps = PrintStream.new(bos)
        ps.println(data)
        ps.close
        bos.close
        fos.close
      end
      
      typesig { [String] }
      def get_absolute_file_name(filename)
        return (System.get_property("user.home") + JavaFile.attr_separator).to_s + ANTLRWORKS_DIR + (JavaFile.attr_separator).to_s + filename
      end
    }
    
    typesig { [] }
    def initialize
    end
    
    private
    alias_method :initialize__stats, :initialize
  end
  
end
