let { abi } = require("../build/contracts/FarmerRole.json");
let Web3 = require("web3");
var web3 = new Web3(Web3.givenProvider || "ws://localhost:7545");
let OWNER_ACC;
let contract;

async function init() {
  OWNER_ACC = '0xCfB503944c444648CD9030fE9841a2128fD3c6c9';
  contract = new web3.eth.Contract(abi, '0x4900d0Af10A2d33Abe00D33D43d51769e418aC8a');
  console.log(contract);
}

async function isFarmer(address) {
  let result = await contract.methods.isFarmer(address).call();
  console.log(result);
}

async function addFarmer() {
  try {
    contract.methods
      .addFarmer("0xb96a876fBa3587dcAd21Cc6eFb958DBC1B3608EB")
      .send({ from: OWNER_ACC })
      .then(function (receipt) {
        console.log(receipt);
      });
  } catch (error) {
    console.log(error.message);
  }
}

init();
isFarmer(OWNER_ACC);
