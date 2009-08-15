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
  module TokenRewriteStreamImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Runtime
      include ::Java::Util
    }
  end
  
  # Useful for dumping out the input stream after doing some
  # augmentation or other manipulations.
  # 
  # You can insert stuff, replace, and delete chunks.  Note that the
  # operations are done lazily--only if you convert the buffer to a
  # String.  This is very efficient because you are not moving data around
  # all the time.  As the buffer of tokens is converted to strings, the
  # toString() method(s) check to see if there is an operation at the
  # current index.  If so, the operation is done and then normal String
  # rendering continues on the buffer.  This is like having multiple Turing
  # machine instruction streams (programs) operating on a single input tape. :)
  # 
  # Since the operations are done lazily at toString-time, operations do not
  # screw up the token index values.  That is, an insert operation at token
  # index i does not change the index values for tokens i+1..n-1.
  # 
  # Because operations never actually alter the buffer, you may always get
  # the original token stream back without undoing anything.  Since
  # the instructions are queued up, you can easily simulate transactions and
  # roll back any changes if there is an error just by removing instructions.
  # For example,
  # 
  # CharStream input = new ANTLRFileStream("input");
  # TLexer lex = new TLexer(input);
  # TokenRewriteStream tokens = new TokenRewriteStream(lex);
  # T parser = new T(tokens);
  # parser.startRule();
  # 
  # Then in the rules, you can execute
  # Token t,u;
  # ...
  # input.insertAfter(t, "text to put after t");}
  # input.insertAfter(u, "text after u");}
  # System.out.println(tokens.toString());
  # 
  # Actually, you have to cast the 'input' to a TokenRewriteStream. :(
  # 
  # You can also have multiple "instruction streams" and get multiple
  # rewrites from a single pass over the input.  Just name the instruction
  # streams and use that name again when printing the buffer.  This could be
  # useful for generating a C file and also its header file--all from the
  # same buffer:
  # 
  # tokens.insertAfter("pass1", t, "text to put after t");}
  # tokens.insertAfter("pass2", u, "text after u");}
  # System.out.println(tokens.toString("pass1"));
  # System.out.println(tokens.toString("pass2"));
  # 
  # If you don't use named rewrite streams, a "default" stream is used as
  # the first example shows.
  class TokenRewriteStream < TokenRewriteStreamImports.const_get :CommonTokenStream
    include_class_members TokenRewriteStreamImports
    
    class_module.module_eval {
      const_set_lazy(:DEFAULT_PROGRAM_NAME) { "default" }
      const_attr_reader  :DEFAULT_PROGRAM_NAME
      
      const_set_lazy(:PROGRAM_INIT_SIZE) { 100 }
      const_attr_reader  :PROGRAM_INIT_SIZE
      
      const_set_lazy(:MIN_TOKEN_INDEX) { 0 }
      const_attr_reader  :MIN_TOKEN_INDEX
      
      # Define the rewrite operation hierarchy
      const_set_lazy(:RewriteOperation) { Class.new do
        extend LocalClass
        include_class_members TokenRewriteStream
        
        # What index into rewrites List are we?
        attr_accessor :instruction_index
        alias_method :attr_instruction_index, :instruction_index
        undef_method :instruction_index
        alias_method :attr_instruction_index=, :instruction_index=
        undef_method :instruction_index=
        
        # Token buffer index.
        attr_accessor :index
        alias_method :attr_index, :index
        undef_method :index
        alias_method :attr_index=, :index=
        undef_method :index=
        
        attr_accessor :text
        alias_method :attr_text, :text
        undef_method :text
        alias_method :attr_text=, :text=
        undef_method :text=
        
        typesig { [::Java::Int, Object] }
        def initialize(index, text)
          @instruction_index = 0
          @index = 0
          @text = nil
          @index = index
          @text = text
        end
        
        typesig { [StringBuffer] }
        # Execute the rewrite operation by possibly adding to the buffer.
        # Return the index of the next token to operate on.
        def execute(buf)
          return @index
        end
        
        typesig { [] }
        def to_s
          op_name = get_class.get_name
          $index = op_name.index_of(Character.new(?$.ord))
          op_name = RJava.cast_to_string(op_name.substring($index + 1, op_name.length))
          return "<" + op_name + "@" + RJava.cast_to_string(@index) + ":\"" + RJava.cast_to_string(@text) + "\">"
        end
        
        private
        alias_method :initialize__rewrite_operation, :initialize
      end }
      
      const_set_lazy(:InsertBeforeOp) { Class.new(RewriteOperation) do
        extend LocalClass
        include_class_members TokenRewriteStream
        
        typesig { [::Java::Int, Object] }
        def initialize(index, text)
          super(index, text)
        end
        
        typesig { [StringBuffer] }
        def execute(buf)
          buf.append(self.attr_text)
          buf.append((self.attr_tokens.get(self.attr_index)).get_text)
          return self.attr_index + 1
        end
        
        private
        alias_method :initialize__insert_before_op, :initialize
      end }
      
      # I'm going to try replacing range from x..y with (y-x)+1 ReplaceOp
      # instructions.
      const_set_lazy(:ReplaceOp) { Class.new(RewriteOperation) do
        extend LocalClass
        include_class_members TokenRewriteStream
        
        attr_accessor :last_index
        alias_method :attr_last_index, :last_index
        undef_method :last_index
        alias_method :attr_last_index=, :last_index=
        undef_method :last_index=
        
        typesig { [::Java::Int, ::Java::Int, Object] }
        def initialize(from, to, text)
          @last_index = 0
          super(from, text)
          @last_index = to
        end
        
        typesig { [StringBuffer] }
        def execute(buf)
          if (!(self.attr_text).nil?)
            buf.append(self.attr_text)
          end
          return @last_index + 1
        end
        
        typesig { [] }
        def to_s
          return "<ReplaceOp@" + RJava.cast_to_string(self.attr_index) + ".." + RJava.cast_to_string(@last_index) + ":\"" + RJava.cast_to_string(self.attr_text) + "\">"
        end
        
        private
        alias_method :initialize__replace_op, :initialize
      end }
      
      const_set_lazy(:DeleteOp) { Class.new(ReplaceOp) do
        extend LocalClass
        include_class_members TokenRewriteStream
        
        typesig { [::Java::Int, ::Java::Int] }
        def initialize(from, to)
          super(from, to, nil)
        end
        
        typesig { [] }
        def to_s
          return "<DeleteOp@" + RJava.cast_to_string(self.attr_index) + ".." + RJava.cast_to_string(self.attr_last_index) + ">"
        end
        
        private
        alias_method :initialize__delete_op, :initialize
      end }
    }
    
    # You may have multiple, named streams of rewrite operations.
    # I'm calling these things "programs."
    # Maps String (name) -> rewrite (List)
    attr_accessor :programs
    alias_method :attr_programs, :programs
    undef_method :programs
    alias_method :attr_programs=, :programs=
    undef_method :programs=
    
    # Map String (program name) -> Integer index
    attr_accessor :last_rewrite_token_indexes
    alias_method :attr_last_rewrite_token_indexes, :last_rewrite_token_indexes
    undef_method :last_rewrite_token_indexes
    alias_method :attr_last_rewrite_token_indexes=, :last_rewrite_token_indexes=
    undef_method :last_rewrite_token_indexes=
    
    typesig { [] }
    def initialize
      @programs = nil
      @last_rewrite_token_indexes = nil
      super()
      @programs = nil
      @last_rewrite_token_indexes = nil
      init
    end
    
    typesig { [] }
    def init
      @programs = HashMap.new
      @programs.put(DEFAULT_PROGRAM_NAME, ArrayList.new(PROGRAM_INIT_SIZE))
      @last_rewrite_token_indexes = HashMap.new
    end
    
    typesig { [TokenSource] }
    def initialize(token_source)
      @programs = nil
      @last_rewrite_token_indexes = nil
      super(token_source)
      @programs = nil
      @last_rewrite_token_indexes = nil
      init
    end
    
    typesig { [TokenSource, ::Java::Int] }
    def initialize(token_source, channel)
      @programs = nil
      @last_rewrite_token_indexes = nil
      super(token_source, channel)
      @programs = nil
      @last_rewrite_token_indexes = nil
      init
    end
    
    typesig { [::Java::Int] }
    def rollback(instruction_index)
      rollback(DEFAULT_PROGRAM_NAME, instruction_index)
    end
    
    typesig { [String, ::Java::Int] }
    # Rollback the instruction stream for a program so that
    # the indicated instruction (via instructionIndex) is no
    # longer in the stream.  UNTESTED!
    def rollback(program_name, instruction_index)
      is = @programs.get(program_name)
      if (!(is).nil?)
        @programs.put(program_name, is.sub_list(MIN_TOKEN_INDEX, instruction_index))
      end
    end
    
    typesig { [] }
    def delete_program
      delete_program(DEFAULT_PROGRAM_NAME)
    end
    
    typesig { [String] }
    # Reset the program so that no instructions exist
    def delete_program(program_name)
      rollback(program_name, MIN_TOKEN_INDEX)
    end
    
    typesig { [Token, Object] }
    def insert_after(t, text)
      insert_after(DEFAULT_PROGRAM_NAME, t, text)
    end
    
    typesig { [::Java::Int, Object] }
    def insert_after(index, text)
      insert_after(DEFAULT_PROGRAM_NAME, index, text)
    end
    
    typesig { [String, Token, Object] }
    def insert_after(program_name, t, text)
      insert_after(program_name, t.get_token_index, text)
    end
    
    typesig { [String, ::Java::Int, Object] }
    def insert_after(program_name, index, text)
      # to insert after, just insert before next index (even if past end)
      insert_before(program_name, index + 1, text)
      # addToSortedRewriteList(programName, new InsertAfterOp(index,text));
    end
    
    typesig { [Token, Object] }
    def insert_before(t, text)
      insert_before(DEFAULT_PROGRAM_NAME, t, text)
    end
    
    typesig { [::Java::Int, Object] }
    def insert_before(index, text)
      insert_before(DEFAULT_PROGRAM_NAME, index, text)
    end
    
    typesig { [String, Token, Object] }
    def insert_before(program_name, t, text)
      insert_before(program_name, t.get_token_index, text)
    end
    
    typesig { [String, ::Java::Int, Object] }
    def insert_before(program_name, index, text)
      # addToSortedRewriteList(programName, new InsertBeforeOp(index,text));
      op = InsertBeforeOp.new_local(self, index, text)
      rewrites = get_program(program_name)
      op.attr_instruction_index = rewrites.size
      rewrites.add(op)
    end
    
    typesig { [::Java::Int, Object] }
    def replace(index, text)
      replace(DEFAULT_PROGRAM_NAME, index, index, text)
    end
    
    typesig { [::Java::Int, ::Java::Int, Object] }
    def replace(from, to, text)
      replace(DEFAULT_PROGRAM_NAME, from, to, text)
    end
    
    typesig { [Token, Object] }
    def replace(index_t, text)
      replace(DEFAULT_PROGRAM_NAME, index_t, index_t, text)
    end
    
    typesig { [Token, Token, Object] }
    def replace(from, to, text)
      replace(DEFAULT_PROGRAM_NAME, from, to, text)
    end
    
    typesig { [String, ::Java::Int, ::Java::Int, Object] }
    def replace(program_name, from, to, text)
      if (from > to || from < 0 || to < 0 || to >= self.attr_tokens.size)
        raise IllegalArgumentException.new("replace: range invalid: " + RJava.cast_to_string(from) + ".." + RJava.cast_to_string(to) + "(size=" + RJava.cast_to_string(self.attr_tokens.size) + ")")
      end
      op = ReplaceOp.new_local(self, from, to, text)
      rewrites = get_program(program_name)
      op.attr_instruction_index = rewrites.size
      rewrites.add(op)
    end
    
    typesig { [String, Token, Token, Object] }
    def replace(program_name, from, to, text)
      replace(program_name, from.get_token_index, to.get_token_index, text)
    end
    
    typesig { [::Java::Int] }
    def delete(index)
      delete(DEFAULT_PROGRAM_NAME, index, index)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def delete(from, to)
      delete(DEFAULT_PROGRAM_NAME, from, to)
    end
    
    typesig { [Token] }
    def delete(index_t)
      delete(DEFAULT_PROGRAM_NAME, index_t, index_t)
    end
    
    typesig { [Token, Token] }
    def delete(from, to)
      delete(DEFAULT_PROGRAM_NAME, from, to)
    end
    
    typesig { [String, ::Java::Int, ::Java::Int] }
    def delete(program_name, from, to)
      replace(program_name, from, to, nil)
    end
    
    typesig { [String, Token, Token] }
    def delete(program_name, from, to)
      replace(program_name, from, to, nil)
    end
    
    typesig { [] }
    def get_last_rewrite_token_index
      return get_last_rewrite_token_index(DEFAULT_PROGRAM_NAME)
    end
    
    typesig { [String] }
    def get_last_rewrite_token_index(program_name)
      i = @last_rewrite_token_indexes.get(program_name)
      if ((i).nil?)
        return -1
      end
      return i.int_value
    end
    
    typesig { [String, ::Java::Int] }
    def set_last_rewrite_token_index(program_name, i)
      @last_rewrite_token_indexes.put(program_name, i)
    end
    
    typesig { [String] }
    def get_program(name)
      is = @programs.get(name)
      if ((is).nil?)
        is = initialize_program(name)
      end
      return is
    end
    
    typesig { [String] }
    def initialize_program(name)
      is = ArrayList.new(PROGRAM_INIT_SIZE)
      @programs.put(name, is)
      return is
    end
    
    typesig { [] }
    def to_original_string
      return to_original_string(MIN_TOKEN_INDEX, size - 1)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def to_original_string(start, end_)
      buf = StringBuffer.new
      i = start
      while i >= MIN_TOKEN_INDEX && i <= end_ && i < self.attr_tokens.size
        buf.append(get(i).get_text)
        i += 1
      end
      return buf.to_s
    end
    
    typesig { [] }
    def to_s
      return to_s(MIN_TOKEN_INDEX, size - 1)
    end
    
    typesig { [String] }
    def to_s(program_name)
      return to_s(program_name, MIN_TOKEN_INDEX, size - 1)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def to_s(start, end_)
      return to_s(DEFAULT_PROGRAM_NAME, start, end_)
    end
    
    typesig { [String, ::Java::Int, ::Java::Int] }
    def to_s(program_name, start, end_)
      rewrites = @programs.get(program_name)
      # ensure start/end are in range
      if (end_ > self.attr_tokens.size - 1)
        end_ = self.attr_tokens.size - 1
      end
      if (start < 0)
        start = 0
      end
      if ((rewrites).nil? || (rewrites.size).equal?(0))
        return to_original_string(start, end_) # no instructions to execute
      end
      buf = StringBuffer.new
      # First, optimize instruction stream
      index_to_op = reduce_to_single_operation_per_index(rewrites)
      # Walk buffer, executing instructions and emitting tokens
      i = start
      while (i <= end_ && i < self.attr_tokens.size)
        op = index_to_op.get(i)
        index_to_op.remove(i) # remove so any left have index size-1
        t = self.attr_tokens.get(i)
        if ((op).nil?)
          # no operation at that index, just dump token
          buf.append(t.get_text)
          i += 1 # move to next token
        else
          i = op.execute(buf) # execute operation and skip
        end
      end
      # include stuff after end if it's last index in buffer
      # So, if they did an insertAfter(lastValidIndex, "foo"), include
      # foo if end==lastValidIndex.
      if ((end_).equal?(self.attr_tokens.size - 1))
        # Scan any remaining operations after last token
        # should be included (they will be inserts).
        it = index_to_op.values.iterator
        while (it.has_next)
          op = it.next_
          if (op.attr_index >= self.attr_tokens.size - 1)
            buf.append(op.attr_text)
          end
        end
      end
      return buf.to_s
    end
    
    typesig { [JavaList] }
    # We need to combine operations and report invalid operations (like
    # overlapping replaces that are not completed nested).  Inserts to
    # same index need to be combined etc...   Here are the cases:
    # 
    # I.i.u I.j.v								leave alone, nonoverlapping
    # I.i.u I.i.v								combine: Iivu
    # 
    # R.i-j.u R.x-y.v	| i-j in x-y			delete first R
    # R.i-j.u R.i-j.v							delete first R
    # R.i-j.u R.x-y.v	| x-y in i-j			ERROR
    # R.i-j.u R.x-y.v	| boundaries overlap	ERROR
    # 
    # I.i.u R.x-y.v | i in x-y				delete I
    # I.i.u R.x-y.v | i not in x-y			leave alone, nonoverlapping
    # R.x-y.v I.i.u | i in x-y				ERROR
    # R.x-y.v I.x.u 							R.x-y.uv (combine, delete I)
    # R.x-y.v I.i.u | i not in x-y			leave alone, nonoverlapping
    # 
    # I.i.u = insert u before op @ index i
    # R.x-y.u = replace x-y indexed tokens with u
    # 
    # First we need to examine replaces.  For any replace op:
    # 
    # 1. wipe out any insertions before op within that range.
    # 2. Drop any replace op before that is contained completely within
    # that range.
    # 3. Throw exception upon boundary overlap with any previous replace.
    # 
    # Then we can deal with inserts:
    # 
    # 1. for any inserts to same index, combine even if not adjacent.
    # 2. for any prior replace with same left boundary, combine this
    # insert with replace and delete this replace.
    # 3. throw exception if index in same range as previous replace
    # 
    # Don't actually delete; make op null in list. Easier to walk list.
    # Later we can throw as we add to index -> op map.
    # 
    # Note that I.2 R.2-2 will wipe out I.2 even though, technically, the
    # inserted stuff would be before the replace range.  But, if you
    # add tokens in front of a method body '{' and then delete the method
    # body, I think the stuff before the '{' you added should disappear too.
    # 
    # Return a map from token index to operation.
    def reduce_to_single_operation_per_index(rewrites)
      # System.out.println("rewrites="+rewrites);
      # WALK REPLACES
      i = 0
      while i < rewrites.size
        op = rewrites.get(i)
        if ((op).nil?)
          i += 1
          next
        end
        if (!(op.is_a?(ReplaceOp)))
          i += 1
          next
        end
        rop = rewrites.get(i)
        # Wipe prior inserts within range
        inserts = get_kind_of_ops(rewrites, InsertBeforeOp, i)
        j = 0
        while j < inserts.size
          iop = inserts.get(j)
          if (iop.attr_index >= rop.attr_index && iop.attr_index <= rop.attr_last_index)
            # delete insert as it's a no-op.
            rewrites.set(iop.attr_instruction_index, nil)
          end
          j += 1
        end
        # Drop any prior replaces contained within
        prev_replaces = get_kind_of_ops(rewrites, ReplaceOp, i)
        j_ = 0
        while j_ < prev_replaces.size
          prev_rop = prev_replaces.get(j_)
          if (prev_rop.attr_index >= rop.attr_index && prev_rop.attr_last_index <= rop.attr_last_index)
            # delete replace as it's a no-op.
            rewrites.set(prev_rop.attr_instruction_index, nil)
            j_ += 1
            next
          end
          # throw exception unless disjoint or identical
          disjoint = prev_rop.attr_last_index < rop.attr_index || prev_rop.attr_index > rop.attr_last_index
          same = (prev_rop.attr_index).equal?(rop.attr_index) && (prev_rop.attr_last_index).equal?(rop.attr_last_index)
          if (!disjoint && !same)
            raise IllegalArgumentException.new("replace op boundaries of " + RJava.cast_to_string(rop) + " overlap with previous " + RJava.cast_to_string(prev_rop))
          end
          j_ += 1
        end
        i += 1
      end
      # WALK INSERTS
      i_ = 0
      while i_ < rewrites.size
        op = rewrites.get(i_)
        if ((op).nil?)
          i_ += 1
          next
        end
        if (!(op.is_a?(InsertBeforeOp)))
          i_ += 1
          next
        end
        iop = rewrites.get(i_)
        # combine current insert with prior if any at same index
        prev_inserts = get_kind_of_ops(rewrites, InsertBeforeOp, i_)
        j = 0
        while j < prev_inserts.size
          prev_iop = prev_inserts.get(j)
          if ((prev_iop.attr_index).equal?(iop.attr_index))
            # combine objects
            # convert to strings...we're in process of toString'ing
            # whole token buffer so no lazy eval issue with any templates
            iop.attr_text = cat_op_text(iop.attr_text, prev_iop.attr_text)
            # delete redundant prior insert
            rewrites.set(prev_iop.attr_instruction_index, nil)
          end
          j += 1
        end
        # look for replaces where iop.index is in range; error
        prev_replaces = get_kind_of_ops(rewrites, ReplaceOp, i_)
        j_ = 0
        while j_ < prev_replaces.size
          rop = prev_replaces.get(j_)
          if ((iop.attr_index).equal?(rop.attr_index))
            rop.attr_text = cat_op_text(iop.attr_text, rop.attr_text)
            rewrites.set(i_, nil) # delete current insert
            j_ += 1
            next
          end
          if (iop.attr_index >= rop.attr_index && iop.attr_index <= rop.attr_last_index)
            raise IllegalArgumentException.new("insert op " + RJava.cast_to_string(iop) + " within boundaries of previous " + RJava.cast_to_string(rop))
          end
          j_ += 1
        end
        i_ += 1
      end
      # System.out.println("rewrites after="+rewrites);
      m = HashMap.new
      i__ = 0
      while i__ < rewrites.size
        op = rewrites.get(i__)
        if ((op).nil?)
          i__ += 1
          next
        end # ignore deleted ops
        if (!(m.get(op.attr_index)).nil?)
          raise JavaError.new("should only be one op per index")
        end
        m.put(op.attr_index, op)
        i__ += 1
      end
      # System.out.println("index to op: "+m);
      return m
    end
    
    typesig { [Object, Object] }
    def cat_op_text(a, b)
      x = ""
      y = ""
      if (!(a).nil?)
        x = RJava.cast_to_string(a.to_s)
      end
      if (!(b).nil?)
        y = RJava.cast_to_string(b.to_s)
      end
      return x + y
    end
    
    typesig { [JavaList, Class] }
    def get_kind_of_ops(rewrites, kind)
      return get_kind_of_ops(rewrites, kind, rewrites.size)
    end
    
    typesig { [JavaList, Class, ::Java::Int] }
    # Get all operations before an index of a particular kind
    def get_kind_of_ops(rewrites, kind, before)
      ops = ArrayList.new
      i = 0
      while i < before && i < rewrites.size
        op = rewrites.get(i)
        if ((op).nil?)
          i += 1
          next
        end # ignore deleted
        if ((op.get_class).equal?(kind))
          ops.add(op)
        end
        i += 1
      end
      return ops
    end
    
    typesig { [] }
    def to_debug_string
      return to_debug_string(MIN_TOKEN_INDEX, size - 1)
    end
    
    typesig { [::Java::Int, ::Java::Int] }
    def to_debug_string(start, end_)
      buf = StringBuffer.new
      i = start
      while i >= MIN_TOKEN_INDEX && i <= end_ && i < self.attr_tokens.size
        buf.append(get(i))
        i += 1
      end
      return buf.to_s
    end
    
    private
    alias_method :initialize__token_rewrite_stream, :initialize
  end
  
end
