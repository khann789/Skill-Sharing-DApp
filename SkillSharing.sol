// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SkillSharing {

    struct Skill {
        address payable provider;
        string description;
        uint price; // Price in Wei
        uint expirationTime; // Expiration timestamp
        uint maxBuyers;
        uint buyersCount;
        bool active; // Skill availability
    }

    struct Rating {
        uint sum;
        uint count;
    }

    mapping(uint => Skill) public skills; // skillId => Skill
    mapping(uint => Rating) public ratings; // skillId => Rating
    mapping(address => uint) public balances; // address => balance of accumulated earnings
    uint public skillCounter; // Incremental skill ID counter

    event SkillListed(uint skillId, address provider, string description, uint price, uint maxBuyers, uint expirationTime);
    event SkillPurchased(uint skillId, address buyer);
    event SkillRated(uint skillId, uint rating, address buyer);
    event FundsWithdrawn(address provider, uint amount);
    event SkillDeactivated(uint skillId);

    // List a new skill/service
    function listSkill(string memory _description, uint _price, uint _expirationTime, uint _maxBuyers) public {
        skillCounter++;
        uint skillId = skillCounter;

        skills[skillId] = Skill({
            provider: payable(msg.sender),
            description: _description,
            price: _price,
            expirationTime: block.timestamp + _expirationTime,
            maxBuyers: _maxBuyers,
            buyersCount: 0,
            active: true
        });

        emit SkillListed(skillId, msg.sender, _description, _price, _maxBuyers, _expirationTime);
    }

    // Purchase a skill/service
    function purchaseSkill(uint _skillId) public payable {
        Skill storage skill = skills[_skillId];
        
        // Check if the skill is active and valid
        require(skill.active, "Skill is no longer available.");
        require(skill.expirationTime > block.timestamp, "Skill has expired.");
        require(skill.buyersCount < skill.maxBuyers, "Maximum number of buyers reached.");
        require(msg.value == skill.price, "Incorrect Ether value.");

        // Transfer payment to the provider
        skill.provider.transfer(msg.value);
        
        // Increment the buyer count
        skill.buyersCount++;

        // Record the purchase
        balances[skill.provider] += msg.value;

        emit SkillPurchased(_skillId, msg.sender);
    }

    // Rate a purchased skill/service (1-5 stars)
    function rateSkill(uint _skillId, uint _rating) public {
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5.");

        Rating storage skillRating = ratings[_skillId];
        skillRating.sum += _rating;
        skillRating.count++;

        emit SkillRated(_skillId, _rating, msg.sender);
    }

    // Withdraw earned funds by the provider
    function withdrawFunds() public {
        uint amount = balances[msg.sender];
        require(amount > 0, "No funds to withdraw.");

        // Reset the provider's balance
        balances[msg.sender] = 0;

        // Transfer the funds
        payable(msg.sender).transfer(amount);

        emit FundsWithdrawn(msg.sender, amount);
    }

    // Deactivate a skill (due to expiration or manually)
    function deactivateSkill(uint _skillId) public {
        Skill storage skill = skills[_skillId];

        // Only the provider can deactivate the skill
        require(msg.sender == skill.provider, "Only the provider can deactivate the skill.");

        // Deactivate the skill
        skill.active = false;

        emit SkillDeactivated(_skillId);
    }

    // Get the rating for a skill
    function getSkillRating(uint _skillId) public view returns (uint averageRating) {
        Rating storage skillRating = ratings[_skillId];
        if (skillRating.count == 0) {
            return 0; // No ratings yet
        }
        return skillRating.sum / skillRating.count;
    }

    // Get skill details
    function getSkillDetails(uint _skillId) public view returns (address provider, string memory description, uint price, uint expirationTime, uint buyersCount, uint maxBuyers, bool active) {
        Skill storage skill = skills[_skillId];
        return (skill.provider, skill.description, skill.price, skill.expirationTime, skill.buyersCount, skill.maxBuyers, skill.active);
    }
}