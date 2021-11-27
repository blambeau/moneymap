module Moneymap
  class Source
    class Auto < Source

      def all_transactions
        sources.map(&:all_transactions).flatten
      end

      def recognized_transactions
        sources.map(&:recognized_transactions).flatten
      end

      def unrecognized_transactions
        sources.map(&:unrecognized_transactions).flatten
      end

    private

      def sources
        files.map{|f|
          case f.to_s
          when /\.loop/ then Loop.new([f])
          when /\.belfius/ then Belfius.new([f])
          when /\.bnp2/    then Bnp2.new([f])
          when /\.bnp/     then Bnp.new([f])
          else
            raise "Unable to source file `#{f}`"
          end
        }
      end

    end # class Auto
  end # class Source
end # module Moneymap
