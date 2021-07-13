pragma solidity ^0.8.0;

import "./ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeCast.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";


/// @author Joseph H. Cottingham
/// @notice This is still in Beta and has not been optimized or tested
/// @dev Nothing as of now
contract SpeakWordManager is Ownable {

    using SafeMath for uint256;

    struct Word {
        string title;
        string body;
        uint32 timestamp;
    }

    struct WordExtended {
        string title;
        string body;
        uint32 timestamp;
        uint256 totalLikes;
        bool liked;
    }

    uint createWordFee = 0.001 ether;

    mapping (uint256 => address[]) wordToLikeAddresses;
    mapping (uint256 => address) wordToOwner;
    mapping (address => uint) ownerToBal;

    Word[] public words;
    address[] public speakers;

    uint256[] public topWords;

    event NewWord(uint wordId, string title, string body, address owner);


    constructor() {
        string memory first_word = "If liberty means anything at all, it means the right to tell people what they do not want to hear. ~ George Orwell";
        _createWord("Liberty of Words.", first_word);
    }

    /// @notice Creates a new word
    /// @param _title Title of new word
    /// @param _body Body of new word
    function _createWord(string memory _title, string memory _body) internal {
        require(ownerToBal[msg.sender] < 1000);
        Word memory newWord = Word(_title, _body, uint32(block.timestamp));
        words.push(newWord);
        uint256 id = words.length;
        wordToOwner[id] = msg.sender;
        wordToLikeAddresses[id].push(msg.sender);
        ownerToBal[msg.sender] = ownerToBal[msg.sender] + 1;
        configSpeakers();
        emit NewWord(id, _title, _body, wordToOwner[id]);
    }

    /// @notice Creates a new word external
    /// @param _title Title of new word
    /// @param _body Body of new word
    function createWord(string memory _title, string memory _body) external payable {
        _createWord(_title, _body);
    }

    /// @notice Like a word by word id
    /// @param wordId id of word token
    function like(uint256 wordId) external returns (bool result) {
        // Check if address has already like content
        for (uint256 index = 0; index < wordToLikeAddresses[wordId].length; index++) {
            if (msg.sender == wordToLikeAddresses[wordId][index]) {
                return false;
            }
        }
        // Like the word
        wordToLikeAddresses[wordId].push(msg.sender);
        return true;
    }


    /// @notice Get the top words of all time
    /// @return wordIdArray Array of word Id based on index
    /// @return titleArray Array of word title based on index
    /// @return bodyArray Array of word bodies based on index
    /// @return timestampArray Array of creation timestamp based on index
    /// @return totalLikesArray Array of word likes's based on index
    /// @return likedArray Array of wallet address like status for a word based on index
    function getTopWords() external view returns (uint256[50] memory wordIdArray, string[50] memory titleArray, string[50] memory bodyArray, uint32[50] memory timestampArray, uint256[50] memory totalLikesArray, bool[50] memory likedArray) {
        uint256[50] memory wordIdArray;
        string[50] memory titleArray;
        string[50] memory bodyArray;
        uint32[50] memory timestampArray;
        uint256[50] memory totalLikesArray;
        bool[50] memory likedArray;
    
        uint256 lowestLikes = 0;
        uint256 lowestLikesId = 0;
        for (uint256 index = 0; index < words.length; index++) {
            address[] memory likes = wordToLikeAddresses[index];
            if (index < 50 || likes.length > lowestLikes) {
                if (index < 50) {
                    lowestLikesId=index;
                    lowestLikes=likes.length;
                } else {
                    // Finds the lowest like word in current top list
                    for (uint256 indexTopWord = 0; indexTopWord < 50; indexTopWord++) {
                        address[] memory likesSub = wordToLikeAddresses[wordIdArray[indexTopWord]];
                        if (likesSub.length < lowestLikes) {
                            lowestLikesId=indexTopWord;
                            lowestLikes=likesSub.length;
                        }
                    }
                }

                bool liked = false;
                for (uint256 indexLike = 0; indexLike < likes.length; indexLike++) {
                    if (likes[indexLike] == msg.sender) {
                        liked = true;
                    }
                }
                
                // Sets values
                wordIdArray[lowestLikesId] = index;
                titleArray[lowestLikesId] = words[index].title;
                bodyArray[lowestLikesId] = words[index].body;
                timestampArray[lowestLikesId] = words[index].timestamp;
                totalLikesArray[lowestLikesId] = likes.length;
                likedArray[lowestLikesId] = liked;

            }
        }
        return (wordIdArray, titleArray, bodyArray, timestampArray, totalLikesArray, likedArray);
    }


    /// @notice Get the recent created words
    /// @return wordIdArray Array of word Id based on index
    /// @return titleArray Array of word title based on index
    /// @return bodyArray Array of word bodies based on index
    /// @return timestampArray Array of creation timestamp based on index
    /// @return totalLikesArray Array of word likes's based on index
    /// @return likedArray Array of wallet address like status for a word based on index
    function getRecentWords() external view returns (uint256[50] memory wordIdArray, string[50] memory titleArray, string[50] memory bodyArray, uint32[50] memory timestampArray, uint256[50] memory totalLikesArray, bool[50] memory likedArray) {
        uint256[50] memory wordIdArray;
        string[50] memory titleArray;
        string[50] memory bodyArray;
        uint32[50] memory timestampArray;
        uint256[50] memory totalLikesArray;
        bool[50] memory likedArray;
    
        uint256 count = 0;
        uint256 length = words.length;
        if (length < 50) {
            length=0;
        } else {
            length=length-51;
        }
        for (uint256 index = words.length-1; index >= length; index--) {
            bool liked = false;
            for (uint256 indexLike = 0; indexLike < wordToLikeAddresses[index].length; indexLike++) {
                if (wordToLikeAddresses[index][indexLike] == msg.sender) {
                    liked = true;
                }
            }
            // Sets values
            wordIdArray[count] = index;
            titleArray[count] = words[index].title;
            bodyArray[count] = words[index].body;
            timestampArray[count] = words[index].timestamp;
            totalLikesArray[count] = wordToLikeAddresses[index].length;
            likedArray[count] = liked;
            count++;
            // Breaks if about to flip sign bit
            if (index == 0) {
                break;
            }
        }
        return (wordIdArray, titleArray, bodyArray, timestampArray, totalLikesArray, likedArray);
    }


    /// @notice Get of wall adress words
    /// @return wordIdArray Array of word Id based on index
    /// @return titleArray Array of word title based on index
    /// @return bodyArray Array of word bodies based on index
    /// @return timestampArray Array of creation timestamp based on index
    function getWords(address owner) external view returns (uint256[1000] memory wordIdArray, string[1000] memory titleArray, string[1000] memory bodyArray, uint32[1000] memory timestampArray) {
        uint256[1000] memory wordIdArray;
        string[1000] memory titleArray;
        string[1000] memory bodyArray;
        uint32[1000] memory timestampArray;
        
        uint256 count = 0;
        for (uint256 index = 0; index < words.length; index++) {
            if (owner == wordToOwner[index]) {
                wordIdArray[count] = index;
                titleArray[count] = words[index].title;
                bodyArray[count] = words[index].body;
                timestampArray[count] = words[index].timestamp;
                count++;
            }
        }
        return (wordIdArray, titleArray, bodyArray, timestampArray);
    } 

    /// @notice Get all words that exist
    /// @return words array of all words that exist
    function getAllWords() external view returns (Word[] memory words) {
        return words;
    } 

    /// @notice sets the new word creation fee
    function setCreateWordFee(uint _fee) external onlyOwner {
        createWordFee = _fee;
    }

    /// @notice sets the new word creation fee
    function configSpeakers() internal {
        for (uint256 index = 0; index < speakers.length; index++) {
            if (speakers[index] == msg.sender) {
                return;
            }
        }
        speakers.push(owner);
    }

}
