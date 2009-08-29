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
  module ANTLRReaderStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include ::Java::Io
    }
  end
  
  # Vacuum all input from a Reader and then treat it like a StringStream.
  # Manage the buffer manually to avoid unnecessary data copying.
  # 
  # If you need encoding, use ANTLRInputStream.
  class ANTLRReaderStream < ANTLRReaderStreamImports.const_get :ANTLRStringStream
    include_class_members ANTLRReaderStreamImports
    
    class_module.module_eval {
      const_set_lazy(:READ_BUFFER_SIZE) { 1024 }
      const_attr_reader  :READ_BUFFER_SIZE
      
      const_set_lazy(:INITIAL_BUFFER_SIZE) { 1024 }
      const_attr_reader  :INITIAL_BUFFER_SIZE
    }
    
    typesig { [] }
    def initialize
      super()
    end
    
    typesig { [Reader] }
    def initialize(r)
      initialize__antlrreader_stream(r, INITIAL_BUFFER_SIZE, READ_BUFFER_SIZE)
    end
    
    typesig { [Reader, ::Java::Int] }
    def initialize(r, size)
      initialize__antlrreader_stream(r, size, READ_BUFFER_SIZE)
    end
    
    typesig { [Reader, ::Java::Int, ::Java::Int] }
    def initialize(r, size, read_chunk_size)
      super()
      load(r, size, read_chunk_size)
    end
    
    typesig { [Reader, ::Java::Int, ::Java::Int] }
    def load(r, size, read_chunk_size)
      if ((r).nil?)
        return
      end
      if (size <= 0)
        size = INITIAL_BUFFER_SIZE
      end
      if (read_chunk_size <= 0)
        read_chunk_size = READ_BUFFER_SIZE
      end
      # System.out.println("load "+size+" in chunks of "+readChunkSize);
      begin
        # alloc initial buffer size.
        self.attr_data = CharArray.new(size)
        # read all the data in chunks of readChunkSize
        num_read = 0
        p = 0
        begin
          if (p + read_chunk_size > self.attr_data.attr_length)
            # overflow?
            # System.out.println("### overflow p="+p+", data.length="+data.length);
            newdata = CharArray.new(self.attr_data.attr_length * 2) # resize
            System.arraycopy(self.attr_data, 0, newdata, 0, self.attr_data.attr_length)
            self.attr_data = newdata
          end
          num_read = r.read(self.attr_data, p, read_chunk_size)
          # System.out.println("read "+numRead+" chars; p was "+p+" is now "+(p+numRead));
          p += num_read
        end while (!(num_read).equal?(-1)) # while not EOF
        # set the actual size of the data available;
        # EOF subtracted one above in p+=numRead; add one back
        @n = p + 1
        # System.out.println("n="+n);
      ensure
        r.close
      end
    end
    
    private
    alias_method :initialize__antlrreader_stream, :initialize
  end
  
end
