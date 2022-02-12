const { expect } = require('chai');
const { ethers } = require('hardhat');
const { ether } = require('./utils');

const feeInNumber = 0.025;
const nft1PriceInNumber = 0.55;
const nft2PriceInNumber = 0.66;

describe('Marketplace', function () {
  let Marketplace;
  let marketplace;
  let NFT;
  let nft;
  // eslint-disable-next-line no-unused-vars
  let owner;
  let user1;
  let user2;
  // eslint-disable-next-line no-unused-vars
  let users;
  const nft1Price = ether(nft1PriceInNumber);
  const nft2Price = ether(nft2PriceInNumber);

  beforeEach(async function () {
    Marketplace = await ethers.getContractFactory('Marketplace');
    marketplace = await Marketplace.deploy();
    await marketplace.deployed();
    NFT = await ethers.getContractFactory('NFT');
    nft = await NFT.deploy(marketplace.address);
    await nft.deployed();
    [owner, user1, user2, ...users] = await ethers.getSigners();
  });

  it('Should init fee correctly', async function () {
    expect(await marketplace.fee()).to.equal(ether(0.025));
    expect(await marketplace.fee()).to.not.equal(ether(0.02));
  });

  it('Should create NFT', async function () {
    /// @notes about callStatic
    /// @reference https://ethereum.stackexchange.com/questions/88119/i-see-no-way-to-obtain-the-return-value-of-a-non-view-function-ethers-js
    // callStatic is handy to test return values
    // using `callStatic` to pretend there is not need to wait the state changing to be confirmed
    // and get return value right away
    const tokenId = await nft.callStatic.createItem('https://coolimage.com');
    expect(tokenId).to.equal(0);
  });
  it('Should create NFT, listItem, buyItem, withdraw', async function () {
    // user1 create nft1
    const createItemTx = await nft
      .connect(user1)
      .createItem('https://image.com/1');
    await createItemTx.wait();
    // user2 create nft2
    const createItemTx2 = await nft
      .connect(user2)
      .createItem('https://image.com/2');
    await createItemTx2.wait();

    // user1 list nft1
    // and test event
    expect(await marketplace.connect(user1).listItem(nft.address, 0, nft1Price))
      .to.emit(marketplace, 'ItemListed')
      .withArgs(
        0,
        nft.address,
        0,
        user1.address,
        ethers.constants.AddressZero,
        nft1Price,
        false
      );

    // user2 list nft2
    await marketplace.connect(user2).listItem(nft.address, 1, nft2Price);

    const allListingItems = await marketplace.fetchAllListingItems();
    expect(allListingItems.length).to.equal(2);
    expect(allListingItems[0].seller).to.equal(user1.address);
    expect(allListingItems[0].owner).to.equal(ethers.constants.AddressZero);

    const user1ListingItems = await marketplace
      .connect(user1)
      .fetchUserListingItems();
    expect(user1ListingItems.length).to.equal(1);

    // user1 try to buy nft2 without enough price
    await expect(
      marketplace.connect(user1).buyItem(nft.address, 1, { value: ether(0.1) })
    ).to.be.revertedWith('Price does not match listing price');

    // user1 try to buy nft2 without fee
    await expect(
      marketplace.connect(user1).buyItem(nft.address, 1, { value: nft2Price })
    ).to.be.revertedWith('Price does not match listing price');

    // user1 owns 9 nft
    const user1OwningItems = await marketplace
      .connect(user1)
      .fetchUserOwningItems();
    expect(user1OwningItems.length).to.equal(0);

    // user1 try to buy nft2 with enough price
    await expect(
      marketplace.connect(user1).buyItem(nft.address, 1, {
        value: ether(nft2PriceInNumber + feeInNumber),
      })
    )
      .to.emit(marketplace, 'ItemSold')
      .withArgs(
        1,
        nft.address,
        1,
        user2.address, // seller/prevOwner
        user1.address, // buyer/newOwner
        nft2Price,
        true
      );

    // user2 had money available to withdraw
    expect(
      await marketplace.connect(user2).userWallets(user2.address)
    ).to.equal(nft2Price);
    // user1 had no money to withdraw
    await expect(marketplace.connect(user1).withdraw()).to.be.revertedWith(
      'No money to withdraw'
    );
    // user2 can withdraw
    await marketplace.connect(user2).withdraw();
    // user2's wallet balance reset to 0
    expect(
      await marketplace.connect(user2).userWallets(user2.address)
    ).to.equal(0);

    // user1 does bought one nft
    const userBoughtItems = await marketplace
      .connect(user1)
      .fetchUserBoughtItems();
    expect(userBoughtItems.length).to.equal(1);

    // user1 owns 1 nft
    const userOwningItems = await marketplace
      .connect(user1)
      .fetchUserOwningItems();
    expect(userOwningItems.length).to.equal(1);
  });
});
