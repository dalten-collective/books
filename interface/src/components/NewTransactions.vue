<template>
  <a-table :columns="columns" :data-source="data" :scroll="{ x: 1000 }">
    <template #addressColumn="{ record }">
      <AddressLookup :addy="record.primaryWallet" />
    </template>
    <template #expandedRowRender="{ record }">
      <div class="flex">
        <p class="flex-auto basis-1/2">
          {{ record.description }}
        </p>
        <div class="flex-auto basis-1/2">
          <Note :hash="record.hash" />
        </div>
      </div>
    </template>
  </a-table>
</template>
<script lang="ts">
import AddressLookup from '@/components/AddressLookup.vue';
import Note from '@/components/Note.vue';
import { defineComponent, ref } from 'vue';
import { mapState, mapGetters } from 'vuex';
import dateFormat, { masks } from 'dateformat';

export default defineComponent({
  components: {
    AddressLookup,
    Note,
  },

  setup() {
    const filteredInfo = ref();
    const sortedInfo = ref();
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
      },
      {
        title: 'Action',
        dataIndex: 'shortDescription',
      },
    ]


    return {
      columns,
    };
  },

  computed: {
    ...mapGetters('books', ['paginateTransactions', 'orderedTransactions']),
    data() {
      return this.orderedTransactions.map((item) => {
        return {
          key: item[1].hash,
          hash: item[1].hash,
          timeStamp: this.makeDate(item[1].timeStamp),
          timeOriginal: item[1].timeStamp,
          primaryWallet: item[1].primaryWallet,
          involvedCurrencies: (() => {
            const remakeCurrencies = item[1].subTransactions.map((item) => {
              return item.symbol;
            })
            return remakeCurrencies.join("/")
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
          description: 'test description',
        };
      });
    },
  },

  methods: {
    makeDate(secs) {
      let txDate = new Date(secs * 1000);
      let ftxDate =
        dateFormat(txDate, 'paddedShortDate') +
        ' ' +
        dateFormat(txDate, 'h:MM:ss TT');
      return ftxDate;
    },
  },
});
</script>
