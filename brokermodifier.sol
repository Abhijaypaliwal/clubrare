pragma solidity 0.5.17;
pragma experimental ABIEncoderV2;
import "./Storage.sol";

contract BrokerModifiers is Storage {
    modifier erc20Allowed(address _erc20Token) {
        if (_erc20Token != address(0)) {
            require(
                erc20TokensArray.exists(_erc20Token),
                "ERC20 not allowed"
            );
        }
        _;
    }

    modifier onSaleOnly(uint256 tokenID, address _mintableToken) {
        require(
            tokenOpenForSale[_mintableToken][tokenID] == true,
            "Token Not For Sale"
        );
        _;
    }

    modifier activeAuction(uint256 tokenID, address _mintableToken) {
        require(
            block.timestamp < auctions[_mintableToken][tokenID].closingTime,
            "Auction Time Over!"
        );
        require(
            block.timestamp > auctions[_mintableToken][tokenID].startingTime,
            "Auction Not Started yet!"
        );
        _;
    }

    modifier auctionOnly(uint256 tokenID, address _mintableToken) {
        require(
            auctions[_mintableToken][tokenID].auctionType != 1,
            "Auction Not For Bid"
        );
        _;
    }

    modifier flatSaleOnly(uint256 tokenID, address _mintableToken) {
        require(
            auctions[_mintableToken][tokenID].auctionType != 2,
            "For flat sale only!"
        );
        _;
    }

    modifier tokenOwnerOnlly(uint256 tokenID, address _mintableToken) {
        // Sender will be owner only if no have bidded on auction.
        require(
            IMintableToken(_mintableToken).ownerOf(tokenID) == msg.sender,
            "You must be owner and Token should not have any bid"
        );
        _;
    }

    modifier notZero(
        uint256 _amount
    )
    {
        require(_amount!=0,"not zero");
        _;
    }
}