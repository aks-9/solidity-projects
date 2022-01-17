// SPDX-License-Identifier: GPL-3.0
pragma solidity >= 0.5.0 < 0.9.0;

contract multiSigWallet
{
    address[] public owners;
    uint numOfApprovalsReq;
    mapping(address=>bool) public isOwner;
    mapping(uint => mapping(address => bool)) public isApproved;

    constructor(address[] memory _owners, uint _numOfApprovalsReq)
    {
        require(_owners.length > 0 ,"Owners required");
        require(_numOfApprovalsReq > 0 && _numOfApprovalsReq <= _owners.length,"Invalid number of approvals required.");

        for(uint i=0; i<=owners.length; i++)
        {
            address owner = _owners[i];
            require(!isOwner[owner],"owner not uinque");
            isOwner[owner] = true;
            owners.push(owner);
        }

        numOfApprovalsReq = _numOfApprovalsReq;    
    }

    struct transactionData{
        uint value;
        address to;
        bytes data;
        bool isExecuted;
        uint numOfApprovals;
    }

    transactionData[] public transactions;

    modifier onlyOwner(){
        require(isOwner[msg.sender],"Not an owner");
        _;
    }
    modifier txExists(uint _txIndex){
        require(_txIndex < transactions.length);
        _;
    }
    modifier notApproved(uint _txIndex){
        require(!isApproved[_txIndex][msg.sender],"Tx not approved");
        _;
    }
    modifier notExecuted(uint _txIndex){
        require(!transactions[_txIndex].isExecuted,"Tx not executed");
        _;
    }

    receive() external payable
    {

    }

    function createTransaction(address _to,  uint _value, bytes memory _data) public onlyOwner 
    {
        // uint txIndex = transactions.length;

        transactions.push(transactionData({
            to: _to,
            value: _value,
            data: _data,
            isExecuted: false,
            numOfApprovals: 0

        }));

    }
    function approveTransaction(uint _txIndex) public txExists(_txIndex) notApproved(_txIndex) notExecuted(_txIndex)
    {        
        isApproved[_txIndex][msg.sender] = true;
        transactionData storage newTransaction = transactions[_txIndex];
        newTransaction.numOfApprovals += 1;

    }
    function executeTransaction(uint _txIndex) public txExists(_txIndex)  notExecuted(_txIndex)
    {
        transactionData storage newTransaction = transactions[_txIndex];
        require(newTransaction.numOfApprovals >= numOfApprovalsReq," Can't execute tx.");
        newTransaction.isExecuted = true;

        (bool success, ) = newTransaction.to.call{value: newTransaction.value}(newTransaction.data);
        require(success,"Tx failed");

    }
    function revokeApproval(uint _txIndex) public txExists(_txIndex)  notExecuted(_txIndex)
    {
        require(isApproved[_txIndex][msg.sender],"Tx not approved");
        isApproved[_txIndex][msg.sender] = false;
        transactionData storage newTransaction = transactions[_txIndex];
        newTransaction.numOfApprovals -= 1;

    }
    
}

