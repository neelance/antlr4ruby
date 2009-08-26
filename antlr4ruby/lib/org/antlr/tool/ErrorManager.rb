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
  module ErrorManagerImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Tool
      include_const ::Antlr, :Token
      include_const ::Org::Antlr, :Tool
      include_const ::Org::Antlr::Misc, :BitSet
      include_const ::Org::Antlr::Analysis, :DFAState
      include_const ::Org::Antlr::Analysis, :DecisionProbe
      include_const ::Org::Antlr::Analysis, :Label
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateErrorListener
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateGroup
      include_const ::Org::Antlr::Stringtemplate::Language, :AngleBracketTemplateLexer
      include_const ::Java::Io, :BufferedReader
      include_const ::Java::Io, :IOException
      include_const ::Java::Io, :InputStream
      include_const ::Java::Io, :InputStreamReader
      include_const ::Java::Lang::Reflect, :Field
      include_const ::Java::Lang::Reflect, :InvocationTargetException
      include ::Java::Util
    }
  end
  
  # Defines all the errors ANTLR can generator for both the tool and for
  # issues with a grammar.
  # 
  # Here is a list of language names:
  # 
  # http://ftp.ics.uci.edu/pub/ietf/http/related/iso639.txt
  # 
  # Here is a list of country names:
  # 
  # http://www.chemie.fu-berlin.de/diverse/doc/ISO_3166.html
  # 
  # I use constants not strings to identify messages as the compiler will
  # find any errors/mismatches rather than leaving a mistyped string in
  # the code to be found randomly in the future.  Further, Intellij can
  # do field name expansion to save me some typing.  I have to map
  # int constants to template names, however, which could introduce a mismatch.
  # Someone could provide a .stg file that had a template name wrong.  When
  # I load the group, then, I must verify that all messages are there.
  # 
  # This is essentially the functionality of the resource bundle stuff Java
  # has, but I don't want to load a property file--I want to load a template
  # group file and this is so simple, why mess with their junk.
  # 
  # I use the default Locale as defined by java to compute a group file name
  # in the org/antlr/tool/templates/messages dir called en_US.stg and so on.
  # 
  # Normally we want to use the default locale, but often a message file will
  # not exist for it so we must fall back on the US local.
  # 
  # During initialization of this class, all errors go straight to System.err.
  # There is no way around this.  If I have not set up the error system, how
  # can I do errors properly?  For example, if the string template group file
  # full of messages has an error, how could I print to anything but System.err?
  # 
  # TODO: how to map locale to a file encoding for the stringtemplate group file?
  # StringTemplate knows how to pay attention to the default encoding so it
  # should probably just work unless a GUI sets the local to some chinese
  # variation but System.getProperty("file.encoding") is US.  Hmm...
  # 
  # TODO: get antlr.g etc.. parsing errors to come here.
  class ErrorManager 
    include_class_members ErrorManagerImports
    
    class_module.module_eval {
      # TOOL ERRORS
      # file errors
      const_set_lazy(:MSG_CANNOT_WRITE_FILE) { 1 }
      const_attr_reader  :MSG_CANNOT_WRITE_FILE
      
      const_set_lazy(:MSG_CANNOT_CLOSE_FILE) { 2 }
      const_attr_reader  :MSG_CANNOT_CLOSE_FILE
      
      const_set_lazy(:MSG_CANNOT_FIND_TOKENS_FILE) { 3 }
      const_attr_reader  :MSG_CANNOT_FIND_TOKENS_FILE
      
      const_set_lazy(:MSG_ERROR_READING_TOKENS_FILE) { 4 }
      const_attr_reader  :MSG_ERROR_READING_TOKENS_FILE
      
      const_set_lazy(:MSG_DIR_NOT_FOUND) { 5 }
      const_attr_reader  :MSG_DIR_NOT_FOUND
      
      const_set_lazy(:MSG_OUTPUT_DIR_IS_FILE) { 6 }
      const_attr_reader  :MSG_OUTPUT_DIR_IS_FILE
      
      const_set_lazy(:MSG_CANNOT_OPEN_FILE) { 7 }
      const_attr_reader  :MSG_CANNOT_OPEN_FILE
      
      const_set_lazy(:MSG_FILE_AND_GRAMMAR_NAME_DIFFER) { 8 }
      const_attr_reader  :MSG_FILE_AND_GRAMMAR_NAME_DIFFER
      
      const_set_lazy(:MSG_FILENAME_EXTENSION_ERROR) { 9 }
      const_attr_reader  :MSG_FILENAME_EXTENSION_ERROR
      
      const_set_lazy(:MSG_INTERNAL_ERROR) { 10 }
      const_attr_reader  :MSG_INTERNAL_ERROR
      
      const_set_lazy(:MSG_INTERNAL_WARNING) { 11 }
      const_attr_reader  :MSG_INTERNAL_WARNING
      
      const_set_lazy(:MSG_ERROR_CREATING_ARTIFICIAL_RULE) { 12 }
      const_attr_reader  :MSG_ERROR_CREATING_ARTIFICIAL_RULE
      
      const_set_lazy(:MSG_TOKENS_FILE_SYNTAX_ERROR) { 13 }
      const_attr_reader  :MSG_TOKENS_FILE_SYNTAX_ERROR
      
      const_set_lazy(:MSG_CANNOT_GEN_DOT_FILE) { 14 }
      const_attr_reader  :MSG_CANNOT_GEN_DOT_FILE
      
      const_set_lazy(:MSG_BAD_AST_STRUCTURE) { 15 }
      const_attr_reader  :MSG_BAD_AST_STRUCTURE
      
      const_set_lazy(:MSG_BAD_ACTION_AST_STRUCTURE) { 16 }
      const_attr_reader  :MSG_BAD_ACTION_AST_STRUCTURE
      
      # code gen errors
      const_set_lazy(:MSG_MISSING_CODE_GEN_TEMPLATES) { 20 }
      const_attr_reader  :MSG_MISSING_CODE_GEN_TEMPLATES
      
      const_set_lazy(:MSG_MISSING_CYCLIC_DFA_CODE_GEN_TEMPLATES) { 21 }
      const_attr_reader  :MSG_MISSING_CYCLIC_DFA_CODE_GEN_TEMPLATES
      
      const_set_lazy(:MSG_CODE_GEN_TEMPLATES_INCOMPLETE) { 22 }
      const_attr_reader  :MSG_CODE_GEN_TEMPLATES_INCOMPLETE
      
      const_set_lazy(:MSG_CANNOT_CREATE_TARGET_GENERATOR) { 23 }
      const_attr_reader  :MSG_CANNOT_CREATE_TARGET_GENERATOR
      
      # public static final int MSG_CANNOT_COMPUTE_SAMPLE_INPUT_SEQ = 24;
      # GRAMMAR ERRORS
      const_set_lazy(:MSG_SYNTAX_ERROR) { 100 }
      const_attr_reader  :MSG_SYNTAX_ERROR
      
      const_set_lazy(:MSG_RULE_REDEFINITION) { 101 }
      const_attr_reader  :MSG_RULE_REDEFINITION
      
      const_set_lazy(:MSG_LEXER_RULES_NOT_ALLOWED) { 102 }
      const_attr_reader  :MSG_LEXER_RULES_NOT_ALLOWED
      
      const_set_lazy(:MSG_PARSER_RULES_NOT_ALLOWED) { 103 }
      const_attr_reader  :MSG_PARSER_RULES_NOT_ALLOWED
      
      const_set_lazy(:MSG_CANNOT_FIND_ATTRIBUTE_NAME_IN_DECL) { 104 }
      const_attr_reader  :MSG_CANNOT_FIND_ATTRIBUTE_NAME_IN_DECL
      
      const_set_lazy(:MSG_NO_TOKEN_DEFINITION) { 105 }
      const_attr_reader  :MSG_NO_TOKEN_DEFINITION
      
      const_set_lazy(:MSG_UNDEFINED_RULE_REF) { 106 }
      const_attr_reader  :MSG_UNDEFINED_RULE_REF
      
      const_set_lazy(:MSG_LITERAL_NOT_ASSOCIATED_WITH_LEXER_RULE) { 107 }
      const_attr_reader  :MSG_LITERAL_NOT_ASSOCIATED_WITH_LEXER_RULE
      
      const_set_lazy(:MSG_CANNOT_ALIAS_TOKENS_IN_LEXER) { 108 }
      const_attr_reader  :MSG_CANNOT_ALIAS_TOKENS_IN_LEXER
      
      const_set_lazy(:MSG_ATTRIBUTE_REF_NOT_IN_RULE) { 111 }
      const_attr_reader  :MSG_ATTRIBUTE_REF_NOT_IN_RULE
      
      const_set_lazy(:MSG_INVALID_RULE_SCOPE_ATTRIBUTE_REF) { 112 }
      const_attr_reader  :MSG_INVALID_RULE_SCOPE_ATTRIBUTE_REF
      
      const_set_lazy(:MSG_UNKNOWN_ATTRIBUTE_IN_SCOPE) { 113 }
      const_attr_reader  :MSG_UNKNOWN_ATTRIBUTE_IN_SCOPE
      
      const_set_lazy(:MSG_UNKNOWN_SIMPLE_ATTRIBUTE) { 114 }
      const_attr_reader  :MSG_UNKNOWN_SIMPLE_ATTRIBUTE
      
      const_set_lazy(:MSG_INVALID_RULE_PARAMETER_REF) { 115 }
      const_attr_reader  :MSG_INVALID_RULE_PARAMETER_REF
      
      const_set_lazy(:MSG_UNKNOWN_RULE_ATTRIBUTE) { 116 }
      const_attr_reader  :MSG_UNKNOWN_RULE_ATTRIBUTE
      
      const_set_lazy(:MSG_ISOLATED_RULE_SCOPE) { 117 }
      const_attr_reader  :MSG_ISOLATED_RULE_SCOPE
      
      const_set_lazy(:MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE) { 118 }
      const_attr_reader  :MSG_SYMBOL_CONFLICTS_WITH_GLOBAL_SCOPE
      
      const_set_lazy(:MSG_LABEL_CONFLICTS_WITH_RULE) { 119 }
      const_attr_reader  :MSG_LABEL_CONFLICTS_WITH_RULE
      
      const_set_lazy(:MSG_LABEL_CONFLICTS_WITH_TOKEN) { 120 }
      const_attr_reader  :MSG_LABEL_CONFLICTS_WITH_TOKEN
      
      const_set_lazy(:MSG_LABEL_CONFLICTS_WITH_RULE_SCOPE_ATTRIBUTE) { 121 }
      const_attr_reader  :MSG_LABEL_CONFLICTS_WITH_RULE_SCOPE_ATTRIBUTE
      
      const_set_lazy(:MSG_LABEL_CONFLICTS_WITH_RULE_ARG_RETVAL) { 122 }
      const_attr_reader  :MSG_LABEL_CONFLICTS_WITH_RULE_ARG_RETVAL
      
      const_set_lazy(:MSG_ATTRIBUTE_CONFLICTS_WITH_RULE) { 123 }
      const_attr_reader  :MSG_ATTRIBUTE_CONFLICTS_WITH_RULE
      
      const_set_lazy(:MSG_ATTRIBUTE_CONFLICTS_WITH_RULE_ARG_RETVAL) { 124 }
      const_attr_reader  :MSG_ATTRIBUTE_CONFLICTS_WITH_RULE_ARG_RETVAL
      
      const_set_lazy(:MSG_LABEL_TYPE_CONFLICT) { 125 }
      const_attr_reader  :MSG_LABEL_TYPE_CONFLICT
      
      const_set_lazy(:MSG_ARG_RETVAL_CONFLICT) { 126 }
      const_attr_reader  :MSG_ARG_RETVAL_CONFLICT
      
      const_set_lazy(:MSG_NONUNIQUE_REF) { 127 }
      const_attr_reader  :MSG_NONUNIQUE_REF
      
      const_set_lazy(:MSG_FORWARD_ELEMENT_REF) { 128 }
      const_attr_reader  :MSG_FORWARD_ELEMENT_REF
      
      const_set_lazy(:MSG_MISSING_RULE_ARGS) { 129 }
      const_attr_reader  :MSG_MISSING_RULE_ARGS
      
      const_set_lazy(:MSG_RULE_HAS_NO_ARGS) { 130 }
      const_attr_reader  :MSG_RULE_HAS_NO_ARGS
      
      const_set_lazy(:MSG_ARGS_ON_TOKEN_REF) { 131 }
      const_attr_reader  :MSG_ARGS_ON_TOKEN_REF
      
      const_set_lazy(:MSG_RULE_REF_AMBIG_WITH_RULE_IN_ALT) { 132 }
      const_attr_reader  :MSG_RULE_REF_AMBIG_WITH_RULE_IN_ALT
      
      const_set_lazy(:MSG_ILLEGAL_OPTION) { 133 }
      const_attr_reader  :MSG_ILLEGAL_OPTION
      
      const_set_lazy(:MSG_LIST_LABEL_INVALID_UNLESS_RETVAL_STRUCT) { 134 }
      const_attr_reader  :MSG_LIST_LABEL_INVALID_UNLESS_RETVAL_STRUCT
      
      const_set_lazy(:MSG_UNDEFINED_TOKEN_REF_IN_REWRITE) { 135 }
      const_attr_reader  :MSG_UNDEFINED_TOKEN_REF_IN_REWRITE
      
      const_set_lazy(:MSG_REWRITE_ELEMENT_NOT_PRESENT_ON_LHS) { 136 }
      const_attr_reader  :MSG_REWRITE_ELEMENT_NOT_PRESENT_ON_LHS
      
      const_set_lazy(:MSG_UNDEFINED_LABEL_REF_IN_REWRITE) { 137 }
      const_attr_reader  :MSG_UNDEFINED_LABEL_REF_IN_REWRITE
      
      const_set_lazy(:MSG_NO_GRAMMAR_START_RULE) { 138 }
      const_attr_reader  :MSG_NO_GRAMMAR_START_RULE
      
      const_set_lazy(:MSG_EMPTY_COMPLEMENT) { 139 }
      const_attr_reader  :MSG_EMPTY_COMPLEMENT
      
      const_set_lazy(:MSG_UNKNOWN_DYNAMIC_SCOPE) { 140 }
      const_attr_reader  :MSG_UNKNOWN_DYNAMIC_SCOPE
      
      const_set_lazy(:MSG_UNKNOWN_DYNAMIC_SCOPE_ATTRIBUTE) { 141 }
      const_attr_reader  :MSG_UNKNOWN_DYNAMIC_SCOPE_ATTRIBUTE
      
      const_set_lazy(:MSG_ISOLATED_RULE_ATTRIBUTE) { 142 }
      const_attr_reader  :MSG_ISOLATED_RULE_ATTRIBUTE
      
      const_set_lazy(:MSG_INVALID_ACTION_SCOPE) { 143 }
      const_attr_reader  :MSG_INVALID_ACTION_SCOPE
      
      const_set_lazy(:MSG_ACTION_REDEFINITION) { 144 }
      const_attr_reader  :MSG_ACTION_REDEFINITION
      
      const_set_lazy(:MSG_DOUBLE_QUOTES_ILLEGAL) { 145 }
      const_attr_reader  :MSG_DOUBLE_QUOTES_ILLEGAL
      
      const_set_lazy(:MSG_INVALID_TEMPLATE_ACTION) { 146 }
      const_attr_reader  :MSG_INVALID_TEMPLATE_ACTION
      
      const_set_lazy(:MSG_MISSING_ATTRIBUTE_NAME) { 147 }
      const_attr_reader  :MSG_MISSING_ATTRIBUTE_NAME
      
      const_set_lazy(:MSG_ARG_INIT_VALUES_ILLEGAL) { 148 }
      const_attr_reader  :MSG_ARG_INIT_VALUES_ILLEGAL
      
      const_set_lazy(:MSG_REWRITE_OR_OP_WITH_NO_OUTPUT_OPTION) { 149 }
      const_attr_reader  :MSG_REWRITE_OR_OP_WITH_NO_OUTPUT_OPTION
      
      const_set_lazy(:MSG_NO_RULES) { 150 }
      const_attr_reader  :MSG_NO_RULES
      
      const_set_lazy(:MSG_WRITE_TO_READONLY_ATTR) { 151 }
      const_attr_reader  :MSG_WRITE_TO_READONLY_ATTR
      
      const_set_lazy(:MSG_MISSING_AST_TYPE_IN_TREE_GRAMMAR) { 152 }
      const_attr_reader  :MSG_MISSING_AST_TYPE_IN_TREE_GRAMMAR
      
      const_set_lazy(:MSG_REWRITE_FOR_MULTI_ELEMENT_ALT) { 153 }
      const_attr_reader  :MSG_REWRITE_FOR_MULTI_ELEMENT_ALT
      
      const_set_lazy(:MSG_RULE_INVALID_SET) { 154 }
      const_attr_reader  :MSG_RULE_INVALID_SET
      
      const_set_lazy(:MSG_HETERO_ILLEGAL_IN_REWRITE_ALT) { 155 }
      const_attr_reader  :MSG_HETERO_ILLEGAL_IN_REWRITE_ALT
      
      const_set_lazy(:MSG_NO_SUCH_GRAMMAR_SCOPE) { 156 }
      const_attr_reader  :MSG_NO_SUCH_GRAMMAR_SCOPE
      
      const_set_lazy(:MSG_NO_SUCH_RULE_IN_SCOPE) { 157 }
      const_attr_reader  :MSG_NO_SUCH_RULE_IN_SCOPE
      
      const_set_lazy(:MSG_TOKEN_ALIAS_CONFLICT) { 158 }
      const_attr_reader  :MSG_TOKEN_ALIAS_CONFLICT
      
      const_set_lazy(:MSG_TOKEN_ALIAS_REASSIGNMENT) { 159 }
      const_attr_reader  :MSG_TOKEN_ALIAS_REASSIGNMENT
      
      const_set_lazy(:MSG_TOKEN_VOCAB_IN_DELEGATE) { 160 }
      const_attr_reader  :MSG_TOKEN_VOCAB_IN_DELEGATE
      
      const_set_lazy(:MSG_INVALID_IMPORT) { 161 }
      const_attr_reader  :MSG_INVALID_IMPORT
      
      const_set_lazy(:MSG_IMPORTED_TOKENS_RULE_EMPTY) { 162 }
      const_attr_reader  :MSG_IMPORTED_TOKENS_RULE_EMPTY
      
      const_set_lazy(:MSG_IMPORT_NAME_CLASH) { 163 }
      const_attr_reader  :MSG_IMPORT_NAME_CLASH
      
      const_set_lazy(:MSG_AST_OP_WITH_NON_AST_OUTPUT_OPTION) { 164 }
      const_attr_reader  :MSG_AST_OP_WITH_NON_AST_OUTPUT_OPTION
      
      const_set_lazy(:MSG_AST_OP_IN_ALT_WITH_REWRITE) { 165 }
      const_attr_reader  :MSG_AST_OP_IN_ALT_WITH_REWRITE
      
      # GRAMMAR WARNINGS
      const_set_lazy(:MSG_GRAMMAR_NONDETERMINISM) { 200 }
      const_attr_reader  :MSG_GRAMMAR_NONDETERMINISM
      
      # A predicts alts 1,2
      const_set_lazy(:MSG_UNREACHABLE_ALTS) { 201 }
      const_attr_reader  :MSG_UNREACHABLE_ALTS
      
      # nothing predicts alt i
      const_set_lazy(:MSG_DANGLING_STATE) { 202 }
      const_attr_reader  :MSG_DANGLING_STATE
      
      # no edges out of state
      const_set_lazy(:MSG_INSUFFICIENT_PREDICATES) { 203 }
      const_attr_reader  :MSG_INSUFFICIENT_PREDICATES
      
      const_set_lazy(:MSG_DUPLICATE_SET_ENTRY) { 204 }
      const_attr_reader  :MSG_DUPLICATE_SET_ENTRY
      
      # (A|A)
      const_set_lazy(:MSG_ANALYSIS_ABORTED) { 205 }
      const_attr_reader  :MSG_ANALYSIS_ABORTED
      
      const_set_lazy(:MSG_RECURSION_OVERLOW) { 206 }
      const_attr_reader  :MSG_RECURSION_OVERLOW
      
      const_set_lazy(:MSG_LEFT_RECURSION) { 207 }
      const_attr_reader  :MSG_LEFT_RECURSION
      
      const_set_lazy(:MSG_UNREACHABLE_TOKENS) { 208 }
      const_attr_reader  :MSG_UNREACHABLE_TOKENS
      
      # nothing predicts token
      const_set_lazy(:MSG_TOKEN_NONDETERMINISM) { 209 }
      const_attr_reader  :MSG_TOKEN_NONDETERMINISM
      
      # alts of Tokens rule
      const_set_lazy(:MSG_LEFT_RECURSION_CYCLES) { 210 }
      const_attr_reader  :MSG_LEFT_RECURSION_CYCLES
      
      const_set_lazy(:MSG_NONREGULAR_DECISION) { 211 }
      const_attr_reader  :MSG_NONREGULAR_DECISION
      
      const_set_lazy(:MAX_MESSAGE_NUMBER) { 211 }
      const_attr_reader  :MAX_MESSAGE_NUMBER
      
      add(MSG_RULE_REDEFINITION)
      add(MSG_UNDEFINED_RULE_REF)
      add(MSG_LEFT_RECURSION_CYCLES)
      add(MSG_REWRITE_OR_OP_WITH_NO_OUTPUT_OPTION)
      add(MSG_NO_RULES)
      add(MSG_NO_SUCH_GRAMMAR_SCOPE)
      add(MSG_NO_SUCH_RULE_IN_SCOPE)
      add(MSG_LEXER_RULES_NOT_ALLOWED)
      # TODO: ...
      const_set_lazy(:ERRORS_FORCING_NO_ANALYSIS) { # Do not do perform analysis if one of these happens
      Class.new(BitSet.class == Class ? BitSet : Object) do
        extend LocalClass
        include_class_members ErrorManager
        include BitSet if BitSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :ERRORS_FORCING_NO_ANALYSIS
      
      add(MSG_NONREGULAR_DECISION)
      add(MSG_RECURSION_OVERLOW)
      add(MSG_UNREACHABLE_ALTS)
      add(MSG_FILE_AND_GRAMMAR_NAME_DIFFER)
      add(MSG_INVALID_IMPORT)
      add(MSG_AST_OP_WITH_NON_AST_OUTPUT_OPTION)
      # TODO: ...
      const_set_lazy(:ERRORS_FORCING_NO_CODEGEN) { # Do not do code gen if one of these happens
      Class.new(BitSet.class == Class ? BitSet : Object) do
        extend LocalClass
        include_class_members ErrorManager
        include BitSet if BitSet.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :ERRORS_FORCING_NO_CODEGEN
      
      put("danglingState", HashSet.new)
      const_set_lazy(:EmitSingleError) { # Only one error can be emitted for any entry in this table.
      # Map<String,Set> where the key is a method name like danglingState.
      # The set is whatever that method accepts or derives like a DFA.
      Class.new(HashMap.class == Class ? HashMap : Object) do
        extend LocalClass
        include_class_members ErrorManager
        include HashMap if HashMap.class == Module
        
        typesig { [] }
        define_method :initialize do
          super()
        end
        
        private
        alias_method :initialize_anonymous, :initialize
      end.new_local(self) }
      const_attr_reader  :EmitSingleError
      
      # Messages should be sensitive to the locale.
      
      def locale
        defined?(@@locale) ? @@locale : @@locale= nil
      end
      alias_method :attr_locale, :locale
      
      def locale=(value)
        @@locale = value
      end
      alias_method :attr_locale=, :locale=
      
      
      def format_name
        defined?(@@format_name) ? @@format_name : @@format_name= nil
      end
      alias_method :attr_format_name, :format_name
      
      def format_name=(value)
        @@format_name = value
      end
      alias_method :attr_format_name=, :format_name=
      
      # Each thread might need it's own error listener; e.g., a GUI with
      # multiple window frames holding multiple grammars.
      
      def thread_to_listener_map
        defined?(@@thread_to_listener_map) ? @@thread_to_listener_map : @@thread_to_listener_map= HashMap.new
      end
      alias_method :attr_thread_to_listener_map, :thread_to_listener_map
      
      def thread_to_listener_map=(value)
        @@thread_to_listener_map = value
      end
      alias_method :attr_thread_to_listener_map=, :thread_to_listener_map=
      
      # TODO: figure out how to do info messages. these do not have IDs...kr
      # public BitSet infoMsgIDs = new BitSet();
      const_set_lazy(:ErrorState) { Class.new do
        include_class_members ErrorManager
        
        attr_accessor :errors
        alias_method :attr_errors, :errors
        undef_method :errors
        alias_method :attr_errors=, :errors=
        undef_method :errors=
        
        attr_accessor :warnings
        alias_method :attr_warnings, :warnings
        undef_method :warnings
        alias_method :attr_warnings=, :warnings=
        undef_method :warnings=
        
        attr_accessor :infos
        alias_method :attr_infos, :infos
        undef_method :infos
        alias_method :attr_infos=, :infos=
        undef_method :infos=
        
        # Track all msgIDs; we use to abort later if necessary
        # also used in Message to find out what type of message it is via getMessageType()
        attr_accessor :error_msg_ids
        alias_method :attr_error_msg_ids, :error_msg_ids
        undef_method :error_msg_ids
        alias_method :attr_error_msg_ids=, :error_msg_ids=
        undef_method :error_msg_ids=
        
        attr_accessor :warning_msg_ids
        alias_method :attr_warning_msg_ids, :warning_msg_ids
        undef_method :warning_msg_ids
        alias_method :attr_warning_msg_ids=, :warning_msg_ids=
        undef_method :warning_msg_ids=
        
        typesig { [] }
        def initialize
          @errors = 0
          @warnings = 0
          @infos = 0
          @error_msg_ids = self.class::BitSet.new
          @warning_msg_ids = self.class::BitSet.new
        end
        
        private
        alias_method :initialize__error_state, :initialize
      end }
      
      # Track the number of errors regardless of the listener but track
      # per thread.
      
      def thread_to_error_state_map
        defined?(@@thread_to_error_state_map) ? @@thread_to_error_state_map : @@thread_to_error_state_map= HashMap.new
      end
      alias_method :attr_thread_to_error_state_map, :thread_to_error_state_map
      
      def thread_to_error_state_map=(value)
        @@thread_to_error_state_map = value
      end
      alias_method :attr_thread_to_error_state_map=, :thread_to_error_state_map=
      
      # Each thread has its own ptr to a Tool object, which knows how
      # to panic, for example.  In a GUI, the thread might just throw an Error
      # to exit rather than the suicide System.exit.
      
      def thread_to_tool_map
        defined?(@@thread_to_tool_map) ? @@thread_to_tool_map : @@thread_to_tool_map= HashMap.new
      end
      alias_method :attr_thread_to_tool_map, :thread_to_tool_map
      
      def thread_to_tool_map=(value)
        @@thread_to_tool_map = value
      end
      alias_method :attr_thread_to_tool_map=, :thread_to_tool_map=
      
      # The group of templates that represent all possible ANTLR errors.
      
      def messages
        defined?(@@messages) ? @@messages : @@messages= nil
      end
      alias_method :attr_messages, :messages
      
      def messages=(value)
        @@messages = value
      end
      alias_method :attr_messages=, :messages=
      
      # The group of templates that represent the current message format.
      
      def format
        defined?(@@format) ? @@format : @@format= nil
      end
      alias_method :attr_format, :format
      
      def format=(value)
        @@format = value
      end
      alias_method :attr_format=, :format=
      
      # From a msgID how can I get the name of the template that describes
      # the error or warning?
      
      def id_to_message_template_name
        defined?(@@id_to_message_template_name) ? @@id_to_message_template_name : @@id_to_message_template_name= Array.typed(String).new(MAX_MESSAGE_NUMBER + 1) { nil }
      end
      alias_method :attr_id_to_message_template_name, :id_to_message_template_name
      
      def id_to_message_template_name=(value)
        @@id_to_message_template_name = value
      end
      alias_method :attr_id_to_message_template_name=, :id_to_message_template_name=
      
      
      def the_default_error_listener
        defined?(@@the_default_error_listener) ? @@the_default_error_listener : @@the_default_error_listener= Class.new(ANTLRErrorListener.class == Class ? ANTLRErrorListener : Object) do
          extend LocalClass
          include_class_members ErrorManager
          include ANTLRErrorListener if ANTLRErrorListener.class == Module
          
          typesig { [String] }
          define_method :info do |msg|
            if (format_wants_single_line_message)
              msg = RJava.cast_to_string(msg.replace_all("\n", " "))
            end
            System.err.println(msg)
          end
          
          typesig { [Message] }
          define_method :error do |msg|
            output_msg = msg.to_s
            if (format_wants_single_line_message)
              output_msg = RJava.cast_to_string(output_msg.replace_all("\n", " "))
            end
            System.err.println(output_msg)
          end
          
          typesig { [Message] }
          define_method :warning do |msg|
            output_msg = msg.to_s
            if (format_wants_single_line_message)
              output_msg = RJava.cast_to_string(output_msg.replace_all("\n", " "))
            end
            System.err.println(output_msg)
          end
          
          typesig { [ToolMessage] }
          define_method :error do |msg|
            output_msg = msg.to_s
            if (format_wants_single_line_message)
              output_msg = RJava.cast_to_string(output_msg.replace_all("\n", " "))
            end
            System.err.println(output_msg)
          end
          
          typesig { [] }
          define_method :initialize do
            super()
          end
          
          private
          alias_method :initialize_anonymous, :initialize
        end.new_local(self)
      end
      alias_method :attr_the_default_error_listener, :the_default_error_listener
      
      def the_default_error_listener=(value)
        @@the_default_error_listener = value
      end
      alias_method :attr_the_default_error_listener=, :the_default_error_listener=
      
      
      def init_stlistener
        defined?(@@init_stlistener) ? @@init_stlistener : @@init_stlistener= # Handle all ST error listeners here (code gen, Grammar, and this class
        # use templates.
        Class.new(StringTemplateErrorListener.class == Class ? StringTemplateErrorListener : Object) do
          extend LocalClass
          include_class_members ErrorManager
          include StringTemplateErrorListener if StringTemplateErrorListener.class == Module
          
          typesig { [String, JavaThrowable] }
          define_method :error do |s, e|
            System.err.println("ErrorManager init error: " + s)
            if (!(e).nil?)
              System.err.println("exception: " + RJava.cast_to_string(e))
            end
            # if ( e!=null ) {
            # e.printStackTrace(System.err);
            # }
          end
          
          typesig { [String] }
          define_method :warning do |s|
            System.err.println("ErrorManager init warning: " + s)
          end
          
          typesig { [String] }
          define_method :debug do |s|
          end
          
          typesig { [] }
          define_method :initialize do
            super()
          end
          
          private
          alias_method :initialize_anonymous, :initialize
        end.new_local(self)
      end
      alias_method :attr_init_stlistener, :init_stlistener
      
      def init_stlistener=(value)
        @@init_stlistener = value
      end
      alias_method :attr_init_stlistener=, :init_stlistener=
      
      
      def blank_stlistener
        defined?(@@blank_stlistener) ? @@blank_stlistener : @@blank_stlistener= # During verification of the messages group file, don't gen errors.
        # I'll handle them here.  This is used only after file has loaded ok
        # and only for the messages STG.
        Class.new(StringTemplateErrorListener.class == Class ? StringTemplateErrorListener : Object) do
          extend LocalClass
          include_class_members ErrorManager
          include StringTemplateErrorListener if StringTemplateErrorListener.class == Module
          
          typesig { [String, JavaThrowable] }
          define_method :error do |s, e|
          end
          
          typesig { [String] }
          define_method :warning do |s|
          end
          
          typesig { [String] }
          define_method :debug do |s|
          end
          
          typesig { [] }
          define_method :initialize do
            super()
          end
          
          private
          alias_method :initialize_anonymous, :initialize
        end.new_local(self)
      end
      alias_method :attr_blank_stlistener, :blank_stlistener
      
      def blank_stlistener=(value)
        @@blank_stlistener = value
      end
      alias_method :attr_blank_stlistener=, :blank_stlistener=
      
      
      def the_default_stlistener
        defined?(@@the_default_stlistener) ? @@the_default_stlistener : @@the_default_stlistener= # Errors during initialization related to ST must all go to System.err.
        Class.new(StringTemplateErrorListener.class == Class ? StringTemplateErrorListener : Object) do
          extend LocalClass
          include_class_members ErrorManager
          include StringTemplateErrorListener if StringTemplateErrorListener.class == Module
          
          typesig { [String, JavaThrowable] }
          define_method :error do |s, e|
            if (e.is_a?(self.class::InvocationTargetException))
              e = (e).get_target_exception
            end
            ErrorManager.error(ErrorManager::MSG_INTERNAL_ERROR, s, e)
          end
          
          typesig { [String] }
          define_method :warning do |s|
            ErrorManager.warning(ErrorManager::MSG_INTERNAL_WARNING, s)
          end
          
          typesig { [String] }
          define_method :debug do |s|
          end
          
          typesig { [] }
          define_method :initialize do
            super()
          end
          
          private
          alias_method :initialize_anonymous, :initialize
        end.new_local(self)
      end
      alias_method :attr_the_default_stlistener, :the_default_stlistener
      
      def the_default_stlistener=(value)
        @@the_default_stlistener = value
      end
      alias_method :attr_the_default_stlistener=, :the_default_stlistener=
      
      # make sure that this class is ready to use after loading
      when_class_loaded do
        init_id_to_message_name_mapping
        # it is inefficient to set the default locale here if another
        # piece of code is going to set the locale, but that would
        # require that a user call an init() function or something.  I prefer
        # that this class be ready to go when loaded as I'm absentminded ;)
        set_locale(Locale.get_default)
        # try to load the message format group
        # the user might have specified one on the command line
        # if not, or if the user has given an illegal value, we will fall back to "antlr"
        set_format("antlr")
      end
      
      typesig { [] }
      def get_string_template_error_listener
        return self.attr_the_default_stlistener
      end
      
      typesig { [Locale] }
      # We really only need a single locale for entire running ANTLR code
      # in a single VM.  Only pay attention to the language, not the country
      # so that French Canadians and French Frenchies all get the same
      # template file, fr.stg.  Just easier this way.
      def set_locale(locale)
        self.attr_locale.attr_locale = locale
        language = locale.get_language
        file_name = "org/antlr/tool/templates/messages/languages/" + language + ".stg"
        cl = JavaThread.current_thread.get_context_class_loader
        is = cl.get_resource_as_stream(file_name)
        if ((is).nil?)
          cl = ErrorManager.get_class_loader
          is = cl.get_resource_as_stream(file_name)
        end
        if ((is).nil? && (language == Locale::US.get_language))
          raw_error("ANTLR installation corrupted; cannot find English messages file " + file_name)
          panic
        else
          if ((is).nil?)
            # rawError("no such locale file "+fileName+" retrying with English locale");
            set_locale(Locale::US) # recurse on this rule, trying the US locale
            return
          end
        end
        br = nil
        begin
          br = BufferedReader.new(InputStreamReader.new(is))
          self.attr_messages = StringTemplateGroup.new(br, AngleBracketTemplateLexer, self.attr_init_stlistener)
          br.close
        rescue IOException => ioe
          raw_error("error reading message file " + file_name, ioe)
        ensure
          if (!(br).nil?)
            begin
              br.close
            rescue IOException => ioe
              raw_error("cannot close message file " + file_name, ioe)
            end
          end
        end
        self.attr_messages.set_error_listener(self.attr_blank_stlistener)
        messages_ok = verify_messages
        if (!messages_ok && (language == Locale::US.get_language))
          raw_error("ANTLR installation corrupted; English messages file " + language + ".stg incomplete")
          panic
        else
          if (!messages_ok)
            set_locale(Locale::US) # try US to see if that will work
          end
        end
      end
      
      typesig { [String] }
      # The format gets reset either from the Tool if the user supplied a command line option to that effect
      # Otherwise we just use the default "antlr".
      def set_format(format_name)
        self.attr_format_name.attr_format_name = format_name
        file_name = "org/antlr/tool/templates/messages/formats/" + format_name + ".stg"
        cl = JavaThread.current_thread.get_context_class_loader
        is = cl.get_resource_as_stream(file_name)
        if ((is).nil?)
          cl = ErrorManager.get_class_loader
          is = cl.get_resource_as_stream(file_name)
        end
        if ((is).nil? && (format_name == "antlr"))
          raw_error("ANTLR installation corrupted; cannot find ANTLR messages format file " + file_name)
          panic
        else
          if ((is).nil?)
            raw_error("no such message format file " + file_name + " retrying with default ANTLR format")
            set_format("antlr") # recurse on this rule, trying the default message format
            return
          end
        end
        br = nil
        begin
          br = BufferedReader.new(InputStreamReader.new(is))
          self.attr_format = StringTemplateGroup.new(br, AngleBracketTemplateLexer, self.attr_init_stlistener)
        ensure
          begin
            if (!(br).nil?)
              br.close
            end
          rescue IOException => ioe
            raw_error("cannot close message format file " + file_name, ioe)
          end
        end
        self.attr_format.set_error_listener(self.attr_blank_stlistener)
        format_ok = verify_format
        if (!format_ok && (format_name == "antlr"))
          raw_error("ANTLR installation corrupted; ANTLR messages format file " + format_name + ".stg incomplete")
          panic
        else
          if (!format_ok)
            set_format("antlr") # recurse on this rule, trying the default message format
          end
        end
      end
      
      typesig { [ANTLRErrorListener] }
      # Encodes the error handling found in setLocale, but does not trigger
      # panics, which would make GUI tools die if ANTLR's installation was
      # a bit screwy.  Duplicated code...ick.
      # public static Locale getLocaleForValidMessages(Locale locale) {
      # ErrorManager.locale = locale;
      # String language = locale.getLanguage();
      # String fileName = "org/antlr/tool/templates/messages/"+language+".stg";
      # ClassLoader cl = Thread.currentThread().getContextClassLoader();
      # InputStream is = cl.getResourceAsStream(fileName);
      # if ( is==null && language.equals(Locale.US.getLanguage()) ) {
      # return null;
      # }
      # else if ( is==null ) {
      # return getLocaleForValidMessages(Locale.US); // recurse on this rule, trying the US locale
      # }
      # 
      # boolean messagesOK = verifyMessages();
      # if ( !messagesOK && language.equals(Locale.US.getLanguage()) ) {
      # return null;
      # }
      # else if ( !messagesOK ) {
      # return getLocaleForValidMessages(Locale.US); // try US to see if that will work
      # }
      # return true;
      # }
      # 
      # In general, you'll want all errors to go to a single spot.
      # However, in a GUI, you might have two frames up with two
      # different grammars.  Two threads might launch to process the
      # grammars--you would want errors to go to different objects
      # depending on the thread.  I store a single listener per
      # thread.
      def set_error_listener(listener)
        self.attr_thread_to_listener_map.put(JavaThread.current_thread, listener)
      end
      
      typesig { [] }
      def remove_error_listener
        self.attr_thread_to_listener_map.remove(JavaThread.current_thread)
      end
      
      typesig { [Tool] }
      def set_tool(tool)
        self.attr_thread_to_tool_map.put(JavaThread.current_thread, tool)
      end
      
      typesig { [::Java::Int] }
      # Given a message ID, return a StringTemplate that somebody can fill
      # with data.  We need to convert the int ID to the name of a template
      # in the messages ST group.
      def get_message(msg_id)
        msg_name = self.attr_id_to_message_template_name[msg_id]
        return self.attr_messages.get_instance_of(msg_name)
      end
      
      typesig { [::Java::Int] }
      def get_message_type(msg_id)
        if (get_error_state.attr_warning_msg_ids.member(msg_id))
          return self.attr_messages.get_instance_of("warning").to_s
        else
          if (get_error_state.attr_error_msg_ids.member(msg_id))
            return self.attr_messages.get_instance_of("error").to_s
          end
        end
        assert_true(false, "Assertion failed! Message ID " + RJava.cast_to_string(msg_id) + " created but is not present in errorMsgIDs or warningMsgIDs.")
        return ""
      end
      
      typesig { [] }
      # Return a StringTemplate that refers to the current format used for
      # emitting messages.
      def get_location_format
        return self.attr_format.get_instance_of("location")
      end
      
      typesig { [] }
      def get_report_format
        return self.attr_format.get_instance_of("report")
      end
      
      typesig { [] }
      def get_message_format
        return self.attr_format.get_instance_of("message")
      end
      
      typesig { [] }
      def format_wants_single_line_message
        return (self.attr_format.get_instance_of("wantsSingleLineMessage").to_s == "true")
      end
      
      typesig { [] }
      def get_error_listener
        el = self.attr_thread_to_listener_map.get(JavaThread.current_thread)
        if ((el).nil?)
          return self.attr_the_default_error_listener
        end
        return el
      end
      
      typesig { [] }
      def get_error_state
        ec = self.attr_thread_to_error_state_map.get(JavaThread.current_thread)
        if ((ec).nil?)
          ec = ErrorState.new
          self.attr_thread_to_error_state_map.put(JavaThread.current_thread, ec)
        end
        return ec
      end
      
      typesig { [] }
      def get_num_errors
        return get_error_state.attr_errors
      end
      
      typesig { [] }
      def reset_error_state
        ec = ErrorState.new
        self.attr_thread_to_error_state_map.put(JavaThread.current_thread, ec)
      end
      
      typesig { [String] }
      def info(msg)
        get_error_state.attr_infos += 1
        get_error_listener.info(msg)
      end
      
      typesig { [::Java::Int] }
      def error(msg_id)
        get_error_state.attr_errors += 1
        get_error_state.attr_error_msg_ids.add(msg_id)
        get_error_listener.error(ToolMessage.new(msg_id))
      end
      
      typesig { [::Java::Int, JavaThrowable] }
      def error(msg_id, e)
        get_error_state.attr_errors += 1
        get_error_state.attr_error_msg_ids.add(msg_id)
        get_error_listener.error(ToolMessage.new(msg_id, e))
      end
      
      typesig { [::Java::Int, Object] }
      def error(msg_id, arg)
        get_error_state.attr_errors += 1
        get_error_state.attr_error_msg_ids.add(msg_id)
        get_error_listener.error(ToolMessage.new(msg_id, arg))
      end
      
      typesig { [::Java::Int, Object, Object] }
      def error(msg_id, arg, arg2)
        get_error_state.attr_errors += 1
        get_error_state.attr_error_msg_ids.add(msg_id)
        get_error_listener.error(ToolMessage.new(msg_id, arg, arg2))
      end
      
      typesig { [::Java::Int, Object, JavaThrowable] }
      def error(msg_id, arg, e)
        get_error_state.attr_errors += 1
        get_error_state.attr_error_msg_ids.add(msg_id)
        get_error_listener.error(ToolMessage.new(msg_id, arg, e))
      end
      
      typesig { [::Java::Int, Object] }
      def warning(msg_id, arg)
        get_error_state.attr_warnings += 1
        get_error_state.attr_warning_msg_ids.add(msg_id)
        get_error_listener.warning(ToolMessage.new(msg_id, arg))
      end
      
      typesig { [DecisionProbe, DFAState] }
      def nondeterminism(probe, d)
        get_error_state.attr_warnings += 1
        msg = GrammarNonDeterminismMessage.new(probe, d)
        get_error_state.attr_warning_msg_ids.add(msg.attr_msg_id)
        get_error_listener.warning(msg)
      end
      
      typesig { [DecisionProbe, DFAState] }
      def dangling_state(probe, d)
        get_error_state.attr_errors += 1
        msg = GrammarDanglingStateMessage.new(probe, d)
        get_error_state.attr_error_msg_ids.add(msg.attr_msg_id)
        seen = EmitSingleError.get("danglingState")
        if (!seen.contains(RJava.cast_to_string(d.attr_dfa.attr_decision_number) + "|" + RJava.cast_to_string(d.get_alt_set)))
          get_error_listener.error(msg)
          # we've seen this decision and this alt set; never again
          seen.add(RJava.cast_to_string(d.attr_dfa.attr_decision_number) + "|" + RJava.cast_to_string(d.get_alt_set))
        end
      end
      
      typesig { [DecisionProbe] }
      def analysis_aborted(probe)
        get_error_state.attr_warnings += 1
        msg = GrammarAnalysisAbortedMessage.new(probe)
        get_error_state.attr_warning_msg_ids.add(msg.attr_msg_id)
        get_error_listener.warning(msg)
      end
      
      typesig { [DecisionProbe, JavaList] }
      def unreachable_alts(probe, alts)
        get_error_state.attr_errors += 1
        msg = GrammarUnreachableAltsMessage.new(probe, alts)
        get_error_state.attr_error_msg_ids.add(msg.attr_msg_id)
        get_error_listener.error(msg)
      end
      
      typesig { [DecisionProbe, DFAState, Map] }
      def insufficient_predicates(probe, d, alt_to_uncovered_locations)
        get_error_state.attr_warnings += 1
        msg = GrammarInsufficientPredicatesMessage.new(probe, d, alt_to_uncovered_locations)
        get_error_state.attr_warning_msg_ids.add(msg.attr_msg_id)
        get_error_listener.warning(msg)
      end
      
      typesig { [DecisionProbe] }
      def non_llstar_decision(probe)
        get_error_state.attr_errors += 1
        msg = NonRegularDecisionMessage.new(probe, probe.get_non_deterministic_alts)
        get_error_state.attr_error_msg_ids.add(msg.attr_msg_id)
        get_error_listener.error(msg)
      end
      
      typesig { [DecisionProbe, DFAState, ::Java::Int, Collection, Collection] }
      def recursion_overflow(probe, sample_bad_state, alt, target_rules, call_site_states)
        get_error_state.attr_errors += 1
        msg = RecursionOverflowMessage.new(probe, sample_bad_state, alt, target_rules, call_site_states)
        get_error_state.attr_error_msg_ids.add(msg.attr_msg_id)
        get_error_listener.error(msg)
      end
      
      typesig { [Collection] }
      # // TODO: we can remove I think.  All detected now with cycles check.
      # public static void leftRecursion(DecisionProbe probe,
      # int alt,
      # Collection targetRules,
      # Collection callSiteStates)
      # {
      # getErrorState().warnings++;
      # Message msg = new LeftRecursionMessage(probe, alt, targetRules, callSiteStates);
      # getErrorState().warningMsgIDs.add(msg.msgID);
      # getErrorListener().warning(msg);
      # }
      def left_recursion_cycles(cycles)
        get_error_state.attr_errors += 1
        msg = LeftRecursionCyclesMessage.new(cycles)
        get_error_state.attr_error_msg_ids.add(msg.attr_msg_id)
        get_error_listener.warning(msg)
      end
      
      typesig { [::Java::Int, Grammar, Token, Object, Object] }
      def grammar_error(msg_id, g, token, arg, arg2)
        get_error_state.attr_errors += 1
        msg = GrammarSemanticsMessage.new(msg_id, g, token, arg, arg2)
        get_error_state.attr_error_msg_ids.add(msg_id)
        get_error_listener.error(msg)
      end
      
      typesig { [::Java::Int, Grammar, Token, Object] }
      def grammar_error(msg_id, g, token, arg)
        grammar_error(msg_id, g, token, arg, nil)
      end
      
      typesig { [::Java::Int, Grammar, Token] }
      def grammar_error(msg_id, g, token)
        grammar_error(msg_id, g, token, nil, nil)
      end
      
      typesig { [::Java::Int, Grammar, Token, Object, Object] }
      def grammar_warning(msg_id, g, token, arg, arg2)
        get_error_state.attr_warnings += 1
        msg = GrammarSemanticsMessage.new(msg_id, g, token, arg, arg2)
        get_error_state.attr_warning_msg_ids.add(msg_id)
        get_error_listener.warning(msg)
      end
      
      typesig { [::Java::Int, Grammar, Token, Object] }
      def grammar_warning(msg_id, g, token, arg)
        grammar_warning(msg_id, g, token, arg, nil)
      end
      
      typesig { [::Java::Int, Grammar, Token] }
      def grammar_warning(msg_id, g, token)
        grammar_warning(msg_id, g, token, nil, nil)
      end
      
      typesig { [::Java::Int, Grammar, Token, Object, Antlr::RecognitionException] }
      def syntax_error(msg_id, grammar, token, arg, re)
        get_error_state.attr_errors += 1
        get_error_state.attr_error_msg_ids.add(msg_id)
        get_error_listener.error(GrammarSyntaxMessage.new(msg_id, grammar, token, arg, re))
      end
      
      typesig { [Object, JavaThrowable] }
      def internal_error(error, e)
        location = get_last_non_error_manager_code_location(e)
        msg = "Exception " + RJava.cast_to_string(e) + "@" + RJava.cast_to_string(location) + ": " + RJava.cast_to_string(error)
        error(MSG_INTERNAL_ERROR, msg)
      end
      
      typesig { [Object] }
      def internal_error(error_)
        location = get_last_non_error_manager_code_location(JavaException.new)
        msg = RJava.cast_to_string(location) + ": " + RJava.cast_to_string(error_)
        error(MSG_INTERNAL_ERROR, msg)
      end
      
      typesig { [] }
      def do_not_attempt_analysis
        return !get_error_state.attr_error_msg_ids.and_(ERRORS_FORCING_NO_ANALYSIS).is_nil
      end
      
      typesig { [] }
      def do_not_attempt_code_gen
        return do_not_attempt_analysis || !get_error_state.attr_error_msg_ids.and_(ERRORS_FORCING_NO_CODEGEN).is_nil
      end
      
      typesig { [JavaThrowable] }
      # Return first non ErrorManager code location for generating messages
      def get_last_non_error_manager_code_location(e)
        stack = e.get_stack_trace
        i = 0
        while i < stack.attr_length
          t = stack[i]
          if (t.to_s.index_of("ErrorManager") < 0)
            break
          end
          i += 1
        end
        location = stack[i]
        return location
      end
      
      typesig { [::Java::Boolean, String] }
      # A S S E R T I O N  C O D E
      def assert_true(condition, message)
        if (!condition)
          internal_error(message)
        end
      end
      
      typesig { [] }
      # S U P P O R T  C O D E
      def init_id_to_message_name_mapping
        # make sure a message exists, even if it's just to indicate a problem
        i = 0
        while i < self.attr_id_to_message_template_name.attr_length
          self.attr_id_to_message_template_name[i] = "INVALID MESSAGE ID: " + RJava.cast_to_string(i)
          i += 1
        end
        # get list of fields and use it to fill in idToMessageTemplateName mapping
        fields = ErrorManager.get_fields
        i_ = 0
        while i_ < fields.attr_length
          f = fields[i_]
          field_name = f.get_name
          if (!field_name.starts_with("MSG_"))
            i_ += 1
            next
          end
          template_name = field_name.substring("MSG_".length, field_name.length)
          msg_id = 0
          begin
            # get the constant value from this class object
            msg_id = f.get_int(ErrorManager)
          rescue IllegalAccessException => iae
            System.err.println("cannot get const value for " + RJava.cast_to_string(f.get_name))
            i_ += 1
            next
          end
          if (field_name.starts_with("MSG_"))
            self.attr_id_to_message_template_name[msg_id] = template_name
          end
          i_ += 1
        end
        return true
      end
      
      typesig { [] }
      # Use reflection to find list of MSG_ fields and then verify a
      # template exists for each one from the locale's group.
      def verify_messages
        ok = true
        fields = ErrorManager.get_fields
        i = 0
        while i < fields.attr_length
          f = fields[i]
          field_name = f.get_name
          template_name = field_name.substring("MSG_".length, field_name.length)
          if (field_name.starts_with("MSG_"))
            if (!self.attr_messages.is_defined(template_name))
              System.err.println("Message " + template_name + " in locale " + RJava.cast_to_string(self.attr_locale) + " not found")
              ok = false
            end
          end
          i += 1
        end
        # check for special templates
        if (!self.attr_messages.is_defined("warning"))
          System.err.println("Message template 'warning' not found in locale " + RJava.cast_to_string(self.attr_locale))
          ok = false
        end
        if (!self.attr_messages.is_defined("error"))
          System.err.println("Message template 'error' not found in locale " + RJava.cast_to_string(self.attr_locale))
          ok = false
        end
        return ok
      end
      
      typesig { [] }
      # Verify the message format template group
      def verify_format
        ok = true
        if (!self.attr_format.is_defined("location"))
          System.err.println("Format template 'location' not found in " + self.attr_format_name)
          ok = false
        end
        if (!self.attr_format.is_defined("message"))
          System.err.println("Format template 'message' not found in " + self.attr_format_name)
          ok = false
        end
        if (!self.attr_format.is_defined("report"))
          System.err.println("Format template 'report' not found in " + self.attr_format_name)
          ok = false
        end
        return ok
      end
      
      typesig { [String] }
      # If there are errors during ErrorManager init, we have no choice
      # but to go to System.err.
      def raw_error(msg)
        System.err.println(msg)
      end
      
      typesig { [String, JavaThrowable] }
      def raw_error(msg, e)
        raw_error(msg)
        e.print_stack_trace(System.err)
      end
      
      typesig { [] }
      # I *think* this will allow Tool subclasses to exit gracefully
      # for GUIs etc...
      def panic
        tool = self.attr_thread_to_tool_map.get(JavaThread.current_thread)
        if ((tool).nil?)
          # no tool registered, exit
          raise JavaError.new("ANTLR ErrorManager panic")
        else
          tool.panic
        end
      end
    }
    
    typesig { [] }
    def initialize
    end
    
    private
    alias_method :initialize__error_manager, :initialize
  end
  
end
