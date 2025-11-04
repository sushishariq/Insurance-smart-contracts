# 🛡️ InsurancePolicy Smart Contract

## Overview
The **InsurancePolicy.sol** contract is a blockchain-based insurance management system that ensures **transparency**, **accountability**, and **trustless claim handling** between policyholders and insurers.  
It allows administrators to create insurance policies, holders to pay premiums, and insurers to process claims — all securely on-chain.

---

## ✨ Key Features
- **Role-Based Access Control**  
  Uses OpenZeppelin’s `AccessControl` to define `ADMIN_ROLE` and `INSURER_ROLE` for controlled operations.
  
- **Transparent Policy Creation**  
  Policies are created by admins and permanently recorded on the blockchain with unique IDs.

- **Secure Premium Payments**  
  Policyholders pay premiums directly via smart contracts (`payable`), with built-in reentrancy protection.

- **Claims Lifecycle Management**  
  Claim filing, approval, and payouts are handled through immutable on-chain logic.

- **Immutable Record Keeping**  
  All events (policy creation, premium payments, claim approvals) are publicly accessible and verifiable.

---

## 🧱 Contract Architecture

### Roles
| Role | Description | Permissions |
|------|--------------|-------------|
| `ADMIN_ROLE` | Deployed and managed by the contract admin. | Can create or deactivate policies. |
| `INSURER_ROLE` | Designated insurance authority. | Can approve and pay claims. |
| `DEFAULT_ADMIN_ROLE` | Superuser role for role assignments. | Grants or revokes roles. |

---

## ⚙️ Core Data Structures

### `Policy`
Stores information about each insurance policy:
```solidity
struct Policy {
    uint256 id;
    address holder;
    uint256 premium;
    uint256 coverageAmount;
    bool active;
    string detailsURI;
}
```
Claim
Tracks each claim filed against a policy:
```
solidity
Copy code
struct Claim {
    uint256 id;
    uint256 policyId;
    address claimant;
    uint256 amount;
    string reason;
    bool approved;
    bool paid;
}
```
🧩 Main Functions
1. createPolicy()
solidity
```
Copy code
function createPolicy(
    address holder,
    uint256 premium,
    uint256 coverageAmount,
    string calldata detailsURI
) external onlyAdmin returns (uint256);
```
Creates a new insurance policy and assigns it to a holder.

Requirements:

Caller must have ADMIN_ROLE.

holder address cannot be zero.

premium and coverageAmount must be positive values.

Event:
```
PolicyCreated(uint256 indexed id, address indexed holder)
```
2. payPremium()
solidity
```
Copy code
function payPremium(uint256 policyId) external payable nonReentrant;
```
Allows a policyholder to deposit the premium amount.

Requirements:

The policy must be active.

Caller must be the policyholder.

msg.value must match the premium amount.

Event:
PremiumPaid(uint256 indexed id, uint256 amount)

3. fileClaim()
solidity
```
Copy code
function fileClaim(
    uint256 policyId,
    uint256 amount,
    string calldata reason
) external returns (uint256);
```
Lets the policyholder file a claim for an active policy.

Requirements:

Policy must be active.

Claimant must be the policyholder.

Requested amount ≤ coverage amount.

Event:
ClaimFiled(uint256 indexed id, address indexed claimant)

4. approveClaim()
solidity
```
Copy code
function approveClaim(uint256 claimId) external onlyInsurer;
```
Allows an insurer to approve a submitted claim.

Requirements:

Caller must have INSURER_ROLE.

The claim must not be already approved or paid.

Event:
ClaimApproved(uint256 indexed id, uint256 amount)

5. payClaim()
solidity
```
Copy code
function payClaim(uint256 claimId) external payable onlyInsurer nonReentrant;
```
Executes the payment of an approved claim directly to the claimant.

Requirements:

Claim must be approved and unpaid.

msg.value must equal the claim amount.

Event:
ClaimPaid(uint256 indexed id, address indexed claimant, uint256 amount)

6. deactivatePolicy()
solidity
```
Copy code
function deactivatePolicy(uint256 policyId) external onlyAdmin;
```
Deactivates an existing policy (e.g., after expiration or cancellation).

🧰 Dependencies
This contract leverages battle-tested OpenZeppelin libraries:

@openzeppelin/contracts/access/AccessControl.sol

@openzeppelin/contracts/security/ReentrancyGuard.sol

🪙 Events Summary
Event	Description
PolicyCreated(id, holder)	Emitted when a new policy is created.
PremiumPaid(id, amount)	Triggered when a premium is paid.
ClaimFiled(id, claimant)	Logged when a new claim is submitted.
ClaimApproved(id, amount)	Marks claim approval by insurer.
ClaimPaid(id, claimant, amount)	Records final claim payout.

🧑‍💼 Example Workflow
Deployment:
The contract is deployed by the admin (DEFAULT_ADMIN_ROLE).

Setup Roles:
Admin assigns INSURER_ROLE to the authorized insurance entity.

Policy Creation:
Admin creates a policy for a user with createPolicy().

Premium Payment:
Policyholder pays the premium using payPremium().

Claim Filing:
Holder files a claim via fileClaim() with reason and amount.

Claim Approval & Payment:
Insurer verifies and executes approveClaim() → payClaim().

🧪 Testing & Deployment
Prerequisites
Node.js ≥ 18.x

Hardhat or Foundry environment

OpenZeppelin Contracts package

Installation
bash
Copy code
npm install @openzeppelin/contracts
Compile
bash
Copy code
npx hardhat compile
Deploy
bash
Copy code
npx hardhat run scripts/deploy.js --network <network-name>
🧠 Security Considerations
Protected by ReentrancyGuard to prevent reentrancy attacks.

Enforces strict role-based permissions.

All monetary flows are transparent and event-logged.

Avoids arbitrary admin withdrawals — funds are only moved via approved claims.

## Contract Deployment

0x9A2626aeACdB6c50E294bD7fBFf3d340A113ad93
<img width="1397" height="699" alt="image" src="https://github.com/user-attachments/assets/915e2c97-b60f-45dd-98b3-ef55447bc883" />
