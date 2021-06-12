module Moneymap
  class Summarizer

    def summarize(enum)
      by = Alf::Types::AttrList.coerce([:account, :category])
      summarization = Alf::Types::Summarization.coerce(:total => Alf::Aggregator.sum(:amount))
      ordering = Alf::Types::Ordering.coerce([:total])
      grouping = Alf::Types::AttrList.coerce([:account])

      operand = enum.map{|t| t.to_h}
      operand = Alf::Engine::Summarize::Hash.new operand, by, summarization, false
      operand = Alf::Engine::Sort::InMemory.new operand, ordering
      operand = Alf::Engine::Group::Hash.new operand, grouping, :details, true
      operand.map{|t|
        t.merge(:details => Alf::Engine::Sort::InMemory.new(t[:details], ordering).to_a)
      }
      operand.to_a
    end

  end # class Summarizer
end # module Moneymap
