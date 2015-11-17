require_relative '../report'

describe Report do
  before do
    @report = Report.new('spec/test_transactions.csv', 'USD', 0.08)
  end

  it 'is a report' do
    expect(@report.class).to eq(Report)
  end

  it 'imports a list of transactions' do
    expect(@report.transactions.class).to eq(Array)
    expect(@report.transactions.length).to eq(324)
  end

  it 'trims out non transaction lines in the csv' do
    @report.transactions.each do |t|
      expect(t.date.class).to eq(Date)
    end
  end

  it 'splits transactions into income & expenses' do
    expect(@report.spent_trans.class).to eq(Array)
    expect(@report.spent_trans.length).to eq(315)
    @report.spent_trans.each do |t|
      expect(t.expense?).to eq(true)
    end

    expect(@report.received_trans.class).to eq(Array)
    expect(@report.received_trans.length).to eq(9)
    @report.received_trans.each do |t|
      expect(t.expense?).to eq(false)
    end
  end

  it 'adds up the total income' do
    expect(@report.total_income).to eq('R174,249.40')
  end

  # xit 'selects a date range' do
  # end

  it 'categorizes spent transactions' do
    expect(@report.categorize_spent.class).to eq(Hash)
    expect(@report.categorize_spent.length).to eq(11)
    expect(@report.categorize_spent['Classroom'].class).to eq(Array)
    expect(@report.categorize_spent['Classroom'].first.class).to eq(Transaction)
    expect(@report.categorize_spent['Classroom'].first.category).to eq('Classroom')
  end

  it 'adds up the total of each category' do
    expect(@report.totaled_categories.class).to eq(Hash)
    expect(@report.totaled_categories['Classroom'].format).to eq('R88,743.78')
  end

  it 'adds up the grand total of all expenses' do
    expect(@report.total_exp(@report.transactions).format).to eq('R173,932.88')
  end

  it 'groups transactions by year' do
    expect(@report.yearly_expenses.class).to eq(Hash)
    expect(@report.yearly_expenses[2014].class).to eq(Array)
    expect(@report.yearly_expenses[2014][0].class).to eq(Transaction)
    expect(@report.yearly_expenses[2014].length).to eq(128)
    expect(@report.yearly_expenses[2015].length).to eq(187)
  end

  it 'groups transactions by month' do
    expect(@report.monthly_expenses.class).to eq(Hash)
    expect(@report.monthly_expenses[2014].class).to eq(Hash)
    expect(@report.monthly_expenses[2014].size).to eq(6)
    expect(@report.monthly_expenses[2014][7].class).to eq(Array)
    expect(@report.monthly_expenses[2014][7].first.class).to eq(Transaction)
    expect(@report.monthly_expenses[2014][7].first.date.month).to eq(7)
    expect(@report.monthly_expenses[2014][8].first.date.month).to eq(8)
    expect(@report.monthly_expenses[2014][8].size).to eq(47)
  end

  it 'adds up total expenses of a month' do
    expect(@report.total_exp(@report.monthly_expenses[2014][8]).format).to eq('R21,931.97')
  end

  it 'splits ongoing from regular expenses' do
    expect(@report.split_once_vs_ongoing(@report.transactions).class).to eq(Hash)
    expect(@report.split_once_vs_ongoing(@report.transactions)[:one_time].class).to eq(Array)
    expect(@report.split_once_vs_ongoing(@report.transactions)[:one_time].class).to eq(Array)
    expect(@report.split_once_vs_ongoing(@report.transactions)[:one_time][0].class).to eq(Transaction)
    expect(@report.split_once_vs_ongoing(@report.transactions)[:one_time][0].category).to eq('Classroom')
    once_vs_ongoing = @report.split_once_vs_ongoing(@report.transactions)
    expect(once_vs_ongoing[:one_time].length).to eq(87)
    expect(once_vs_ongoing[:recurring].length).to eq(237)

    once_vs_ongoing[:one_time].each do |t|
      expect(t.class).to eq(Transaction)
      expect(t.category).to eq('Classroom')
    end

    once_vs_ongoing[:recurring].each do |t|
      expect(t.class).to eq(Transaction)
      expect(t.category).not_to eq('Classroom')
    end
  end

  it 'receives a currency in which it will print reports' do
    @report = Report.new('spec/test_transactions.csv', 'USD', 0.08)
    expect(@report.output_currency).to eq('USD')
  end
end
