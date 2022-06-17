<template>
  <div @click="toggleDetails">
    <div class="flex flex-row">
      <div variant="h5" class="mb-2 font-mono">
        Nickname: {{ wallet.details.nick }}
      </div>
    </div>
    <div class="flex flex-row">
      <div variant="h5" class="mb-2 font-mono">
        Address: {{ wallet.address }}
      </div>
    </div>
  </div>
  <div v-if="showingDetails">Details</div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import { BigNumber } from 'ethers';
import { mapState } from 'vuex';
import type { PropType } from 'vue';
import { Address } from '@/types';

export default defineComponent({
  data() {
    return {
      showingDetails: false,
    };
  },

  mounted() {},
  unmounted() {},
  components: {},
  computed: {
    ...mapState('books', ['myWallets']),
  },
  methods: {
    toggleDetails() {
      this.showingDetails = !this.showingDetails;
    },
  },
  props: ['wallet'],
});
</script>
