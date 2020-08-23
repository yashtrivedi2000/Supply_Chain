const assert = require('assert')
const ganache = require('ganache-cli')
const Web3 = require('web3');
const { describe, it } = require('mocha');
const web3 = new Web3(ganache.provider());
const { interface, bytecode } = require('../compile')
let accounts;
var inbox;
beforeEach(async () => {
    accounts = await web3.eth.getAccounts()
    console.log(bytecode)
    /* inbox = await new web3.eth.Contract(JSON.parse(interface)).
        deploy({ "data": "bytecode", "arguments": ['Hello'] }).
        send({ "from": accounts[1], "gas": '10000000' })
    console.log(inbox); */
});
describe('Dummy', () => {
    it('DummyTest', () => {
        console.log(interface)
    })
})