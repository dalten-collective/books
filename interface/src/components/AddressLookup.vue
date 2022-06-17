<template>
  <div class="has-tooltip" v-if="showingDetails">
    <span class="tooltip rounded bg-gray-100 p-1 text-red-500 shadow-lg">
      {{ addy }}
    </span>
  </div>
  <div @click="toggleDetails">
    {{ checkAddress(myWallets, myFriends, addy) }}
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import { mapState, mapGetters } from 'vuex';
import type { PropType } from 'vue';
import { Address, TxHash, Transaction } from '@/types';
import Immutable, { OrderedMap, Map } from 'immutable';

export default defineComponent({
  data() {
    return {
      showingDetails: false,
    };
  },

  mounted() {},

  unmounted() {},

  computed: {
    ...mapState('books', ['myFriends', 'myWallets']),
  },

  methods: {
    checkAddress(map, fmap, addy) {
      const myWal = Immutable.Map(map) as Map<
        [Address, { nickname: string; tags: Array<string> }]
      >;
      const frenWal = Immutable.Map(fmap) as Map<[Address, WalletDetails]>;
      if (Immutable.has(myWal, addy)) {
        return Immutable.get(myWal, addy).nick
          ? Immutable.get(myWal, addy).nick
          : this.truncateAddress(addy);
      } else if (Immutable.has(frenWal, addy)) {
        return Immutable.get(frenWal, addy).nick
          ? Immutable.get(frenWal, addy).nick
          : this.truncateAddress(addy);
      } else {
        return this.truncateAddress(addy);
      }
    },

    truncateAddress(address) {
      try {
        const truncateRegex =
          /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;
        const match = address.match(truncateRegex);
        if (match) {
          return `${match[1]}…${match[2]}`;
        }
      } catch (e) {
        return address;
      }
    },

    toggleDetails() {
      this.showingDetails = !this.showingDetails;
    },
  },

  props: {
    addy: {
      type: String as PropType<Address>,
      default: 'Null Address',
    },
  },
});
</script>
