// pragma solidity ^0.8.0;

// import "truffle/Assert.sol";
// import "truffle/DeployedAddresses.sol";
// import "../SpeakWordManager.sol";

// contract TestSpeakWordManager {

//   Background public background;

//     // Run before every test function
//     function beforeEach() public {
//         background = new Background();
//     }

//     // Test that it stores a value correctly
//     function testItcreateWord() public {
//         uint value = 5;
//         background.createWord("title", "body");
//         // uint result = background.getValue(0);
//         // Assert.equal(result, value, "It should store the correct value");
//     }

//     // Test that it gets the correct number of values
//     function testItGetTopWords() public {
//         background.storeValue(99);
//         (uint256[50] memory wordIdArray, string[50] memory titleArray, string[50] memory bodyArray, uint32[50] memory timestampArray, uint256[50] memory totalLikesArray, bool[50] memory likedArray) = background.getTopWords();
//     }

//     // // Test that it stores multiple values correctly
//     // function testItStoresMultipleValues() public {
//     //     for (uint8 i = 0; i < 10; i++) {
//     //         uint value = i;
//     //         background.storeValue(value);
//     //         uint result = background.getValue(i);
//     //         Assert.equal(result, value, "It should store the correct value for multiple values");
//     //     }
//     // }
// }
