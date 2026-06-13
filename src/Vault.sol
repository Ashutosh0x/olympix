// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Vault
/// @notice A simple ETH vault that lets users deposit and withdraw funds.
///         Intentionally includes common vulnerability patterns so Olympix
///         can demonstrate its detection capabilities.
contract Vault {
    mapping(address => uint256) public balances;
    address public owner;

    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    /// @notice Deposit ETH into the vault.
    function deposit() external payable {
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw all deposited ETH.
    /// @dev Vulnerable to reentrancy — external call before state update.
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        // ⚠️ Reentrancy: sending ETH before zeroing balance
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0;
        emit Withdrawal(msg.sender, amount);
    }

    /// @notice Owner-only emergency drain.
    /// @dev Uses tx.origin instead of msg.sender — phishing risk.
    function emergencyDrain() external {
        // ⚠️ tx.origin check — vulnerable to phishing attacks
        require(tx.origin == owner, "Not owner");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Drain failed");
    }

    /// @notice Accept direct ETH transfers.
    /// @dev Contract can receive ETH but only withdraw() can send it out,
    ///      which is controlled — but Olympix may flag locked-ether patterns.
    receive() external payable {
        balances[msg.sender] += msg.value;
    }
}
