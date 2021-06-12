require 'optparse'

module Moneymap
  class Command

    def initialize
      self.source_class = Source::Auto
      self.format = "text"
      self.ignore = []
      @parser = OptionParser.new do|opts|
        opts.banner = "Usage: moneymap [options] FILES"
        opts.on('--belfius', 'Use Belfius file source') do
          self.source_class = Source::Belfius
        end
        opts.on('--bnp', 'Use BNP file source') do
          self.source_class = Source::Bnp
        end
        opts.on('--credit', 'Only keep credit transactions') do
          self.only_credit = true
        end
        opts.on('--debit', 'Only keep debit transactions') do
          self.only_debit = true
        end
        opts.on('--focus CATEGORY', 'Focus on a particular category only') do |category|
          self.focus = category
        end
        opts.on('--ignore CATEGORY', 'Ignore particular categories') do |category|
          self.ignore += category.split(',')
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
        opts.on('-u', '--unrecognized', 'Only show unrecognized transactions then exit') do
          self.unrecognized = true
        end
        opts.on('-t', '--todo', 'Only show unclassified transactions') do
          self.todo = true
        end
        opts.on('-d', '--details', 'Show each line with its category') do
          self.details = true
        end
        opts.on('--out FORMAT', 'Export in (text,sandkey,sunburst)') do |format|
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

    attr_accessor :source_class
    attr_accessor :unrecognized
    attr_accessor :todo
    attr_accessor :details
    attr_accessor :grep_expr
    attr_accessor :rules_file
    attr_accessor :only_credit
    attr_accessor :only_debit
    attr_accessor :source2sink
    attr_accessor :focus
    attr_accessor :ignore
    attr_accessor :average_by
    attr_accessor :format

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

      classified = rules.classify(source.each)

      if self.only_debit
        classified = classified.select{|t| t.debit? }
      elsif self.only_credit
        classified = classified.select{|t| t.credit? }
      elsif self.source2sink
        classified = classified.select{|t| not(t.category =~ /^BE/) }
      end

      if self.focus
        classified = classified.select{|t| t[:category] == self.focus }
      end

      if self.ignore
        classified = classified.reject{|t| self.ignore.include? t[:category] }
      end

      if self.average_by
        classified = classified.map{|t| t.divide_by(self.average_by) }
      end

      if todo
        debug classified.select{|t| t[:category].nil? or t[:category] == 'Unclassified' }
      elsif details
        debug classified
      elsif grep_expr
        debug classified.select{|t| t.matches?(grep_expr) }
      end

      case self.format
      when /text/
        Alf::Renderer.text(Summarizer.new.summarize(classified)).execute
      when /sankey/
        relation = Alf::Relation.coerce(classified.map{|t| t.to_h })
        puts JSON.pretty_generate(D3::Sankey.new.graphit(relation))
      when /sunburst/
        relation = Alf::Relation.coerce(classified.map{|t| t.to_h })
        puts JSON.pretty_generate(D3::Sunburst.new.graphit(relation))
      end
    end

    protected

      def debug(transactions)
        Alf::Renderer.text(transactions.map{|t|
          t.merge({
            :details => t[:details].to_s[0..100],
            :to_name => t[:to_name].to_s[0..55]
          }).to_h
        }).execute
      end

  end # class Command
end # module Moneymap
