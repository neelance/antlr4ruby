require "rjava"

module Org::Antlr::Codegen
  module JavaScriptTargetImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include ::Java::Util
    }
  end
  
  class JavaScriptTarget < JavaScriptTargetImports.const_get :Target
    include_class_members JavaScriptTargetImports
    
    typesig { [::Java::Int] }
    # Convert an int to a JavaScript Unicode character literal.
    # 
    # The current JavaScript spec (ECMA-262) doesn't provide for octal
    # notation in String literals, although some implementations support it.
    # This method overrides the parent class so that characters will always
    # be encoded as Unicode literals (e.g. \u0011).
    def encode_int_as_char_escape(v)
      hex = JavaInteger.to_hex_string(v | 0x10000).substring(1, 5)
      return "\\u" + hex
    end
    
    typesig { [::Java::Long] }
    # Convert long to two 32-bit numbers separted by a comma.
    # JavaScript does not support 64-bit numbers, so we need to break
    # the number into two 32-bit literals to give to the Bit.  A number like
    # 0xHHHHHHHHLLLLLLLL is broken into the following string:
    # "0xLLLLLLLL, 0xHHHHHHHH"
    # Note that the low order bits are first, followed by the high order bits.
    # This is to match how the BitSet constructor works, where the bits are
    # passed in in 32-bit chunks with low-order bits coming first.
    # 
    # Note: stole the following two methods from the ActionScript target.
    def get_target64bit_string_from_value(word)
      buf = StringBuffer.new(22) # enough for the two "0x", "," and " "
      buf.append("0x")
      write_hex_with_padding(buf, JavaInteger.to_hex_string(((word & 0xffffffff)).to_int))
      buf.append(", 0x")
      write_hex_with_padding(buf, JavaInteger.to_hex_string(((word >> 32)).to_int))
      return buf.to_s
    end
    
    typesig { [StringBuffer, String] }
    def write_hex_with_padding(buf, digits)
      digits = RJava.cast_to_string(digits.to_upper_case)
      padding = 8 - digits.length
      # pad left with zeros
      i = 1
      while i <= padding
        buf.append(Character.new(?0.ord))
        i += 1
      end
      buf.append(digits)
    end
    
    typesig { [] }
    def initialize
      super()
    end
    
    private
    alias_method :initialize__java_script_target, :initialize
  end
  
end
