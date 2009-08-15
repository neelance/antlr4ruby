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
  module RandomPhraseImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Misc, :IntervalSet
      include_const ::Org::Antlr, :Tool
      include ::Java::Util
      include_const ::Java::Io, :FileReader
      include_const ::Java::Io, :BufferedReader
    }
  end
  
  # Generate a random phrase given a grammar.
  # Usage:
  # java org.antlr.tool.RandomPhrase grammarFile.g startRule [seed]
  # 
  # For example:
  # java org.antlr.tool.RandomPhrase simple.g program 342
  # 
  # The seed acts like a unique identifier so you can get the same random
  # phrase back during unit testing, for example.
  # 
  # If you do not specify a seed then the current time in milliseconds is used
  # guaranteeing that you'll never see that seed again.
  # 
  # NOTE: this does not work well for large grammars...it tends to recurse
  # too much and build really long strings.  I need throttle control; later.
  class RandomPhrase 
    include_class_members RandomPhraseImports
    
    class_module.module_eval {
      const_set_lazy(:Debug) { false }
      const_attr_reader  :Debug
      
      
      def random
        defined?(@@random) ? @@random : @@random= nil
      end
      alias_method :attr_random, :random
      
      def random=(value)
        @@random = value
      end
      alias_method :attr_random=, :random=
      
      typesig { [Grammar, JavaList, String] }
      # an experimental method to generate random phrases for a given
      # grammar given a start rule.  Return a list of token types.
      def random_phrase(g, token_types, start_rule)
        state = g.get_rule_start_state(start_rule)
        stop_state = g.get_rule_stop_state(start_rule)
        rule_invocation_stack = Stack.new
        while (true)
          if ((state).equal?(stop_state) && (rule_invocation_stack.size).equal?(0))
            break
          end
          if (Debug)
            System.out.println("state " + RJava.cast_to_string(state))
          end
          if ((state.get_number_of_transitions).equal?(0))
            if (Debug)
              System.out.println("dangling state: " + RJava.cast_to_string(state))
            end
            return
          end
          # end of rule node
          if (state.is_accept_state)
            invoking_state = rule_invocation_stack.pop
            if (Debug)
              System.out.println("pop invoking state " + RJava.cast_to_string(invoking_state))
            end
            # System.out.println("leave "+state.enclosingRule.name);
            invoking_transition = invoking_state.attr_transition[0]
            # move to node after state that invoked this rule
            state = invoking_transition.attr_follow_state
            next
          end
          if ((state.get_number_of_transitions).equal?(1))
            # no branching, just take this path
            t0 = state.attr_transition[0]
            if (t0.is_a?(RuleClosureTransition))
              rule_invocation_stack.push(state)
              if (Debug)
                System.out.println("push state " + RJava.cast_to_string(state))
              end
              # System.out.println("call "+((RuleClosureTransition)t0).rule.name);
              # System.out.println("stack depth="+ruleInvocationStack.size());
            else
              if (t0.attr_label.is_set || t0.attr_label.is_atom)
                token_types.add(get_token_type(t0.attr_label))
              end
            end
            state = t0.attr_target
            next
          end
          decision_number = state.get_decision_number
          if ((decision_number).equal?(0))
            System.out.println("weird: no decision number but a choice node")
            next
          end
          # decision point, pick ith alternative randomly
          n = g.get_number_of_alts_for_decision_nfa(state)
          random_alt = self.attr_random.next_int(n) + 1
          if (Debug)
            System.out.println("randomAlt=" + RJava.cast_to_string(random_alt))
          end
          alt_start_state = g.get_nfastate_for_alt_of_decision(state, random_alt)
          t = alt_start_state.attr_transition[0]
          state = t.attr_target
        end
      end
      
      typesig { [Label] }
      def get_token_type(label)
        if (label.is_set)
          # pick random element of set
          type_set = label.get_set
          random_index = self.attr_random.next_int(type_set.size)
          return type_set.get(random_index)
        else
          return Utils.integer(label.get_atom)
        end
        # System.out.println(t0.label.toString(g));
      end
      
      typesig { [Array.typed(String)] }
      # Used to generate random strings
      def main(args)
        if (args.attr_length < 2)
          System.err.println("usage: java org.antlr.tool.RandomPhrase grammarfile startrule")
          return
        end
        grammar_file_name = args[0]
        start_rule = args[1]
        seed = System.current_time_millis # use random seed unless spec.
        if ((args.attr_length).equal?(3))
          seed_str = args[2]
          seed = Long.parse_long(seed_str)
        end
        begin
          self.attr_random = Random.new(seed)
          composite = CompositeGrammar.new
          parser = Grammar.new(Tool.new, grammar_file_name, composite)
          composite.set_delegation_root(parser)
          fr = FileReader.new(grammar_file_name)
          br = BufferedReader.new(fr)
          parser.parse_and_build_ast(br)
          br.close
          parser.attr_composite.assign_token_types
          parser.attr_composite.define_grammar_symbols
          parser.attr_composite.create_nfas
          left_recursive_rules = parser.check_all_rules_for_left_recursion
          if (left_recursive_rules.size > 0)
            return
          end
          if ((parser.get_rule(start_rule)).nil?)
            System.out.println("undefined start rule " + start_rule)
            return
          end
          lexer_grammar_text = parser.get_lexer_grammar
          lexer = Grammar.new
          lexer.import_token_vocabulary(parser)
          lexer.attr_file_name = grammar_file_name
          if (!(lexer_grammar_text).nil?)
            lexer.set_grammar_content(lexer_grammar_text)
          else
            System.err.println("no lexer grammar found in " + grammar_file_name)
          end
          lexer.build_nfa
          left_recursive_rules = lexer.check_all_rules_for_left_recursion
          if (left_recursive_rules.size > 0)
            return
          end
          # System.out.println("lexer:\n"+lexer);
          token_types = ArrayList.new(100)
          random_phrase(parser, token_types, start_rule)
          System.out.println("token types=" + RJava.cast_to_string(token_types))
          i = 0
          while i < token_types.size
            ttype_i = token_types.get(i)
            ttype = ttype_i.int_value
            ttype_display_name = parser.get_token_display_name(ttype)
            if (Character.is_upper_case(ttype_display_name.char_at(0)))
              chars_in_token = ArrayList.new(10)
              random_phrase(lexer, chars_in_token, ttype_display_name)
              System.out.print(" ")
              j = 0
              while j < chars_in_token.size
                c_i = chars_in_token.get(j)
                System.out.print(RJava.cast_to_char(c_i.int_value))
                j += 1
              end
            else
              # it's a literal
              literal = ttype_display_name.substring(1, ttype_display_name.length - 1)
              System.out.print(" " + literal)
            end
            i += 1
          end
          System.out.println
        rescue JavaError => er
          System.err.println("Error walking " + grammar_file_name + " rule " + start_rule + " seed " + RJava.cast_to_string(seed))
          er.print_stack_trace(System.err)
        rescue JavaException => e
          System.err.println("Exception walking " + grammar_file_name + " rule " + start_rule + " seed " + RJava.cast_to_string(seed))
          e.print_stack_trace(System.err)
        end
      end
    }
    
    typesig { [] }
    def initialize
    end
    
    private
    alias_method :initialize__random_phrase, :initialize
  end
  
  RandomPhrase.main($*) if $0 == __FILE__
end
