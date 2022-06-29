import urbitAPI from './urbitAPI';
import { Scry } from '@urbit/http-api';
import { Transaction, Address } from '@/types';

export function pushWallet(address: Address, nick: string) {
  return urbitAPI
    .poke({
      app: 'books',
      mark: 'books-page',
      json: { 'add-wallet': { address, nick, tags: [] } },
    })
    .then((r) => {
      return r;
    })
    .catch((e) => {
      console.log('err ', e);
    });
};

export function pullWallet(address: Address) {
  return urbitAPI
    .poke({
      app: 'books',
      mark: 'books-page',
      json: { 'del-wallet': { address } },
    })
    .then((r) => {
      return r;
    })
    .catch((e) => {
      console.log('err ', e);
    });
};

export function pushTags(address: Address, tags: []) {
  return urbitAPI
    .poke({
        app: 'books',
        mark: 'books-page',
        json: { 'set-tags': { address: address, tags: tags } },      
    })
};

export function pushName(address: Address, name: string) {
  return urbitAPI
    .poke({
      app: 'books',
      mark: 'books-page',
      json: { 'set-nick': { address: address, nick: name}}
    })
}

export function pushTransaction(trans: Transaction) {
  const reformTrans = {
    network: trans.network,
    hash: trans.hash,
    blocknumber: trans.blockNumber,
    name: trans.name,
    direction: trans.direction,
    timestamp: trans.timeStamp,
    symbol: trans.symbol,
    address: trans.address,
    amount: trans.amount.toString(),
    from: trans.from,
    destination: trans.destination,
    contract: trans.contract,
    subtransactions: trans.subTransactions.map((subt) => {
      return {
        address: subt.address,
        amount: subt.amount.toString(),
        symbol: subt.symbol,
        type: subt.type,
      };
    }),
    nonce: trans.nonce,
    txgas: trans.txGas?.toString(),
    txgaslimit: trans.txGasLimit?.toString(),
    input: trans.input,
    fee: trans.fee.toString(),
    txsuccessful: trans.txSuccessful,
    primarywallet: trans.primaryWallet,
  };
  console.log(reformTrans);
  urbitAPI
    .poke({
      //   return {
      app: 'books',
      mark: 'books-page',
      json: { 'add-transaction': reformTrans },
      //   }
    })
    .then((r) => {
      console.log('res ', r);
    })
    .catch((e) => {
      console.log(reformTrans);
      console.log('err ', e);
    });
};
