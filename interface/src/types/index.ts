import { BigNumber } from 'ethers';

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
  basis: BigNumber;
  annotation: string;
  tags: Array<string>;
}

//  Ethereum-Type Strings
export type Address = `/^0x([0-9a-f][0-9a-f])*$/I`;
type txHash = `/^0x([0-9a-f][0-9a-f])*$/I`;

//  Supported Networks
enum Network {
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
enum Direction {
  incoming,
  outgoing,
  exchange,
}

//  Multi-call Support
interface SubTx {
  type: Direction;
  symbol: string;
  amount: BigNumber;
  address: Address;
}

//  Transaction Shape
export interface Transaction {
  network: Network;
  hash: txHash;
  blockNumber: number;
  name: string;
  direction: Direction;
  timeStamp: number;
  symbol: string;
  address: Address | null;  //  dis the primary contract action, null for base product
  amount: BigNumber;
  from: Address;
  destination: Address;
  contract: Address | null;
  subTransactions: Array<SubTx>;
  nonce: number;
  txGas: BigNumber | null;
  txGasLimit: BigNumber | null;
  input: string | null;
  cost: BigNumber;
  txsuccessful: boolean;
  primaryWallet: Address;
}

