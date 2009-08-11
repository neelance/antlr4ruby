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
module Org::Antlr::Analysis
  module SemanticContextImports
    class_module.module_eval {
      include ::Java::Lang
      include ::Org::Antlr::Analysis
      include_const ::Org::Antlr::Stringtemplate, :StringTemplate
      include_const ::Org::Antlr::Stringtemplate, :StringTemplateGroup
      include_const ::Org::Antlr::Codegen, :CodeGenerator
      include_const ::Org::Antlr::Tool, :ANTLRParser
      include_const ::Org::Antlr::Tool, :GrammarAST
      include_const ::Org::Antlr::Tool, :Grammar
      include_const ::Java::Util, :JavaSet
      include_const ::Java::Util, :HashSet
      include_const ::Java::Util, :Iterator
    }
  end
  
  # A binary tree structure used to record the semantic context in which
  # an NFA configuration is valid.  It's either a single predicate or
  # a tree representing an operation tree such as: p1&&p2 or p1||p2.
  # 
  # For NFA o-p1->o-p2->o, create tree AND(p1,p2).
  # For NFA (1)-p1->(2)
  # |       ^
  # |       |
  # (3)-p2----
  # we will have to combine p1 and p2 into DFA state as we will be
  # adding NFA configurations for state 2 with two predicates p1,p2.
  # So, set context for combined NFA config for state 2: OR(p1,p2).
  # 
  # I have scoped the AND, NOT, OR, and Predicate subclasses of
  # SemanticContext within the scope of this outer class.
  # 
  # July 7, 2006: TJP altered OR to be set of operands. the Binary tree
  # made it really hard to reduce complicated || sequences to their minimum.
  # Got huge repeated || conditions.
  class SemanticContext 
    include_class_members SemanticContextImports
    
    class_module.module_eval {
      # Create a default value for the semantic context shared among all
      # NFAConfigurations that do not have an actual semantic context.
      # This prevents lots of if!=null type checks all over; it represents
      # just an empty set of predicates.
      const_set_lazy(:EMPTY_SEMANTIC_CONTEXT) { Predicate.new }
      const_attr_reader  :EMPTY_SEMANTIC_CONTEXT
    }
    
    typesig { [] }
    # Given a semantic context expression tree, return a tree with all
    # nongated predicates set to true and then reduced.  So p&&(q||r) would
    # return p&&r if q is nongated but p and r are gated.
    def get_gated_predicate_context
      raise NotImplementedError
    end
    
    typesig { [CodeGenerator, StringTemplateGroup, DFA] }
    # Generate an expression that will evaluate the semantic context,
    # given a set of output templates.
    def gen_expr(generator, templates, dfa)
      raise NotImplementedError
    end
    
    typesig { [] }
    def is_syntactic_predicate
      raise NotImplementedError
    end
    
    typesig { [Grammar] }
    # Notify the indicated grammar of any syn preds used within this context
    def track_use_of_syntactic_predicates(g)
    end
    
    class_module.module_eval {
      const_set_lazy(:Predicate) { Class.new(SemanticContext) do
        include_class_members SemanticContext
        
        # The AST node in tree created from the grammar holding the predicate
        attr_accessor :predicate_ast
        alias_method :attr_predicate_ast, :predicate_ast
        undef_method :predicate_ast
        alias_method :attr_predicate_ast=, :predicate_ast=
        undef_method :predicate_ast=
        
        # Is this a {...}?=> gating predicate or a normal disambiguating {..}?
        # If any predicate in expression is gated, then expression is considered
        # gated.
        # 
        # The simple Predicate object's predicate AST's type is used to set
        # gated to true if type==GATED_SEMPRED.
        attr_accessor :gated
        alias_method :attr_gated, :gated
        undef_method :gated
        alias_method :attr_gated=, :gated=
        undef_method :gated=
        
        # syntactic predicates are converted to semantic predicates
        # but synpreds are generated slightly differently.
        attr_accessor :synpred
        alias_method :attr_synpred, :synpred
        undef_method :synpred
        alias_method :attr_synpred=, :synpred=
        undef_method :synpred=
        
        class_module.module_eval {
          const_set_lazy(:INVALID_PRED_VALUE) { -1 }
          const_attr_reader  :INVALID_PRED_VALUE
          
          const_set_lazy(:FALSE_PRED) { 0 }
          const_attr_reader  :FALSE_PRED
          
          const_set_lazy(:TRUE_PRED) { 1 }
          const_attr_reader  :TRUE_PRED
        }
        
        # sometimes predicates are known to be true or false; we need
        # a way to represent this without resorting to a target language
        # value like true or TRUE.
        attr_accessor :constant_value
        alias_method :attr_constant_value, :constant_value
        undef_method :constant_value
        alias_method :attr_constant_value=, :constant_value=
        undef_method :constant_value=
        
        typesig { [] }
        def initialize
          @predicate_ast = nil
          @gated = false
          @synpred = false
          @constant_value = 0
          super()
          @gated = false
          @synpred = false
          @constant_value = self.class::INVALID_PRED_VALUE
          @predicate_ast = GrammarAST.new
          @gated = false
        end
        
        typesig { [GrammarAST] }
        def initialize(predicate)
          @predicate_ast = nil
          @gated = false
          @synpred = false
          @constant_value = 0
          super()
          @gated = false
          @synpred = false
          @constant_value = self.class::INVALID_PRED_VALUE
          @predicate_ast = predicate
          @gated = (predicate.get_type).equal?(ANTLRParser::GATED_SEMPRED) || (predicate.get_type).equal?(ANTLRParser::SYN_SEMPRED)
          @synpred = (predicate.get_type).equal?(ANTLRParser::SYN_SEMPRED) || (predicate.get_type).equal?(ANTLRParser::BACKTRACK_SEMPRED)
        end
        
        typesig { [Predicate] }
        def initialize(p)
          @predicate_ast = nil
          @gated = false
          @synpred = false
          @constant_value = 0
          super()
          @gated = false
          @synpred = false
          @constant_value = self.class::INVALID_PRED_VALUE
          @predicate_ast = p.attr_predicate_ast
          @gated = p.attr_gated
          @synpred = p.attr_synpred
          @constant_value = p.attr_constant_value
        end
        
        typesig { [Object] }
        # Two predicates are the same if they are literally the same
        # text rather than same node in the grammar's AST.
        # Or, if they have the same constant value, return equal.
        # As of July 2006 I'm not sure these are needed.
        def equals(o)
          if (!(o.is_a?(Predicate)))
            return false
          end
          return (@predicate_ast.get_text == (o).attr_predicate_ast.get_text)
        end
        
        typesig { [] }
        def hash_code
          if ((@predicate_ast).nil?)
            return 0
          end
          return @predicate_ast.get_text.hash_code
        end
        
        typesig { [CodeGenerator, StringTemplateGroup, DFA] }
        def gen_expr(generator, templates, dfa)
          e_st = nil
          if (!(templates).nil?)
            if (@synpred)
              e_st = templates.get_instance_of("evalSynPredicate")
            else
              e_st = templates.get_instance_of("evalPredicate")
              generator.attr_grammar.attr_decisions_whose_dfas_uses_sem_preds.add(dfa)
            end
            pred_enclosing_rule_name = @predicate_ast.attr_enclosing_rule_name
            # String decisionEnclosingRuleName =
            # dfa.getNFADecisionStartState().getEnclosingRule();
            # // if these rulenames are diff, then pred was hoisted out of rule
            # // Currently I don't warn you about this as it could be annoying.
            # // I do the translation anyway.
            # 
            # eST.setAttribute("pred", this.toString());
            if (!(generator).nil?)
              e_st.set_attribute("pred", generator.translate_action(pred_enclosing_rule_name, @predicate_ast))
            end
          else
            e_st = StringTemplate.new("$pred$")
            e_st.set_attribute("pred", self.to_s)
            return e_st
          end
          if (!(generator).nil?)
            description = generator.attr_target.get_target_string_literal_from_string(self.to_s)
            e_st.set_attribute("description", description)
          end
          return e_st
        end
        
        typesig { [] }
        def get_gated_predicate_context
          if (@gated)
            return self
          end
          return nil
        end
        
        typesig { [] }
        def is_syntactic_predicate
          return !(@predicate_ast).nil? && ((@predicate_ast.get_type).equal?(ANTLRParser::SYN_SEMPRED) || (@predicate_ast.get_type).equal?(ANTLRParser::BACKTRACK_SEMPRED))
        end
        
        typesig { [Grammar] }
        def track_use_of_syntactic_predicates(g)
          if (@synpred)
            g.attr_syn_pred_names_used_in_dfa.add(@predicate_ast.get_text)
          end
        end
        
        typesig { [] }
        def to_s
          if ((@predicate_ast).nil?)
            return "<nopred>"
          end
          return @predicate_ast.get_text
        end
        
        private
        alias_method :initialize__predicate, :initialize
      end }
      
      const_set_lazy(:TruePredicate) { Class.new(Predicate) do
        include_class_members SemanticContext
        
        typesig { [] }
        def initialize
          super()
          self.attr_constant_value = TRUE_PRED
        end
        
        typesig { [CodeGenerator, StringTemplateGroup, DFA] }
        def gen_expr(generator, templates, dfa)
          if (!(templates).nil?)
            return templates.get_instance_of("true")
          end
          return StringTemplate.new("true")
        end
        
        typesig { [] }
        def to_s
          return "true" # not used for code gen, just DOT and print outs
        end
        
        private
        alias_method :initialize__true_predicate, :initialize
      end }
      
      # public static class FalsePredicate extends Predicate {
      # public FalsePredicate() {
      # super();
      # this.constantValue = FALSE_PRED;
      # }
      # public StringTemplate genExpr(CodeGenerator generator,
      # StringTemplateGroup templates,
      # DFA dfa)
      # {
      # if ( templates!=null ) {
      # return templates.getInstanceOf("false");
      # }
      # return new StringTemplate("false");
      # }
      # public String toString() {
      # return "false"; // not used for code gen, just DOT and print outs
      # }
      # }
      const_set_lazy(:AND) { Class.new(SemanticContext) do
        include_class_members SemanticContext
        
        attr_accessor :left
        alias_method :attr_left, :left
        undef_method :left
        alias_method :attr_left=, :left=
        undef_method :left=
        
        attr_accessor :right
        alias_method :attr_right, :right
        undef_method :right
        alias_method :attr_right=, :right=
        undef_method :right=
        
        typesig { [SemanticContext, SemanticContext] }
        def initialize(a, b)
          @left = nil
          @right = nil
          super()
          @left = a
          @right = b
        end
        
        typesig { [CodeGenerator, StringTemplateGroup, DFA] }
        def gen_expr(generator, templates, dfa)
          e_st = nil
          if (!(templates).nil?)
            e_st = templates.get_instance_of("andPredicates")
          else
            e_st = StringTemplate.new("($left$&&$right$)")
          end
          e_st.set_attribute("left", @left.gen_expr(generator, templates, dfa))
          e_st.set_attribute("right", @right.gen_expr(generator, templates, dfa))
          return e_st
        end
        
        typesig { [] }
        def get_gated_predicate_context
          gated_left = @left.get_gated_predicate_context
          gated_right = @right.get_gated_predicate_context
          if ((gated_left).nil?)
            return gated_right
          end
          if ((gated_right).nil?)
            return gated_left
          end
          return AND.new(gated_left, gated_right)
        end
        
        typesig { [] }
        def is_syntactic_predicate
          return @left.is_syntactic_predicate || @right.is_syntactic_predicate
        end
        
        typesig { [Grammar] }
        def track_use_of_syntactic_predicates(g)
          @left.track_use_of_syntactic_predicates(g)
          @right.track_use_of_syntactic_predicates(g)
        end
        
        typesig { [] }
        def to_s
          return "(" + (@left).to_s + "&&" + (@right).to_s + ")"
        end
        
        private
        alias_method :initialize__and, :initialize
      end }
      
      const_set_lazy(:OR) { Class.new(SemanticContext) do
        include_class_members SemanticContext
        
        attr_accessor :operands
        alias_method :attr_operands, :operands
        undef_method :operands
        alias_method :attr_operands=, :operands=
        undef_method :operands=
        
        typesig { [SemanticContext, SemanticContext] }
        def initialize(a, b)
          @operands = nil
          super()
          @operands = HashSet.new
          if (a.is_a?(OR))
            @operands.add_all((a).attr_operands)
          else
            if (!(a).nil?)
              @operands.add(a)
            end
          end
          if (b.is_a?(OR))
            @operands.add_all((b).attr_operands)
          else
            if (!(b).nil?)
              @operands.add(b)
            end
          end
        end
        
        typesig { [CodeGenerator, StringTemplateGroup, DFA] }
        def gen_expr(generator, templates, dfa)
          e_st = nil
          if (!(templates).nil?)
            e_st = templates.get_instance_of("orPredicates")
          else
            e_st = StringTemplate.new("($first(operands)$$rest(operands):{o | ||$o$}$)")
          end
          it = @operands.iterator
          while it.has_next
            semctx = it.next
            e_st.set_attribute("operands", semctx.gen_expr(generator, templates, dfa))
          end
          return e_st
        end
        
        typesig { [] }
        def get_gated_predicate_context
          result = nil
          it = @operands.iterator
          while it.has_next
            semctx = it.next
            gated_pred = semctx.get_gated_predicate_context
            if (!(gated_pred).nil?)
              result = or(result, gated_pred)
              # result = new OR(result, gatedPred);
            end
          end
          return result
        end
        
        typesig { [] }
        def is_syntactic_predicate
          it = @operands.iterator
          while it.has_next
            semctx = it.next
            if (semctx.is_syntactic_predicate)
              return true
            end
          end
          return false
        end
        
        typesig { [Grammar] }
        def track_use_of_syntactic_predicates(g)
          it = @operands.iterator
          while it.has_next
            semctx = it.next
            semctx.track_use_of_syntactic_predicates(g)
          end
        end
        
        typesig { [] }
        def to_s
          buf = StringBuffer.new
          buf.append("(")
          i = 0
          it = @operands.iterator
          while it.has_next
            semctx = it.next
            if (i > 0)
              buf.append("||")
            end
            buf.append(semctx.to_s)
            i += 1
          end
          buf.append(")")
          return buf.to_s
        end
        
        private
        alias_method :initialize__or, :initialize
      end }
      
      const_set_lazy(:NOT) { Class.new(SemanticContext) do
        include_class_members SemanticContext
        
        attr_accessor :ctx
        alias_method :attr_ctx, :ctx
        undef_method :ctx
        alias_method :attr_ctx=, :ctx=
        undef_method :ctx=
        
        typesig { [SemanticContext] }
        def initialize(ctx)
          @ctx = nil
          super()
          @ctx = ctx
        end
        
        typesig { [CodeGenerator, StringTemplateGroup, DFA] }
        def gen_expr(generator, templates, dfa)
          e_st = nil
          if (!(templates).nil?)
            e_st = templates.get_instance_of("notPredicate")
          else
            e_st = StringTemplate.new("?!($pred$)")
          end
          e_st.set_attribute("pred", @ctx.gen_expr(generator, templates, dfa))
          return e_st
        end
        
        typesig { [] }
        def get_gated_predicate_context
          p = @ctx.get_gated_predicate_context
          if ((p).nil?)
            return nil
          end
          return NOT.new(p)
        end
        
        typesig { [] }
        def is_syntactic_predicate
          return @ctx.is_syntactic_predicate
        end
        
        typesig { [Grammar] }
        def track_use_of_syntactic_predicates(g)
          @ctx.track_use_of_syntactic_predicates(g)
        end
        
        typesig { [Object] }
        def equals(object)
          if (!(object.is_a?(NOT)))
            return false
          end
          return (@ctx == (object).attr_ctx)
        end
        
        typesig { [] }
        def to_s
          return "!(" + (@ctx).to_s + ")"
        end
        
        private
        alias_method :initialize__not, :initialize
      end }
      
      typesig { [SemanticContext, SemanticContext] }
      def and(a, b)
        # System.out.println("AND: "+a+"&&"+b);
        if ((a).equal?(EMPTY_SEMANTIC_CONTEXT) || (a).nil?)
          return b
        end
        if ((b).equal?(EMPTY_SEMANTIC_CONTEXT) || (b).nil?)
          return a
        end
        if ((a == b))
          return a # if same, just return left one
        end
        # System.out.println("## have to AND");
        return AND.new(a, b)
      end
      
      typesig { [SemanticContext, SemanticContext] }
      def or(a, b)
        # System.out.println("OR: "+a+"||"+b);
        if ((a).equal?(EMPTY_SEMANTIC_CONTEXT) || (a).nil?)
          return b
        end
        if ((b).equal?(EMPTY_SEMANTIC_CONTEXT) || (b).nil?)
          return a
        end
        if (a.is_a?(TruePredicate))
          return a
        end
        if (b.is_a?(TruePredicate))
          return b
        end
        if (a.is_a?(NOT) && b.is_a?(Predicate))
          n = a
          # check for !p||p
          if ((n.attr_ctx == b))
            return TruePredicate.new
          end
        else
          if (b.is_a?(NOT) && a.is_a?(Predicate))
            n = b
            # check for p||!p
            if ((n.attr_ctx == a))
              return TruePredicate.new
            end
          else
            if ((a == b))
              return a
            end
          end
        end
        # System.out.println("## have to OR");
        return OR.new(a, b)
      end
      
      typesig { [SemanticContext] }
      def not(a)
        return NOT.new(a)
      end
    }
    
    typesig { [] }
    def initialize
    end
    
    private
    alias_method :initialize__semantic_context, :initialize
  end
  
end
