pragma solidity >=0.4.0 <0.5.0;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 */
library SafeMath {
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
       
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
}

/**
 * @title Token
 * @dev API interface for interacting with the ITC Token contract 
 */
interface Token {

  function transfer(address _to, uint256 _value) external;

  function balanceOf(address _owner) external returns (uint256 balance);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol
 */
contract Ownable {
     address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ITCMapping is Ownable{
    
    using SafeMath for uint256;

    //ITC合约
    Token public token;
    
    //ITC和ITG发放比例
    uint ratio = 100;
    
    constructor(address tokenAddress) public{
        
        token = Token(tokenAddress);
    }
    
    /**
    * @dev 接收ETH
    */
    function() payable external{
    }
    
    /**
    * @dev 批量映射ITC和ITG
    */
    function batchTransfer(address[] memory addresses,uint256[] memory values) public payable onlyOwner{
        
        require(addresses.length == values.length,'param error');
        
        uint length = addresses.length;
        for (uint i=0 ; i< length ; i++){
                        
            uint256 itgBalance = SafeMath.div(values[i],ratio);

            require(token.balanceOf(address(this))>values[i],'Insufficient ITC balance');
            require(address(this).balance>itgBalance,'Insufficient ITG balance');
            
            //发放ITC
            token.transfer(addresses[i],values[i]);
            
            //发放ITG
            addresses[i].transfer(itgBalance);
        }
    }
    
    /**
    * @dev 发送剩余ITC至合约拥有人
    */
    function transferITCToOwner() public onlyOwner{
        
        address contractAddress = address(this);
        uint256 balance = token.balanceOf(contractAddress);
        token.transfer(msg.sender,balance);
    }
    
    /**
    * @dev 销毁合约
    */
    function destruct() payable public onlyOwner {
        
        //销毁合约前，先确保合约地址的ITC已经转移完毕 
        address contractAddress = address(this);
        require(token.balanceOf(contractAddress) == 0,'ITC balance is not empty, please transfer ITC first');
        
        selfdestruct(msg.sender); // 销毁合约
    }
}
