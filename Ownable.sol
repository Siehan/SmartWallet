/* Metadata of "smartwallet" was published successfully.
contracts/Ownable.sol
contracts/SmartWallet.sol
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Ownable {
    address private _owner;

    constructor(address owner_) {
        _owner = owner_;
    }

    modifier onlyOwner() {
        require(
            msg.sender == _owner,
            "Ownable: Only owner can call this function"
        );
        _;
    }

    function owner() public view returns (address) {
        return _owner;
    }
}
