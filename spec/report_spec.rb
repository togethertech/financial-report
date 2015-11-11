require_relative '../report'

describe Report do
  before do
    @rep = Report.new
  end

  it 'is a report' do
    expect(@rep.class).to eq(Report)
  end

  it 'imports a list of transactions' do
    expect(@rep.transactions.class).to eq(Array)
    expect(@rep.transactions.length).to eq(324)
  end

  it 'trims out non transaction lines in the csv' do
    @rep.transactions.each do |t|
      expect(t.date.class).to eq(Date)
    end
  end

  it 'splits transactions into income & expenses' do
    expect(@rep.spent_trans.class).to eq(Array)
    expect(@rep.spent_trans.length).to eq(315)
    @rep.spent_trans.each do |t|
      expect(t.expense?).to eq(true)
    end

    expect(@rep.received_trans.class).to eq(Array)
    expect(@rep.received_trans.length).to eq(9)
    @rep.received_trans.each do |t|
      expect(t.expense?).to eq(false)
    end
  end

  it 'adds up the total income' do
    expect(@rep.total_income).to eq(174_249.4)
  end

  # xit 'selects a date range' do
  # end

  it 'categorizes spent transactions' do
    expect(@rep.categorize_spent.class).to eq(Hash)
    expect(@rep.categorize_spent.length).to eq(11)
    expect(@rep.categorize_spent['Classroom'].class).to eq(Array)
    expect(@rep.categorize_spent['Classroom'].first.class).to eq(Transaction)
    expect(@rep.categorize_spent['Classroom'].first.category).to eq('Classroom')
  end

  it 'adds up the total of each category' do
    expect(@rep.totaled_categories.class).to eq(Hash)
    expect(@rep.totaled_categories['Classroom']).to eq(88743.78)
  end

  it 'adds up the grand total of all expenses' do
    expect(@rep.total_exp(@rep.transactions).round(2)).to eq(173932.88)
  end

  it 'groups transactions by year' do
    expect(@rep.yearly_expenses.class).to eq(Hash)
    expect(@rep.yearly_expenses[2014].class).to eq(Array)
    expect(@rep.yearly_expenses[2014][0].class).to eq(Transaction)
    expect(@rep.yearly_expenses[2014].length).to eq(128)
    expect(@rep.yearly_expenses[2015].length).to eq(187)
  end

  it 'groups transactions by month' do
    expect(@rep.monthly_expenses.class).to eq(Hash)
    expect(@rep.monthly_expenses[2014].class).to eq(Hash)
    expect(@rep.monthly_expenses[2014].size).to eq(6)
    expect(@rep.monthly_expenses[2014][7].class).to eq(Array)
    expect(@rep.monthly_expenses[2014][7].first.class).to eq(Transaction)
    expect(@rep.monthly_expenses[2014][7].first.date.month).to eq(7)
    expect(@rep.monthly_expenses[2014][8].first.date.month).to eq(8)
    expect(@rep.monthly_expenses[2014][8].size).to eq(47)
  end

  it 'adds up total expenses of a month' do
    expect(@rep.total_exp(@rep.monthly_expenses[2014][8])).to eq(21931.97)
  end
end
