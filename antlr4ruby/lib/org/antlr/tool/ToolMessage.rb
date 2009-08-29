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
  module ToolMessageImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
    }
  end
  
  # A generic message from the tool such as "file not found" type errors; there
  # is no reason to create a special object for each error unlike the grammar
  # errors, which may be rather complex.
  # 
  # Sometimes you need to pass in a filename or something to say it is "bad".
  # Allow a generic object to be passed in and the string template can deal
  # with just printing it or pulling a property out of it.
  # 
  # TODO what to do with exceptions?  Want stack trace for internal errors?
  class ToolMessage < ToolMessageImports.const_get :Message
    include_class_members ToolMessageImports
    
    typesig { [::Java::Int] }
    def initialize(msg_id)
      super(msg_id, nil, nil)
    end
    
    typesig { [::Java::Int, Object] }
    def initialize(msg_id, arg)
      super(msg_id, arg, nil)
    end
    
    typesig { [::Java::Int, JavaThrowable] }
    def initialize(msg_id, e)
      super(msg_id)
      self.attr_e = e
    end
    
    typesig { [::Java::Int, Object, Object] }
    def initialize(msg_id, arg, arg2)
      super(msg_id, arg, arg2)
    end
    
    typesig { [::Java::Int, Object, JavaThrowable] }
    def initialize(msg_id, arg, e)
      super(msg_id, arg, nil)
      self.attr_e = e
    end
    
    typesig { [] }
    def to_s
      st = get_message_template
      if (!(self.attr_arg).nil?)
        st.set_attribute("arg", self.attr_arg)
      end
      if (!(self.attr_arg2).nil?)
        st.set_attribute("arg2", self.attr_arg2)
      end
      if (!(self.attr_e).nil?)
        st.set_attribute("exception", self.attr_e)
        st.set_attribute("stackTrace", self.attr_e.get_stack_trace)
      end
      return super(st)
    end
    
    private
    alias_method :initialize__tool_message, :initialize
  end
  
end
