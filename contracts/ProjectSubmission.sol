pragma solidity >=0.4.21 <0.6.0;

contract ProjectSubmission {
    // Step 1

    struct University {
        // Step 1
        uint256 balance;
        bool available;
    }

    struct Project {
        // Step 2
        address author;
        address university;
        ProjectStatus status;
        uint256 balance;
    }

    address public owner; // Step 1 (state variable)
    uint256 public ownerBalance; // Step 4 (state variable)
    mapping(address => University) public universities; // Step 1 (state variable)
    mapping(bytes32 => Project) public projects; // Step 2 (state variable)
    enum ProjectStatus {Waiting, Rejected, Approved, Disabled}

    modifier onlyOwner() {
        // Step 1
        require(msg.sender == owner, "unauthorized account");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function registerUniversity(address _account) public onlyOwner {
        // Step 1
        universities[_account].available = true;
    }

    function disableUniversity(address _account) public onlyOwner {
        // Step 1
        universities[_account].available = false;
    }

    function submitProject(bytes32 _projectHash, address _universityAddress)
        public
        payable
    {
        // Step 2 and 4
        require(msg.value >= 1 ether, "unpaid fee");
        require(
            universities[_universityAddress].available,
            "unavailable university"
        );
        projects[_projectHash].author = msg.sender;
        projects[_projectHash].university = _universityAddress;
        projects[_projectHash].status = ProjectStatus.Waiting;
        ownerBalance += msg.value;
    }

    function disableProject(bytes32 _projectHash) public onlyOwner {
        // Step 3
        projects[_projectHash].status = ProjectStatus.Disabled;
    }

    function reviewProject(bytes32 _projectHash, uint8 _status)
        public
        onlyOwner
    {
        // Step 3
        require(
            projects[_projectHash].status == ProjectStatus.Waiting,
            "not in waiting status"
        );
        require(_status == 1 || _status == 2, "status not allowed");
        projects[_projectHash].status = ProjectStatus(_status);
    }

    function donate(bytes32 _projectHash) public payable {
        // Step 4
        require(
            projects[_projectHash].status == ProjectStatus.Approved,
            "not in approved status"
        );
        projects[_projectHash].balance += (msg.value * 70)/100;
        universities[projects[_projectHash].university].balance += (msg.value * 20)/100;
        ownerBalance += (msg.value * 10)/100;
    }

    function withdraw() public {
        // Step 5
        uint256 amount;
        if (msg.sender == owner) {
            amount = ownerBalance;
            ownerBalance = 0;
        } else {
            amount = universities[msg.sender].balance;
            universities[msg.sender].balance = 0;
        }
        msg.sender.transfer(amount);
    }

    function withdraw(bytes32 _projectHash) public {
        // Step 5
        require(msg.sender == projects[_projectHash].author, "not author");
        uint256 amount = projects[_projectHash].balance;
        projects[_projectHash].balance = 0;
        msg.sender.transfer(amount);
    }
}
