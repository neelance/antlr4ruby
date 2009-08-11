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
  module ANTLRErrorListenerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
    }
  end
  
  # Defines behavior of object able to handle error messages from ANTLR including
  # both tool errors like "can't write file" and grammar ambiguity warnings.
  # To avoid having to change tools that use ANTLR (like GUIs), I am
  # wrapping error data in Message objects and passing them to the listener.
  # In this way, users of this interface are less sensitive to changes in
  # the info I need for error messages.
  module ANTLRErrorListener
    include_class_members ANTLRErrorListenerImports
    
    typesig { [String] }
    def info(msg)
      raise NotImplementedError
    end
    
    typesig { [Message] }
    def error(msg)
      raise NotImplementedError
    end
    
    typesig { [Message] }
    def warning(msg)
      raise NotImplementedError
    end
    
    typesig { [ToolMessage] }
    def error(msg)
      raise NotImplementedError
    end
  end
  
end
