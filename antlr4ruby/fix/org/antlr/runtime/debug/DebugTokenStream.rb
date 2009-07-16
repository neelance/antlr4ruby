class Org::Antlr::Runtime::Debug::DebugTokenStream
  alias_method :antlr_consume_initial_hidden_tokens, :consume_initial_hidden_tokens
  def consume_initial_hidden_tokens
    backtracking = @dbg.attr_backtracking
    @dbg.attr_backtracking = 0
    antlr_consume_initial_hidden_tokens
    @dbg.attr_backtracking = backtracking
  end
end
