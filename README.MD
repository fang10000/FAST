# Fractional Allowance Stabletoken (FAST)

## Overview

Fractional Allowance Stablecoin (FAST) is an ERC20 token with role-based access control, allowing for fractional minting allowances. The contract leverages OpenZeppelin's libraries for secure and robust implementation. The primary features include role-based minting permissions, the ability to set fractional minting allowances and time elapse based allowance refill.

## Features

- **Fractional Minting Allowance**: Allows the minter to mint tokens up to a specified fraction of the token's total supply.
- **Time Elapse Based Allowance Refill**: Layered on top of the fractional minting allowance, partially refill allowance using an `applyDrip()` function to increase the allowance based on time elapsed. The refill amount is determined by `dripAmount` * `timeElapsed` /  `dripInterval`, capped at the max allowance defined by the frational bps and toatal supply.  
- **Role-Based Access Control**: Utilizes OpenZeppelin's `AccessControl` to manage roles such as `DEFAULT_ADMIN_ROLE`, `GOVERNANCE_ROLE`, and `MINTER_ROLE`.
  - Only `GOVERNANCE_ROLE` can request the minting allowance basis points to be updated.
  - Only `DEFAULT_ADMIN_ROLE` can approve basis points update request. 
  - Only `MINTER_ROLE` can request dripAmount to be updated. 
  - Only `GOVERNANCE_ROLE` can approve dripAmount update request. 
  - Only `GOVERNANCE_ROLE` can replenish mint allowance for the `MINTER_ROLE`.
  - Only `MINTER_ROLE` can mint. 

## Benefits
The **Fractional Allowance** approach directly limits the downside financial risk from an attack or unauhorized minting by setting the minter allowance to a small fraction of the total token supply. 
The refill model allow allowance to be slowly refilled before the next manual top-up to the max allowance by the `MINTER_ROLE`, reducing the risk of allowance running out due to spike in minting activities. 

## Contract Details

### Roles

- **DEFAULT_ADMIN_ROLE**: The default admin role, typically assigned to the deployer.
- **GOVERNANCE_ROLE**: Role responsible for governance actions, such as updating the minting allowance.
- **MINTER_ROLE**: Role allowed to mint new tokens within the specified allowance.

### Functions

## Installation

1. **Clone the repository**:
   ```sh
   git clone git@github.com:fang10000/FAST.git
   cd FAST