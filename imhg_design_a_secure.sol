pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/access/Roles.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

contract IMHGDASC {
    // Role Definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MODELER_ROLE = keccak256("MODELER_ROLE");
    bytes32 public constant DEVELOPER_ROLE = keccak256("DEVELOPER_ROLE");

    // Mapping of chatbot templates
    mapping (address => Template) public templates;
    mapping (address => mapping (address => Template)) public userTemplates;

    // Mapping of chatbot instances
    mapping (address => ChatbotInstance) public chatbots;
    mapping (address => mapping (address => ChatbotInstance)) public userChatbots;

    // Events
    event NewTemplate(address indexed modeler, address templateAddress);
    event NewChatbotInstance(address indexed user, address chatbotInstanceAddress);

    // Struct for chatbot template
    struct Template {
        address modeler;
        string templateName;
        string templateDescription;
        string[] intents;
        string[] entities;
    }

    // Struct for chatbot instance
    struct ChatbotInstance {
        address user;
        address templateAddress;
        string chatbotName;
        string chatbotDescription;
        bool isActive;
    }

    // Modifiers
    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Only admins can perform this action");
        _;
    }

    modifier onlyModeler() {
        require(hasRole(MODELER_ROLE, msg.sender), "Only modelers can perform this action");
        _;
    }

    modifier onlyDeveloper() {
        require(hasRole(DEVELOPER_ROLE, msg.sender), "Only developers can perform this action");
        _;
    }

    // Functions
    function createTemplate(string memory _templateName, string memory _templateDescription, string[] memory _intents, string[] memory _entities) public onlyModeler {
        // Create a new template and add it to the templates mapping
        Template template = Template(msg.sender, _templateName, _templateDescription, _intents, _entities);
        address templateAddress = address(this).templates[template.modeler].push(template) - 1;
        emit NewTemplate(msg.sender, templateAddress);
    }

    function instantiateChatbot(address _templateAddress, string memory _chatbotName, string memory _chatbotDescription) public onlyDeveloper {
        // Create a new chatbot instance and add it to the chatbots mapping
        Template storage template = templates[_templateAddress];
        ChatbotInstance chatbotInstance = ChatbotInstance(msg.sender, _templateAddress, _chatbotName, _chatbotDescription, true);
        address chatbotInstanceAddress = address(this).chatbots[template.modeler].push(chatbotInstance) - 1;
        emit NewChatbotInstance(msg.sender, chatbotInstanceAddress);
    }

    function pauseChatbot(address _chatbotInstanceAddress) public onlyDeveloper {
        // Pause a chatbot instance
        ChatbotInstance storage chatbotInstance = chatbots[_chatbotInstanceAddress];
        chatbotInstance.isActive = false;
    }

    function resumeChatbot(address _chatbotInstanceAddress) public onlyDeveloper {
        // Resume a chatbot instance
        ChatbotInstance storage chatbotInstance = chatbots[_chatbotInstanceAddress];
        chatbotInstance.isActive = true;
    }

    function hasRole(bytes32 role, address account) internal view returns (bool) {
        return Roles.has(role, account);
    }
}