pragma solidity ^0.5.17;
import "./ownable.sol";
import "./Storage.sol";

interface IMintable {
    // Required read methods
    function getApproved(uint256 tokenId) external returns (address operator);

    function isApprovedForAll(address owner, address operator) external returns (bool);

    function tokenURI(uint256 tokenId) external returns (string memory);

    // Required write methods
    function approve(address _to, uint256 _tokenId) external;

    function transfer(address _to, uint256 _tokenId) external;

    function burn(uint256 tokenId) external;

    function mint(string calldata _tokenURI, uint256 _royality) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract Admin is Ownable{

    

    event NFTBurned(
        address indexed collection,
        uint256 indexed tokenId,
        address indexed admin,
        uint256 time,
        string tokenURI
    );
    event AdminRemoved(address admin, uint256 time);
    event AdminAdded(address admin, uint256 time);

    event AdminActionPerformed(
        address indexed admin,
        address indexed contractAddress,
        string indexed functionName,
        address collectionAddress,
        uint256 tokenId
    );


    

    struct FunctionNames {
        string approve;
        string transfer;
        string burn;
        string mint;
        string safeTransferFrom;
        string transferFrom;
        string putOnSale;
        string buy;
        string bid;
        string collect;
        string updatePrice;
        string putSaleOff;
        string makeAnOffer;
        string accpetOffer;
        string revertOffer;
        string revertAll;
        string erc20Approve;
        string erc20DecreaseApproval;
        string erc20IncreaseApproval;
        string erc20Transfer;
        string erc20TransferFrom;
        string erc20IncreaseAllowance;
        string erc20DecreaseAllowance;
        string batchListing;
        string batchDelisting;
        string setAddress;
    }

    FunctionNames functionNames =
        FunctionNames(
            "ERC721:approve",
            "ERC721:transfer",
            "ERC721:burn",
            "ERC721:mint",
            "ERC721:safeTransferFrom",
            "ERC721:transferFrom",
            "Broker:putOnSale",
            "Broker:buy",
            "Broker:bid",
            "Broker:collect",
            "Broker:updatePrice",
            "Broker:putSaleOff",
            "Broker:makeAnOffer",
            "Broker:accpetOffer",
            "Broker:revertOffer",
            "Broker:revertAll",
            "Broker:batchListing",
            "Broker:batchDelisting",
            "Broker:setAddress",
            "ERC20:approve",
            "ERC20:decreaseApproval",
            "ERC20:increaseApproval",
            "ERC20:transfer",
            "ERC20:transferFrom",
            "ERC20:increaseAllowance",
            "ERC20:decreaseAllowance"
        );    

    
    address[] public admins;
      

    function adminExist(address _sender) public view returns (bool) {
        for (uint256 i = 0; i < admins.length; i++) {
            if (_sender == admins[i]) {
                return true;
            }
        }
        return false;
    }

    modifier adminOnly() {
        require(adminExist(msg.sender), "AdminManager: admin only.");
        _;
    }

    modifier adminAndOwnerOnly() {
        require(
            adminExist(msg.sender) || isOwner(),
            "AdminManager: admin and owner only."
        );
        _;
    }

    function addAdmin(address admin) public onlyOwner {
        if (!adminExist(admin)) {
            admins.push(admin);
        } else {
            revert("admin already in list");
        }

        emit AdminAdded(admin, block.timestamp);
    }

    function getAdmins() public view returns (address[] memory) {
        return admins;
    }


    function removeAdmin(address admin) public onlyOwner {
        for (uint256 i = 0; i < admins.length; i++) {
            if (admins[i] == admin) {
                admins[admins.length - 1] = admins[i];
                admins.pop();
                break;
            }
        }
        emit AdminRemoved(admin, block.timestamp);
    }

    function burnNFT(address collection, uint256 tokenId)
        public
        adminAndOwnerOnly
    {
        IMintable NFTToken = IMintable(collection);

        string memory tokenURI = NFTToken.tokenURI(tokenId);
        require(
            NFTToken.getApproved(tokenId) == address(this),
            "Token not apporove for burn"
        );
        NFTToken.burn(tokenId);
        emit NFTBurned(
            collection,
            tokenId,
            msg.sender,
            block.timestamp,
            tokenURI
        );
    }

    // NFT methods for admin to manage by this contract URL
    function erc721Approve(
        address _ERC721Address,
        address _to,
        uint256 _tokenId
    ) public adminAndOwnerOnly {
        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.approve,
            _ERC721Address,
            _tokenId
        );
        return erc721.approve(_to, _tokenId);
    }

