// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/FlashLoanReceiverBase.sol";

contract AaveFlashFlashLoan is FlashLoanReceiverBase {
    constructor(ILendingPoolAddressProvider _addressProvider) 
    public FlashLoanReceiverBase(_addressProvider)
    {

    }

    // INPUTS: that we want to borrow and the ammount that we want to boorow
    function testFlashLoan(address asset, uint amount) external {
        uint bal = IERC20(asset).balanceOf(address(this));
        require(bal > amount, "bal <= amount");

        address receiver = address(this);
        uint[] memory assets = new address[](1);
        assets[0] = asset;

        uint[] memory amounts = new uint[](1);
        amounts[0] = amount;
        
        //available modes
        // 0 = no debt, 1 = stable, 2 = variable
        // 0 = pay all loaned
        uint[] memory modes = new uint[](1);
        modes[0] = 0;

        bytes memory onBehalfOf = address(this);

        //extra data to pass abi.encode(...)
        bytes memory params = "";

        uint referralCode = 0;
        // Make the flash loan
        LENDING_POOL.flashLoan(
            //address is the address of the contract that will receive the token that we want to borrow 
            receiver,
            //array of tokens that we want to borrow
            assets,
            //amount of tokens that we want to borrow
            amounts,
            modes,
            //address that receive the debt if mode is 1 or 2 
            onBehalfOf,
            //extra data
            params,
            referralCode
        );


    }

    function executeOperation(
        address[] calldata assets,
        uint[] calldata amounts,
        //fees that we need to pay back for borrowing
        uint[] calldata premiums,
        //address that executed the flash loan
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // usage(arbitrage, liquidation, exploits, etc...)
        // abi.decode(params) to decode extra params
        for(uint i = 0; i < assets.length; i++){
            emit Log("borrowes", ammounts[i]);
            emit Log("fee", premiums[i]);

            uint amountOwing = amounts[i].add(premiums[i]);
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }
        // repay Aave
        return true;
    }
}