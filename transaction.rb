require 'date'
require 'money'
I18n.config.available_locales = :en

# an income or expense transaction with all of it's information
class Transaction
  attr_accessor :date, :account, :payee, :category, :spent, :received
  def initialize(line)
    @date, @account, @payee, @category, @spent, @received = line.split(',')

    @spent = Money.new((@spent.to_f) * 100, 'ZAR')
    @received = Money.new((@received.to_f) * 100, 'ZAR')
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
    @spent.cents != 0 && @received.cents == 0
  end
end
