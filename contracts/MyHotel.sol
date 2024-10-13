// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MegaERC20} from "./HotelToken.sol";

error MyHotel__NotOwner();

contract MyHotel {
    MegaERC20 public hotelToken; // ERC20 token for hotel ownership
    uint256 public immutable i_totalSupply; // Total supply of hotel tokens
    uint256 public constant LOCK_DURATION = 90 days; // 3 months lock duration
    address public immutable i_owner;

    struct Booking {
        uint256 tokenAmount;
        uint256 lockTimestamp;
    }

    mapping(address => Booking) public bookings;

    event RoomBooked(uint256 indexed amountOfToken, address guest);
    event TokensUnlocked();

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert MyHotel__NotOwner();
        _;
    }

    constructor(address _hotelTokenAddress, uint256 totalSupply) {
        hotelToken = MegaERC20(_hotelTokenAddress);
        i_totalSupply = totalSupply;
        i_owner = msg.sender;
    }

    // Function to check eligibility and book a room
    function bookRoom(uint256 _tokenAmount) external payable {
        uint256 minimumRequiredTokens = (i_totalSupply * 5) / 10000;
        require(_tokenAmount <= (i_totalSupply * 25) / 100, "Must hold at most 25% of the totalsupply to book");
        require(_tokenAmount >= minimumRequiredTokens, "Must hold at least 0.05% of tokens to book");
        require(hotelToken.balanceOf(msg.sender) >= _tokenAmount, "Not enough tokens!");

        // Lock tokens for 6 months
        hotelToken.transferFrom(msg.sender, address(this), _tokenAmount);
        bookings[msg.sender] = Booking({tokenAmount: _tokenAmount, lockTimestamp: block.timestamp});
        emit RoomBooked(_tokenAmount, msg.sender);
    }

    // Function to unlock tokens after 6 months
    function unlockTokens() external {
        Booking memory userBooking = bookings[msg.sender];
        require(userBooking.tokenAmount > 0, "No tokens locked");
        require(block.timestamp >= userBooking.lockTimestamp + LOCK_DURATION, "Tokens are still locked");

        // Transfer tokens back to the user after 6 months
        hotelToken.transfer(msg.sender, userBooking.tokenAmount);
        delete bookings[msg.sender]; // Reset the booking record
        emit TokensUnlocked();
    }

    function withdraw() public onlyOwner {
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    // Check how much time is left until tokens are unlocked
    function getLockTimeRemaining() external view returns (uint256) {
        Booking memory userBooking = bookings[msg.sender];
        if (block.timestamp >= userBooking.lockTimestamp + LOCK_DURATION) {
            return 0;
        } else {
            return (userBooking.lockTimestamp + LOCK_DURATION) - block.timestamp;
        }
    }
}
