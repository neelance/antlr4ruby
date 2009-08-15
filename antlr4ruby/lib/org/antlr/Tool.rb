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
module Org::Antlr
  module ToolImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Runtime::Misc, :Stats
      include ::Org::Antlr::Tool
      include ::Java::Io
      include ::Java::Util
    }
  end
  
  # The main ANTLR entry point.  Read a grammar and generate a parser.
  class Tool 
    include_class_members ToolImports
    
    class_module.module_eval {
      const_set_lazy(:REV) { "" }
      const_attr_reader  :REV
      
      const_set_lazy(:VERSION) { "3.1.1" + REV }
      const_attr_reader  :VERSION
      
      const_set_lazy(:UNINITIALIZED_DIR) { "<unset-dir>" }
      const_attr_reader  :UNINITIALIZED_DIR
    }
    
    # Input parameters / option
    attr_accessor :grammar_file_names
    alias_method :attr_grammar_file_names, :grammar_file_names
    undef_method :grammar_file_names
    alias_method :attr_grammar_file_names=, :grammar_file_names=
    undef_method :grammar_file_names=
    
    attr_accessor :generate_nfa_dot
    alias_method :attr_generate_nfa_dot, :generate_nfa_dot
    undef_method :generate_nfa_dot
    alias_method :attr_generate_nfa_dot=, :generate_nfa_dot=
    undef_method :generate_nfa_dot=
    
    attr_accessor :generate_dfa_dot
    alias_method :attr_generate_dfa_dot, :generate_dfa_dot
    undef_method :generate_dfa_dot
    alias_method :attr_generate_dfa_dot=, :generate_dfa_dot=
    undef_method :generate_dfa_dot=
    
    attr_accessor :output_directory
    alias_method :attr_output_directory, :output_directory
    undef_method :output_directory
    alias_method :attr_output_directory=, :output_directory=
    undef_method :output_directory=
    
    attr_accessor :lib_directory
    alias_method :attr_lib_directory, :lib_directory
    undef_method :lib_directory
    alias_method :attr_lib_directory=, :lib_directory=
    undef_method :lib_directory=
    
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    attr_accessor :trace
    alias_method :attr_trace, :trace
    undef_method :trace
    alias_method :attr_trace=, :trace=
    undef_method :trace=
    
    attr_accessor :profile
    alias_method :attr_profile, :profile
    undef_method :profile
    alias_method :attr_profile=, :profile=
    undef_method :profile=
    
    attr_accessor :report
    alias_method :attr_report, :report
    undef_method :report
    alias_method :attr_report=, :report=
    undef_method :report=
    
    attr_accessor :print_grammar
    alias_method :attr_print_grammar, :print_grammar
    undef_method :print_grammar
    alias_method :attr_print_grammar=, :print_grammar=
    undef_method :print_grammar=
    
    attr_accessor :depend
    alias_method :attr_depend, :depend
    undef_method :depend
    alias_method :attr_depend=, :depend=
    undef_method :depend=
    
    attr_accessor :force_all_files_to_output_dir
    alias_method :attr_force_all_files_to_output_dir, :force_all_files_to_output_dir
    undef_method :force_all_files_to_output_dir
    alias_method :attr_force_all_files_to_output_dir=, :force_all_files_to_output_dir=
    undef_method :force_all_files_to_output_dir=
    
    attr_accessor :delete_temp_lexer
    alias_method :attr_delete_temp_lexer, :delete_temp_lexer
    undef_method :delete_temp_lexer
    alias_method :attr_delete_temp_lexer=, :delete_temp_lexer=
    undef_method :delete_temp_lexer=
    
    class_module.module_eval {
      # the internal options are for my use on the command line during dev
      
      def internal_option_print_grammar_tree
        defined?(@@internal_option_print_grammar_tree) ? @@internal_option_print_grammar_tree : @@internal_option_print_grammar_tree= false
      end
      alias_method :attr_internal_option_print_grammar_tree, :internal_option_print_grammar_tree
      
      def internal_option_print_grammar_tree=(value)
        @@internal_option_print_grammar_tree = value
      end
      alias_method :attr_internal_option_print_grammar_tree=, :internal_option_print_grammar_tree=
      
      
      def internal_option_print_dfa
        defined?(@@internal_option_print_dfa) ? @@internal_option_print_dfa : @@internal_option_print_dfa= false
      end
      alias_method :attr_internal_option_print_dfa, :internal_option_print_dfa
      
      def internal_option_print_dfa=(value)
        @@internal_option_print_dfa = value
      end
      alias_method :attr_internal_option_print_dfa=, :internal_option_print_dfa=
      
      
      def internal_option_show_nfaconfigs_in_dfa
        defined?(@@internal_option_show_nfaconfigs_in_dfa) ? @@internal_option_show_nfaconfigs_in_dfa : @@internal_option_show_nfaconfigs_in_dfa= false
      end
      alias_method :attr_internal_option_show_nfaconfigs_in_dfa, :internal_option_show_nfaconfigs_in_dfa
      
      def internal_option_show_nfaconfigs_in_dfa=(value)
        @@internal_option_show_nfaconfigs_in_dfa = value
      end
      alias_method :attr_internal_option_show_nfaconfigs_in_dfa=, :internal_option_show_nfaconfigs_in_dfa=
      
      
      def internal_option_watch_nfaconversion
        defined?(@@internal_option_watch_nfaconversion) ? @@internal_option_watch_nfaconversion : @@internal_option_watch_nfaconversion= false
      end
      alias_method :attr_internal_option_watch_nfaconversion, :internal_option_watch_nfaconversion
      
      def internal_option_watch_nfaconversion=(value)
        @@internal_option_watch_nfaconversion = value
      end
      alias_method :attr_internal_option_watch_nfaconversion=, :internal_option_watch_nfaconversion=
      
      typesig { [Array.typed(String)] }
      def main(args)
        ErrorManager.info("ANTLR Parser Generator  Version " + VERSION) # + " (August 12, 2008)  1989-2008");
        antlr = Tool.new(args)
        antlr.process
        if (ErrorManager.get_num_errors > 0)
          System.exit(1)
        end
        System.exit(0)
      end
    }
    
    typesig { [] }
    def initialize
      @grammar_file_names = ArrayList.new
      @generate_nfa_dot = false
      @generate_dfa_dot = false
      @output_directory = UNINITIALIZED_DIR
      @lib_directory = "."
      @debug = false
      @trace = false
      @profile = false
      @report = false
      @print_grammar = false
      @depend = false
      @force_all_files_to_output_dir = false
      @delete_temp_lexer = true
    end
    
    typesig { [Array.typed(String)] }
    def initialize(args)
      @grammar_file_names = ArrayList.new
      @generate_nfa_dot = false
      @generate_dfa_dot = false
      @output_directory = UNINITIALIZED_DIR
      @lib_directory = "."
      @debug = false
      @trace = false
      @profile = false
      @report = false
      @print_grammar = false
      @depend = false
      @force_all_files_to_output_dir = false
      @delete_temp_lexer = true
      process_args(args)
    end
    
    typesig { [Array.typed(String)] }
    def process_args(args)
      if ((args).nil? || (args.attr_length).equal?(0))
        help
        return
      end
      i = 0
      while i < args.attr_length
        if ((args[i] == "-o") || (args[i] == "-fo"))
          if (i + 1 >= args.attr_length)
            System.err.println("missing output directory with -fo/-o option; ignoring")
          else
            if ((args[i] == "-fo"))
              # force output into dir
              @force_all_files_to_output_dir = true
            end
            i += 1
            @output_directory = RJava.cast_to_string(args[i])
            if (@output_directory.ends_with("/") || @output_directory.ends_with("\\"))
              @output_directory = RJava.cast_to_string(@output_directory.substring(0, @output_directory.length - 1))
            end
            out_dir = JavaFile.new(@output_directory)
            if (out_dir.exists && !out_dir.is_directory)
              ErrorManager.error(ErrorManager::MSG_OUTPUT_DIR_IS_FILE, @output_directory)
              @lib_directory = "."
            end
          end
        else
          if ((args[i] == "-lib"))
            if (i + 1 >= args.attr_length)
              System.err.println("missing library directory with -lib option; ignoring")
            else
              i += 1
              @lib_directory = RJava.cast_to_string(args[i])
              if (@lib_directory.ends_with("/") || @lib_directory.ends_with("\\"))
                @lib_directory = RJava.cast_to_string(@lib_directory.substring(0, @lib_directory.length - 1))
              end
              out_dir = JavaFile.new(@lib_directory)
              if (!out_dir.exists)
                ErrorManager.error(ErrorManager::MSG_DIR_NOT_FOUND, @lib_directory)
                @lib_directory = "."
              end
            end
          else
            if ((args[i] == "-nfa"))
              @generate_nfa_dot = true
            else
              if ((args[i] == "-dfa"))
                @generate_dfa_dot = true
              else
                if ((args[i] == "-debug"))
                  @debug = true
                else
                  if ((args[i] == "-trace"))
                    @trace = true
                  else
                    if ((args[i] == "-report"))
                      @report = true
                    else
                      if ((args[i] == "-profile"))
                        @profile = true
                      else
                        if ((args[i] == "-print"))
                          @print_grammar = true
                        else
                          if ((args[i] == "-depend"))
                            @depend = true
                          else
                            if ((args[i] == "-message-format"))
                              if (i + 1 >= args.attr_length)
                                System.err.println("missing output format with -message-format option; using default")
                              else
                                i += 1
                                ErrorManager.set_format(args[i])
                              end
                            else
                              if ((args[i] == "-Xgrtree"))
                                self.attr_internal_option_print_grammar_tree = true # print grammar tree
                              else
                                if ((args[i] == "-Xdfa"))
                                  self.attr_internal_option_print_dfa = true
                                else
                                  if ((args[i] == "-Xnoprune"))
                                    DFAOptimizer::PRUNE_EBNF_EXIT_BRANCHES = false
                                  else
                                    if ((args[i] == "-Xnocollapse"))
                                      DFAOptimizer::COLLAPSE_ALL_PARALLEL_EDGES = false
                                    else
                                      if ((args[i] == "-Xdbgconversion"))
                                        NFAToDFAConverter.attr_debug = true
                                      else
                                        if ((args[i] == "-Xmultithreaded"))
                                          NFAToDFAConverter::SINGLE_THREADED_NFA_CONVERSION = false
                                        else
                                          if ((args[i] == "-Xnomergestopstates"))
                                            DFAOptimizer::MERGE_STOP_STATES = false
                                          else
                                            if ((args[i] == "-Xdfaverbose"))
                                              self.attr_internal_option_show_nfaconfigs_in_dfa = true
                                            else
                                              if ((args[i] == "-Xwatchconversion"))
                                                self.attr_internal_option_watch_nfaconversion = true
                                              else
                                                if ((args[i] == "-XdbgST"))
                                                  CodeGenerator::EMIT_TEMPLATE_DELIMITERS = true
                                                else
                                                  if ((args[i] == "-Xmaxinlinedfastates"))
                                                    if (i + 1 >= args.attr_length)
                                                      System.err.println("missing max inline dfa states -Xmaxinlinedfastates option; ignoring")
                                                    else
                                                      i += 1
                                                      CodeGenerator::MAX_ACYCLIC_DFA_STATES_INLINE = JavaInteger.parse_int(args[i])
                                                    end
                                                  else
                                                    if ((args[i] == "-Xm"))
                                                      if (i + 1 >= args.attr_length)
                                                        System.err.println("missing max recursion with -Xm option; ignoring")
                                                      else
                                                        i += 1
                                                        NFAContext::MAX_SAME_RULE_INVOCATIONS_PER_NFA_CONFIG_STACK = JavaInteger.parse_int(args[i])
                                                      end
                                                    else
                                                      if ((args[i] == "-Xmaxdfaedges"))
                                                        if (i + 1 >= args.attr_length)
                                                          System.err.println("missing max number of edges with -Xmaxdfaedges option; ignoring")
                                                        else
                                                          i += 1
                                                          DFA::MAX_STATE_TRANSITIONS_FOR_TABLE = JavaInteger.parse_int(args[i])
                                                        end
                                                      else
                                                        if ((args[i] == "-Xconversiontimeout"))
                                                          if (i + 1 >= args.attr_length)
                                                            System.err.println("missing max time in ms -Xconversiontimeout option; ignoring")
                                                          else
                                                            i += 1
                                                            DFA::MAX_TIME_PER_DFA_CREATION = JavaInteger.parse_int(args[i])
                                                          end
                                                        else
                                                          if ((args[i] == "-Xnfastates"))
                                                            DecisionProbe.attr_verbose = true
                                                          else
                                                            if ((args[i] == "-X"))
                                                              _xhelp
                                                            else
                                                              if (!(args[i].char_at(0)).equal?(Character.new(?-.ord)))
                                                                # Must be the grammar file
                                                                @grammar_file_names.add(args[i])
                                                              end
                                                            end
                                                          end
                                                        end
                                                      end
                                                    end
                                                  end
                                                end
                                              end
                                            end
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
        i += 1
      end
    end
    
    typesig { [] }
    # protected void checkForInvalidArguments(String[] args, BitSet cmdLineArgValid) {
    # // check for invalid command line args
    # for (int a = 0; a < args.length; a++) {
    # if (!cmdLineArgValid.member(a)) {
    # System.err.println("invalid command-line argument: " + args[a] + "; ignored");
    # }
    # }
    # }
    def process
      num_files = @grammar_file_names.size
      exception_when_writing_lexer_file = false
      lexer_grammar_file_name = nil # necessary at this scope to have access in the catch below
      i = 0
      while i < num_files
        grammar_file_name = @grammar_file_names.get(i)
        if (num_files > 1 && !@depend)
          System.out.println(grammar_file_name)
        end
        begin
          if (@depend)
            dep = BuildDependencyGenerator.new(self, grammar_file_name)
            output_files = dep.get_generated_file_list
            dependents = dep.get_dependencies_file_list
            # System.out.println("output: "+outputFiles);
            # System.out.println("dependents: "+dependents);
            System.out.println(dep.get_dependencies)
            i += 1
            next
          end
          grammar = get_root_grammar(grammar_file_name)
          # we now have all grammars read in as ASTs
          # (i.e., root and all delegates)
          grammar.attr_composite.assign_token_types
          grammar.attr_composite.define_grammar_symbols
          grammar.attr_composite.create_nfas
          generate_recognizer(grammar)
          if (@print_grammar)
            grammar.print_grammar(System.out)
          end
          if (@report)
            report = GrammarReport.new(grammar)
            System.out.println(report.to_s)
            # print out a backtracking report too (that is not encoded into log)
            System.out.println(report.get_backtracking_report)
            # same for aborted NFA->DFA conversions
            System.out.println(report.get_analysis_timeout_report)
          end
          if (@profile)
            report = GrammarReport.new(grammar)
            Stats.write_report(GrammarReport::GRAMMAR_STATS_FILENAME, report.to_notify_string)
          end
          # now handle the lexer if one was created for a merged spec
          lexer_grammar_str = grammar.get_lexer_grammar
          # System.out.println("lexer grammar:\n"+lexerGrammarStr);
          if ((grammar.attr_type).equal?(Grammar::COMBINED) && !(lexer_grammar_str).nil?)
            lexer_grammar_file_name = RJava.cast_to_string(grammar.get_implicitly_generated_lexer_file_name)
            begin
              w = get_output_file(grammar, lexer_grammar_file_name)
              w.write(lexer_grammar_str)
              w.close
            rescue IOException => e
              # emit different error message when creating the implicit lexer fails
              # due to write permission error
              exception_when_writing_lexer_file = true
              raise e
            end
            begin
              sr = StringReader.new(lexer_grammar_str)
              lexer_grammar = Grammar.new
              lexer_grammar.attr_composite.attr_watch_nfaconversion = self.attr_internal_option_watch_nfaconversion
              lexer_grammar.attr_implicit_lexer = true
              lexer_grammar.set_tool(self)
              lexer_grammar_full_file = JavaFile.new(get_file_directory(lexer_grammar_file_name), lexer_grammar_file_name)
              lexer_grammar.set_file_name(lexer_grammar_full_file.to_s)
              lexer_grammar.import_token_vocabulary(grammar)
              lexer_grammar.parse_and_build_ast(sr)
              sr.close
              lexer_grammar.attr_composite.assign_token_types
              lexer_grammar.attr_composite.define_grammar_symbols
              lexer_grammar.attr_composite.create_nfas
              generate_recognizer(lexer_grammar)
            ensure
              # make sure we clean up
              if (@delete_temp_lexer)
                output_dir = get_output_directory(lexer_grammar_file_name)
                output_file = JavaFile.new(output_dir, lexer_grammar_file_name)
                output_file.delete
              end
            end
          end
        rescue IOException => e
          if (exception_when_writing_lexer_file)
            ErrorManager.error(ErrorManager::MSG_CANNOT_WRITE_FILE, lexer_grammar_file_name, e)
          else
            ErrorManager.error(ErrorManager::MSG_CANNOT_OPEN_FILE, grammar_file_name)
          end
        rescue JavaException => e
          ErrorManager.error(ErrorManager::MSG_INTERNAL_ERROR, grammar_file_name, e)
        end
        i += 1
      end
    end
    
    typesig { [String] }
    # Get a grammar mentioned on the command-line and any delegates
    def get_root_grammar(grammar_file_name)
      # StringTemplate.setLintMode(true);
      # grammars mentioned on command line are either roots or single grammars.
      # create the necessary composite in case it's got delegates; even
      # single grammar needs it to get token types.
      composite = CompositeGrammar.new
      grammar = Grammar.new(self, grammar_file_name, composite)
      composite.set_delegation_root(grammar)
      fr = nil
      fr = FileReader.new(grammar_file_name)
      br = BufferedReader.new(fr)
      grammar.parse_and_build_ast(br)
      composite.attr_watch_nfaconversion = self.attr_internal_option_watch_nfaconversion
      br.close
      fr.close
      return grammar
    end
    
    typesig { [Grammar] }
    # Create NFA, DFA and generate code for grammar.
    # Create NFA for any delegates first.  Once all NFA are created,
    # it's ok to create DFA, which must check for left-recursion.  That check
    # is done by walking the full NFA, which therefore must be complete.
    # After all NFA, comes DFA conversion for root grammar then code gen for
    # root grammar.  DFA and code gen for delegates comes next.
    def generate_recognizer(grammar)
      language = grammar.get_option("language")
      if (!(language).nil?)
        generator = CodeGenerator.new(self, grammar, language)
        grammar.set_code_generator(generator)
        generator.set_debug(@debug)
        generator.set_profile(@profile)
        generator.set_trace(@trace)
        # generate NFA early in case of crash later (for debugging)
        if (@generate_nfa_dot)
          generate_nfas(grammar)
        end
        # GENERATE CODE
        generator.gen_recognizer
        if (@generate_dfa_dot)
          generate_dfas(grammar)
        end
        delegates = grammar.get_direct_delegates
        i = 0
        while !(delegates).nil? && i < delegates.size
          delegate = delegates.get(i)
          if (!(delegate).equal?(grammar))
            # already processing this one
            generate_recognizer(delegate)
          end
          i += 1
        end
      end
    end
    
    typesig { [Grammar] }
    def generate_dfas(g)
      d = 1
      while d <= g.get_number_of_decisions
        dfa = g.get_lookahead_dfa(d)
        if ((dfa).nil?)
          d += 1
          next # not there for some reason, ignore
        end
        dot_generator = DOTGenerator.new(g)
        dot = dot_generator.get_dot(dfa.attr_start_state)
        dot_file_name = RJava.cast_to_string(g.attr_name) + "." + "dec-" + RJava.cast_to_string(d)
        if (g.attr_implicit_lexer)
          dot_file_name = RJava.cast_to_string(g.attr_name + Grammar.attr_grammar_type_to_file_name_suffix[g.attr_type]) + "." + "dec-" + RJava.cast_to_string(d)
        end
        begin
          write_dotfile(g, dot_file_name, dot)
        rescue IOException => ioe
          ErrorManager.error(ErrorManager::MSG_CANNOT_GEN_DOT_FILE, dot_file_name, ioe)
        end
        d += 1
      end
    end
    
    typesig { [Grammar] }
    def generate_nfas(g)
      dot_generator = DOTGenerator.new(g)
      rules = g.get_all_imported_rules
      rules.add_all(g.get_rules)
      itr = rules.iterator
      while itr.has_next
        r = itr.next_
        begin
          dot = dot_generator.get_dot(r.attr_start_state)
          if (!(dot).nil?)
            write_dotfile(g, r, dot)
          end
        rescue IOException => ioe
          ErrorManager.error(ErrorManager::MSG_CANNOT_WRITE_FILE, ioe)
        end
      end
    end
    
    typesig { [Grammar, Rule, String] }
    def write_dotfile(g, r, dot)
      write_dotfile(g, RJava.cast_to_string(r.attr_grammar.attr_name) + "." + RJava.cast_to_string(r.attr_name), dot)
    end
    
    typesig { [Grammar, String, String] }
    def write_dotfile(g, name, dot)
      fw = get_output_file(g, name + ".dot")
      fw.write(dot)
      fw.close
    end
    
    class_module.module_eval {
      typesig { [] }
      def help
        System.err.println("usage: java org.antlr.Tool [args] file.g [file2.g file3.g ...]")
        System.err.println("  -o outputDir          specify output directory where all output is generated")
        System.err.println("  -fo outputDir         same as -o but force even files with relative paths to dir")
        System.err.println("  -lib dir              specify location of token files")
        System.err.println("  -depend               generate file dependencies")
        System.err.println("  -report               print out a report about the grammar(s) processed")
        System.err.println("  -print                print out the grammar without actions")
        System.err.println("  -debug                generate a parser that emits debugging events")
        System.err.println("  -profile              generate a parser that computes profiling information")
        System.err.println("  -nfa                  generate an NFA for each rule")
        System.err.println("  -dfa                  generate a DFA for each decision point")
        System.err.println("  -message-format name  specify output style for messages")
        System.err.println("  -X                    display extended argument list")
      end
      
      typesig { [] }
      def _xhelp
        System.err.println("  -Xgrtree               print the grammar AST")
        System.err.println("  -Xdfa                  print DFA as text ")
        System.err.println("  -Xnoprune              test lookahead against EBNF block exit branches")
        System.err.println("  -Xnocollapse           collapse incident edges into DFA states")
        System.err.println("  -Xdbgconversion        dump lots of info during NFA conversion")
        System.err.println("  -Xmultithreaded        run the analysis in 2 threads")
        System.err.println("  -Xnomergestopstates    do not merge stop states")
        System.err.println("  -Xdfaverbose           generate DFA states in DOT with NFA configs")
        System.err.println("  -Xwatchconversion      print a message for each NFA before converting")
        System.err.println("  -XdbgST                put tags at start/stop of all templates in output")
        System.err.println("  -Xm m                  max number of rule invocations during conversion")
        System.err.println("  -Xmaxdfaedges m        max \"comfortable\" number of edges for single DFA state")
        System.err.println("  -Xconversiontimeout t  set NFA conversion timeout for each decision")
        System.err.println("  -Xmaxinlinedfastates m max DFA states before table used rather than inlining")
        System.err.println("  -Xnfastates            for nondeterminisms, list NFA states for each path")
      end
    }
    
    typesig { [String] }
    def set_output_directory(output_directory)
      @output_directory = output_directory
    end
    
    typesig { [Grammar, String] }
    # This method is used by all code generators to create new output
    # files. If the outputDir set by -o is not present it will be created.
    # The final filename is sensitive to the output directory and
    # the directory where the grammar file was found.  If -o is /tmp
    # and the original grammar file was foo/t.g then output files
    # go in /tmp/foo.
    # 
    # The output dir -o spec takes precedence if it's absolute.
    # E.g., if the grammar file dir is absolute the output dir is given
    # precendence. "-o /tmp /usr/lib/t.g" results in "/tmp/T.java" as
    # output (assuming t.g holds T.java).
    # 
    # If no -o is specified, then just write to the directory where the
    # grammar file was found.
    # 
    # If outputDirectory==null then write a String.
    def get_output_file(g, file_name)
      if ((@output_directory).nil?)
        return StringWriter.new
      end
      # output directory is a function of where the grammar file lives
      # for subdir/T.g, you get subdir here.  Well, depends on -o etc...
      output_dir = get_output_directory(g.get_file_name)
      output_file = JavaFile.new(output_dir, file_name)
      if (!output_dir.exists)
        output_dir.mkdirs
      end
      fw = FileWriter.new(output_file)
      return BufferedWriter.new(fw)
    end
    
    typesig { [String] }
    def get_output_directory(file_name_with_path)
      output_dir = JavaFile.new(@output_directory)
      file_directory = get_file_directory(file_name_with_path)
      if (!(@output_directory).equal?(UNINITIALIZED_DIR))
        # -o /tmp /var/lib/t.g => /tmp/T.java
        # -o subdir/output /usr/lib/t.g => subdir/output/T.java
        # -o . /usr/lib/t.g => ./T.java
        # isAbsolute doesn't count this :(
        if (!(file_directory).nil? && (JavaFile.new(file_directory).is_absolute || file_directory.starts_with("~")) || @force_all_files_to_output_dir)
          # somebody set the dir, it takes precendence; write new file there
          output_dir = JavaFile.new(@output_directory)
        else
          # -o /tmp subdir/t.g => /tmp/subdir/t.g
          if (!(file_directory).nil?)
            output_dir = JavaFile.new(@output_directory, file_directory)
          else
            output_dir = JavaFile.new(@output_directory)
          end
        end
      else
        # they didn't specify a -o dir so just write to location
        # where grammar is, absolute or relative
        dir = "."
        if (!(file_directory).nil?)
          dir = file_directory
        end
        output_dir = JavaFile.new(dir)
      end
      return output_dir
    end
    
    typesig { [String] }
    # Name a file in the -lib dir.  Imported grammars and .tokens files
    def get_library_file(file_name)
      return @lib_directory + RJava.cast_to_string(JavaFile.attr_separator) + file_name
    end
    
    typesig { [] }
    def get_library_directory
      return @lib_directory
    end
    
    typesig { [String] }
    # Return the directory containing the grammar file for this grammar.
    # normally this is a relative path from current directory.  People will
    # often do "java org.antlr.Tool grammars/*.g3"  So the file will be
    # "grammars/foo.g3" etc...  This method returns "grammars".
    def get_file_directory(file_name)
      f = JavaFile.new(file_name)
      return f.get_parent
    end
    
    typesig { [String] }
    # Return a File descriptor for vocab file.  Look in library or
    # in -o output path.  antlr -o foo T.g U.g where U needs T.tokens
    # won't work unless we look in foo too.
    def get_imported_vocab_file(vocab_name)
      f = JavaFile.new(get_library_directory, RJava.cast_to_string(JavaFile.attr_separator) + vocab_name + RJava.cast_to_string(CodeGenerator::VOCAB_FILE_EXTENSION))
      if (f.exists)
        return f
      end
      return JavaFile.new(@output_directory + RJava.cast_to_string(JavaFile.attr_separator) + vocab_name + RJava.cast_to_string(CodeGenerator::VOCAB_FILE_EXTENSION))
    end
    
    typesig { [] }
    # If the tool needs to panic/exit, how do we do that?
    def panic
      raise JavaError.new("ANTLR panic")
    end
    
    class_module.module_eval {
      typesig { [] }
      # Return a time stamp string accurate to sec: yyyy-mm-dd hh:mm:ss
      def get_current_time_stamp
        calendar = Java::Util::GregorianCalendar.new
        y = calendar.get(Calendar::YEAR)
        m = calendar.get(Calendar::MONTH) + 1 # zero-based for months
        d = calendar.get(Calendar::DAY_OF_MONTH)
        h = calendar.get(Calendar::HOUR_OF_DAY)
        min = calendar.get(Calendar::MINUTE)
        sec = calendar.get(Calendar::SECOND)
        sy = String.value_of(y)
        sm = m < 10 ? "0" + RJava.cast_to_string(m) : String.value_of(m)
        sd = d < 10 ? "0" + RJava.cast_to_string(d) : String.value_of(d)
        sh = h < 10 ? "0" + RJava.cast_to_string(h) : String.value_of(h)
        smin = min < 10 ? "0" + RJava.cast_to_string(min) : String.value_of(min)
        ssec = sec < 10 ? "0" + RJava.cast_to_string(sec) : String.value_of(sec)
        return StringBuffer.new.append(sy).append("-").append(sm).append("-").append(sd).append(" ").append(sh).append(":").append(smin).append(":").append(ssec).to_s
      end
    }
    
    private
    alias_method :initialize__tool, :initialize
  end
  
  Tool.main($*) if $0 == __FILE__
end
