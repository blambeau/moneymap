module Moneymap
  module D3
    class Sunburst

      SUM = {
        :size => Alf::Aggregator.sum(:size)
      }

      def graphit(all_data)
        outcomes = all_data
          .rename(:amount => :size)
          .restrict(->(t){ t[:size] <= 0 })
          .extend(size: ->(t){ t[:size].abs })
          .summarize([:category, :subcategory], SUM)
          .extend(:account => "All")

        children = accounts(outcomes)
        if children.size == 1
          children.first
        else
          {
            name: "All",
            children: children
          }
        end
      end

      def accounts(outcomes)
        outcomes
          .summarize([:account], SUM)
          .extend(:children => ->(t){
            account_outcomes(outcomes, t[:account])
          })
          .rename(:account => :name)
          .to_a
      end

      def account_outcomes(outcomes, account)
        account_outcomes = outcomes
          .restrict(account: account)
        account_outcomes
          .summarize([:category], SUM)
          .extend(:children => ->(t){
            category_outcomes(account_outcomes, t[:category])
          })
          .rename(:category => :name)
          .to_a
      end

      def category_outcomes(account_outcomes, category)
        category_outcomes = account_outcomes
          .restrict(category: category)
          .restrict(->(t){ !t[:subcategory].nil? })
          .summarize([:subcategory], SUM)
          .rename(:subcategory => :name)
          .to_a
      end

    end # class Sunburst
  end # module D3
end # module Moneymap
