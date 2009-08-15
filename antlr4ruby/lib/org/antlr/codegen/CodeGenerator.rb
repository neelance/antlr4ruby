require "rjava"

# [The "BSD licence"]
# Copyright (c) 2005-2007 Terence Parr
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
module Org::Antlr::Codegen
  module CodeGeneratorImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Codegen
      include_const ::Antlr, :RecognitionException
      include_const ::Antlr, :TokenStreamRewriteEngine
      include_const ::Antlr::Collections, :AST
      include_const ::Org::Antlr, :Tool
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Misc, :BitSet
      include ::Org::Antlr::Misc
      include ::Org::Antlr::Stringtemplate
      include_const ::Org::Antlr::Stringtemplate::Language, :AngleBracketTemplateLexer
      include ::Org::Antlr::Tool
      include_const ::Java::Io, :IOException
      include_const ::Java::Io, :StringReader
      include_const ::Java::Io, :Writer
      include ::Java::Util
    }
  end
  
  # ANTLR's code generator.
  # 
  # Generate recognizers derived from grammars.  Language independence
  # achieved through the use of StringTemplateGroup objects.  All output
  # strings are completely encapsulated in the group files such as Java.stg.
  # Some computations are done that are unused by a particular language.
  # This generator just computes and sets the values into the templates;
  # the templates are free to use or not use the information.
  # 
  # To make a new code generation target, define X.stg for language X
  # by copying from existing Y.stg most closely releated to your language;
  # e.g., to do CSharp.stg copy Java.stg.  The template group file has a
  # bunch of templates that are needed by the code generator.  You can add
  # a new target w/o even recompiling ANTLR itself.  The language=X option
  # in a grammar file dictates which templates get loaded/used.
  # 
  # Some language like C need both parser files and header files.  Java needs
  # to have a separate file for the cyclic DFA as ANTLR generates bytecodes
  # directly (which cannot be in the generated parser Java file).  To facilitate
  # this,
  # 
  # cyclic can be in same file, but header, output must be searpate.  recognizer
  # is in outptufile.
  class CodeGenerator 
    include_class_members CodeGeneratorImports
    
    # When generating SWITCH statements, some targets might need to limit
    # the size (based upon the number of case labels).  Generally, this
    # limit will be hit only for lexers where wildcard in a UNICODE
    # vocabulary environment would generate a SWITCH with 65000 labels.
    attr_accessor :max_switch_case_labels
    alias_method :attr_max_switch_case_labels, :max_switch_case_labels
    undef_method :max_switch_case_labels
    alias_method :attr_max_switch_case_labels=, :max_switch_case_labels=
    undef_method :max_switch_case_labels=
    
    attr_accessor :min_switch_alts
    alias_method :attr_min_switch_alts, :min_switch_alts
    undef_method :min_switch_alts
    alias_method :attr_min_switch_alts=, :min_switch_alts=
    undef_method :min_switch_alts=
    
    attr_accessor :generate_switches_when_possible
    alias_method :attr_generate_switches_when_possible, :generate_switches_when_possible
    undef_method :generate_switches_when_possible
    alias_method :attr_generate_switches_when_possible=, :generate_switches_when_possible=
    undef_method :generate_switches_when_possible=
    
    class_module.module_eval {
      # public static boolean GEN_ACYCLIC_DFA_INLINE = true;
      
      def emit_template_delimiters
        defined?(@@emit_template_delimiters) ? @@emit_template_delimiters : @@emit_template_delimiters= false
      end
      alias_method :attr_emit_template_delimiters, :emit_template_delimiters
      
      def emit_template_delimiters=(value)
        @@emit_template_delimiters = value
      end
      alias_method :attr_emit_template_delimiters=, :emit_template_delimiters=
      
      
      def max_acyclic_dfa_states_inline
        defined?(@@max_acyclic_dfa_states_inline) ? @@max_acyclic_dfa_states_inline : @@max_acyclic_dfa_states_inline= 10
      end
      alias_method :attr_max_acyclic_dfa_states_inline, :max_acyclic_dfa_states_inline
      
      def max_acyclic_dfa_states_inline=(value)
        @@max_acyclic_dfa_states_inline = value
      end
      alias_method :attr_max_acyclic_dfa_states_inline=, :max_acyclic_dfa_states_inline=
    }
    
    attr_accessor :classpath_template_root_directory_name
    alias_method :attr_classpath_template_root_directory_name, :classpath_template_root_directory_name
    undef_method :classpath_template_root_directory_name
    alias_method :attr_classpath_template_root_directory_name=, :classpath_template_root_directory_name=
    undef_method :classpath_template_root_directory_name=
    
    # Which grammar are we generating code for?  Each generator
    # is attached to a specific grammar.
    attr_accessor :grammar
    alias_method :attr_grammar, :grammar
    undef_method :grammar
    alias_method :attr_grammar=, :grammar=
    undef_method :grammar=
    
    # What language are we generating?
    attr_accessor :language
    alias_method :attr_language, :language
    undef_method :language
    alias_method :attr_language=, :language=
    undef_method :language=
    
    # The target specifies how to write out files and do other language
    # specific actions.
    attr_accessor :target
    alias_method :attr_target, :target
    undef_method :target
    alias_method :attr_target=, :target=
    undef_method :target=
    
    # Where are the templates this generator should use to generate code?
    attr_accessor :templates
    alias_method :attr_templates, :templates
    undef_method :templates
    alias_method :attr_templates=, :templates=
    undef_method :templates=
    
    # The basic output templates without AST or templates stuff; this will be
    # the templates loaded for the language such as Java.stg *and* the Dbg
    # stuff if turned on.  This is used for generating syntactic predicates.
    attr_accessor :base_templates
    alias_method :attr_base_templates, :base_templates
    undef_method :base_templates
    alias_method :attr_base_templates=, :base_templates=
    undef_method :base_templates=
    
    attr_accessor :recognizer_st
    alias_method :attr_recognizer_st, :recognizer_st
    undef_method :recognizer_st
    alias_method :attr_recognizer_st=, :recognizer_st=
    undef_method :recognizer_st=
    
    attr_accessor :output_file_st
    alias_method :attr_output_file_st, :output_file_st
    undef_method :output_file_st
    alias_method :attr_output_file_st=, :output_file_st=
    undef_method :output_file_st=
    
    attr_accessor :header_file_st
    alias_method :attr_header_file_st, :header_file_st
    undef_method :header_file_st
    alias_method :attr_header_file_st=, :header_file_st=
    undef_method :header_file_st=
    
    # Used to create unique labels
    attr_accessor :unique_label_number
    alias_method :attr_unique_label_number, :unique_label_number
    undef_method :unique_label_number
    alias_method :attr_unique_label_number=, :unique_label_number=
    undef_method :unique_label_number=
    
    # A reference to the ANTLR tool so we can learn about output directories
    # and such.
    attr_accessor :tool
    alias_method :attr_tool, :tool
    undef_method :tool
    alias_method :attr_tool=, :tool=
    undef_method :tool=
    
    # Generate debugging event method calls
    attr_accessor :debug
    alias_method :attr_debug, :debug
    undef_method :debug
    alias_method :attr_debug=, :debug=
    undef_method :debug=
    
    # Create a Tracer object and make the recognizer invoke this.
    attr_accessor :trace
    alias_method :attr_trace, :trace
    undef_method :trace
    alias_method :attr_trace=, :trace=
    undef_method :trace=
    
    # Track runtime parsing information about decisions etc...
    # This requires the debugging event mechanism to work.
    attr_accessor :profile
    alias_method :attr_profile, :profile
    undef_method :profile
    alias_method :attr_profile=, :profile=
    undef_method :profile=
    
    attr_accessor :line_width
    alias_method :attr_line_width, :line_width
    undef_method :line_width
    alias_method :attr_line_width=, :line_width=
    undef_method :line_width=
    
    # I have factored out the generation of acyclic DFAs to separate class
    attr_accessor :acyclic_dfagenerator
    alias_method :attr_acyclic_dfagenerator, :acyclic_dfagenerator
    undef_method :acyclic_dfagenerator
    alias_method :attr_acyclic_dfagenerator=, :acyclic_dfagenerator=
    undef_method :acyclic_dfagenerator=
    
    class_module.module_eval {
      # I have factored out the generation of cyclic DFAs to separate class
      # 
      # public CyclicDFACodeGenerator cyclicDFAGenerator =
      # new CyclicDFACodeGenerator(this);
      const_set_lazy(:VOCAB_FILE_EXTENSION) { ".tokens" }
      const_attr_reader  :VOCAB_FILE_EXTENSION
      
      const_set_lazy(:VocabFilePattern) { "<tokens:{<attr.name>=<attr.type>\n}>" + "<literals:{<attr.name>=<attr.type>\n}>" }
      const_attr_reader  :VocabFilePattern
    }
    
    typesig { [Tool, Grammar, String] }
    def initialize(tool, grammar, language)
      @max_switch_case_labels = 300
      @min_switch_alts = 3
      @generate_switches_when_possible = true
      @classpath_template_root_directory_name = "org/antlr/codegen/templates"
      @grammar = nil
      @language = nil
      @target = nil
      @templates = nil
      @base_templates = nil
      @recognizer_st = nil
      @output_file_st = nil
      @header_file_st = nil
      @unique_label_number = 1
      @tool = nil
      @debug = false
      @trace = false
      @profile = false
      @line_width = 72
      @acyclic_dfagenerator = ACyclicDFACodeGenerator.new(self)
      @tool = tool
      @grammar = grammar
      @language = language
      load_language_target(language)
    end
    
    typesig { [String] }
    def load_language_target(language)
      target_name = "org.antlr.codegen." + language + "Target"
      begin
        c = Class.for_name(target_name)
        @target = c.new_instance
      rescue ClassNotFoundException => cnfe
        @target = Target.new # use default
      rescue InstantiationException => ie
        ErrorManager.error(ErrorManager::MSG_CANNOT_CREATE_TARGET_GENERATOR, target_name, ie)
      rescue IllegalAccessException => cnfe
        ErrorManager.error(ErrorManager::MSG_CANNOT_CREATE_TARGET_GENERATOR, target_name, cnfe)
      end
    end
    
    typesig { [String] }
    # load the main language.stg template group file
    def load_templates(language)
      # get a group loader containing main templates dir and target subdir
      template_dirs = @classpath_template_root_directory_name + ":" + @classpath_template_root_directory_name + "/" + language
      # System.out.println("targets="+templateDirs.toString());
      loader = CommonGroupLoader.new(template_dirs, ErrorManager.get_string_template_error_listener)
      StringTemplateGroup.register_group_loader(loader)
      StringTemplateGroup.register_default_lexer(AngleBracketTemplateLexer)
      # first load main language template
      core_templates = StringTemplateGroup.load_group(language)
      @base_templates = core_templates
      if ((core_templates).nil?)
        ErrorManager.error(ErrorManager::MSG_MISSING_CODE_GEN_TEMPLATES, language)
        return
      end
      # dynamically add subgroups that act like filters to apply to
      # their supergroup.  E.g., Java:Dbg:AST:ASTParser::ASTDbg.
      output_option = @grammar.get_option("output")
      if (!(output_option).nil? && (output_option == "AST"))
        if (@debug && !(@grammar.attr_type).equal?(Grammar::LEXER))
          dbg_templates = StringTemplateGroup.load_group("Dbg", core_templates)
          @base_templates = dbg_templates
          ast_templates = StringTemplateGroup.load_group("AST", dbg_templates)
          ast_parser_templates = ast_templates
          # if ( !grammar.rewriteMode() ) {
          if ((@grammar.attr_type).equal?(Grammar::TREE_PARSER))
            ast_parser_templates = StringTemplateGroup.load_group("ASTTreeParser", ast_templates)
          else
            ast_parser_templates = StringTemplateGroup.load_group("ASTParser", ast_templates)
          end
          # }
          ast_dbg_templates = StringTemplateGroup.load_group("ASTDbg", ast_parser_templates)
          @templates = ast_dbg_templates
        else
          ast_templates = StringTemplateGroup.load_group("AST", core_templates)
          ast_parser_templates = ast_templates
          # if ( !grammar.rewriteMode() ) {
          if ((@grammar.attr_type).equal?(Grammar::TREE_PARSER))
            ast_parser_templates = StringTemplateGroup.load_group("ASTTreeParser", ast_templates)
          else
            ast_parser_templates = StringTemplateGroup.load_group("ASTParser", ast_templates)
          end
          # }
          @templates = ast_parser_templates
        end
      else
        if (!(output_option).nil? && (output_option == "template"))
          if (@debug && !(@grammar.attr_type).equal?(Grammar::LEXER))
            dbg_templates = StringTemplateGroup.load_group("Dbg", core_templates)
            @base_templates = dbg_templates
            st_templates = StringTemplateGroup.load_group("ST", dbg_templates)
            @templates = st_templates
          else
            @templates = StringTemplateGroup.load_group("ST", core_templates)
          end
        else
          if (@debug && !(@grammar.attr_type).equal?(Grammar::LEXER))
            @templates = StringTemplateGroup.load_group("Dbg", core_templates)
            @base_templates = @templates
          else
            @templates = core_templates
          end
        end
      end
      if (self.attr_emit_template_delimiters)
        @templates.emit_debug_start_stop_strings(true)
        @templates.do_not_emit_debug_strings_for_template("codeFileExtension")
        @templates.do_not_emit_debug_strings_for_template("headerFileExtension")
      end
    end
    
    typesig { [] }
    # Given the grammar to which we are attached, walk the AST associated
    # with that grammar to create NFAs.  Then create the DFAs for all
    # decision points in the grammar by converting the NFAs to DFAs.
    # Finally, walk the AST again to generate code.
    # 
    # Either 1 or 2 files are written:
    # 
    # recognizer: the main parser/lexer/treewalker item
    # header file: language like C/C++ need extern definitions
    # 
    # The target, such as JavaTarget, dictates which files get written.
    def gen_recognizer
      # System.out.println("### generate "+grammar.name+" recognizer");
      # LOAD OUTPUT TEMPLATES
      load_templates(@language)
      if ((@templates).nil?)
        return nil
      end
      # CREATE NFA FROM GRAMMAR, CREATE DFA FROM NFA
      if (ErrorManager.do_not_attempt_analysis)
        return nil
      end
      @target.perform_grammar_analysis(self, @grammar)
      # some grammar analysis errors will not yield reliable DFA
      if (ErrorManager.do_not_attempt_code_gen)
        return nil
      end
      # OPTIMIZE DFA
      optimizer = DFAOptimizer.new(@grammar)
      optimizer.optimize
      # OUTPUT FILE (contains recognizerST)
      @output_file_st = @templates.get_instance_of("outputFile")
      # HEADER FILE
      if (@templates.is_defined("headerFile"))
        @header_file_st = @templates.get_instance_of("headerFile")
      else
        # create a dummy to avoid null-checks all over code generator
        @header_file_st = StringTemplate.new(@templates, "")
        @header_file_st.set_name("dummy-header-file")
      end
      filter_mode = !(@grammar.get_option("filter")).nil? && (@grammar.get_option("filter") == "true")
      can_backtrack = !(@grammar.get_syntactic_predicates).nil? || filter_mode
      # TODO: move this down further because generating the recognizer
      # alters the model with info on who uses predefined properties etc...
      # The actions here might refer to something.
      # The only two possible output files are available at this point.
      # Verify action scopes are ok for target and dump actions into output
      # Templates can say <actions.parser.header> for example.
      actions = @grammar.get_actions
      verify_action_scopes_ok_for_target(actions)
      # translate $x::y references
      translate_action_attribute_references(actions)
      actions_for_grammar_scope = actions.get(@grammar.get_default_action_scope(@grammar.attr_type))
      if (filter_mode && ((actions_for_grammar_scope).nil? || !actions_for_grammar_scope.contains_key(Grammar::SYNPREDGATE_ACTION_NAME)))
        # if filtering, we need to set actions to execute at backtracking
        # level 1 not 0.  Don't set this action if a user has though
        gate_st = @templates.get_instance_of("filteringActionGate")
        if ((actions_for_grammar_scope).nil?)
          actions_for_grammar_scope = HashMap.new
          actions.put(@grammar.get_default_action_scope(@grammar.attr_type), actions_for_grammar_scope)
        end
        actions_for_grammar_scope.put(Grammar::SYNPREDGATE_ACTION_NAME, gate_st)
      end
      @header_file_st.set_attribute("actions", actions)
      @output_file_st.set_attribute("actions", actions)
      @header_file_st.set_attribute("buildTemplate", Boolean.new(@grammar.build_template))
      @output_file_st.set_attribute("buildTemplate", Boolean.new(@grammar.build_template))
      @header_file_st.set_attribute("buildAST", Boolean.new(@grammar.build_ast))
      @output_file_st.set_attribute("buildAST", Boolean.new(@grammar.build_ast))
      @output_file_st.set_attribute("rewriteMode", Boolean.value_of(@grammar.rewrite_mode))
      @header_file_st.set_attribute("rewriteMode", Boolean.value_of(@grammar.rewrite_mode))
      @output_file_st.set_attribute("backtracking", Boolean.value_of(can_backtrack))
      @header_file_st.set_attribute("backtracking", Boolean.value_of(can_backtrack))
      # turn on memoize attribute at grammar level so we can create ruleMemo.
      # each rule has memoize attr that hides this one, indicating whether
      # it needs to save results
      memoize = @grammar.get_option("memoize")
      @output_file_st.set_attribute("memoize", (@grammar.attr_at_least_one_rule_memoizes || Boolean.value_of(!(memoize).nil? && (memoize == "true")) && can_backtrack))
      @header_file_st.set_attribute("memoize", (@grammar.attr_at_least_one_rule_memoizes || Boolean.value_of(!(memoize).nil? && (memoize == "true")) && can_backtrack))
      @output_file_st.set_attribute("trace", Boolean.value_of(@trace))
      @header_file_st.set_attribute("trace", Boolean.value_of(@trace))
      @output_file_st.set_attribute("profile", Boolean.value_of(@profile))
      @header_file_st.set_attribute("profile", Boolean.value_of(@profile))
      # RECOGNIZER
      if ((@grammar.attr_type).equal?(Grammar::LEXER))
        @recognizer_st = @templates.get_instance_of("lexer")
        @output_file_st.set_attribute("LEXER", Boolean.value_of(true))
        @header_file_st.set_attribute("LEXER", Boolean.value_of(true))
        @recognizer_st.set_attribute("filterMode", Boolean.value_of(filter_mode))
      else
        if ((@grammar.attr_type).equal?(Grammar::PARSER) || (@grammar.attr_type).equal?(Grammar::COMBINED))
          @recognizer_st = @templates.get_instance_of("parser")
          @output_file_st.set_attribute("PARSER", Boolean.value_of(true))
          @header_file_st.set_attribute("PARSER", Boolean.value_of(true))
        else
          @recognizer_st = @templates.get_instance_of("treeParser")
          @output_file_st.set_attribute("TREE_PARSER", Boolean.value_of(true))
          @header_file_st.set_attribute("TREE_PARSER", Boolean.value_of(true))
        end
      end
      @output_file_st.set_attribute("recognizer", @recognizer_st)
      @header_file_st.set_attribute("recognizer", @recognizer_st)
      @output_file_st.set_attribute("actionScope", @grammar.get_default_action_scope(@grammar.attr_type))
      @header_file_st.set_attribute("actionScope", @grammar.get_default_action_scope(@grammar.attr_type))
      target_appropriate_file_name_string = @target.get_target_string_literal_from_string(@grammar.get_file_name)
      @output_file_st.set_attribute("fileName", target_appropriate_file_name_string)
      @header_file_st.set_attribute("fileName", target_appropriate_file_name_string)
      @output_file_st.set_attribute("ANTLRVersion", Tool::VERSION)
      @header_file_st.set_attribute("ANTLRVersion", Tool::VERSION)
      @output_file_st.set_attribute("generatedTimestamp", Tool.get_current_time_stamp)
      @header_file_st.set_attribute("generatedTimestamp", Tool.get_current_time_stamp)
      # GENERATE RECOGNIZER
      # Walk the AST holding the input grammar, this time generating code
      # Decisions are generated by using the precomputed DFAs
      # Fill in the various templates with data
      gen = CodeGenTreeWalker.new
      begin
        gen.grammar(@grammar.get_grammar_tree, @grammar, @recognizer_st, @output_file_st, @header_file_st)
      rescue RecognitionException => re
        ErrorManager.error(ErrorManager::MSG_BAD_AST_STRUCTURE, re)
      end
      gen_token_type_constants(@recognizer_st)
      gen_token_type_constants(@output_file_st)
      gen_token_type_constants(@header_file_st)
      if (!(@grammar.attr_type).equal?(Grammar::LEXER))
        gen_token_type_names(@recognizer_st)
        gen_token_type_names(@output_file_st)
        gen_token_type_names(@header_file_st)
      end
      # Now that we know what synpreds are used, we can set into template
      synpred_names = nil
      if (@grammar.attr_syn_pred_names_used_in_dfa.size > 0)
        synpred_names = @grammar.attr_syn_pred_names_used_in_dfa
      end
      @output_file_st.set_attribute("synpreds", synpred_names)
      @header_file_st.set_attribute("synpreds", synpred_names)
      # all recognizers can see Grammar object
      @recognizer_st.set_attribute("grammar", @grammar)
      # WRITE FILES
      begin
        @target.gen_recognizer_file(@tool, self, @grammar, @output_file_st)
        if (@templates.is_defined("headerFile"))
          ext_st = @templates.get_instance_of("headerFileExtension")
          @target.gen_recognizer_header_file(@tool, self, @grammar, @header_file_st, ext_st.to_s)
        end
        # write out the vocab interchange file; used by antlr,
        # does not change per target
        token_vocab_serialization = gen_token_vocab_output
        vocab_file_name = get_vocab_file_name
        if (!(vocab_file_name).nil?)
          write(token_vocab_serialization, vocab_file_name)
        end
        # System.out.println(outputFileST.getDOTForDependencyGraph(false));
      rescue IOException => ioe
        ErrorManager.error(ErrorManager::MSG_CANNOT_WRITE_FILE, get_vocab_file_name, ioe)
      end
      # System.out.println("num obj.prop refs: "+ ASTExpr.totalObjPropRefs);
      # System.out.println("num reflection lookups: "+ ASTExpr.totalReflectionLookups);
      return @output_file_st
    end
    
    typesig { [Map] }
    # Some targets will have some extra scopes like C++ may have
    # '@headerfile:name {action}' or something.  Make sure the
    # target likes the scopes in action table.
    def verify_action_scopes_ok_for_target(actions)
      action_scope_key_set = actions.key_set
      it = action_scope_key_set.iterator
      while it.has_next
        scope = it.next_
        if (!@target.is_valid_action_scope(@grammar.attr_type, scope))
          # get any action from the scope to get error location
          scope_actions = actions.get(scope)
          action_ast = scope_actions.values.iterator.next_
          ErrorManager.grammar_error(ErrorManager::MSG_INVALID_ACTION_SCOPE, @grammar, action_ast.get_token, scope, @grammar.get_grammar_type_string)
        end
      end
    end
    
    typesig { [Map] }
    # Actions may reference $x::y attributes, call translateAction on
    # each action and replace that action in the Map.
    def translate_action_attribute_references(actions)
      action_scope_key_set = actions.key_set
      it = action_scope_key_set.iterator
      while it.has_next
        scope = it.next_
        scope_actions = actions.get(scope)
        translate_action_attribute_references_for_single_scope(nil, scope_actions)
      end
    end
    
    typesig { [Rule, Map] }
    # Use for translating rule @init{...} actions that have no scope
    def translate_action_attribute_references_for_single_scope(r, scope_actions)
      rule_name = nil
      if (!(r).nil?)
        rule_name = RJava.cast_to_string(r.attr_name)
      end
      action_name_set = scope_actions.key_set
      name_it = action_name_set.iterator
      while name_it.has_next
        name = name_it.next_
        action_ast = scope_actions.get(name)
        chunks = translate_action(rule_name, action_ast)
        scope_actions.put(name, chunks) # replace with translation
      end
    end
    
    typesig { [GrammarAST, String, String, ::Java::Int] }
    # Error recovery in ANTLR recognizers.
    # 
    # Based upon original ideas:
    # 
    # Algorithms + Data Structures = Programs by Niklaus Wirth
    # 
    # and
    # 
    # A note on error recovery in recursive descent parsers:
    # http://portal.acm.org/citation.cfm?id=947902.947905
    # 
    # Later, Josef Grosch had some good ideas:
    # Efficient and Comfortable Error Recovery in Recursive Descent Parsers:
    # ftp://www.cocolab.com/products/cocktail/doca4.ps/ell.ps.zip
    # 
    # Like Grosch I implemented local FOLLOW sets that are combined at run-time
    # upon error to avoid parsing overhead.
    def generate_local_follow(referenced_element_node, referenced_element_name, enclosing_rule_name, element_index)
      # System.out.println("compute FOLLOW "+grammar.name+"."+referencedElementNode.toString()+
      # " for "+referencedElementName+"#"+elementIndex +" in "+
      # enclosingRuleName+
      # " line="+referencedElementNode.getLine());
      following_nfastate = referenced_element_node.attr_following_nfastate
      follow = nil
      if (!(following_nfastate).nil?)
        # compute follow for this element and, as side-effect, track
        # the rule LOOK sensitivity.
        follow = @grammar._first(following_nfastate)
      end
      if ((follow).nil?)
        ErrorManager.internal_error("no follow state or cannot compute follow")
        follow = LookaheadSet.new
      end
      if (follow.member(Label::EOF))
        # TODO: can we just remove?  Seems needed here:
        # compilation_unit : global_statement* EOF
        # Actually i guess we resync to EOF regardless
        follow.remove(Label::EOF)
      end
      # System.out.println(" "+follow);
      token_type_list = nil
      words = nil
      if ((follow.attr_token_type_set).nil?)
        words = Array.typed(::Java::Long).new(1) { 0 }
        token_type_list = ArrayList.new
      else
        bits = BitSet.of(follow.attr_token_type_set)
        words = bits.to_packed_array
        token_type_list = follow.attr_token_type_set.to_list
      end
      # use the target to convert to hex strings (typically)
      word_strings = Array.typed(String).new(words.attr_length) { nil }
      j = 0
      while j < words.attr_length
        w = words[j]
        word_strings[j] = @target.get_target64bit_string_from_value(w)
        j += 1
      end
      @recognizer_st.set_attribute("bitsets.{name,inName,bits,tokenTypes,tokenIndex}", referenced_element_name, enclosing_rule_name, word_strings, token_type_list, Utils.integer(element_index))
      @output_file_st.set_attribute("bitsets.{name,inName,bits,tokenTypes,tokenIndex}", referenced_element_name, enclosing_rule_name, word_strings, token_type_list, Utils.integer(element_index))
      @header_file_st.set_attribute("bitsets.{name,inName,bits,tokenTypes,tokenIndex}", referenced_element_name, enclosing_rule_name, word_strings, token_type_list, Utils.integer(element_index))
    end
    
    typesig { [StringTemplate, DFA] }
    # L O O K A H E A D  D E C I S I O N  G E N E R A T I O N
    # Generate code that computes the predicted alt given a DFA.  The
    # recognizerST can be either the main generated recognizerTemplate
    # for storage in the main parser file or a separate file.  It's up to
    # the code that ultimately invokes the codegen.g grammar rule.
    # 
    # Regardless, the output file and header file get a copy of the DFAs.
    def gen_lookahead_decision(recognizer_st, dfa)
      decision_st = nil
      # If we are doing inline DFA and this one is acyclic and LL(*)
      # I have to check for is-non-LL(*) because if non-LL(*) the cyclic
      # check is not done by DFA.verify(); that is, verify() avoids
      # doesStateReachAcceptState() if non-LL(*)
      if (dfa.can_inline_decision)
        decision_st = @acyclic_dfagenerator.gen_fixed_lookahead_decision(get_templates, dfa)
      else
        # generate any kind of DFA here (cyclic or acyclic)
        dfa.create_state_tables(self)
        @output_file_st.set_attribute("cyclicDFAs", dfa)
        @header_file_st.set_attribute("cyclicDFAs", dfa)
        decision_st = @templates.get_instance_of("dfaDecision")
        description = dfa.get_nfadecision_start_state.get_description
        description = RJava.cast_to_string(@target.get_target_string_literal_from_string(description))
        if (!(description).nil?)
          decision_st.set_attribute("description", description)
        end
        decision_st.set_attribute("decisionNumber", Utils.integer(dfa.get_decision_number))
      end
      return decision_st
    end
    
    typesig { [DFAState] }
    # A special state is huge (too big for state tables) or has a predicated
    # edge.  Generate a simple if-then-else.  Cannot be an accept state as
    # they have no emanating edges.  Don't worry about switch vs if-then-else
    # because if you get here, the state is super complicated and needs an
    # if-then-else.  This is used by the new DFA scheme created June 2006.
    def generate_special_state(s)
      state_st = nil
      state_st = @templates.get_instance_of("cyclicDFAState")
      state_st.set_attribute("needErrorClause", Boolean.value_of(true))
      state_st.set_attribute("semPredState", Boolean.value_of(s.is_resolved_with_predicates))
      state_st.set_attribute("stateNumber", s.attr_state_number)
      state_st.set_attribute("decisionNumber", s.attr_dfa.attr_decision_number)
      found_gated_pred = false
      eot_st = nil
      i = 0
      while i < s.get_number_of_transitions
        edge = s.transition(i)
        edge_st = nil
        if ((edge.attr_label.get_atom).equal?(Label::EOT))
          # this is the default clause; has to held until last
          edge_st = @templates.get_instance_of("eotDFAEdge")
          state_st.remove_attribute("needErrorClause")
          eot_st = edge_st
        else
          edge_st = @templates.get_instance_of("cyclicDFAEdge")
          expr_st = gen_label_expr(@templates, edge, 1)
          edge_st.set_attribute("labelExpr", expr_st)
        end
        edge_st.set_attribute("edgeNumber", Utils.integer(i + 1))
        edge_st.set_attribute("targetStateNumber", Utils.integer(edge.attr_target.attr_state_number))
        # stick in any gated predicates for any edge if not already a pred
        if (!edge.attr_label.is_semantic_predicate)
          t = edge.attr_target
          preds = t.get_gated_predicates_in_nfaconfigurations
          if (!(preds).nil?)
            found_gated_pred = true
            pred_st = preds.gen_expr(self, get_templates, t.attr_dfa)
            edge_st.set_attribute("predicates", pred_st.to_s)
          end
        end
        if (!(edge.attr_label.get_atom).equal?(Label::EOT))
          state_st.set_attribute("edges", edge_st)
        end
        i += 1
      end
      if (found_gated_pred)
        # state has >= 1 edge with a gated pred (syn or sem)
        # must rewind input first, set flag.
        state_st.set_attribute("semPredState", Boolean.new(found_gated_pred))
      end
      if (!(eot_st).nil?)
        state_st.set_attribute("edges", eot_st)
      end
      return state_st
    end
    
    typesig { [StringTemplateGroup, Transition, ::Java::Int] }
    # Generate an expression for traversing an edge.
    def gen_label_expr(templates, edge, k)
      label = edge.attr_label
      if (label.is_semantic_predicate)
        return gen_semantic_predicate_expr(templates, edge)
      end
      if (label.is_set)
        return gen_set_expr(templates, label.get_set, k, true)
      end
      # must be simple label
      e_st = templates.get_instance_of("lookaheadTest")
      e_st.set_attribute("atom", get_token_type_as_target_label(label.get_atom))
      e_st.set_attribute("atomAsInt", Utils.integer(label.get_atom))
      e_st.set_attribute("k", Utils.integer(k))
      return e_st
    end
    
    typesig { [StringTemplateGroup, Transition] }
    def gen_semantic_predicate_expr(templates, edge)
      dfa = (edge.attr_target).attr_dfa # which DFA are we in
      label = edge.attr_label
      sem_ctx = label.get_semantic_context
      return sem_ctx.gen_expr(self, templates, dfa)
    end
    
    typesig { [StringTemplateGroup, IntSet, ::Java::Int, ::Java::Boolean] }
    # For intervals such as [3..3, 30..35], generate an expression that
    # tests the lookahead similar to LA(1)==3 || (LA(1)>=30&&LA(1)<=35)
    def gen_set_expr(templates, set, k, part_of_dfa)
      if (!(set.is_a?(IntervalSet)))
        raise IllegalArgumentException.new("unable to generate expressions for non IntervalSet objects")
      end
      iset = set
      if ((iset.get_intervals).nil? || (iset.get_intervals.size).equal?(0))
        empty_st = StringTemplate.new(templates, "")
        empty_st.set_name("empty-set-expr")
        return empty_st
      end
      test_stname = "lookaheadTest"
      test_range_stname = "lookaheadRangeTest"
      if (!part_of_dfa)
        test_stname = "isolatedLookaheadTest"
        test_range_stname = "isolatedLookaheadRangeTest"
      end
      set_st = templates.get_instance_of("setTest")
      iter = iset.get_intervals.iterator
      range_number = 1
      while (iter.has_next)
        i = iter.next_
        a = i.attr_a
        b = i.attr_b
        e_st = nil
        if ((a).equal?(b))
          e_st = templates.get_instance_of(test_stname)
          e_st.set_attribute("atom", get_token_type_as_target_label(a))
          e_st.set_attribute("atomAsInt", Utils.integer(a))
          # eST.setAttribute("k",Utils.integer(k));
        else
          e_st = templates.get_instance_of(test_range_stname)
          e_st.set_attribute("lower", get_token_type_as_target_label(a))
          e_st.set_attribute("lowerAsInt", Utils.integer(a))
          e_st.set_attribute("upper", get_token_type_as_target_label(b))
          e_st.set_attribute("upperAsInt", Utils.integer(b))
          e_st.set_attribute("rangeNumber", Utils.integer(range_number))
        end
        e_st.set_attribute("k", Utils.integer(k))
        set_st.set_attribute("ranges", e_st)
        range_number += 1
      end
      return set_st
    end
    
    typesig { [StringTemplate] }
    # T O K E N  D E F I N I T I O N  G E N E R A T I O N
    # Set attributes tokens and literals attributes in the incoming
    # code template.  This is not the token vocab interchange file, but
    # rather a list of token type ID needed by the recognizer.
    def gen_token_type_constants(code)
      # make constants for the token types
      token_ids = @grammar.get_token_ids.iterator
      while (token_ids.has_next)
        token_id = token_ids.next_
        token_type = @grammar.get_token_type(token_id)
        if ((token_type).equal?(Label::EOF) || token_type >= Label::MIN_TOKEN_TYPE)
          # don't do FAUX labels 'cept EOF
          code.set_attribute("tokens.{name,type}", token_id, Utils.integer(token_type))
        end
      end
    end
    
    typesig { [StringTemplate] }
    # Generate a token names table that maps token type to a printable
    # name: either the label like INT or the literal like "begin".
    def gen_token_type_names(code)
      t = Label::MIN_TOKEN_TYPE
      while t <= @grammar.get_max_token_type
        token_name = @grammar.get_token_display_name(t)
        if (!(token_name).nil?)
          token_name = RJava.cast_to_string(@target.get_target_string_literal_from_string(token_name, true))
          code.set_attribute("tokenNames", token_name)
        end
        t += 1
      end
    end
    
    typesig { [::Java::Int] }
    # Get a meaningful name for a token type useful during code generation.
    # Literals without associated names are converted to the string equivalent
    # of their integer values. Used to generate x==ID and x==34 type comparisons
    # etc...  Essentially we are looking for the most obvious way to refer
    # to a token type in the generated code.  If in the lexer, return the
    # char literal translated to the target language.  For example, ttype=10
    # will yield '\n' from the getTokenDisplayName method.  That must
    # be converted to the target languages literals.  For most C-derived
    # languages no translation is needed.
    def get_token_type_as_target_label(ttype)
      if ((@grammar.attr_type).equal?(Grammar::LEXER))
        name = @grammar.get_token_display_name(ttype)
        return @target.get_target_char_literal_from_antlrchar_literal(self, name)
      end
      return @target.get_token_type_as_target_label(self, ttype)
    end
    
    typesig { [] }
    # Generate a token vocab file with all the token names/types.  For example:
    # ID=7
    # FOR=8
    # 'for'=8
    # 
    # This is independent of the target language; used by antlr internally
    def gen_token_vocab_output
      vocab_file_st = StringTemplate.new(VocabFilePattern, AngleBracketTemplateLexer)
      vocab_file_st.set_name("vocab-file")
      # make constants for the token names
      token_ids = @grammar.get_token_ids.iterator
      while (token_ids.has_next)
        token_id = token_ids.next_
        token_type = @grammar.get_token_type(token_id)
        if (token_type >= Label::MIN_TOKEN_TYPE)
          vocab_file_st.set_attribute("tokens.{name,type}", token_id, Utils.integer(token_type))
        end
      end
      # now dump the strings
      literals = @grammar.get_string_literals.iterator
      while (literals.has_next)
        literal = literals.next_
        token_type = @grammar.get_token_type(literal)
        if (token_type >= Label::MIN_TOKEN_TYPE)
          vocab_file_st.set_attribute("tokens.{name,type}", literal, Utils.integer(token_type))
        end
      end
      return vocab_file_st
    end
    
    typesig { [String, GrammarAST] }
    def translate_action(rule_name, action_tree)
      if ((action_tree.get_type).equal?(ANTLRParser::ARG_ACTION))
        return translate_arg_action(rule_name, action_tree)
      end
      translator = ActionTranslator.new(self, rule_name, action_tree)
      chunks = translator.translate_to_chunks
      chunks = @target.post_process_action(chunks, action_tree.attr_token)
      return chunks
    end
    
    typesig { [String, GrammarAST] }
    # Translate an action like [3,"foo",a[3]] and return a List of the
    # translated actions.  Because actions are themselves translated to a list
    # of chunks, must cat together into a StringTemplate>.  Don't translate
    # to strings early as we need to eval templates in context.
    def translate_arg_action(rule_name, action_tree)
      action_text = action_tree.attr_token.get_text
      args = get_list_of_arguments_from_action(action_text, Character.new(?,.ord))
      translated_args = ArrayList.new
      args.each do |arg|
        if (!(arg).nil?)
          action_token = Antlr::CommonToken.new(ANTLRParser::ACTION, arg)
          translator = ActionTranslator.new(self, rule_name, action_token, action_tree.attr_outer_alt_num)
          chunks = translator.translate_to_chunks
          chunks = @target.post_process_action(chunks, action_token)
          cat_st = StringTemplate.new(@templates, "<chunks>")
          cat_st.set_attribute("chunks", chunks)
          @templates.create_string_template
          translated_args.add(cat_st)
        end
      end
      if ((translated_args.size).equal?(0))
        return nil
      end
      return translated_args
    end
    
    class_module.module_eval {
      typesig { [String, ::Java::Int] }
      def get_list_of_arguments_from_action(action_text, separator_char)
        args = ArrayList.new
        get_list_of_arguments_from_action(action_text, 0, -1, separator_char, args)
        return args
      end
      
      typesig { [String, ::Java::Int, ::Java::Int, ::Java::Int, JavaList] }
      # Given an arg action like
      # 
      # [x, (*a).foo(21,33), 3.2+1, '\n',
      # "a,oo\nick", {bl, "fdkj"eck}, ["cat\n,", x, 43]]
      # 
      # convert to a list of arguments.  Allow nested square brackets etc...
      # Set separatorChar to ';' or ',' or whatever you want.
      def get_list_of_arguments_from_action(action_text, start, target_char, separator_char, args)
        if ((action_text).nil?)
          return -1
        end
        action_text = RJava.cast_to_string(action_text.replace_all("//.*\n", ""))
        n = action_text.length
        # System.out.println("actionText@"+start+"->"+(char)targetChar+"="+actionText.substring(start,n));
        p = start
        last = p
        while (p < n && !(action_text.char_at(p)).equal?(target_char))
          c = action_text.char_at(p)
          case (c)
          when Character.new(?\'.ord)
            p += 1
            while (p < n && !(action_text.char_at(p)).equal?(Character.new(?\'.ord)))
              if ((action_text.char_at(p)).equal?(Character.new(?\\.ord)) && (p + 1) < n && (action_text.char_at(p + 1)).equal?(Character.new(?\'.ord)))
                p += 1 # skip escaped quote
              end
              p += 1
            end
            p += 1
          when Character.new(?".ord)
            p += 1
            while (p < n && !(action_text.char_at(p)).equal?(Character.new(?\".ord)))
              if ((action_text.char_at(p)).equal?(Character.new(?\\.ord)) && (p + 1) < n && (action_text.char_at(p + 1)).equal?(Character.new(?\".ord)))
                p += 1 # skip escaped quote
              end
              p += 1
            end
            p += 1
          when Character.new(?(.ord)
            p = get_list_of_arguments_from_action(action_text, p + 1, Character.new(?).ord), separator_char, args)
          when Character.new(?{.ord)
            p = get_list_of_arguments_from_action(action_text, p + 1, Character.new(?}.ord), separator_char, args)
          when Character.new(?<.ord)
            if (action_text.index_of(Character.new(?>.ord), p + 1) >= p)
              # do we see a matching '>' ahead?  if so, hope it's a generic
              # and not less followed by expr with greater than
              p = get_list_of_arguments_from_action(action_text, p + 1, Character.new(?>.ord), separator_char, args)
            else
              p += 1 # treat as normal char
            end
          when Character.new(?[.ord)
            p = get_list_of_arguments_from_action(action_text, p + 1, Character.new(?].ord), separator_char, args)
          else
            if ((c).equal?(separator_char) && (target_char).equal?(-1))
              arg = action_text.substring(last, p)
              # System.out.println("arg="+arg);
              args.add(arg.trim)
              last = p + 1
            end
            p += 1
          end
        end
        if ((target_char).equal?(-1) && p <= n)
          arg = action_text.substring(last, p).trim
          # System.out.println("arg="+arg);
          if (arg.length > 0)
            args.add(arg.trim)
          end
        end
        p += 1
        return p
      end
    }
    
    typesig { [String, ::Java::Int, Antlr::Token, String] }
    # Given a template constructor action like %foo(a={...}) in
    # an action, translate it to the appropriate template constructor
    # from the templateLib. This translates a *piece* of the action.
    def translate_template_constructor(rule_name, outer_alt_num, action_token, template_action_text)
      # first, parse with antlr.g
      # System.out.println("translate template: "+templateActionText);
      lexer = ANTLRLexer.new(StringReader.new(template_action_text))
      lexer.set_filename(@grammar.get_file_name)
      lexer.set_token_object_class("antlr.TokenWithIndex")
      token_buffer = TokenStreamRewriteEngine.new(lexer)
      token_buffer.discard(ANTLRParser::WS)
      token_buffer.discard(ANTLRParser::ML_COMMENT)
      token_buffer.discard(ANTLRParser::COMMENT)
      token_buffer.discard(ANTLRParser::SL_COMMENT)
      parser = ANTLRParser.new(token_buffer)
      parser.set_filename(@grammar.get_file_name)
      parser.set_astnode_class("org.antlr.tool.GrammarAST")
      begin
        parser.rewrite_template
      rescue RecognitionException => re
        ErrorManager.grammar_error(ErrorManager::MSG_INVALID_TEMPLATE_ACTION, @grammar, action_token, template_action_text)
      rescue JavaException => tse
        ErrorManager.internal_error("can't parse template action", tse)
      end
      rewrite_tree = parser.get_ast
      # then translate via codegen.g
      gen = CodeGenTreeWalker.new
      gen.init(@grammar)
      gen.attr_current_rule_name = rule_name
      gen.attr_outer_alt_num = outer_alt_num
      st = nil
      begin
        st = gen.rewrite_template(rewrite_tree)
      rescue RecognitionException => re
        ErrorManager.error(ErrorManager::MSG_BAD_AST_STRUCTURE, re)
      end
      return st
    end
    
    typesig { [String, String, Rule, Antlr::Token, ::Java::Int] }
    def issue_invalid_scope_error(x, y, enclosing_rule, action_token, outer_alt_num)
      # System.out.println("error $"+x+"::"+y);
      r = @grammar.get_rule(x)
      scope = @grammar.get_global_scope(x)
      if ((scope).nil?)
        if (!(r).nil?)
          scope = r.attr_rule_scope # if not global, might be rule scope
        end
      end
      if ((scope).nil?)
        ErrorManager.grammar_error(ErrorManager::MSG_UNKNOWN_DYNAMIC_SCOPE, @grammar, action_token, x)
      else
        if ((scope.get_attribute(y)).nil?)
          ErrorManager.grammar_error(ErrorManager::MSG_UNKNOWN_DYNAMIC_SCOPE_ATTRIBUTE, @grammar, action_token, x, y)
        end
      end
    end
    
    typesig { [String, String, Rule, Antlr::Token, ::Java::Int] }
    def issue_invalid_attribute_error(x, y, enclosing_rule, action_token, outer_alt_num)
      # System.out.println("error $"+x+"."+y);
      if ((enclosing_rule).nil?)
        # action not in a rule
        ErrorManager.grammar_error(ErrorManager::MSG_ATTRIBUTE_REF_NOT_IN_RULE, @grammar, action_token, x, y)
        return
      end
      # action is in a rule
      label = enclosing_rule.get_rule_label(x)
      if (!(label).nil? || !(enclosing_rule.get_rule_refs_in_alt(x, outer_alt_num)).nil?)
        # $rulelabel.attr or $ruleref.attr; must be unknown attr
        refd_rule_name = x
        if (!(label).nil?)
          refd_rule_name = RJava.cast_to_string(enclosing_rule.get_rule_label(x).attr_referenced_rule_name)
        end
        refd_rule = @grammar.get_rule(refd_rule_name)
        scope = refd_rule.get_attribute_scope(y)
        if ((scope).nil?)
          ErrorManager.grammar_error(ErrorManager::MSG_UNKNOWN_RULE_ATTRIBUTE, @grammar, action_token, refd_rule_name, y)
        else
          if (scope.attr_is_parameter_scope)
            ErrorManager.grammar_error(ErrorManager::MSG_INVALID_RULE_PARAMETER_REF, @grammar, action_token, refd_rule_name, y)
          else
            if (scope.attr_is_dynamic_rule_scope)
              ErrorManager.grammar_error(ErrorManager::MSG_INVALID_RULE_SCOPE_ATTRIBUTE_REF, @grammar, action_token, refd_rule_name, y)
            end
          end
        end
      end
    end
    
    typesig { [String, Rule, Antlr::Token, ::Java::Int] }
    def issue_invalid_attribute_error(x, enclosing_rule, action_token, outer_alt_num)
      # System.out.println("error $"+x);
      if ((enclosing_rule).nil?)
        # action not in a rule
        ErrorManager.grammar_error(ErrorManager::MSG_ATTRIBUTE_REF_NOT_IN_RULE, @grammar, action_token, x)
        return
      end
      # action is in a rule
      label = enclosing_rule.get_rule_label(x)
      scope = enclosing_rule.get_attribute_scope(x)
      if (!(label).nil? || !(enclosing_rule.get_rule_refs_in_alt(x, outer_alt_num)).nil? || (enclosing_rule.attr_name == x))
        ErrorManager.grammar_error(ErrorManager::MSG_ISOLATED_RULE_SCOPE, @grammar, action_token, x)
      else
        if (!(scope).nil? && scope.attr_is_dynamic_rule_scope)
          ErrorManager.grammar_error(ErrorManager::MSG_ISOLATED_RULE_ATTRIBUTE, @grammar, action_token, x)
        else
          ErrorManager.grammar_error(ErrorManager::MSG_UNKNOWN_SIMPLE_ATTRIBUTE, @grammar, action_token, x)
        end
      end
    end
    
    typesig { [] }
    # M I S C
    def get_templates
      return @templates
    end
    
    typesig { [] }
    def get_base_templates
      return @base_templates
    end
    
    typesig { [::Java::Boolean] }
    def set_debug(debug)
      @debug = debug
    end
    
    typesig { [::Java::Boolean] }
    def set_trace(trace)
      @trace = trace
    end
    
    typesig { [::Java::Boolean] }
    def set_profile(profile)
      @profile = profile
      if (profile)
        set_debug(true) # requires debug events
      end
    end
    
    typesig { [] }
    def get_recognizer_st
      return @output_file_st
    end
    
    typesig { [String, ::Java::Int] }
    # Generate TParser.java and TLexer.java from T.g if combined, else
    # just use T.java as output regardless of type.
    def get_recognizer_file_name(name, type)
      ext_st = @templates.get_instance_of("codeFileExtension")
      recognizer_name = @grammar.get_recognizer_name
      return recognizer_name + RJava.cast_to_string(ext_st.to_s)
      # String suffix = "";
      # if ( type==Grammar.COMBINED ||
      # (type==Grammar.LEXER && !grammar.implicitLexer) )
      # {
      # suffix = Grammar.grammarTypeToFileNameSuffix[type];
      # }
      # return name+suffix+extST.toString();
    end
    
    typesig { [] }
    # What is the name of the vocab file generated for this grammar?
    # Returns null if no .tokens file should be generated.
    def get_vocab_file_name
      if (@grammar.is_built_from_string)
        return nil
      end
      return RJava.cast_to_string(@grammar.attr_name) + VOCAB_FILE_EXTENSION
    end
    
    typesig { [StringTemplate, String] }
    def write(code, file_name)
      start = System.current_time_millis
      w = @tool.get_output_file(@grammar, file_name)
      # Write the output to a StringWriter
      wr = @templates.get_string_template_writer(w)
      wr.set_line_width(@line_width)
      code.write(wr)
      w.close
      stop = System.current_time_millis
      # System.out.println("render time for "+fileName+": "+(int)(stop-start)+"ms");
    end
    
    typesig { [DFAState] }
    # You can generate a switch rather than if-then-else for a DFA state
    # if there are no semantic predicates and the number of edge label
    # values is small enough; e.g., don't generate a switch for a state
    # containing an edge label such as 20..52330 (the resulting byte codes
    # would overflow the method 65k limit probably).
    def can_generate_switch(s)
      if (!@generate_switches_when_possible)
        return false
      end
      size_ = 0
      i = 0
      while i < s.get_number_of_transitions
        edge = s.transition(i)
        if (edge.attr_label.is_semantic_predicate)
          return false
        end
        # can't do a switch if the edges are going to require predicates
        if ((edge.attr_label.get_atom).equal?(Label::EOT))
          eotpredicts = (edge.attr_target).get_uniquely_predicted_alt
          if ((eotpredicts).equal?(NFA::INVALID_ALT_NUMBER))
            # EOT target has to be a predicate then; no unique alt
            return false
          end
        end
        # if target is a state with gated preds, we need to use preds on
        # this edge then to reach it.
        if (!((edge.attr_target).get_gated_predicates_in_nfaconfigurations).nil?)
          return false
        end
        size_ += edge.attr_label.get_set.size
        i += 1
      end
      if (s.get_number_of_transitions < @min_switch_alts || size_ > @max_switch_case_labels)
        return false
      end
      return true
    end
    
    typesig { [String] }
    # Create a label to track a token / rule reference's result.
    # Technically, this is a place where I break model-view separation
    # as I am creating a variable name that could be invalid in a
    # target language, however, label ::= <ID><INT> is probably ok in
    # all languages we care about.
    def create_unique_label(name)
      return StringBuffer.new.append(name).append(((@unique_label_number += 1) - 1)).to_s
    end
    
    private
    alias_method :initialize__code_generator, :initialize
  end
  
end
