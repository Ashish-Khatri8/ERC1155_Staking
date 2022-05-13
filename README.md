# ERC1155 NFT Staking

## Contract: BlazeToken.sol

- Contract deployed on [rinkeby test network](https://rinkeby.etherscan.io/address/0x0dC599c076333A0e40BE2495d16257544266b718) at:

> 0x0dC599c076333A0e40BE2495d16257544266b718

This contract deploys an ERC20 token with the following details.

- Name: "BlazeK"
- Symbol: "BLZ"
- Decimals: 18

- This token will be used to pay the reward/ interest that users get for staking their NFT tokens.

- There is no initial supply, but the contract owner can call the mint() function to mint tokens to an address.
It takes the address and the amount of tokens to mint as arguments (must be passed without token decimals).

## Contract: NFT.sol

- Contract deployed on [rinkeby test network](https://rinkeby.etherscan.io/address/0xEfD0556aA6aFfD322b04943a730e823345DaA7e5) at:

> 0xEfD0556aA6aFfD322b04943a730e823345DaA7e5

- An ERC1155 token contract that could be used to mint and burn your own NFTs.

- Users can call the mintNFT() function to mint their own tokens.
  It takes the amount of tokens one wants to mint as argument (must mint at least 101 tokens as that is the minimum staking amount).

- Token IDs of minted tokens are incremented accordingly using Counters.sol utility library.

- Users can call the burnNFT() function to burn their NFTs.
  It takes the tokenId and the amount of tokens to burn as arguments.

## Staking.sol

- Contract deployed on [rinkeby test network](https://rinkeby.etherscan.io/address/0x3Ae67a2a0BE55931A549a54657E6A8473F1bFD86) at:

> 0x3Ae67a2a0BE55931A549a54657E6A8473F1bFD86

- A staking contract where users can stake their minted ERC1155 tokens in order to get BlazeToken(ERC20 token) as staking reward.

- Users can call the stakeNFT() function to stake their NFT tokens. It takes the tokenId and amount of tokens to stake as arguments.

- Minimum staking amount is 101 tokens.

- Users can call the unstakeNFT() function to unstake their staked tokens.
It takes the id of tokens to unstake as argument.

- Depending on the time for which the tokens were staked, the interest rate for reward tokens is calculated as:

```script
    Time                       Interest Rate (APR)

    Less than 1 month          0%
    Between 1 and 6 months     5%
    Between 6 and 12 months    10%
    After 12 months            15%
```

- Formula to calculate how much tokens to send as reward:

```script
=> (interestRate * stakedAmount * stakedTime * 10**18) / (100 * 365 days)
```

### Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case.

```shell
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
