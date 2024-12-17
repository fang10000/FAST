// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract FractionalAllowanceStablecoin is ERC20, AccessControl {
    // Roles
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // The fraction of total supply that the minter is allowed, expressed in basis points
    // e.g., fractionInBps = 100 means 1% (100/10,000)
    uint256 public fractionInBps;
    // Tracks the current minter allowance in tokens
    uint256 public minterAllowance;

    // Drip model variables
    uint256 public dripSpeed = 1; // 1/100 of fractionInBps
    uint256 public dripInterval = 60; // 60 seconds
    uint256 public lastDripTime; // Last time the drip was called

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address adminAddress,
        address governanceAddress,
        address minterAddress,
        uint256 initialFractionInBps
    ) ERC20(name_, symbol_) {
        // Grant initial roles
        _grantRole(DEFAULT_ADMIN_ROLE, adminAddress);
        _grantRole(GOVERNANCE_ROLE, governanceAddress);
        _grantRole(MINTER_ROLE, minterAddress);

        // Mint initial supply to governance or a treasury wallet
        _mint(adminAddress, initialSupply_);

        // Set initial fraction and calculate initial minter allowance
        fractionInBps = initialFractionInBps;
        minterAllowance = _calculateMinterAllowance();
        lastDripTime = block.timestamp;
    }

    /**
     * @dev Mint new tokens. Only the address with MINTER_ROLE can call this.
     * Must not exceed current minterAllowance.
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _applyDrip();
        require(
            amount <= minterAllowance,
            "FractionalAllowanceStablecoin: amount exceeds minter allowance"
        );
        minterAllowance -= amount;
        _mint(to, amount);
    }

    /**
     * @dev Set the fraction of total supply that defines the minter allowance.
     * This function can only be called by governance. Once changed, `replenishMinterAllowance()`
     */
    // Define a struct to hold the pending request
    struct FractionRequest {
        uint256 fractionInBps;
        address requester;
        bool isPending;
    }

    FractionRequest private pendingFractionRequest;

    event FractionRequestCreated(uint256 fractionInBps, address requester);
    event FractionRequestApproved(uint256 fractionInBps, address approver);

    // Function to request a fraction update
    function requestMinterFractionUpdate(uint256 newFractionInBps) public onlyRole(GOVERNANCE_ROLE) {
        pendingFractionRequest = FractionRequest({
            fractionInBps: newFractionInBps,
            requester: msg.sender,
            isPending: true
        });
        emit FractionRequestCreated(newFractionInBps, msg.sender);
    }

    // Function to approve the requested fraction update
    function approveMinterFractionUpdate() public onlyRole(DEFAULT_ADMIN_ROLE) {
    require(pendingFractionRequest.isPending, "No pending request");
    fractionInBps = pendingFractionRequest.fractionInBps;
    pendingFractionRequest.isPending = false;
    emit FractionRequestApproved(pendingFractionRequest.fractionInBps, msg.sender);
}

    /**
     * @dev Recalculate the minter’s allowance based on the current total supply and fraction.
     * Can only be called by governance.
     */
    function replenishMinterAllowance() external onlyRole(GOVERNANCE_ROLE) {
        minterAllowance = _calculateMinterAllowance();
    }

    /**
     * @dev Set the drip speed. Can only be called by GOVERNANCE_ROLE.
     */
    function setDripSpeed(
        uint256 newDripSpeed
    ) external onlyRole(GOVERNANCE_ROLE) {
        dripSpeed = newDripSpeed;
    }

    /**
     * @dev Set the drip interval. Can only be called by GOVERNANCE_ROLE.
     */
    function setDripInterval(
        uint256 newDripInterval
    ) external onlyRole(GOVERNANCE_ROLE) {
        dripInterval = newDripInterval;
    }

    /**
     * @dev Internal function to calculate allowance based on fractionInBps and current total supply.
     */
    function _calculateMinterAllowance() internal view returns (uint256) {
        uint256 total = totalSupply();
        return (total * fractionInBps) / 10000;
    }

    /**
     * @dev Internal function to apply the drip model.
     */
    function _applyDrip() internal {
        uint256 currentTime = block.timestamp;
        if (currentTime >= lastDripTime + dripInterval) {
            uint256 intervalsPassed = (currentTime - lastDripTime) /
                dripInterval;
            uint256 dripAmount = (minterAllowance *
                dripSpeed *
                intervalsPassed) / 100;
            uint256 maxAllowance = _calculateMinterAllowance();
            minterAllowance = minterAllowance + dripAmount > maxAllowance
                ? maxAllowance
                : minterAllowance + dripAmount;
            lastDripTime = currentTime;
        }
    }
}
