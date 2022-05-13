const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Staking", () => {
    let owner;
    let staker1;
    let staker2;
    let staker3;

    let BlazeToken;
    let blazeToken;
    let NFT;
    let nft;
    let Staking;
    let staking;

    beforeEach(async () => {
        [owner, staker1, staker2, staker3] = await ethers.getSigners();

        // Deploy the BlazeToken contract.
        BlazeToken = await ethers.getContractFactory("BlazeToken");
        blazeToken = await BlazeToken.deploy("BlazeK", "BLZ");
        await blazeToken.deployed();

        // Deploy the ERC1155 NFT contract.
        NFT = await ethers.getContractFactory("NFT");
        nft = await NFT.deploy("");
        await nft.deployed();

        // Deploy the Staking contract.
        Staking = await ethers.getContractFactory("Staking");
        staking = await Staking.deploy(
            blazeToken.address,
            nft.address
        );

        // Mint BlazeTokens to Staking contract.
        await blazeToken.mint(staking.address, "100000000");

        // Give Staking contract approval for tokens from all accounts.
        await nft.setApprovalForAll(staking.address, true);
        await nft.connect(staker1).setApprovalForAll(staking.address, true);
        await nft.connect(staker2).setApprovalForAll(staking.address, true);
        await nft.connect(staker3).setApprovalForAll(staking.address, true);

        // Mint NFT tokens for all accounts.
        await nft.mintNFT(1000);
        await nft.connect(staker1).mintNFT(1000);
        await nft.connect(staker2).mintNFT(1000);
        await nft.connect(staker3).mintNFT(1000);
    });

    it("Users can stake their NFTs", async () => {
        await staking.stakeNFT(1, 1000);
        const stakedNFT = await staking.stakedNFTs(owner.address, 1);
        expect(stakedNFT.isStaked).to.be.equal(true);
        expect(stakedNFT.stakedAmount).to.equal(1000);
        // Check if the Staking contract received the NFT tokens.
        expect(await nft.balanceOf(staking.address, 1)).to.equal(1000);
        expect(await nft.balanceOf(owner.address, 1)).to.equal(0);
    });

    it("Users can unstake their NFTs and get reward tokens.", async () => {
        // Stake the NFTs.
        await staking.connect(staker1).stakeNFT(2, 1000);
        // Increase evm time by 2 months.
        await ethers.provider.send("evm_increaseTime", [2629743 * 2]);

        // Check staker's current token balance.
        const beforeUnstakingBalance = await blazeToken.balanceOf(staker1.address);

        // Unstake the NFT tokens.
        await staking.connect(staker1).unstakeNFT(2);

        // Check if NFT tokens got transferred back to the staker.
        expect(await nft.balanceOf(staking.address, 2)).to.equal(0);
        expect(await nft.balanceOf(staker1.address, 2)).to.equal(1000);

        // Check if the staker received reward tokens.
        const afterUnStakingBalance = await blazeToken.balanceOf(staker1.address);
        expect(afterUnStakingBalance).to.be.not.equal(beforeUnstakingBalance);
    });

    it("Users cannot stake NFTs they don't own.", async () => {
        expect(staking.stakeNFT(2, 1000))
            .to.be.revertedWith("Staking: Insufficient balance.");
    });

    it("Multiple Users can stake tokens of same token id.", async () => {
        await nft.connect(staker2).safeTransferFrom(
            staker2.address,
            staker3.address,
            3,
            500,
            "0x"
        );

        // Staker 2 can stake own id 3 tokens.
        await staking.connect(staker2).stakeNFT(3, 500);
        const stakingByTwo = await staking.stakedNFTs(staker2.address, 3);
        expect(stakingByTwo.isStaked).to.be.equal(true);
        expect(stakingByTwo.stakedAmount).to.be.equal(500);

        // Staker 3 can stake own id 3 tokens.
        await staking.connect(staker3).stakeNFT(3, 500);
        const stakingByThree = await staking.stakedNFTs(staker3.address, 3);
        expect(stakingByThree.isStaked).to.be.equal(true);
        expect(stakingByThree.stakedAmount).to.be.equal(500);
    });

});
