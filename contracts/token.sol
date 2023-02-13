// pragma solidity ^0.8.0;
pragma solidity >=0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract ISBToken is ERC20("ISBToken", "ISB"), Ownable {

constructor(){
    _mint(msg.sender, 1000000 * 10**18);
}

function mintFifty(address  toAddress) public  onlyOwner {
    _mint(toAddress, 50 * 10**18);
}

function transferToken(address payable toAddress, uint amount) public payable onlyOwner{
    // approve(address(this), amount);
    uint256 val = amount * 10**18;
    // this.transfer(toAddress, val);
    transfer(toAddress, val);
}

function burnToken(address burnAddr) public onlyOwner{
    _burn(burnAddr, balanceOf(burnAddr));
}

}
