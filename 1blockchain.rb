require 'digest'
require 'yaml'

class Transaction
  attr_accessor :from_address
  attr_accessor :to_address
  attr_accessor :amount
  
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
    @hash = calculate_hash
    @nonce = 0
  end
  
  def calculate_hash
    Digest::SHA256.hexdigest self.timestamp + self.transactions.to_s + self.previous_hash.to_s + self.nonce.to_s
  end
  
  def mine_block(difficulty)
    diff_string = "0" * difficulty
    
    while self.hash[0, difficulty] != diff_string do
      self.nonce += 1
      self.hash = self.calculate_hash
    end
  end
end

class Blockchain
  attr_accessor :chain
  attr_reader :difficulty
  attr_accessor :pending_transactions
  attr_reader :mining_reward
  
  def initialize
    @chain = [Block.new("01/01/01", {}, 0)]
    @difficulty = 5
    @pending_transactions = []
    @mining_reward = 100
  end
  
  def mine_pending_transactions(mining_reward_address)
    block = Block.new("01/01/01", self.pending_transactions)
    block.previous_hash = @chain.last.hash
    block.mine_block(self.difficulty)
    
    puts "Block successfully mined"
    
    @chain << block
    
    self.pending_transactions = [Transaction.new(nil, mining_reward_address, self.mining_reward)]
  end
  
  def create_transaction(transaction)
    self.pending_transactions << transaction
  end
  
  def check_address_balance(address)
    balance = 0
    
    @chain.each do |block|
      block.transactions.each do |transaction|
        if transaction.from_address == address
          balance -= transaction.amount
        end
        
        if transaction.to_address == address
          balance += transaction.amount
        end
      end
    end
    
    balance
  end
  
  def chain_valid?
    validity = true
    
    @chain.each_with_index do |block, i|
      unless i == 0 
        if block.hash != block.calculate_hash
          validity = false
        end

        if block.previous_hash != @chain[i - 1].hash
          validity = false
        end
      end
    end
    
    validity
  end
end

danny_coin = Blockchain.new

danny_coin.create_transaction(Transaction.new("address1", "address2", 500))
danny_coin.create_transaction(Transaction.new("address2", "address1", 100))

danny_coin.mine_pending_transactions("dannys_address")

puts danny_coin.check_address_balance("address1")
puts danny_coin.check_address_balance("address2")
puts danny_coin.check_address_balance("dannys_address")

danny_coin.mine_pending_transactions("dannys_address")

puts danny_coin.check_address_balance("dannys_address")


