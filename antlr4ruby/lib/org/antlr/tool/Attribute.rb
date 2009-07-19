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
  module AttributeImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
    }
  end
  
  # Track the names of attributes define in arg lists, return values,
  # scope blocks etc...
  class Attribute 
    include_class_members AttributeImports
    
    # The entire declaration such as "String foo;"
    attr_accessor :decl
    alias_method :attr_decl, :decl
    undef_method :decl
    alias_method :attr_decl=, :decl=
    undef_method :decl=
    
    # The type; might be empty such as for Python which has no static typing
    attr_accessor :type
    alias_method :attr_type, :type
    undef_method :type
    alias_method :attr_type=, :type=
    undef_method :type=
    
    # The name of the attribute "foo"
    attr_accessor :name
    alias_method :attr_name, :name
    undef_method :name
    alias_method :attr_name=, :name=
    undef_method :name=
    
    # The optional attribute intialization expression
    attr_accessor :init_value
    alias_method :attr_init_value, :init_value
    undef_method :init_value
    alias_method :attr_init_value=, :init_value=
    undef_method :init_value=
    
    typesig { [String] }
    def initialize(decl)
      @decl = nil
      @type = nil
      @name = nil
      @init_value = nil
      extract_attribute(decl)
    end
    
    typesig { [String, String] }
    def initialize(name, decl)
      @decl = nil
      @type = nil
      @name = nil
      @init_value = nil
      @name = name
      @decl = decl
    end
    
    typesig { [String] }
    # For decls like "String foo" or "char *foo32[3]" compute the ID
    # and type declarations.  Also handle "int x=3" and 'T t = new T("foo")'
    # but if the separator is ',' you cannot use ',' in the initvalue.
    # AttributeScope.addAttributes takes care of the separation so we are
    # free here to use from '=' to end of string as the expression.
    # 
    # Set name, type, initvalue, and full decl instance vars.
    def extract_attribute(decl)
      if ((decl).nil?)
        return
      end
      in_id = false
      start = -1
      right_edge_of_declarator = decl.length - 1
      equals_index = decl.index_of(Character.new(?=.ord))
      if (equals_index > 0)
        # everything after the '=' is the init value
        @init_value = decl.substring(equals_index + 1, decl.length)
        right_edge_of_declarator = equals_index - 1
      end
      # walk backwards looking for start of an ID
      i = right_edge_of_declarator
      while i >= 0
        # if we haven't found the end yet, keep going
        if (!in_id && Character.is_letter_or_digit(decl.char_at(i)))
          in_id = true
        else
          if (in_id && !(Character.is_letter_or_digit(decl.char_at(i)) || (decl.char_at(i)).equal?(Character.new(?_.ord))))
            start = i + 1
            break
          end
        end
        ((i -= 1) + 1)
      end
      if (start < 0 && in_id)
        start = 0
      end
      if (start < 0)
        ErrorManager.error(ErrorManager::MSG_CANNOT_FIND_ATTRIBUTE_NAME_IN_DECL, decl)
      end
      # walk forwards looking for end of an ID
      stop = -1
      i_ = start
      while i_ <= right_edge_of_declarator
        # if we haven't found the end yet, keep going
        if (!(Character.is_letter_or_digit(decl.char_at(i_)) || (decl.char_at(i_)).equal?(Character.new(?_.ord))))
          stop = i_
          break
        end
        if ((i_).equal?(right_edge_of_declarator))
          stop = i_ + 1
        end
        ((i_ += 1) - 1)
      end
      # the name is the last ID
      @name = decl.substring(start, stop)
      # the type is the decl minus the ID (could be empty)
      @type = decl.substring(0, start)
      if (stop <= right_edge_of_declarator)
        @type += decl.substring(stop, right_edge_of_declarator + 1)
      end
      @type = @type.trim
      if ((@type.length).equal?(0))
        @type = nil
      end
      @decl = decl
    end
    
    typesig { [] }
    def to_s
      if (!(@init_value).nil?)
        return @type + " " + @name + "=" + @init_value
      end
      return @type + " " + @name
    end
    
    private
    alias_method :initialize__attribute, :initialize
  end
  
end
