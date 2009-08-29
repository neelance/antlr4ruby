require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005 Martin Traverso
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
# 
# 
# 
# Please excuse my obvious lack of Java experience. The code here is probably
# full of WTFs - though IMHO Java is the Real WTF(TM) here...
module Org::Antlr::Codegen
  module PythonTargetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Org::Antlr::Tool, :Grammar
      include ::Java::Util
    }
  end
  
  class PythonTarget < PythonTargetImports.const_get :Target
    include_class_members PythonTargetImports
    
    typesig { [CodeGenerator, ::Java::Int] }
    # Target must be able to override the labels used for token types
    def get_token_type_as_target_label(generator, ttype)
      # use ints for predefined types;
      # <invalid> <EOR> <DOWN> <UP>
      if (ttype >= 0 && ttype <= 3)
        return String.value_of(ttype)
      end
      name = generator.attr_grammar.get_token_display_name(ttype)
      # If name is a literal, return the token type instead
      if ((name.char_at(0)).equal?(Character.new(?\'.ord)))
        return String.value_of(ttype)
      end
      return name
    end
    
    typesig { [CodeGenerator, String] }
    def get_target_char_literal_from_antlrchar_literal(generator, literal)
      c = Grammar.get_char_value_from_grammar_char_literal(literal)
      return String.value_of(c)
    end
    
    typesig { [String] }
    def split_lines(text)
      l = ArrayList.new
      idx = 0
      while (true)
        eol = text.index_of("\n", idx)
        if ((eol).equal?(-1))
          l.add(text.substring(idx))
          break
        else
          l.add(text.substring(idx, eol + 1))
          idx = eol + 1
        end
      end
      return l
    end
    
    typesig { [JavaList, Antlr::Token] }
    def post_process_action(chunks, action_token)
      # TODO
      # - check for and report TAB usage
      # 
      # System.out.println("\n*** Action at " + actionToken.getLine() + ":" + actionToken.getColumn());
      # First I create a new list of chunks. String chunks are splitted into
      # lines and some whitespace my be added at the beginning.
      # 
      # As a result I get a list of chunks
      # - where the first line starts at column 0
      # - where every LF is at the end of a string chunk
      n_chunks = ArrayList.new
      i = 0
      while i < chunks.size
        chunk = chunks.get(i)
        if (chunk.is_a?(String))
          text = chunks.get(i)
          if ((n_chunks.size).equal?(0) && action_token.get_column > 0)
            # first chunk and some 'virtual' WS at beginning
            # prepend to this chunk
            ws = ""
            j = 0
            while j < action_token.get_column
              ws += " "
              j += 1
            end
            text = ws + text
          end
          parts = split_lines(text)
          j = 0
          while j < parts.size
            chunk = parts.get(j)
            n_chunks.add(chunk)
            j += 1
          end
        else
          if ((n_chunks.size).equal?(0) && action_token.get_column > 0)
            # first chunk and some 'virtual' WS at beginning
            # add as a chunk of its own
            ws = ""
            j = 0
            while j < action_token.get_column
              ws += " "
              j += 1
            end
            n_chunks.add(ws)
          end
          n_chunks.add(chunk)
        end
        i += 1
      end
      line_no = action_token.get_line
      col = 0
      # strip trailing empty lines
      last_chunk = n_chunks.size - 1
      while (last_chunk > 0 && n_chunks.get(last_chunk).is_a?(String) && ((n_chunks.get(last_chunk)).trim.length).equal?(0))
        last_chunk -= 1
      end
      # string leading empty lines
      first_chunk = 0
      while (first_chunk <= last_chunk && n_chunks.get(first_chunk).is_a?(String) && ((n_chunks.get(first_chunk)).trim.length).equal?(0) && (n_chunks.get(first_chunk)).ends_with("\n"))
        line_no += 1
        first_chunk += 1
      end
      indent = -1
      i_ = first_chunk
      while i_ <= last_chunk
        chunk = n_chunks.get(i_)
        # System.out.println(lineNo + ":" + col + " " + quote(chunk.toString()));
        if (chunk.is_a?(String))
          text = chunk
          if ((col).equal?(0))
            if ((indent).equal?(-1))
              # first non-blank line
              # count number of leading whitespaces
              indent = 0
              j = 0
              while j < text.length
                if (!Character.is_whitespace(text.char_at(j)))
                  break
                end
                indent += 1
                j += 1
              end
            end
            if (text.length >= indent)
              j = 0
              j = 0
              while j < indent
                if (!Character.is_whitespace(text.char_at(j)))
                  # should do real error reporting here...
                  System.err.println("Warning: badly indented line " + RJava.cast_to_string(line_no) + " in action:")
                  System.err.println(text)
                  break
                end
                j += 1
              end
              n_chunks.set(i_, text.substring(j))
            else
              if (text.trim.length > 0)
                # should do real error reporting here...
                System.err.println("Warning: badly indented line " + RJava.cast_to_string(line_no) + " in action:")
                System.err.println(text)
              end
            end
          end
          if (text.ends_with("\n"))
            line_no += 1
            col = 0
          else
            col += text.length
          end
        else
          # not really correct, but all I need is col to increment...
          col += 1
        end
        i_ += 1
      end
      return n_chunks
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__python_target, :initialize
  end
  
end
