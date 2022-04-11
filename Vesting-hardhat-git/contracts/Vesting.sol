//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vesting {    
    
    using SafeERC20 for IERC20; 


    /// STATE VARIABLES

    address public vestingOwner;

    uint public mentor = 10; //in percentage 
    uint public advisor = 5; //in percentage     
    // uint partner = 0;  

    uint public cliffTime = 120 seconds;
    uint public timePeriod = block.timestamp + 600 seconds;

    uint public cliffTimeNew;
    uint public startTimeNew;
    uint public timePeriodNew;

    struct roles{        
        uint partnerAmount;
        uint advisorAmount;
        uint mentorAmount;        
        address vestingOwner;
        address partner;
        address advisor;
        address mentor;        
        bool canMentorClaim;
        bool canAdvisorClaim;
        bool hasMentorClaimed;
        bool hasAdvisorClaimed;
    }

    mapping (address => roles) public allRoles;
    mapping (address => uint) private released;     

     constructor (          
         address _mentor, 
         address _advisor, 
         address _partner,
         uint startTime         
         ) {        

        require(_mentor != address(0), "Mentor can't be a zero address");
        require(_advisor != address(0), "Advisor can't be a zero address");
        require(cliffTime <= timePeriod, "Vesting Cliff time is more than Vesting Duration");
        require(timePeriod > 0, "Vesting Duration must be greater than zero");
        require(startTime + timePeriod > block.timestamp, "Invalid Vesting time period");

        vestingOwner = msg.sender;

        allRoles[vestingOwner].vestingOwner = vestingOwner;        
        allRoles[vestingOwner].advisor = _advisor;
        allRoles[vestingOwner].mentor = _mentor;
        allRoles[vestingOwner].partner = _partner;
        
        startTimeNew = startTime;
        cliffTimeNew = startTime + cliffTime;        
        timePeriodNew = timePeriod;
        
        
        
    }


    /// GETTER FUNCTIONS

    function getAdvisorAddress() public view returns (address) {
        return allRoles[vestingOwner].advisor;
    }
    
    function getMentorAddress() public view returns (address) {
        return allRoles[vestingOwner].mentor;
    }    

    function getPartnerAddress() public view returns (address) {
        return allRoles[vestingOwner].partner;
    }

    function getReleased(address tokenAddress) public view returns (uint) {
        return released[tokenAddress];
    }

    function getClaimStatusMentor() public view returns(bool){
        require(allRoles[vestingOwner].mentor == msg.sender, "You are not mentor");
        return allRoles[vestingOwner].canMentorClaim;
    }

    function getClaimStatusAdvisor() public view returns(bool){
        require(allRoles[vestingOwner].advisor == msg.sender, "You are not advisor");
        return allRoles[vestingOwner].canAdvisorClaim;
    }

    function getContractBalance(IERC20 token) public view returns(uint){
        return token.balanceOf(address(this));
    }

    function vested(IERC20 token) public view returns (uint256) {
        require(block.timestamp < timePeriodNew,"the vesting time period is over");
        return getVestedAmount(token);
    }
        
    function getVestedAmount(IERC20 token) private view returns (uint) {
        
        uint currentBalance = token.balanceOf(address(this));
        uint totalBalance = currentBalance + released[address(token)];

        if (block.timestamp < cliffTimeNew) {
            return 0;
        } else if (block.timestamp >= startTimeNew + timePeriodNew) {
            return totalBalance;
        } else {
            return totalBalance * (block.timestamp - startTimeNew) / timePeriodNew;
        }
    }

    function getMentorAmount() public view returns (uint256) {
        return allRoles[vestingOwner].mentorAmount;
    }

    function getAdvisorAmount() public view returns (uint256) {
        return allRoles[vestingOwner].advisorAmount;
    }


    /// SETTER FUNCTIONS    

    // Transfers the vested tokens to vestingOwner upon input of a vested token's address.
    function release (IERC20 token) public {

        require(msg.sender == vestingOwner, "Only Vesting Owner allowed to release tokens");

        uint unreleased = getVestedAmount(token) - released[address(token)];

        allRoles[vestingOwner].mentorAmount = unreleased * mentor / 100;
        allRoles[vestingOwner].advisorAmount = unreleased * advisor / 100;

        require(block.timestamp < timePeriodNew, "Vesting period is over!");
        require(block.timestamp > startTimeNew, "Vesting period has not yet started!");
        require(unreleased > 0, "No tokens are unrealeased");

        released[address(token)] = released[address(token)] + unreleased;
        
        allRoles[vestingOwner].canMentorClaim = true;
        allRoles[vestingOwner].canAdvisorClaim = true;
        allRoles[vestingOwner].hasMentorClaimed = false;
        allRoles[vestingOwner].hasAdvisorClaimed = false;
    }


    /// CLAIM FUNCTIONS

    function claimMentor(IERC20 token) public {
        require(!allRoles[vestingOwner].hasMentorClaimed, "Reward already claimed!");
        require(allRoles[vestingOwner].canMentorClaim, "Mentor cannot claim their reward");
        require(allRoles[vestingOwner].mentor == msg.sender, "You are not a mentor");

        allRoles[vestingOwner].hasMentorClaimed = true;

        token.safeTransfer(allRoles[vestingOwner].mentor, allRoles[vestingOwner].mentorAmount);
    }

    function claimAdvisor(IERC20 token) public {
        require(allRoles[vestingOwner].hasAdvisorClaimed == false, "Reward already claimed!");
        require(allRoles[vestingOwner].canAdvisorClaim == true, "Advisor cannot claim their reward");
        require(allRoles[vestingOwner].advisor == msg.sender, "You are not an advisor");

        allRoles[vestingOwner].hasAdvisorClaimed = true;
        
        token.safeTransfer(allRoles[vestingOwner].advisor, allRoles[vestingOwner].advisorAmount);
    }

    


}













