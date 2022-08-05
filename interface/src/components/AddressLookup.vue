<template>
  <a-tooltip :title="addy" color="gold" placement="topLeft">
    <div class="cursor-pointer">
      {{ checkAddress(myWallets, myFriends, addy) }}
    </div>
  </a-tooltip>
</template>

<script lang="ts">
import { defineComponent, computed } from "vue";
import { useStore } from "vuex";
import type { PropType } from "vue";
import { Address } from "@/types";
import Immutable, { Map } from "immutable";

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mapState and mapGetters replacements
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);

    //  methods
    const checkAddress = (map, fmap, addy) => {
      if (null === addy) {
        return "Unknown";
      }

      const myWal = Immutable.Map(map) as Map<
        [Address, { nickname: string; tags: Array<string> }]
      >;
      const frenWal = Immutable.Map(fmap) as Map<[Address, WalletDetails]>;
      if (Immutable.has(myWal, addy)) {
        return Immutable.get(myWal, addy).nick
          ? Immutable.get(myWal, addy).nick
          : truncateAddress(addy);
      } else if (Immutable.has(frenWal, addy)) {
        return Immutable.get(frenWal, addy).nick
          ? Immutable.get(frenWal, addy).nick
          : truncateAddress(addy);
      } else {
        return truncateAddress(addy);
      }
    };

    const truncateAddress = (address) => {
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
    };

    const toggleDetails = () => {
      this.showingDetails = !this.showingDetails;
    };

    return {
      myWallets,
      myFriends,
      checkAddress,
      truncateAddress,
      toggleDetails,
    };
  },

  data() {
    return {
      showingDetails: false,
    };
  },

  props: {
    addy: {
      type: String as PropType<Address>,
      default: "Null Address",
    },
  },
});
</script>