    function erc721Transfer(
        address _ERC721Address,
        address _to,
        uint256 _tokenId
    ) public adminAndOwnerOnly {
        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.transfer,
            _ERC721Address,
            _tokenId
        );
        return erc721.transfer(_to, _tokenId);
    }

    function erc721Burn(address _ERC721Address, uint256 tokenId)
        public
        adminAndOwnerOnly
    {
        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.burn,
            _ERC721Address,
            tokenId
        );
        return erc721.burn(tokenId);
    }

    function erc721Mint(
        address _ERC721Address,
        string memory tokenURI,
        uint256 _royality
    ) public adminAndOwnerOnly {
        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.mint,
            _ERC721Address,
            0
        );
        return erc721.mint(tokenURI, _royality);
    }

    function erc721SafeTransferFrom(
        address _ERC721Address,
        address from,
        address to,
        uint256 tokenId
    ) public adminAndOwnerOnly {
        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.safeTransferFrom,
            _ERC721Address,
            tokenId
        );
        return erc721.safeTransferFrom(from, to, tokenId);
    }

    function erc721SafeTransferFrom(
        address _ERC721Address,
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public adminAndOwnerOnly {
        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.safeTransferFrom,
            _ERC721Address,
            tokenId
        );
        return erc721.safeTransferFrom(from, to, tokenId, _data);
    }

    function erc721TransferFrom(
        address _ERC721Address,
        address from,
        address to,
        uint256 tokenId
    ) public adminAndOwnerOnly {
        IMintable erc721 = IMintable(_ERC721Address);
        emit AdminActionPerformed(
            msg.sender,
            _ERC721Address,
            functionNames.transferFrom,
            _ERC721Address,
            tokenId
        );
        return erc721.transferFrom(from, to, tokenId);
    }

    function erc20Approve(
        address _erc20,
        address spender,
        uint256 value
    ) public adminAndOwnerOnly {
        IERC20 erc20 = IERC20(_erc20);
        erc20.approve(spender, value);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20Approve,
            spender,
            value
        );
    }

    function erc20DecreaseApproval(
        address _erc20,
        address _spender,
        uint256 _subtractedValue
    ) public adminAndOwnerOnly {
        IERC20 erc20 = IERC20(_erc20);
        erc20.decreaseApproval(_spender, _subtractedValue);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20DecreaseAllowance,
            _spender,
            _subtractedValue
        );
    }

    function erc20IncreaseApproval(
        address _erc20,
        address spender,
        uint256 addedValue
    ) public adminAndOwnerOnly {
        IERC20 erc20 = IERC20(_erc20);
        erc20.increaseApproval(spender, addedValue);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20IncreaseApproval,
            spender,
            addedValue
        );
    }

    function erc20Transfer(
        address _erc20,
        address to,
        uint256 value
    ) public adminAndOwnerOnly {
        IERC20 erc20 = IERC20(_erc20);
        erc20.transfer(to, value);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20Transfer,
            to,
            value
        );
    }

    function erc20TransferFrom(
        address _erc20,
        address from,
        address to,
        uint256 value
    ) public adminAndOwnerOnly {
        IERC20 erc20 = IERC20(_erc20);
        erc20.transferFrom(from, to, value);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20TransferFrom,
            to,
            value
        );
    }

    function erc20IncreaseAllowance(
        address _erc20,
        address spender,
        uint256 addedValue
    ) public adminAndOwnerOnly {
        IERC20 erc20 = IERC20(_erc20);
        erc20.increaseAllowance(spender, addedValue);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20IncreaseAllowance,
            spender,
            addedValue
        );
    }

    function erc20DecreaseAllowance(
        address _erc20,
        address spender,
        uint256 subtractedValue
    ) public adminAndOwnerOnly {
        IERC20 erc20 = IERC20(_erc20);
        erc20.decreaseAllowance(spender, subtractedValue);
        emit AdminActionPerformed(
            msg.sender,
            _erc20,
            functionNames.erc20DecreaseAllowance,
            spender,
            subtractedValue
        );
    }
}