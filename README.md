# HealPass

A decentralized, patient-first health data access protocol that empowers individuals to securely store, share, and control their medical records across chains and borders — all on-chain.

---

## Overview

HealPass is composed of ten smart contracts working together to create a cross-chain, privacy-preserving health record ecosystem:

1. **Patient Registry Contract** – Manages patient onboarding and decentralized identity mapping.
2. **Provider Registry Contract** – Verifies and whitelists licensed healthcare providers.
3. **Access Control Contract** – Handles secure access requests and permissions for health records.
4. **Health Record Anchor Contract** – Anchors encrypted off-chain data hashes and metadata on-chain.
5. **Cross-Chain Bridge Contract** – Enables secure cross-chain messaging and data sharing.
6. **Audit Log Contract** – Records an immutable trail of all access and modification events.
7. **Emergency Access Contract** – Grants access via multisig consensus in emergencies.
8. **Reputation Contract** – Tracks provider performance and data trustworthiness.
9. **Token Incentive Contract** – Rewards data validation, provider participation, and ecosystem contributions.
10. **Governance Contract** – Manages protocol upgrades, policy changes, and community decisions.

---

## Features

- **Decentralized identity management** for patients and providers  
- **Cross-chain data sharing** using interoperability protocols  
- **Patient-controlled access permissions** with revocation rights  
- **Encrypted health records** anchored on-chain (IPFS/Filecoin integration)  
- **Emergency access mechanism** governed by multisig provider groups  
- **Real-time access audit logs** for compliance and transparency  
- **Provider reputation scoring** to ensure data quality and trust  
- **Token-based incentives** to encourage accurate data entry and upkeep  
- **Modular governance** for community and institutional collaboration  

---

## Smart Contracts

### Patient Registry Contract
- Maps patients to decentralized identifiers (DIDs)
- Registers new patient wallets
- Stores encrypted metadata for off-chain records

### Provider Registry Contract
- Registers and verifies licensed providers
- Links provider credentials to Chainlink Functions or oracle systems
- Supports suspension or removal based on reputation or fraud

### Access Control Contract
- Issues, tracks, and revokes granular access rights
- Manages time-limited and scope-limited permissions
- Interfaces with off-chain storage access tokens

### Health Record Anchor Contract
- Stores IPFS/Filecoin hash references to encrypted health data
- Links record metadata to timestamps and record types
- Supports version control and updates

### Cross-Chain Bridge Contract
- Uses LayerZero, Axelar, or Wormhole to relay access events and updates
- Enables cross-chain record requests and approvals
- Verifies source-chain authenticity

### Audit Log Contract
- Appends immutable logs of every access, write, and revocation
- Publicly readable for audit and compliance
- Timestamped, hashed entries for each interaction

### Emergency Access Contract
- Allows temporary access through multisig from trusted providers
- Requires threshold approval (e.g., 3-of-5)
- Logs usage separately for review

### Reputation Contract
- Updates provider reputation based on usage, reviews, and activity
- Penalizes bad actors via governance-triggered actions
- Enables public inspection of provider trust scores

### Token Incentive Contract
- Rewards accurate record anchoring and provider participation
- Distributes utility tokens ($HEAL)
- Allows staking for governance or benefits

### Governance Contract
- Manages HealPass protocol upgrades and policy decisions
- Allows voting via staked $HEAL tokens
- Supports proposal submission and quorum enforcement

---

## Installation

1. Install [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/healpass.git
   ```
3. Run tests:
    ```bash
    npm test
    ```
4. Deploy contracts:
    ```bash
    clarinet deploy
    ```

---

## Usage

HealPass contracts are modular but interoperable. Each contract provides specific capabilities for patient data access, provider trust, and cross-chain functionality. Refer to the individual smart contract documentation for method signatures, parameters, and sample transactions.

---

## License

MIT License