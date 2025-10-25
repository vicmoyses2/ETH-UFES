# ⚡ ETH-UFES – Ethereum Developer Pack

> **Educational Repository by [Victor Moyses Nascimento](https://github.com/vicmoyses2)**  
> Developed during the **Ethereum Developer Pack – UFES**, taught by **Professor Afonso Dalvi**  
> Professor’s GitHub: **https://github.com/Afonsodalvi**
> Promoted by **[Espírito Bitcoin](https://espiritobitcoin.moodiy.com/)**  

---

## 🧠 Learning Objectives

This repository combines **academic material** from the UFES blockchain curriculum with **practical implementations** developed during my learning path.

You’ll find examples and exercises focusing on:

- **Solidity Fundamentals:** Variables, functions, modifiers, inheritance  
- **Advanced Patterns:** Interfaces, abstract contracts, and security models  
- **Testing & Deployment:** Foundry-based testing and automated deployment flows  
- **Smart Contract Security:** Reentrancy protection, CEI pattern, and best practices  
- **Web3 Integration:** Interfacing contracts via ethers.js and frontend dApps  

---

## 🧪 Testing & Development

### Build and Test Commands
```bash
# Build all contracts
forge build

# Run all tests
forge test

# Run with gas report
forge test --gas-report

# Run specific contract tests
forge test --match-contract EscrowTest

# Local blockchain
anvil
```

### Deploy Commands
```bash
# Deploy Escrow contract to Sepolia
make deploy-escrow network=sepolia

# Deploy all contracts
make deploy-all network=sepolia
```

---

## 📚 Learning Path (ETH-UFES)

### Beginner Level
- `Counter.sol` → State variables and functions  
- `Variables.sol` → Storage, memory, calldata  
- `Functions.sol` → Visibility, modifiers, payable  
- `ReceiveFallback.sol` → Handling ETH transfers  

### Intermediate Level
- `InterfaceAbstract.sol` → Interfaces and inheritance  
- `ClassVote.sol` → Voting systems and state machines  
- `TimeLockVault.sol` → Time-based locks  
- `Escrow.sol` → Multi-party transactions and arbitration  

### Advanced Level
- `SafePiggy.sol` → Security patterns and reentrancy protection  
- `ReentrancyAttacker.sol` → Attack simulation and defense  
- Gas optimization, error handling, CEI pattern  

---

⭐ *"Engineering the physical world. Building the digital one."*
