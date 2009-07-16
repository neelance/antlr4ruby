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
module Org::Antlr::Runtime::Debug
  module RemoteDebugEventSocketListenerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Debug
      include_const ::Org::Antlr::Runtime, :RecognitionException
      include_const ::Org::Antlr::Runtime, :Token
      include_const ::Org::Antlr::Runtime, :CharStream
      include_const ::Org::Antlr::Runtime::Tree, :BaseTree
      include_const ::Org::Antlr::Runtime::Tree, :Tree
      include ::Java::Io
      include_const ::Java::Net, :ConnectException
      include_const ::Java::Net, :Socket
      include_const ::Java::Util, :StringTokenizer
    }
  end
  
  class RemoteDebugEventSocketListener 
    include_class_members RemoteDebugEventSocketListenerImports
    include Runnable
    
    class_module.module_eval {
      const_set_lazy(:MAX_EVENT_ELEMENTS) { 8 }
      const_attr_reader  :MAX_EVENT_ELEMENTS
    }
    
    attr_accessor :listener
    alias_method :attr_listener, :listener
    undef_method :listener
    alias_method :attr_listener=, :listener=
    undef_method :listener=
    
    attr_accessor :machine
    alias_method :attr_machine, :machine
    undef_method :machine
    alias_method :attr_machine=, :machine=
    undef_method :machine=
    
    attr_accessor :port
    alias_method :attr_port, :port
    undef_method :port
    alias_method :attr_port=, :port=
    undef_method :port=
    
    attr_accessor :channel
    alias_method :attr_channel, :channel
    undef_method :channel
    alias_method :attr_channel=, :channel=
    undef_method :channel=
    
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
    
    attr_accessor :event
    alias_method :attr_event, :event
    undef_method :event
    alias_method :attr_event=, :event=
    undef_method :event=
    
    # Version of ANTLR (dictates events)
    attr_accessor :version
    alias_method :attr_version, :version
    undef_method :version
    alias_method :attr_version=, :version=
    undef_method :version=
    
    attr_accessor :grammar_file_name
    alias_method :attr_grammar_file_name, :grammar_file_name
    undef_method :grammar_file_name
    alias_method :attr_grammar_file_name=, :grammar_file_name=
    undef_method :grammar_file_name=
    
    # Track the last token index we saw during a consume.  If same, then
    # set a flag that we have a problem.
    attr_accessor :previous_token_index
    alias_method :attr_previous_token_index, :previous_token_index
    undef_method :previous_token_index
    alias_method :attr_previous_token_index=, :previous_token_index=
    undef_method :previous_token_index=
    
    attr_accessor :token_indexes_invalid
    alias_method :attr_token_indexes_invalid, :token_indexes_invalid
    undef_method :token_indexes_invalid
    alias_method :attr_token_indexes_invalid=, :token_indexes_invalid=
    undef_method :token_indexes_invalid=
    
    class_module.module_eval {
      const_set_lazy(:ProxyToken) { Class.new do
        include_class_members RemoteDebugEventSocketListener
        include Token
        
        attr_accessor :index
        alias_method :attr_index, :index
        undef_method :index
        alias_method :attr_index=, :index=
        undef_method :index=
        
        attr_accessor :type
        alias_method :attr_type, :type
        undef_method :type
        alias_method :attr_type=, :type=
        undef_method :type=
        
        attr_accessor :channel
        alias_method :attr_channel, :channel
        undef_method :channel
        alias_method :attr_channel=, :channel=
        undef_method :channel=
        
        attr_accessor :line
        alias_method :attr_line, :line
        undef_method :line
        alias_method :attr_line=, :line=
        undef_method :line=
        
        attr_accessor :char_pos
        alias_method :attr_char_pos, :char_pos
        undef_method :char_pos
        alias_method :attr_char_pos=, :char_pos=
        undef_method :char_pos=
        
        attr_accessor :text
        alias_method :attr_text, :text
        undef_method :text
        alias_method :attr_text=, :text=
        undef_method :text=
        
        typesig { [::Java::Int] }
        def initialize(index)
          @index = 0
          @type = 0
          @channel = 0
          @line = 0
          @char_pos = 0
          @text = nil
          @index = index
        end
        
        typesig { [::Java::Int, ::Java::Int, ::Java::Int, ::Java::Int, ::Java::Int, String] }
        def initialize(index, type, channel, line, char_pos, text)
          @index = 0
          @type = 0
          @channel = 0
          @line = 0
          @char_pos = 0
          @text = nil
          @index = index
          @type = type
          @channel = channel
          @line = line
          @char_pos = char_pos
          @text = text
        end
        
        typesig { [] }
        def get_text
          return @text
        end
        
        typesig { [String] }
        def set_text(text)
          @text = text
        end
        
        typesig { [] }
        def get_type
          return @type
        end
        
        typesig { [::Java::Int] }
        def set_type(ttype)
          @type = ttype
        end
        
        typesig { [] }
        def get_line
          return @line
        end
        
        typesig { [::Java::Int] }
        def set_line(line)
          @line = line
        end
        
        typesig { [] }
        def get_char_position_in_line
          return @char_pos
        end
        
        typesig { [::Java::Int] }
        def set_char_position_in_line(pos)
          @char_pos = pos
        end
        
        typesig { [] }
        def get_channel
          return @channel
        end
        
        typesig { [::Java::Int] }
        def set_channel(channel)
          @channel = channel
        end
        
        typesig { [] }
        def get_token_index
          return @index
        end
        
        typesig { [::Java::Int] }
        def set_token_index(index)
          @index = index
        end
        
        typesig { [] }
        def get_input_stream
          return nil
        end
        
        typesig { [CharStream] }
        def set_input_stream(input)
        end
        
        typesig { [] }
        def to_s
          channel_str = ""
          if (!(@channel).equal?(Token::DEFAULT_CHANNEL))
            channel_str = ",channel=" + (@channel).to_s
          end
          return "[" + (get_text).to_s + "/<" + (@type).to_s + ">" + channel_str + "," + (@line).to_s + ":" + (get_char_position_in_line).to_s + ",@" + (@index).to_s + "]"
        end
        
        private
        alias_method :initialize__proxy_token, :initialize
      end }
      
      const_set_lazy(:ProxyTree) { Class.new(BaseTree) do
        include_class_members RemoteDebugEventSocketListener
        
        attr_accessor :id
        alias_method :attr_id, :id
        undef_method :id
        alias_method :attr_id=, :id=
        undef_method :id=
        
        attr_accessor :type
        alias_method :attr_type, :type
        undef_method :type
        alias_method :attr_type=, :type=
        undef_method :type=
        
        attr_accessor :line
        alias_method :attr_line, :line
        undef_method :line
        alias_method :attr_line=, :line=
        undef_method :line=
        
        attr_accessor :char_pos
        alias_method :attr_char_pos, :char_pos
        undef_method :char_pos
        alias_method :attr_char_pos=, :char_pos=
        undef_method :char_pos=
        
        attr_accessor :token_index
        alias_method :attr_token_index, :token_index
        undef_method :token_index
        alias_method :attr_token_index=, :token_index=
        undef_method :token_index=
        
        attr_accessor :text
        alias_method :attr_text, :text
        undef_method :text
        alias_method :attr_text=, :text=
        undef_method :text=
        
        typesig { [::Java::Int, ::Java::Int, ::Java::Int, ::Java::Int, ::Java::Int, String] }
        def initialize(id, type, line, char_pos, token_index, text)
          @id = 0
          @type = 0
          @line = 0
          @char_pos = 0
          @token_index = 0
          @text = nil
          super()
          @line = 0
          @char_pos = -1
          @token_index = -1
          @id = id
          @type = type
          @line = line
          @char_pos = char_pos
          @token_index = token_index
          @text = text
        end
        
        typesig { [::Java::Int] }
        def initialize(id)
          @id = 0
          @type = 0
          @line = 0
          @char_pos = 0
          @token_index = 0
          @text = nil
          super()
          @line = 0
          @char_pos = -1
          @token_index = -1
          @id = id
        end
        
        typesig { [] }
        def get_token_start_index
          return @token_index
        end
        
        typesig { [::Java::Int] }
        def set_token_start_index(index)
        end
        
        typesig { [] }
        def get_token_stop_index
          return 0
        end
        
        typesig { [::Java::Int] }
        def set_token_stop_index(index)
        end
        
        typesig { [] }
        def dup_node
          return nil
        end
        
        typesig { [] }
        def get_type
          return @type
        end
        
        typesig { [] }
        def get_text
          return @text
        end
        
        typesig { [] }
        def to_s
          return "fix this"
        end
        
        private
        alias_method :initialize__proxy_tree, :initialize
      end }
    }
    
    typesig { [DebugEventListener, String, ::Java::Int] }
    def initialize(listener, machine, port)
      @listener = nil
      @machine = nil
      @port = 0
      @channel = nil
      @out = nil
      @in = nil
      @event = nil
      @version = nil
      @grammar_file_name = nil
      @previous_token_index = -1
      @token_indexes_invalid = false
      @listener = listener
      @machine = machine
      @port = port
      if (!open_connection)
        raise ConnectException.new
      end
    end
    
    typesig { [] }
    def event_handler
      begin
        handshake
        @event = (@in.read_line).to_s
        while (!(@event).nil?)
          dispatch(@event)
          ack
          @event = (@in.read_line).to_s
        end
      rescue Exception => e
        System.err.println(e)
        e.print_stack_trace(System.err)
      ensure
        close_connection
      end
    end
    
    typesig { [] }
    def open_connection
      success = false
      begin
        @channel = Socket.new(@machine, @port)
        @channel.set_tcp_no_delay(true)
        os = @channel.get_output_stream
        osw = OutputStreamWriter.new(os, "UTF8")
        @out = PrintWriter.new(BufferedWriter.new(osw))
        is = @channel.get_input_stream
        isr = InputStreamReader.new(is, "UTF8")
        @in = BufferedReader.new(isr)
        success = true
      rescue Exception => e
        System.err.println(e)
      end
      return success
    end
    
    typesig { [] }
    def close_connection
      begin
        @in.close
        @in = nil
        @out.close
        @out = nil
        @channel.close
        @channel = nil
      rescue Exception => e
        System.err.println(e)
        e.print_stack_trace(System.err)
      ensure
        if (!(@in).nil?)
          begin
            @in.close
          rescue IOException => ioe
            System.err.println(ioe)
          end
        end
        if (!(@out).nil?)
          @out.close
        end
        if (!(@channel).nil?)
          begin
            @channel.close
          rescue IOException => ioe
            System.err.println(ioe_)
          end
        end
      end
    end
    
    typesig { [] }
    def handshake
      antlr_line = @in.read_line
      antlr_elements = get_event_elements(antlr_line)
      @version = (antlr_elements[1]).to_s
      grammar_line = @in.read_line
      grammar_elements = get_event_elements(grammar_line)
      @grammar_file_name = (grammar_elements[1]).to_s
      ack
      @listener.commence # inform listener after handshake
    end
    
    typesig { [] }
    def ack
      @out.println("ack")
      @out.flush
    end
    
    typesig { [String] }
    def dispatch(line)
      elements = get_event_elements(line)
      if ((elements).nil? || (elements[0]).nil?)
        System.err.println("unknown debug event: " + line)
        return
      end
      if ((elements[0] == "enterRule"))
        @listener.enter_rule(elements[1], elements[2])
      else
        if ((elements[0] == "exitRule"))
          @listener.exit_rule(elements[1], elements[2])
        else
          if ((elements[0] == "enterAlt"))
            @listener.enter_alt(JavaInteger.parse_int(elements[1]))
          else
            if ((elements[0] == "enterSubRule"))
              @listener.enter_sub_rule(JavaInteger.parse_int(elements[1]))
            else
              if ((elements[0] == "exitSubRule"))
                @listener.exit_sub_rule(JavaInteger.parse_int(elements[1]))
              else
                if ((elements[0] == "enterDecision"))
                  @listener.enter_decision(JavaInteger.parse_int(elements[1]))
                else
                  if ((elements[0] == "exitDecision"))
                    @listener.exit_decision(JavaInteger.parse_int(elements[1]))
                  else
                    if ((elements[0] == "location"))
                      @listener.location(JavaInteger.parse_int(elements[1]), JavaInteger.parse_int(elements[2]))
                    else
                      if ((elements[0] == "consumeToken"))
                        t = deserialize_token(elements, 1)
                        if ((t.get_token_index).equal?(@previous_token_index))
                          @token_indexes_invalid = true
                        end
                        @previous_token_index = t.get_token_index
                        @listener.consume_token(t)
                      else
                        if ((elements[0] == "consumeHiddenToken"))
                          t_ = deserialize_token(elements, 1)
                          if ((t_.get_token_index).equal?(@previous_token_index))
                            @token_indexes_invalid = true
                          end
                          @previous_token_index = t_.get_token_index
                          @listener.consume_hidden_token(t_)
                        else
                          if ((elements[0] == "LT"))
                            t__ = deserialize_token(elements, 2)
                            @listener._lt(JavaInteger.parse_int(elements[1]), t__)
                          else
                            if ((elements[0] == "mark"))
                              @listener.mark(JavaInteger.parse_int(elements[1]))
                            else
                              if ((elements[0] == "rewind"))
                                if (!(elements[1]).nil?)
                                  @listener.rewind(JavaInteger.parse_int(elements[1]))
                                else
                                  @listener.rewind
                                end
                              else
                                if ((elements[0] == "beginBacktrack"))
                                  @listener.begin_backtrack(JavaInteger.parse_int(elements[1]))
                                else
                                  if ((elements[0] == "endBacktrack"))
                                    level = JavaInteger.parse_int(elements[1])
                                    success_i = JavaInteger.parse_int(elements[2])
                                    @listener.end_backtrack(level, (success_i).equal?(DebugEventListener::TRUE))
                                  else
                                    if ((elements[0] == "exception"))
                                      exc_name = elements[1]
                                      index_s = elements[2]
                                      line_s = elements[3]
                                      pos_s = elements[4]
                                      exc_class = nil
                                      begin
                                        exc_class = Class.for_name(exc_name)
                                        e = exc_class.new_instance
                                        e.attr_index = JavaInteger.parse_int(index_s)
                                        e.attr_line = JavaInteger.parse_int(line_s)
                                        e.attr_char_position_in_line = JavaInteger.parse_int(pos_s)
                                        @listener.recognition_exception(e)
                                      rescue ClassNotFoundException => cnfe
                                        System.err.println("can't find class " + (cnfe).to_s)
                                        cnfe.print_stack_trace(System.err)
                                      rescue InstantiationException => ie
                                        System.err.println("can't instantiate class " + (ie).to_s)
                                        ie.print_stack_trace(System.err)
                                      rescue IllegalAccessException => iae
                                        System.err.println("can't access class " + (iae).to_s)
                                        iae.print_stack_trace(System.err)
                                      end
                                    else
                                      if ((elements[0] == "beginResync"))
                                        @listener.begin_resync
                                      else
                                        if ((elements[0] == "endResync"))
                                          @listener.end_resync
                                        else
                                          if ((elements[0] == "terminate"))
                                            @listener.terminate
                                          else
                                            if ((elements[0] == "semanticPredicate"))
                                              result = Boolean.value_of(elements[1])
                                              predicate_text = elements[2]
                                              predicate_text = (un_escape_newlines(predicate_text)).to_s
                                              @listener.semantic_predicate(result.boolean_value, predicate_text)
                                            else
                                              if ((elements[0] == "consumeNode"))
                                                node = deserialize_node(elements, 1)
                                                @listener.consume_node(node)
                                              else
                                                if ((elements[0] == "LN"))
                                                  i = JavaInteger.parse_int(elements[1])
                                                  node_ = deserialize_node(elements, 2)
                                                  @listener._lt(i, node_)
                                                else
                                                  if ((elements[0] == "createNodeFromTokenElements"))
                                                    id = JavaInteger.parse_int(elements[1])
                                                    type = JavaInteger.parse_int(elements[2])
                                                    text = elements[3]
                                                    text = (un_escape_newlines(text)).to_s
                                                    node__ = ProxyTree.new(id, type, -1, -1, -1, text)
                                                    @listener.create_node(node__)
                                                  else
                                                    if ((elements[0] == "createNode"))
                                                      id_ = JavaInteger.parse_int(elements[1])
                                                      token_index = JavaInteger.parse_int(elements[2])
                                                      # create dummy node/token filled with ID, tokenIndex
                                                      node___ = ProxyTree.new(id_)
                                                      token = ProxyToken.new(token_index)
                                                      @listener.create_node(node___, token)
                                                    else
                                                      if ((elements[0] == "nilNode"))
                                                        id__ = JavaInteger.parse_int(elements[1])
                                                        node____ = ProxyTree.new(id__)
                                                        @listener.nil_node(node____)
                                                      else
                                                        if ((elements[0] == "errorNode"))
                                                          # TODO: do we need a special tree here?
                                                          id___ = JavaInteger.parse_int(elements[1])
                                                          type_ = JavaInteger.parse_int(elements[2])
                                                          text_ = elements[3]
                                                          text_ = (un_escape_newlines(text_)).to_s
                                                          node_____ = ProxyTree.new(id___, type_, -1, -1, -1, text_)
                                                          @listener.error_node(node_____)
                                                        else
                                                          if ((elements[0] == "becomeRoot"))
                                                            new_root_id = JavaInteger.parse_int(elements[1])
                                                            old_root_id = JavaInteger.parse_int(elements[2])
                                                            new_root = ProxyTree.new(new_root_id)
                                                            old_root = ProxyTree.new(old_root_id)
                                                            @listener.become_root(new_root, old_root)
                                                          else
                                                            if ((elements[0] == "addChild"))
                                                              root_id = JavaInteger.parse_int(elements[1])
                                                              child_id = JavaInteger.parse_int(elements[2])
                                                              root = ProxyTree.new(root_id)
                                                              child = ProxyTree.new(child_id)
                                                              @listener.add_child(root, child)
                                                            else
                                                              if ((elements[0] == "setTokenBoundaries"))
                                                                id____ = JavaInteger.parse_int(elements[1])
                                                                node______ = ProxyTree.new(id____)
                                                                @listener.set_token_boundaries(node______, JavaInteger.parse_int(elements[2]), JavaInteger.parse_int(elements[3]))
                                                              else
                                                                System.err.println("unknown debug event: " + line)
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
          end
        end
      end
    end
    
    typesig { [Array.typed(String), ::Java::Int] }
    def deserialize_node(elements, offset)
      id = JavaInteger.parse_int(elements[offset + 0])
      type = JavaInteger.parse_int(elements[offset + 1])
      token_line = JavaInteger.parse_int(elements[offset + 2])
      char_position_in_line = JavaInteger.parse_int(elements[offset + 3])
      token_index = JavaInteger.parse_int(elements[offset + 4])
      text = elements[offset + 5]
      text = (un_escape_newlines(text)).to_s
      return ProxyTree.new(id, type, token_line, char_position_in_line, token_index, text)
    end
    
    typesig { [Array.typed(String), ::Java::Int] }
    def deserialize_token(elements, offset)
      index_s = elements[offset + 0]
      type_s = elements[offset + 1]
      channel_s = elements[offset + 2]
      line_s = elements[offset + 3]
      pos_s = elements[offset + 4]
      text = elements[offset + 5]
      text = (un_escape_newlines(text)).to_s
      index = JavaInteger.parse_int(index_s)
      t = ProxyToken.new(index, JavaInteger.parse_int(type_s), JavaInteger.parse_int(channel_s), JavaInteger.parse_int(line_s), JavaInteger.parse_int(pos_s), text)
      return t
    end
    
    typesig { [] }
    # Create a thread to listen to the remote running recognizer
    def start
      t = JavaThread.new(self)
      t.start
    end
    
    typesig { [] }
    def run
      event_handler
    end
    
    typesig { [String] }
    # M i s c
    def get_event_elements(event)
      if ((event).nil?)
        return nil
      end
      elements = Array.typed(String).new(MAX_EVENT_ELEMENTS) { nil }
      str = nil # a string element if present (must be last)
      begin
        first_quote_index = event.index_of(Character.new(?".ord))
        if (first_quote_index >= 0)
          # treat specially; has a string argument like "a comment\n
          # Note that the string is terminated by \n not end quote.
          # Easier to parse that way.
          event_without_string = event.substring(0, first_quote_index)
          str = (event.substring(first_quote_index + 1, event.length)).to_s
          event = event_without_string
        end
        st = StringTokenizer.new(event, " \t", false)
        i = 0
        while (st.has_more_tokens)
          if (i >= MAX_EVENT_ELEMENTS)
            # ErrorManager.internalError("event has more than "+MAX_EVENT_ELEMENTS+" args: "+event);
            return elements
          end
          elements[i] = st.next_token
          ((i += 1) - 1)
        end
        if (!(str).nil?)
          elements[i] = str
        end
      rescue Exception => e
        e.print_stack_trace(System.err)
      end
      return elements
    end
    
    typesig { [String] }
    def un_escape_newlines(txt)
      # this unescape is slow but easy to understand
      txt = (txt.replace_all("%0A", "\n")).to_s # unescape \n
      txt = (txt.replace_all("%0D", "\r")).to_s # unescape \r
      txt = (txt.replace_all("%25", "%")).to_s # undo escaped escape chars
      return txt
    end
    
    typesig { [] }
    def token_indexes_are_invalid
      return false
      # return tokenIndexesInvalid;
    end
    
    private
    alias_method :initialize__remote_debug_event_socket_listener, :initialize
  end
  
end
