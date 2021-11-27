require 'optparse'

module Moneymap
  class Command

    def initialize
      self.source_class = Source::Auto
      self.format = "text"
      self.mode = :evolution
      self.per = [:category]
      @parser = OptionParser.new do|opts|
        opts.banner = "Usage: moneymap [options] FILES"
        opts.on('--belfius', 'Use Belfius file source') do
          self.source_class = Source::Belfius
        end
        opts.on('--bnp', 'Use BNP file source') do
          self.source_class = Source::Bnp
        end
        opts.on('--loop', 'Use loop source') do
          self.source_class = Source::Loop
        end
        opts.on('--credit', 'Only keep credit transactions') do
          self.only_credit = true
        end
        opts.on('--debit', 'Only keep debit transactions') do
          self.only_debit = true
        end
        opts.on('--category CATEGORY,...', 'Focus on particular categories only') do |category|
          self.category = category.split(',')
        end
        opts.on('--subcategory SUBCATEGORY,...', 'Focus on particular subcategories only') do |category|
          self.subcategory = category.split(',')
        end
        opts.on('--ignore CATEGORY', 'Ignore particular categories') do |category|
          self.ignore = category.split(',')
        end
        opts.on('--source2sink', 'Hide transferts between internal accounts') do
          self.source2sink = true
        end
        opts.on('--average X', 'Computes the average by dividing totals by X') do |x|
          self.average_by = x.to_i
        end
        opts.on('--grep EXPR', 'Find recognized transactions through a regular expression') do |expr|
          self.grep_expr = Regexp.new(expr, Regexp::IGNORECASE)
        end
        opts.on('--account EXPR', 'Filter transactions on a given account only') do |expr|
          self.account = expr.split(',')
        end
        opts.on('--year EXPR', 'Filter transactions in a given year') do |expr|
          self.year = Integer(expr)
        end
        opts.on('--per EXPR', 'Summarize per specified attributes') do |expr|
          self.per = expr.split(',').map(&:to_sym)
        end
        opts.on('-u', '--unrecognized', 'Only show unrecognized transactions then exit') do
          self.unrecognized = true
        end
        opts.on('-t', '--todo', 'Only show unclassified transactions') do
          self.mode = :todo
        end
        opts.on('--evolution', 'Show evolution per --per') do
          self.mode = :evolution
        end
        opts.on('--balance', 'Show balance per --per') do
          self.mode = :balance
        end
        opts.on('--details', 'Show detailed transactions') do
          self.mode = :details
        end
        opts.on('--out FORMAT', 'Export in (text,sandkey,sunburst,csv)') do |format|
          self.format = format
        end
        opts.on('--rules RULEFILE') do |rules_file|
          self.rules_file = rules_file
        end
        opts.on('-h', '--help', 'Displays Help') do
          puts opts
          exit
        end
      end
    end

    attr_reader :parser
    protected :parser

    attr_accessor :mode
    attr_accessor :source_class
    attr_accessor :unrecognized
    attr_accessor :grep_expr
    attr_accessor :year
    attr_accessor :rules_file
    attr_accessor :only_credit
    attr_accessor :only_debit
    attr_accessor :source2sink
    attr_accessor :category
    attr_accessor :subcategory
    attr_accessor :ignore
    attr_accessor :average_by
    attr_accessor :format
    attr_accessor :account
    attr_accessor :per

    def is_loop?
      self.source_class == Source::Loop
    end

    def call(argv)
      parser.parse!(argv)
      source = source_class.new(argv)

      if unrecognized
        debug source.unrecognized_transactions
      end

      ruler = nil
      if rules_file
        rules = Kernel.instance_eval (Path.pwd/rules_file).read, rules_file
      else
        rules = Rules.default
      end

      classified = source.each.to_a
      classified = rules.classify(classified) unless is_loop?
      classified = Transactions.new(classified)

      if self.only_debit
        classified = classified.select{|t| t.debit? }
      elsif self.only_credit
        classified = classified.select{|t| t.credit? }
      elsif self.source2sink
        classified = classified.select{|t| not(t.category =~ /^BE/) }
      end

      if self.account
        classified = classified.select{|t| self.account.include?(t[:account]) }
      end

      if self.category
        classified = classified.select{|t| self.category.any?{|f| t[:category] == f }}
      end

      if self.subcategory
        classified = classified.select{|t| self.subcategory.any?{|f| t[:subcategory] == f }}
      end

      if self.ignore
        classified = classified.reject{|t| self.ignore.any?{|f| t[:category] == f }}
      end

      if self.year
        classified = classified.select{|t| t[:at].year == self.year }
      end

      if self.grep_expr
        classified = classified.select{|t| t.matches?(grep_expr) }
      end

      if self.average_by
        classified = classified.map{|t| t.divide_by(self.average_by) }
      end

      classified = case mode
      when :todo
        classified
          .select{|t| t[:category].nil? or t[:category] == 'Unclassified' }
          .by_abs_amount_asc
      when :details
        classified
          .map{|t|
            t.merge({
              :details => t[:details].to_s[0..100],
              :to_name => t[:to_name].to_s[0..55]
            }).to_h
          }
          .by_abs_amount_asc
      when :balance
        Summarizer.new.summarize(classified, :balance, per)
      when :evolution
        Summarizer.new.summarize(classified, :evolution, per)
      end

      case self.format
      when /text/
        Alf::Renderer.text(classified.to_a.map{|t| t.to_h }).execute
      when /csvh/
        puts classified.to_csv(write_headers: true, col_sep: ';')
      when /csv/
        puts classified.to_csv(write_headers: false, col_sep: ';')
      end        
    end

  end # class Command
end # module Moneymap
