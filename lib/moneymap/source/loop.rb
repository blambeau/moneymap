module Moneymap
  class Source
    class Loop < Source

      def attributes
        {
          id: ->(t){ t[0].to_s },
          at: ->(t){ Date.parse(t[1]) rescue t[1] },
          account: ->(t){ t[2] },
          to_account: ->(t){ t[3] },
          to_name: ->(t){ t[4] },
          details: ->(t){ t[5] },
          amount: ->(t){ t[6] },
          category: ->(t){ t[7] },
          subcategory: ->(t){ t[8] }
        }
      end
      
    end # class Loop
  end # class Source
end # module Moneymap
