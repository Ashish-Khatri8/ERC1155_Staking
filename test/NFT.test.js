const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFT", () => {
    const uri = "";
    let NFT;
    let nft;
    let owner;
    let address1;
    let address2;

    beforeEach(async() => {
        [owner, address1, address2] = await ethers.getSigners();
        NFT = await ethers.getContractFactory("NFT");
        nft = await NFT.deploy(uri);
        await nft.deployed();
    });

    it("Users can mint NFTs", async () => {
        await nft.mintNFT(1000);
        expect(await nft.balanceOf(owner.address, 1)).to.equal(1000);

        await nft.connect(address1).mintNFT(500);
        expect(await nft.balanceOf(address1.address, 2)).to.equal(500);

        await nft.connect(address2).mintNFT(5000);
        expect(await nft.balanceOf(address2.address, 3)).to.equal(5000);
    });

    it("Users can burn their NFTs", async () => {
        // First mint some tokens.
        await nft.mintNFT(1000);
        expect(await nft.balanceOf(owner.address, 1)).to.equal(1000);
        
        // Now burn these minted tokens.
        await nft.burnNFT(1, 1000);
        expect(await nft.balanceOf(owner.address, 1)).to.equal(0);
    });
});
