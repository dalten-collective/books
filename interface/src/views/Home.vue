<template>
  <Start />
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import Start from "@/components/Start.vue";
import { BigNumber } from "ethers";
import { mapState } from "vuex";

export default defineComponent({
  mounted() {
    this.startAirlock('books');
  },
  components: {
    Start
  },
  computed: {
    ...mapState("books", ["webData"]),
  }
})
</script>

