<template>
  <select v-model="selected">
    <option text="All" value="" />
    <option v-for="[address, details] in myWallets" :value="address">
      {{ details.nick ? details.nick : truncateAddress(address) }}
    </option>
  </select>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { mapState } from "vuex";
import { Address } from "@/types";
import Immutable, { Map } from "immutable";

export default defineComponent({
  data() {
    return {
      selected: "",
    };
  },
  watch: {
    selected(newVal, oldVal) {
      if (newVal === "" || newVal) {
        this.handleSetBrowse(newVal);
      }
    },
  },

  mounted() {},
  unmounted() {},

  computed: {
    ...mapState("books", ["myWallets"]),
  },

  methods: {
    handleSetBrowse(which) {
      this.$store.dispatch("books/handleSwitchBrowse", which);
    },

    checkAddress(map, fmap, addy) {
      const myWal = Immutable.Map(map) as Map<
        [Address, { nickname: string; tags: Array<string> }]
      >;
      const frenWal = Immutable.Map(fmap) as Map<[Address, WalletDetails]>;
      if (Immutable.has(myWal, addy)) {
        return Immutable.get(myWal, addy).nick;
      } else if (Immutable.has(frenWal, addy)) {
        return Immutable.get(frenWal, addy).nick;
      } else {
        return addy;
      }
    },

    truncateAddress(address) {
      const truncateRegex = /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;

      const truncateEthAddress = (address: string) => {
        const match = address.match(truncateRegex);
        if (!match) return address;
        return `${match[1]}…${match[2]}`;
      };
    },
  },
});
</script>
