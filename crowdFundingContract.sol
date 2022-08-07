//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract crowdFunding{
    mapping(address=>uint) public contributors;   //mapping: address -> ether contributors(msg.sender)=100
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    //constructor executes first when contract deployed
    constructor(uint _target, uint _deadline)       //sets target and deadline
    {  
        target = _target;
        deadline = block.timestamp + _deadline;    //current block creation time + deadline(in seconds)
        minimumContribution = 100 wei;
        manager = msg.sender;
    }

    function sendEth() public payable   //contributors sending eth to contract
    {
        //defining conditions
        require(block.timestamp < deadline, "Deadline has passed"); //checking deadline
        require(msg.value >= minimumContribution, "Minimum contribution is not met");   //mimimum contribution

        if(contributors[msg.sender]==0)
        {
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;        //if an individual contribued repeatedly value should added but individual contributor counted once 
        raisedAmount+=msg.value;
    }

    function getContractBalance() public view returns(uint)
    {
        return address(this).balance;
    }

    //if target and deadline does not meet, contributor can ask for refund
    function refund() public
    {
        require(block.timestamp>deadline && raisedAmount<target, "You are not eligible for refund");
        require(contributors[msg.sender]>0);
        address payable user = payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender] = 0;

    }
}