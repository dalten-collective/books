<template>
  <NewTransactions />
</template>

<script lang="ts">
import AddressLookup from '@/components/AddressLookup.vue';
import PagePolice from '@/components/PagePolice.vue';
import SelectedWallet from '@/components/SelectedWallet.vue';
import NewTransactions from '@/components/NewTransactions.vue';
import TransUnit from '@/components/Transaction.vue';
import { defineComponent } from 'vue';
import { mapState, mapGetters } from 'vuex';
import type { PropType } from 'vue';
import dateFormat, { masks } from 'dateformat';
import Immutable from 'immutable';
import { TxHash, Transaction } from '@/types';

export default defineComponent({
  mounted() {
    this.switchNav();
  },
  unmounted() {},
  components: {
    AddressLookup,
    PagePolice,
    SelectedWallet,
    TransUnit,
    NewTransactions,
  },
  computed: {
    ...mapState('books', ['urbitData']),
    ...mapGetters('books', ['orderedTransactions']),
    ...mapGetters('books', ['paginateTransactions']),
  },
  methods: {
    chkStep(arr, wat) {
      return arr.some((el) => el.type == wat);
    },

    makeDate(secs) {
      let txDate = new Date(secs * 1000);
      let ftxDate =
        dateFormat(txDate, 'paddedShortDate') +
        ' ' +
        dateFormat(txDate, 'h:MM:ss TT');
      return ftxDate;
    },

    switchNav() {
      this.$store.dispatch('books/handleSwitchNav', 2);
    },
  },
});
</script>
