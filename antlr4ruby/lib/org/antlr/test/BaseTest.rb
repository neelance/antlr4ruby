require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2006 Terence Parr
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
module Org::Antlr::Test
  module BaseTestImports #:nodoc:
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Test
      include_const ::Junit::Framework, :TestCase
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Tool, :ErrorManager
      include_const ::Org::Antlr::Tool, :Message
      include_const ::Org::Antlr::Tool, :GrammarSemanticsMessage
      include_const ::Org::Antlr::Tool, :ANTLRErrorListener
      include ::Java::Io
      include ::Java::Util
    }
  end
  
  class BaseTest < BaseTestImports.const_get :TestCase
    include_class_members BaseTestImports
    
    class_module.module_eval {
      const_set_lazy(:Jikes) { nil }
      const_attr_reader  :Jikes
      
      # "/usr/bin/jikes";
      const_set_lazy(:PathSep) { System.get_property("path.separator") }
      const_attr_reader  :PathSep
      
      const_set_lazy(:CLASSPATH) { System.get_property("java.class.path") }
      const_attr_reader  :CLASSPATH
    }
    
    attr_accessor :tmpdir
    alias_method :attr_tmpdir, :tmpdir
    undef_method :tmpdir
    alias_method :attr_tmpdir=, :tmpdir=
    undef_method :tmpdir=
    
    # If error during execution, store stderr here
    attr_accessor :stderr
    alias_method :attr_stderr, :stderr
    undef_method :stderr
    alias_method :attr_stderr=, :stderr=
    undef_method :stderr=
    
    typesig { [] }
    def set_up
      ErrorManager.reset_error_state
    end
    
    typesig { [Array.typed(String)] }
    def new_tool(args)
      tool = Tool.new(args)
      tool.set_output_directory(@tmpdir)
      return tool
    end
    
    typesig { [] }
    def new_tool
      tool = Tool.new
      tool.set_output_directory(@tmpdir)
      return tool
    end
    
    typesig { [String] }
    def compile(file_name)
      compiler = "javac"
      classpath_option = "-classpath"
      if (!(Jikes).nil?)
        compiler = Jikes
        classpath_option = "-bootclasspath"
      end
      args = Array.typed(String).new([compiler, "-d", @tmpdir, classpath_option, @tmpdir + PathSep + CLASSPATH, @tmpdir + "/" + file_name])
      cmd_line = compiler + " -d " + @tmpdir + " " + classpath_option + " " + @tmpdir + PathSep + CLASSPATH + " " + file_name
      # System.out.println("compile: "+cmdLine);
      output_dir = JavaFile.new(@tmpdir)
      begin
        process = Runtime.get_runtime.exec(args, nil, output_dir)
        stdout = StreamVacuum.new(process.get_input_stream)
        stderr = StreamVacuum.new(process.get_error_stream)
        stdout.start
        stderr.start
        process.wait_for
        if (stdout.to_s.length > 0)
          System.err.println("compile stderr from: " + cmd_line)
          System.err.println(stdout)
        end
        if (stderr.to_s.length > 0)
          System.err.println("compile stderr from: " + cmd_line)
          System.err.println(stderr)
        end
        ret = process.exit_value
        return (ret).equal?(0)
      rescue JavaException => e
        System.err.println("can't exec compilation")
        e.print_stack_trace(System.err)
        return false
      end
    end
    
    typesig { [String, String, String, ::Java::Boolean] }
    # Return true if all is ok, no errors
    def antlr(file_name, grammar_file_name, grammar_str, debug)
      all_is_well = true
      mkdir(@tmpdir)
      write_file(@tmpdir, file_name, grammar_str)
      begin
        options = ArrayList.new
        if (debug)
          options.add("-debug")
        end
        options.add("-o")
        options.add(@tmpdir)
        options.add("-lib")
        options.add(@tmpdir)
        options.add(JavaFile.new(@tmpdir, grammar_file_name).to_s)
        options_a = Array.typed(String).new(options.size) { nil }
        options.to_array(options_a)
        # final ErrorQueue equeue = new ErrorQueue();
        # ErrorManager.setErrorListener(equeue);
        antlr = Tool.new(options_a)
        antlr.process
        listener = ErrorManager.get_error_listener
        if (listener.is_a?(ErrorQueue))
          equeue = listener
          if (equeue.attr_errors.size > 0)
            all_is_well = false
            System.err.println("antlr reports errors from " + RJava.cast_to_string(options))
            i = 0
            while i < equeue.attr_errors.size
              msg = equeue.attr_errors.get(i)
              System.err.println(msg)
              i += 1
            end
          end
        end
      rescue JavaException => e
        all_is_well = false
        System.err.println("problems building grammar: " + RJava.cast_to_string(e))
        e.print_stack_trace(System.err)
      end
      return all_is_well
    end
    
    typesig { [String, String, String, String, ::Java::Boolean] }
    def exec_lexer(grammar_file_name, grammar_str, lexer_name, input, debug)
      raw_generate_and_build_recognizer(grammar_file_name, grammar_str, nil, lexer_name, debug)
      write_file(@tmpdir, "input", input)
      return raw_exec_recognizer(nil, nil, lexer_name, nil, nil, false, false, false, debug)
    end
    
    typesig { [String, String, String, String, String, String, ::Java::Boolean] }
    def exec_parser(grammar_file_name, grammar_str, parser_name, lexer_name, start_rule_name, input, debug)
      raw_generate_and_build_recognizer(grammar_file_name, grammar_str, parser_name, lexer_name, debug)
      write_file(@tmpdir, "input", input)
      parser_builds_trees = grammar_str.index_of("output=AST") >= 0 || grammar_str.index_of("output = AST") >= 0
      parser_builds_template = grammar_str.index_of("output=template") >= 0 || grammar_str.index_of("output = template") >= 0
      return raw_exec_recognizer(parser_name, nil, lexer_name, start_rule_name, nil, parser_builds_trees, parser_builds_template, false, debug)
    end
    
    typesig { [String, String, String, String, String, String, String, String, String, String] }
    def exec_tree_parser(parser_grammar_file_name, parser_grammar_str, parser_name, tree_parser_grammar_file_name, tree_parser_grammar_str, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, input)
      return exec_tree_parser(parser_grammar_file_name, parser_grammar_str, parser_name, tree_parser_grammar_file_name, tree_parser_grammar_str, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, input, false)
    end
    
    typesig { [String, String, String, String, String, String, String, String, String, String, ::Java::Boolean] }
    def exec_tree_parser(parser_grammar_file_name, parser_grammar_str, parser_name, tree_parser_grammar_file_name, tree_parser_grammar_str, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, input, debug)
      # build the parser
      raw_generate_and_build_recognizer(parser_grammar_file_name, parser_grammar_str, parser_name, lexer_name, debug)
      # build the tree parser
      raw_generate_and_build_recognizer(tree_parser_grammar_file_name, tree_parser_grammar_str, tree_parser_name, lexer_name, debug)
      write_file(@tmpdir, "input", input)
      parser_builds_trees = parser_grammar_str.index_of("output=AST") >= 0 || parser_grammar_str.index_of("output = AST") >= 0
      tree_parser_builds_trees = tree_parser_grammar_str.index_of("output=AST") >= 0 || tree_parser_grammar_str.index_of("output = AST") >= 0
      parser_builds_template = parser_grammar_str.index_of("output=template") >= 0 || parser_grammar_str.index_of("output = template") >= 0
      return raw_exec_recognizer(parser_name, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, parser_builds_trees, parser_builds_template, tree_parser_builds_trees, debug)
    end
    
    typesig { [String, String, String, String, ::Java::Boolean] }
    # Return true if all is well
    def raw_generate_and_build_recognizer(grammar_file_name, grammar_str, parser_name, lexer_name, debug)
      all_is_well = antlr(grammar_file_name, grammar_file_name, grammar_str, debug)
      if (!(lexer_name).nil?)
        ok = false
        if (!(parser_name).nil?)
          ok = compile(parser_name + ".java")
          if (!ok)
            all_is_well = false
          end
        end
        ok = compile(lexer_name + ".java")
        if (!ok)
          all_is_well = false
        end
      else
        ok = compile(parser_name + ".java")
        if (!ok)
          all_is_well = false
        end
      end
      return all_is_well
    end
    
    typesig { [String, String, String, String, String, ::Java::Boolean, ::Java::Boolean, ::Java::Boolean, ::Java::Boolean] }
    def raw_exec_recognizer(parser_name, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, parser_builds_trees, parser_builds_template, tree_parser_builds_trees, debug)
      if (tree_parser_builds_trees && parser_builds_trees)
        write_tree_and_tree_test_file(parser_name, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, debug)
      else
        if (parser_builds_trees)
          write_tree_test_file(parser_name, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, debug)
        else
          if (parser_builds_template)
            write_template_test_file(parser_name, lexer_name, parser_start_rule_name, debug)
          else
            if ((parser_name).nil?)
              write_lexer_test_file(lexer_name, debug)
            else
              write_test_file(parser_name, lexer_name, parser_start_rule_name, debug)
            end
          end
        end
      end
      compile("Test.java")
      begin
        args = Array.typed(String).new(["java", "-classpath", @tmpdir + PathSep + CLASSPATH, "Test", JavaFile.new(@tmpdir, "input").get_absolute_path])
        cmd_line = "java -classpath " + CLASSPATH + PathSep + @tmpdir + " Test " + RJava.cast_to_string(JavaFile.new(@tmpdir, "input").get_absolute_path)
        # System.out.println("execParser: "+cmdLine);
        @stderr = nil
        process_ = Runtime.get_runtime.exec(args, nil, JavaFile.new(@tmpdir))
        stdout_vacuum = StreamVacuum.new(process_.get_input_stream)
        stderr_vacuum = StreamVacuum.new(process_.get_error_stream)
        stdout_vacuum.start
        stderr_vacuum.start
        process_.wait_for
        stdout_vacuum.join
        stderr_vacuum.join
        output = nil
        output = RJava.cast_to_string(stdout_vacuum.to_s)
        if (stderr_vacuum.to_s.length > 0)
          @stderr = stderr_vacuum.to_s
          System.err.println("exec stderrVacuum: " + RJava.cast_to_string(stderr_vacuum))
        end
        return output
      rescue JavaException => e
        System.err.println("can't exec recognizer")
        e.print_stack_trace(System.err)
      end
      return nil
    end
    
    typesig { [ErrorQueue, GrammarSemanticsMessage] }
    def check_grammar_semantics_error(equeue, expected_message)
      # System.out.println(equeue.infos);
      # System.out.println(equeue.warnings);
      # System.out.println(equeue.errors);
      # assertTrue("number of errors mismatch", n, equeue.errors.size());
      found_msg = nil
      i = 0
      while i < equeue.attr_errors.size
        m = equeue.attr_errors.get(i)
        if ((m.attr_msg_id).equal?(expected_message.attr_msg_id))
          found_msg = m
        end
        i += 1
      end
      assert_not_null("no error; " + RJava.cast_to_string(expected_message.attr_msg_id) + " expected", found_msg)
      assert_true("error is not a GrammarSemanticsMessage", found_msg.is_a?(GrammarSemanticsMessage))
      assert_equals(expected_message.attr_arg, found_msg.attr_arg)
      if (!(equeue.size).equal?(1))
        System.err.println(equeue)
      end
    end
    
    typesig { [ErrorQueue, GrammarSemanticsMessage] }
    def check_grammar_semantics_warning(equeue, expected_message)
      found_msg = nil
      i = 0
      while i < equeue.attr_warnings.size
        m = equeue.attr_warnings.get(i)
        if ((m.attr_msg_id).equal?(expected_message.attr_msg_id))
          found_msg = m
        end
        i += 1
      end
      assert_not_null("no error; " + RJava.cast_to_string(expected_message.attr_msg_id) + " expected", found_msg)
      assert_true("error is not a GrammarSemanticsMessage", found_msg.is_a?(GrammarSemanticsMessage))
      assert_equals(expected_message.attr_arg, found_msg.attr_arg)
    end
    
    class_module.module_eval {
      const_set_lazy(:StreamVacuum) { Class.new do
        include_class_members BaseTest
        include Runnable
        
        attr_accessor :buf
        alias_method :attr_buf, :buf
        undef_method :buf
        alias_method :attr_buf=, :buf=
        undef_method :buf=
        
        attr_accessor :in
        alias_method :attr_in, :in
        undef_method :in
        alias_method :attr_in=, :in=
        undef_method :in=
        
        attr_accessor :sucker
        alias_method :attr_sucker, :sucker
        undef_method :sucker
        alias_method :attr_sucker=, :sucker=
        undef_method :sucker=
        
        typesig { [class_self::InputStream] }
        def initialize(in_)
          @buf = self.class::StringBuffer.new
          @in = nil
          @sucker = nil
          @in = self.class::BufferedReader.new(self.class::InputStreamReader.new(in_))
        end
        
        typesig { [] }
        def start
          @sucker = self.class::JavaThread.new(self)
          @sucker.start
        end
        
        typesig { [] }
        def run
          begin
            line = @in.read_line
            while (!(line).nil?)
              @buf.append(line)
              @buf.append(Character.new(?\n.ord))
              line = RJava.cast_to_string(@in.read_line)
            end
          rescue self.class::IOException => ioe
            System.err.println("can't read output from process")
          end
        end
        
        typesig { [] }
        # wait for the thread to finish
        def join
          @sucker.join
        end
        
        typesig { [] }
        def to_s
          return @buf.to_s
        end
        
        private
        alias_method :initialize__stream_vacuum, :initialize
      end }
    }
    
    typesig { [String, String, String] }
    def write_file(dir, file_name, content)
      begin
        f = JavaFile.new(dir, file_name)
        w = FileWriter.new(f)
        bw = BufferedWriter.new(w)
        bw.write(content)
        bw.close
        w.close
      rescue IOException => ioe
        System.err.println("can't write file")
        ioe.print_stack_trace(System.err)
      end
    end
    
    typesig { [String] }
    def mkdir(dir)
      f = JavaFile.new(dir)
      f.mkdirs
    end
    
    typesig { [String, String, String, ::Java::Boolean] }
    def write_test_file(parser_name, lexer_name, parser_start_rule_name, debug)
      output_file_st = StringTemplate.new("import org.antlr.runtime.*;\n" + "import org.antlr.runtime.tree.*;\n" + "import org.antlr.runtime.debug.*;\n" + "\n" + "class Profiler2 extends Profiler {\n" + "    public void terminate() { ; }\n" + "}\n" + "public class Test {\n" + "    public static void main(String[] args) throws Exception {\n" + "        CharStream input = new ANTLRFileStream(args[0]);\n" + "        $lexerName$ lex = new $lexerName$(input);\n" + "        CommonTokenStream tokens = new CommonTokenStream(lex);\n" + "        $createParser$\n" + "        parser.$parserStartRuleName$();\n" + "    }\n" + "}")
      create_parser_st = StringTemplate.new("        Profiler2 profiler = new Profiler2();\n" + "        $parserName$ parser = new $parserName$(tokens,profiler);\n" + "        profiler.setParser(parser);\n")
      if (!debug)
        create_parser_st = StringTemplate.new("        $parserName$ parser = new $parserName$(tokens);\n")
      end
      output_file_st.set_attribute("createParser", create_parser_st)
      output_file_st.set_attribute("parserName", parser_name)
      output_file_st.set_attribute("lexerName", lexer_name)
      output_file_st.set_attribute("parserStartRuleName", parser_start_rule_name)
      write_file(@tmpdir, "Test.java", output_file_st.to_s)
    end
    
    typesig { [String, ::Java::Boolean] }
    def write_lexer_test_file(lexer_name, debug)
      output_file_st = StringTemplate.new("import org.antlr.runtime.*;\n" + "import org.antlr.runtime.tree.*;\n" + "import org.antlr.runtime.debug.*;\n" + "\n" + "class Profiler2 extends Profiler {\n" + "    public void terminate() { ; }\n" + "}\n" + "public class Test {\n" + "    public static void main(String[] args) throws Exception {\n" + "        CharStream input = new ANTLRFileStream(args[0]);\n" + "        $lexerName$ lex = new $lexerName$(input);\n" + "        CommonTokenStream tokens = new CommonTokenStream(lex);\n" + "        System.out.println(tokens);\n" + "    }\n" + "}")
      output_file_st.set_attribute("lexerName", lexer_name)
      write_file(@tmpdir, "Test.java", output_file_st.to_s)
    end
    
    typesig { [String, String, String, String, String, ::Java::Boolean] }
    def write_tree_test_file(parser_name, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, debug)
      output_file_st = StringTemplate.new("import org.antlr.runtime.*;\n" + "import org.antlr.runtime.tree.*;\n" + "import org.antlr.runtime.debug.*;\n" + "\n" + "class Profiler2 extends Profiler {\n" + "    public void terminate() { ; }\n" + "}\n" + "public class Test {\n" + "    public static void main(String[] args) throws Exception {\n" + "        CharStream input = new ANTLRFileStream(args[0]);\n" + "        $lexerName$ lex = new $lexerName$(input);\n" + "        TokenRewriteStream tokens = new TokenRewriteStream(lex);\n" + "        $createParser$\n" + "        $parserName$.$parserStartRuleName$_return r = parser.$parserStartRuleName$();\n" + "        $if(!treeParserStartRuleName)$\n" + "        if ( r.tree!=null ) {\n" + "            System.out.println(((Tree)r.tree).toStringTree());\n" + "            ((CommonTree)r.tree).sanityCheckParentAndChildIndexes();\n" + "		 }\n" + "        $else$\n" + "        CommonTreeNodeStream nodes = new CommonTreeNodeStream((Tree)r.tree);\n" + "        nodes.setTokenStream(tokens);\n" + "        $treeParserName$ walker = new $treeParserName$(nodes);\n" + "        walker.$treeParserStartRuleName$();\n" + "        $endif$\n" + "    }\n" + "}")
      create_parser_st = StringTemplate.new("        Profiler2 profiler = new Profiler2();\n" + "        $parserName$ parser = new $parserName$(tokens,profiler);\n" + "        profiler.setParser(parser);\n")
      if (!debug)
        create_parser_st = StringTemplate.new("        $parserName$ parser = new $parserName$(tokens);\n")
      end
      output_file_st.set_attribute("createParser", create_parser_st)
      output_file_st.set_attribute("parserName", parser_name)
      output_file_st.set_attribute("treeParserName", tree_parser_name)
      output_file_st.set_attribute("lexerName", lexer_name)
      output_file_st.set_attribute("parserStartRuleName", parser_start_rule_name)
      output_file_st.set_attribute("treeParserStartRuleName", tree_parser_start_rule_name)
      write_file(@tmpdir, "Test.java", output_file_st.to_s)
    end
    
    typesig { [String, String, String, String, String, ::Java::Boolean] }
    # Parser creates trees and so does the tree parser
    def write_tree_and_tree_test_file(parser_name, tree_parser_name, lexer_name, parser_start_rule_name, tree_parser_start_rule_name, debug)
      output_file_st = StringTemplate.new("import org.antlr.runtime.*;\n" + "import org.antlr.runtime.tree.*;\n" + "import org.antlr.runtime.debug.*;\n" + "\n" + "class Profiler2 extends Profiler {\n" + "    public void terminate() { ; }\n" + "}\n" + "public class Test {\n" + "    public static void main(String[] args) throws Exception {\n" + "        CharStream input = new ANTLRFileStream(args[0]);\n" + "        $lexerName$ lex = new $lexerName$(input);\n" + "        TokenRewriteStream tokens = new TokenRewriteStream(lex);\n" + "        $createParser$\n" + "        $parserName$.$parserStartRuleName$_return r = parser.$parserStartRuleName$();\n" + "        ((CommonTree)r.tree).sanityCheckParentAndChildIndexes();\n" + "        CommonTreeNodeStream nodes = new CommonTreeNodeStream((Tree)r.tree);\n" + "        nodes.setTokenStream(tokens);\n" + "        $treeParserName$ walker = new $treeParserName$(nodes);\n" + "        $treeParserName$.$treeParserStartRuleName$_return r2 = walker.$treeParserStartRuleName$();\n" + "		 CommonTree rt = ((CommonTree)r2.tree);\n" + "		 if ( rt!=null ) System.out.println(((CommonTree)r2.tree).toStringTree());\n" + "    }\n" + "}")
      create_parser_st = StringTemplate.new("        Profiler2 profiler = new Profiler2();\n" + "        $parserName$ parser = new $parserName$(tokens,profiler);\n" + "        profiler.setParser(parser);\n")
      if (!debug)
        create_parser_st = StringTemplate.new("        $parserName$ parser = new $parserName$(tokens);\n")
      end
      output_file_st.set_attribute("createParser", create_parser_st)
      output_file_st.set_attribute("parserName", parser_name)
      output_file_st.set_attribute("treeParserName", tree_parser_name)
      output_file_st.set_attribute("lexerName", lexer_name)
      output_file_st.set_attribute("parserStartRuleName", parser_start_rule_name)
      output_file_st.set_attribute("treeParserStartRuleName", tree_parser_start_rule_name)
      write_file(@tmpdir, "Test.java", output_file_st.to_s)
    end
    
    typesig { [String, String, String, ::Java::Boolean] }
    def write_template_test_file(parser_name, lexer_name, parser_start_rule_name, debug)
      output_file_st = StringTemplate.new("import org.antlr.runtime.*;\n" + "import org.antlr.stringtemplate.*;\n" + "import org.antlr.stringtemplate.language.*;\n" + "import org.antlr.runtime.debug.*;\n" + "import java.io.*;\n" + "\n" + "class Profiler2 extends Profiler {\n" + "    public void terminate() { ; }\n" + "}\n" + "public class Test {\n" + "    static String templates =\n" + "    		\"group test;\"+" + "    		\"foo(x,y) ::= \\\"<x> <y>\\\"\";\n" + "    static StringTemplateGroup group =" + "    		new StringTemplateGroup(new StringReader(templates)," + "					AngleBracketTemplateLexer.class);" + "    public static void main(String[] args) throws Exception {\n" + "        CharStream input = new ANTLRFileStream(args[0]);\n" + "        $lexerName$ lex = new $lexerName$(input);\n" + "        CommonTokenStream tokens = new CommonTokenStream(lex);\n" + "        $createParser$\n" + "		 parser.setTemplateLib(group);\n" + "        $parserName$.$parserStartRuleName$_return r = parser.$parserStartRuleName$();\n" + "        if ( r.st!=null )\n" + "            System.out.print(r.st.toString());\n" + "	 	 else\n" + "            System.out.print(\"\");\n" + "    }\n" + "}")
      create_parser_st = StringTemplate.new("        Profiler2 profiler = new Profiler2();\n" + "        $parserName$ parser = new $parserName$(tokens,profiler);\n" + "        profiler.setParser(parser);\n")
      if (!debug)
        create_parser_st = StringTemplate.new("        $parserName$ parser = new $parserName$(tokens);\n")
      end
      output_file_st.set_attribute("createParser", create_parser_st)
      output_file_st.set_attribute("parserName", parser_name)
      output_file_st.set_attribute("lexerName", lexer_name)
      output_file_st.set_attribute("parserStartRuleName", parser_start_rule_name)
      write_file(@tmpdir, "Test.java", output_file_st.to_s)
    end
    
    typesig { [String] }
    def erase_files(files_ending_with)
      tmpdir_f = JavaFile.new(@tmpdir)
      files = tmpdir_f.list
      i = 0
      while !(files).nil? && i < files.attr_length
        if (files[i].ends_with(files_ending_with))
          JavaFile.new(@tmpdir + "/" + RJava.cast_to_string(files[i])).delete
        end
        i += 1
      end
    end
    
    typesig { [] }
    def get_first_line_of_exception
      if ((@stderr).nil?)
        return nil
      end
      lines = @stderr.split(Regexp.new("\n"))
      prefix = "Exception in thread \"main\" "
      return lines[0].substring(prefix.length, lines[0].length)
    end
    
    typesig { [JavaList] }
    def real_elements(elements)
      n = ArrayList.new
      i = Label::NUM_FAUX_LABELS + Label::MIN_TOKEN_TYPE - 1
      while i < elements.size
        o = elements.get(i)
        if (!(o).nil?)
          n.add(o)
        end
        i += 1
      end
      return n
    end
    
    typesig { [Map] }
    def real_elements(elements)
      n = ArrayList.new
      iterator = elements.key_set.iterator
      while (iterator.has_next)
        token_id = iterator.next_
        if (elements.get(token_id) >= Label::MIN_TOKEN_TYPE)
          n.add(token_id + "=" + RJava.cast_to_string(elements.get(token_id)))
        end
      end
      Collections.sort(n)
      return n
    end
    
    typesig { [] }
    def initialize
      @tmpdir = nil
      @stderr = nil
      super()
      @tmpdir = JavaFile.new(System.get_property("java.io.tmpdir"), "antlr-" + RJava.cast_to_string(System.current_time_millis)).get_absolute_path
    end
    
    private
    alias_method :initialize__base_test, :initialize
  end
  
end
