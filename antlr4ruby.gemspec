--- !ruby/object:Gem::Specification 
name: antlr4ruby
version: !ruby/object:Gem::Version 
  version: 1.0.2
platform: ruby
authors: []

autorequire: 
bindir: bin
cert_chain: []

date: 2009-07-17 00:00:00 +02:00
default_executable: 
dependencies: 
- !ruby/object:Gem::Dependency 
  name: java2ruby
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
- !ruby/object:Gem::Dependency 
  name: jre4ruby
  type: :runtime
  version_requirement: 
  version_requirements: !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        version: "0"
    version: 
description: 
email: 
executables: []

extensions: []

extra_rdoc_files: []

files: 
- antlr4ruby.rb
- LICENSE
- antlr4ruby/lib/org/antlr/tool/templates/dot/nfa.st
- antlr4ruby/lib/org/antlr/tool/templates/dot/dfa.st
- antlr4ruby/lib/org/antlr/tool/templates/dot/edge.st
- antlr4ruby/lib/org/antlr/tool/templates/dot/state.st
- antlr4ruby/lib/org/antlr/tool/templates/dot/epsilon-edge.st
- antlr4ruby/lib/org/antlr/tool/templates/dot/stopstate.st
- antlr4ruby/lib/org/antlr/tool/templates/dot/action-edge.st
- antlr4ruby/lib/org/antlr/tool/templates/dot/decision-rank.st
- antlr4ruby/lib/org/antlr/tool/templates/depend.stg
- antlr4ruby/lib/org/antlr/tool/templates/messages/formats/gnu.stg
- antlr4ruby/lib/org/antlr/tool/templates/messages/formats/vs2005.stg
- antlr4ruby/lib/org/antlr/tool/templates/messages/formats/antlr.stg
- antlr4ruby/lib/org/antlr/tool/templates/messages/languages/en.stg
- antlr4ruby/lib/org/antlr/tool/NonRegularDecisionMessage.rb
- antlr4ruby/lib/org/antlr/tool/AssignTokenTypesWalkerTokenTypes.txt
- antlr4ruby/lib/org/antlr/tool/NameSpaceChecker.rb
- antlr4ruby/lib/org/antlr/tool/AssignTokenTypesWalkerTokenTypes.rb
- antlr4ruby/lib/org/antlr/tool/GrammarReport.rb
- antlr4ruby/lib/org/antlr/tool/AssignTokenTypesBehavior.rb
- antlr4ruby/lib/org/antlr/tool/CompositeGrammar.rb
- antlr4ruby/lib/org/antlr/tool/AttributeScope.rb
- antlr4ruby/lib/org/antlr/tool/ANTLRv3.g
- antlr4ruby/lib/org/antlr/tool/RecursionOverflowMessage.rb
- antlr4ruby/lib/org/antlr/tool/TreeToNFAConverter.smap
- antlr4ruby/lib/org/antlr/tool/ANTLRLexer.rb
- antlr4ruby/lib/org/antlr/tool/assign.types.g
- antlr4ruby/lib/org/antlr/tool/ANTLRTokenTypes.txt
- antlr4ruby/lib/org/antlr/tool/buildnfa.g
- antlr4ruby/lib/org/antlr/tool/ANTLRTokenTypes.rb
- antlr4ruby/lib/org/antlr/tool/Interp.rb
- antlr4ruby/lib/org/antlr/tool/TreeToNFAConverterTokenTypes.txt
- antlr4ruby/lib/org/antlr/tool/Grammar.rb
- antlr4ruby/lib/org/antlr/tool/NFAFactory.rb
- antlr4ruby/lib/org/antlr/tool/GrammarAnalysisAbortedMessage.rb
- antlr4ruby/lib/org/antlr/tool/GrammarAST.rb
- antlr4ruby/lib/org/antlr/tool/DOTGenerator.rb
- antlr4ruby/lib/org/antlr/tool/GrammarSanity.rb
- antlr4ruby/lib/org/antlr/tool/GrammarNonDeterminismMessage.rb
- antlr4ruby/lib/org/antlr/tool/DefineGrammarItemsWalkerTokenTypes.txt
- antlr4ruby/lib/org/antlr/tool/antlr.g
- antlr4ruby/lib/org/antlr/tool/ANTLRTreePrinter.rb
- antlr4ruby/lib/org/antlr/tool/GrammarUnreachableAltsMessage.rb
- antlr4ruby/lib/org/antlr/tool/ANTLRParser.smap
- antlr4ruby/lib/org/antlr/tool/DefineGrammarItemsWalker.rb
- antlr4ruby/lib/org/antlr/tool/ActionAnalysisLexer.rb
- antlr4ruby/lib/org/antlr/tool/ANTLRParser.rb
- antlr4ruby/lib/org/antlr/tool/ANTLRTreePrinter.smap
- antlr4ruby/lib/org/antlr/tool/ANTLRErrorListener.rb
- antlr4ruby/lib/org/antlr/tool/Attribute.rb
- antlr4ruby/lib/org/antlr/tool/ANTLRLexer.smap
- antlr4ruby/lib/org/antlr/tool/ANTLRTreePrinterTokenTypes.txt
- antlr4ruby/lib/org/antlr/tool/ErrorManager.rb
- antlr4ruby/lib/org/antlr/tool/CompositeGrammarTree.rb
- antlr4ruby/lib/org/antlr/tool/ToolMessage.rb
- antlr4ruby/lib/org/antlr/tool/AssignTokenTypesWalker.smap
- antlr4ruby/lib/org/antlr/tool/ActionAnalysis.g
- antlr4ruby/lib/org/antlr/tool/antlr.print.g
- antlr4ruby/lib/org/antlr/tool/define.g
- antlr4ruby/lib/org/antlr/tool/AssignTokenTypesWalker.rb
- antlr4ruby/lib/org/antlr/tool/TreeToNFAConverter.rb
- antlr4ruby/lib/org/antlr/tool/FASerializer.rb
- antlr4ruby/lib/org/antlr/tool/DefineGrammarItemsWalker.smap
- antlr4ruby/lib/org/antlr/tool/DefineGrammarItemsWalkerTokenTypes.rb
- antlr4ruby/lib/org/antlr/tool/GrammarSemanticsMessage.rb
- antlr4ruby/lib/org/antlr/tool/ANTLRTreePrinterTokenTypes.rb
- antlr4ruby/lib/org/antlr/tool/GrammarSyntaxMessage.rb
- antlr4ruby/lib/org/antlr/tool/RuleLabelScope.rb
- antlr4ruby/lib/org/antlr/tool/RandomPhrase.rb
- antlr4ruby/lib/org/antlr/tool/GrammarInsufficientPredicatesMessage.rb
- antlr4ruby/lib/org/antlr/tool/Rule.rb
- antlr4ruby/lib/org/antlr/tool/BuildDependencyGenerator.rb
- antlr4ruby/lib/org/antlr/tool/LeftRecursionCyclesMessage.rb
- antlr4ruby/lib/org/antlr/tool/TreeToNFAConverterTokenTypes.rb
- antlr4ruby/lib/org/antlr/tool/Message.rb
- antlr4ruby/lib/org/antlr/tool/GrammarDanglingStateMessage.rb
- antlr4ruby/lib/org/antlr/tool/Interpreter.rb
- antlr4ruby/lib/org/antlr/Tool.rb
- antlr4ruby/lib/org/antlr/analysis/AnalysisTimeoutException.rb
- antlr4ruby/lib/org/antlr/analysis/LL1Analyzer.rb
- antlr4ruby/lib/org/antlr/analysis/NFAState.rb
- antlr4ruby/lib/org/antlr/analysis/LookaheadSet.rb
- antlr4ruby/lib/org/antlr/analysis/Label.rb
- antlr4ruby/lib/org/antlr/analysis/NonLLStarDecisionException.rb
- antlr4ruby/lib/org/antlr/analysis/DecisionProbe.rb
- antlr4ruby/lib/org/antlr/analysis/ActionLabel.rb
- antlr4ruby/lib/org/antlr/analysis/StateCluster.rb
- antlr4ruby/lib/org/antlr/analysis/Transition.rb
- antlr4ruby/lib/org/antlr/analysis/NFAConfiguration.rb
- antlr4ruby/lib/org/antlr/analysis/NFAContext.rb
- antlr4ruby/lib/org/antlr/analysis/PredicateLabel.rb
- antlr4ruby/lib/org/antlr/analysis/DFA.rb
- antlr4ruby/lib/org/antlr/analysis/NFA.rb
- antlr4ruby/lib/org/antlr/analysis/AnalysisRecursionOverflowException.rb
- antlr4ruby/lib/org/antlr/analysis/NFAToDFAConverter.rb
- antlr4ruby/lib/org/antlr/analysis/RuleClosureTransition.rb
- antlr4ruby/lib/org/antlr/analysis/NFAConversionThread.rb
- antlr4ruby/lib/org/antlr/analysis/State.rb
- antlr4ruby/lib/org/antlr/analysis/DFAOptimizer.rb
- antlr4ruby/lib/org/antlr/analysis/DFAState.rb
- antlr4ruby/lib/org/antlr/analysis/SemanticContext.rb
- antlr4ruby/lib/org/antlr/analysis/LL1DFA.rb
- antlr4ruby/lib/org/antlr/test/TestTreeWizard.rb
- antlr4ruby/lib/org/antlr/test/TestSets.rb
- antlr4ruby/lib/org/antlr/test/TestCharDFAConversion.rb
- antlr4ruby/lib/org/antlr/test/TestIntervalSet.rb
- antlr4ruby/lib/org/antlr/test/TestTreeParsing.rb
- antlr4ruby/lib/org/antlr/test/TestSymbolDefinitions.rb
- antlr4ruby/lib/org/antlr/test/TestJavaCodeGeneration.rb
- antlr4ruby/lib/org/antlr/test/TestRewriteTemplates.rb
- antlr4ruby/lib/org/antlr/test/TestTreeNodeStream.rb
- antlr4ruby/lib/org/antlr/test/TestInterpretedLexing.rb
- antlr4ruby/lib/org/antlr/test/TestSyntacticPredicateEvaluation.rb
- antlr4ruby/lib/org/antlr/test/TestCompositeGrammars.rb
- antlr4ruby/lib/org/antlr/test/TestLexer.rb
- antlr4ruby/lib/org/antlr/test/BaseTest.rb
- antlr4ruby/lib/org/antlr/test/ErrorQueue.rb
- antlr4ruby/lib/org/antlr/test/DebugTestCompositeGrammars.rb
- antlr4ruby/lib/org/antlr/test/TestASTConstruction.rb
- antlr4ruby/lib/org/antlr/test/TestDFAConversion.rb
- antlr4ruby/lib/org/antlr/test/TestNFAConstruction.rb
- antlr4ruby/lib/org/antlr/test/TestUnBufferedTreeNodeStream.rb
- antlr4ruby/lib/org/antlr/test/TestCommonTreeNodeStream.rb
- antlr4ruby/lib/org/antlr/test/TestAttributes.rb
- antlr4ruby/lib/org/antlr/test/TestDFAMatching.rb
- antlr4ruby/lib/org/antlr/test/TestTreeGrammarRewriteAST.rb
- antlr4ruby/lib/org/antlr/test/TestSemanticPredicateEvaluation.rb
- antlr4ruby/lib/org/antlr/test/TestTokenRewriteStream.rb
- antlr4ruby/lib/org/antlr/test/TestSemanticPredicates.rb
- antlr4ruby/lib/org/antlr/test/TestTrees.rb
- antlr4ruby/lib/org/antlr/test/TestTemplates.rb
- antlr4ruby/lib/org/antlr/test/TestAutoAST.rb
- antlr4ruby/lib/org/antlr/test/DebugTestAutoAST.rb
- antlr4ruby/lib/org/antlr/test/TestInterpretedParsing.rb
- antlr4ruby/lib/org/antlr/test/DebugTestRewriteAST.rb
- antlr4ruby/lib/org/antlr/test/TestRewriteAST.rb
- antlr4ruby/lib/org/antlr/test/TestMessages.rb
- antlr4ruby/lib/org/antlr/test/TestHeteroAST.rb
- antlr4ruby/lib/org/antlr/runtime/MismatchedSetException.rb
- antlr4ruby/lib/org/antlr/runtime/MismatchedTreeNodeException.rb
- antlr4ruby/lib/org/antlr/runtime/CharStreamState.rb
- antlr4ruby/lib/org/antlr/runtime/CommonTokenStream.rb
- antlr4ruby/lib/org/antlr/runtime/NoViableAltException.rb
- antlr4ruby/lib/org/antlr/runtime/CharStream.rb
- antlr4ruby/lib/org/antlr/runtime/MismatchedRangeException.rb
- antlr4ruby/lib/org/antlr/runtime/BitSet.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugEventHub.rb
- antlr4ruby/lib/org/antlr/runtime/debug/Tracer.rb
- antlr4ruby/lib/org/antlr/runtime/debug/RemoteDebugEventSocketListener.rb
- antlr4ruby/lib/org/antlr/runtime/debug/Profiler.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugTokenStream.rb
- antlr4ruby/lib/org/antlr/runtime/debug/ParseTreeBuilder.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugEventSocketProxy.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugTreeAdaptor.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugEventListener.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugEventRepeater.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugTreeNodeStream.rb
- antlr4ruby/lib/org/antlr/runtime/debug/TraceDebugEventListener.rb
- antlr4ruby/lib/org/antlr/runtime/debug/BlankDebugEventListener.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugParser.rb
- antlr4ruby/lib/org/antlr/runtime/debug/DebugTreeParser.rb
- antlr4ruby/lib/org/antlr/runtime/RuleReturnScope.rb
- antlr4ruby/lib/org/antlr/runtime/ANTLRStringStream.rb
- antlr4ruby/lib/org/antlr/runtime/TokenRewriteStream.rb
- antlr4ruby/lib/org/antlr/runtime/ANTLRFileStream.rb
- antlr4ruby/lib/org/antlr/runtime/EarlyExitException.rb
- antlr4ruby/lib/org/antlr/runtime/BaseRecognizer.rb
- antlr4ruby/lib/org/antlr/runtime/ANTLRInputStream.rb
- antlr4ruby/lib/org/antlr/runtime/CommonToken.rb
- antlr4ruby/lib/org/antlr/runtime/TokenStream.rb
- antlr4ruby/lib/org/antlr/runtime/IntStream.rb
- antlr4ruby/lib/org/antlr/runtime/MismatchedNotSetException.rb
- antlr4ruby/lib/org/antlr/runtime/DFA.rb
- antlr4ruby/lib/org/antlr/runtime/RecognizerSharedState.rb
- antlr4ruby/lib/org/antlr/runtime/MismatchedTokenException.rb
- antlr4ruby/lib/org/antlr/runtime/Token.rb
- antlr4ruby/lib/org/antlr/runtime/ClassicToken.rb
- antlr4ruby/lib/org/antlr/runtime/tree/TreePatternLexer.rb
- antlr4ruby/lib/org/antlr/runtime/tree/RewriteRuleNodeStream.rb
- antlr4ruby/lib/org/antlr/runtime/tree/TreeNodeStream.rb
- antlr4ruby/lib/org/antlr/runtime/tree/RewriteRuleSubtreeStream.rb
- antlr4ruby/lib/org/antlr/runtime/tree/CommonTreeNodeStream.rb
- antlr4ruby/lib/org/antlr/runtime/tree/BaseTree.rb
- antlr4ruby/lib/org/antlr/runtime/tree/TreeRuleReturnScope.rb
- antlr4ruby/lib/org/antlr/runtime/tree/RewriteRuleElementStream.rb
- antlr4ruby/lib/org/antlr/runtime/tree/TreeParser.rb
- antlr4ruby/lib/org/antlr/runtime/tree/RewriteEarlyExitException.rb
- antlr4ruby/lib/org/antlr/runtime/tree/TreePatternParser.rb
- antlr4ruby/lib/org/antlr/runtime/tree/Tree.rb
- antlr4ruby/lib/org/antlr/runtime/tree/RewriteCardinalityException.rb
- antlr4ruby/lib/org/antlr/runtime/tree/DOTTreeGenerator.rb
- antlr4ruby/lib/org/antlr/runtime/tree/TreeAdaptor.rb
- antlr4ruby/lib/org/antlr/runtime/tree/UnBufferedTreeNodeStream.rb
- antlr4ruby/lib/org/antlr/runtime/tree/RewriteRuleTokenStream.rb
- antlr4ruby/lib/org/antlr/runtime/tree/TreeWizard.rb
- antlr4ruby/lib/org/antlr/runtime/tree/CommonErrorNode.rb
- antlr4ruby/lib/org/antlr/runtime/tree/CommonTree.rb
- antlr4ruby/lib/org/antlr/runtime/tree/BaseTreeAdaptor.rb
- antlr4ruby/lib/org/antlr/runtime/tree/ParseTree.rb
- antlr4ruby/lib/org/antlr/runtime/tree/CommonTreeAdaptor.rb
- antlr4ruby/lib/org/antlr/runtime/tree/RewriteEmptyStreamException.rb
- antlr4ruby/lib/org/antlr/runtime/RecognitionException.rb
- antlr4ruby/lib/org/antlr/runtime/misc/IntArray.rb
- antlr4ruby/lib/org/antlr/runtime/misc/Stats.rb
- antlr4ruby/lib/org/antlr/runtime/Lexer.rb
- antlr4ruby/lib/org/antlr/runtime/FailedPredicateException.rb
- antlr4ruby/lib/org/antlr/runtime/UnwantedTokenException.rb
- antlr4ruby/lib/org/antlr/runtime/MissingTokenException.rb
- antlr4ruby/lib/org/antlr/runtime/ANTLRReaderStream.rb
- antlr4ruby/lib/org/antlr/runtime/ParserRuleReturnScope.rb
- antlr4ruby/lib/org/antlr/runtime/Parser.rb
- antlr4ruby/lib/org/antlr/runtime/TokenSource.rb
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp2/ASTDbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp2/ASTTreeParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp2/Dbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp2/CSharp2.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp2/ASTParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp2/AST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp2/ST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Ruby/Ruby.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ObjC/ASTDbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ObjC/ObjC.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ObjC/ASTTreeParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ObjC/Dbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ObjC/ASTParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ObjC/AST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp/CSharp.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp/ASTDbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp/ASTTreeParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp/Dbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp/ASTParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp/AST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CSharp/ST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Java/Java.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Java/ASTDbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Java/ASTTreeParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Java/Dbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Java/ASTParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Java/AST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Java/ST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/C/ASTDbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/C/C.stg
- antlr4ruby/lib/org/antlr/codegen/templates/C/ASTTreeParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/C/Dbg.stg
- antlr4ruby/lib/org/antlr/codegen/templates/C/ASTParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/C/AST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ActionScript/ActionScript.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ActionScript/ASTTreeParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ActionScript/ASTParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ActionScript/AST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/JavaScript/ASTTreeParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/JavaScript/ASTParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/JavaScript/AST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/JavaScript/JavaScript.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Perl5/Perl5.stg
- antlr4ruby/lib/org/antlr/codegen/templates/ANTLRCore.sti
- antlr4ruby/lib/org/antlr/codegen/templates/Python/ASTTreeParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Python/ASTParser.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Python/AST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Python/Python.stg
- antlr4ruby/lib/org/antlr/codegen/templates/Python/ST.stg
- antlr4ruby/lib/org/antlr/codegen/templates/CPP/CPP.stg
- antlr4ruby/lib/org/antlr/codegen/codegen.g
- antlr4ruby/lib/org/antlr/codegen/CTarget.rb
- antlr4ruby/lib/org/antlr/codegen/CodeGenTreeWalker.smap
- antlr4ruby/lib/org/antlr/codegen/JavaScriptTarget.rb
- antlr4ruby/lib/org/antlr/codegen/CSharp2Target.rb
- antlr4ruby/lib/org/antlr/codegen/ActionScriptTarget.rb
- antlr4ruby/lib/org/antlr/codegen/ANTLRTokenTypes.txt
- antlr4ruby/lib/org/antlr/codegen/CodeGenerator.rb
- antlr4ruby/lib/org/antlr/codegen/PythonTarget.rb
- antlr4ruby/lib/org/antlr/codegen/Perl5Target.rb
- antlr4ruby/lib/org/antlr/codegen/CodeGenTreeWalkerTokenTypes.rb
- antlr4ruby/lib/org/antlr/codegen/JavaTarget.rb
- antlr4ruby/lib/org/antlr/codegen/ObjCTarget.rb
- antlr4ruby/lib/org/antlr/codegen/CPPTarget.rb
- antlr4ruby/lib/org/antlr/codegen/CodeGenTreeWalkerTokenTypes.txt
- antlr4ruby/lib/org/antlr/codegen/Target.rb
- antlr4ruby/lib/org/antlr/codegen/CodeGenTreeWalker.rb
- antlr4ruby/lib/org/antlr/codegen/CSharpTarget.rb
- antlr4ruby/lib/org/antlr/codegen/ACyclicDFACodeGenerator.rb
- antlr4ruby/lib/org/antlr/codegen/ActionTranslator.g
- antlr4ruby/lib/org/antlr/codegen/RubyTarget.rb
- antlr4ruby/lib/org/antlr/codegen/ActionTranslator.rb
- antlr4ruby/lib/org/antlr/misc/OrderedHashSet.rb
- antlr4ruby/lib/org/antlr/misc/BitSet.rb
- antlr4ruby/lib/org/antlr/misc/MultiMap.rb
- antlr4ruby/lib/org/antlr/misc/MutableInteger.rb
- antlr4ruby/lib/org/antlr/misc/Utils.rb
- antlr4ruby/lib/org/antlr/misc/Barrier.rb
- antlr4ruby/lib/org/antlr/misc/IntervalSet.rb
- antlr4ruby/lib/org/antlr/misc/IntArrayList.rb
- antlr4ruby/lib/org/antlr/misc/Interval.rb
- antlr4ruby/lib/org/antlr/misc/IntSet.rb
- antlr4ruby/fix/org/antlr/runtime/debug/DebugTokenStream.rb
- antlr4ruby/fix/org/antlr/runtime/DFA.rb
has_rdoc: true
homepage: http://github.com/neelance/antlr4ruby/
post_install_message: 
rdoc_options: 
- --charset=UTF-8
require_paths: 
- .
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      version: "0"
  version: 
requirements: []

rubyforge_project: 
rubygems_version: 1.3.1
signing_key: 
specification_version: 2
summary: Converted ANTLR.
test_files: []

