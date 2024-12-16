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
    }

    /**
     * @dev Mint new tokens. Only the address with MINTER_ROLE can call this.
     * Must not exceed current minterAllowance.
     */
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(amount <= minterAllowance, "FractionalAllowanceStablecoin: amount exceeds minter allowance");
        minterAllowance -= amount;
        _mint(to, amount);
    }

    /**
     * @dev Set the fraction of total supply that defines the minter allowance.
     * This function can only be called by governance. Once changed, `replenishMinterAllowance()`
     * should be called to update the allowance based on the new fraction.
     */
    function setMinterFraction(uint256 newFractionInBps) external onlyRole(GOVERNANCE_ROLE) {
        require(newFractionInBps <= 10000, "FractionalAllowanceStablecoin: fraction cannot exceed 100%");
        fractionInBps = newFractionInBps;
        // Note: We do not automatically replenish allowance to prevent immediate issues.
        // Governance can decide the right moment to call `replenishMinterAllowance()`.
    }

    /**
     * @dev Recalculate the minter’s allowance based on the current total supply and fraction.
     * Can only be called by governance.
     */
    function replenishMinterAllowance() external onlyRole(GOVERNANCE_ROLE) {
        minterAllowance = _calculateMinterAllowance();
    }

    /**
     * @dev Internal function to calculate allowance based on fractionInBps and current total supply.
     */
    function _calculateMinterAllowance() internal view returns (uint256) {
        uint256 total = totalSupply();
        return (total * fractionInBps) / 10000;
    }
}
