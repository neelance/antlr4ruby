require "rjava"
 # $ANTLR 2.7.7 (2006-01-29): "antlr.g" -> "ANTLRLexer.java"$
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
  module ANTLRLexerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include ::Java::Util
      include ::Java::Io
      include ::Org::Antlr::Analysis
      include ::Org::Antlr::Misc
      include ::Antlr
      include_const ::Java::Io, :InputStream
      include_const ::Antlr, :TokenStreamException
      include_const ::Antlr, :TokenStreamIOException
      include_const ::Antlr, :TokenStreamRecognitionException
      include_const ::Antlr, :CharStreamException
      include_const ::Antlr, :CharStreamIOException
      include_const ::Antlr, :ANTLRException
      include_const ::Java::Io, :Reader
      include_const ::Java::Util, :Hashtable
      include_const ::Antlr, :CharScanner
      include_const ::Antlr, :InputBuffer
      include_const ::Antlr, :ByteBuffer
      include_const ::Antlr, :CharBuffer
      include_const ::Antlr, :Token
      include_const ::Antlr, :CommonToken
      include_const ::Antlr, :RecognitionException
      include_const ::Antlr, :NoViableAltForCharException
      include_const ::Antlr, :MismatchedCharException
      include_const ::Antlr, :TokenStream
      include_const ::Antlr, :ANTLRHashString
      include_const ::Antlr, :LexerSharedInputState
      include_const ::Antlr::Collections::Impl, :BitSet
      include_const ::Antlr, :SemanticException
    }
  end
  
  class ANTLRLexer < Antlr::CharScanner
    include_class_members ANTLRLexerImports
    include ANTLRTokenTypes
    include TokenStream
    
    typesig { [] }
    # advance the current column number by one; don't do tabs.
    # we want char position in line to be sent to AntlrWorks.
    def tab
      set_column(get_column + 1)
    end
    
    attr_accessor :has_astoperator
    alias_method :attr_has_astoperator, :has_astoperator
    undef_method :has_astoperator
    alias_method :attr_has_astoperator=, :has_astoperator=
    undef_method :has_astoperator=
    
    typesig { [InputStream] }
    def initialize(in_)
      initialize__antlrlexer(ByteBuffer.new(in_))
    end
    
    typesig { [Reader] }
    def initialize(in_)
      initialize__antlrlexer(CharBuffer.new(in_))
    end
    
    typesig { [InputBuffer] }
    def initialize(ib)
      initialize__antlrlexer(LexerSharedInputState.new(ib))
    end
    
    typesig { [LexerSharedInputState] }
    def initialize(state)
      @has_astoperator = false
      super(state)
      @has_astoperator = false
      self.attr_case_sensitive_literals = true
      set_case_sensitive(true)
      self.attr_literals = Hashtable.new
      self.attr_literals.put(ANTLRHashString.new("lexer", self), 43)
      self.attr_literals.put(ANTLRHashString.new("scope", self), 33)
      self.attr_literals.put(ANTLRHashString.new("finally", self), 67)
      self.attr_literals.put(ANTLRHashString.new("throws", self), 62)
      self.attr_literals.put(ANTLRHashString.new("import", self), 34)
      self.attr_literals.put(ANTLRHashString.new("fragment", self), 38)
      self.attr_literals.put(ANTLRHashString.new("private", self), 58)
      self.attr_literals.put(ANTLRHashString.new("grammar", self), 45)
      self.attr_literals.put(ANTLRHashString.new("tokens", self), 5)
      self.attr_literals.put(ANTLRHashString.new("options", self), 4)
      self.attr_literals.put(ANTLRHashString.new("parser", self), 6)
      self.attr_literals.put(ANTLRHashString.new("tree", self), 44)
      self.attr_literals.put(ANTLRHashString.new("protected", self), 56)
      self.attr_literals.put(ANTLRHashString.new("returns", self), 61)
      self.attr_literals.put(ANTLRHashString.new("public", self), 57)
      self.attr_literals.put(ANTLRHashString.new("catch", self), 66)
    end
    
    typesig { [] }
    def next_token
      the_ret_token = nil
      loop do
        _token = nil
        _ttype = Token::INVALID_TYPE
        reset_text
        begin
          # for char stream error handling
          begin
            # for lexical error handling
            case (_la(1))
            when Character.new(?\t.ord), Character.new(?\n.ord), Character.new(?\r.ord), Character.new(?\s.ord)
              m_ws(true)
              the_ret_token = self.attr__return_token
            when Character.new(?/.ord)
              m_comment(true)
              the_ret_token = self.attr__return_token
            when Character.new(?>.ord)
              m_close_element_option(true)
              the_ret_token = self.attr__return_token
            when Character.new(?@.ord)
              m_ampersand(true)
              the_ret_token = self.attr__return_token
            when Character.new(?,.ord)
              m_comma(true)
              the_ret_token = self.attr__return_token
            when Character.new(??.ord)
              m_question(true)
              the_ret_token = self.attr__return_token
            when Character.new(?(.ord)
              m_lparen(true)
              the_ret_token = self.attr__return_token
            when Character.new(?).ord)
              m_rparen(true)
              the_ret_token = self.attr__return_token
            when Character.new(?:.ord)
              m_colon(true)
              the_ret_token = self.attr__return_token
            when Character.new(?*.ord)
              m_star(true)
              the_ret_token = self.attr__return_token
            when Character.new(?-.ord)
              m_rewrite(true)
              the_ret_token = self.attr__return_token
            when Character.new(?;.ord)
              m_semi(true)
              the_ret_token = self.attr__return_token
            when Character.new(?!.ord)
              m_bang(true)
              the_ret_token = self.attr__return_token
            when Character.new(?|.ord)
              m_or(true)
              the_ret_token = self.attr__return_token
            when Character.new(?~.ord)
              m_not(true)
              the_ret_token = self.attr__return_token
            when Character.new(?}.ord)
              m_rcurly(true)
              the_ret_token = self.attr__return_token
            when Character.new(?$.ord)
              m_dollar(true)
              the_ret_token = self.attr__return_token
            when Character.new(?].ord)
              m_stray_bracket(true)
              the_ret_token = self.attr__return_token
            when Character.new(?\'.ord)
              m_char_literal(true)
              the_ret_token = self.attr__return_token
            when Character.new(?".ord)
              m_double_quote_string_literal(true)
              the_ret_token = self.attr__return_token
            when Character.new(?0.ord), Character.new(?1.ord), Character.new(?2.ord), Character.new(?3.ord), Character.new(?4.ord), Character.new(?5.ord), Character.new(?6.ord), Character.new(?7.ord), Character.new(?8.ord), Character.new(?9.ord)
              m_int(true)
              the_ret_token = self.attr__return_token
            when Character.new(?[.ord)
              m_arg_action(true)
              the_ret_token = self.attr__return_token
            when Character.new(?{.ord)
              m_action(true)
              the_ret_token = self.attr__return_token
            when Character.new(?A.ord), Character.new(?B.ord), Character.new(?C.ord), Character.new(?D.ord), Character.new(?E.ord), Character.new(?F.ord), Character.new(?G.ord), Character.new(?H.ord), Character.new(?I.ord), Character.new(?J.ord), Character.new(?K.ord), Character.new(?L.ord), Character.new(?M.ord), Character.new(?N.ord), Character.new(?O.ord), Character.new(?P.ord), Character.new(?Q.ord), Character.new(?R.ord), Character.new(?S.ord), Character.new(?T.ord), Character.new(?U.ord), Character.new(?V.ord), Character.new(?W.ord), Character.new(?X.ord), Character.new(?Y.ord), Character.new(?Z.ord)
              m_token_ref(true)
              the_ret_token = self.attr__return_token
            when Character.new(?a.ord), Character.new(?b.ord), Character.new(?c.ord), Character.new(?d.ord), Character.new(?e.ord), Character.new(?f.ord), Character.new(?g.ord), Character.new(?h.ord), Character.new(?i.ord), Character.new(?j.ord), Character.new(?k.ord), Character.new(?l.ord), Character.new(?m.ord), Character.new(?n.ord), Character.new(?o.ord), Character.new(?p.ord), Character.new(?q.ord), Character.new(?r.ord), Character.new(?s.ord), Character.new(?t.ord), Character.new(?u.ord), Character.new(?v.ord), Character.new(?w.ord), Character.new(?x.ord), Character.new(?y.ord), Character.new(?z.ord)
              m_rule_ref(true)
              the_ret_token = self.attr__return_token
            else
              if (((_la(1)).equal?(Character.new(?..ord))) && ((_la(2)).equal?(Character.new(?..ord))) && ((_la(3)).equal?(Character.new(?..ord))))
                m_etc(true)
                the_ret_token = self.attr__return_token
              else
                if (((_la(1)).equal?(Character.new(?^.ord))) && ((_la(2)).equal?(Character.new(?(.ord))))
                  m_tree_begin(true)
                  the_ret_token = self.attr__return_token
                else
                  if (((_la(1)).equal?(Character.new(?+.ord))) && ((_la(2)).equal?(Character.new(?=.ord))))
                    m_plus_assign(true)
                    the_ret_token = self.attr__return_token
                  else
                    if (((_la(1)).equal?(Character.new(?=.ord))) && ((_la(2)).equal?(Character.new(?>.ord))))
                      m_implies(true)
                      the_ret_token = self.attr__return_token
                    else
                      if (((_la(1)).equal?(Character.new(?..ord))) && ((_la(2)).equal?(Character.new(?..ord))) && (true))
                        m_range(true)
                        the_ret_token = self.attr__return_token
                      else
                        if (((_la(1)).equal?(Character.new(?<.ord))) && ((_la(2)).equal?(Character.new(?<.ord))))
                          m_double_angle_string_literal(true)
                          the_ret_token = self.attr__return_token
                        else
                          if (((_la(1)).equal?(Character.new(?<.ord))) && (true))
                            m_open_element_option(true)
                            the_ret_token = self.attr__return_token
                          else
                            if (((_la(1)).equal?(Character.new(?+.ord))) && (true))
                              m_plus(true)
                              the_ret_token = self.attr__return_token
                            else
                              if (((_la(1)).equal?(Character.new(?=.ord))) && (true))
                                m_assign(true)
                                the_ret_token = self.attr__return_token
                              else
                                if (((_la(1)).equal?(Character.new(?^.ord))) && (true))
                                  m_root(true)
                                  the_ret_token = self.attr__return_token
                                else
                                  if (((_la(1)).equal?(Character.new(?..ord))) && (true))
                                    m_wildcard(true)
                                    the_ret_token = self.attr__return_token
                                  else
                                    if ((_la(1)).equal?(EOF_CHAR))
                                      upon_eof
                                      self.attr__return_token = make_token(Token::EOF_TYPE)
                                    else
                                      raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
            if ((self.attr__return_token).nil?)
              next
            end # found SKIP token
            _ttype = self.attr__return_token.get_type
            self.attr__return_token.set_type(_ttype)
            return self.attr__return_token
          rescue RecognitionException => e
            raise TokenStreamRecognitionException.new(e)
          end
        rescue CharStreamException => cse
          if (cse.is_a?(CharStreamIOException))
            raise TokenStreamIOException.new((cse).attr_io)
          else
            raise TokenStreamException.new(cse.get_message)
          end
        end
      end
    end
    
    typesig { [::Java::Boolean] }
    def m_ws(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = WS
      _save_index = 0
      case (_la(1))
      when Character.new(?\s.ord)
        match(Character.new(?\s.ord))
      when Character.new(?\t.ord)
        match(Character.new(?\t.ord))
      when Character.new(?\n.ord), Character.new(?\r.ord)
        case (_la(1))
        when Character.new(?\r.ord)
          match(Character.new(?\r.ord))
        when Character.new(?\n.ord)
        else
          raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
        end
        match(Character.new(?\n.ord))
        if ((self.attr_input_state.attr_guessing).equal?(0))
          newline
        end
      else
        raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_comment(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = COMMENT
      _save_index = 0
      t = nil
      if (((_la(1)).equal?(Character.new(?/.ord))) && ((_la(2)).equal?(Character.new(?/.ord))))
        m_sl_comment(false)
      else
        if (((_la(1)).equal?(Character.new(?/.ord))) && ((_la(2)).equal?(Character.new(?*.ord))))
          m_ml_comment(true)
          t = self.attr__return_token
          if ((self.attr_input_state.attr_guessing).equal?(0))
            _ttype = t.get_type
          end
        else
          raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
        end
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_sl_comment(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = SL_COMMENT
      _save_index = 0
      match("//")
      syn_pred_matched161 = false
      if ((((_la(1)).equal?(Character.new(?\s.ord))) && ((_la(2)).equal?(Character.new(?$.ord))) && ((_la(3)).equal?(Character.new(?A.ord)))))
        _m161 = mark
        syn_pred_matched161 = true
        self.attr_input_state.attr_guessing += 1
        begin
          match(" $ANTLR")
        rescue RecognitionException => pe
          syn_pred_matched161 = false
        end
        rewind(_m161)
        self.attr_input_state.attr_guessing -= 1
      end
      if (syn_pred_matched161)
        match(" $ANTLR ")
        m_src(false)
        case (_la(1))
        when Character.new(?\r.ord)
          match(Character.new(?\r.ord))
        when Character.new(?\n.ord)
        else
          raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
        end
        match(Character.new(?\n.ord))
      else
        if (((_la(1) >= Character.new(0x0003) && _la(1) <= Character.new(0x00ff))) && (true) && (true))
          begin
            # nongreedy exit test
            if (((_la(1)).equal?(Character.new(?\n.ord)) || (_la(1)).equal?(Character.new(?\r.ord))) && (true) && (true))
              break
            end
            if (((_la(1) >= Character.new(0x0003) && _la(1) <= Character.new(0x00ff))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
              match_not(EOF_CHAR)
            else
              break
            end
          end while (true)
          case (_la(1))
          when Character.new(?\r.ord)
            match(Character.new(?\r.ord))
          when Character.new(?\n.ord)
          else
            raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
          end
          match(Character.new(?\n.ord))
        else
          raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
        end
      end
      if ((self.attr_input_state.attr_guessing).equal?(0))
        newline
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_ml_comment(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ML_COMMENT
      _save_index = 0
      match("/*")
      if ((((_la(1)).equal?(Character.new(?*.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff)))) && (!(_la(2)).equal?(Character.new(?/.ord))))
        match(Character.new(?*.ord))
        if ((self.attr_input_state.attr_guessing).equal?(0))
          _ttype = DOC_COMMENT
        end
      else
        if (((_la(1) >= Character.new(0x0003) && _la(1) <= Character.new(0x00ff))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
        else
          raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
        end
      end
      catch(:break__loop170) do
        begin
          # nongreedy exit test
          if (((_la(1)).equal?(Character.new(?*.ord))) && ((_la(2)).equal?(Character.new(?/.ord))) && (true))
            break
          end
          case (_la(1))
          when Character.new(?\r.ord)
            match(Character.new(?\r.ord))
            match(Character.new(?\n.ord))
            if ((self.attr_input_state.attr_guessing).equal?(0))
              newline
            end
          when Character.new(?\n.ord)
            match(Character.new(?\n.ord))
            if ((self.attr_input_state.attr_guessing).equal?(0))
              newline
            end
          else
            if ((_tokenSet_0.member(_la(1))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff))))
              match(_tokenSet_0)
            else
              throw :break__loop170, :thrown
            end
          end
        end while (true)
      end
      match("*/")
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    # Reset the file and line information; useful when the grammar
    # has been generated so that errors are shown relative to the
    # original file like the old C preprocessor used to do.
    def m_src(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = SRC
      _save_index = 0
      file = nil
      line = nil
      match("src")
      match(Character.new(?\s.ord))
      m_action_string_literal(true)
      file = self.attr__return_token
      match(Character.new(?\s.ord))
      m_int(true)
      line = self.attr__return_token
      if ((self.attr_input_state.attr_guessing).equal?(0))
        newline
        set_filename(file.get_text.substring(1, file.get_text.length - 1))
        set_line(JavaInteger.parse_int(line.get_text) - 1) # -1 because SL_COMMENT will increment the line no. KR
        _ttype = Token::SKIP # don't let this go to the parser
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_open_element_option(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = OPEN_ELEMENT_OPTION
      _save_index = 0
      match(Character.new(?<.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_close_element_option(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = CLOSE_ELEMENT_OPTION
      _save_index = 0
      match(Character.new(?>.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_ampersand(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = AMPERSAND
      _save_index = 0
      match(Character.new(?@.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_comma(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = COMMA
      _save_index = 0
      match(Character.new(?,.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_question(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = QUESTION
      _save_index = 0
      match(Character.new(??.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_tree_begin(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = TREE_BEGIN
      _save_index = 0
      match("^(")
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_lparen(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = LPAREN
      _save_index = 0
      match(Character.new(?(.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_rparen(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = RPAREN
      _save_index = 0
      match(Character.new(?).ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_colon(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = COLON
      _save_index = 0
      match(Character.new(?:.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_star(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = STAR
      _save_index = 0
      match(Character.new(?*.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_plus(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = PLUS
      _save_index = 0
      match(Character.new(?+.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_assign(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ASSIGN
      _save_index = 0
      match(Character.new(?=.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_plus_assign(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = PLUS_ASSIGN
      _save_index = 0
      match("+=")
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_implies(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = IMPLIES
      _save_index = 0
      match("=>")
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_rewrite(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = REWRITE
      _save_index = 0
      match("->")
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_semi(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = SEMI
      _save_index = 0
      match(Character.new(?;.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_root(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ROOT
      _save_index = 0
      match(Character.new(?^.ord))
      if ((self.attr_input_state.attr_guessing).equal?(0))
        @has_astoperator = true
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_bang(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = BANG
      _save_index = 0
      match(Character.new(?!.ord))
      if ((self.attr_input_state.attr_guessing).equal?(0))
        @has_astoperator = true
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_or(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = OR
      _save_index = 0
      match(Character.new(?|.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_wildcard(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = WILDCARD
      _save_index = 0
      match(Character.new(?..ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_etc(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ETC
      _save_index = 0
      match("...")
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_range(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = RANGE
      _save_index = 0
      match("..")
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_not(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = NOT
      _save_index = 0
      match(Character.new(?~.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_rcurly(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = RCURLY
      _save_index = 0
      match(Character.new(?}.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_dollar(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = DOLLAR
      _save_index = 0
      match(Character.new(?$.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_stray_bracket(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = STRAY_BRACKET
      _save_index = 0
      match(Character.new(?].ord))
      if ((self.attr_input_state.attr_guessing).equal?(0))
        ErrorManager.syntax_error(ErrorManager::MSG_SYNTAX_ERROR, nil, _token, "antlr: dangling ']'? make sure to escape with \\]", nil)
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_char_literal(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = CHAR_LITERAL
      _save_index = 0
      match(Character.new(?\'.ord))
      catch(:break__loop199) do
        begin
          case (_la(1))
          when Character.new(?\\.ord)
            m_esc(false)
          when Character.new(?\n.ord)
            match(Character.new(?\n.ord))
            if ((self.attr_input_state.attr_guessing).equal?(0))
              newline
            end
          else
            if ((_tokenSet_1.member(_la(1))))
              match_not(Character.new(?\'.ord))
            else
              throw :break__loop199, :thrown
            end
          end
        end while (true)
      end
      match(Character.new(?\'.ord))
      if ((self.attr_input_state.attr_guessing).equal?(0))
        s = Grammar.get_unescaped_string_from_grammar_string_literal(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
        if (s.length > 1)
          _ttype = STRING_LITERAL
        end
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_esc(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ESC
      _save_index = 0
      match(Character.new(?\\.ord))
      if (((_la(1)).equal?(Character.new(?u.ord))) && (_tokenSet_2.member(_la(2))) && (_tokenSet_2.member(_la(3))))
        match(Character.new(?u.ord))
        m_xdigit(false)
        m_xdigit(false)
        m_xdigit(false)
        m_xdigit(false)
      else
        if (((_la(1)).equal?(Character.new(?n.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
          match(Character.new(?n.ord))
        else
          if (((_la(1)).equal?(Character.new(?r.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
            match(Character.new(?r.ord))
          else
            if (((_la(1)).equal?(Character.new(?t.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
              match(Character.new(?t.ord))
            else
              if (((_la(1)).equal?(Character.new(?b.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                match(Character.new(?b.ord))
              else
                if (((_la(1)).equal?(Character.new(?f.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                  match(Character.new(?f.ord))
                else
                  if (((_la(1)).equal?(Character.new(?".ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                    match(Character.new(?".ord))
                  else
                    if (((_la(1)).equal?(Character.new(?\'.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                      match(Character.new(?\'.ord))
                    else
                      if (((_la(1)).equal?(Character.new(?\\.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                        match(Character.new(?\\.ord))
                      else
                        if (((_la(1)).equal?(Character.new(?>.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                          match(Character.new(?>.ord))
                        else
                          if (((_la(1) >= Character.new(0x0003) && _la(1) <= Character.new(0x00ff))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                            match_not(EOF_CHAR)
                          else
                            raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_double_quote_string_literal(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = DOUBLE_QUOTE_STRING_LITERAL
      _save_index = 0
      match(Character.new(?".ord))
      begin
        if (((_la(1)).equal?(Character.new(?\\.ord))) && ((_la(2)).equal?(Character.new(?".ord))))
          _save_index = self.attr_text.length
          match(Character.new(?\\.ord))
          self.attr_text.set_length(_save_index)
          match(Character.new(?".ord))
        else
          if (((_la(1)).equal?(Character.new(?\\.ord))) && (_tokenSet_3.member(_la(2))))
            match(Character.new(?\\.ord))
            match_not(Character.new(?".ord))
          else
            if (((_la(1)).equal?(Character.new(?\n.ord))))
              match(Character.new(?\n.ord))
              if ((self.attr_input_state.attr_guessing).equal?(0))
                newline
              end
            else
              if ((_tokenSet_4.member(_la(1))))
                match_not(Character.new(?".ord))
              else
                break
              end
            end
          end
        end
      end while (true)
      match(Character.new(?".ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_double_angle_string_literal(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = DOUBLE_ANGLE_STRING_LITERAL
      _save_index = 0
      match("<<")
      begin
        # nongreedy exit test
        if (((_la(1)).equal?(Character.new(?>.ord))) && ((_la(2)).equal?(Character.new(?>.ord))) && (true))
          break
        end
        if (((_la(1)).equal?(Character.new(?\n.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff))))
          match(Character.new(?\n.ord))
          if ((self.attr_input_state.attr_guessing).equal?(0))
            newline
          end
        else
          if (((_la(1) >= Character.new(0x0003) && _la(1) <= Character.new(0x00ff))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff))))
            match_not(EOF_CHAR)
          else
            break
          end
        end
      end while (true)
      match(">>")
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_xdigit(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = XDIGIT
      _save_index = 0
      case (_la(1))
      when Character.new(?0.ord), Character.new(?1.ord), Character.new(?2.ord), Character.new(?3.ord), Character.new(?4.ord), Character.new(?5.ord), Character.new(?6.ord), Character.new(?7.ord), Character.new(?8.ord), Character.new(?9.ord)
        match_range(Character.new(?0.ord), Character.new(?9.ord))
      when Character.new(?a.ord), Character.new(?b.ord), Character.new(?c.ord), Character.new(?d.ord), Character.new(?e.ord), Character.new(?f.ord)
        match_range(Character.new(?a.ord), Character.new(?f.ord))
      when Character.new(?A.ord), Character.new(?B.ord), Character.new(?C.ord), Character.new(?D.ord), Character.new(?E.ord), Character.new(?F.ord)
        match_range(Character.new(?A.ord), Character.new(?F.ord))
      else
        raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_digit(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = DIGIT
      _save_index = 0
      match_range(Character.new(?0.ord), Character.new(?9.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_int(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = INT
      _save_index = 0
      _cnt212 = 0
      begin
        if (((_la(1) >= Character.new(?0.ord) && _la(1) <= Character.new(?9.ord))))
          match_range(Character.new(?0.ord), Character.new(?9.ord))
        else
          if (_cnt212 >= 1)
            break
          else
            raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
          end
        end
        _cnt212 += 1
      end while (true)
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_arg_action(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ARG_ACTION
      _save_index = 0
      _save_index = self.attr_text.length
      match(Character.new(?[.ord))
      self.attr_text.set_length(_save_index)
      m_nested_arg_action(false)
      _save_index = self.attr_text.length
      match(Character.new(?].ord))
      self.attr_text.set_length(_save_index)
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_nested_arg_action(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = NESTED_ARG_ACTION
      _save_index = 0
      catch(:break__loop216) do
        begin
          case (_la(1))
          when Character.new(?\r.ord)
            match(Character.new(?\r.ord))
            match(Character.new(?\n.ord))
            if ((self.attr_input_state.attr_guessing).equal?(0))
              newline
            end
          when Character.new(?\n.ord)
            match(Character.new(?\n.ord))
            if ((self.attr_input_state.attr_guessing).equal?(0))
              newline
            end
          when Character.new(?".ord)
            m_action_string_literal(false)
          when Character.new(?\'.ord)
            m_action_char_literal(false)
          else
            if (((_la(1)).equal?(Character.new(?\\.ord))) && ((_la(2)).equal?(Character.new(?].ord))))
              _save_index = self.attr_text.length
              match(Character.new(?\\.ord))
              self.attr_text.set_length(_save_index)
              match(Character.new(?].ord))
            else
              if (((_la(1)).equal?(Character.new(?\\.ord))) && (_tokenSet_5.member(_la(2))))
                match(Character.new(?\\.ord))
                match_not(Character.new(?].ord))
              else
                if ((_tokenSet_6.member(_la(1))))
                  match_not(Character.new(?].ord))
                else
                  throw :break__loop216, :thrown
                end
              end
            end
          end
        end while (true)
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_action_string_literal(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ACTION_STRING_LITERAL
      _save_index = 0
      match(Character.new(?".ord))
      catch(:break__loop228) do
        begin
          case (_la(1))
          when Character.new(?\\.ord)
            m_action_esc(false)
          when Character.new(?\n.ord)
            match(Character.new(?\n.ord))
            if ((self.attr_input_state.attr_guessing).equal?(0))
              newline
            end
          else
            if ((_tokenSet_4.member(_la(1))))
              match_not(Character.new(?".ord))
            else
              throw :break__loop228, :thrown
            end
          end
        end while (true)
      end
      match(Character.new(?".ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_action_char_literal(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ACTION_CHAR_LITERAL
      _save_index = 0
      match(Character.new(?\'.ord))
      catch(:break__loop225) do
        begin
          case (_la(1))
          when Character.new(?\\.ord)
            m_action_esc(false)
          when Character.new(?\n.ord)
            match(Character.new(?\n.ord))
            if ((self.attr_input_state.attr_guessing).equal?(0))
              newline
            end
          else
            if ((_tokenSet_1.member(_la(1))))
              match_not(Character.new(?\'.ord))
            else
              throw :break__loop225, :thrown
            end
          end
        end while (true)
      end
      match(Character.new(?\'.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_action(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ACTION
      _save_index = 0
      action_line = get_line
      action_column = get_column
      m_nested_action(false)
      if (((_la(1)).equal?(Character.new(??.ord))))
        _save_index = self.attr_text.length
        match(Character.new(??.ord))
        self.attr_text.set_length(_save_index)
        if ((self.attr_input_state.attr_guessing).equal?(0))
          _ttype = SEMPRED
        end
      else
      end
      if ((self.attr_input_state.attr_guessing).equal?(0))
        t = make_token(_ttype)
        action = String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin)
        n = 1 # num delimiter chars
        if (action.starts_with("{{") && action.ends_with("}}"))
          t.set_type(FORCED_ACTION)
          n = 2
        end
        action = (action.substring(n, action.length - n)).to_s
        t.set_text(action)
        t.set_line(action_line) # set action line to start
        t.set_column(action_column)
        _token = t
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_nested_action(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = NESTED_ACTION
      _save_index = 0
      match(Character.new(?{.ord))
      begin
        # nongreedy exit test
        if (((_la(1)).equal?(Character.new(?}.ord))) && (true) && (true))
          break
        end
        if (((_la(1)).equal?(Character.new(?{.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff))))
          m_nested_action(false)
        else
          if (((_la(1)).equal?(Character.new(?\'.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff))))
            m_action_char_literal(false)
          else
            if (((_la(1)).equal?(Character.new(?/.ord))) && ((_la(2)).equal?(Character.new(?*.ord)) || (_la(2)).equal?(Character.new(?/.ord))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff))))
              m_comment(false)
            else
              if (((_la(1)).equal?(Character.new(?".ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff))))
                m_action_string_literal(false)
              else
                if (((_la(1)).equal?(Character.new(?\\.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && ((_la(3) >= Character.new(0x0003) && _la(3) <= Character.new(0x00ff))))
                  m_action_esc(false)
                else
                  if (((_la(1)).equal?(Character.new(?\n.ord)) || (_la(1)).equal?(Character.new(?\r.ord))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                    case (_la(1))
                    when Character.new(?\r.ord)
                      match(Character.new(?\r.ord))
                      match(Character.new(?\n.ord))
                      if ((self.attr_input_state.attr_guessing).equal?(0))
                        newline
                      end
                    when Character.new(?\n.ord)
                      match(Character.new(?\n.ord))
                      if ((self.attr_input_state.attr_guessing).equal?(0))
                        newline
                      end
                    else
                      raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
                    end
                  else
                    if (((_la(1) >= Character.new(0x0003) && _la(1) <= Character.new(0x00ff))) && ((_la(2) >= Character.new(0x0003) && _la(2) <= Character.new(0x00ff))) && (true))
                      match_not(EOF_CHAR)
                    else
                      break
                    end
                  end
                end
              end
            end
          end
        end
      end while (true)
      match(Character.new(?}.ord))
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_action_esc(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = ACTION_ESC
      _save_index = 0
      if (((_la(1)).equal?(Character.new(?\\.ord))) && ((_la(2)).equal?(Character.new(?\'.ord))))
        match("\\'")
      else
        if (((_la(1)).equal?(Character.new(?\\.ord))) && ((_la(2)).equal?(Character.new(?".ord))))
          match("\\\"")
        else
          if (((_la(1)).equal?(Character.new(?\\.ord))) && (_tokenSet_7.member(_la(2))))
            match(Character.new(?\\.ord))
            match(_tokenSet_7)
          else
            raise NoViableAltForCharException.new(RJava.cast_to_char(_la(1)), get_filename, get_line, get_column)
          end
        end
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_token_ref(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = TOKEN_REF
      _save_index = 0
      match_range(Character.new(?A.ord), Character.new(?Z.ord))
      catch(:break__loop233) do
        begin
          case (_la(1))
          when Character.new(?a.ord), Character.new(?b.ord), Character.new(?c.ord), Character.new(?d.ord), Character.new(?e.ord), Character.new(?f.ord), Character.new(?g.ord), Character.new(?h.ord), Character.new(?i.ord), Character.new(?j.ord), Character.new(?k.ord), Character.new(?l.ord), Character.new(?m.ord), Character.new(?n.ord), Character.new(?o.ord), Character.new(?p.ord), Character.new(?q.ord), Character.new(?r.ord), Character.new(?s.ord), Character.new(?t.ord), Character.new(?u.ord), Character.new(?v.ord), Character.new(?w.ord), Character.new(?x.ord), Character.new(?y.ord), Character.new(?z.ord)
            match_range(Character.new(?a.ord), Character.new(?z.ord))
          when Character.new(?A.ord), Character.new(?B.ord), Character.new(?C.ord), Character.new(?D.ord), Character.new(?E.ord), Character.new(?F.ord), Character.new(?G.ord), Character.new(?H.ord), Character.new(?I.ord), Character.new(?J.ord), Character.new(?K.ord), Character.new(?L.ord), Character.new(?M.ord), Character.new(?N.ord), Character.new(?O.ord), Character.new(?P.ord), Character.new(?Q.ord), Character.new(?R.ord), Character.new(?S.ord), Character.new(?T.ord), Character.new(?U.ord), Character.new(?V.ord), Character.new(?W.ord), Character.new(?X.ord), Character.new(?Y.ord), Character.new(?Z.ord)
            match_range(Character.new(?A.ord), Character.new(?Z.ord))
          when Character.new(?_.ord)
            match(Character.new(?_.ord))
          when Character.new(?0.ord), Character.new(?1.ord), Character.new(?2.ord), Character.new(?3.ord), Character.new(?4.ord), Character.new(?5.ord), Character.new(?6.ord), Character.new(?7.ord), Character.new(?8.ord), Character.new(?9.ord)
            match_range(Character.new(?0.ord), Character.new(?9.ord))
          else
            throw :break__loop233, :thrown
          end
        end while (true)
      end
      _ttype = test_literals_table(_ttype)
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_rule_ref(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = RULE_REF
      _save_index = 0
      t = 0
      t = m_internal_rule_ref(false)
      if ((self.attr_input_state.attr_guessing).equal?(0))
        _ttype = t
      end
      if ((true) && ((t).equal?(OPTIONS)))
        m_ws_loop(false)
        if (((_la(1)).equal?(Character.new(?{.ord))))
          match(Character.new(?{.ord))
          if ((self.attr_input_state.attr_guessing).equal?(0))
            _ttype = OPTIONS
          end
        else
        end
      else
        if ((true) && ((t).equal?(TOKENS)))
          m_ws_loop(false)
          if (((_la(1)).equal?(Character.new(?{.ord))))
            match(Character.new(?{.ord))
            if ((self.attr_input_state.attr_guessing).equal?(0))
              _ttype = TOKENS
            end
          else
          end
        else
        end
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_internal_rule_ref(_create_token)
      t = 0
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = INTERNAL_RULE_REF
      _save_index = 0
      t = RULE_REF
      match_range(Character.new(?a.ord), Character.new(?z.ord))
      catch(:break__loop243) do
        begin
          case (_la(1))
          when Character.new(?a.ord), Character.new(?b.ord), Character.new(?c.ord), Character.new(?d.ord), Character.new(?e.ord), Character.new(?f.ord), Character.new(?g.ord), Character.new(?h.ord), Character.new(?i.ord), Character.new(?j.ord), Character.new(?k.ord), Character.new(?l.ord), Character.new(?m.ord), Character.new(?n.ord), Character.new(?o.ord), Character.new(?p.ord), Character.new(?q.ord), Character.new(?r.ord), Character.new(?s.ord), Character.new(?t.ord), Character.new(?u.ord), Character.new(?v.ord), Character.new(?w.ord), Character.new(?x.ord), Character.new(?y.ord), Character.new(?z.ord)
            match_range(Character.new(?a.ord), Character.new(?z.ord))
          when Character.new(?A.ord), Character.new(?B.ord), Character.new(?C.ord), Character.new(?D.ord), Character.new(?E.ord), Character.new(?F.ord), Character.new(?G.ord), Character.new(?H.ord), Character.new(?I.ord), Character.new(?J.ord), Character.new(?K.ord), Character.new(?L.ord), Character.new(?M.ord), Character.new(?N.ord), Character.new(?O.ord), Character.new(?P.ord), Character.new(?Q.ord), Character.new(?R.ord), Character.new(?S.ord), Character.new(?T.ord), Character.new(?U.ord), Character.new(?V.ord), Character.new(?W.ord), Character.new(?X.ord), Character.new(?Y.ord), Character.new(?Z.ord)
            match_range(Character.new(?A.ord), Character.new(?Z.ord))
          when Character.new(?_.ord)
            match(Character.new(?_.ord))
          when Character.new(?0.ord), Character.new(?1.ord), Character.new(?2.ord), Character.new(?3.ord), Character.new(?4.ord), Character.new(?5.ord), Character.new(?6.ord), Character.new(?7.ord), Character.new(?8.ord), Character.new(?9.ord)
            match_range(Character.new(?0.ord), Character.new(?9.ord))
          else
            throw :break__loop243, :thrown
          end
        end while (true)
      end
      if ((self.attr_input_state.attr_guessing).equal?(0))
        t = test_literals_table(t)
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
      return t
    end
    
    typesig { [::Java::Boolean] }
    def m_ws_loop(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = WS_LOOP
      _save_index = 0
      catch(:break__loop240) do
        begin
          case (_la(1))
          when Character.new(?\t.ord), Character.new(?\n.ord), Character.new(?\r.ord), Character.new(?\s.ord)
            m_ws(false)
          when Character.new(?/.ord)
            m_comment(false)
          else
            throw :break__loop240, :thrown
          end
        end while (true)
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    typesig { [::Java::Boolean] }
    def m_ws_opt(_create_token)
      _ttype = 0
      _token = nil
      _begin = self.attr_text.length
      _ttype = WS_OPT
      _save_index = 0
      if ((_tokenSet_8.member(_la(1))))
        m_ws(false)
      else
      end
      if (_create_token && (_token).nil? && !(_ttype).equal?(Token::SKIP))
        _token = make_token(_ttype)
        _token.set_text(String.new(self.attr_text.get_buffer, _begin, self.attr_text.length - _begin))
      end
      self.attr__return_token = _token
    end
    
    class_module.module_eval {
      typesig { [] }
      def mk_token_set_0
        data = Array.typed(::Java::Long).new(8) { 0 }
        data[0] = -9224
        i = 1
        while i <= 3
          data[i] = -1
          i += 1
        end
        return data
      end
      
      const_set_lazy(:_tokenSet_0) { BitSet.new(mk_token_set_0) }
      const_attr_reader  :_tokenSet_0
      
      typesig { [] }
      def mk_token_set_1
        data = Array.typed(::Java::Long).new(8) { 0 }
        data[0] = -549755814920
        data[1] = -268435457
        i = 2
        while i <= 3
          data[i] = -1
          i += 1
        end
        return data
      end
      
      const_set_lazy(:_tokenSet_1) { BitSet.new(mk_token_set_1) }
      const_attr_reader  :_tokenSet_1
      
      typesig { [] }
      def mk_token_set_2
        data = Array.typed(::Java::Long).new([287948901175001088, 541165879422, 0, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_2) { BitSet.new(mk_token_set_2) }
      const_attr_reader  :_tokenSet_2
      
      typesig { [] }
      def mk_token_set_3
        data = Array.typed(::Java::Long).new(8) { 0 }
        data[0] = -17179869192
        i = 1
        while i <= 3
          data[i] = -1
          i += 1
        end
        return data
      end
      
      const_set_lazy(:_tokenSet_3) { BitSet.new(mk_token_set_3) }
      const_attr_reader  :_tokenSet_3
      
      typesig { [] }
      def mk_token_set_4
        data = Array.typed(::Java::Long).new(8) { 0 }
        data[0] = -17179870216
        data[1] = -268435457
        i = 2
        while i <= 3
          data[i] = -1
          i += 1
        end
        return data
      end
      
      const_set_lazy(:_tokenSet_4) { BitSet.new(mk_token_set_4) }
      const_attr_reader  :_tokenSet_4
      
      typesig { [] }
      def mk_token_set_5
        data = Array.typed(::Java::Long).new(8) { 0 }
        data[0] = -8
        data[1] = -536870913
        i = 2
        while i <= 3
          data[i] = -1
          i += 1
        end
        return data
      end
      
      const_set_lazy(:_tokenSet_5) { BitSet.new(mk_token_set_5) }
      const_attr_reader  :_tokenSet_5
      
      typesig { [] }
      def mk_token_set_6
        data = Array.typed(::Java::Long).new(8) { 0 }
        data[0] = -566935692296
        data[1] = -805306369
        i = 2
        while i <= 3
          data[i] = -1
          i += 1
        end
        return data
      end
      
      const_set_lazy(:_tokenSet_6) { BitSet.new(mk_token_set_6) }
      const_attr_reader  :_tokenSet_6
      
      typesig { [] }
      def mk_token_set_7
        data = Array.typed(::Java::Long).new(8) { 0 }
        data[0] = -566935683080
        i = 1
        while i <= 3
          data[i] = -1
          i += 1
        end
        return data
      end
      
      const_set_lazy(:_tokenSet_7) { BitSet.new(mk_token_set_7) }
      const_attr_reader  :_tokenSet_7
      
      typesig { [] }
      def mk_token_set_8
        data = Array.typed(::Java::Long).new([4294977024, 0, 0, 0, 0])
        return data
      end
      
      const_set_lazy(:_tokenSet_8) { BitSet.new(mk_token_set_8) }
      const_attr_reader  :_tokenSet_8
    }
    
    private
    alias_method :initialize__antlrlexer, :initialize
  end
  
end
