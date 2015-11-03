require 'date'

$EXCHANGE = 13.74

class Report
  attr_reader :transactions, :categorized, :totaled_categories
  def initialize(days_back)
    @transactions = []
    @totaled_categories = {}
    load_transactions
    trim_transactions
    trim_categories
    format_dates
    select_date_range(days_back)
    categorize
    total_spent_categories
    select_categories
    print_income
    print_expenses
  end

  def to_usd(zar)
    (zar/$EXCHANGE).round(2)
  end

  def load_transactions
    File.readlines("transactions.csv").each do |line|
      @transactions << Transaction.new(line)
    end
  end

  def trim_transactions
    @transactions = @transactions.select { |t| t.date =~ /([0-9]{2}\/){2}[0-9]{4}/ }
    @transactions = @transactions.select { |t| t.category != "Loaned"}
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

  def total_spent_categories
    @categorized.each do |category, cat_transactions|
      total_spent = cat_transactions.map { |trans| trans.spent }.reduce(:+)
      @totaled_categories[category] = total_spent
    end
  end

  def select_categories
    @totaled_categories = @totaled_categories.select { |c, total| total > 0.0 }
  end

  def print_income
    @total_income = @transactions.map { |t| t.received }.reduce(:+)
    puts "Total income".ljust(17, "-") + "#{to_usd(@total_income)}"
  end

  def print_expenses
    puts "Expense Categories"
    @grand_total = 0.0
    @totaled_categories.sort_by {|k,v| v}.reverse.each do |category, total|
      puts "#{category}".ljust(17, "-") + "#{to_usd(total)}"
      @grand_total += total
    end
    puts "Total Expenses".ljust(17, "-") + "#{to_usd(@grand_total)}"
  end

end

class Transaction
  attr_accessor :date, :account, :payee, :category, :spent, :received
  def initialize(line)
    line_arr = line.split(",")
    @date, @account, @payee, @category, @spent, @received = line_arr

    @spent = @spent.to_f
    @received = @received.to_f
  end

  def trim_category
    @category = @category.gsub("Together ", "").gsub("Tech ", "").gsub(" and Take-outs", "").gsub("Telephone", "Phone")
  end

  def parse_date
    @date = Date.parse(@date)
  end
end


r = Report.new(365)
