module Moneymap
  module D3
    class Sankey

      def graphit(operand)
        m = main_graph(operand)
        s = sub_graph(operand)
        {
          nodes: (m[:nodes] + s[:nodes]).to_a,
          links: m[:links] + s[:links]
        }
      end

      def main_graph(operand)
        operand = operand.summarize([:account, :category], :total => Alf::Aggregator.sum(:amount))

        # Main nodes and their links
        {
          nodes:
            operand.project([:category]).rename(category: :name) +
            operand.project([:account]).rename(account: :name),

          links: operand
            .map{|t|
              if t[:total] > 0
                source, target = t[:category], t[:account]
              else
                target, source = t[:category], t[:account]
              end
              {
                source: source,
                target: target,
                value: t[:total].abs
              }
            }
        }
      end

      def sub_graph(operand)
        operand = operand.summarize([:category, :subcategory], :total => Alf::Aggregator.sum(:amount))

        # Main nodes and their links
        {
          nodes:
            operand.project([:category]).rename(category: :name) +
            operand
              .project([:category, :subcategory])
              .restrict(->(t){ !t[:subcategory].nil? })
              .extend(:name => ->(t){ "#{t[:category]}/#{t[:subcategory]}" })
              .project([:name]),

          links: operand
            .restrict(->(t){ !t[:subcategory].nil? })
            .map{|t|
              if t[:total] > 0
                source, target = "#{t[:category]}/#{t[:subcategory]}", t[:category]
              else
                target, source = "#{t[:category]}/#{t[:subcategory]}", t[:category]
              end
              {
                source: source,
                target: target,
                value: t[:total].abs
              }
            }
        }
      end

    end # class Sankey
  end # module D3
end # module Moneymap
