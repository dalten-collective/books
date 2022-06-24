<style scoped>
/* For demo */
.ant-carousel :deep(.slick-slide) {
  text-align: center;
  height: 100px;
  line-height: 40px;
  background: #364d79;
}

.ant-carousel :deep(.slick-slide h3) {
  color: #fff;
}

.ant-carousel :deep(.slick-slide h4) {
  color: #fff;
}
</style>

<template>
  <div class="flex flex-col gap-4">
    <div class="w-full">
      <div class="mt-6 md:w-3/5">
        <div>My Wallets</div>
        <div>
          <a-carousel autoplay effect="fade">
            <div v-for="[address, details] in myWallets" :key="address">
              <h3>{{ details.nick }}</h3>
              <h4>{{ address }}</h4>
            </div>
          </a-carousel>
          <div>
            <router-link :to="{ name: 'wallets' }">see more...</router-link>
          </div>
        </div>
      </div>
    </div>
    <div class="w-full justify-center">
      <div class="flex flex-col">
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
      </div>
      <div>
        <router-link :to="{ name: 'transactions' }">see more...</router-link>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import Start from '@/components/Start.vue';
import WalletList from '@/components/WalletList.vue';
import Wallet from '@/components/Wallet.vue';
import TransactionList from '@/components/TransactionList.vue';
import TransUnit from '@/components/Transaction.vue';
import AddressLookup from '@/components/AddressLookup.vue';
import Navigation from '@/components/Navigation.vue';
import { BigNumber } from 'ethers';
import { mapState, mapGetters } from 'vuex';
import dateFormat, { masks } from 'dateformat';

export default defineComponent({
  setup() {
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
    ];
    return {
      columns,
    };
  },

  mounted() {
    this.switchNav();
  },

  unmounted() {},

  components: {
    AddressLookup,
    Navigation,
    WalletList,
    Wallet,
    TransUnit,
  },

  computed: {
    ...mapState('books', ['myWallets']),
    ...mapGetters('books', ['pageFrontTransactions']),
    ...mapState('ship', ['subscriptions']),

    data() {
      return this.pageFrontTransactions.map((item) => {
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
    switchNav() {
      this.$store.dispatch('books/handleSwitchNav', 0);
    },

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
