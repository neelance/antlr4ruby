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
module Org::Antlr::Test
  module ErrorQueueImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Org::Antlr::Tool, :ANTLRErrorListener
      include_const ::Org::Antlr::Tool, :Message
      include_const ::Org::Antlr::Tool, :ToolMessage
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :LinkedList
    }
  end
  
  class ErrorQueue 
    include_class_members ErrorQueueImports
    include ANTLRErrorListener
    
    attr_accessor :infos
    alias_method :attr_infos, :infos
    undef_method :infos
    alias_method :attr_infos=, :infos=
    undef_method :infos=
    
    attr_accessor :errors
    alias_method :attr_errors, :errors
    undef_method :errors
    alias_method :attr_errors=, :errors=
    undef_method :errors=
    
    attr_accessor :warnings
    alias_method :attr_warnings, :warnings
    undef_method :warnings
    alias_method :attr_warnings=, :warnings=
    undef_method :warnings=
    
    typesig { [String] }
    def info(msg)
      @infos.add(msg)
    end
    
    typesig { [Message] }
    def error(msg)
      @errors.add(msg)
    end
    
    typesig { [Message] }
    def warning(msg)
      @warnings.add(msg)
    end
    
    typesig { [ToolMessage] }
    def error(msg)
      @errors.add(msg)
    end
    
    typesig { [] }
    def size
      return @infos.size + @errors.size + @warnings.size
    end
    
    typesig { [] }
    def to_s
      return "infos: " + RJava.cast_to_string(@infos) + "errors: " + RJava.cast_to_string(@errors) + "warnings: " + RJava.cast_to_string(@warnings)
    end
    
    typesig { [] }
    def initialize
      @infos = LinkedList.new
      @errors = LinkedList.new
      @warnings = LinkedList.new
    end
    
    private
    alias_method :initialize__error_queue, :initialize
  end
  
end
