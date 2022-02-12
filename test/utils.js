const { ethers } = require('hardhat');

exports.ether = (eth) => ethers.utils.parseEther(`${eth}`);
