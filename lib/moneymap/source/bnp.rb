module Moneymap
  class Source
    class Bnp < Source

      def attributes
        {
          id: ->(t){ "#{t[0]}" },
          at: ->(t){ Date.parse(t[1]) rescue t[1] },
          account: ->(t){ "#{t[7]}".gsub(/\s/,'') },
          to_account: ->(t){ "#{t[5]}" },
          to_name: ->(t){ "#{t[5]}" },
          details: ->(t){ "#{t[6]}" },
          amount: 3
        }
      end
      
    end # class Bnp
  end # class Source
end # module Moneymap
