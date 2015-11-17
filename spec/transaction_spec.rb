require_relative '../transaction'

describe Transaction do
  before do
    @exp_t = Transaction.new('22/07/2014,Together Technologies,CHEQUE CARD PURCHASE ROADRUNNER LOC4278193340943018 9362,Together Classroom,25,')
    @inc_t = Transaction.new('09/07/2014,Together Technologies,CASH DEPOSIT KRISTIAN SALYE RS xxxxxxxxxx 907,Transfer from another bank account (System),,10000')
  end

  it 'trims category names' do
    expect(@exp_t.category).to eq('Classroom')
  end

  it 'has a date' do
    expect(@exp_t.date.class).to eq(Date)
    expect(@exp_t.date.month).to eq(7)
    expect(@exp_t.date.year).to eq(2014)
  end

  it 'has a payee' do
    expect(@exp_t.payee.class).to eq(String)
    expect(@exp_t.payee).to include('ROADRUNNER')
  end

  it 'has a spent' do
    expect(@exp_t.spent.class).to eq(Money)
    expect(@exp_t.spent.format).to eq('R25.00')
  end

  it 'has a received' do
    expect(@exp_t.received.class).to eq(Money)
    expect(@inc_t.received.format).to eq('R10,000.00')
    expect(@exp_t.received.format).to eq('R0.00')
  end

  it 'knows if it was an income or expense' do
    expect(@exp_t.expense?).to eq(true)
    expect(@inc_t.expense?).to eq(false)
  end
end

# :account, :payee, :category, :spent, :received
