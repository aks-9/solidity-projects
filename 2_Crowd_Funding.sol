//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{

    //State variables
    mapping(address=>uint) public contributors; 
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    constructor(uint _target,uint _deadline)
    {
        target = _target;
        deadline = block.timestamp + _deadline; 
        minimumContribution = 100 wei;
        manager = msg.sender;
    }      

    //FOR CONTRIBUTORS

    //For contributors to send eth.
    function sendEth() public payable{
        require(block.timestamp < deadline,"Deadline has passed"); 
        require(msg.value >=minimumContribution,"Minimum Contribution is not met");

        if(contributors[msg.sender]==0) 
        {
            noOfContributors++; 
        }
        contributors[msg.sender]+=msg.value;         
        raisedAmount+=msg.value;
    }

    function getContractBalance() public view returns(uint)
    {
        return address(this).balance;
    }

    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"You are not eligible for refund");
        require(contributors[msg.sender] > 0); 
        address payable user = payable(msg.sender); 
        user.transfer(contributors[msg.sender]); 
        contributors[msg.sender]=0; 
    }


    //FOR THE MANAGER

    struct Request
    {
        string description; 
        address payable recipient; 
        uint value; 
        bool isCompleted; 
        uint noOfVoters; 
        mapping(address=>bool) voters; 
    }
    
    mapping(uint=>Request) public allRequests; 
    uint public numRequests; 

    modifier onlyManger(){
        require(msg.sender==manager,"Only manager can call this function");
        _;
    }

    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManger
    {
        Request storage newRequest = allRequests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value;
        newRequest.isCompleted = false;
        newRequest.noOfVoters = 0;
    }

    //FOR VOTING
    function voteRequest(uint _requestNo) public
    {
        require(contributors[msg.sender] > 0 ,"You must be contributor");
        Request storage thisRequest = allRequests[_requestNo]; 
        require(thisRequest.voters[msg.sender] == false,"You have already voted");
        thisRequest.voters[msg.sender] = true; 
        thisRequest.noOfVoters++; 
    }

    
    function makePayment(uint _requestNo) public onlyManger
    {
        require(raisedAmount >= target);
        Request storage thisRequest = allRequests[_requestNo];
        require(thisRequest.isCompleted == false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support"); 
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.isCompleted = true;
    }
}
