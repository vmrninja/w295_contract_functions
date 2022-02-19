// SPDX-License-Identifier: GPL-3.0
pragma solidity = 0.8.7;

contract Escrow {
    struct Sellers_table {
        uint amount;
        uint criteria;
        uint buyerRetract;
        bool paid;
    }

    mapping(address => Sellers_table) public sellers;
    address public buyer;

    constructor() {
        buyer = msg.sender;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, 'only buyer can take this action');
        _;
    }

    function addSeller(address seller, uint timeToCriteria) external payable onlyBuyer {
        require(sellers[msg.sender].amount == 0, 'seller already exist');
        require(msg.value > 0, 'price must be above zero');
        sellers[seller] = Sellers_table(msg.value, block.timestamp + timeToCriteria, block.timestamp + (3 * timeToCriteria), false);
    }

    function payout() external {
        Sellers_table storage seller = sellers[msg.sender];
        require(seller.criteria <= block.timestamp, 'criteria not met');
        require(seller.amount > 0, 'only the proper seller can be paid');
        require(seller.paid == false, 'seller already paid');
        seller.paid = true;
        payable(msg.sender).transfer(seller.amount);
    }

    function buyerRetract(address sellerRetract) external onlyBuyer {
        Sellers_table storage seller = sellers[sellerRetract];
        require(seller.paid == false, 'seller already paid');
        require(seller.buyerRetract <= block.timestamp, 'buyer cannot retract yet');
        seller.paid = false;
        payable(buyer).transfer(seller.amount);
    }
}
