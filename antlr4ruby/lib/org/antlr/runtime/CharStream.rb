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
module Org::Antlr::Runtime
  module CharStreamImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
    }
  end
  
  # A source of characters for an ANTLR lexer
  module CharStream
    include_class_members CharStreamImports
    include IntStream
    
    class_module.module_eval {
      const_set_lazy(:EOF) { -1 }
      const_attr_reader  :EOF
    }
    
    typesig { [::Java::Int, ::Java::Int] }
    # For infinite streams, you don't need this; primarily I'm providing
    # a useful interface for action code.  Just make sure actions don't
    # use this on streams that don't support it.
    def substring(start, stop)
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    # Get the ith character of lookahead.  This is the same usually as
    # LA(i).  This will be used for labels in the generated
    # lexer code.  I'd prefer to return a char here type-wise, but it's
    # probably better to be 32-bit clean and be consistent with LA.
    def _lt(i)
      raise NotImplementedError
    end
    
    typesig { [] }
    # ANTLR tracks the line information automatically
    def get_line
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    # Because this stream can rewind, we need to be able to reset the line
    def set_line(line)
      raise NotImplementedError
    end
    
    typesig { [::Java::Int] }
    def set_char_position_in_line(pos)
      raise NotImplementedError
    end
    
    typesig { [] }
    # The index of the character relative to the beginning of the line 0..n-1
    def get_char_position_in_line
      raise NotImplementedError
    end
  end
  
end
