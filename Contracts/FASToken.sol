// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract FractionalAllowanceStablecoin is ERC20, AccessControl {
    // Roles
    bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // The fraction of total supply that the minter is allowed, expressed in basis points
    // e.g., fractionInBps = 100 means 1%
    uint256 public fractionInBps;
    // Tracks the current minter allowance in tokens
    uint256 public minterAllowance;

    // Drip model variables
    uint256 public dripAmount = 50;
    uint256 public dripInterval = 60;
    uint256 public maxAllowance;
    uint256 public lastDripTime;

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

    struct DripAmountRequest {
        uint256 newDripAmount;
        address requester;
        bool isPending;
    }

    DripAmountRequest private pendingDripAmountRequest;

    event DripAmountRequestCreated(uint256 newDripAmount, address requester);
    event DripAmountRequestApproved(uint256 newDripAmount, address approver);

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
        maxAllowance = _calculateMinterAllowance();
        lastDripTime = block.timestamp;
    }

    /**
     * @dev Mint new tokens. Only the address with MINTER_ROLE can call this.
     * Must not exceed current minterAllowance.
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(
            amount <= minterAllowance,
            "FractionalAllowanceStablecoin: amount exceeds minter allowance"
        );
        minterAllowance -= amount;
        _mint(to, amount);
    }

    // Function to request a drip amount update
    function requestDripAmountUpdate(uint256 newDripAmount) public onlyRole(MINTER_ROLE) {
        pendingDripAmountRequest = DripAmountRequest({
            newDripAmount: newDripAmount,
            requester: msg.sender,
            isPending: true
        });
        emit DripAmountRequestCreated(newDripAmount, msg.sender);
    }

    // Function to approve the requested drip amount update
    function approveDripAmountUpdate() public onlyRole(GOVERNANCE_ROLE) {
        require(pendingDripAmountRequest.isPending, "No pending request");
        dripAmount = pendingDripAmountRequest.newDripAmount;
        pendingDripAmountRequest.isPending = false;
        emit DripAmountRequestApproved(pendingDripAmountRequest.newDripAmount, msg.sender);
    }

    // External function to apply the drip
    function applyDrip() external onlyRole(MINTER_ROLE) {
        uint256 currentTime = block.timestamp;
        if (currentTime > lastDripTime) {
            uint256 timeElapsed = currentTime - lastDripTime;
            uint256 topUpAmount = (timeElapsed / dripInterval) * dripAmount;
            maxAllowance = _calculateMinterAllowance();
            if (minterAllowance + topUpAmount > maxAllowance) {
                topUpAmount = maxAllowance - minterAllowance;
            }
            minterAllowance += topUpAmount;
            lastDripTime = currentTime;
        }
    }

    /**
     * @dev Internal function to calculate allowance based on fractionInBps and current total supply.
     */
    function _calculateMinterAllowance() internal view returns (uint256) {
        uint256 total = totalSupply();
        return (total * fractionInBps) / 10000;
    }

    // Function to replenish minter allowance
    function replenishMinterAllowance() external onlyRole(GOVERNANCE_ROLE) {
        minterAllowance = _calculateMinterAllowance();
    }
}