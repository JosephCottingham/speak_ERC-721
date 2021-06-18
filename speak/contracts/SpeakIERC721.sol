pragma solidity ^0.8.0;

import "./speak.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeCast.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";



contract SpeakIERC721 is Speak, IERC721 {

    using SafeMath for uint256;

    mapping (uint => address) wordToApproved;


    // STATE VARIABLES
    constructor() {
        
    }

    modifier validOperator(uint256 tokenId) {
        require(msg.sender == wordToOwner[tokenId] || msg.sender == wordToApproved[tokenId]);
        _;
    }

    // IERC721 Implementation
    function balanceOf(address owner) external view override returns (uint256 balance) {
        uint256 count = 0; 
        for (uint256 index = 0; index < words.length; index++) {
            if (wordToOwner[index] == owner) {
                count++;
            }
        }
        return count;
    }

    function ownerOf(uint256 tokenId) external view override returns (address owner){
        return wordToOwner[tokenId];
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override validOperator(tokenId) {
        bool validAddress = false;
        for (uint256 index; index < speakers.length; index++) {
            if (speakers[index] == to) {
                validAddress = true;
                break;
            }
        }
        require(validAddress);
        wordToOwner[tokenId] = to;
        wordToApproved[tokenId] = address(0);
        emit Transfer(from, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external override validOperator(tokenId) {
        require(to != address(0));
        wordToOwner[tokenId] = to;
        wordToApproved[tokenId] = address(0);
        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external override validOperator(tokenId) {
        wordToApproved[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function getApproved(uint256 tokenId) external view override returns (address operator) {
        return wordToApproved[tokenId];
    }

    function setApprovalForAll(address operator, bool _approved) external override {
    }

    function isApprovedForAll(address owner, address operator) external view override returns (bool) {

    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override validOperator(tokenId) {
        require(to != address(0));
        wordToOwner[tokenId] = to;
        wordToApproved[tokenId] = address(0);
        emit Transfer(from, to, tokenId);
    }

    // IERC165
    function supportsInterface(bytes4 interfaceId) external view override returns (bool){
        return interfaceId == this.supportsInterface.selector;
    }

}
