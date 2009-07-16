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
module Org::Antlr::Runtime
  module ANTLRStringStreamImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include_const ::Java::Util, :ArrayList
      include_const ::Java::Util, :JavaList
    }
  end
  
  # A pretty quick CharStream that pulls all data from an array
  # directly.  Every method call counts in the lexer.  Java's
  # strings aren't very good so I'm avoiding.
  class ANTLRStringStream 
    include_class_members ANTLRStringStreamImports
    include CharStream
    
    # The data being scanned
    attr_accessor :data
    alias_method :attr_data, :data
    undef_method :data
    alias_method :attr_data=, :data=
    undef_method :data=
    
    # How many characters are actually in the buffer
    attr_accessor :n
    alias_method :attr_n, :n
    undef_method :n
    alias_method :attr_n=, :n=
    undef_method :n=
    
    # 0..n-1 index into string of next char
    attr_accessor :p
    alias_method :attr_p, :p
    undef_method :p
    alias_method :attr_p=, :p=
    undef_method :p=
    
    # line number 1..n within the input
    attr_accessor :line
    alias_method :attr_line, :line
    undef_method :line
    alias_method :attr_line=, :line=
    undef_method :line=
    
    # The index of the character relative to the beginning of the line 0..n-1
    attr_accessor :char_position_in_line
    alias_method :attr_char_position_in_line, :char_position_in_line
    undef_method :char_position_in_line
    alias_method :attr_char_position_in_line=, :char_position_in_line=
    undef_method :char_position_in_line=
    
    # tracks how deep mark() calls are nested
    attr_accessor :mark_depth
    alias_method :attr_mark_depth, :mark_depth
    undef_method :mark_depth
    alias_method :attr_mark_depth=, :mark_depth=
    undef_method :mark_depth=
    
    # A list of CharStreamState objects that tracks the stream state
    # values line, charPositionInLine, and p that can change as you
    # move through the input stream.  Indexed from 1..markDepth.
    # A null is kept @ index 0.  Create upon first call to mark().
    attr_accessor :markers
    alias_method :attr_markers, :markers
    undef_method :markers
    alias_method :attr_markers=, :markers=
    undef_method :markers=
    
    # Track the last mark() call result value for use in rewind().
    attr_accessor :last_marker
    alias_method :attr_last_marker, :last_marker
    undef_method :last_marker
    alias_method :attr_last_marker=, :last_marker=
    undef_method :last_marker=
    
    # What is name or source of this char stream?
    attr_accessor :name
    alias_method :attr_name, :name
    undef_method :name
    alias_method :attr_name=, :name=
    undef_method :name=
    
    typesig { [] }
    def initialize
      @data = nil
      @n = 0
      @p = 0
      @line = 1
      @char_position_in_line = 0
      @mark_depth = 0
      @markers = nil
      @last_marker = 0
      @name = nil
    end
    
    typesig { [String] }
    # Copy data in string to a local char array
    def initialize(input)
      initialize__antlrstring_stream()
      @data = input.to_char_array
      @n = input.length
    end
    
    typesig { [Array.typed(::Java::Char), ::Java::Int] }
    # This is the preferred constructor as no data is copied
    def initialize(data, number_of_actual_chars_in_array)
      initialize__antlrstring_stream()
      @data = data
      @n = number_of_actual_chars_in_array
    end
    
    typesig { [] }
    # Reset the stream so that it's in the same state it was
    # when the object was created *except* the data array is not
    # touched.
    def reset
      @p = 0
      @line = 1
      @char_position_in_line = 0
      @mark_depth = 0
    end
    
    typesig { [] }
    def consume
      # System.out.println("prev p="+p+", c="+(char)data[p]);
      if (@p < @n)
        ((@char_position_in_line += 1) - 1)
        if ((@data[@p]).equal?(Character.new(?\n.ord)))
          # 
          # System.out.println("newline char found on line: "+line+
          # "@ pos="+charPositionInLine);
          ((@line += 1) - 1)
          @char_position_in_line = 0
        end
        ((@p += 1) - 1)
        # System.out.println("p moves to "+p+" (c='"+(char)data[p]+"')");
      end
    end
    
    typesig { [::Java::Int] }
    def _la(i)
      if ((i).equal?(0))
        return 0 # undefined
      end
      if (i < 0)
        ((i += 1) - 1) # e.g., translate LA(-1) to use offset i=0; then data[p+0-1]
        if ((@p + i - 1) < 0)
          return CharStream::EOF # invalid; no char before first char
        end
      end
      if ((@p + i - 1) >= @n)
        # System.out.println("char LA("+i+")=EOF; p="+p);
        return CharStream::EOF
      end
      # System.out.println("char LA("+i+")="+(char)data[p+i-1]+"; p="+p);
      # System.out.println("LA("+i+"); p="+p+" n="+n+" data.length="+data.length);
      return @data[@p + i - 1]
    end
    
    typesig { [::Java::Int] }
    def _lt(i)
      return _la(i)
    end
    
    typesig { [] }
    # Return the current input symbol index 0..n where n indicates the
    # last symbol has been read.  The index is the index of char to
    # be returned from LA(1).
    def index
      return @p
    end
    
    typesig { [] }
    def size
      return @n
    end
    
    typesig { [] }
    def mark
      if ((@markers).nil?)
        @markers = ArrayList.new
        @markers.add(nil) # depth 0 means no backtracking, leave blank
      end
      ((@mark_depth += 1) - 1)
      state = nil
      if (@mark_depth >= @markers.size)
        state = CharStreamState.new
        @markers.add(state)
      else
        state = @markers.get(@mark_depth)
      end
      state.attr_p = @p
      state.attr_line = @line
      state.attr_char_position_in_line = @char_position_in_line
      @last_marker = @mark_depth
      return @mark_depth
    end
    
    typesig { [::Java::Int] }
    def rewind(m)
      state = @markers.get(m)
      # restore stream state
      seek(state.attr_p)
      @line = state.attr_line
      @char_position_in_line = state.attr_char_position_in_line
      release(m)
    end
    
    typesig { [] }
    def rewind
      rewind(@last_marker)
    end
    
    typesig { [::Java::Int] }
    def release(marker)
      # unwind any other markers made after m and release m
      @mark_depth = marker
      # release this marker
      ((@mark_depth -= 1) + 1)
    end
    
    typesig { [::Java::Int] }
    # consume() ahead until p==index; can't just set p=index as we must
    # update line and charPositionInLine.
    def seek(index)
      if (index <= @p)
        @p = index # just jump; don't update stream state (line, ...)
        return
      end
      # seek forward, consume until p hits index
      while (@p < index)
        consume
      end
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def substring(start, stop)
      return String.new(@data, start, stop - start + 1)
    end
    
    typesig { [] }
    def get_line
      return @line
    end
    
    typesig { [] }
    def get_char_position_in_line
      return @char_position_in_line
    end
    
    typesig { [::Java::Int] }
    def set_line(line)
      @line = line
    end
    
    typesig { [::Java::Int] }
    def set_char_position_in_line(pos)
      @char_position_in_line = pos
    end
    
    typesig { [] }
    def get_source_name
      return @name
    end
    
    private
    alias_method :initialize__antlrstring_stream, :initialize
  end
  
end
