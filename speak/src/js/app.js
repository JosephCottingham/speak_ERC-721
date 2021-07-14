CONTRACT_ADRESS='0x0AAE1F042CAbbC1D719E23b992b7857a0359C3dD'

var speakCardBase = `
<div class="col-sm-4">
  <div class="card">
    <div class="card-body">
      <h5 class="card-title">{{TITLE}}</h5>
      <p class="card-text">
      {{BODY}}
      </p>
    </div>
    {{TIMESTAMP}} --- {{LIKES}}
  </div>
</div>
`

var speakCardWithLike = `
<div class="col-sm-4">
  <div class="card">
    <div class="card-body">
      <h5 class="card-title">{{TITLE}}</h5>
      <p class="card-text">
      {{BODY}}
      </p>
      <button wordId="{{WORDID}}" class="btn btn-primary like-btn">Like</button>
    </div>
    {{TIMESTAMP}} --- {{LIKES}}
  </div>
</div>
`

var speakCardWithLikeDisable = `
<div class="col-sm-4">
  <div class="card">
    <div class="card-body">
      <h5 class="card-title">{{TITLE}}</h5>
      <p class="card-text">
      {{BODY}}
      </p>
      <button wordId="{{WORDID}}" class="btn btn-primary like-btn" disabled>Like</button>
    </div>
    {{TIMESTAMP}} --- {{LIKES}}
  </div>
</div>
`

