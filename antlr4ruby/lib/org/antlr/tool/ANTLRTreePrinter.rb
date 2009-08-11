require "rjava"
 # $ANTLR 2.7.7 (2006-01-29): "antlr.print.g" -> "ANTLRTreePrinter.java"$
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
  module ANTLRTreePrinterImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Java::Util
      include_const ::Antlr, :TreeParser
      include_const ::Antlr, :Token
      include_const ::Antlr::Collections, :AST
      include_const ::Antlr, :RecognitionException
      include_const ::Antlr, :ANTLRException
      include_const ::Antlr, :NoViableAltException
      include_const ::Antlr, :MismatchedTokenException
      include_const ::Antlr, :SemanticException
      include_const ::Antlr::Collections::Impl, :BitSet
      include_const ::Antlr, :ASTPair
      include_const ::Antlr::Collections::Impl, :ASTArray
    }
  end
  
  # Print out a grammar (no pretty printing).
  # 
  # Terence Parr
  # University of San Francisco
  # August 19, 2003
  class ANTLRTreePrinter < Antlr::TreeParser
    include_class_members ANTLRTreePrinterImports
    include ANTLRTreePrinterTokenTypes
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :show_actions
    alias_method :attr_show_actions, :show_actions
    undef_method :show_actions
    alias_method :attr_show_actions=, :show_actions=
    undef_method :show_actions=
    
    attr_accessor :buf
    alias_method :attr_buf, :buf
    undef_method :buf
    alias_method :attr_buf=, :buf=
    undef_method :buf=
    
    typesig { [String] }
    def out(s)
      @buf.append(s)
    end
    
    typesig { [RecognitionException] }
    def report_error(ex)
      token = nil
      if (ex.is_a?(MismatchedTokenException))
        token = (ex).attr_token
      else
        if (ex.is_a?(NoViableAltException))
          token = (ex).attr_token
        end
      end
      ErrorManager.syntax_error(ErrorManager::MSG_SYNTAX_ERROR, @grammar, token, "antlr.print: " + (ex.to_s).to_s, ex)
    end
    
    class_module.module_eval {
      typesig { [String] }
      # Normalize a grammar print out by removing all double spaces
      # and trailing/beginning stuff.  FOr example, convert
      # 
      # ( A  |  B  |  C )*
      # 
      # to
      # 
      # ( A | B | C )*
      def normalize(g)
        st = StringTokenizer.new(g, " ", false)
        buf = StringBuffer.new
        while (st.has_more_tokens)
          w = st.next_token
          buf.append(w)
          buf.append(" ")
        end
        return buf.to_s.trim
      end
    }
    
    typesig { [] }
    def initialize
      @grammar = nil
      @show_actions = false
      @buf = nil
      super()
      @buf = StringBuffer.new(300)
      self.attr_token_names = _tokenNames
    end
    
    typesig { [AST, Grammar, ::Java::Boolean] }
    # Call this to figure out how to print
    def to_s(_t, g, show_actions)
      s = nil
      to_string_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      @grammar = g
      @show_actions = show_actions
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LEXER_GRAMMAR, PARSER_GRAMMAR, TREE_GRAMMAR, COMBINED_GRAMMAR
          grammar(_t)
          _t = self.attr__ret_tree
        when RULE
          rule(_t)
          _t = self.attr__ret_tree
        when ALT
          alternative(_t)
          _t = self.attr__ret_tree
        when BLOCK, OPTIONAL, CLOSURE, POSITIVE_CLOSURE, SYNPRED, RANGE, CHAR_RANGE, EPSILON, FORCED_ACTION, LABEL, GATED_SEMPRED, SYN_SEMPRED, BACKTRACK_SEMPRED, DOT, ACTION, ASSIGN, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, BANG, PLUS_ASSIGN, SEMPRED, ROOT, WILDCARD, RULE_REF, NOT, TREE_BEGIN
          element(_t)
          _t = self.attr__ret_tree
        when REWRITE
          single_rewrite(_t)
          _t = self.attr__ret_tree
        when EOR
          tmp1_ast_in = _t
          match(_t, EOR)
          _t = _t.get_next_sibling
          s = "EOR"
        else
          raise NoViableAltException.new(_t)
        end
        return normalize(@buf.to_s)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return s
    end
    
    typesig { [AST] }
    def grammar(_t)
      grammar_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LEXER_GRAMMAR
          __t5 = _t
          tmp2_ast_in = _t
          match(_t, LEXER_GRAMMAR)
          _t = _t.get_first_child
          grammar_spec(_t, "lexer ")
          _t = self.attr__ret_tree
          _t = __t5
          _t = _t.get_next_sibling
        when PARSER_GRAMMAR
          __t6 = _t
          tmp3_ast_in = _t
          match(_t, PARSER_GRAMMAR)
          _t = _t.get_first_child
          grammar_spec(_t, "parser ")
          _t = self.attr__ret_tree
          _t = __t6
          _t = _t.get_next_sibling
        when TREE_GRAMMAR
          __t7 = _t
          tmp4_ast_in = _t
          match(_t, TREE_GRAMMAR)
          _t = _t.get_first_child
          grammar_spec(_t, "tree ")
          _t = self.attr__ret_tree
          _t = __t7
          _t = _t.get_next_sibling
        when COMBINED_GRAMMAR
          __t8 = _t
          tmp5_ast_in = _t
          match(_t, COMBINED_GRAMMAR)
          _t = _t.get_first_child
          grammar_spec(_t, "")
          _t = self.attr__ret_tree
          _t = __t8
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rule(_t)
      rule_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      arg = nil
      ret = nil
      b = nil
      begin
        # for error handling
        __t48 = _t
        tmp6_ast_in = _t
        match(_t, RULE)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when FRAGMENT, LITERAL_protected, LITERAL_public, LITERAL_private
          modifier(_t)
          _t = self.attr__ret_tree
        when ARG
        else
          raise NoViableAltException.new(_t)
        end
        out(id.get_text)
        __t50 = _t
        tmp7_ast_in = _t
        match(_t, ARG)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ARG_ACTION
          arg = _t
          match(_t, ARG_ACTION)
          _t = _t.get_next_sibling
          out("[" + (arg.get_text).to_s + "]")
        when 3
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t50
        _t = _t.get_next_sibling
        __t52 = _t
        tmp8_ast_in = _t
        match(_t, RET)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ARG_ACTION
          ret = _t
          match(_t, ARG_ACTION)
          _t = _t.get_next_sibling
          out(" returns [" + (ret.get_text).to_s + "]")
        when 3
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t52
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          options_spec(_t)
          _t = self.attr__ret_tree
        when BLOCK, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when SCOPE
          rule_scope_spec(_t)
          _t = self.attr__ret_tree
        when BLOCK, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            rule_action(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        out(" : ")
        b = (_t).equal?(ASTNULL) ? nil : _t
        block(_t, false)
        _t = self.attr__ret_tree
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_catch, LITERAL_finally
          exception_group(_t)
          _t = self.attr__ret_tree
        when EOR
        else
          raise NoViableAltException.new(_t)
        end
        tmp9_ast_in = _t
        match(_t, EOR)
        _t = _t.get_next_sibling
        out(";\n")
        _t = __t48
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def alternative(_t)
      alternative_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t80 = _t
        tmp10_ast_in = _t
        match(_t, ALT)
        _t = _t.get_first_child
        _cnt82 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(BLOCK) || (_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(SYNPRED) || (_t.get_type).equal?(RANGE) || (_t.get_type).equal?(CHAR_RANGE) || (_t.get_type).equal?(EPSILON) || (_t.get_type).equal?(FORCED_ACTION) || (_t.get_type).equal?(LABEL) || (_t.get_type).equal?(GATED_SEMPRED) || (_t.get_type).equal?(SYN_SEMPRED) || (_t.get_type).equal?(BACKTRACK_SEMPRED) || (_t.get_type).equal?(DOT) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(BANG) || (_t.get_type).equal?(PLUS_ASSIGN) || (_t.get_type).equal?(SEMPRED) || (_t.get_type).equal?(ROOT) || (_t.get_type).equal?(WILDCARD) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(NOT) || (_t.get_type).equal?(TREE_BEGIN)))
            element(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt82 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt82 += 1
        end while (true)
        tmp11_ast_in = _t
        match(_t, EOA)
        _t = _t.get_next_sibling
        _t = __t80
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def element(_t)
      element_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      id2 = nil
      a = nil
      a2 = nil
      pred = nil
      spred = nil
      gpred = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ROOT
          __t107 = _t
          tmp12_ast_in = _t
          match(_t, ROOT)
          _t = _t.get_first_child
          element(_t)
          _t = self.attr__ret_tree
          _t = __t107
          _t = _t.get_next_sibling
        when BANG
          __t108 = _t
          tmp13_ast_in = _t
          match(_t, BANG)
          _t = _t.get_first_child
          element(_t)
          _t = self.attr__ret_tree
          _t = __t108
          _t = _t.get_next_sibling
        when LABEL, DOT, STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, WILDCARD, RULE_REF
          atom(_t)
          _t = self.attr__ret_tree
        when NOT
          __t109 = _t
          tmp14_ast_in = _t
          match(_t, NOT)
          _t = _t.get_first_child
          out("~")
          element(_t)
          _t = self.attr__ret_tree
          _t = __t109
          _t = _t.get_next_sibling
        when RANGE
          __t110 = _t
          tmp15_ast_in = _t
          match(_t, RANGE)
          _t = _t.get_first_child
          atom(_t)
          _t = self.attr__ret_tree
          out("..")
          atom(_t)
          _t = self.attr__ret_tree
          _t = __t110
          _t = _t.get_next_sibling
        when CHAR_RANGE
          __t111 = _t
          tmp16_ast_in = _t
          match(_t, CHAR_RANGE)
          _t = _t.get_first_child
          atom(_t)
          _t = self.attr__ret_tree
          out("..")
          atom(_t)
          _t = self.attr__ret_tree
          _t = __t111
          _t = _t.get_next_sibling
        when ASSIGN
          __t112 = _t
          tmp17_ast_in = _t
          match(_t, ASSIGN)
          _t = _t.get_first_child
          id = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          out((id.get_text).to_s + "=")
          element(_t)
          _t = self.attr__ret_tree
          _t = __t112
          _t = _t.get_next_sibling
        when PLUS_ASSIGN
          __t113 = _t
          tmp18_ast_in = _t
          match(_t, PLUS_ASSIGN)
          _t = _t.get_first_child
          id2 = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          out((id2.get_text).to_s + "+=")
          element(_t)
          _t = self.attr__ret_tree
          _t = __t113
          _t = _t.get_next_sibling
        when BLOCK, OPTIONAL, CLOSURE, POSITIVE_CLOSURE
          ebnf(_t)
          _t = self.attr__ret_tree
        when TREE_BEGIN
          tree(_t)
          _t = self.attr__ret_tree
        when SYNPRED
          __t114 = _t
          tmp19_ast_in = _t
          match(_t, SYNPRED)
          _t = _t.get_first_child
          block(_t, true)
          _t = self.attr__ret_tree
          _t = __t114
          _t = _t.get_next_sibling
          out("=>")
        when ACTION
          a = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          if (@show_actions)
            out("{")
            out(a.get_text)
            out("}")
          end
        when FORCED_ACTION
          a2 = _t
          match(_t, FORCED_ACTION)
          _t = _t.get_next_sibling
          if (@show_actions)
            out("{{")
            out(a2.get_text)
            out("}}")
          end
        when SEMPRED
          pred = _t
          match(_t, SEMPRED)
          _t = _t.get_next_sibling
          if (@show_actions)
            out("{")
            out(pred.get_text)
            out("}?")
          else
            out("{...}?")
          end
        when SYN_SEMPRED
          spred = _t
          match(_t, SYN_SEMPRED)
          _t = _t.get_next_sibling
          name = spred.get_text
          pred_ast = @grammar.get_syntactic_predicate(name)
          block(pred_ast, true)
          out("=>")
        when BACKTRACK_SEMPRED
          tmp20_ast_in = _t
          match(_t, BACKTRACK_SEMPRED)
          _t = _t.get_next_sibling
        when GATED_SEMPRED
          gpred = _t
          match(_t, GATED_SEMPRED)
          _t = _t.get_next_sibling
          if (@show_actions)
            out("{")
            out(gpred.get_text)
            out("}? =>")
          else
            out("{...}? =>")
          end
        when EPSILON
          tmp21_ast_in = _t
          match(_t, EPSILON)
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def single_rewrite(_t)
      single_rewrite_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t92 = _t
        tmp22_ast_in = _t
        match(_t, REWRITE)
        _t = _t.get_first_child
        out(" ->")
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when SEMPRED
          tmp23_ast_in = _t
          match(_t, SEMPRED)
          _t = _t.get_next_sibling
          out(" {" + (tmp23_ast_in.get_text).to_s + "}?")
        when ALT, TEMPLATE, ACTION, ETC
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ALT
          alternative(_t)
          _t = self.attr__ret_tree
        when TEMPLATE
          rewrite_template(_t)
          _t = self.attr__ret_tree
        when ETC
          tmp24_ast_in = _t
          match(_t, ETC)
          _t = _t.get_next_sibling
          out("...")
        when ACTION
          tmp25_ast_in = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          out(" {" + (tmp25_ast_in.get_text).to_s + "}")
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t92
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, String] }
    def grammar_spec(_t, gtype)
      grammar_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      cmt = nil
      begin
        # for error handling
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        out(gtype + "grammar " + (id.get_text).to_s)
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when DOC_COMMENT
          cmt = _t
          match(_t, DOC_COMMENT)
          _t = _t.get_next_sibling
          out((cmt.get_text).to_s + "\n")
        when OPTIONS, TOKENS, RULE, SCOPE, IMPORT, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          options_spec(_t)
          _t = self.attr__ret_tree
        when TOKENS, RULE, SCOPE, IMPORT, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        out(";\n")
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when IMPORT
          delegate_grammars(_t)
          _t = self.attr__ret_tree
        when TOKENS, RULE, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when TOKENS
          tokens_spec(_t)
          _t = self.attr__ret_tree
        when RULE, SCOPE, AMPERSAND
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(SCOPE)))
            attr_scope(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when AMPERSAND
          actions(_t)
          _t = self.attr__ret_tree
        when RULE
        else
          raise NoViableAltException.new(_t)
        end
        rules(_t)
        _t = self.attr__ret_tree
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def attr_scope(_t)
      attr_scope_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t10 = _t
        tmp26_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        tmp27_ast_in = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        tmp28_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t10
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def options_spec(_t)
      options_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t26 = _t
        tmp29_ast_in = _t
        match(_t, OPTIONS)
        _t = _t.get_first_child
        out(" options {")
        _cnt28 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ASSIGN)))
            option(_t)
            _t = self.attr__ret_tree
            out("; ")
          else
            if (_cnt28 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt28 += 1
        end while (true)
        out("} ")
        _t = __t26
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def delegate_grammars(_t)
      delegate_grammars_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t33 = _t
        tmp30_ast_in = _t
        match(_t, IMPORT)
        _t = _t.get_first_child
        _cnt36 = 0
        catch(:break__loop36) do
          begin
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when ASSIGN
              __t35 = _t
              tmp31_ast_in = _t
              match(_t, ASSIGN)
              _t = _t.get_first_child
              tmp32_ast_in = _t
              match(_t, ID)
              _t = _t.get_next_sibling
              tmp33_ast_in = _t
              match(_t, ID)
              _t = _t.get_next_sibling
              _t = __t35
              _t = _t.get_next_sibling
            when ID
              tmp34_ast_in = _t
              match(_t, ID)
              _t = _t.get_next_sibling
            else
              if (_cnt36 >= 1)
                throw :break__loop36, :thrown
              else
                raise NoViableAltException.new(_t)
              end
            end
            _cnt36 += 1
          end while (true)
        end
        _t = __t33
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def tokens_spec(_t)
      tokens_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t38 = _t
        tmp35_ast_in = _t
        match(_t, TOKENS)
        _t = _t.get_first_child
        _cnt40 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(TOKEN_REF)))
            token_spec(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt40 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt40 += 1
        end while (true)
        _t = __t38
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def actions(_t)
      actions_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        _cnt21 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(AMPERSAND)))
            action(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt21 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt21 += 1
        end while (true)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rules(_t)
      rules_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        _cnt46 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(RULE)))
            rule(_t)
            _t = self.attr__ret_tree
          else
            if (_cnt46 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt46 += 1
        end while (true)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def action(_t)
      action_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id1 = nil
      id2 = nil
      a1 = nil
      a2 = nil
      scope = nil
      name = nil
      action_ = nil
      begin
        # for error handling
        __t23 = _t
        tmp36_ast_in = _t
        match(_t, AMPERSAND)
        _t = _t.get_first_child
        id1 = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ID
          id2 = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          a1 = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          scope = (id1.get_text).to_s
          name = (a1.get_text).to_s
          action_ = (a1.get_text).to_s
        when ACTION
          a2 = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          scope = (nil).to_s
          name = (id1.get_text).to_s
          action_ = (a2.get_text).to_s
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t23
        _t = _t.get_next_sibling
        if (@show_actions)
          out("@" + ((!(scope).nil? ? scope + "::" : "")).to_s + name + action_)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def option(_t)
      option_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      begin
        # for error handling
        __t30 = _t
        tmp37_ast_in = _t
        match(_t, ASSIGN)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        out((id.get_text).to_s + "=")
        option_value(_t)
        _t = self.attr__ret_tree
        _t = __t30
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def option_value(_t)
      option_value_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      s = nil
      c = nil
      i = nil
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ID
          id = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          out(id.get_text)
        when STRING_LITERAL
          s = _t
          match(_t, STRING_LITERAL)
          _t = _t.get_next_sibling
          out(s.get_text)
        when CHAR_LITERAL
          c = _t
          match(_t, CHAR_LITERAL)
          _t = _t.get_next_sibling
          out(c.get_text)
        when INT
          i = _t
          match(_t, INT)
          _t = _t.get_next_sibling
          out(i.get_text)
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def token_spec(_t)
      token_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when TOKEN_REF
          tmp38_ast_in = _t
          match(_t, TOKEN_REF)
          _t = _t.get_next_sibling
        when ASSIGN
          __t42 = _t
          tmp39_ast_in = _t
          match(_t, ASSIGN)
          _t = _t.get_first_child
          tmp40_ast_in = _t
          match(_t, TOKEN_REF)
          _t = _t.get_next_sibling
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when STRING_LITERAL
            tmp41_ast_in = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_next_sibling
          when CHAR_LITERAL
            tmp42_ast_in = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_next_sibling
          else
            raise NoViableAltException.new(_t)
          end
          _t = __t42
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def modifier(_t)
      modifier_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      out(modifier_ast_in.get_text)
      out(" ")
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_protected
          tmp43_ast_in = _t
          match(_t, LITERAL_protected)
          _t = _t.get_next_sibling
        when LITERAL_public
          tmp44_ast_in = _t
          match(_t, LITERAL_public)
          _t = _t.get_next_sibling
        when LITERAL_private
          tmp45_ast_in = _t
          match(_t, LITERAL_private)
          _t = _t.get_next_sibling
        when FRAGMENT
          tmp46_ast_in = _t
          match(_t, FRAGMENT)
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rule_scope_spec(_t)
      rule_scope_spec_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t63 = _t
        tmp47_ast_in = _t
        match(_t, SCOPE)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ACTION
          tmp48_ast_in = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
        when 3, ID
        else
          raise NoViableAltException.new(_t)
        end
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ID)))
            tmp49_ast_in = _t
            match(_t, ID)
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        _t = __t63
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rule_action(_t)
      rule_action_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      a = nil
      begin
        # for error handling
        __t60 = _t
        tmp50_ast_in = _t
        match(_t, AMPERSAND)
        _t = _t.get_first_child
        id = _t
        match(_t, ID)
        _t = _t.get_next_sibling
        a = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t60
        _t = _t.get_next_sibling
        if (@show_actions)
          out("@" + (id.get_text).to_s + "{" + (a.get_text).to_s + "}")
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST, ::Java::Boolean] }
    def block(_t, force_parens)
      block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      num_alts = count_alts_for_block(block_ast_in)
      begin
        # for error handling
        __t68 = _t
        tmp51_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        if (force_parens || num_alts > 1)
          out(" (")
        end
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          options_spec(_t)
          _t = self.attr__ret_tree
          out(" : ")
        when ALT
        else
          raise NoViableAltException.new(_t)
        end
        alternative(_t)
        _t = self.attr__ret_tree
        rewrite(_t)
        _t = self.attr__ret_tree
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            out(" | ")
            alternative(_t)
            _t = self.attr__ret_tree
            rewrite(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        tmp52_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        if (force_parens || num_alts > 1)
          out(")")
        end
        _t = __t68
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def exception_group(_t)
      exception_group_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when LITERAL_catch
          _cnt85 = 0
          begin
            if ((_t).nil?)
              _t = ASTNULL
            end
            if (((_t.get_type).equal?(LITERAL_catch)))
              exception_handler(_t)
              _t = self.attr__ret_tree
            else
              if (_cnt85 >= 1)
                break
              else
                raise NoViableAltException.new(_t)
              end
            end
            _cnt85 += 1
          end while (true)
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when LITERAL_finally
            finally_clause(_t)
            _t = self.attr__ret_tree
          when EOR
          else
            raise NoViableAltException.new(_t)
          end
        when LITERAL_finally
          finally_clause(_t)
          _t = self.attr__ret_tree
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite(_t)
      rewrite_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(REWRITE)))
            single_rewrite(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def count_alts_for_block(_t)
      n = 0
      count_alts_for_block_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t73 = _t
        tmp53_ast_in = _t
        match(_t, BLOCK)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when OPTIONS
          tmp54_ast_in = _t
          match(_t, OPTIONS)
          _t = _t.get_next_sibling
        when ALT
        else
          raise NoViableAltException.new(_t)
        end
        _cnt78 = 0
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ALT)))
            tmp55_ast_in = _t
            match(_t, ALT)
            _t = _t.get_next_sibling
            begin
              if ((_t).nil?)
                _t = ASTNULL
              end
              if (((_t.get_type).equal?(REWRITE)))
                tmp56_ast_in = _t
                match(_t, REWRITE)
                _t = _t.get_next_sibling
              else
                break
              end
            end while (true)
            n += 1
          else
            if (_cnt78 >= 1)
              break
            else
              raise NoViableAltException.new(_t)
            end
          end
          _cnt78 += 1
        end while (true)
        tmp57_ast_in = _t
        match(_t, EOB)
        _t = _t.get_next_sibling
        _t = __t73
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
      return n
    end
    
    typesig { [AST] }
    def exception_handler(_t)
      exception_handler_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t88 = _t
        tmp58_ast_in = _t
        match(_t, LITERAL_catch)
        _t = _t.get_first_child
        tmp59_ast_in = _t
        match(_t, ARG_ACTION)
        _t = _t.get_next_sibling
        tmp60_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t88
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def finally_clause(_t)
      finally_clause_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t90 = _t
        tmp61_ast_in = _t
        match(_t, LITERAL_finally)
        _t = _t.get_first_child
        tmp62_ast_in = _t
        match(_t, ACTION)
        _t = _t.get_next_sibling
        _t = __t90
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def rewrite_template(_t)
      rewrite_template_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      id = nil
      ind = nil
      arg = nil
      a = nil
      begin
        # for error handling
        __t96 = _t
        tmp63_ast_in = _t
        match(_t, TEMPLATE)
        _t = _t.get_first_child
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ID
          id = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          out(" " + (id.get_text).to_s)
        when ACTION
          ind = _t
          match(_t, ACTION)
          _t = _t.get_next_sibling
          out(" ({" + (ind.get_text).to_s + "})")
        else
          raise NoViableAltException.new(_t)
        end
        __t98 = _t
        tmp64_ast_in = _t
        match(_t, ARGLIST)
        _t = _t.get_first_child
        out("(")
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(ARG)))
            __t100 = _t
            tmp65_ast_in = _t
            match(_t, ARG)
            _t = _t.get_first_child
            arg = _t
            match(_t, ID)
            _t = _t.get_next_sibling
            out((arg.get_text).to_s + "=")
            a = _t
            match(_t, ACTION)
            _t = _t.get_next_sibling
            out(a.get_text)
            _t = __t100
            _t = _t.get_next_sibling
          else
            break
          end
        end while (true)
        out(")")
        _t = __t98
        _t = _t.get_next_sibling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when DOUBLE_QUOTE_STRING_LITERAL
          tmp66_ast_in = _t
          match(_t, DOUBLE_QUOTE_STRING_LITERAL)
          _t = _t.get_next_sibling
          out(" " + (tmp66_ast_in.get_text).to_s)
        when DOUBLE_ANGLE_STRING_LITERAL
          tmp67_ast_in = _t
          match(_t, DOUBLE_ANGLE_STRING_LITERAL)
          _t = _t.get_next_sibling
          out(" " + (tmp67_ast_in.get_text).to_s)
        when 3
        else
          raise NoViableAltException.new(_t)
        end
        _t = __t96
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def atom(_t)
      atom_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      rarg = nil
      targ = nil
      out(" ")
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when STRING_LITERAL, CHAR_LITERAL, TOKEN_REF, WILDCARD, RULE_REF
          if ((_t).nil?)
            _t = ASTNULL
          end
          case (_t.get_type)
          when RULE_REF
            __t125 = _t
            tmp68_ast_in = _t
            match(_t, RULE_REF)
            _t = _t.get_first_child
            out(atom_ast_in.to_s)
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when ARG_ACTION
              rarg = _t
              match(_t, ARG_ACTION)
              _t = _t.get_next_sibling
              out("[" + (rarg.to_s).to_s + "]")
            when 3, BANG, ROOT
            else
              raise NoViableAltException.new(_t)
            end
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when BANG, ROOT
              ast_suffix(_t)
              _t = self.attr__ret_tree
            when 3
            else
              raise NoViableAltException.new(_t)
            end
            _t = __t125
            _t = _t.get_next_sibling
          when TOKEN_REF
            __t128 = _t
            tmp69_ast_in = _t
            match(_t, TOKEN_REF)
            _t = _t.get_first_child
            out(atom_ast_in.to_s)
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when ARG_ACTION
              targ = _t
              match(_t, ARG_ACTION)
              _t = _t.get_next_sibling
              out("[" + (targ.to_s).to_s + "]")
            when 3, BANG, ROOT
            else
              raise NoViableAltException.new(_t)
            end
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when BANG, ROOT
              ast_suffix(_t)
              _t = self.attr__ret_tree
            when 3
            else
              raise NoViableAltException.new(_t)
            end
            _t = __t128
            _t = _t.get_next_sibling
          when CHAR_LITERAL
            __t131 = _t
            tmp70_ast_in = _t
            match(_t, CHAR_LITERAL)
            _t = _t.get_first_child
            out(atom_ast_in.to_s)
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when BANG, ROOT
              ast_suffix(_t)
              _t = self.attr__ret_tree
            when 3
            else
              raise NoViableAltException.new(_t)
            end
            _t = __t131
            _t = _t.get_next_sibling
          when STRING_LITERAL
            __t133 = _t
            tmp71_ast_in = _t
            match(_t, STRING_LITERAL)
            _t = _t.get_first_child
            out(atom_ast_in.to_s)
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when BANG, ROOT
              ast_suffix(_t)
              _t = self.attr__ret_tree
            when 3
            else
              raise NoViableAltException.new(_t)
            end
            _t = __t133
            _t = _t.get_next_sibling
          when WILDCARD
            __t135 = _t
            tmp72_ast_in = _t
            match(_t, WILDCARD)
            _t = _t.get_first_child
            out(atom_ast_in.to_s)
            if ((_t).nil?)
              _t = ASTNULL
            end
            case (_t.get_type)
            when BANG, ROOT
              ast_suffix(_t)
              _t = self.attr__ret_tree
            when 3
            else
              raise NoViableAltException.new(_t)
            end
            _t = __t135
            _t = _t.get_next_sibling
          else
            raise NoViableAltException.new(_t)
          end
          out(" ")
        when LABEL
          tmp73_ast_in = _t
          match(_t, LABEL)
          _t = _t.get_next_sibling
          out(" $" + (tmp73_ast_in.get_text).to_s)
        when DOT
          __t137 = _t
          tmp74_ast_in = _t
          match(_t, DOT)
          _t = _t.get_first_child
          tmp75_ast_in = _t
          match(_t, ID)
          _t = _t.get_next_sibling
          out((tmp75_ast_in.get_text).to_s + ".")
          atom(_t)
          _t = self.attr__ret_tree
          _t = __t137
          _t = _t.get_next_sibling
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def ebnf(_t)
      ebnf_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when BLOCK
          block(_t, true)
          _t = self.attr__ret_tree
          out(" ")
        when OPTIONAL
          __t116 = _t
          tmp76_ast_in = _t
          match(_t, OPTIONAL)
          _t = _t.get_first_child
          block(_t, true)
          _t = self.attr__ret_tree
          _t = __t116
          _t = _t.get_next_sibling
          out("? ")
        when CLOSURE
          __t117 = _t
          tmp77_ast_in = _t
          match(_t, CLOSURE)
          _t = _t.get_first_child
          block(_t, true)
          _t = self.attr__ret_tree
          _t = __t117
          _t = _t.get_next_sibling
          out("* ")
        when POSITIVE_CLOSURE
          __t118 = _t
          tmp78_ast_in = _t
          match(_t, POSITIVE_CLOSURE)
          _t = _t.get_first_child
          block(_t, true)
          _t = self.attr__ret_tree
          _t = __t118
          _t = _t.get_next_sibling
          out("+ ")
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def tree(_t)
      tree_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        __t120 = _t
        tmp79_ast_in = _t
        match(_t, TREE_BEGIN)
        _t = _t.get_first_child
        out(" ^(")
        element(_t)
        _t = self.attr__ret_tree
        begin
          if ((_t).nil?)
            _t = ASTNULL
          end
          if (((_t.get_type).equal?(BLOCK) || (_t.get_type).equal?(OPTIONAL) || (_t.get_type).equal?(CLOSURE) || (_t.get_type).equal?(POSITIVE_CLOSURE) || (_t.get_type).equal?(SYNPRED) || (_t.get_type).equal?(RANGE) || (_t.get_type).equal?(CHAR_RANGE) || (_t.get_type).equal?(EPSILON) || (_t.get_type).equal?(FORCED_ACTION) || (_t.get_type).equal?(LABEL) || (_t.get_type).equal?(GATED_SEMPRED) || (_t.get_type).equal?(SYN_SEMPRED) || (_t.get_type).equal?(BACKTRACK_SEMPRED) || (_t.get_type).equal?(DOT) || (_t.get_type).equal?(ACTION) || (_t.get_type).equal?(ASSIGN) || (_t.get_type).equal?(STRING_LITERAL) || (_t.get_type).equal?(CHAR_LITERAL) || (_t.get_type).equal?(TOKEN_REF) || (_t.get_type).equal?(BANG) || (_t.get_type).equal?(PLUS_ASSIGN) || (_t.get_type).equal?(SEMPRED) || (_t.get_type).equal?(ROOT) || (_t.get_type).equal?(WILDCARD) || (_t.get_type).equal?(RULE_REF) || (_t.get_type).equal?(NOT) || (_t.get_type).equal?(TREE_BEGIN)))
            element(_t)
            _t = self.attr__ret_tree
          else
            break
          end
        end while (true)
        out(") ")
        _t = __t120
        _t = _t.get_next_sibling
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    typesig { [AST] }
    def ast_suffix(_t)
      ast_suffix_ast_in = ((_t).equal?(ASTNULL)) ? nil : _t
      begin
        # for error handling
        if ((_t).nil?)
          _t = ASTNULL
        end
        case (_t.get_type)
        when ROOT
          tmp80_ast_in = _t
          match(_t, ROOT)
          _t = _t.get_next_sibling
          out("^")
        when BANG
          tmp81_ast_in = _t
          match(_t, BANG)
          _t = _t.get_next_sibling
          out("!")
        else
          raise NoViableAltException.new(_t)
        end
      rescue RecognitionException => ex
        report_error(ex)
        if (!(_t).nil?)
          _t = _t.get_next_sibling
        end
      end
      self.attr__ret_tree = _t
    end
    
    class_module.module_eval {
      const_set_lazy(:_tokenNames) { Array.typed(String).new(["<0>", "EOF", "<2>", "NULL_TREE_LOOKAHEAD", "\"options\"", "\"tokens\"", "\"parser\"", "LEXER", "RULE", "BLOCK", "OPTIONAL", "CLOSURE", "POSITIVE_CLOSURE", "SYNPRED", "RANGE", "CHAR_RANGE", "EPSILON", "ALT", "EOR", "EOB", "EOA", "ID", "ARG", "ARGLIST", "RET", "LEXER_GRAMMAR", "PARSER_GRAMMAR", "TREE_GRAMMAR", "COMBINED_GRAMMAR", "INITACTION", "FORCED_ACTION", "LABEL", "TEMPLATE", "\"scope\"", "\"import\"", "GATED_SEMPRED", "SYN_SEMPRED", "BACKTRACK_SEMPRED", "\"fragment\"", "DOT", "ACTION", "DOC_COMMENT", "SEMI", "\"lexer\"", "\"tree\"", "\"grammar\"", "AMPERSAND", "COLON", "RCURLY", "ASSIGN", "STRING_LITERAL", "CHAR_LITERAL", "INT", "STAR", "COMMA", "TOKEN_REF", "\"protected\"", "\"public\"", "\"private\"", "BANG", "ARG_ACTION", "\"returns\"", "\"throws\"", "LPAREN", "OR", "RPAREN", "\"catch\"", "\"finally\"", "PLUS_ASSIGN", "SEMPRED", "IMPLIES", "ROOT", "WILDCARD", "RULE_REF", "NOT", "TREE_BEGIN", "QUESTION", "PLUS", "OPEN_ELEMENT_OPTION", "CLOSE_ELEMENT_OPTION", "REWRITE", "ETC", "DOLLAR", "DOUBLE_QUOTE_STRING_LITERAL", "DOUBLE_ANGLE_STRING_LITERAL", "WS", "COMMENT", "SL_COMMENT", "ML_COMMENT", "STRAY_BRACKET", "ESC", "DIGIT", "XDIGIT", "NESTED_ARG_ACTION", "NESTED_ACTION", "ACTION_CHAR_LITERAL", "ACTION_STRING_LITERAL", "ACTION_ESC", "WS_LOOP", "INTERNAL_RULE_REF", "WS_OPT", "SRC"]) }
      const_attr_reader  :_tokenNames
    }
    
    private
    alias_method :initialize__antlrtree_printer, :initialize
  end
  
end
