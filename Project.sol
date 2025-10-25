// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
  InsurancePolicy.sol
  - Manages policy creation, premium deposits, and claims
  - Keeps transparent records on blockchain
*/

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract InsurancePolicy is AccessControl, ReentrancyGuard {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant INSURER_ROLE = keccak256("INSURER_ROLE");

    uint256 private _policyIds;
    uint256 private _claimIds;

    struct Policy {
        uint256 id;
        address holder;
        uint256 premium;
        uint256 coverageAmount;
        bool active;
        string detailsURI;
    }

    struct Claim {
        uint256 id;
        uint256 policyId;
        address claimant;
        uint256 amount;
        string reason;
        bool approved;
        bool paid;
    }

    mapping(uint256 => Policy) public policies;
    mapping(uint256 => Claim) public claims;

    event PolicyCreated(uint256 indexed id, address indexed holder);
    event PremiumPaid(uint256 indexed id, uint256 amount);
    event ClaimFiled(uint256 indexed id, address indexed claimant);
    event ClaimApproved(uint256 indexed id, uint256 amount);
    event ClaimPaid(uint256 indexed id, address indexed claimant, uint256 amount);

    constructor(address admin) {
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(ADMIN_ROLE, admin);
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "not-admin");
        _;
    }

    // Create a new insurance policy
    function createPolicy(
        address holder,
        uint256 premium,
        uint256 coverageAmount,
        string calldata detailsURI
    ) external onlyAdmin returns (uint256) {
        require(holder != address(0), "zero-holder");

        _policyIds += 1;
        uint256 id = _policyIds;

        policies[id] = Policy({
            id: id,
            holder: holder,
            premium: premium,
            coverageAmount: coverageAmount,
            active: true,
            detailsURI: detailsURI
        });

        emit PolicyCreated(id, holder);
        return id;
    }

    // Premium deposit (payable)
    function payPremium(uint256 policyId) external payable nonReentrant {
        Policy storage p = policies[policyId];
        require(p.active, "inactive");
        require(msg.sender == p.holder, "not-holder");
        require(msg.value == p.premium, "wrong-premium");

        emit PremiumPaid(policyId, msg.value);
    }

    // File claim
    function fileClaim(uint256 policyId, uint256 amount, string calldata reason) external returns (uint256) {
        Policy storage p = policies[policyId];
        require(p.active, "policy-inactive");
        require(msg.sender == p.holder, "not-holder");
        require(amount <= p.coverageAmount, "too-high");

        _claimIds += 1;
        uint256 id = _claimIds;

        claims[id] = Claim({
            id: id,
            policyId: policyId,
            claimant: msg.sender,
            amount: amount,
            reason: reason,
            approved: false,
            paid: false
        });

        emit ClaimFiled(id, msg.sender);
        return id;
    }
}
