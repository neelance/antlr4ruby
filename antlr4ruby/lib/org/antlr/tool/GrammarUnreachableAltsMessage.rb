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
module Org::Antlr::Tool
  module GrammarUnreachableAltsMessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Analysis, :DecisionProbe
      include_const ::Org::Antlr::Analysis, :DFAState
      include_const ::Org::Antlr::Analysis, :NFAState
      include_const ::Org::Antlr::Analysis, :SemanticContext
      include_const ::Antlr, :Token
      include_const ::Java::Util, :Iterator
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :JavaSet
    }
  end
  
  # Reports a potential parsing issue with a decision; the decision is
  # nondeterministic in some way.
  class GrammarUnreachableAltsMessage < GrammarUnreachableAltsMessageImports.const_get :Message
    include_class_members GrammarUnreachableAltsMessageImports
    
    attr_accessor :probe
    alias_method :attr_probe, :probe
    undef_method :probe
    alias_method :attr_probe=, :probe=
    undef_method :probe=
    
    attr_accessor :alts
    alias_method :attr_alts, :alts
    undef_method :alts
    alias_method :attr_alts=, :alts=
    undef_method :alts=
    
    typesig { [DecisionProbe, JavaList] }
    def initialize(probe, alts)
      @probe = nil
      @alts = nil
      super(ErrorManager::MSG_UNREACHABLE_ALTS)
      @probe = probe
      @alts = alts
      # flip msg ID if alts are actually token refs in Tokens rule
      if (probe.attr_dfa.is_tokens_rule_decision)
        set_message_id(ErrorManager::MSG_UNREACHABLE_TOKENS)
      end
    end
    
    typesig { [] }
    def to_s
      decision_astnode = @probe.attr_dfa.get_decision_astnode
      self.attr_line = decision_astnode.get_line
      self.attr_column = decision_astnode.get_column
      file_name = @probe.attr_dfa.attr_nfa.attr_grammar.get_file_name
      if (!(file_name).nil?)
        self.attr_file = file_name
      end
      st = get_message_template
      if (@probe.attr_dfa.is_tokens_rule_decision)
        # alts are token rules, convert to the names instead of numbers
        i = 0
        while i < @alts.size
          alt_i = @alts.get(i)
          token_name = @probe.get_token_name_for_tokens_rule_alt(alt_i.int_value)
          # reset the line/col to the token definition
          rule_start = @probe.attr_dfa.attr_nfa.attr_grammar.get_rule_start_state(token_name)
          self.attr_line = rule_start.attr_associated_astnode.get_line
          self.attr_column = rule_start.attr_associated_astnode.get_column
          st.set_attribute("tokens", token_name)
          i += 1
        end
      else
        # regular alt numbers, show the alts
        st.set_attribute("alts", @alts)
      end
      return super(st)
    end
    
    private
    alias_method :initialize__grammar_unreachable_alts_message, :initialize
  end
  
end
