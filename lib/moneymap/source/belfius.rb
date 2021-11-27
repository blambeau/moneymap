module Moneymap
  class Source
    class Belfius < Source

      def attributes
        {
          id: ->(t){ "#{t[2]}/#{t[3]}" },
          at: ->(t){ Date.parse(t[1]) rescue t[1] },
          account: ->(t){ "#{t[0]}".gsub(/\s/,'') },
          to_account: ->(t){ "#{t[4]}".gsub(/\s/,'') },
          to_name: 5,
          details: 8,
          amount: ->(t){ t[10] && t[10].gsub(/\./,'').gsub(/,/,'.') }
        }
      end

    end # class Belfius
  end # class Source
end # module Moneymap
