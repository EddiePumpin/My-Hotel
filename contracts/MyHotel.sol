// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MegaERC20} from "./HotelToken.sol";

error MyHotel__NotOwner();
error MyHotel__RoomAlreadyBooked();

/**
 * @title Tokenized Hotel Room Booking
 * @dev allow users/guests/travellers to book and stay in a specific room using cryptocurrency(ERC 20)
 */

contract MyHotel {
  MegaERC20 public hotelToken; // ERC20 tokens for hotel ownership
  uint256 public immutable i_totalSupply; // Total supply of hotel tokens
  uint256 public constant LOCK_DURATION = 90 days; // 3 months lock duration
  address public immutable i_owner;

  struct Booking {
    uint256 tokenAmount; // Amount of tokens locked for the booking
    uint256 lockTimestamp; // Timestamp when the tokens were locked
    uint256 roomId; // ID of the booked room
  }

  mapping(address => Booking) public bookings; // Mapping of guest addresses to their bookings
  mapping(uint256 => bool) public roomBooked; // Mapping of roomId to a bool to track booked room status

  event RoomBooked(
    uint256 indexed amountOfToken,
    address guest,
    uint256 roomId
  );
  event TokensUnlocked();

  modifier onlyOwner() {
    if (msg.sender != i_owner) revert MyHotel__NotOwner();
    _;
  }

  /**
   * @dev Constructor to initialize the hotel tokens and total supply
   * @param _hotelTokenAddress Hotel tokens contract address
   * @param totalSupply Hotel tokens total supply
   */
  constructor(address _hotelTokenAddress, uint256 totalSupply) {
    hotelToken = MegaERC20(_hotelTokenAddress);
    i_totalSupply = totalSupply;
    i_owner = msg.sender;
  }

  /**
   * @dev Function to check eligibility and book a room
   * @param _tokenAmount Amount of tokens to be locked
   * @param _roomId ID of the room to be booked
   */
  function bookRoom(uint256 _tokenAmount, uint256 _roomId) external payable {
    require(!roomBooked[_roomId], "Room is already booked");
    uint256 minimumRequiredTokens = (i_totalSupply * 5) / 10000;
    require(
      _tokenAmount <= (i_totalSupply * 25) / 100,
      "Must hold at most 25% of the totalsupply to book"
    );
    require(
      _tokenAmount >= minimumRequiredTokens,
      "Must hold at least 0.05% of tokens to book"
    );
    require(
      hotelToken.balanceOf(msg.sender) >= _tokenAmount,
      "Not enough tokens!"
    );

    // Lock tokens for 3 months
    hotelToken.transferFrom(msg.sender, address(this), _tokenAmount);
    bookings[msg.sender] = Booking({
      tokenAmount: _tokenAmount,
      lockTimestamp: block.timestamp,
      roomId: _roomId // Store the roomId in the booking
    });

    roomBooked[_roomId] = true; // Mark the room as booked
    emit RoomBooked(_tokenAmount, msg.sender, _roomId);
  }

  /**
   * @dev Function to unlock tokens after the specified lock duration
   */
  function unlockTokens() external {
    Booking memory userBooking = bookings[msg.sender];
    require(userBooking.tokenAmount > 0, "No tokens locked");
    require(
      block.timestamp >= userBooking.lockTimestamp + LOCK_DURATION,
      "Tokens are still locked"
    );

    // Transfer tokens back to the user after 3 months
    hotelToken.transfer(msg.sender, userBooking.tokenAmount);

    // Mark the room as available again
    roomBooked[userBooking.roomId] = false;

    delete bookings[msg.sender]; // Reset the booking record
    emit TokensUnlocked();
  }

  /**
   * @dev Function for the owner to withdraw contract balance
   */
  function withdraw() public onlyOwner {
    (bool success, ) = i_owner.call{value: address(this).balance}("");
    require(success);
  }

  /**
   * @dev Function to check how much time left until tokens unlock
   * @return The remaining lock time in seconds
   */
  function getLockTimeRemaining() external view returns (uint256) {
    Booking memory userBooking = bookings[msg.sender];
    if (block.timestamp >= userBooking.lockTimestamp + LOCK_DURATION) {
      return 0;
    } else {
      return (userBooking.lockTimestamp + LOCK_DURATION) - block.timestamp;
    }
  }
}
