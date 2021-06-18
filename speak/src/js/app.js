
var speakCard = `
<div class="card" style="width: 18rem;">
  <div class="card-body">
    <h5 class="card-title">{{TITLE}}</h5>
    <p class="card-text">
    {{BODY}}
    </p>
    <a href="#" class="card-link">Card link</a>
    <a href="#" class="card-link">Another link</a>
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
      App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:7545');
      web3 = new Web3(App.web3Provider);
    }

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('SpeakIERC721.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract.
      // const abi = JSON.parse(data);
      App.contracts.SpeakIERC721 = new web3.eth.Contract(data['abi'], '0xD3A5F6149f20fdA15B1eA462855f3BdC4b807654');

      // Set the provider for our contract.
      // App.contracts.SpeakIERC721.setProvider(App.web3Provider);
    });
    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '#transferButton', App.handleTransfer);
    $(document).on('click', '#create-btn-input', App.handleCreate);
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
      console.log('get words');

      App.contracts.SpeakIERC721.methods.getWords(accountAddress).call({from: account}).then(function(result) {
        console.log(result);
        App.setWords(result)
      }).catch(function(err) {
        console.log(err.message);
      });
    // });
  },

  setWords: function(words) {
    console.log(words);
    $("#words-panel").empty()
    for (var wordIndex = 0; wordIndex < words[0].length; wordIndex++) {
      if (words[2][wordIndex] == "0") {
        break;
      }
      $("#words-panel").append(speakCard.replaceAll("{{BODY}}", words[1][wordIndex]).replaceAll("{{TITLE}}", words[0][wordIndex]));
    }
  }
  
};

$(function() {
  $(window).load(function() {
    App.init()
    window.setTimeout(App.getWords, 1000);
    
  });
});
