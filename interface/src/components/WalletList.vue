<template>
  <div>
    <div v-for="[address, details] in myWallets" :key="address">
      <Wallet :wallet="{ address, details }" />
    </div>
  </div>
  <div :class="[pushWalletPending ? 'bg-gray-100 dark:bg-gray-400' : '']">
    <input
      type="text"
      placeholder="0xeee.111.222.333..."
      v-model="newAddress"
    />
    <input type="text" placeholder="my-new-wallet" v-model="newNick" />
    <button
      @click="handleAddWallet"
      :disabled="!validAddress || pushWalletPending"
    >
      Add Wallet
    </button>
  </div>
</template>

<script lang="ts">
import Wallet from '@/components/Wallet.vue';
import { pushWallet } from '@/api/books.ts';
import { defineComponent } from 'vue';
import { BigNumber } from 'ethers';
import { mapState } from 'vuex';
import type { PropType } from 'vue';
import { Address } from '@/types';

export default defineComponent({
  data() {
    return {
      newAddress: '',
      newNick: '',
      pushWalletPending: false,
    };
  },
  mounted() {
    this.switchNav();
  },
  unmounted() {},
  components: {
    Wallet,
  },
  computed: {
    ...mapState('books', ['myWallets']),
    validAddress() {
      if (this.newAddress === '') {
        return false;
      }
      if (this.newNick === '') {
        return false;
      }
      if (!/^0x[a-fA-F0-9]{40}$/.test(this.newAddress)) {
        return false;
      }
      return true;
    },
  },
  methods: {
    switchNav() {
      this.$store.dispatch('books/handleSwitchNav', 1);
    },

    handleAddWallet() {
      if (!this.validAddress) {
        return;
      }
      this.pushWalletPending = true;
      pushWallet(this.newAddress, this.newNick).then((r) => {
        console.log('res: ', r);
        this.pushWalletPending = false;
        this.newAddress = '';
        this.newNick = '';
      });
    },
  },
});
</script>
