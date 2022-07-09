<template>
  <div class="flex flex-col gap-6">
    <div class="w-full">
      <div class="mt-12 md:w-4/5">
        <div>
          <a-card
            class="w-96 bg-zinc-50"
            title="Tracked Wallets"
            :tab-list="tabList"
            :active-tab-key="key"
            @tabChange="(key) => onTabChange(key, 'key')"
          >
            <template #extra>
              <div class="text-yellow-500">
                <router-link :to="{ name: 'wallets' }">
                  see more...
                </router-link>
              </div>
            </template>
            <div class="flex flex-col gap-4">
                <a-collapse v-if="Object.keys(contentList).length !== 0" v-model:activeKey="activeKey">
                  <a-collapse-panel key="1" header="Tags">
                    <template v-for="tag in contentList[key].tags">
                      <a-tag>{{tag}}</a-tag>
                    </template>
                  </a-collapse-panel>
                  <a-collapse-panel key="2" header="Balances">
                    {{contentList[key].balances}}
                  </a-collapse-panel>
                </a-collapse>
            </div>
          </a-card>
        </div>
      </div>
    </div>
    <div class="justify-center w-full">
      <div class="flex flex-col">
        <a-table
          :columns="columns"
          :data-source="data"
          :scroll="{ x: 1000 }"
          :pagination="false"
          :loading="awaitingUrbitData"
        >
          <template #title>Recent Transactions</template>
          <template #dateColumn="{ record }">
            <div class="grid grid-cols-1 gap-2">
              <div>
                {{ record.timeStamp.split(" ")[0] }}
              </div>
            </div>
          </template>

          <template #addressColumn="{ record }">
            <AddressLookup
              :addy="record.primaryWallet"
            />
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
          <template #footer>
            <div class="text-yellow-500 grid justify-items-end">
              <router-link :to="{ name: 'transactions' }">
                see more...
              </router-link>
            </div>
          </template>
        </a-table>
      </div>
      <div></div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, computed, ref } from 'vue';
