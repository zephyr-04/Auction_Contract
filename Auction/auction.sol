// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Auction {
    address public owner;
    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) public bids;

    bool public ended = false;

    event BidPlaced(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyNotEnded() {
        require(!ended, "Auction has already ended");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function placeBid() public payable onlyNotEnded {
        require(msg.value > highestBid, "Bid amount must be higher than the current highest bid");

        if (highestBidder != address(0)) {
            // Refund the previous highest bidder
            payable(highestBidder).transfer(highestBid);
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        bids[msg.sender] += msg.value;

        emit BidPlaced(msg.sender, msg.value);
    }

    function endAuction() public onlyOwner onlyNotEnded {
        require(block.timestamp >= block.timestamp + 7 days, "Auction can only be ended after 7 days");

        ended = true;

        // Transfer the highest bid amount to the owner
        payable(owner).transfer(highestBid);

        emit AuctionEnded(highestBidder, highestBid);
    }

    // Function to retrieve the current highest bid and bidder
    function getHighestBid() public view returns (address, uint256) {
        return (highestBidder, highestBid);
    }
}
