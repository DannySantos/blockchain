require 'digest'
require 'time'
require 'yaml'

class Block
  attr_reader :timestamp
  attr_accessor :transactions
  attr_accessor :previous_hash
  attr_accessor :hash
  
  def initialize(timestamp, transactions = {}, previous_hash = '')
    @timestamp = timestamp
    @transactions = transactions
    @previous_hash = previous_hash
    @hash = calculate_hash
  end
  
  def calculate_hash
    Digest::SHA256.hexdigest @timestamp.to_s + @transactions.to_s + @previous_hash.to_s
  end
end

class Blockchain
  attr_accessor :chain
  
  def initialize
    @chain = [Block.new(Date.new)]
  end
  
  def add_block(block)
    block.previous_hash = @chain.last.hash
    block.hash = block.calculate_hash
    @chain << block
  end
end

@tam_coin = Blockchain.new

@tam_coin.add_block(Block.new(Date.new, {amount: 2000}))
@tam_coin.add_block(Block.new(Date.new, {amount: 10000}))

puts @tam_coin.to_yaml
