// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract ConsensusLiquidate is ERC20, ERC20Burnable, ERC20Permit {
    constructor(address recipient)
        ERC20("ConsensusLiquidate", "CLQ")
        ERC20Permit("ConsensusLiquidate")
    {
        _mint(recipient, 99999999999999 * 10 ** decimals());
    }
}