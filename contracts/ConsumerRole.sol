// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.4;

import "./Roles.sol";

contract ConsumerRole {
	using Roles for Roles.Role;

	event ConsumerAdded(address indexed account);
	event ConsumerRemoved(address indexed account);

	Roles.Role private consumers;

	constructor() {
		_addConsumer(msg.sender);
	}

	// Checks to see if msg.sender has the appropriate role
	modifier onlyConsumer() {
		require(isConsumer(msg.sender));
		_;
	}

	// Check if account is an Consumer account
	function isConsumer(address account) public view returns (bool) {
		return consumers.has(account);
	}

	// Make account Consumer
	function addConsumer(address account) public onlyConsumer {
		_addConsumer(account);
	}

	// Remove Consumer role from account
	function renounceConsumer() public {
		_removeConsumer(msg.sender);
	}

	// Internal Functions

	function _addConsumer(address account) internal {
		consumers.add(account);
		emit ConsumerAdded(account);
	}

	function _removeConsumer(address account) internal {
		consumers.remove(account);
		emit ConsumerRemoved(account);
	}
}