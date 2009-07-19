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
  module BarrierImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Misc
    }
  end
  
  # A very simple barrier wait.  Once a thread has requested a
  # wait on the barrier with waitForRelease, it cannot fool the
  # barrier into releasing by "hitting" the barrier multiple times--
  # the thread is blocked on the wait().
  class Barrier 
    include_class_members BarrierImports
    
    attr_accessor :threshold
    alias_method :attr_threshold, :threshold
    undef_method :threshold
    alias_method :attr_threshold=, :threshold=
    undef_method :threshold=
    
    attr_accessor :count
    alias_method :attr_count, :count
    undef_method :count
    alias_method :attr_count=, :count=
    undef_method :count=
    
    typesig { [::Java::Int] }
    def initialize(t)
      @threshold = 0
      @count = 0
      @threshold = t
    end
    
    typesig { [] }
    def wait_for_release
      synchronized(self) do
        ((@count += 1) - 1)
        # The final thread to reach barrier resets barrier and
        # releases all threads
        if ((@count).equal?(@threshold))
          # notify blocked threads that threshold has been reached
          action # perform the requested operation
          notify_all
        else
          while (@count < @threshold)
            wait
          end
        end
      end
    end
    
    typesig { [] }
    # What to do when everyone reaches barrier
    def action
    end
    
    private
    alias_method :initialize__barrier, :initialize
  end
  
end
