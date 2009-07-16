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
module Org::Antlr::Runtime::Tree
  module TreePatternLexerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime::Tree
    }
  end
  
  class TreePatternLexer 
    include_class_members TreePatternLexerImports
    
    class_module.module_eval {
      const_set_lazy(:EOF) { -1 }
      const_attr_reader  :EOF
      
      const_set_lazy(:BEGIN_) { 1 }
      const_attr_reader  :BEGIN_
      
      const_set_lazy(:END_) { 2 }
      const_attr_reader  :END_
      
      const_set_lazy(:ID) { 3 }
      const_attr_reader  :ID
      
      const_set_lazy(:ARG) { 4 }
      const_attr_reader  :ARG
      
      const_set_lazy(:PERCENT) { 5 }
      const_attr_reader  :PERCENT
      
      const_set_lazy(:COLON) { 6 }
      const_attr_reader  :COLON
      
      const_set_lazy(:DOT) { 7 }
      const_attr_reader  :DOT
    }
    
    # The tree pattern to lex like "(A B C)"
    attr_accessor :pattern
    alias_method :attr_pattern, :pattern
    undef_method :pattern
    alias_method :attr_pattern=, :pattern=
    undef_method :pattern=
    
    # Index into input string
    attr_accessor :p
    alias_method :attr_p, :p
    undef_method :p
    alias_method :attr_p=, :p=
    undef_method :p=
    
    # Current char
    attr_accessor :c
    alias_method :attr_c, :c
    undef_method :c
    alias_method :attr_c=, :c=
    undef_method :c=
    
    # How long is the pattern in char?
    attr_accessor :n
    alias_method :attr_n, :n
    undef_method :n
    alias_method :attr_n=, :n=
    undef_method :n=
    
    # Set when token type is ID or ARG (name mimics Java's StreamTokenizer)
    attr_accessor :sval
    alias_method :attr_sval, :sval
    undef_method :sval
    alias_method :attr_sval=, :sval=
    undef_method :sval=
    
    attr_accessor :error
    alias_method :attr_error, :error
    undef_method :error
    alias_method :attr_error=, :error=
    undef_method :error=
    
    typesig { [String] }
    def initialize(pattern)
      @pattern = nil
      @p = -1
      @c = 0
      @n = 0
      @sval = StringBuffer.new
      @error = false
      @pattern = pattern
      @n = pattern.length
      consume
    end
    
    typesig { [] }
    def next_token
      @sval.set_length(0) # reset, but reuse buffer
      while (!(@c).equal?(EOF))
        if ((@c).equal?(Character.new(?\s.ord)) || (@c).equal?(Character.new(?\n.ord)) || (@c).equal?(Character.new(?\r.ord)) || (@c).equal?(Character.new(?\t.ord)))
          consume
          next
        end
        if ((@c >= Character.new(?a.ord) && @c <= Character.new(?z.ord)) || (@c >= Character.new(?A.ord) && @c <= Character.new(?Z.ord)) || (@c).equal?(Character.new(?_.ord)))
          @sval.append(RJava.cast_to_char(@c))
          consume
          while ((@c >= Character.new(?a.ord) && @c <= Character.new(?z.ord)) || (@c >= Character.new(?A.ord) && @c <= Character.new(?Z.ord)) || (@c >= Character.new(?0.ord) && @c <= Character.new(?9.ord)) || (@c).equal?(Character.new(?_.ord)))
            @sval.append(RJava.cast_to_char(@c))
            consume
          end
          return ID
        end
        if ((@c).equal?(Character.new(?(.ord)))
          consume
          return BEGIN_
        end
        if ((@c).equal?(Character.new(?).ord)))
          consume
          return END_
        end
        if ((@c).equal?(Character.new(?%.ord)))
          consume
          return PERCENT
        end
        if ((@c).equal?(Character.new(?:.ord)))
          consume
          return COLON
        end
        if ((@c).equal?(Character.new(?..ord)))
          consume
          return DOT
        end
        if ((@c).equal?(Character.new(?[.ord)))
          # grab [x] as a string, returning x
          consume
          while (!(@c).equal?(Character.new(?].ord)))
            if ((@c).equal?(Character.new(?\\.ord)))
              consume
              if (!(@c).equal?(Character.new(?].ord)))
                @sval.append(Character.new(?\\.ord))
              end
              @sval.append(RJava.cast_to_char(@c))
            else
              @sval.append(RJava.cast_to_char(@c))
            end
            consume
          end
          consume
          return ARG
        end
        consume
        @error = true
        return EOF
      end
      return EOF
    end
    
    typesig { [] }
    def consume
      ((@p += 1) - 1)
      if (@p >= @n)
        @c = EOF
      else
        @c = @pattern.char_at(@p)
      end
    end
    
    private
    alias_method :initialize__tree_pattern_lexer, :initialize
  end
  
end
