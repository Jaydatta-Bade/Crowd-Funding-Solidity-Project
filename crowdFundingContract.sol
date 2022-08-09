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

    struct Request  //manager requests funds from smart contract
    {
        string description;     //for what purpose funds needed
        address payable recipient;    //fund recipient address
        uint value; //how much funds needed
        bool completed;  //for contributors voting
        uint noOfVoters;
        mapping(address=>bool) voters;  //mapping linked to voters address
    }
    mapping(uint=>Request) public requests;     //multiple requests can be received
    uint public numRequests;

    //constructor executes first when contract deployed
    //sets target and deadline
    constructor(uint _target, uint _deadline)
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

    //only manager can make requests
    modifier onlyManager()
    {
        require(msg.sender==manager,"Only Manager can call this");
        _;
    }

    //requst for funds from smart contract
    function createRequsts(string memory _description, address payable _recipient, uint _value) public onlyManager
    {
        Request storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description=_description;
        newRequest.recipient=_recipient;
        newRequest.value=_value;
        newRequest.completed=false;
        newRequest.noOfVoters=0;
    }

    //fn for voting
    function voteRequest(uint _requestNo) public        
    {
        require(contributors[msg.sender]>0,"You must be a contributor");
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.voters[msg.sender]==false,"You have already voted");
        thisRequest.voters[msg.sender]=true;
        thisRequest.noOfVoters++;
    }

    //fn for making payment
    function makePayment(uint _requestNo) public onlyManager
    {
        require(raisedAmount>=target);
        Request storage thisRequest=requests[_requestNo];
        require(thisRequest.completed==false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support");
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed=true;
    }

}