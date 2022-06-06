import { Map, OrderedMap } from 'immutable';
import axios from 'axios';
import { joinResult } from '@urbit/api';
import { 
  Transaction,
  Network,
  Direction,
  Note, 
  Address, 
  TxHash,
  SubTx,
  WalletDetails
} from "@/types";
import { Decimal } from 'decimal.js'
import Immutable from 'immutable'

export default {
  namespaced: true,
  state() {
    return {
      zapperUID: '96e0cc51-a62e-42ca-acee-910ea7d2a241',
      zapperPwd: '',
      etherscanKey: '3NJSFSVR8PZRN6CTIIXERD88YBKCIXXMW7',
      webData: {} as OrderedMap<number, Transaction>,
      urbitData: {} as OrderedMap<number, Transaction>,
      notes: {} as Map<TxHash, Note>,
      myFriends: {} as Map<Address, WalletDetails>,
      myWallets: {} as Map<Address, WalletDetails>,
      arTrans: [],
    }
  },

  getters: {
    friends(state): Array<string> {
      return ['test']
    },
  },

  mutations: {
    setArTrans(state, transactions) {
      state.arTrans = transactions
    },

    setWebData(state, transactions) {
      state.webData = Immutable.OrderedMap(transactions);
    },

    test({}, thing: string) {
      console.log("test: ", thing);
    }

  },

  actions: {
    fetchTransactions({ state, commit }) {
      const baseURL = "https://api.zapper.fi/v2/transactions?address=0xee884fE6D8955A12a91Be2ebe897E2FAEA76e594&addresses%5B%5D=0xee884fE6D8955A12a91Be2ebe897E2FAEA76e594"
      return new Promise((resolve, reject) => {
        axios({
          method: 'get',
          url: baseURL,
          auth: {
            username: state.zapperUID,
            password: state.zapperPwd,
          },
          //timeout: 60000,
          transformResponse: [function (data) {
            let stuff = JSON.parse(data);

            return stuff.data.map(function (item) {
              return [
                item.timeStamp, 
                {
                  network: item.network as Network,
                  hash: item.hash as TxHash,
                  blockNumber: item.blockNumber as number,
                  name: item.name as string,
                  direction: item.direction as Direction,
                  timeStamp: parseInt(item.timeStamp) as number,
                  symbol: item.symbol as string,
                  address: (() => {
                    if (item.address == '0x0000000000000000000000000000000000000000') {
                      return null
                    } else {
                      return item.address
                    } 
                  })() as Address | null,
                  amount: new Decimal(item.amount) as Decimal,
                  from: item.from as Address,
                  destination: item.destination as Address,
                  contract: item.contract as Address,
                  subTransactions: item.subTransactions.map(function (subm) {
                      if (item.address == '0x0000000000000000000000000000000000000000') {
                        return {
                          address: null,
                          amount: new Decimal(subm.amount) as Decimal,
                          symbol: subm.symbol,
                          type: subm.type as Direction,
                        }
                      } else {
                        return {
                          address: subm.address,
                          amount: new Decimal(subm.amount) as Decimal,
                          symbol: subm.symbol,
                          type: subm.type as Direction,
                        }
                      }
                    }),
                  nonce: item.nonce as number,
                  txGas: new Decimal(item.gas) as Decimal | null,
                  txGasLimit: new Decimal(item.gasLimit) as Decimal | null,
                  input: (() => {
                    if (item.input == '0x') {
                      return null
                    } else {
                      return item.input
                    }
                  })() as string | null,
                  cost: new Decimal(item.gas) as Decimal,
                  txSuccessful: item.txSuccessful as Boolean,
                  primaryWallet: item.account as Address,
                } as Transaction
              ];
            })
          }]
        })
          .then(function (response) {
            console.log(response);

            console.log()

            commit("setArTrans", response.data);
            commit("setWebData", response.data);
            // dispatch mutation x:
            //  e.g. add these transactions to the webUrbit state
          })
          .catch(e => {
            console.log(e);
          })
      })
    }
  }
}
