module Moneymap
  class Transactions

    def initialize(transactions = [])
      @transactions = transactions
    end

    ## Facade over Enumerable

    def select(&bl)
      Transactions.new(@transactions.select(&bl))
    end

    def reject(&bl)
      Transactions.new(@transactions.reject(&bl))
    end

    def map(&bl)
      Transactions.new(@transactions.map(&bl))
    end

  end # class Transactions
end # module Moneymap
