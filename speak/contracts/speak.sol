pragma solidity ^0.8.0;

import "./ownable.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeCast.sol";
import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract Speak is Ownable {

    using SafeMath for uint256;
    
    event NewWord(uint wordId, string title, string body);

    uint createWordFee = 0.001 ether;


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

    mapping (uint => address[]) wordToLikeAddresses;
    mapping (uint => address) wordToOwner;
    mapping (address => uint) ownerToBal;

    Word[] public words;
    address[] public speakers;

    uint256[50] public topWords;

    constructor() {
        string memory first_word = "If liberty means anything at all, it means the right to tell people what they do not want to hear. ~ George Orwell";
        _createWord("Liberty of Words.", first_word);
        speakers.push(owner);
    }


    function _createWord(string memory _title, string memory _body) internal {
        require(ownerToBal[msg.sender] < 12);
        Word memory newWord = Word(_title, _body, uint32(block.timestamp));
        words.push(newWord);
        uint256 id = words.length;
        wordToOwner[id] = msg.sender;
        ownerToBal[msg.sender] = ownerToBal[msg.sender] + 1;
        emit NewWord(id, _title, _body);
    }

    function createWord(string memory _title, string memory _body) external payable {
        _createWord(_title, _body);
    }

    function like(uint256 wordId) external {
        address[] storage wordLikes = wordToLikeAddresses[wordId];
        for (uint256 index = 0; index < wordLikes.length; index++) {
            if (msg.sender == wordLikes[index]) {
                return;
            }
        }
        wordToLikeAddresses[wordId].push(msg.sender);
        configTopWords(wordId);
    }

    function configTopWords(uint256 wordId) internal {
        // Confirm there is a word in topWord list
        if (topWords.length == 0) {
            topWords[0] = wordId;
            return;
        }
        uint256 lowestLikes=wordToLikeAddresses[topWords[0]].length;
        uint256 lowestId=topWords[0];
        for (uint256 index = 1; index < topWords.length; index++) {
            uint256 curLikes = wordToLikeAddresses[topWords[index]].length;
            if (lowestLikes>curLikes) {
                lowestLikes=curLikes;
                lowestId=topWords[index];
            }
        }
        if (lowestLikes<wordToLikeAddresses[wordId].length) {
            topWords[lowestId]=wordId;
        }
    }


    function getTopWords() external view returns (WordExtended[50] memory wordsExtended) {
        WordExtended[50] memory wordsExtended;
        for (uint256 index = 0; index < topWords.length; index++) {
            address[] memory likes = wordToLikeAddresses[topWords[index]];
            bool liked = false;
            for (uint256 indexLike = 0; indexLike < likes.length; indexLike++) {
                if (likes[indexLike] == msg.sender) {
                    liked = true;
                }
            }

            wordsExtended[index] = WordExtended(words[topWords[index]].title, words[topWords[index]].body,words[topWords[index]].timestamp, likes.length, liked);
        }
        return wordsExtended;
    }

    function getWords(address owner) external view returns (string[12] memory titleArray, string[12] memory bodyArray, uint32[12] memory timestampArray) {
        string[12] memory titleArray;
        string[12] memory bodyArray;
        uint32[12] memory timestampArray;
        
        uint256 count = 0;
        for (uint256 index = 0; index < words.length; index++) {
            if (owner == wordToOwner[index]) {
                titleArray[count] = words[index].title;
                bodyArray[count] = words[index].body;
                timestampArray[count] = words[index].timestamp;
                count++;
            }
        }
        return (titleArray, bodyArray, timestampArray);
    } 

    function getAllWords() external view returns (Word[] memory words) {
        return words;
    } 


    function setCreateWordFee(uint _fee) external onlyOwner {
        createWordFee = _fee;
    }

}
