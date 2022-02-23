// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;

// Contract generated by The Smart Blocks (TM) www.thesmartblocks.com for client #1
// Options:
// Contract Type: Escrow
// Owner Role: Buyer
// Contract Parties: Limited to 1 Seller and 1 Buyer
// Arbitrator: Yes
// Privilege to add parties: Owner only
// Parties who can retract: Onwer Only (default)
// Criteria to retract: 30 days elapsed time (will use 30secs for demo purposes)
// Criteria for sellers pay: Arbitrator ok
// Criteria to auto-cancel: 60 days elapsed time (will use 60secs for demo purposes)

contract Escrow_client_1a {
    address public buyer;
    address public seller;
    address public arbitrator;
    address public owner;
    uint buyerOffer;
    uint retractCriteria;
    uint autoCancelMet;
    bool contractExecuted;
    bool executionReleased;

// Owner Role: Buyer
// Criteria to auto-cancel: 60 days ellapsed time (will use 60secs for demo purposes)

    constructor() {
        buyer = msg.sender;
        owner = msg.sender;
        contractExecuted = false;
        executionReleased = false;
        autoCancelMet = block.timestamp + 340;
    }

    modifier onlyOwner {
        require(msg.sender == owner, '** Only owner can execute this clause **');
        _;
    }

    modifier activeContract {
        require(autoCancelMet >= block.timestamp, '** This contract has been automatically cancelled **');
        _;
}
// Contract Parties: Limited to 1 Seller and 1 Buyer
// Privilege to add parties: Owner only

    function addSeller(address sellerInput, uint retractInput) external payable onlyOwner activeContract {
        require(seller == address(0), '** Seller has already been added to this contract **');
        require(msg.value > 0, '** Offer price must be above zero **');
        seller = sellerInput;
        buyerOffer = msg.value;
        retractCriteria = block.timestamp + retractInput;
    }

// Arbitrator: Yes

    function addArbitrator(address arbitratorInput) external onlyOwner activeContract {
        require(arbitrator == address(0), '** Arbitrator has already been added to this contract **');
        arbitrator = arbitratorInput;
    }

// Parties who can retract: Owner Only (default)
// Criteria to retract: 30 days ellapsed time (will use 30secs for demo purposes)

    function ownerRetract() external onlyOwner {
        require(contractExecuted == false, '** This contract has already been executed **');
        require(retractCriteria <= block.timestamp, '** Criteria for retract has not been met yet **');
        contractExecuted = true;
        payable(buyer).transfer(buyerOffer);
    }
                                       
// Criteria for sellers pay: Arbitrator ok

    function arbitratorOk(address sellerOked) external activeContract {
        require(arbitrator != address(0), '** Arbitrator has not been added to this contract **');
        require(msg.sender == arbitrator, '** Only Arbitrator can Ok Seller pay **');
        require(seller == sellerOked, '** Seller does not match contract records **');
        executionReleased = true;
    }

// Seller payment clause

    function paySeller() external activeContract {
        require(contractExecuted == false, '** This contract has already been executed **');
        require(msg.sender == seller, '** Only the actual Seller can be paid **');
        require(executionReleased == true, '** Criteria for Seller payment not met **');
        contractExecuted = true;
        payable(msg.sender).transfer(buyerOffer);
    }
}
