pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import 'hardhat/console.sol';
import './ExampleExternalContract.sol';

contract Staker {
  ExampleExternalContract public exampleExternalContract;

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;
  bool public openForWithdraw = false;

  event Stake(address stakerAddress, uint256 stakeValue);

  constructor(address exampleExternalContractAddress) public {
    exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // TODO: Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake() public payable {
    require(block.timestamp <= deadline, "Deadline is expired.");
    balances[msg.sender] += msg.value;
    emit Stake(msg.sender, msg.value);
  }

  // TODO: After some `deadline` allow anyone to call an `execute()` function
  //  It should call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
  function execute() public notCompleted {
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    } else {
      openForWithdraw = true;
    }
  }

  // TODO: if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw() public notCompleted {
    require(openForWithdraw, "Withdrawals are not open.");
    (bool sent, bytes memory data) = msg.sender.call{value: balances[msg.sender]}("");
    balances[msg.sender] = 0;
    require(sent, "Failed to send Ether");
  }

  // TODO: Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft() public view returns (uint256) {
    if (block.timestamp >= deadline) {
      return 0;
    } else {
      return deadline - block.timestamp;
    }
  }

  // TODO: Add the `receive()` special function that receives eth and calls stake()
  receive() external payable {
    stake();
  }

  modifier notCompleted {
    require(!exampleExternalContract.completed(), "Not Completed");
    _;
  }
}
