<template>
  <a-table
    :columns="columns"
    :data-source="data"
    :scroll="{ x: 1000 }"
    expand-row-by-click
    :loading="awaitingUrbitData"
  >
    <template #dateColumn="{ record }">
      <div class="grid grid-cols-1 gap-2">
        <div>
          {{ record.timeStamp.split(" ")[0] }}
        </div>
      </div>
    </template>

    <template #noteColumn="{ record }">
      <div class="grid grid-cols-1">
        <a-tooltip placement="topRight">
          <template
            #title
            v-if="
              recordAnnotation(record) != '' ||
              (annotations(record).tags && annotations(record).tags.length > 0)
            "
          >
            <div v-if="recordAnnotation(record)">
              <span>{{ recordAnnotation(record) }}</span>
              <br />
            </div>
            <span v-if="annotations(record).tags.length > 0"
              >Tags: {{ annotations(record).tags.join(", ") }}</span
            >
          </template>
          <form-outlined v-if="hasNote(record)" :style="{ color: '#EAB304' }" />
        </a-tooltip>
      </div>
    </template>

    <template #addressColumn="{ record }">
      <div class="flex flex-row">
        <AddressLookup :addy="record.primaryWallet" class="mr-2" />
      </div>
    </template>

    <template #counterpartyColumn="{ record }">
      <div class="flex flex-row">
        <div v-if="recordCounterparties(record).length > 0">
          <AddressLookup
            v-for="cp in recordCounterparties(record)"
            :key="cp"
            :addy="cp"
          />
        </div>
      </div>
    </template>

    <template #currencyInColumn="{ record }">
      <div class="grid grid-cols-1 gap-2">
        <div>
          <div class="flex flex-row">
            <div class="text-sm text-green-500">
              {{ presentFlow(getInflow(record.involvedCurrencies)) }}
            </div>
          </div>
        </div>
      </div>
    </template>

    <template #currencyOutColumn="{ record }">
      <div class="grid grid-cols-1 gap-2">
        <div>
          <div class="flex flex-row">
            <div class="text-sm text-red-500">
              {{ presentFlow(getOutflow(record.involvedCurrencies)) }}
            </div>
          </div>
        </div>
      </div>
    </template>

    <template #actionsColumn="{ record }">
      <a-tooltip title="View on etherscan">
        <a :href="'https://etherscan.io/tx/' + record.hash" target="_blank">
          <div class="flex flex-row">
            <span class="pr-2">
              {{ record.shortDescription }}
            </span>
            <svg height="20" width="20" viewBox="0 0 30 30">
              <path
                d="M 25.980469 2.9902344 A 1.0001 1.0001 0 0 0 25.869141 3 L 20 3 A 1.0001 1.0001 0 1 0 20 5 L 23.585938 5 L 13.292969 15.292969 A 1.0001 1.0001 0 1 0 14.707031 16.707031 L 25 6.4140625 L 25 10 A 1.0001 1.0001 0 1 0 27 10 L 27 4.1269531 A 1.0001 1.0001 0 0 0 25.980469 2.9902344 z M 6 7 C 4.9069372 7 4 7.9069372 4 9 L 4 24 C 4 25.093063 4.9069372 26 6 26 L 21 26 C 22.093063 26 23 25.093063 23 24 L 23 14 L 23 11.421875 L 21 13.421875 L 21 16 L 21 24 L 6 24 L 6 9 L 14 9 L 16 9 L 16.578125 9 L 18.578125 7 L 16 7 L 14 7 L 6 7 z"
                fill="#EAB308"
              />
            </svg>
          </div>
        </a>
      </a-tooltip>
    </template>

    <template #expandedRowRender="{ record }">
      <div class="flex">
        <div class="flex-auto basis-1/2">
          <TransDetails
            :timestamp="record.timeStamp"
            :description="record.description"
            :nonce="record.nonce"
            :input="record.input"
            :fee="record.fee"
            :hash="record.hash"
          />
        </div>
        <div class="flex-auto basis-1/2">
          <Note :hash="record.hash" />
        </div>
      </div>
    </template>
  </a-table>
</template>

<script lang="ts">
import { Decimal } from "decimal.js";
import { FormOutlined } from "@ant-design/icons-vue";
import Note from "@/components/Note.vue";
import { useStore } from "vuex";
import dateFormat, { masks } from "dateformat";
import AddressLookup from "@/components/AddressLookup.vue";
import TransDetails from "@/components/TransDetails.vue";
import { computed, defineComponent } from "vue";
import dateFormat, { masks } from "dateformat";
import Immutable from "immutable";
import { Address, Transaction } from "@/types";
import { Note as ANote } from "@/types";

