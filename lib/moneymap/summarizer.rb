module Moneymap
  class Summarizer

    ALL = 100_000

    def summarize(enum, mode, per)
        base = Bmg::Relation
            .new(enum.to_a.map(&:to_h))
            .extend(:pivot => ->(t){ t[:at].strftime('%Y') })
        summarized = case mode
        when :evolution
            evolution_per_xxx(base, per)
        when :balance
            balance_per_xxx(base, per)
        else
            raise ArgumentError, "Unrecognized #{mode}"
        end
        Transactions.new(summarized)
    end

    def balance_per_account_details(base)
        base
            .summarize([:category, :account], :amount => :sum)
            .group([:account, :amount], :details, array: true)
            .extend(:total => ->(t){
                t[:details].inject(0){|memo,t| memo+t[:amount] }
            })
            .page([:total], 1, :page_size => ALL)
            .to_a
    end

    def evolution_per_xxx(base, xxx)
        series = base.project([:pivot]).map{|t| t[:pivot] }.sort
        base
            .summarize([:pivot] + Array(xxx), :amount => :sum)
            .summarize(Array(xxx), :total => Bmg::Summarizer.value_by(:amount, {
                :by => :pivot,
                :series => series,
                :default => 0.0,
                :symbolize => false
            }))
            .unwrap(:total)
            .page(series.reverse[1..-1], 1, :page_size => ALL)
    end

    def balance_per_account(base)
        balance_per_xxx(base, :account)
    end

    def balance_per_category(base)
        balance_per_xxx(base, :category)
    end

    def balance_per_xxx(base, xxx)
        base
            .summarize(Array(xxx), :amount => :sum)
            .rename(:amount => :total)
            .page([:total], 1, :page_size => ALL)
            .to_a
    end

  end # class Summarizer
end # module Moneymap
