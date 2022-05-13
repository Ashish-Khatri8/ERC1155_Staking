const { ethers } = require("hardhat");

async function main() {
    // Deploy ERC20 BlazeToken contract.
    const BlazeToken = await ethers.getContractFactory("BlazeToken");
    const blazeToken = await BlazeToken.deploy("BlazeK", "BLZ");
    await blazeToken.deployed();
    console.log("BlazeToken is deployed at: ", blazeToken.address);

    // Deploy ERC1155 NFT contract.
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy("");
    await nft.deployed();
    console.log("NFT contract deployed at: ",  nft.address);

    // Deploy the Staking contract.
    const Staking = await ethers.getContractFactory("Staking");
    const staking = await Staking.deploy(
        blazeToken.address,
        nft.address
    );
    await staking.deployed();
    console.log("Staking contract is deployed at: ", staking.address);
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.log(error);
        process.exit(1);
    });
