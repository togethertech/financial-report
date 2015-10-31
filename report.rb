class Report
  attr_reader :transactions, :categorized
  def initialize
    @transactions = []
    load_transactions
    trim_transactions
    categorize
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

  def categorize
    @categorized = @transactions.group_by { |i| i.category }
  end

  def print_expenses
    @categorized.each do |category, cat_transactions|
      total_spent = cat_transactions.map { |trans| trans.spent }.reduce(:+)
      puts "#{category} - #{total_spent}"
    end
  end

end

class Transaction
  attr_accessor :date, :account, :payee, :category, :spent, :received
  def initialize(line)
    line_arr = line.split(",")
#    if line_arr[0] =~ /([0-9]{2}\/){2}[0-9]{4}/
      @date, @account, @payee, @category, @spent, @received = line_arr
      @spent = @spent.to_f
#    end
  end
end


r = Report.new
