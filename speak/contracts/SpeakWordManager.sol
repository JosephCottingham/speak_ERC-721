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

    mapping (uint => address[]) wordToLikeAddresses;
    mapping (uint => address) wordToOwner;
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
    function like(uint256 wordId) external {
        // Check if address has already like content
        address[] memory wordLikes = wordToLikeAddresses[wordId];
        for (uint256 index = 0; index < wordLikes.length; index++) {
            if (msg.sender == wordLikes[index]) {
                return;
            }
        }
        // Like the word
        wordToLikeAddresses[wordId].push(msg.sender);
        // Check if this word now needs to be added to the top list
        configTopWords(wordId);
    }

    /// @notice Checks if wordId is now one of the top words
    /// @param wordId id of word token
    function configTopWords(uint256 wordId) internal {
        // Populate top words till filled to max
        if (topWords.length < 50) {
            topWords.push(wordId);
            return;
        }

        // Figure out which word to replace
        uint256 lowestLikes=wordToLikeAddresses[topWords[0]].length;
        uint256 lowestId=topWords[0];
        for (uint256 index = 1; index < topWords.length; index++) {
            uint256 curLikes = wordToLikeAddresses[topWords[index]].length;
            if (lowestLikes>curLikes) {
                lowestLikes=curLikes;
                lowestId=topWords[index];
            }
        }

        // Complete the replacement
        if (lowestLikes<wordToLikeAddresses[wordId].length) {
            topWords[lowestId]=wordId;
        }
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
    
        uint256 count = 0;
        for (uint256 index = 0; index < topWords.length; index++) {
            address[] memory likes = wordToLikeAddresses[topWords[index]];
            bool liked = false;
            for (uint256 indexLike = 0; indexLike < likes.length; indexLike++) {
                if (likes[indexLike] == msg.sender) {
                    liked = true;
                }
            }
            wordIdArray[count] = index;
            titleArray[count] = words[topWords[index]].title;
            bodyArray[count] = words[topWords[index]].body;
            timestampArray[count] = words[topWords[index]].timestamp;
            totalLikesArray[count] = likes.length;
            likedArray[count] = liked;
            count++;
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
        for (uint256 index = words.length-1; index > words.length-51; index--) {
            address[] memory likes = wordToLikeAddresses[index];
            bool liked = false;
            for (uint256 indexLike = 0; indexLike < likes.length; indexLike++) {
                if (likes[indexLike] == msg.sender) {
                    liked = true;
                }
            }
            wordIdArray[count] = index;
            titleArray[count] = words[index].title;
            bodyArray[count] = words[index].body;
            timestampArray[count] = words[index].timestamp;
            totalLikesArray[count] = likes.length;
            likedArray[count] = liked;
            count++;
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
