// SPDX-License-Identifier: GPL-3.0
pragma solidity = 0.8.7;

contract Escrow {

    // stick to one seller for less complexity of defining types?
    // otherwise too complex to define in YAML... for the time being
    address seller;
    address public buyer;
    
    uint amount;
    uint criteria;
    uint buyerRetract;
    bool paid;

    constructor() {
        buyer = msg.sender;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, 'only buyer can take this action');
        _;
    }
    
    /*
    1 Buyer -> n Sellers
    This function is for a Buyer's controlled contract. It only allows the Buyer who is the owner
    of this contract to add sellers. The Buyer in this case has the option to put several offers
    to different sellers. The Buyer can utilize this function in an on-going contract to consolidate
    all their transactions in a single contract putting bids to multiple sellers. When using this function
    it is required to add another function which permits the Buyer to retract the offer or an automated trigger
    that return the coins to the Buyer to prevent them to be locked in the contract forever.
    */
    
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
