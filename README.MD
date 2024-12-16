# Fractional Allowance Stabletoken (FAST)

## Overview

Fractional Allowance Stablecoin (FAST) is an ERC20 token with role-based access control, allowing for fractional minting allowances. The contract leverages OpenZeppelin's libraries for secure and robust implementation. The primary features include role-based minting permissions and the ability to set fractional minting allowances.

## Features

- **Role-Based Access Control**: Utilizes OpenZeppelin's `AccessControl` to manage roles such as `DEFAULT_ADMIN_ROLE`, `GOVERNANCE_ROLE`, and `MINTER_ROLE`.
- **Fractional Minting Allowance**: Allows the minter to mint tokens up to a specified fraction of the total supply.
- **Governance Control**: Only addresses with the `GOVERNANCE_ROLE` can update the minting allowance basis points or replenish mint allowance for the `MINTER_ROLE`.

## Benefits
The **Fractional Allowance** approach directly limits the downside risk from an attack or unauhorized minting from a malicious insider by setting the minter allowace to a small fraction of total token supply. 

## Contract Details

### Roles

- **DEFAULT_ADMIN_ROLE**: The default admin role, typically assigned to the deployer.
- **GOVERNANCE_ROLE**: Role responsible for governance actions, such as updating the minting allowance.
- **MINTER_ROLE**: Role allowed to mint new tokens within the specified allowance.

### Functions

- **mint**: Allows the minter to mint new tokens within the allowed limit.
- **setMinterFraction**: Allows governance to set the fraction of the total supply that defines the minter allowance.
- **replenishMinterAllowance**: Recalculates the minter’s allowance based on the current total supply and fraction.

## Installation

1. **Clone the repository**:
   ```sh
   git clone git@github.com:fang10000/FAST.git
   cd FAST