<template>
  <a-table :columns="columns" :data-source="data" :scroll="{ x: 1000 }">
    <template #addressColumn="{ record }">
      <AddressLookup
        :addy="record.primaryWallet"
      />
    </template>

    <template #currencyColumn="{ record }">
      <div class="grid grid-cols-1 gap-2">
        <div v-for="step in record.involvedCurrencies">
          <div class="flex flex-row">
            <div v-if="step[0] === 'outgoing'" class="text-sm text-red-500">
              {{ step[1] + ' ' + step[2] }}
            </div>
            <div v-if="step[0] === 'incoming'" class="text-sm text-green-500">
              {{ step[1] + ' ' + step[2] }}
            </div>
            <div v-if="step[0] === 'exchange'" class="text-grey-500 text-sm">
              {{ step[1] + ' ' + step[2] }}
            </div>
          </div>
        </div>
      </div>
    </template>

    <template #expandedRowRender="{ record }">
      <div class="flex">
        <div class="flex-auto basis-1/2">
          <TransDetails
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
import Note from '@/components/Note.vue';
import { defineComponent, computed, ref } from 'vue';
import { useStore } from 'vuex';
import dateFormat, { masks } from 'dateformat';
import AddressLookup from '@/components/AddressLookup.vue';
import TransDetails from '@/components/TransDetails.vue';
import { defineComponent } from 'vue';
import { useStore } from 'vuex';
import type { PropType } from 'vue';
import dateFormat, { masks } from 'dateformat';
import Immutable from 'immutable';
import { TxHash, Transaction } from '@/types';

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mapState and mapGetters replacements
    const orderedTransactions = computed(
      () => store.getters['books/orderedTransactions']
    );
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);

    //  mounted-actions
    store.dispatch('books/handleSwitchNav', 2);

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
                if (item[1].name === 'Receive') {
                  return 'Receive Ethereum';
                } else if (item[1].name === 'Send') {
                  return 'Send Ethereum';
                }
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

    //  methods
    const makeDate = (secs) => {
      let txDate = new Date(secs * 1000);
      let ftxDate =
        dateFormat(txDate, 'paddedShortDate') +
        ' ' +
        dateFormat(txDate, 'h:MM:ss TT');
      return ftxDate;
    };

    return {
      makeDate,
      nameChek,
      columns,
      data,
    };
  },

  components: {
    Note,
    AddressLookup,
    TransDetails,
  },
});
</script>
