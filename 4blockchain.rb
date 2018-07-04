require 'digest'
require 'yaml'

class Transaction
  attr_reader :from_address
  attr_reader :to_address
  attr_reader :amount
  
  def initialize(from_address, to_address, amount)
    @from_address = from_address
    @to_address = to_address
    @amount = amount
  end
end

class Block
  attr_reader :timestamp
  attr_accessor :transactions
  attr_accessor :previous_hash
  attr_accessor :hash
  attr_accessor :nonce
  
  def initialize(timestamp, transactions, previous_hash = '')
    @timestamp = timestamp
    @transactions = transactions
    @previous_hash = previous_hash
    @hash = calculate_hash
    @nonce = 0
  end
  
  def calculate_hash
    Digest::SHA256.hexdigest @timestamp.to_s + @transactions.to_s + @previous_hash.to_s + @nonce.to_s
  end
  
  def mine_block(difficulty)
    while @hash[0, difficulty] != "0" * difficulty do
      @nonce += 1
      @hash = calculate_hash
    end
  end
end

class Blockchain
  attr_accessor :chain
  attr_reader :difficulty
  attr_accessor :pending_transactions
  attr_reader :mining_reward
  
  def initialize
    @chain = [Block.new(Date.new, {}, "0")]
    @difficulty = 2
    @pending_transactions = []
    @mining_reward = 100
  end
  
  def mine_pending_transactions(mining_reward_address)
    block = Block.new(Date.new, @pending_transactions)
    block.previous_hash = @chain.last.hash
    block.mine_block(@difficulty)
    @chain << block
    @pending_transactions = [Transaction.new(nil, mining_reward_address, @mining_reward)]
  end
  
  def add_transaction(transaction)
    @pending_transactions << transaction
  end
  
  def check_wallet_balance(wallet_address)
    balance = 0
    
    @chain.each do |block|
      block.transactions.each do |transaction|
        if transaction.from_address == wallet_address
          balance -= transaction.amount
        end
        
        if transaction.to_address == wallet_address
          balance += transaction.amount
        end
      end
    end
    
    balance
  end
  
  def chain_valid?
    valid = true
    
    @chain.each_with_index do |block, i|
      unless i == 0
        if block.hash != block.calculate_hash
          valid = false
        end

        if block.previous_hash != @chain[i - 1].hash
          valid = false
        end
      end
    end
    
    valid
  end
end

dc = Blockchain.new 

dc.add_transaction(Transaction.new("tams_address", "dannys_address", 1000))
dc.add_transaction(Transaction.new("dannys_address", "tams_address", 2000))

dc.mine_pending_transactions("leroys_address")

puts "Tam's balance (expect 1000): #{dc.check_wallet_balance('tams_address')}"
puts "Danny's balance (expect -1000): #{dc.check_wallet_balance('dannys_address')}"
puts "Leroy's balance (expect 0): #{dc.check_wallet_balance('leroys_address')}"


dc.mine_pending_transactions("leroys_address")
puts "Leroy's balance (expect 100): #{dc.check_wallet_balance('leroys_address')}"


