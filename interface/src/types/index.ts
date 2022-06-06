import { Decimal } from 'decimal.js';

export interface AgentSubscription {
  agentName: string;
  subscriptionNumber: number;
}

//  Wallet Detail
export interface WalletDetails {
  nick: string;
  who: string;
  tags: Array<string>;
}

//  Note Shape
export interface Note {
  basis: Decimal;
  annotation: string;
  tags: Array<string>;
}

//  Ethereum-Type Strings
export type Address = `/^0x([0-9a-f][0-9a-f])*$/I`;
export type TxHash = `/^0x([0-9a-f][0-9a-f])*$/I`;

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

