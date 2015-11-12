require 'date'
require_relative 'transaction'

$MONTHS = {
  1 => 'January',
  2 => 'February',
  3 => 'March',
  4 => 'April',
  5 => 'May',
  6 => 'June',
  7 => 'July',
  8 => 'August',
  9 => 'September',
  10 => 'October',
  11 => 'November',
  12 => 'December'
}

$EXCHANGE = 13.74

# imports transactions & generates a report
class Report
  attr_reader :transactions, :categorized, :totaled_categories
  def initialize
    @transactions = []
    @totaled_categories = {}
    load_transactions
    trim_transactions
    categorize_spent
    total_spent_categories
    # select_categories
    # print_income
    # print_expenses
  end

  def to_usd(zar)
    zar # (zar/$EXCHANGE).round(2)
  end

  def load_transactions
    File.readlines('transactions.csv').each do |line|
      @transactions << Transaction.new(line)
    end
  end

  def trim_transactions
    @transactions = @transactions.select { |t| t.date.class == Date }
    @transactions = @transactions.select { |t| t.category != 'Loaned' }
  end

  # def select_date_range(days)
  #   dates = @transactions.map { |t| t.date }
  #   @transactions = @transactions.select { |t| (Date.today - t.date) < days }
  # end

  def spent_trans
    @transactions.select(&:expense?)
  end

  def received_trans
    @transactions.reject(&:expense?)
  end

  def total_income
    received_trans.reduce(0) { |sum, t| sum + t.received }.format
  end

  def total_exp(transactions)
    transactions.reduce(0) { |sum, t| sum + t.spent }
  end

  def categorize_spent
    @categorized = spent_trans.group_by(&:category)
  end

  def yearly_expenses
    spent_trans.group_by { |t| t.date.year }
  end

  def total_spent_categories
    @categorized.each do |category, cat_transactions|
      total_spent = cat_transactions.reduce(0) { |sum, t| sum + t.spent }
      @totaled_categories[category] = total_spent
    end
  end

  def select_categories
    @totaled_categories = @totaled_categories.select { |_c, total| total > 0.0 }
  end



  def monthly_expenses
    @monthly_expenses = {}
    yearly_expenses.each do |year, transactions|
      @monthly_expenses[year] = transactions.group_by { |t| t.date.month }
    end
    @monthly_expenses
  end

  def print_income
    puts 'Total income'.ljust(17, '-') + "#{to_usd(total_income)}"
  end

  def print_monthly_expenses
    monthly_expenses.each do |year, months|
      puts year
      months.each do |month, transactions|
        puts "#{$MONTHS[month]}".ljust(10, '-') + "#{total_exp(transactions).format}".rjust(11, '-')
      end
    end
  end

  def print_expenses
    puts 'Expense Categories'
    @totaled_categories.sort_by { |_k, v| v }.reverse_each do |category, total|
      puts "#{category}".ljust(17, '-') + "#{total.format}".rjust(11, '-')
    end
    puts 'Total Expenses'.ljust(17, '-') + "#{total_exp(@transactions).format}".rjust(11, '-')
  end
end

if __FILE__ == $0
  r = Report.new
  puts r.print_income
  puts r.print_expenses
  r.print_monthly_expenses
end