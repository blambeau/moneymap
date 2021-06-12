module Moneymap
  class Source
    class Belfius < Source

      def attributes
        {
          id: ->(t){ "#{t[2]}/#{t[3]}" },
          at: 1,
          account: ->(t){ "#{t[0]}".gsub(/\s/,'') },
          to_account: ->(t){ "#{t[4]}".gsub(/\s/,'') },
          to_name: 5,
          details: 8,
          amount: 10
        }
      end

    end # class Belfius
  end # class Source
end # module Moneymap
