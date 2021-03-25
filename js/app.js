let farmerRole = require("../build/contracts/FarmerRole.json")['abi'];
let distributerRole = require('../build/contracts/DistributorRole.json')['abi'];
let Web3 = require("web3");
var web3 = new Web3(Web3.givenProvider || "ws://localhost:7545");
let OWNER_ACC;
let farmerContract;

async function init() {
  //Change everytime we run
  OWNER_ACC = '0x08F8A3fFc4EaD77702888B0f9ea7aca2f0dc5cA6';
  //Change everytime we run
  farmerContract = new web3.eth.Contract(farmerRole, '0xAeA55E4dFeF1820d973793A62Aa6C28a96948b40');
  //console.log(contract);
}

async function isFarmer(address) {
  let result = await farmerContract.methods.isFarmer(address).call();
  console.log(result);
}

async function addFarmer() {
  try {
    farmerContract.methods
      .addFarmer("0xb96a876fBa3587dcAd21Cc6eFb958DBC1B3608EB")
      .send({ from: OWNER_ACC })
      .then(function (receipt) {
        console.log(receipt);
      });
  } catch (error) {
    console.log(error.message);
  }
}
try {
  
  init();
  isFarmer(OWNER_ACC).then(()=>{
          console.log('<---EXIT--->');
          process.exit();
  });
} catch (error) {
  console.log(error.message);
}