App = {

  web3Provider: null,
  contracts: {},

  init: function() {
    console.log('init')
    return App.initWeb3();
  },

  initWeb3: function() {
    // Initialize web3 and set the provider to the testRPC.
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(App.web3Provider);
    } else {
      // set the provider you want from Web3.providers
      // App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:7545');
      App.web3Provider = new Web3.providers.HttpProvider('https://eth-rinkeby.alchemyapi.io/v2/AzEoPVLVtvDF6IB_sWrBInxeIPYKjJ-Z');
      web3 = new Web3(App.web3Provider);
    }

    return App.initContract();
  },
  
  initContract: function() {
    $.getJSON('https://staticsites-joe-ms.s3.amazonaws.com/build/contracts/Speak.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      // const abi = JSON.parse(data);
      App.contracts.SpeakIERC721 = new web3.eth.Contract(data['abi'], CONTRACT_ADRESS);

      // Set the provider for our contract.
      // App.contracts.SpeakIERC721.setProvider(App.web3Provider);
    });
    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '#transferButton', App.handleTransfer);
    $(document).on('click', '#create-btn-input', App.handleCreate);
    $(document).on('click', '.like-btn', App.likeWord);
  },

  handleCreate: async function(event) {
    event.preventDefault();
    const title = $("#title-input").val();
    $("#title-input").val("");
    const body = $("#body-input").val();
    $("#body-input").val("");
    console.log(`${title} : ${body}`)

    var accounts = await ethereum.request({ method: 'eth_requestAccounts' });
    console.log(accounts);
    var account = accounts[0];
    App.contracts.SpeakIERC721.methods.createWord(title, body).send({from: account, gas: '6721975'}).then(function(result) {
      alert('Creation Successful!');
      console.log(result);
    }).catch(function(err) {
      console.log(err.message);
    });
  },

  handleTransfer: function(event) {
    event.preventDefault();

    var amount = parseInt($('#TTTransferAmount').val());
    var toAddress = $('#TTTransferAddress').val();

    console.log('Transfer ' + amount + ' TT to ' + toAddress);

    var speakIERC721Instance;

    web3.eth.getAccounts(function(error, accounts) {
      if (error) {
        console.log(error);
      }

      var account = accounts[0];

      App.contracts.SpeakIERC721.deployed().then(function(instance) {
        speakIERC721Instance = instance;

        return speakIERC721Instance.createWord(title, body, {from: account, gas: 100000});
      }).then(function(result) {
        alert('Word Create Successful!');
        return true;
      }).catch(function(err) {
        console.log(err.message);
      });
    });
  },

  getWords: async function(accountAddress) {
    // return new Promise((resolve, reject) => {
      console.log('Getting words...');    
      var accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      console.log(accounts);
      var account = accounts[0];
      if (accountAddress == null) {
        accountAddress = accounts[0];
      }
      console.log(accountAddress);
      console.log('getWords');

      App.contracts.SpeakIERC721.methods.getWords(accountAddress).call({from: account}).then(function(result) {
        console.log(result);
        App.setWords(result)
      }).catch(function(err) {
        console.log(err.message);
      });
    // });
  },

  getTopWords: async function(accountAddress) {
    // return new Promise((resolve, reject) => {
      console.log('Getting words...');    
      var accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      console.log(accounts);
      var account = accounts[0];
      if (accountAddress == null) {
        accountAddress = accounts[0];
      }
      console.log(accountAddress);
      console.log('getTopWords');

      App.contracts.SpeakIERC721.methods.getTopWords().call({from: account}).then(function(result) {
        console.log(result);
        App.setWords(result)
      }).catch(function(err) {
        console.log(err.message);
      });
    // });
  },

  getRecentWords: async function(accountAddress) {
    // return new Promise((resolve, reject) => {
      console.log('Getting words...');    
      var accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      console.log(accounts);
      var account = accounts[0];
      if (accountAddress == null) {
        accountAddress = accounts[0];
      }
      console.log(accountAddress);
      console.log('getRecentWords');

      App.contracts.SpeakIERC721.methods.getRecentWords().call({from: account}).then(function(result) {
        console.log(result);
        App.setWords(result)
      }).catch(function(err) {
        console.log(err.message);
      });
    // });
  },

  likeWord: async function(likeBtn) {
      console.log(likeBtn.target);
      var wordId = parseInt(likeBtn.target.getAttribute('wordId'));
      // return new Promise((resolve, reject) => {
      console.log(`Liking Word... ID: ${wordId}`);    
      var accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      console.log(accounts);
      var account = accounts[0];
      console.log(account);

      App.contracts.SpeakIERC721.methods.like(wordId).call({from: account}).then(function(result) {
        console.log(result);
      }).catch(function(err) {
        console.log(err.message);
      });
    // // });
  },
  setWords: function(words) {
    console.log(words);
    $("#words-panel").empty()
    for (var wordIndex = 0; wordIndex < words[0].length; wordIndex++) {
      if (words['timestampArray'][wordIndex] == "0") {
        break;
      }
      card = speakCardBase;
      console.log();
      var date = new Date(words['timestampArray'][wordIndex]*1000)
      if (words['likedArray'] !=  undefined && words['likedArray'][wordIndex] != undefined) {
        card = speakCardWithLike;
        if (words['likedArray'][wordIndex] == true) {
          card = speakCardWithLikeDisable;
        }
        $("#words-panel").append(card.replaceAll("{{LIKES}}", words['totalLikesArray'][wordIndex]).replaceAll("{{WORDID}}", words['wordIdArray'][wordIndex]).replaceAll("{{BODY}}", words['bodyArray'][wordIndex]).replaceAll("{{TITLE}}", words['titleArray'][wordIndex]).replaceAll("{{TIMESTAMP}}", date.toDateString()).replaceAll("{{WORDID}}", words['wordIdArray'][wordIndex]));
      } else {
        $("#words-panel").append(card.replaceAll("{{WORDID}}", words['wordIdArray'][wordIndex]).replaceAll("{{BODY}}", words['bodyArray'][wordIndex]).replaceAll("{{TITLE}}", words['titleArray'][wordIndex]).replaceAll("{{TIMESTAMP}}", date.toDateString()).replaceAll("{{WORDID}}", words['wordIdArray'][wordIndex]));
      }
    }
  }
  
};
