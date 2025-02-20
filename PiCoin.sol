// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PiCoin is ERC20 {
    address public immutable treasuryWallet;

    constructor(address _treasuryWallet) ERC20("PiCoin", "PI") {
        require(_treasuryWallet != address(0), "Invalid treasury wallet");
        treasuryWallet = _treasuryWallet;

        // Ensure total supply includes decimals
        uint256 totalSupply = 314159265358979323 * (10 ** decimals());
        _mint(address(this), totalSupply);
    }

    // Automatically receive BNB and exchange for PiCoin
    receive() external payable {
        require(msg.value > 0, "BNB amount must be greater than zero");

        uint256 contractBalance = balanceOf(address(this));
        require(contractBalance > 0, "No PiCoin available for exchange");

        // Correct exchange calculation: BNB% of remaining PiCoin supply
        uint256 amountToTransfer = (contractBalance * msg.value) / 100 ether;
        require(amountToTransfer > 0, "Not enough PiCoin available for exchange");

        // Transfer PiCoin to sender
        _transfer(address(this), msg.sender, amountToTransfer);

        // Send received BNB to treasury wallet
        payable(treasuryWallet).transfer(msg.value);
    }
}
