require "rjava"

# 
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
module Org::Antlr::Tool
  module LeftRecursionCyclesMessageImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include ::Org::Antlr::Analysis
      include_const ::Antlr, :Token
      include ::Java::Util
    }
  end
  
  # Similar to LeftRecursionMessage except this is used for announcing
  # cycles found by walking rules without decisions; the other msg is
  # invoked when a decision DFA construction finds a problem in closure.
  class LeftRecursionCyclesMessage < LeftRecursionCyclesMessageImports.const_get :Message
    include_class_members LeftRecursionCyclesMessageImports
    
    attr_accessor :cycles
    alias_method :attr_cycles, :cycles
    undef_method :cycles
    alias_method :attr_cycles=, :cycles=
    undef_method :cycles=
    
    typesig { [Collection] }
    def initialize(cycles)
      @cycles = nil
      super(ErrorManager::MSG_LEFT_RECURSION_CYCLES)
      @cycles = cycles
    end
    
    typesig { [] }
    def to_s
      st = get_message_template
      st.set_attribute("listOfCycles", @cycles)
      return super(st)
    end
    
    private
    alias_method :initialize__left_recursion_cycles_message, :initialize
  end
  
end
