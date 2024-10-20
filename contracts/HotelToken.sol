// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MegaERC20 is ERC20 {
  // initial supply is 50 <- 50 WEI
  // initial supply 50e18
  // 50 * 10**18

  mapping(address account => mapping(address spender => uint256))
    private _allowances;

  constructor(uint256 initialSupply) ERC20("MegaETH", "METH") {
    _mint(msg.sender, initialSupply);
  }

  function transfer(address to, uint256 value) public override returns (bool) {
    address owner = _msgSender();
    _transfer(owner, to, value);
    return true;
  }

  function allowance(
    address owner,
    address spender
  ) public view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(
    address spender,
    uint256 amount
  ) public virtual override returns (bool) {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) public override returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, value);
    _transfer(from, to, value);
    return true;
  }
}