import Note from '@/components/Note.vue';
import AddressLookup from '@/components/AddressLookup.vue';
import TransDetails from '@/components/TransDetails.vue';
import { useStore } from 'vuex';
import Immutable from 'immutable';
import dateFormat, { masks } from 'dateformat';

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mounted-actions
    store.dispatch('books/handleSwitchNav', 0);

    //  mapState and mapGetters replacements
    const subscriptions = computed(() => store.state.ship.subscriptions);
    const pageFrontTransactions = computed(
      () => store.getters['books/pageFrontTransactions']
    );
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);
    const awaitingUrbitData = computed(() => store.state.books.awaitingUrbitData);

    //  Tabs
    const activeKey = ref([]);

    //  Transaction Data
    // const columns = [
    //   {
    //     title: 'Timestamp',
    //     dataIndex: 'timeStamp',
    //     sorter: (a, b) => a.timeOriginal - b.timeOriginal,
    //   },
    //   {
    //     title: 'Primary Wallet',
    //     dataIndex: 'primaryWallet',
    //     slots: {
    //       customRender: 'addressColumn',
    //     },
    //   },
    //   {
    //     title: 'Involved Currencies',
    //     dataIndex: 'involvedCurrencies',
    //     slots: {
    //       customRender: 'currencyColumn',
    //     },
    //   },
    //   {
    //     title: 'Action',
    //     dataIndex: 'shortDescription',
    //   },
    // ];
    const columns = computed(() => {
      return [
        {
          title: 'Date',
          dataIndex: 'timeStamp',
          slots: {
            customRender: 'dateColumn',
          }
        },
        {
          title: 'Primary Wallet',
          dataIndex: 'primaryWallet',
          slots: {
            customRender: 'addressColumn',
          },
        },
        {
          title: 'In',
          dataIndex: ['involvedCurrencies', '[2]'],
          slots: {
            customRender: 'currencyInColumn',
          },
        },
        {
          title: 'Out',
          dataIndex: ['involvedCurrencies', '[2]'],
          slots: {
            customRender: 'currencyOutColumn',
          },
        },
        {
          title: 'Action',
          dataIndex: 'shortDescription',
        },
      ]
    })

    const data = computed(() => {
      if (undefined === pageFrontTransactions.value) {
        return null;
      } else if (pageFrontTransactions.value !== undefined) {
        return pageFrontTransactions.value.slice().map((item) => {
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
              if (null === item[1].address) {
                return item[1].name + ' Ethereum';
              } else if (item[1].name === 'Exchange') {
                return 'Token Swap';
              } else {
                return 'Multipart Transaction';
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

    //  Wallet Data
    const key = ref('0')
    const tabList = computed(() => {
      if (undefined === myWallets.value) {
        return null;
      } else if (myWallets.value !== undefined) {
        return myWallets.value.slice().map((item, index) => {
          return {
            key: index.toString(),
            tab: item[1].nick,
          };
        });
      }
    });
    const contentList = computed(() => {
      if (undefined === myWallets.value) {
        return {};
      } else if (myWallets.value !== undefined) {
        const obj = {}
        myWallets.value.forEach((item, index) => {
          obj[index] = {
              balances: 'coming soon',
              tags: item[1].tags,
            };
        });
        return obj;
      }
    });

    // Functions
    const makeDate = (secs) => {
      let txDate = new Date(secs * 1000);
      let ftxDate =
        dateFormat(txDate, 'paddedShortDate') +
        ' ' +
        dateFormat(txDate, 'h:MM:ss TT');
      return ftxDate;
    };
    const onTabChange = (value) => {
      key.value = value;
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
        return 'Unknown';
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

    const getInflow = (involved: Array<Steps> | undefined): Steps | undefined  => {
      if (involved === undefined) {
        return undefined
      } else {
        return involved.find((triplet: Steps) => triplet[0] === 'incoming')
      }
    }

    const getOutflow = (involved: Array<Steps> | undefined): Steps | undefined => {
      if (involved === undefined) {
        return undefined
      } else {
        return involved.find((triplet: Steps) => triplet[0] === 'outgoing')
      }
    }

    const presentFlow = (steps: Steps | undefined): string => {
      if (steps === undefined) {
        return ''
      } else {
        const direction = steps[0]
        const amount = steps[1]
        const currency = steps[2]
        if ( direction === 'outgoing' ) {
          return `- (${ amount }) ${ currency }`
        } else {
          return `${ amount } ${ currency }`
        }
      }
    }

    const inCurrencies = computed(() => {
      const uniqCurrencies = Array.from(
        new Set(
          data.value
            .map((t) => {
              const inf = getInflow(t.involvedCurrencies)
              if (inf && inf[2] !== '') {
                return inf[2]
              }
            })
            .flat()
            .filter(item => { // Remove empties
              if (item !== undefined && Object.keys(item).length !== 0) {
                return true
              }
            })
        )
      )
      const mapped = uniqCurrencies.map((currency) => {
        return {
          text: currency,
          value: currency,
        }
      })
      return mapped
    });

    const outCurrencies = computed(() => {
      const uniqCurrencies = Array.from(
        new Set(
          data.value
            .map((t) => {
              const out = getOutflow(t.involvedCurrencies)
              if (out && out[2] !== '') {
                return out[2]
              }
            })
            .flat()
            .filter(item => { // Remove empties
              if (item !== undefined && Object.keys(item).length !== 0) {
                return true
              }
            })
        )
      )
      const mapped = uniqCurrencies.map((currency) => {
        return {
          text: currency,
          value: currency,
        }
      })
      return mapped
    });

    return {
      subscriptions,
      pageFrontTransactions,
      columns,
      data,
      key,
      tabList,
      contentList,
      onTabChange,
      nameChek,
      activeKey,
      inCurrencies,
      outCurrencies,
      getInflow,
      getOutflow,
      presentFlow,
      awaitingUrbitData,
    };
  },

  components: {
    AddressLookup,
    Note,
    TransDetails,
  },
});
</script>
