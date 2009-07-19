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
module Org::Antlr::Runtime::Debug
  module DebugEventSocketProxyImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :RecognitionException
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :BaseRecognizer
      include_const ::Org::Antlr::Runtime::Tree, :TreeAdaptor
      include ::Java::Io
      include_const ::Java::Net, :ServerSocket
      include_const ::Java::Net, :Socket
    }
  end
  
  # A proxy debug event listener that forwards events over a socket to
  # a debugger (or any other listener) using a simple text-based protocol;
  # one event per line.  ANTLRWorks listens on server socket with a
  # RemoteDebugEventSocketListener instance.  These two objects must therefore
  # be kept in sync.  New events must be handled on both sides of socket.
  class DebugEventSocketProxy < DebugEventSocketProxyImports.const_get :BlankDebugEventListener
    include_class_members DebugEventSocketProxyImports
    
    class_module.module_eval {
      const_set_lazy(:DEFAULT_DEBUGGER_PORT) { 0xc001 }
      const_attr_reader  :DEFAULT_DEBUGGER_PORT
    }
    
    attr_accessor :port
    alias_method :attr_port, :port
    undef_method :port
    alias_method :attr_port=, :port=
    undef_method :port=
    
    attr_accessor :server_socket
    alias_method :attr_server_socket, :server_socket
    undef_method :server_socket
    alias_method :attr_server_socket=, :server_socket=
    undef_method :server_socket=
    
    attr_accessor :socket
    alias_method :attr_socket, :socket
    undef_method :socket
    alias_method :attr_socket=, :socket=
    undef_method :socket=
    
    attr_accessor :grammar_file_name
    alias_method :attr_grammar_file_name, :grammar_file_name
    undef_method :grammar_file_name
    alias_method :attr_grammar_file_name=, :grammar_file_name=
    undef_method :grammar_file_name=
    
    attr_accessor :out
    alias_method :attr_out, :out
    undef_method :out
    alias_method :attr_out=, :out=
    undef_method :out=
    
    attr_accessor :in
    alias_method :attr_in, :in
    undef_method :in
    alias_method :attr_in=, :in=
    undef_method :in=
    
    # Who am i debugging?
    attr_accessor :recognizer
    alias_method :attr_recognizer, :recognizer
    undef_method :recognizer
    alias_method :attr_recognizer=, :recognizer=
    undef_method :recognizer=
    
    # Almost certainly the recognizer will have adaptor set, but
    # we don't know how to cast it (Parser or TreeParser) to get
    # the adaptor field.  Must be set with a constructor. :(
    attr_accessor :adaptor
    alias_method :attr_adaptor, :adaptor
    undef_method :adaptor
    alias_method :attr_adaptor=, :adaptor=
    undef_method :adaptor=
    
    typesig { [BaseRecognizer, TreeAdaptor] }
    def initialize(recognizer, adaptor)
      initialize__debug_event_socket_proxy(recognizer, DEFAULT_DEBUGGER_PORT, adaptor)
    end
    
    typesig { [BaseRecognizer, ::Java::Int, TreeAdaptor] }
    def initialize(recognizer, port, adaptor)
      @port = 0
      @server_socket = nil
      @socket = nil
      @grammar_file_name = nil
      @out = nil
      @in = nil
      @recognizer = nil
      @adaptor = nil
      super()
      @port = DEFAULT_DEBUGGER_PORT
      @grammar_file_name = recognizer.get_grammar_file_name
      @adaptor = adaptor
      @port = port
    end
    
    typesig { [] }
    def handshake
      if ((@server_socket).nil?)
        @server_socket = ServerSocket.new(@port)
        @socket = @server_socket.accept
        @socket.set_tcp_no_delay(true)
        os = @socket.get_output_stream
        osw = OutputStreamWriter.new(os, "UTF8")
        @out = PrintWriter.new(BufferedWriter.new(osw))
        is = @socket.get_input_stream
        isr = InputStreamReader.new(is, "UTF8")
        @in = BufferedReader.new(isr)
        @out.println("ANTLR " + (DebugEventListener::PROTOCOL_VERSION).to_s)
        @out.println("grammar \"" + @grammar_file_name)
        @out.flush
        ack
      end
    end
    
    typesig { [] }
    def commence
      # don't bother sending event; listener will trigger upon connection
    end
    
    typesig { [] }
    def terminate
      transmit("terminate")
      @out.close
      begin
        @socket.close
      rescue IOException => ioe
        ioe.print_stack_trace(System.err)
      end
    end
    
    typesig { [] }
    def ack
      begin
        @in.read_line
      rescue IOException => ioe
        ioe.print_stack_trace(System.err)
      end
    end
    
    typesig { [String] }
    def transmit(event)
      @out.println(event)
      @out.flush
      ack
    end
    
    typesig { [String, String] }
    def enter_rule(grammar_file_name, rule_name)
      transmit("enterRule " + grammar_file_name + " " + rule_name)
    end
    
    typesig { [::Java::Int] }
    def enter_alt(alt)
      transmit("enterAlt " + (alt).to_s)
    end
    
    typesig { [String, String] }
    def exit_rule(grammar_file_name, rule_name)
      transmit("exitRule " + grammar_file_name + " " + rule_name)
    end
    
    typesig { [::Java::Int] }
    def enter_sub_rule(decision_number)
      transmit("enterSubRule " + (decision_number).to_s)
    end
    
    typesig { [::Java::Int] }
    def exit_sub_rule(decision_number)
      transmit("exitSubRule " + (decision_number).to_s)
    end
    
    typesig { [::Java::Int] }
    def enter_decision(decision_number)
      transmit("enterDecision " + (decision_number).to_s)
    end
    
    typesig { [::Java::Int] }
    def exit_decision(decision_number)
      transmit("exitDecision " + (decision_number).to_s)
    end
    
    typesig { [Token] }
    def consume_token(t)
      buf = serialize_token(t)
      transmit("consumeToken " + buf)
    end
    
    typesig { [Token] }
    def consume_hidden_token(t)
      buf = serialize_token(t)
      transmit("consumeHiddenToken " + buf)
    end
    
    typesig { [::Java::Int, Token] }
    def _lt(i, t)
      if (!(t).nil?)
        transmit("LT " + (i).to_s + " " + (serialize_token(t)).to_s)
      end
    end
    
    typesig { [::Java::Int] }
    def mark(i)
      transmit("mark " + (i).to_s)
    end
    
    typesig { [::Java::Int] }
    def rewind(i)
      transmit("rewind " + (i).to_s)
    end
    
    typesig { [] }
    def rewind
      transmit("rewind")
    end
    
    typesig { [::Java::Int] }
    def begin_backtrack(level)
      transmit("beginBacktrack " + (level).to_s)
    end
    
    typesig { [::Java::Int, ::Java::Boolean] }
    def end_backtrack(level, successful)
      transmit("endBacktrack " + (level).to_s + " " + ((successful ? TRUE : FALSE)).to_s)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def location(line, pos)
      transmit("location " + (line).to_s + " " + (pos).to_s)
    end
    
    typesig { [RecognitionException] }
    def recognition_exception(e)
      buf = StringBuffer.new(50)
      buf.append("exception ")
      buf.append(e.get_class.get_name)
      # dump only the data common to all exceptions for now
      buf.append(" ")
      buf.append(e.attr_index)
      buf.append(" ")
      buf.append(e.attr_line)
      buf.append(" ")
      buf.append(e.attr_char_position_in_line)
      transmit(buf.to_s)
    end
    
    typesig { [] }
    def begin_resync
      transmit("beginResync")
    end
    
    typesig { [] }
    def end_resync
      transmit("endResync")
    end
    
    typesig { [::Java::Boolean, String] }
    def semantic_predicate(result, predicate)
      buf = StringBuffer.new(50)
      buf.append("semanticPredicate ")
      buf.append(result)
      serialize_text(buf, predicate)
      transmit(buf.to_s)
    end
    
    typesig { [Object] }
    # A S T  P a r s i n g  E v e n t s
    def consume_node(t)
      buf = StringBuffer.new(50)
      buf.append("consumeNode")
      serialize_node(buf, t)
      transmit(buf.to_s)
    end
    
    typesig { [::Java::Int, Object] }
    def _lt(i, t)
      id = @adaptor.get_unique_id(t)
      text = @adaptor.get_text(t)
      type = @adaptor.get_type(t)
      buf = StringBuffer.new(50)
      buf.append("LN ") # lookahead node; distinguish from LT in protocol
      buf.append(i)
      serialize_node(buf, t)
      transmit(buf.to_s)
    end
    
    typesig { [StringBuffer, Object] }
    def serialize_node(buf, t)
      id = @adaptor.get_unique_id(t)
      text = @adaptor.get_text(t)
      type = @adaptor.get_type(t)
      buf.append(" ")
      buf.append(id)
      buf.append(" ")
      buf.append(type)
      token = @adaptor.get_token(t)
      line = -1
      pos = -1
      if (!(token).nil?)
        line = token.get_line
        pos = token.get_char_position_in_line
      end
      buf.append(" ")
      buf.append(line)
      buf.append(" ")
      buf.append(pos)
      token_index = @adaptor.get_token_start_index(t)
      buf.append(" ")
      buf.append(token_index)
      serialize_text(buf, text)
    end
    
    typesig { [Object] }
    # A S T  E v e n t s
    def nil_node(t)
      id = @adaptor.get_unique_id(t)
      transmit("nilNode " + (id).to_s)
    end
    
    typesig { [Object] }
    def error_node(t)
      id = @adaptor.get_unique_id(t)
      text = t.to_s
      buf = StringBuffer.new(50)
      buf.append("errorNode ")
      buf.append(id)
      buf.append(" ")
      buf.append(Token::INVALID_TOKEN_TYPE)
      serialize_text(buf, text)
      transmit(buf.to_s)
    end
    
    typesig { [Object] }
    def create_node(t)
      id = @adaptor.get_unique_id(t)
      text = @adaptor.get_text(t)
      type = @adaptor.get_type(t)
      buf = StringBuffer.new(50)
      buf.append("createNodeFromTokenElements ")
      buf.append(id)
      buf.append(" ")
      buf.append(type)
      serialize_text(buf, text)
      transmit(buf.to_s)
    end
    
    typesig { [Object, Token] }
    def create_node(node, token)
      id = @adaptor.get_unique_id(node)
      token_index = token.get_token_index
      transmit("createNode " + (id).to_s + " " + (token_index).to_s)
    end
    
    typesig { [Object, Object] }
    def become_root(new_root, old_root)
      new_root_id = @adaptor.get_unique_id(new_root)
      old_root_id = @adaptor.get_unique_id(old_root)
      transmit("becomeRoot " + (new_root_id).to_s + " " + (old_root_id).to_s)
    end
    
    typesig { [Object, Object] }
    def add_child(root, child)
      root_id = @adaptor.get_unique_id(root)
      child_id = @adaptor.get_unique_id(child)
      transmit("addChild " + (root_id).to_s + " " + (child_id).to_s)
    end
    
    typesig { [Object, ::Java::Int, ::Java::Int] }
    def set_token_boundaries(t, token_start_index, token_stop_index)
      id = @adaptor.get_unique_id(t)
      transmit("setTokenBoundaries " + (id).to_s + " " + (token_start_index).to_s + " " + (token_stop_index).to_s)
    end
    
    typesig { [TreeAdaptor] }
    # support
    def set_tree_adaptor(adaptor)
      @adaptor = adaptor
    end
    
    typesig { [] }
    def get_tree_adaptor
      return @adaptor
    end
    
    typesig { [Token] }
    def serialize_token(t)
      buf = StringBuffer.new(50)
      buf.append(t.get_token_index)
      buf.append(Character.new(?\s.ord))
      buf.append(t.get_type)
      buf.append(Character.new(?\s.ord))
      buf.append(t.get_channel)
      buf.append(Character.new(?\s.ord))
      buf.append(t.get_line)
      buf.append(Character.new(?\s.ord))
      buf.append(t.get_char_position_in_line)
      serialize_text(buf, t.get_text)
      return buf.to_s
    end
    
    typesig { [StringBuffer, String] }
    def serialize_text(buf, text)
      buf.append(" \"")
      if ((text).nil?)
        text = ""
      end
      # escape \n and \r all text for token appears to exist on one line
      # this escape is slow but easy to understand
      text = (escape_newlines(text)).to_s
      buf.append(text)
    end
    
    typesig { [String] }
    def escape_newlines(txt)
      txt = (txt.replace_all("%", "%25")).to_s # escape all escape char ;)
      txt = (txt.replace_all("\n", "%0A")).to_s # escape \n
      txt = (txt.replace_all("\r", "%0D")).to_s # escape \r
      return txt
    end
    
    private
    alias_method :initialize__debug_event_socket_proxy, :initialize
  end
  
end
