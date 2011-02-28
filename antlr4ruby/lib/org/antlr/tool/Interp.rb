require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2008 Terence Parr
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
module Org::Antlr::Tool
  module InterpImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Runtime, :ANTLRFileStream
      include_const ::Org::Antlr::Runtime, :CharStream
      include_const ::Org::Antlr::Runtime, :CommonTokenStream
      include_const ::Org::Antlr::Runtime::Tree, :ParseTree
      include_const ::Org::Antlr, :Tool
      include_const ::Java::Util, :StringTokenizer
      include_const ::Java::Util, :JavaList
      include_const ::Java::Io, :FileReader
      include_const ::Java::Io, :BufferedReader
    }
  end
  
  # Interpret any ANTLR grammar:
  # 
  # java Interp file.g tokens-to-ignore start-rule input-file
  # 
  # java Interp C.g 'WS COMMENT' program t.c
  # 
  # where the WS and COMMENT are the names of tokens you want to have
  # the parser ignore.
  class Interp 
    include_class_members InterpImports
    
    class_module.module_eval {
      typesig { [Array.typed(String)] }
      # pass me a java file to parse
      def main(args)
        if (!(args.attr_length).equal?(4))
          System.err.println("java Interp file.g tokens-to-ignore start-rule input-file")
          return
        end
        grammar_file_name = args[0]
        ignore_tokens = args[1]
        start_rule = args[2]
        input_file_name = args[3]
        # TODO: using wrong constructor now
        tool = Tool.new
        composite = CompositeGrammar.new
        parser = Grammar.new(tool, grammar_file_name, composite)
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
        lexer.set_tool(tool)
        if (!(lexer_grammar_text).nil?)
          lexer.set_grammar_content(lexer_grammar_text)
        else
          System.err.println("no lexer grammar found in " + grammar_file_name)
        end
        lexer.attr_composite.create_nfas
        input = ANTLRFileStream.new(input_file_name)
        lex_engine = Interpreter.new(lexer, input)
        tokens = CommonTokenStream.new(lex_engine)
        tk = StringTokenizer.new(ignore_tokens, " ")
        while (tk.has_more_tokens)
          token_name = tk.next_token
          tokens.set_token_type_channel(lexer.get_token_type(token_name), 99)
        end
        if ((parser.get_rule(start_rule)).nil?)
          System.err.println("Rule " + start_rule + " does not exist in " + grammar_file_name)
          return
        end
        parse_engine = Interpreter.new(parser, tokens)
        t = parse_engine.parse(start_rule)
        System.out.println(t.to_string_tree)
      end
    }
    
    typesig { [] }
    def initialize
    end
    
    private
    alias_method :initialize__interp, :initialize
  end
  
end

Org::Antlr::Tool::Interp.main($*) if $0 == __FILE__
