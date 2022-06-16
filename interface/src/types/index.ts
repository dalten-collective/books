import { KilnDiff } from '@urbit/api';
import BigNumber from 'bignumber.js';
import { Decimal } from 'decimal.js';
import Immutable, { Map, OrderedMap } from "immutable";

//  Sidebar
export enum Navi {
  home,
  wallets,
  transactions,
  rolodex,
}

//  Using Tagged Unions in TypeScript to mirror /books/sur/page
//  see: https://mariusschulz.com/blog/tagged-union-types-in-typescript#:~:text=TypeScript%202.0%20implements%20a%20rather%20useful%20feature:%20tagged,define%20a%20discriminant%20property%20of%20a%20literal%20type.
export type Page =
 |  Wallets
 |  Transactions
 |  ChangeZapperCred
 |  EtherscanKey
 |  AddTransaction
 |  AddWallet
 |  DelWallet
 |  AddFriend
 |  DelFriend
 |  Annotation
 |  DelANote
 |  JustStatus;

// Interfaces for Tagged Union
export interface Wallets {
  head: 'wallets'
  fren: Array<[string, WalletDetails]>,
  mine: Array<[string, {nick: string, tags: Array<string>}]>,
}
export interface Transactions {
  head: 'transactions',
  tran: Array<{
    network: Network,
    hash: string,
    blocknumber: number,
    name: string,
    direction: Direction,
    timestamp: number,
    symbol: string,
    address: string | null,
    amount: string,
    from: string,
    destination: string,
    contract: string | null,
    subtransactions: Array<{type: string, symbol: string, amount: string, address: string | null}>,
    nonce: number,
    txgas: string | null,
    txgaslimit: string | null,
    input: string | null,
    cost: string,
    txsuccessful: boolean,
    primarywallet: string,
  }>
}
// We don't really need this in the front end.
// export interface ChangeZapperCred {
//   head: 'change-zapper-cred',
//   uid: string,
//   pwd: string,
//   status: string,
// }
export interface EtherscanKey {
  head: 'etherscan-key',
  key: string,
  status: string,
}
export interface AddTransaction {
  head: 'add-transaction',
  status: string,
  transaction: {
    network: Network,
    hash: string,
    blocknumber: number,
    name: string,
    direction: Direction,
    timestamp: number,
    symbol: string,
    address: string | null,
    amount: string,
    from: string,
    destination: string,
    contract: string | null,
    subtransactions: Array<{type: string, symbol: string, amount: string, address: string | null}>,
    nonce: number,
    txgas: string | null,
    txgaslimit: string | null,
    input: string | null,
    cost: string,
    txsuccessful: boolean,
    primarywallet: string,
  },
}
export interface AddWallet {
  head: 'add-wallet',
  new: [string, {nick: string, tags: Array<string>}],
  status: string,
}
export interface DelWallet {
  head: 'del-wallet'
  remove: string,
  status: string,
}
export interface AddFriend {
  head: 'add-friend',
  new: [string, WalletDetails],
  status: string,
}
export interface DelFriend {
  head: 'del-friend',
  remove: string,
  status: string,
}
export interface Annotation {
  head: 'annotation',
  new: Array<[TxHash, Note]>,
  status: string,
}
export interface DelANote{
  head: 'del-a-note',
  remove: TxHash,
  status: string,
}
export interface JustStatus{
  head: 'just-status',
  status: string,
}


//  ship
export interface AgentSubscription {
  agentName: string;
  subscriptionNumber: number;
}


//    FE State
//  Wallet Detail
export interface WalletDetails {
  nick: string;
  who: string;
  tags: Array<string>;
}

//  Note Shape
export interface Note {
  basis: Decimal;
  to: Address | null;
  annotation: string;
  tags: Array<string>;
}

//  Ethereum-Type Strings
export type Address = `/^0x[a-fA-F0-9]{40}$/`;
export type TxHash = `/^0x[a-fA-F0-9]{64}$/`;

//  Supported Networks
export enum Network {
  ethereum,
  polygon,
  optimism,
  gnosis,
  binanceSmartChain,
  fantom,
  avalanche,
  arbitrum,
  celo,
  harmony,
  moonriver,
  bitcoin,
  cronos,
  aurora,
  evmos,
}

//  Transaction Direction
export enum Direction {
  incoming,
  outgoing,
  exchange,
}

//  Multi-call Support
export interface SubTx {
  type: Direction;
  symbol: string;
  amount: Decimal;
  address: Address | null;
}

//  Transaction Shape
export interface Transaction {
  network: Network;
  hash: TxHash;
  blockNumber: number;
  name: string;
  direction: Direction;
  timeStamp: number;
  symbol: string;
  address: Address | null;  //  dis the primary contract action, null for base product
  amount: Decimal;
  from: Address;
  destination: Address;
  contract: Address | null;
  subTransactions: Array<SubTx>;
  nonce: number;
  txGas: Decimal | null;
  txGasLimit: Decimal | null;
  input: string | null;
  cost: Decimal;
  txSuccessful: boolean;
  primaryWallet: Address;
}

