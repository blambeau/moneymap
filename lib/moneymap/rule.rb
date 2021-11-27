module Moneymap
  class Rule

    def initialize(matcher, category)
      @matcher, @category = matcher, category
    end
    attr_reader :matcher, :category

    def ===(t)
      case matcher
      when TrueClass, FalseClass then matcher
      when Proc                  then matcher.call(t)
      end
    end

    def call(t)
      split = (category || '').split('/')
      {
        category: split[0],
        subcategory: split[1]
      }
    end

  end # class Rule
end # module Moneymap
