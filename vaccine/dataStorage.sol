pragma solidity >=0.4.0 <0.6.0;
pragma experimental ABIEncoderV2;

contract Vaccine {
    address public minter;

    uint256 public recoderAmount;
    
    string[] public recoderKeys;  

    mapping (string => string) private values;

    constructor() public {
        minter = msg.sender;
    }

    function setValue(string memory key, string memory newValue) public onlyOwner {
        require(bytes(key).length != 0,"invalid key");
        require(bytes(newValue).length != 0,"invalid value");

        if(bytes(values[key]).length==0){
            recoderAmount++;
        }
        
        recoderKeys.push(key);
        
        values[key] = newValue;
    }

    function batchSetValues(string[] memory keys,string[] memory newValues) public onlyOwner {
        
        require(keys.length == newValues.length,"invalid keys and values");
        
        for (uint i = 0;i<keys.length;i++) {
            
            setValue(keys[i],newValues[i]);
        }
    }

    function getValue(string memory key) public view returns (string memory){ 
        
        return values[key];
    }

    function batchGetValues(string[] memory keys) public view returns (string[] memory){
        
        string[] memory list = new string[](keys.length);
        for (uint i = 0;i<keys.length;i++) {
            list[i] = values[keys[i]];
        }
        return list;
    }
    
    modifier onlyOwner {
        require(msg.sender == minter,"No Permission");
        _;
    }
}