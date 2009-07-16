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
module Org::Antlr::Tool
  module BuildDependencyGeneratorImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Misc, :Utils
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateGroup
      include_const ::Org::Antlr::Stringtemplate::Language, :AngleBracketTemplateLexer
      include_const ::Java::Util, :JavaList
      include_const ::Java::Util, :ArrayList
      include ::Java::Io
    }
  end
  
  # Given a grammar file, show the dependencies on .tokens etc...
  # Using ST, emit a simple "make compatible" list of dependencies.
  # For example, combined grammar T.g (no token import) generates:
  # 
  # TParser.java : T.g
  # T.tokens : T.g
  # T__g : T.g
  # 
  # For tree grammar TP with import of T.tokens:
  # 
  # TP.g : T.tokens
  # TP.java : TP.g
  # 
  # If "-lib libdir" is used on command-line with -depend, then include the
  # path like
  # 
  # TP.g : libdir/T.tokens
  # 
  # Pay attention to -o as well:
  # 
  # outputdir/TParser.java : T.g
  # 
  # So this output shows what the grammar depends on *and* what it generates.
  # 
  # Operate on one grammar file at a time.  If given a list of .g on the
  # command-line with -depend, just emit the dependencies.  The grammars
  # may depend on each other, but the order doesn't matter.  Build tools,
  # reading in this output, will know how to organize it.
  # 
  # This is a wee bit slow probably because the code generator has to load
  # all of its template files in order to figure out the file extension
  # for the generated recognizer.
  # 
  # This code was obvious until I removed redundant "./" on front of files
  # and had to escape spaces in filenames :(
  class BuildDependencyGenerator 
    include_class_members BuildDependencyGeneratorImports
    
    attr_accessor :grammar_file_name
    alias_method :attr_grammar_file_name, :grammar_file_name
    undef_method :grammar_file_name
    alias_method :attr_grammar_file_name=, :grammar_file_name=
    undef_method :grammar_file_name=
    
    attr_accessor :tool
    alias_method :attr_tool, :tool
    undef_method :tool
    alias_method :attr_tool=, :tool=
    undef_method :tool=
    
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    attr_accessor :generator
    alias_method :attr_generator, :generator
    undef_method :generator
    alias_method :attr_generator=, :generator=
    undef_method :generator=
    
    attr_accessor :templates
    alias_method :attr_templates, :templates
    undef_method :templates
    alias_method :attr_templates=, :templates=
    undef_method :templates=
    
    typesig { [Tool, String] }
    def initialize(tool, grammar_file_name)
      @grammar_file_name = nil
      @tool = nil
      @grammar = nil
      @generator = nil
      @templates = nil
      @tool = tool
      @grammar_file_name = grammar_file_name
      @grammar = tool.get_root_grammar(grammar_file_name)
      language = @grammar.get_option("language")
      @generator = CodeGenerator.new(tool, @grammar, language)
      @generator.load_templates(language)
    end
    
    typesig { [] }
    # From T.g return a list of File objects that
    # name files ANTLR will emit from T.g.
    def get_generated_file_list
      files = ArrayList.new
      output_dir = @tool.get_output_directory(@grammar_file_name)
      if ((output_dir.get_name == "."))
        output_dir = nil
      else
        if (output_dir.get_name.index_of(Character.new(?\s.ord)) >= 0)
          # has spaces?
          esc_spaces = Utils.replace(output_dir.to_s, " ", "\\ ")
          output_dir = JavaFile.new(esc_spaces)
        end
      end
      # add generated recognizer; e.g., TParser.java
      recognizer = @generator.get_recognizer_file_name(@grammar.attr_name, @grammar.attr_type)
      files.add(JavaFile.new(output_dir, recognizer))
      # add output vocab file; e.g., T.tokens
      files.add(JavaFile.new(output_dir, @generator.get_vocab_file_name))
      # are we generating a .h file?
      header_ext_st = nil
      if (@generator.get_templates.is_defined("headerFile"))
        header_ext_st = @generator.get_templates.get_instance_of("headerFileExtension")
        suffix = Grammar.attr_grammar_type_to_file_name_suffix[@grammar.attr_type]
        file_name = (@grammar.attr_name).to_s + suffix + (header_ext_st.to_s).to_s
        files.add(JavaFile.new(output_dir, file_name))
      end
      if ((@grammar.attr_type).equal?(Grammar::COMBINED))
        # add autogenerated lexer; e.g., TLexer.java TLexer.h TLexer.tokens
        # don't add T__.g (just a temp file)
        ext_st = @generator.get_templates.get_instance_of("codeFileExtension")
        suffix_ = Grammar.attr_grammar_type_to_file_name_suffix[Grammar::LEXER]
        lexer = (@grammar.attr_name).to_s + suffix_ + (ext_st.to_s).to_s
        files.add(JavaFile.new(output_dir, lexer))
        # TLexer.h
        if (!(header_ext_st).nil?)
          header = (@grammar.attr_name).to_s + suffix_ + (header_ext_st.to_s).to_s
          files.add(JavaFile.new(output_dir, header))
        end
        # for combined, don't generate TLexer.tokens
      end
      # handle generated files for imported grammars
      imports = @grammar.attr_composite.get_delegates(@grammar.attr_composite.get_root_grammar)
      imports.each do |g|
        output_dir = @tool.get_output_directory(g.get_file_name)
        fname = groom_qualified_file_name(output_dir.to_s, g.get_recognizer_name)
        files.add(JavaFile.new(fname))
      end
      if ((files.size).equal?(0))
        return nil
      end
      return files
    end
    
    typesig { [] }
    # Return a list of File objects that name files ANTLR will read
    # to process T.g; for now, this can only be .tokens files and only
    # if they use the tokenVocab option.
    def get_dependencies_file_list
      files = ArrayList.new
      # handle token vocabulary loads
      vocab_name = @grammar.get_option("tokenVocab")
      if (!(vocab_name).nil?)
        vocab_file = @tool.get_imported_vocab_file(vocab_name)
        output_dir = vocab_file.get_parent_file
        file_name = groom_qualified_file_name(output_dir.get_name, vocab_file.get_name)
        files.add(file_name)
      end
      # handle imported grammars
      imports = @grammar.attr_composite.get_delegates(@grammar.attr_composite.get_root_grammar)
      imports.each do |g|
        libdir = @tool.get_library_directory
        file_name_ = groom_qualified_file_name(libdir, g.attr_file_name)
        files.add(file_name_)
      end
      if ((files.size).equal?(0))
        return nil
      end
      return files
    end
    
    typesig { [] }
    def get_dependencies
      load_dependency_templates
      dependencies_st = @templates.get_instance_of("dependencies")
      dependencies_st.set_attribute("in", get_dependencies_file_list)
      dependencies_st.set_attribute("out", get_generated_file_list)
      dependencies_st.set_attribute("grammarFileName", @grammar.attr_file_name)
      return dependencies_st
    end
    
    typesig { [] }
    def load_dependency_templates
      if (!(@templates).nil?)
        return
      end
      file_name = "org/antlr/tool/templates/depend.stg"
      cl = JavaThread.current_thread.get_context_class_loader
      is = cl.get_resource_as_stream(file_name)
      if ((is).nil?)
        cl = ErrorManager.class.get_class_loader
        is = cl.get_resource_as_stream(file_name)
      end
      if ((is).nil?)
        ErrorManager.internal_error("Can't load dependency templates: " + file_name)
        return
      end
      br = nil
      begin
        br = BufferedReader.new(InputStreamReader.new(is))
        @templates = StringTemplateGroup.new(br, AngleBracketTemplateLexer.class)
        br.close
      rescue IOException => ioe
        ErrorManager.internal_error("error reading dependency templates file " + file_name, ioe)
      ensure
        if (!(br).nil?)
          begin
            br.close
          rescue IOException => ioe
            ErrorManager.internal_error("cannot close dependency templates file " + file_name, ioe_)
          end
        end
      end
    end
    
    typesig { [String, String] }
    def groom_qualified_file_name(output_dir, file_name)
      if ((output_dir == "."))
        return file_name
      else
        if (output_dir.index_of(Character.new(?\s.ord)) >= 0)
          # has spaces?
          esc_spaces = Utils.replace(output_dir.to_s, " ", "\\ ")
          return esc_spaces + (JavaFile.attr_separator).to_s + file_name
        else
          return output_dir + (JavaFile.attr_separator).to_s + file_name
        end
      end
    end
    
    private
    alias_method :initialize__build_dependency_generator, :initialize
  end
  
end
