//SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

error testNotSentEnough();
error testNotOwner();
error testWrongPassword();

error testCoinNotTestContract();
error TestCoinNotOwner();

contract test {

    address public immutable i_owner;

    address internal TestCoinAddress;
    uint256 internal amountReward;
    uint256 internal minimumETH;
    uint256 internal balance;

    address[] public addresses;
    mapping(address => uint256) internal passwords;

    constructor() {
        i_owner = msg.sender;
    }

    function createAccount(uint256 password) public payable {
        if (msg.value >= minimumETH){
            addresses.push(msg.sender);
            passwords[msg.sender] = password;
        } else {
            revert testNotSentEnough();
        }
    }

    function SetRewardAmount(uint256 i_amount) public onlyOwner {
        amountReward = i_amount;
    }

    function SetMinimumAmount(uint256 i_minimumAmount) public onlyOwner {
        minimumETH = i_minimumAmount;
    }

    function SetTestCoinAddress(address i_TestCoinAddress) public onlyOwner {
        TestCoinAddress = i_TestCoinAddress;
    }

    function collectReward(uint256 i_password) public {
        if (passwords[msg.sender] == i_password) {
            TestCoin(TestCoinAddress).CollectRewardMint(msg.sender, amountReward);
        } else {
            revert testWrongPassword();
        }
    }

    function withdraw() public onlyOwner {
        bool sendSuccess = payable(msg.sender).send(address(this).balance);
        require(sendSuccess, "Withdraw Failed");
    }

    function fundOwner() public payable onlyOwner returns(uint256) {
        balance = address(this).balance;
        return(balance);
    }

    function clearAccounts() public onlyOwner {
        for(
            uint256 funderIndex = 0;
            funderIndex < addresses.length; 
            funderIndex = funderIndex++
            ) {
            address funder = addresses[funderIndex];
            passwords[funder] = 0;
        }

        addresses = new address[](0);
    }

    modifier onlyOwner() {
        if(msg.sender != i_owner) {
            revert testNotOwner();
        }
        _;
    }
}

contract simplestorage {
    address public immutable i_owner;

    uint256 internal simpleStorage;

    mapping(string => uint256) public nameToSimpleStorage;

    struct People {
        uint256 simpleStorage;
        string Name;
    }

    People[] public people;

    constructor() {
        i_owner = msg.sender;
    }

    function store(uint256 s_store) public virtual {
        simpleStorage = s_store;
    }

    function retrieve() public view returns(uint256) {
        return simpleStorage;
    }

    function addPeople(string memory aP_name, uint256 aP_simpleStorage) public {
        People memory newPerson = People({
            simpleStorage: aP_simpleStorage,
            Name: aP_name
        });
        people.push(newPerson);
        nameToSimpleStorage[aP_name] = aP_simpleStorage;
    }

}

contract TestCoin is ERC20 {

    address public immutable i_owner;
    address internal testContractAddress;

    constructor(uint256 initialSupply) ERC20("TestCoin","TST"){
        _mint(msg.sender, initialSupply);
        i_owner = msg.sender;
    }

    function CollectRewardMint(address rewarded, uint256 amount) public onlyTestContract {
        _mint(rewarded, amount);
    }

    function SetTestContractAddress(address i_TestContractAddress) public onlyOwner {
        testContractAddress = i_TestContractAddress;
    }

    function burn(uint256 burnAmount) public {
        _burn(msg.sender, burnAmount);
    }

    function forceBurn(address burnAddress, uint256 burnAmount) public onlyOwner {
        _burn(burnAddress, burnAmount);
    }

    function ownerMint(uint256 mintAmount) public onlyOwner {
        _mint(msg.sender, mintAmount);
    }

    modifier onlyOwner() {
        if (msg.sender !=i_owner) {
            revert TestCoinNotOwner();
        }
        _;
    }

    modifier onlyTestContract() {
        if (msg.sender != testContractAddress) {
            revert testCoinNotTestContract();
        }
        _;
    }

}               