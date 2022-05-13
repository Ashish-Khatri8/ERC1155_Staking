// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";


contract Staking is ReentrancyGuard, ERC1155Holder {
    using SafeERC20 for IERC20;
    IERC20 private rewardTokenContract;
    IERC1155 private nftContract;

    uint256 constant oneMonthInSeconds = 2629743;

    /*
        Total tokens to send as reward are calculated as:
            (stakedAmount * interestRate * stakedTime * 10**18) / (100 * 365 days)
        
        Thus, the same repeating part for each calculation is calculated at once
        and stored in the constant variable "rate" to avoid calculating it again and again.
    */
    uint256 constant rate = 10**18 / (100 * oneMonthInSeconds * 12);

    struct StakingItem {
        address owner;
        uint256 tokenId;
        uint256 stakedAmount;
        uint256 stakingTime;
        bool isStaked;
    }

    // Mapping addresses to a mapping of tokenID to StakingItems.
    mapping(address => mapping(uint256 => StakingItem)) public stakedNFTs;

    event Staked(
        address indexed by,
        uint256 indexed id,
        uint256 indexed amount,
        uint256 time
    );

    event Unstaked(
        address indexed by,
        uint256 indexed id,
        uint256 indexed amount,
        uint256 time
    );

    event RewardTokensSent(
        address indexed to,
        uint256 indexed amount
    );

    constructor(
        IERC20 _rewardTokenContractAddress,
        IERC1155 _nftContractAddress
    ) {
        require(
            address(_rewardTokenContractAddress) != address(0) &&
            address(_nftContractAddress) != address(0) &&
            address(_rewardTokenContractAddress) != address(_nftContractAddress),
            "Staking: Contract addresses cannot be same or null address."
        );
        rewardTokenContract = _rewardTokenContractAddress;
        nftContract = _nftContractAddress;
    }

    function stakeNFT(uint256 _id, uint256 _amount) external {
        preStakingValidation(_id, _amount);
        uint256 time = block.timestamp;

        StakingItem memory stakedNFT = StakingItem(
            msg.sender,
            _id,
            _amount,
            time,
            true
        );
        stakedNFTs[msg.sender][_id] = stakedNFT;

        // Transfer nft tokens from msg.sender to contract.
        nftContract.safeTransferFrom(
            msg.sender,
            address(this),
            _id,
            _amount,
            ""
        );
        emit Staked(msg.sender, _id, _amount, time);
    }

    function unstakeNFT(uint256 _id) external nonReentrant {
        require(
            stakedNFTs[msg.sender][_id].isStaked == true,
            "Staking: You have not staked any token with given id."
        );
        // Retrieve staked token amount.
        uint256 stakedAmount = stakedNFTs[msg.sender][_id].stakedAmount;

        // Calculate time elapsed since NFT tokens staked.
        uint256 timeElapsed = block.timestamp - stakedNFTs[msg.sender][_id].stakingTime;

        // Calculate interest rate.
        uint256 interestRate = calculateInterestRate(timeElapsed);

        /* 
            If interestRate is 0, => staked tokens are unstaked within 1 month.
            Thus, no reward tokens will be sent.
        */
        if (interestRate > 0) {
            // Calculate tokens to send in reward.
            uint256 tokensToSend = interestRate * stakedAmount * timeElapsed * rate;

            // Send Reward Tokens.
            rewardTokenContract.safeTransfer(msg.sender, tokensToSend);
            emit RewardTokensSent(msg.sender, tokensToSend);
        }

        // Send staked NFT Tokens back.
        nftContract.safeTransferFrom(address(this), msg.sender, _id, stakedAmount, "");
        emit Unstaked(msg.sender, _id, stakedAmount, block.timestamp);
        
        // Change token staking status.
        stakedNFTs[msg.sender][_id].isStaked = false;
    }

    function calculateInterestRate(uint256 _timeElapsed) private pure returns(uint256) {
        if (_timeElapsed < oneMonthInSeconds)
            return 0;
        else if (_timeElapsed < oneMonthInSeconds * 6)
            return 5;
        else if (_timeElapsed < oneMonthInSeconds * 12)
            return 10;
        else
            return 15;
    }

    function preStakingValidation(uint256 _id, uint256 _amount) private view {
        require(
            _id != 0,
            "Staking: Invalid token id."
        );
        require(
            _amount > 100,
            "Staking: Minimum staking amount is 101 tokens."
        );
        require(
            nftContract.balanceOf(msg.sender, _id) >= _amount,
            "Staking: Insufficient balance."
        );
        require(
            stakedNFTs[msg.sender][_id].isStaked == false,
            "Staking: Token is already staked."
        );
        require(
            nftContract.isApprovedForAll(msg.sender, address(this)) == true,
            "Staking: Contract not approved to transfer your tokens. Give permission first!"
        );
    }

}
