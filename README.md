# NonFungible Marketplace

A weekend project - working NFT marketplace with testing

## Test coverage

```
------------------|----------|----------|----------|----------|----------------|
File              |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
------------------|----------|----------|----------|----------|----------------|
 contracts/       |    87.72 |    86.36 |    77.78 |    89.06 |                |
  Marketplace.sol |      100 |    86.36 |      100 |      100 |                |
  NFT.sol         |        0 |      100 |        0 |        0 |... 24,25,26,27 |
------------------|----------|----------|----------|----------|----------------|
All files         |    87.72 |    86.36 |    77.78 |    89.06 |                |
------------------|----------|----------|----------|----------|----------------|
```

## To start

```
git clone https://github.com/amazingandyyy/nonfungible.git
yarn
```

## Development

```
npm test
```

## Gas report

```
·------------------------------|----------------------------|-------------|-----------------------------·
|     Solc version: 0.8.4      ·  Optimizer enabled: false  ·  Runs: 200  ·  Block limit: 30000000 gas  │
·······························|····························|·············|······························
|  Methods                                                                                              │
················|··············|··············|·············|·············|···············|··············
|  Contract     ·  Method      ·  Min         ·  Max        ·  Avg        ·  # calls      ·  usd (avg)  │
················|··············|··············|·············|·············|···············|··············
|  Marketplace  ·  buyItem     ·           -  ·          -  ·     171997  ·            2  ·          -  │
················|··············|··············|·············|·············|···············|··············
|  Marketplace  ·  listItem    ·      169458  ·     175070  ·     171329  ·            3  ·          -  │
················|··············|··············|·············|·············|···············|··············
|  Marketplace  ·  withdraw    ·           -  ·          -  ·      28946  ·            1  ·          -  │
················|··············|··············|·············|·············|···············|··············
|  NFT          ·  createItem  ·      124682  ·     141782  ·     133232  ·            4  ·          -  │
················|··············|··············|·············|·············|···············|··············
|  Deployments                 ·                                          ·  % of limit   ·             │
·······························|··············|·············|·············|···············|··············
|  Marketplace                 ·           -  ·          -  ·    2144299  ·        7.1 %  ·          -  │
·······························|··············|·············|·············|···············|··············
|  NFT                         ·     2532947  ·    2532959  ·    2532953  ·        8.4 %  ·          -  │
·------------------------------|--------------|-------------|-------------|---------------|-------------·

```

## Developer

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
npx hardhat help
REPORT_GAS=true npx hardhat test
npx hardhat coverage
npx hardhat run scripts/deploy.js
node scripts/deploy.js
npx eslint '**/*.js'
npx eslint '**/*.js' --fix
npx prettier '**/*.{json,sol,md}' --check
npx prettier '**/*.{json,sol,md}' --write
npx solhint 'contracts/**/*.sol'
npx solhint 'contracts/**/*.sol' --fix
```

### Etherscan verification

To try out Etherscan verification, you first need to deploy a contract to an Ethereum network that's supported by Etherscan, such as Ropsten.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Etherscan API key, your Ropsten node URL (eg from Alchemy), and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

```shell
hardhat run --network ropsten scripts/deploy.js
```

Then, copy the deployment address and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network ropsten DEPLOYED_CONTRACT_ADDRESS "Hello, Hardhat!"
```

## References

- [Hardhat](https://hardhat.org/guides/project-setup.html)
- [Solidity by Example](https://solidity-by-example.org/)
- [Chai matchers](https://ethereum-waffle.readthedocs.io/en/latest/matchers.html)
- [The Complete Solidity Course - Blockchain - Zero to Expert](https://www.udemy.com/course/the-complete-solidity-course-blockchain-zero-to-expert)
- [Build your own NFT marketplace like OpenSea clone with solidity, openzeppelin and polygon](https://www.youtube.com/watch?v=7Q5E6RvLlUw&t=4423s&ab_channel=BraintempleTutorialTV)
