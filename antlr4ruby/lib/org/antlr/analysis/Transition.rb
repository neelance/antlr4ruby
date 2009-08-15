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
  module TransitionImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
    }
  end
  
  # A generic transition between any two state machine states.  It defines
  # some special labels that indicate things like epsilon transitions and
  # that the label is actually a set of labels or a semantic predicate.
  # This is a one way link.  It emanates from a state (usually via a list of
  # transitions) and has a label/target pair.  I have abstracted the notion
  # of a Label to handle the various kinds of things it can be.
  class Transition 
    include_class_members TransitionImports
    include JavaComparable
    
    # What label must be consumed to transition to target
    attr_accessor :label
    alias_method :attr_label, :label
    undef_method :label
    alias_method :attr_label=, :label=
    undef_method :label=
    
    # The target of this transition
    attr_accessor :target
    alias_method :attr_target, :target
    undef_method :target
    alias_method :attr_target=, :target=
    undef_method :target=
    
    typesig { [Label, State] }
    def initialize(label, target)
      @label = nil
      @target = nil
      @label = label
      @target = target
    end
    
    typesig { [::Java::Int, State] }
    def initialize(label, target)
      @label = nil
      @target = nil
      @label = Label.new(label)
      @target = target
    end
    
    typesig { [] }
    def is_epsilon
      return @label.is_epsilon
    end
    
    typesig { [] }
    def is_action
      return @label.is_action
    end
    
    typesig { [] }
    def is_semantic_predicate
      return @label.is_semantic_predicate
    end
    
    typesig { [] }
    def hash_code
      return @label.hash_code + @target.attr_state_number
    end
    
    typesig { [Object] }
    def ==(o)
      other = o
      return (@label == other.attr_label) && (@target == other.attr_target)
    end
    
    typesig { [Object] }
    def compare_to(o)
      other = o
      return (@label <=> other.attr_label)
    end
    
    typesig { [] }
    def to_s
      return RJava.cast_to_string(@label) + "->" + RJava.cast_to_string(@target.attr_state_number)
    end
    
    private
    alias_method :initialize__transition, :initialize
  end
  
end
