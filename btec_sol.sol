// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearnToEarnStreaming {
    // State variables
    address public owner;
    uint256 public totalRewardsDistributed;

    struct User {
        uint256 earnedTokens;
        bool registered;
    }

    mapping(address => User) public users;
    
    struct Content {
        string title;
        string description;
        address creator;
        uint256 rewardPerView;
        uint256 views;
    }

    Content[] public contents;

    event UserRegistered(address indexed user);
    event ContentAdded(uint256 indexed contentId, address indexed creator);
    event ContentViewed(uint256 indexed contentId, address indexed viewer, uint256 reward);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    modifier onlyRegistered() {
        require(users[msg.sender].registered, "User not registered");
        _;
    }

    function registerUser() external {
        require(!users[msg.sender].registered, "User already registered");
        users[msg.sender] = User({
            earnedTokens: 0,
            registered: true
        });
        emit UserRegistered(msg.sender);
    }

    function addContent(string memory _title, string memory _description, uint256 _rewardPerView) external onlyRegistered {
        contents.push(Content({
            title: _title,
            description: _description,
            creator: msg.sender,
            rewardPerView: _rewardPerView,
            views: 0
        }));
        emit ContentAdded(contents.length - 1, msg.sender);
    }

    function viewContent(uint256 _contentId) external onlyRegistered {
        require(_contentId < contents.length, "Content does not exist");
        Content storage content = contents[_contentId];
        content.views++;

        users[msg.sender].earnedTokens += content.rewardPerView;
        totalRewardsDistributed += content.rewardPerView;

        emit ContentViewed(_contentId, msg.sender, content.rewardPerView);
    }

    function getUserTokens() external view onlyRegistered returns (uint256) {
        return users[msg.sender].earnedTokens;
    }

    function getContentDetails(uint256 _contentId) external view returns (string memory, string memory, address, uint256, uint256) {
        require(_contentId < contents.length, "Content does not exist");
        Content memory content = contents[_contentId];
        return (content.title, content.description, content.creator, content.rewardPerView, content.views);
    }
}
