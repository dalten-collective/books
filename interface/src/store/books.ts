import {
  Transaction,
  Navi,
  Note,
  Address,
  TxHash,
  WalletDetails,
  Annotation,
} from '@/types';
import Immutable, { OrderedMap } from 'immutable';

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
      myWallets: [] as Array<[Address, { nick: string; tags: Array<string> }]>,
      nav: 0 as Navi,
      transPage: 0 as number,
      browsing: '' as Address,
    };
  },

  getters: {
    friends(state): Array<string> {
      return ['test'];
    },

    pageFrontTransactions: (state, getters) => {
      const sorted = getters.orderedTransactions;
      return sorted.slice(1, 5) as Array<[[number, TxHash], Transaction]>;
    },

    orderedTransactions(state): Array<[[number, TxHash], Transaction]> {
      const immuMap = Immutable.OrderedMap(state.urbitData) as OrderedMap<
        [number, TxHash],
        Transaction
      >;

      if (state.browsing === '') {
        return immuMap
          .sort((a: Transaction, b: Transaction) => {
            if (a.timeStamp > b.timeStamp) {
              return -1;
            }
            if (a.timeStamp < b.timeStamp) {
              return 1;
            }
            if (a.timeStamp == b.timeStamp) {
              if (a.hash > b.hash) {
                return -1;
              }
              if (a.hash < b.hash) {
                return 1;
              } else {
                return 0;
              }
            } else {
              return 0;
            }
          })
          .toArray() as Array<[[number, TxHash], Transaction]>;
      } else {
        const filtMap = Immutable.OrderedMap(
          state.urbitData.filter((a) => {
            if (a[1].primaryWallet === state.browsing) {
              return true;
            } else {
              return false;
            }
          })
        ) as OrderedMap<[number, TxHash], Transaction>;

        return filtMap
          .sort((a: Transaction, b: Transaction) => {
            if (a.timeStamp > b.timeStamp) {
              return -1;
            }
            if (a.timeStamp < b.timeStamp) {
              return 1;
            }
            if (a.timeStamp == b.timeStamp) {
              if (a.hash > b.hash) {
                return -1;
              }
              if (a.hash < b.hash) {
                return 1;
              } else {
                return 0;
              }
            } else {
              return 0;
            }
          })
          .toArray() as Array<[[number, TxHash], Transaction]>;
      }
    },
  },

  mutations: {
    setBrowse(state, which) {
      console.log('wallet: ', which);
      state.browsing = which;
    },

    setTransPage(state, which) {
      console.log('page: ', which);
      state.transPage = which;
    },

    setNav(state, which) {
      console.log('tab: ', which);
      state.nav = which;
    },

    setWallets(
      state,
      battery: {
        fren: Array<[Address, WalletDetails]>;
        mine: Array<[Address, { nickname: string; tags: Array<string> }]>;
      }
    ) {
      console.log('setting my-wallets: ', battery.mine);
      state.myWallets = Immutable.Map(state.myWallets)
        .mergeDeepWith((olds, news) => {
          return news;
        }, Immutable.Map(battery.mine))
        .toArray();
      console.log('setting fren-wallets: ', battery.fren);
      state.myFriends = Immutable.Map(state.myFriends)
        .mergeDeepWith((olds, news) => {
          return news;
        }, Immutable.Map(battery.fren))
        .toArray();
    },

    setTransactions(
      state,
      battery: {
        tran: Array<Transaction>;
      }
    ) {
      console.log('set-transaction');
      const newt = battery.tran.slice().map((t) => [[t.timeStamp, t.hash], t]) as Array<
        [[number, TxHash], Transaction]
      >;
      state.urbitData = state.urbitData.concat(
        newt.filter((item) => {
          return !Immutable.Map(state.urbitData).has(item[0]);
        })
      );
    },
    unSetTransactions (
      state,
      battery: {
        tran: Array<Transaction>;
      }
    ) {
      console.log('unset-transaction');
      const newt = battery.tran.slice().map((t) => [[t.timeStamp, t.hash], t]) as Array<
        [[number, TxHash], Transaction]
      >;
      state.urbitData = newt;
    },
    setAnnotations(
      state,
      battery: {
        notes: Array<[TxHash, Annotation]>;
      }
    ) {
      console.log('set-annotation');
      state.notes = state.notes.concat(
        battery.notes.filter((item) => {
          return !Immutable.Map(state.notes).has(item[0]);
        })
      );
    },

    addWallet(
      state,
      battery: {
        new: [Address, { nickname: string; tags: Array<string> }];
      }
    ) {
      console.log('add-wallet', battery.new[0]);
      state.myWallets = Immutable.Map(state.myWallets)
        .delete(battery.new[0])
        .set(battery.new[0], battery.new[1])
        .toArray();
    },

    delWallet(
      state,
      battery: {
        remove: Address;
      }
    ) {
      console.log('del-wallet', battery.remove);
      state.myWallets = Immutable.Map(state.myWallets)
        .delete(battery.remove)
        .toArray();
    },

    addFriend(
      state,
      battery: {
        new: [Address, WalletDetails];
      }
    ) {
      console.log('add-friend', battery.new[0]);
      state.myFriends = Immutable.Map(state.myFriends)
        .delete(battery.new[0])
        .set(battery.new[0], battery.new[1])
        .toArray();
    },

    delFriend(
      state,
      battery: {
        remove: Address;
      }
    ) {
      console.log('del-friend', battery.remove);
      state.myWallets = Immutable.Map(state.myFriends)
        .delete(battery.remove)
        .toArray();
    },

    addTransaction(
      state,
      battery: {
        trans: Transaction;
      }
    ) {
      console.log('add-Transaction', battery.trans);
      state.urbitData = Immutable.OrderedMap(state.urbitData)
        .mergeDeepWith((olds, news) => {
          return news;
        }, Immutable.OrderedMap([[[battery.trans.timeStamp, battery.trans.hash], battery.trans]]))
        .toArray();
    },
  },

  actions: {
    handleSwitchPage({ commit }, battery: number) {
      commit('setTransPage', battery);
    },

    handleSwitchBrowse({ commit }, battery: string) {
      commit('setBrowse', battery);
    },

    handleSwitchNav({ commit }, battery: Navi) {
      commit('setNav', battery);
    },

    handleSetWallets(
      { commit },
      battery: {
        fren: Array<[Address, WalletDetails]>;
        mine: Array<[Address, { nickname: string; tags: Array<string> }]>;
      }
    ) {
      commit('setWallets', { fren: battery.fren, mine: battery.mine });
    },
    handleSetAnnotation({ commit }, battery: { notes: Array<[TxHash, Note]> }) {
      console.log('battery', battery.notes);
      commit('setAnnotations', { notes: battery.notes });
    },
    handleSetTransactions(
      { commit },
      battery: {
        tran: Array<Transaction>;
      }
    ) {
      console.log('battery', battery.tran);
      commit('setTransactions', { tran: battery.tran });
    },
    handleUnSetTransactions(
      { commit },
      battery: {
        tran: Array<Transaction>;
      }
    ) {
      console.log('unsetting', battery.tran);
      commit('unSetTransactions', { tran: battery.tran })
    },
    handleAddWallet(
      { commit },
      battery: {
        new: [Address, { nickname: string; tags: Array<string> }];
      }
    ) {
      commit('addWallet', { new: battery.new });
    },
    handleDelWallet({ commit }, battery: { remove: Address }) {
      commit('delWallet', { remove: battery.remove });
    },
    handleAddFriend(
      { commit },
      battery: {
        new: [Address, WalletDetails];
      }
    ) {
      commit('addFriend', { new: battery.new });
    },
    handleDelFriend({ commit }, battery: { remove: Address }) {
      commit('delFriend', { remove: battery.remove });
    },
    handleAddTransaction({ commit }, battery: { transaction: Transaction }) {
      commit('addTransaction', { trans: battery.transaction });
    },
    // handleAddNote(
    //   { commit }
    // )
  },
};
