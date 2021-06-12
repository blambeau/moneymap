module Moneymap
  class Rules

    def initialize
      @rules  = []
      yield self if block_given?
    end
    attr_reader :rules

    def self.default
      Rules.new do |rs|
        rs.add(nil){|t| true }
      end
    end

    def add(category, &bl)
      rules << Rule.new(bl, category)
    end

    def classify(enum)
      enum.map do |t|
        rule = rules.find{|r| r === t }
        t.merge(rule ? rule.call(t) : { category: "Unclassified", subcategory: "All" })
      end
    end

  end # class Rules
end # module Moneymap
