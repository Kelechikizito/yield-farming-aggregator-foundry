// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


contract SelfDestruct is Ownable {
    event ETHReceived();
    
    constructor() Ownable(payable(msg.sender)){
        
    }

    receive() external payable {
        emit ETHReceived();
    }

     function destroy(address payable recipient) external onlyOwner {
        selfdestruct(recipient); // 💣 sends all ETH to recipient, deletes this contract
    }
}