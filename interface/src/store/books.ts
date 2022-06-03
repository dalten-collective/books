import { Map, OrderedMap } from 'immutable';
import axios from 'axios';
import { Transaction, Note, Address, WalletDetails} from "@/types"

export default {
  state() {
    return {
      apiToken: '3NJSFSVR8PZRN6CTIIXERD88YBKCIXXMW7',
      webData: {} as OrderedMap<number, Transaction>,
      urbitData: {} as OrderedMap<number, Transaction>,
      notes: {} as Map<number, Note>,
      myFriends: {} as Map<Address, WalletDetails>,
      myWallets: {} as Map<Address, WalletDetails>,
    }
  },

  getters: {
    friends(state): Array<string> {
      return ['test']
    },
  },

  mutations: {
    test({}, thing: string) {
      console.log("test: ", thing);
    }
  },

  actions: {
    fetchTransactions() {
      const baseURL = "https://api.zapper.fi/v2/transactions?address=0xee884fE6D8955A12a91Be2ebe897E2FAEA76e594&addresses%5B%5D=0xee884fE6D8955A12a91Be2ebe897E2FAEA76e594"

      return new Promise((resolve, reject) => {

      })
    }
  }
}
