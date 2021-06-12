module Moneymap
  class Source
    include Enumerable

    AMOUNT_RX = /^-?[\d\.]+(,\d+)?$/

    def initialize(files)
      @files = files
    end
    attr_reader :files
    protected :files

    def each(&bl)
      recognized_transactions.each(&bl)
    end

    def all_transactions
      line2transaction = Proc.new{|t|
        converted = attributes.each_pair.each_with_object({}) do |(key,value), tuple|
          tuple[key] = case value
            when Integer then t[value]
            when Proc    then value.call(t)
          end
        end
        Transaction.new(converted)
      }
      files.inject([]) do |transactions, file|
        newtransactions = CSV
          .foreach(file.to_s, {col_sep: ';'})
          .map(&line2transaction)
          .to_a
        transactions + newtransactions
      end
    end

    def recognized_transactions
      all_transactions
        .select{|t| t[:amount] =~ AMOUNT_RX }
        .map{|t| t.merge(:amount => t[:amount].gsub(/\./,'').to_f) }
    end

    def unrecognized_transactions
      all_transactions
        .reject{|t| t[:amount] =~ AMOUNT_RX }
    end

  end # class Source
end # module Moneymap
require 'moneymap/source/belfius'
require 'moneymap/source/bnp'
require 'moneymap/source/auto'
