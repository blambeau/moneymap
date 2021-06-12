module Moneymap
  class Transaction < OpenStruct

    SCHEMA = <<-FIO
      {
        account    : String       # Account on which the transaction occurs
        id         : String       # Unique identifier of the transaction for the account
        at         : String       # Date at which the transaction occurs
        to_account : String|Nil   # Other account involved in the transaction, if any
        to_name    : String|Nil   # Name of the other party involved in the transaction
        amount     : Float        # Transaction amount, positive (debit) or negative (credit)
        details    : String       # Transaction details (aka comments)
      }
    FIO

    ### Query

    def debit?
      self.amount >= 0
    end

    def credit?
      self.amount < 0
    end

    def matches?(rx)
      self.to_name =~ rx or self.to_account =~ rx or self.details =~ rx
    end

    ### Command (functional)

    def merge(h)
      Transaction.new self.to_h.merge(h)
    end    

    def divide_by(x)
      merge(amount: self.amount.to_i / x.to_i)
    end

  end # class Transaction
end # module Moneymap
