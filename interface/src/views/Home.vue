<template>
  <div class="flex flex-col gap-6">
    <div class="w-full">
      <div class="mt-6 md:w-4/5">
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
    <div class="w-full justify-center">
      <div class="flex flex-col">
        <a-table
          :columns="columns"
          :data-source="data"
          :scroll="{ x: 1000 }"
          :pagination="false"
        >
          <template #title>Recent Transactions</template>
          <template #addressColumn="{ record }">
            <AddressLookup :addy="record.primaryWallet" />
          </template>

          <template #currencyColumn="{ record }">
            <div class="grid grid-cols-1 gap-2">
              <div v-for="step in record.involvedCurrencies">
                <div class="flex flex-row">
                  <div
                    v-if="step[0] === 'outgoing'"
                    class="text-sm text-red-500"
                  >
                    {{ step[1] + ' ' + step[2] }}
                  </div>
                  <div
                    v-if="step[0] === 'incoming'"
                    class="text-sm text-green-500"
                  >
                    {{ step[1] + ' ' + step[2] }}
                  </div>
                  <div
                    v-if="step[0] === 'exchange'"
                    class="text-grey-500 text-sm"
                  >
                    {{ step[1] + ' ' + step[2] }}
                  </div>
                </div>
              </div>
            </div>
          </template>

          <template #expandedRowRender="{ record }">
            <div class="flex flex-row">
              <div class="flex-auto basis-1/2">
                <div v-for="step in record.description">
                  <a-tooltip
                    :title="[null === step[3] ? 'Null Address' : step[3]]"
                    color="gold"
                    placement="topLeft"
                  >
                    <a-statistic
                      :title="[
                        step[0] === 'outgoing'
                          ? 'Sent to ' + nameChek(step[3])
                          : 'Received from ' + nameChek(step[3]),
                      ]"
                      :value="step[1]"
                      :precision="2"
                      :suffix="step[2]"
                      :value-style="{ fontSize: '15px' }"
                    >
                      <template #prefix>
                        <svg
                          v-if="step[0] === 'outgoing'"
                          focusable="false"
                          class=""
                          data-icon="arrow-down"
                          width="15px"
                          height="15px"
                          fill="red"
                          aria-hidden="true"
                          viewBox="64 64 896 896"
                        >
                          <path
                            d="M862 465.3h-81c-4.6 0-9 2-12.1 5.5L550 723.1V160c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8v563.1L255.1 470.8c-3-3.5-7.4-5.5-12.1-5.5h-81c-6.8 0-10.5 8.1-6 13.2L487.9 861a31.96 31.96 0 0048.3 0L868 478.5c4.5-5.2.8-13.2-6-13.2z"
                          />
                        </svg>
                        <svg
                          v-if="step[0] === 'incoming'"
                          focusable="false"
                          class=""
                          data-icon="arrow-up"
                          width="15px"
                          height="15px"
                          fill="green"
                          aria-hidden="true"
                          viewBox="64 64 896 896"
                        >
                          <path
                            d="M868 545.5L536.1 163a31.96 31.96 0 00-48.3 0L156 545.5a7.97 7.97 0 006 13.2h81c4.6 0 9-2 12.1-5.5L474 300.9V864c0 4.4 3.6 8 8 8h60c4.4 0 8-3.6 8-8V300.9l218.9 252.3c3 3.5 7.4 5.5 12.1 5.5h81c6.8 0 10.5-8 6-13.2z"
                          />
                        </svg>
                      </template>
                    </a-statistic>
                  </a-tooltip>
                </div>
              </div>
              <div class="flex-auto basis-1/2">
                <Note :hash="record.hash" />
              </div>
            </div>
          </template>
          <template #footer>
            <div class="grid justify-items-end text-yellow-500">
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

    //  Tabs
    const activeKey = ref([]);

    //  Transaction Data
    const columns = [
      {
        title: 'Timestamp',
        dataIndex: 'timeStamp',
        sorter: (a, b) => a.timeOriginal - b.timeOriginal,
      },
      {
        title: 'Primary Wallet',
        dataIndex: 'primaryWallet',
        slots: {
          customRender: 'addressColumn',
        },
      },
      {
        title: 'Involved Currencies',
        dataIndex: 'involvedCurrencies',
        slots: {
          customRender: 'currencyColumn',
        },
      },
      {
        title: 'Action',
        dataIndex: 'shortDescription',
      },
    ];
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
    const key = ref(0)
    const tabList = computed(() => {
      if (undefined === myWallets.value) {
        return null;
      } else if (myWallets.value !== undefined) {
        return myWallets.value.slice().map((item, index) => {
          return {
            key: index,
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
    };
  },

  components: {
    AddressLookup,
    Note,
  },
});
</script>
