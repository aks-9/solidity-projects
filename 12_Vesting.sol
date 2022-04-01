//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 < 0.9.0;

contract Vesting{

    struct Founder {
        uint amount;
        uint maturity;
        bool paid;

    }

    mapping(address => Founder) public founders;
    address public admin;

    event addFounderEvent (address _founderEvent, uint _timeToMaturityEvent, string messageEvent);

    constructor(){
        admin = msg.sender;

    }

    function addFounder(address _founder, uint _timeToMaturity) external payable {
        require(_founder == admin, "Only admin can add a founder.");
        require(founders[_founder].amount == 0 ,"Founder already exists");

        founders[_founder] = Founder(msg.value, block.timestamp + _timeToMaturity, false);

        emit addFounderEvent(_founder, _timeToMaturity, "Founder added.");

    }

    function withdraw() external returns(bool) {
        Founder storage founder = founders[msg.sender];

        require(founder.maturity <= block.timestamp, "Vesting period hasn't ended");
        require(founder.amount > 0);
        require(founder.paid == false," Already paid.");

        founder.paid = true;
        payable(msg.sender).transfer(founder.amount);

        return true;
        
    }

}
