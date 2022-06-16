import axios from 'axios';
import { joinResult } from '@urbit/api';
import { pushTransaction } from '@/api/books';
import { 
  Transaction,
  Navi,
  Note, 
  Address, 
  TxHash,
  WalletDetails,
} from "@/types";
import { Decimal } from 'decimal.js';
import Immutable, { OrderedMap } from 'immutable';
import { isTemplateNode } from '@vue/compiler-core';

export default {
  namespaced: true,
  state() {
    return {
      //  loading state
      hasUrbitSubscription: false as Boolean,
      
      //  state objects
      etherscanKey: '3NJSFSVR8PZRN6CTIIXERD88YBKCIXXMW7',
      havUrbData: false as boolean,
      urbitData: [] as Array<[[number, TxHash], Transaction]>,
      notes: [] as Array<[TxHash, Note]>,
      myFriends: [] as Array<[Address, WalletDetails]>,
      myWallets: [] as Array<[Address, {nickname: string, tags: Array<string>}]>,
      nav: 0 as Navi,
      transPage: 0 as number,
      browsing: '' as Address,
    }
  },

  getters: {
    friends(state): Array<string> {
      return ['test']
    },
    orderedTransactions(state): Array<[[number, TxHash], Transaction]> {
      const immuMap = Immutable.OrderedMap(state.urbitData) as OrderedMap<[number, TxHash], Transaction>;
      
      if (state.browsing === '') {
        return immuMap.sort((a: Transaction, b: Transaction) => {
          if (a.timeStamp > b.timeStamp) { return -1; }
          if (a.timeStamp < b.timeStamp) { return 1; }
          if (a.timeStamp == b.timeStamp) {
            if (a.hash > b.hash) { return -1; }
            if (a.hash < b.hash) { return 1; }
            else { return 0; }
          }
          else { return 0; }
        }).toArray() as Array<[[number, TxHash], Transaction]>;
      } else {
        
        const filtMap = Immutable.OrderedMap(state.urbitData.filter((a) => {
          if (a[1].primaryWallet === state.browsing) { return true; }
          else { return false; }
        })) as OrderedMap<[number, TxHash], Transaction>;

        return filtMap.sort((a: Transaction, b: Transaction) => {
          if (a.timeStamp > b.timeStamp) { return -1; }
          if (a.timeStamp < b.timeStamp) { return 1; }
          if (a.timeStamp == b.timeStamp) {
            if (a.hash > b.hash) { return -1; }
            if (a.hash < b.hash) { return 1; }
            else { return 0; }
          }
          else { return 0; }
        }).toArray() as Array<[[number, TxHash], Transaction]>;
      }




    },
    paginateTransactions: (state, getters) => {
      const sorted = getters.orderedTransactions;
      const begin = function() {if (state.transPage === 0) {
                                  return 1
                                } else {return (state.transPage-1)*25+1}}
      const allay = begin() + 24;
      console.log("displaying transaction range: ",begin(), allay)
      return sorted.slice(begin(), allay) as Array <[[number, TxHash], Transaction]>;
    },
    pageFrontTransactions: (state, getters) => {
      const sorted = getters.orderedTransactions;
      return sorted.slice(1, 5) as Array <[[number, TxHash], Transaction]>;
    },
  },

  mutations: {

    setBrowse(state, which) {
      console.log("wallet: ", which);
      state.browsing = which;
    },

    setTransPage(state, which) {
      console.log("page: ", which);
      state.transPage = which;
    },

    setNav(state, which) {
      console.log("tab: ", which);
      state.nav = which;
    },

    setWallets(state,
               battery: {
                 fren: Array<[Address, WalletDetails]>,
                 mine: Array<[Address, {nickname: string, tags: Array<string>}]>,
                }) {
      console.log("setting my-wallets: ", battery.mine);
      state.myWallets = Immutable.Map(state.myWallets).mergeDeepWith((olds, news) => {
        return news;
      }, Immutable.Map(battery.mine)).toArray();
      console.log("setting fren-wallets: ", battery.fren);
      state.myFriends = Immutable.Map(state.myFriends).mergeDeepWith((olds, news) => {
        return news;
      }, Immutable.Map(battery.fren)).toArray();
    },

    setTransactions(state,
                    battery: {
                      tran: Array<Transaction>,
                    }) {
      console.log("set-transaction");
      const newt = battery.tran.map(t => [[t.timeStamp, t.hash], t]) as Array<[[number, TxHash], Transaction]>;
      state.urbitData = state.urbitData.concat(newt.filter((item) => {
        return !Immutable.Map(state.urbitData).has(item[0]);
      }))
    },

    addWallet(state,
              battery: {
                new: [Address, {nickname: string, tags: Array<string>}],
              }) {
      console.log("add-wallet");
      state.myWallets = Immutable.Map(state.myWallets).mergeDeepWith((olds, news) => {
        return news;
      }, Immutable.Map([ battery.new ])).toArray();
    },

    delWallet(state,
              battery: {
                remove: Address,
              }) {
      console.log("del-wallet");
      state.myWallets = Immutable.Map(state.myWallets).delete(battery.remove).toArray();
    },

    addTransaction(state,
                    battery: {
                      trans: Transaction,
                    }) {
      console.log("add-Transaction");
      state.urbitData = Immutable.OrderedMap(state.urbitData).mergeDeepWith((olds, news) => {
        return news;
      }, Immutable.OrderedMap([[[battery.trans.timeStamp, battery.trans.hash], battery.trans]])).toArray();
    },
  },

  actions: {
    handleSwitchPage(
      { commit },
      battery: number) {
        commit("setTransPage", battery);
    },

    handleSwitchBrowse(
      { commit },
      battery: string) {
        commit("setBrowse", battery);
    },
    
    handleSwitchNav(
      { commit },
      battery: Navi) {
        commit("setNav", battery);
    },

    handleSetWallets(
      { commit, dispatch },
      battery: { 
        fren: Array<[Address, WalletDetails]>,
        mine: Array<[Address, {nickname: string, tags: Array<string>}]> }) {
      commit("setWallets",
             { fren: battery.fren,
               mine: battery.mine  });
    },
    handleSetTransactions(
      { commit },
      battery: {
        tran: Array<Transaction> }) {
      console.log("battery", battery.tran);
      commit("setTransactions",
             { tran: battery.tran });
    },
    handleAddWallet(
      { commit, dispatch },
      battery: {
        new: [Address, {nickname: string, tags: Array<string>}] }) {
      commit("addWallet",
             { new: battery.new });
    },
    handleDelWallet(
      { commit },
      battery: { remove: Address }) {
      commit("delWallet",
             { remove: battery.remove });
    },
    handleAddTransaction(
      { commit },
      battery: { transaction: Transaction }) {
      commit("addTransaction",
             { trans: battery.transaction });
    },
    // handleAddNote(
    //   { commit }
    // )
  }
}
