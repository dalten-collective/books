<template>
  <div class="flex flex-col gap-4">
    <div class="w-full">
      <div class="mt-6 md:w-3/5">
        <div>My Wallets</div>
        <div>
          <div
            class="justify-center text-center"
            v-for="[address, details] in myWallets"
            :key="address"
          >
            <Wallet :wallet="{ address, details }" />
          </div>
          <div>
            <router-link :to="{ name: 'wallets' }">see more...</router-link>
          </div>
        </div>
      </div>
    </div>
    <div class="w-full justify-center">
      <div class="flex flex-col">
        <div class="overflow-x-auto sm:-mx-6 lg:-mx-8">
          <div class="inline-block min-w-full py-2 sm:px-6 lg:px-8">
            <div class="overflow-hidden">
              <table class="min-w-full">
                <thead class="border-b bg-white">
                  <tr>
                    <th
                      scope="col"
                      class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                    >
                      Primary Wallet
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                    >
                      From
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                    >
                      To
                    </th>
                    <th
                      scope="col"
                      class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                    >
                      Action
                    </th>
                  </tr>
                </thead>
                <tbody
                  v-for="[kex, details] in pageFrontTransactions"
                  :key="details.hash"
                  class="border-b bg-white transition duration-300 ease-in-out hover:bg-gray-100"
                >
                  <TransUnit :trans="details" />
                </tbody>
              </table>
            </div>
          </div>
        </div>
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

export default defineComponent({
  mounted() {
    this.switchNav();
  },
  unmounted() {},
  components: {
    Navigation,
    WalletList,
    Wallet,
    TransUnit,
  },
  computed: {
    ...mapState('books', ['myWallets']),
    ...mapGetters('books', ['pageFrontTransactions']),
    ...mapState('ship', ['subscriptions']),
  },
  methods: {
    switchNav() {
      this.$store.dispatch('books/handleSwitchNav', 0);
    },
  },
});
</script>
