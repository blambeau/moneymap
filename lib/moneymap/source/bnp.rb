module Moneymap
  class Source
    class Bnp < Source

      def attributes
        {
          at: 1,
          id: ->(t){ "#{t[0]}" },
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
