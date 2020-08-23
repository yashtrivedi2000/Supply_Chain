const path = require('path')
const fs = require('fs')
const solc = require('solc')

const inboxpath = path.resolve(__dirname, 'contracts', 'Inbox.sol');
const sourceCode = fs.readFileSync(inboxpath, 'utf8');
module.export = solc.compile(sourceCode, 1).contracts[':Inbox'];
