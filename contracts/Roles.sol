// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.4;

library Roles {
	struct Role {
		mapping (address => bool) bearer;
  	}

	// Gives account access to role
  	function add(Role storage role, address account) internal {
		require(account != address(0));
		require(!has(role, account));

		role.bearer[account] = true;
  	}

  	// Remove account access to role 
  	function remove(Role storage role, address account) internal {
		require(account != address(0));
		require(has(role, account));

		role.bearer[account] = false;
  	}

	// Check if account has role
  	function has(Role storage role, address account) internal view returns (bool) {
		require(account != address(0));
		return role.bearer[account];
	}
}