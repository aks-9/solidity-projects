// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 < 0.9.0;

contract Lottery
{
    address public manager;
    address payable[] public participants; //a dynamic array to store addresses of all participants

    constructor()
    {
        manager = msg.sender; // The address that deploys this contract will be stored in this 'manager' variable, and this address will control this contract. Using global variable 'msg.sender'.
    }

    //receive() is a special function used to transfer ether to the contract.Can only be used once.Always used with 'external' and 'payable' keywords.No arguments can be passed.
    receive() external payable
    {
        //We will use require statement, which is like if-else statement but shorter and cleaner.
        require(msg.value == 1 ether); // if the amount of transaction is equal to 1 ether, only then the next statment will execute. 'msg.value' is used to retrieve the amount transacted by the participant.

        participants.push(payable(msg.sender)); //Registering the address of the participants in an array using push() method. The addresses of each participant will be retrieved using 'msg.sender' and stored in the 'participants' array, but we have to make it 'payable' because we have to send ether to one of these addresses.
    }

    function getBalance() view public returns(uint)
    {
        require(msg.sender == manager); //This means that ONLY manager will be able to see the balance. If the address in 'msg.sender' is of manager, ONLY then the next statement will execute.
        return address(this).balance; //Returns the balance from the current contract.
    }

    //We've to use a different address as a particpant, to send ether to this contract. We will use the Transact button in Remix IDE for it, under our deployed contract, after putting a value, let's say 1 and selecting Ether as unit.

    //Creating a function to get a random number.We'll use this random number to get the index of the winner in the participants array.
    function random() internal view returns(uint)
    {
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length))); //keccak256 is a hashing algorithm, not to be used professionally as it is deterministic. It will return a 64 hexadecimal number, to convert it into a decimal number we will enclose it in uint(); function.
    }

    function selectWinnner() public
    {
        require(msg.sender == manager);
        require(participants.length >= 3);

        address payable winner; // creating a variable called winner of type 'address' and making it payable so that we can transfer ether to this variable.
        uint r = random();
        uint index = r % participants.length; // % operator gives us the remainder, which is always less than the diviser(participants.length). So we'll always get a number less than the length of the array, which will also always be an index of the array.
        winner = participants[index];
        winner.transfer(getBalance()); //Calling getBalance(); withing winner.transfer(); will transfer the contract balance to the address within the winner variable.

        //Now we'll reset the lottery by deleting all the addresses in the participants array. We'll do this by setting the length of the array to zero.
        participants = new address payable[](0); //This will set the new address of the array to 0 and also make it 'payable' for further rounds of lottery.
    }






}
