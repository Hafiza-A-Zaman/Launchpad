// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import "./Token.sol";

interface IMint{
  function mint(address _to, uint256 _amount) external;
}
contract Launchpad is Ownable, ReentrancyGuard
{
  constructor() Ownable() ReentrancyGuard()
  {}

  struct ICO
  { 
    address token;
    address owner;
    uint256 tokenPrice;
    uint256 goal;
    uint256 startTime;
    uint256 endTime;
    uint256 currentBal;
    uint256 totalFunds;
  }

  mapping(string => ICO) public projectInfo;

  function createICO(string memory _name, string memory _symbol, uint256 _tokenPrice, uint256 _goal, uint256 _endTime)public
  {
    require(projectInfo[_name].owner == address(0), "Name already exists");
    require(_endTime > block.timestamp && _goal > 0 && _tokenPrice > 0 , "Inavlid params");
    Token _token = new Token(_name , _symbol);
    ICO memory ico = ICO(
      {
        token: address(_token),
        owner: msg.sender,
        tokenPrice: _tokenPrice,
        goal: _goal,
        startTime: block.timestamp,
        endTime: _endTime,
        currentBal: 0,
        totalFunds: 0
      }
    );
    projectInfo[_name] = ico;
  }

  
  function buyToken(string memory _name, uint256 _amount)public payable
  {
    require(msg.value == projectInfo[_name].tokenPrice * _amount, "insufficient funds ");
    require(projectInfo[_name].endTime > block.timestamp, "Sale has ended");
    IMint(projectInfo[_name].token).mint(msg.sender, _amount);
    projectInfo[_name].currentBal += msg.value;
    projectInfo[_name].totalFunds += msg.value;
  }

  function withdrawFunds(string memory _name) public nonReentrant{
    require(block.timestamp > projectInfo[_name].endTime, "sale has not ended");
    require(projectInfo[_name].totalFunds < projectInfo[_name].goal, "Sale Successfully completed");
    uint256 _tokens = IERC20(projectInfo[_name].token).balanceOf(msg.sender);
    IERC20(projectInfo[_name].token).transferFrom(msg.sender, address(this), _tokens);
    uint256 _userfunds = projectInfo[_name].tokenPrice * _tokens;
    bool sended = payable(msg.sender).send(_userfunds);
    require (sended, "failed");
    projectInfo[_name].currentBal -= _userfunds;
  }

  function withdrawOwner(string memory _name) public nonReentrant{
    require(msg.sender == projectInfo[_name].owner, "only owner can withdraw");
    require(projectInfo[_name].endTime < block.timestamp, "sale has not ended yet");
    require(projectInfo[_name].totalFunds >= projectInfo[_name].goal, "Sale is not successful!");
    bool ownerfund = payable(msg.sender).send(projectInfo[_name].currentBal);
    require(ownerfund);
    projectInfo[_name].currentBal = 0;
  }
}

  
