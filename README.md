# 🌱 Genesis Polis Smart Contracts

**Genesis Polis** is a foundational smart contract suite for Polis's digital management system and participation in an experimental community project.

These contracts are written in Solidity, fully tested with Foundry, and ready for deployment to testnets or mainnet.

---

## 🏗️ Architecture

This system acts as a legal-structural backbone for digital governance of property, participation, and identity within a decentralized urban ecosystem.

### 1. `GenesisParticipationToken.sol`

- Type: ERC721
- Purpose: **Marker of participation** in the Genesis project
- Each participant receives a token representing their involvement
- Every token is linked to a `partyNumber` (off-chain participant identifier)
- Used to initiate off-chain agreements with holders

### 2. `Oikos.sol`

- Type: ERC721
- Purpose: **Private digital property unit** (an “Oikos”) within a Polis
- Represents a land plot or house owned by an address (individual or entity)
- Each Oikos is linked to a `Polis`
- Includes status logic (`in property`, `on sale`, `in project`, etc.)
- Owners can authorize "reminting" (token recovery) if access is lost

### 3. `Polis.sol`

- Inherits from `Oikos`
- Purpose: **Digital representation of a Polis (city)**
- Manages a group of Oikos tokens
- Each Polis can optionally belong to a broader `Unity` (future use)
- Supports filtering Oikos by status and parent relationships

---

## 🛠️ Technologies

- Solidity `^0.8.20`
- [Foundry](https://book.getfoundry.sh/) for testing and deployment
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts) for secure ERC standards

---

## ✅ Testing

This project includes **35+ unit tests** covering:

- Token minting, metadata handling, and status logic
- Ownership and permission checks (`onlyOwner`)
- Event emission
- Edge cases and reverts for invalid input

To run all tests:

```bash
forge test -vv
```

## 📁 Project Structure
src/
  ├─ GenesisParticipationToken.sol
  ├─ Oikos.sol
  └─ Polis.sol

test/
  ├─ GenesisTest.t.sol
  ├─ OikosTest.t.sol
  └─ PolisTest.t.sol

## 👥 Contact

This project is maintained by the Genesis team.  
For inquiries, collaboration, or technical support, please reach out at:  
p.k.filimonov@gmail.com 
