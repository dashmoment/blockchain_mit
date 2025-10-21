// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract check_account {
    using SafeERC20 for IERC20; // Attach SafeERC20 to IERC20

    IERC20 public clqToken;
    address public clqAddress;

    constructor(address _clqAddress) {
        clqToken = IERC20(_clqAddress); // Explicitly cast to IERC20
        clqAddress = _clqAddress;
    }

    function checkMyCLQBalance() public view returns (uint256) {
        return clqToken.balanceOf(msg.sender);
    }

    function checkMyCLQAllowance() public view returns (uint256) {
        return clqToken.allowance(msg.sender, address(this));
    }

    function show_current_address() public view returns (address){
        return address(this);
    }

    function show_msg_sender() public view returns (address){
        return msg.sender;
    }

    // Fixed: Now uses safeApprove correctly
    function approve(address addr, uint256 amount) public {
        clqToken.approve(addr, amount); // Works!
    }

    function resetAllowance() public {
        clqToken.approve(address(this), 0);
    }
}