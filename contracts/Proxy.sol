// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/proxy/Proxy.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract UpgradeableICO is Proxy, Ownable
{
    address public logicContract;
    constructor() Proxy() Ownable()
    {}
    function setImplementation(address _contract)public onlyOwner
    {
        logicContract = _contract;
    }
    function _implementation()internal view override returns(address)
    {
        return logicContract;
    }
}