import airlock from "../api";
import BigNumber from "bignumber.js";

import {
  AgentSubscription,
  Address,
  TxHash,
  Direction,
  Network,
  Page,
  SubTx,
  Transaction,
} from "@/types";
import Decimal from "decimal.js";
import { basicProps } from "ant-design-vue/lib/layout/layout";

export default {
  namespaced: true,
  state() {
    return {
      subscriptions: [] as Array<AgentSubscription>,
    };
  },

  getters: {
    agentSubscriptions(state): Array<AgentSubscription> | [] {
      return state.subscriptions;
    },
  },

  mutations: {
    addSubscription(state, payload: AgentSubscription) {
      state.subscriptions.push(payload);
    },

    unsetSubscription(state, subscription: AgentSubscription) {
      console.log("unset subscription");
      const sub = state.subscriptions.find((s) => s === subscription);
      state.subscriptions = state.subscriptions.filter((s) => s != sub);
    },
  },

  actions: {
    openAirlockToAgent({ dispatch }, agentName: string) {
      dispatch("books/startAwaitingUrbitData", null, { root: true });
      airlock.openAirlockTo(
        agentName,
        (data: Page) => {
          // console.log("agentName ", agentName);
          // console.log("data", data);
          // console.log("%books-page: ", data);
          // console.log("status: ", data.status);
          // Remove hoon dots
          const regex = /\./g;
          switch (data.head) {
            case "wallets":
              const modFren = data.fren.map((fren) => [
                "0x" +
                  fren[0].split("0x")[1].replace(regex, "").padStart(40, "0"),
                fren[1],
              ]);
              const modMine = data.mine.map((mine) => [
                "0x" +
                  mine[0].split("0x")[1].replace(regex, "").padStart(40, "0"),
                mine[1],
              ]);

              return dispatch(
                "books/handleSetWallets",
                { fren: modFren, mine: modMine },
                { root: true }
              );
            case "add-wallet":
              const conType = [
                "0x" +
                  data.new[0]
                    .split("0x")[1]
                    .replace(regex, "")
                    .padStart(40, "0"),
                data.new[1],
              ];
              return dispatch(
                "books/handleAddWallet",
                { new: conType },
                { root: true }
              );
            case "del-wallet":
              const remType =
                "0x" +
                data.remove.split("0x")[1].replace(regex, "").padStart(40, "0");
              return dispatch(
                "books/handleDelWallet",
                { remove: remType },
                { root: true }
              );
            case "add-friend":
              return dispatch(
                "books/handleAddFriend",
                {
                  new: [
                    "0x" +
                      data.new[0]
                        .split("0x")[1]
                        .replace(regex, "")
                        .padStart(40, "0"),
                    data.new[1],
                  ],
                },
                { root: true }
              );
            case "del-friend":
              const fremType =
                "0x" +
                data.remove.split("0x")[1].replace(regex, "").padStart(40, "0");
              return dispatch(
                "books/handleDelFriend",
                { remove: fremType },
                { root: true }
              );
            case "annotation":
              const reformNote = data.new.slice().map((item) => {
                return [
                  "0x" +
                    item.hash
                      .split("0x")[1]
                      .replace(regex, "")
                      .padStart(64, "0"),
                  {
                    basis: new Decimal(item.basis.split(".~")[1]),
                    to: [
                      item.to !== null
                        ? "0x" +
                          item.to
                            .split("0x")[1]
                            .replace(regex, "")
                            .padStart(40, "0")
                        : null,
                    ],
                    annotation: item.annotation,
                    tags: item.tags,
                  },
                ];
              });
              return dispatch(
                "books/handleSetAnnotation",
                { notes: reformNote },
                { root: true }
              );
            case "transactions":
              const reformTran = data.tran.map(function (tran) {
                return {
                  network: tran.network as Network,
                  hash: ("0x" +
                    tran.hash
                      .split("0x")[1]
                      .replace(regex, "")
                      .padStart(64, "0")) as TxHash,
                  blockNumber: tran.blocknumber,
                  name: tran.name,
                  direction: tran.direction as Direction,
                  timeStamp: tran.timestamp,
                  symbol: tran.symbol,
                  address: (() => {
                    if (tran.address === null) {
                      return null;
                    } else {
                      return ("0x" +
                        tran.address
                          .split("0x")[1]
                          .replace(regex, "")
                          .padStart(40, "0")) as Address;
                    }
                  })() as Address | null,
                  amount: new Decimal(tran.amount),
                  from:
                    "0x" +
                    tran.from
                      .split("0x")[1]
                      .replace(regex, "")
                      .padStart(40, "0"),
                  destination:
                    "0x" +
                    tran.destination
                      .split("0x")[1]
                      .replace(regex, "")
                      .padStart(40, "0"),
                  contract: (() => {
                    if (tran.contract === null) {
                      return null as null;
                    } else {
                      return ("0x" +
                        tran.contract
                          .split("0x")[1]
                          .replace(regex, "")
                          .padStart(40, "0")) as Address;
                    }
                  })() as unknown as Address | null,
                  subTransactions: tran.subtransactions.map((subt) => {
                    return {
                      type: subt.type as unknown as Direction,
                      symbol: subt.symbol,
                      amount: new Decimal(subt.amount) as Decimal,
                      address: (() => {
                        if (tran.address === null) {
                          return null as null;
                        } else {
                          return ("0x" +
                            tran.address
                              .split("0x")[1]
                              .replace(regex, "")
                              .padStart(40, "0")) as Address;
                        }
                      })() as unknown as Address | null,
                    } as SubTx;
                  }),
                  nonce: tran.nonce,
                  txGas: (() => {
                    if (tran.txgas === null) {
                      return null as null;
                    } else {
                      return new Decimal(tran.txgas) as Decimal;
                    }
                  })() as unknown as Decimal | null,
                  txGasLimit: (() => {
                    if (tran.txgaslimit === null) {
                      return null as null;
                    } else {
                      return new Decimal(tran.txgaslimit) as Decimal;
                    }
                  })() as unknown as Decimal | null,
                  input: (() => {
                    if (tran.input === null) {
                      return null as null;
                    } else {
                      return tran.input as string;
                    }
                  })() as unknown as string | null,
                  fee: new Decimal(tran.fee),
                  txSuccessful: tran.txsuccessful,
                  primaryWallet:
                    "0x" +
                    tran.primarywallet
                      .split("0x")[1]
                      .replace(regex, "")
                      .padStart(40, "0"),
                } as Transaction;
              });
              return dispatch(
                "books/handleSetTransactions",
                { tran: reformTran },
                { root: true }
              );
            case "add-transaction":
              const reformTrans = {
                network: data.transaction.network as Network,
                hash: ("0x" +
                  data.transaction.hash
                    .split("0x")[1]
                    .replace(regex, "")
                    .padStart(64, "0")) as TxHash,
                blockNumber: data.transaction.blocknumber,
                name: data.transaction.name,
                direction: data.transaction.direction as Direction,
                timeStamp: data.transaction.timestamp,
                symbol: data.transaction.symbol,
                address: (() => {
                  if (data.transaction.address === null) {
                    return null as null;
                  } else {
                    return ("0x" +
                      data.transaction.address
                        .split("0x")[1]
                        .replace(regex, "")
                        .padStart(40, "0")) as Address;
                  }
                }) as unknown as Address | null,
                amount: new Decimal(data.transaction.amount),
                from: data.transaction.from
                  .split("0x")[1]
                  .replace(regex, "")
                  .padStart(40, "0"),
                destination:
                  "0x" +
                  data.transaction.destination
                    .split("0x")[1]
                    .replace(regex, "")
                    .padStart(40, "0"),
                contract: (() => {
                  if (data.transaction.contract === null) {
                    return null as null;
                  } else {
                    return ("0x" +
                      data.transaction.contract
                        .split("0x")[1]
                        .replace(regex, "")
                        .padStart(40, "0")) as Address;
                  }
                }) as unknown as Address | null,
                subTransactions: data.transaction.subtransactions.map(
                  (subt) => {
                    return {
                      type: subt.type as unknown as Direction,
                      symbol: subt.symbol,
                      amount: new Decimal(subt.amount) as Decimal,
                      address: (() => {
                        if (data.transaction.address === null) {
                          return null as null;
                        } else {
                          return ("0x" +
                            data.transaction.address
                              .split("0x")[1]
                              .replace(regex, "")
                              .padStart(40, "0")) as Address;
                        }
                      }) as unknown as Address | null,
                    } as SubTx;
                  }
                ),
                nonce: data.transaction.nonce,
                txGas: (() => {
                  if (data.transaction.txgas === null) {
                    return null as null;
                  } else {
                    return new Decimal(data.transaction.txgas) as Decimal;
                  }
                }) as unknown as Decimal | null,
                txGasLimit: (() => {
                  if (data.transaction.txgaslimit === null) {
                    return null as null;
                  } else {
                    return new Decimal(data.transaction.txgaslimit) as Decimal;
                  }
                }) as unknown as Decimal | null,
                input: (() => {
                  if (data.transaction.input === null) {
                    return null as null;
                  } else {
                    return data.transaction.input as string;
                  }
                }) as unknown as string | null,
                fee: new Decimal(data.transaction.fee),
                txSuccessful: data.transaction.txsuccessful,
                primaryWallet:
                  "0x" +
                  data.transaction.primarywallet
                    .split("0x")[1]
                    .replace(regex, "")
                    .padStart(40, "0"),
              } as unknown as Transaction;
              return dispatch(
                "books/handleAddTransaction",
                { transaction: reformTrans },
                { root: true }
              );
          }
        },
        (subscriptionNumber: number) => {
          console.log("got subscription number ", subscriptionNumber);
          dispatch("addSubscription", {
            agentName,
            subscriptionNumber,
          } as AgentSubscription);
        }
      );
    },

    removeSubscription({ commit }, subscription: AgentSubscription) {
      console.log("removesub");
      commit("unsetSubscription", subscription);
    },

    addSubscription({ state, commit, dispatch }, payload: AgentSubscription) {
      const existing: Array<AgentSubscription> | [] =
        state.subscriptions.filter((s: AgentSubscription) => {
          return s.agentName === payload.agentName;
        });
      existing.forEach((sub) => {
        dispatch("removeSubscription", sub);
      });
      commit("addSubscription", payload);
    },

    closeAgentAirlocks({ commit, getters }) {
      const agentSubscriptions: Array<AgentSubscription> | [] =
        getters.agentSubscriptions;
      agentSubscriptions.forEach((sub) => {
        airlock.closeAirlock(sub.subscriptionNumber, [
          commit("unsetSubscription", sub),
        ]);
      });
    },
  },
};
