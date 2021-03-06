// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.4;

import "./Roles.sol";

contract DistributerRole {
	using Roles for Roles.Role;

	event DistributerAdded(address indexed account);
	event DistributerRemoved(address indexed account);

	Roles.Role private distributers;

	constructor() {
		_addDistributer(msg.sender);
	}

	// Checks to see if msg.sender has the appropriate role
	modifier onlyDistributer() {
		require(isDistributer(msg.sender));
		_;
	}

	// Check if account is an Distributer account
	function isDistributer(address account) public view returns (bool) {
		return distributers.has(account);
	}

	// Make account Distributer
	function addDistributer(address account) public onlyDistributer {
		_addDistributer(account);
	}

	// Remove Distributer role from account
	function renounceDistributer() public {
		_removeDistributer(msg.sender);
	}

	// Internal Functions

	function _addDistributer(address account) internal {
		distributers.add(account);
		emit DistributerAdded(account);
	}

	function _removeDistributer(address account) internal {
		distributers.remove(account);
		emit DistributerRemoved(account);
	}
}