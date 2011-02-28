require "rjava"
 # $ANTLR 2.7.7 (2006-01-29): "define.g" -> "DefineGrammarItemsWalker.java"$
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
  module DefineGrammarItemsWalkerTokenTypesImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Java::Util
      include ::Org::Antlr::Misc
    }
  end
  
  module DefineGrammarItemsWalkerTokenTypes
    include_class_members DefineGrammarItemsWalkerTokenTypesImports
    
    class_module.module_eval {
      const_set_lazy(:EOF) { 1 }
      const_attr_reader  :EOF
      
      const_set_lazy(:NULL_TREE_LOOKAHEAD) { 3 }
      const_attr_reader  :NULL_TREE_LOOKAHEAD
      
      const_set_lazy(:OPTIONS) { 4 }
      const_attr_reader  :OPTIONS
      
      const_set_lazy(:TOKENS) { 5 }
      const_attr_reader  :TOKENS
      
      const_set_lazy(:PARSER) { 6 }
      const_attr_reader  :PARSER
      
      const_set_lazy(:LEXER) { 7 }
      const_attr_reader  :LEXER
      
      const_set_lazy(:RULE) { 8 }
      const_attr_reader  :RULE
      
      const_set_lazy(:BLOCK) { 9 }
      const_attr_reader  :BLOCK
      
      const_set_lazy(:OPTIONAL) { 10 }
      const_attr_reader  :OPTIONAL
      
      const_set_lazy(:CLOSURE) { 11 }
      const_attr_reader  :CLOSURE
      
      const_set_lazy(:POSITIVE_CLOSURE) { 12 }
      const_attr_reader  :POSITIVE_CLOSURE
      
      const_set_lazy(:SYNPRED) { 13 }
      const_attr_reader  :SYNPRED
      
      const_set_lazy(:RANGE) { 14 }
      const_attr_reader  :RANGE
      
      const_set_lazy(:CHAR_RANGE) { 15 }
      const_attr_reader  :CHAR_RANGE
      
      const_set_lazy(:EPSILON) { 16 }
      const_attr_reader  :EPSILON
      
      const_set_lazy(:ALT) { 17 }
      const_attr_reader  :ALT
      
      const_set_lazy(:EOR) { 18 }
      const_attr_reader  :EOR
      
      const_set_lazy(:EOB) { 19 }
      const_attr_reader  :EOB
      
      const_set_lazy(:EOA) { 20 }
      const_attr_reader  :EOA
      
      const_set_lazy(:ID) { 21 }
      const_attr_reader  :ID
      
      const_set_lazy(:ARG) { 22 }
      const_attr_reader  :ARG
      
      const_set_lazy(:ARGLIST) { 23 }
      const_attr_reader  :ARGLIST
      
      const_set_lazy(:RET) { 24 }
      const_attr_reader  :RET
      
      const_set_lazy(:LEXER_GRAMMAR) { 25 }
      const_attr_reader  :LEXER_GRAMMAR
      
      const_set_lazy(:PARSER_GRAMMAR) { 26 }
      const_attr_reader  :PARSER_GRAMMAR
      
      const_set_lazy(:TREE_GRAMMAR) { 27 }
      const_attr_reader  :TREE_GRAMMAR
      
      const_set_lazy(:COMBINED_GRAMMAR) { 28 }
      const_attr_reader  :COMBINED_GRAMMAR
      
      const_set_lazy(:INITACTION) { 29 }
      const_attr_reader  :INITACTION
      
      const_set_lazy(:FORCED_ACTION) { 30 }
      const_attr_reader  :FORCED_ACTION
      
      const_set_lazy(:LABEL) { 31 }
      const_attr_reader  :LABEL
      
      const_set_lazy(:TEMPLATE) { 32 }
      const_attr_reader  :TEMPLATE
      
      const_set_lazy(:SCOPE) { 33 }
      const_attr_reader  :SCOPE
      
      const_set_lazy(:IMPORT) { 34 }
      const_attr_reader  :IMPORT
      
      const_set_lazy(:GATED_SEMPRED) { 35 }
      const_attr_reader  :GATED_SEMPRED
      
      const_set_lazy(:SYN_SEMPRED) { 36 }
      const_attr_reader  :SYN_SEMPRED
      
      const_set_lazy(:BACKTRACK_SEMPRED) { 37 }
      const_attr_reader  :BACKTRACK_SEMPRED
      
      const_set_lazy(:FRAGMENT) { 38 }
      const_attr_reader  :FRAGMENT
      
      const_set_lazy(:DOT) { 39 }
      const_attr_reader  :DOT
      
      const_set_lazy(:ACTION) { 40 }
      const_attr_reader  :ACTION
      
      const_set_lazy(:DOC_COMMENT) { 41 }
      const_attr_reader  :DOC_COMMENT
      
      const_set_lazy(:SEMI) { 42 }
      const_attr_reader  :SEMI
      
      const_set_lazy(:LITERAL_lexer) { 43 }
      const_attr_reader  :LITERAL_lexer
      
      const_set_lazy(:LITERAL_tree) { 44 }
      const_attr_reader  :LITERAL_tree
      
      const_set_lazy(:LITERAL_grammar) { 45 }
      const_attr_reader  :LITERAL_grammar
      
      const_set_lazy(:AMPERSAND) { 46 }
      const_attr_reader  :AMPERSAND
      
      const_set_lazy(:COLON) { 47 }
      const_attr_reader  :COLON
      
      const_set_lazy(:RCURLY) { 48 }
      const_attr_reader  :RCURLY
      
      const_set_lazy(:ASSIGN) { 49 }
      const_attr_reader  :ASSIGN
      
      const_set_lazy(:STRING_LITERAL) { 50 }
      const_attr_reader  :STRING_LITERAL
      
      const_set_lazy(:CHAR_LITERAL) { 51 }
      const_attr_reader  :CHAR_LITERAL
      
      const_set_lazy(:INT) { 52 }
      const_attr_reader  :INT
      
      const_set_lazy(:STAR) { 53 }
      const_attr_reader  :STAR
      
      const_set_lazy(:COMMA) { 54 }
      const_attr_reader  :COMMA
      
      const_set_lazy(:TOKEN_REF) { 55 }
      const_attr_reader  :TOKEN_REF
      
      const_set_lazy(:LITERAL_protected) { 56 }
      const_attr_reader  :LITERAL_protected
      
      const_set_lazy(:LITERAL_public) { 57 }
      const_attr_reader  :LITERAL_public
      
      const_set_lazy(:LITERAL_private) { 58 }
      const_attr_reader  :LITERAL_private
      
      const_set_lazy(:BANG) { 59 }
      const_attr_reader  :BANG
      
      const_set_lazy(:ARG_ACTION) { 60 }
      const_attr_reader  :ARG_ACTION
      
      const_set_lazy(:LITERAL_returns) { 61 }
      const_attr_reader  :LITERAL_returns
      
      const_set_lazy(:LITERAL_throws) { 62 }
      const_attr_reader  :LITERAL_throws
      
      const_set_lazy(:LPAREN) { 63 }
      const_attr_reader  :LPAREN
      
      const_set_lazy(:OR) { 64 }
      const_attr_reader  :OR
      
      const_set_lazy(:RPAREN) { 65 }
      const_attr_reader  :RPAREN
      
      const_set_lazy(:LITERAL_catch) { 66 }
      const_attr_reader  :LITERAL_catch
      
      const_set_lazy(:LITERAL_finally) { 67 }
      const_attr_reader  :LITERAL_finally
      
      const_set_lazy(:PLUS_ASSIGN) { 68 }
      const_attr_reader  :PLUS_ASSIGN
      
      const_set_lazy(:SEMPRED) { 69 }
      const_attr_reader  :SEMPRED
      
      const_set_lazy(:IMPLIES) { 70 }
      const_attr_reader  :IMPLIES
      
      const_set_lazy(:ROOT) { 71 }
      const_attr_reader  :ROOT
      
      const_set_lazy(:WILDCARD) { 72 }
      const_attr_reader  :WILDCARD
      
      const_set_lazy(:RULE_REF) { 73 }
      const_attr_reader  :RULE_REF
      
      const_set_lazy(:NOT) { 74 }
      const_attr_reader  :NOT
      
      const_set_lazy(:TREE_BEGIN) { 75 }
      const_attr_reader  :TREE_BEGIN
      
      const_set_lazy(:QUESTION) { 76 }
      const_attr_reader  :QUESTION
      
      const_set_lazy(:PLUS) { 77 }
      const_attr_reader  :PLUS
      
      const_set_lazy(:OPEN_ELEMENT_OPTION) { 78 }
      const_attr_reader  :OPEN_ELEMENT_OPTION
      
      const_set_lazy(:CLOSE_ELEMENT_OPTION) { 79 }
      const_attr_reader  :CLOSE_ELEMENT_OPTION
      
      const_set_lazy(:REWRITE) { 80 }
      const_attr_reader  :REWRITE
      
      const_set_lazy(:ETC) { 81 }
      const_attr_reader  :ETC
      
      const_set_lazy(:DOLLAR) { 82 }
      const_attr_reader  :DOLLAR
      
      const_set_lazy(:DOUBLE_QUOTE_STRING_LITERAL) { 83 }
      const_attr_reader  :DOUBLE_QUOTE_STRING_LITERAL
      
      const_set_lazy(:DOUBLE_ANGLE_STRING_LITERAL) { 84 }
      const_attr_reader  :DOUBLE_ANGLE_STRING_LITERAL
      
      const_set_lazy(:WS) { 85 }
      const_attr_reader  :WS
      
      const_set_lazy(:COMMENT) { 86 }
      const_attr_reader  :COMMENT
      
      const_set_lazy(:SL_COMMENT) { 87 }
      const_attr_reader  :SL_COMMENT
      
      const_set_lazy(:ML_COMMENT) { 88 }
      const_attr_reader  :ML_COMMENT
      
      const_set_lazy(:STRAY_BRACKET) { 89 }
      const_attr_reader  :STRAY_BRACKET
      
      const_set_lazy(:ESC) { 90 }
      const_attr_reader  :ESC
      
      const_set_lazy(:DIGIT) { 91 }
      const_attr_reader  :DIGIT
      
      const_set_lazy(:XDIGIT) { 92 }
      const_attr_reader  :XDIGIT
      
      const_set_lazy(:NESTED_ARG_ACTION) { 93 }
      const_attr_reader  :NESTED_ARG_ACTION
      
      const_set_lazy(:NESTED_ACTION) { 94 }
      const_attr_reader  :NESTED_ACTION
      
      const_set_lazy(:ACTION_CHAR_LITERAL) { 95 }
      const_attr_reader  :ACTION_CHAR_LITERAL
      
      const_set_lazy(:ACTION_STRING_LITERAL) { 96 }
      const_attr_reader  :ACTION_STRING_LITERAL
      
      const_set_lazy(:ACTION_ESC) { 97 }
      const_attr_reader  :ACTION_ESC
      
      const_set_lazy(:WS_LOOP) { 98 }
      const_attr_reader  :WS_LOOP
      
      const_set_lazy(:INTERNAL_RULE_REF) { 99 }
      const_attr_reader  :INTERNAL_RULE_REF
      
      const_set_lazy(:WS_OPT) { 100 }
      const_attr_reader  :WS_OPT
      
      const_set_lazy(:SRC) { 101 }
      const_attr_reader  :SRC
    }
  end
  
end
