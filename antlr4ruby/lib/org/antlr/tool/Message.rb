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
  module MessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
    }
  end
  
  # The ANTLR code calls methods on ErrorManager to report errors etc...
  # Rather than simply pass these arguments to the ANTLRErrorListener directly,
  # create an object that encapsulates everything.  In this way, the error
  # listener interface does not have to change when I add a new kind of
  # error message.  I don't want to break a GUI for example every time
  # I update the error system in ANTLR itself.
  # 
  # To get a printable error/warning message, call toString().
  class Message 
    include_class_members MessageImports
    
    # msgST is the actual text of the message
    attr_accessor :msg_st
    alias_method :attr_msg_st, :msg_st
    undef_method :msg_st
    alias_method :attr_msg_st=, :msg_st=
    undef_method :msg_st=
    
    # these are for supporting different output formats
    attr_accessor :location_st
    alias_method :attr_location_st, :location_st
    undef_method :location_st
    alias_method :attr_location_st=, :location_st=
    undef_method :location_st=
    
    attr_accessor :report_st
    alias_method :attr_report_st, :report_st
    undef_method :report_st
    alias_method :attr_report_st=, :report_st=
    undef_method :report_st=
    
    attr_accessor :message_format_st
    alias_method :attr_message_format_st, :message_format_st
    undef_method :message_format_st
    alias_method :attr_message_format_st=, :message_format_st=
    undef_method :message_format_st=
    
    attr_accessor :msg_id
    alias_method :attr_msg_id, :msg_id
    undef_method :msg_id
    alias_method :attr_msg_id=, :msg_id=
    undef_method :msg_id=
    
    attr_accessor :arg
    alias_method :attr_arg, :arg
    undef_method :arg
    alias_method :attr_arg=, :arg=
    undef_method :arg=
    
    attr_accessor :arg2
    alias_method :attr_arg2, :arg2
    undef_method :arg2
    alias_method :attr_arg2=, :arg2=
    undef_method :arg2=
    
    attr_accessor :e
    alias_method :attr_e, :e
    undef_method :e
    alias_method :attr_e=, :e=
    undef_method :e=
    
    # used for location template
    attr_accessor :file
    alias_method :attr_file, :file
    undef_method :file
    alias_method :attr_file=, :file=
    undef_method :file=
    
    attr_accessor :line
    alias_method :attr_line, :line
    undef_method :line
    alias_method :attr_line=, :line=
    undef_method :line=
    
    attr_accessor :column
    alias_method :attr_column, :column
    undef_method :column
    alias_method :attr_column=, :column=
    undef_method :column=
    
    typesig { [] }
    def initialize
      @msg_st = nil
      @location_st = nil
      @report_st = nil
      @message_format_st = nil
      @msg_id = 0
      @arg = nil
      @arg2 = nil
      @e = nil
      @file = nil
      @line = -1
      @column = -1
    end
    
    typesig { [::Java::Int] }
    def initialize(msg_id)
      initialize__message(msg_id, nil, nil)
    end
    
    typesig { [::Java::Int, Object, Object] }
    def initialize(msg_id, arg, arg2)
      @msg_st = nil
      @location_st = nil
      @report_st = nil
      @message_format_st = nil
      @msg_id = 0
      @arg = nil
      @arg2 = nil
      @e = nil
      @file = nil
      @line = -1
      @column = -1
      set_message_id(msg_id)
      @arg = arg
      @arg2 = arg2
    end
    
    typesig { [::Java::Int] }
    def set_line(line)
      @line = line
    end
    
    typesig { [::Java::Int] }
    def set_column(column)
      @column = column
    end
    
    typesig { [::Java::Int] }
    def set_message_id(msg_id)
      @msg_id = msg_id
      @msg_st = ErrorManager.get_message(msg_id)
    end
    
    typesig { [] }
    # Return a new template instance every time someone tries to print
    # a Message.
    def get_message_template
      return @msg_st.get_instance_of
    end
    
    typesig { [] }
    # Return a new template instance for the location part of a Message.
    # TODO: Is this really necessary? -Kay
    def get_location_template
      return @location_st.get_instance_of
    end
    
    typesig { [StringTemplate] }
    def to_s(message_st)
      # setup the location
      @location_st = ErrorManager.get_location_format
      @report_st = ErrorManager.get_report_format
      @message_format_st = ErrorManager.get_message_format
      location_valid = false
      if (!(@line).equal?(-1))
        @location_st.set_attribute("line", @line)
        location_valid = true
      end
      if (!(@column).equal?(-1))
        @location_st.set_attribute("column", @column)
        location_valid = true
      end
      if (!(@file).nil?)
        @location_st.set_attribute("file", @file)
        location_valid = true
      end
      @message_format_st.set_attribute("id", @msg_id)
      @message_format_st.set_attribute("text", message_st)
      if (location_valid)
        @report_st.set_attribute("location", @location_st)
      end
      @report_st.set_attribute("message", @message_format_st)
      @report_st.set_attribute("type", ErrorManager.get_message_type(@msg_id))
      return @report_st.to_s
    end
    
    private
    alias_method :initialize__message, :initialize
  end
  
end
