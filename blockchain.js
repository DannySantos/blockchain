const SHA256 = require('crypto-js/sha256');

class Transaction {
  constructor(fromAddress, toAddress, amount) {
    this.fromAddress = fromAddress;
    this.toAddress = toAddress;
    this.amount = amount;
  }
}

class Block {
  constructor(timestamp, transactions, previousHash = '') {
    this.previousHash = previousHash;
    this.timestamp = timestamp;
    this.transactions = transactions;
    this.hash = this.calculateHash();
    this.nonce = 0;
  }
  
  calculateHash() {
    return SHA256(this.previousHash + this.timestamp + this.nonce + JSON.stringify(this.transactions)).toString();
  }
  
  mineBlock(difficulty) {
    while(this.hash.substring(0, difficulty) !== Array(difficulty + 1).join("0")) {
      this.nonce++;
      this.hash = this.calculateHash();
    }
    
    console.log("Block mined");
  }
}

class Blockchain {
  constructor() {
    this.chain = [this.createGenesisBlock()];
    this.difficulty = 2;
    this.pendingTransactions = [];
    this.miningReward = 100;
  }
    
  createGenesisBlock() {
    return new Block("01/01/2018", "Genesis block", "0");
  }

  getLatestBlock() {
    return this.chain[this.chain.length - 1];
  }

  minePendingTransactions(miningRewardAddress) {
    let block = new Block(Date.now(), this.pendingTransactions);
    block.previousHash = this.getLatestBlock().hash;
    block.mineBlock(this.difficulty);
    
    console.log("Block successfully mined");
    
    this.chain.push(block);
    
    this.pendingTransactions = [
      new Transaction(null, miningRewardAddress, this.miningReward)
    ];
  }
  
  getBalanceOfAddress(address) {
    let balance = 0;
    
    for(const block of this.chain) {
      for(const trans of block.transactions) {
        if(trans.fromAddress == address) {
          balance -= trans.amount;
        }
        
        if(trans.toAddress == address) {
          balance += trans.amount;
        }
      }
    }
    
    return balance;
  }
  
  createTransaction(transaction) {
    this.pendingTransactions.push(transaction);
  }
  
  isChainValid() {
    for(let i = 1; i < this.chain.length; i++) {
      const currentBlock = this.chain[i];
      const previousBlock = this.chain[i - 1];
      
      if(currentBlock.hash !== currentBlock.calculateHash()) {
        return false;
      }
      
      if(currentBlock.previousHash !== previousBlock.hash) {
        return false;
      }
    }
    
    return true;
  }
}

var dannyCoin = new Blockchain;

dannyCoin.createTransaction(new Transaction("address1", "address2", 100));
dannyCoin.createTransaction(new Transaction("address2", "address1", 50));

console.log("\nStarting the miner");
dannyCoin.minePendingTransactions("dannys-address");

console.log("\nBalance of Danny's Address: " + dannyCoin.getBalanceOfAddress("address2"));

dannyCoin.minePendingTransactions("dannys-address");
console.log("\nBalance of Danny's Address: " + dannyCoin.getBalanceOfAddress("dannys-address"));

dannyCoin.chain[1].transactions = [dannyCoin.createTransaction(new Transaction("address1", "dannys-address", 10000))]
dannyCoin.chain[1].hash = dannyCoin.chain[1].calculateHash();

dannyCoin.chain[2].previousHash = dannyCoin.chain[1].calculateHash();
dannyCoin.chain[2].hash = dannyCoin.chain[2].calculateHash();

console.log("\nIs chain valid? " + dannyCoin.isChainValid());
