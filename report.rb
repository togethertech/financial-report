require 'date'

class Report
  attr_reader :transactions, :categorized, :totaled_categories
  def initialize
    @transactions = []
    @totaled_categories = {}
    load_transactions
    trim_transactions
    trim_categories
    format_dates
    select_date_range(60)
    categorize
    total_categories
    select_categories
    print_expenses
  end

  def load_transactions
    File.readlines("transactions.csv").each do |line|
      @transactions << Transaction.new(line)
    end
  end

  def trim_transactions
    @transactions = @transactions.select { |t| t.date =~ /([0-9]{2}\/){2}[0-9]{4}/ }
  end

  def trim_categories
    @transactions.each { |t| t.trim_category }
  end

  def format_dates
    @transactions.each { |t| t.parse_date }
  end

  def select_date_range(days)
    @transactions = @transactions.select { |t| (Date.today - t.date) < days }
  end

  def categorize
    @categorized = @transactions.group_by { |t| t.category }
  end

  def total_categories
    @categorized.each do |category, cat_transactions|
      total_spent = cat_transactions.map { |trans| trans.spent }.reduce(:+)
      @totaled_categories[category] = total_spent
    end
  end

  def select_categories
    @totaled_categories = @totaled_categories.select { |c, total| total > 0.0 }
  end

  def print_expenses
    @grand_total = 0.0
    @totaled_categories.sort_by {|k,v| v}.reverse.each do |category, total|
      puts "#{category} - #{total}"
      @grand_total += total
    end
    puts @grand_total
  end

end

class Transaction
  attr_accessor :date, :account, :payee, :category, :spent, :received
  def initialize(line)
    line_arr = line.split(",")
    @date, @account, @payee, @category, @spent, @received = line_arr

    @spent = @spent.to_f
  end

  def trim_category
    @category = @category.gsub("Together ", "").gsub("Tech ", "")
  end

  def parse_date
    @date = Date.parse(@date)
  end
end


r = Report.new
