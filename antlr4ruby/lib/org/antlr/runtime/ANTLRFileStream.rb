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
  module ANTLRFileStreamImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include ::Java::Io
    }
  end
  
  # This is a char buffer stream that is loaded from a file
  # all at once when you construct the object.  This looks very
  # much like an ANTLReader or ANTLRInputStream, but it's a special case
  # since we know the exact size of the object to load.  We can avoid lots
  # of data copying.
  class ANTLRFileStream < ANTLRFileStreamImports.const_get :ANTLRStringStream
    include_class_members ANTLRFileStreamImports
    
    attr_accessor :file_name
    alias_method :attr_file_name, :file_name
    undef_method :file_name
    alias_method :attr_file_name=, :file_name=
    undef_method :file_name=
    
    typesig { [String] }
    def initialize(file_name)
      initialize__antlrfile_stream(file_name, nil)
    end
    
    typesig { [String, String] }
    def initialize(file_name, encoding)
      @file_name = nil
      super()
      @file_name = file_name
      load(file_name, encoding)
    end
    
    typesig { [String, String] }
    def load(file_name, encoding)
      if ((file_name).nil?)
        return
      end
      f = JavaFile.new(file_name)
      size = RJava.cast_to_int(f.length)
      isr = nil
      fis = FileInputStream.new(file_name)
      if (!(encoding).nil?)
        isr = InputStreamReader.new(fis, encoding)
      else
        isr = InputStreamReader.new(fis)
      end
      begin
        self.attr_data = CharArray.new(size)
        @n = isr.read(self.attr_data)
      ensure
        isr.close
      end
    end
    
    typesig { [] }
    def get_source_name
      return @file_name
    end
    
    private
    alias_method :initialize__antlrfile_stream, :initialize
  end
  
end
