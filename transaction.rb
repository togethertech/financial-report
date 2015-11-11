require 'date'

# an income or expense transaction with all of it's information
class Transaction
  attr_accessor :date, :account, :payee, :category, :spent, :received
  def initialize(line)
    @date, @account, @payee, @category, @spent, @received = line.split(',')

    @spent = @spent.to_f
    @received = @received.to_f
    trim_category
    parse_date
  end

  def trim_category
    @category = @category.gsub('Together ', '').gsub('Tech ', '').gsub(' and Take-outs', '').gsub('Telephone', 'Phone')
  end

  def parse_date
    @date = Date.parse(@date) if @date =~ /([0-9]{2}\/){2}[0-9]{4}/
  end

  def expense?
    @spent != 0.0 && @received == 0.0
  end
end
