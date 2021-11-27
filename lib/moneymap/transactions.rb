module Moneymap
  class Transactions
    include Enumerable

    def initialize(transactions = [])
      @transactions = transactions
    end

    ## Facade over Enumerable

    def each(&bl)
      @transactions.each(&bl)
    end

    def select(&bl)
      Transactions.new(@transactions.select(&bl))
    end

    def reject(&bl)
      Transactions.new(@transactions.reject(&bl))
    end

    def map(&bl)
      Transactions.new(@transactions.map(&bl))
    end

    def by_abs_amount_asc
      Transactions.new(@transactions.sort{|t1,t2|
        am = t1[:amount].abs <=> t2[:amount].abs
        if am == 0
          t1[:at] <=> t2[:at]
        else
          am
        end
      })
    end

    def limit(n)
      Transactions.new(@transactions[0...n])
    end

    def to_csv(*args)
      Bmg::Relation.new(@transactions.map(&:to_h)).to_csv(*args)
    end

  end # class Transactions
end # module Moneymap
