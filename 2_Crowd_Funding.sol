//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;

contract CrowdFunding{

    //Defining variables
    mapping(address=>uint) public contributors; //this mapping will tell how much amount given by which address.
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    constructor(uint _target,uint _deadline)
    {
        target = _target;
        deadline = block.timestamp + _deadline; //10sec + 3600sec (60*60)
        minimumContribution = 100 wei;
        manager = msg.sender;
    }      

    //PART 1- FOR CONTRIBUTORS

    //For contributors to send eth.
    function sendEth() public payable{
        require(block.timestamp < deadline,"Deadline has passed"); //Error message is attached in "".
        require(msg.value >=minimumContribution,"Minimum Contribution is not met");

        if(contributors[msg.sender]==0) //The mapping called 'contributors' will have an 'address' that will be in msg.sender. So if the contributor is sending money for the first time, his address will have zero amount in the mapping. If he's contributed earlier as well then it will not be zero. This will not let anyone gain from multiple transactions with small amount in order to get more voting rights.
        {
            noOfContributors++; //increasing it if it's a new contributor.
        }
        contributors[msg.sender]+=msg.value; // contributors[msg.sender] = contributors[msg.sender] + msg.value;

        //contributors[msg.sender] represents the amount sent by a particular address. If he's an older contributor then we simply add its new contribution represented by 'msg.value' to the previous total contribution represented by contributors[msg.sender]
        raisedAmount+=msg.value; // raisedAmount = raisedAmount + msg.value; Updating the total raised amount after every contribution.
    }


    //To read the current balance of the contract.
    function getContractBalance() public view returns(uint)
    {
        return address(this).balance;
    }



    function refund() public{
        require(block.timestamp>deadline && raisedAmount<target,"You are not eligible for refund");
        require(contributors[msg.sender] > 0); //amount contributed must be greater than zero to be a contributor, only then refund can be claimed.
        address payable user = payable(msg.sender); //creating a variable 'user' of datatype 'address, and have to make it explicitly payable to process refund.
        user.transfer(contributors[msg.sender]); //Transfering the ether present in the contributors[msg.sender] to 'user'
        contributors[msg.sender]=0; // setting the amount held by the address of the contributor, in the mapping 'contributors', that is claiming the refund to  zero.

    }


    //PART 2- FOR THE MANAGER

    struct Request //Creating a structure called 'Request'.
    {
        string description; // Reason for withdrawal
        address payable recipient; // address where amount will be withdrawn.
        uint value; // Amount asked for withdrwal by manager.
        bool isCompleted; // Is this request pending for voting or not?
        uint noOfVoters; //How many voted.
        mapping(address=>bool) voters; //Each address to be mapped to either Yes or No.
    }
    
    mapping(uint=>Request) public allRequests; //A mapping to log different kinds of requests eg. business, charity, personal etc. This will have many integers from 0 onwards , each with a unique Request structure. So this mapping will have many structures on its indexes.
    uint public numRequests; //It denotes the index of the mapping 'allRequests'. It's not possible to increment in a mapping like in an array, so numRequests will be used.


    modifier onlyManger(){
        require(msg.sender==manager,"Only manager can call this function");
        _;
    }

    function createRequests(string memory _description,address payable _recipient,uint _value) public onlyManger
    {
        Request storage newRequest = allRequests[numRequests]; // We have used 'storage' keyword here, because whenever we create a structure, and then create a mapping in that structure, then we can't use 'memory' keyword in a function to access that structure.
        // Here we're creating a new variable called 'newRequest' of type 'Request', which is a structure. Then whatever is in allRequests[0] is going into 'newRequest'. So 'newRequest' is able to make changes in the structure 'Request' for zeroth position,i.e. allRequests[0] of the mapping 'allRequests'. 
        
        //In short 'newRequest' will point to a structure 'Request' at the index of 'allRequests' mapping.

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
        Request storage thisRequest = allRequests[_requestNo]; //Creating another structure 'thisRequest' of type 'Request'.
        require(thisRequest.voters[msg.sender] == false,"You have already voted");// Default value of bool is false.
        thisRequest.voters[msg.sender] = true; //As voting is done once.
        thisRequest.noOfVoters++; //incrementing.
    }

    //Checking voting is in favour of a particular request or not, and then transfering money to a particular address.
    function makePayment(uint _requestNo) public onlyManger
    {
        require(raisedAmount >= target);
        Request storage thisRequest = allRequests[_requestNo];
        require(thisRequest.isCompleted == false,"The request has been completed");
        require(thisRequest.noOfVoters > noOfContributors/2,"Majority does not support"); // checking greater than 50% or not.
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.isCompleted = true;
    }
}