type FlowDirection = string;
type FlowAmount = string;
type FlowCurrency = string;
type Steps = [FlowDirection, FlowAmount, FlowCurrency];

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mapState and mapGetters replacements
    const orderedTransactions = computed(
      () => store.getters["books/orderedTransactions"]
    );
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);
    const notes = computed(() => store.state.books.notes);

    const awaitingUrbitData = computed(
      () => store.state.books.awaitingUrbitData
    );

    //  mounted-actions
    store.dispatch("books/handleSwitchNav", 2);

    //  Transaction Data
    const data = computed(() => {
      if (undefined === orderedTransactions.value) {
        return null;
      } else if (orderedTransactions.value !== undefined) {
        return orderedTransactions.value.slice().map((item) => {
          return {
            key: item[1].hash,
            hash: item[1].hash,
            timeStamp: makeDate(item[1].timeStamp),
            timeOriginal: item[1].timeStamp,
            primaryWallet: item[1].primaryWallet,
            nonce: item[1].nonce,
            txGas: item[1].txGas,
            txGasLimit: item[1].txGasLimit,
            fee: item[1].fee.toSignificantDigits(5).toString(),
            input: item[1].input,
            involvedCurrencies: (() => {
              return item[1].subTransactions.slice().map((step) => {
                return [
                  step.type,
                  step.amount.toSignificantDigits(5),
                  step.symbol,
                ];
              });
            })(),
            shortDescription: (() => {
              if (item[1].address === null) {
                if (item[1].name === "Receive") {
                  return "Receive Ethereum";
                } else if (item[1].name === "Send") {
                  return "Send Ethereum";
                }
              } else if (item[1].name === "Exchange") {
                return "Token Swap";
              } else {
                return "Multipart Transaction";
              }
            })(),
            description: (() => {
              return item[1].subTransactions.slice().map((step) => {
                return [
                  step.type,
                  step.amount.toSignificantDigits(5),
                  step.symbol,
                  step.address,
                ];
              });
            })(),
          };
        });
      }
    });

    const getInflow = (
      involved: Array<Steps> | undefined
    ): Steps | undefined => {
      if (involved === undefined) {
        return undefined;
      } else {
        return involved.find((triplet: Steps) => triplet[0] === "incoming");
      }
    };

    const getOutflow = (
      involved: Array<Steps> | undefined
    ): Steps | undefined => {
      if (involved === undefined) {
        return undefined;
      } else {
        return involved.find((triplet: Steps) => triplet[0] === "outgoing");
      }
    };

    // Unused for now
    // const getExchange = (involved: Array<Steps>): Steps | undefined  => {
    //   return involved.find((triplet: Steps) => triplet[0] === 'exchange')
    // }

    const presentFlow = (steps: Steps | undefined): string => {
      if (steps === undefined) {
        return "";
      } else {
        const direction = steps[0];
        const amount = steps[1];
        const currency = steps[2];
        if (direction === "outgoing") {
          return `- (${amount}) ${currency}`;
        } else {
          return `${amount} ${currency}`;
        }
      }
    };

    const hasNote = (record: Transaction): boolean => {
      return Immutable.has(Immutable.Map(notes.value), record.hash);
    };
    const annotations = (record: Transaction): ANote | Object => {
      if (hasNote(record)) {
        return Immutable.Map(notes.value).get(record.hash, {});
      }
      return {};
    };
    const recordCounterparties = (record: Transaction): Address[] => {
      const notes = annotations(record);
      if (Object.keys(notes).length === 0) {
        return [];
      }
      return notes.to.filter((c) => c !== null);
    };
    const recordAnnotation = (record: Transaction): string => {
      const notes = annotations(record);
      if (Object.keys(notes).length === 0) {
        return "";
      }
      return notes.annotation;
    };

    const nameChek = (addy) => {
      //  First, get arrays of addy, name for utility
      const myne = myWallets.value
        .slice()
        .map((item) => [item[0], item[1].nick]);
      const yurs = myFriends.value
        .slice()
        .map((item) => [item[0], item[1].nick]);
      const mapp = Immutable.Map(myne.concat(yurs));

      if (null === addy) {
        return "Unknown";
      } else if (mapp.has(addy)) {
        return Immutable.get(mapp, addy);
      } else {
        try {
          const truncateRegex =
            /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;
          const match = addy.match(truncateRegex);
          if (match) {
            return `${match[1]}…${match[2]}`;
          }
        } catch (e) {
          return addy;
        }
      }
    };

    const allTags = computed(() => {
      const aT = Array.from(
        new Set(
          notes.value
            .map((a) => {
              return a[1].tags;
            })
            .flat()
        )
      );
      const mapped = aT.map((tag) => {
        return {
          text: tag,
          value: tag,
        };
      });
      return mapped;
    });

    const allCounterparties = computed(() => {
      const myne = myWallets.value.slice().map((i) => i[0]);
      const yurs = myFriends.value.slice().map((i) => i[0]);
      const everyone = myne.concat(yurs);

      const mapped = everyone.map((addy) => {
        const text = nameChek(addy);
        return {
          text: text,
          value: addy,
        };
      });
      return mapped;
    });

    const inCurrencies = computed(() => {
      const uniqCurrencies = Array.from(
        new Set(
          data.value
            .map((t) => {
              const inf = getInflow(t.involvedCurrencies);
              if (inf && inf[2] !== "") {
                return inf[2];
              }
            })
            .flat()
            .filter((item) => {
              // Remove empties
              if (item !== undefined && Object.keys(item).length !== 0) {
                return true;
              }
            })
        )
      );
      const mapped = uniqCurrencies.map((currency) => {
        return {
          text: currency,
          value: currency,
        };
      });
      return mapped;
    });

    const outCurrencies = computed(() => {
      const uniqCurrencies = Array.from(
        new Set(
          data.value
            .map((t) => {
              const out = getOutflow(t.involvedCurrencies);
              if (out && out[2] !== "") {
                return out[2];
              }
            })
            .flat()
            .filter((item) => {
              // Remove empties
              if (item !== undefined && Object.keys(item).length !== 0) {
                return true;
              }
            })
        )
      );
      const mapped = uniqCurrencies.map((currency) => {
        return {
          text: currency,
          value: currency,
        };
      });
      return mapped;
    });

    const columns = computed(() => {
      return [
        {
          title: "Tags",
          slots: {
            customRender: "noteColumn",
          },
          filters: allTags.value,
          onFilter: (soughtTag, txn) => {
            const tags = annotations(txn).tags;
            if (tags !== undefined && Object.keys(tags).length > 0) {
              return tags.includes(soughtTag);
            }
          },
        },
        {
          title: "Date",
          dataIndex: "timeStamp",
          sorter: (a, b) => a.timeOriginal - b.timeOriginal,
          slots: {
            customRender: "dateColumn",
          },
        },
        {
          title: "Primary Wallet",
          dataIndex: "primaryWallet",
          slots: {
            customRender: "addressColumn",
          },
        },
        {
          title: "Counterparty",
          dataIndex: "",
          slots: {
            customRender: "counterpartyColumn",
          },
          filters: allCounterparties.value,
          onFilter: (soughtParty, txn) => {
            const cps = recordCounterparties(txn);
            return cps.includes(soughtParty);
          },
        },
        {
          title: "In",
          dataIndex: ["involvedCurrencies", "[2]"],
          slots: {
            customRender: "currencyInColumn",
          },
          filters: inCurrencies.value,
          onFilter: (soughtCurrency, txn) => {
            const inf = getInflow(txn.involvedCurrencies);
            if (inf !== undefined) {
              return inf[2] === soughtCurrency;
            }
          },
          sorter: {
            compare: (a, b) => {
              let ain = getInflow(a.involvedCurrencies) || 0;
              let bin = getInflow(b.involvedCurrencies) || 0;
              if (ain !== undefined && ain[1] !== undefined) {
                ain = ain[1];
              } else {
                ain = 0;
              }
              if (bin !== undefined && bin[1] !== undefined) {
                bin = bin[1];
              } else {
                bin = 0;
              }

              return Decimal.sub(ain, bin);
            },
          },
        },
        {
          title: "Out",
          dataIndex: ["involvedCurrencies", "[2]"],
          slots: {
            customRender: "currencyOutColumn",
          },
          filters: outCurrencies.value,
          onFilter: (soughtCurrency, txn) => {
            const out = getOutflow(txn.involvedCurrencies);
            if (out !== undefined) {
              return out[2] === soughtCurrency;
            }
          },
          sorter: {
            compare: (a, b) => {
              let aout = getOutflow(a.involvedCurrencies) || 0;
              let bout = getOutflow(b.involvedCurrencies) || 0;
              if (aout !== undefined && aout[1] !== undefined) {
                aout = aout[1];
              } else {
                aout = 0;
              }
              if (bout !== undefined && bout[1] !== undefined) {
                bout = bout[1];
              } else {
                bout = 0;
              }

              return Decimal.sub(aout, bout);
            },
          },
        },
        {
          title: "Fee",
          dataIndex: "fee",
          sorter: (a, b) => a.fee - b.fee,
          // slots: {
          //   customRender: 'currencyOutColumn',
          // },
        },
        {
          title: "Action",
          dataIndex: "shortDescription",
          slots: {
            customRender: "actionsColumn",
          },
        },
      ];
    });

    //  methods
    const makeDate = (secs) => {
      let txDate = new Date(secs * 1000);
      let ftxDate =
        dateFormat(txDate, "paddedShortDate") +
        " " +
        dateFormat(txDate, "h:MM:ss TT");
      return ftxDate;
    };

    return {
      makeDate,
      nameChek,
      columns,
      data,
      inCurrencies,
      outCurrencies,
      allTags,
      getInflow,
      getOutflow,
      presentFlow,
      hasNote,
      annotations,
      recordCounterparties,
      recordAnnotation,
      awaitingUrbitData,
    };
  },

  components: {
    Note,
    AddressLookup,
    TransDetails,
    FormOutlined,
  },
});
</script>
