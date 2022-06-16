<template>
<div class="grid grid-cols-4 gap-4">
  <div class="col-span-1 flex w-full justify-center"
       @click="backPage"
       v-bind:class="[ pageNo === 1 ? 'bg-gray-200' : '']">
    <svg xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" height="24px" viewBox="0 0 24 24" width="24px" fill="#000000">
      <rect fill="none" height="24" width="24"/>
      <g><polygon points="17.77,3.77 16,2 6,12 16,22 17.77,20.23 9.54,12"/></g>
    </svg>
  </div>
  <div class="col-span-2 text-center text-sm ">
    <p>Page {{ pageNo }} / {{numPage}}</p>
  </div>
  <div class="col-span-1 flex w-full justify-center"
       @click="forePage"
       v-bind:class="[ pageNo >= numPage ? 'bg-gray-200' : '']">
    <svg xmlns="http://www.w3.org/2000/svg" enable-background="new 0 0 24 24" height="24px" viewBox="0 0 24 24" width="24px" fill="#000000">
      <g><path d="M0,0h24v24H0V0z" fill="none"/></g>
      <g><polygon points="6.23,20.23 8,22 18,12 8,2 6.23,3.77 14.46,12"/></g>
    </svg>
  </div>
</div>

</template>

<script lang="ts">
import { defineComponent } from 'vue';
import { mapState, mapGetters } from "vuex";
import type { PropType } from 'vue';
import { Address, TxHash, Transaction } from "@/types";
import Immutable, { OrderedMap, Map } from 'immutable';

export default defineComponent ({
    data() {
      return {
        pageNo: 1,
      }
    },
    watch: {
      pageNo(newVal, oldVal) {
        if (newVal) {
          this.handleSetPage(newVal)
        }
      },
      numPage(newVal) {
        if (newVal) {
          this.pageNo = 1;
          this.handleSetPage(1);
        }
      },
    },

    mounted() {

    },

    unmounted() {

    },

    computed: {
    ...mapGetters('books',['orderedTransactions']),
    numPage() {
      if (this.orderedTransactions.length < 25) {
        return 1;
      } else if (this.orderedTransactions.length % 25 === 0) {
        return Math.ceil(this.orderedTransactions.length/25);
      } else {
        return Math.ceil(this.orderedTransactions.length/25);
      }
    },
    },

    methods: {

      handleSetPage(which) {
        this.$store.dispatch("books/handleSwitchPage", which);
      },

      forePage() {
        if (this.pageNo < this.numPage) {
          this.pageNo = this.pageNo + 1;
        }
      },

      backPage() {
        if (this.pageNo > 1) {
          this.pageNo = this.pageNo - 1;
        }
      }


    },

})
</script>
