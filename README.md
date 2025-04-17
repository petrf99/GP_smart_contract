# 🌱 Genesis Polis Smart Contracts

**Genesis Polis** is a foundational suite of smart contracts for digital property management, community participation, and urban governance within an experimental system called *Polis*.

These contracts are written in **Solidity**, thoroughly tested using **Foundry**, and ready for deployment to testnets or mainnet.

---

## 🏗️ Architecture

This system acts as a legal-structural backbone for digital governance of property, participation, and identity in a self-governed urban ecosystem.

A *Polis* consists of several *Oikoses*, each representing a living unit (e.g., land plot or house) for one family or entity.

---

### 🔹 `GenesisParticipationToken.sol`

- **Type**: ERC721
- **Purpose**: Represents **participation** in the Genesis project
- Each token corresponds to a unique participant
- Linked to a `partyNumber` (an off-chain identifier)
- Used to initiate real-world agreements with holders

---

### 🔹 `Oikos.sol`

- **Type**: ERC721
- **Purpose**: Represents a **digital private property unit** (*Oikos*) within a Polis
- Each token is tied to a specific *Polis*
- Includes detailed status logic: `in property`, `on sale`, `in project`, etc.
- Owners can authorize **token reminting** in case of lost access (recovery feature)

---

### 🔹 `Polis.sol`

- **Inherits from**: `Oikos`
- **Purpose**: Represents a **Polis (city)** as a collection of Oikoses
- Manages grouped Oikos tokens with parent-child relationships
- Supports **filtering** Oikoses by status and Polis ID
- Each Polis can optionally belong to a higher-level `Unity` (future extension)

---

## 🛠️ Tech Stack

- **Solidity** `^0.8.20`
- **Foundry** – for testing, scripting, and deployment  
  [→ Foundry Docs](https://book.getfoundry.sh/)
- **OpenZeppelin** – audited ERC implementations  
  [→ OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)

---

## ✅ Testing

Includes **40+ unit tests** covering:

- Token minting & metadata
- Ownership logic (`onlyOwner`)
- Status management
- Event emission
- Validation & reverts

🧪 To run all tests:

```bash
forge test -vv
```

---

## 📁 Project Structure

```
src/
  ├─ GenesisParticipationToken.sol
  ├─ Oikos.sol
  └─ Polis.sol

test/
  ├─ GenesisTest.t.sol
  ├─ OikosTest.t.sol
  └─ PolisTest.t.sol

script/scenarios_of_use/
  └─ Real-world interaction scripts
```

---

## 🧚 Examples

You can explore the `script/scenarios_of_use` folder for practical scripts that simulate real-world usage of the contracts — including minting, transferring, and filtering tokens.

---

## 👥 Contact

Maintained by the **Genesis Team**.

📩 For questions, collaborations, or technical support:  
**p.k.filimonov@gmail.com**