module Moneymap
  class Source
    class Bnp2 < Source

      def attributes
        {
          id: ->(t){ "#{t[0]}" },
          at: ->(t){ Date.parse(t[1]) rescue t[1] },
          account: ->(t){ "#{t[5]}".gsub(/\s/,'') },
          to_account: ->(t){ "#{t[7]}" },
          to_name: ->(t){ "#{t[8]}" },
          details: ->(t){ t[9].to_s.strip.empty? ? t[10].to_s.strip : t[9].to_s.strip },
          amount: 3
        }
      end
      
    end # class Bnp2
  end # class Source
end # module Moneymap
