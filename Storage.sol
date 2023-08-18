pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;
import "./TokenDetArrayLib.sol";
import "./ownable.sol";
import "./ERC20Addresses.sol";

interface IERC20 {

    function approve(address spender, uint256 value) external;

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        external;

    function increaseApproval(address spender, uint256 addedValue) external;

    function increaseAllowance(address spender, uint256 addedValue) external;

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

}

contract IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4);
}

contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

contract IMintableToken {
    // Required methods
    function ownerOf(uint256 _tokenId) external view returns (address owner);

    function royalities(uint256 _tokenId) public view returns (uint256);

    function creators(uint256 _tokenId) public view returns (address payable);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;

    function getApproved(uint256 tokenId)
        public
        view
        returns (address operator);
        
    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool);

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID)
        external
        view
        returns (bool);
}


contract Storage is Ownable {
    using TokenDetArrayLib for TokenDetArrayLib.TokenDets;
    using ERC20Addresses for ERC20Addresses.erc20Addresses;
    // address owner;
    // address owner;
    uint16 public rewardDistributionPercentage;
    uint16 public platFormFeePercentage;   
    uint16 public lpStakefeepercentage; 
    // uint16 public brokerage;
    uint256 public updateClosingTime;

    mapping(address => mapping(uint256 => bool)) tokenOpenForSale;
    mapping(address => TokenDetArrayLib.TokenDets) tokensForSalePerUser;
    TokenDetArrayLib.TokenDets fixedPriceTokens;
    TokenDetArrayLib.TokenDets auctionTokens;

    //auction type :
    // 1 : only direct buy
    // 2 : only bid
    // 3 : both buy and bid

    struct auction {
        address payable lastOwner;
        uint256 currentBid;
        address payable highestBidder;
        uint256 auctionType;
        uint256 startingPrice;
        uint256 buyPrice;
        bool buyer;
        uint256 startingTime;
        uint256 closingTime;
        address erc20Token;
    }

    struct OfferDetails {
        address offerer;
        uint256 amount;
    }
    
    /** Offer mapping
     * {
     *      ERC721Address:{
     *          tokenId:{
     *               ERC20Address{
     *                   offerer: Address of offerer,
     *                   amount: Offer in this currency
     *               }
     *           }
     *       }   
     * }
     */
    mapping(
        address => mapping( 
            uint256 => mapping(
                address => OfferDetails
            )
        )
    ) public offerprice;

    mapping(address => mapping(uint256 => auction)) public auctions;

    mapping(address=>mapping(uint256 => mapping(address => mapping(uint256 => OfferDetails)))) bidOffers;

    TokenDetArrayLib.TokenDets tokensForSale;
    ERC20Addresses.erc20Addresses erc20TokensArray;

    address public WETHAddress;
    address public StakeAddress;
    address public LPStakeAddress;
    function getErc20Tokens()
        public
        view
        returns (ERC20Addresses.erc20Addresses memory)
    {
        return erc20TokensArray;
    }

    function getTokensForSale()
        public
        view
        returns (TokenDetArrayLib.TokenDet[] memory)
    {
        return tokensForSale.array;
    }

    function getFixedPriceTokensForSale()
        public
        view
        returns (TokenDetArrayLib.TokenDet[] memory)
    {
        return fixedPriceTokens.array;
    }

    function getAuctionTokensForSale()
        public
        view
        returns (TokenDetArrayLib.TokenDet[] memory)
    {
        return auctionTokens.array;
    }

    function getTokensForSalePerUser(address _user)
        public
        view
        returns (TokenDetArrayLib.TokenDet[] memory)
    {
        return tokensForSalePerUser[_user].array;
    }

    // function setBrokerage(uint16 _brokerage) public onlyOwner {
    //     brokerage = _brokerage;
    // }


      function setBrokerage(address _rewardDistributionAddress,address _lpStakeAddress ,uint16 _lpStakefeepercentage, uint16 _rewardDistributionPercentage, uint16 _platFormFeePercentage) public onlyOwner {
        require(_rewardDistributionAddress != address(0) &&_lpStakeAddress!=address(0), "Address is Zero");
        require(_rewardDistributionPercentage >= 0 && _platFormFeePercentage >= 0 &&_lpStakefeepercentage>=0, "should be greater than zero");
        require(_rewardDistributionPercentage <= 1000 && _platFormFeePercentage <= 1000 && _lpStakefeepercentage<=1000, "should be greater than zero");
        rewardDistributionPercentage = _rewardDistributionPercentage;
        platFormFeePercentage = _platFormFeePercentage;
        lpStakefeepercentage=_lpStakefeepercentage;
        StakeAddress = _rewardDistributionAddress;
        LPStakeAddress = _lpStakeAddress;
    }

    function setUpdatedClosingTime(uint256 _updateTime) public onlyOwner {
        updateClosingTime = _updateTime;
    }

    function setAddress(address _weth, address _rewardDistributionAddress) external onlyOwner {
        WETHAddress =_weth;
        StakeAddress = _rewardDistributionAddress;
    }
}