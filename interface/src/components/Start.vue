<template>
  <h1>Hello world</h1>
  This is Start.vue
  <button @click="fetchTx">"test"</button>
  {{arTrans}}
  {{webData}}
</template>

<script lang="ts">
import { defineComponent } from "vue";
import { mapState } from "vuex";

export default defineComponent({
  mounted() {
    const deskname = "book" // TODO: change to your desk
    this.startAirlock(deskname);
  },
  unmounted() {
    this.closeAirlocks();
  },

  computed: {
    ...mapState("books", ["arTrans", "webData"]),
  },

  methods: {
    fetchTx() {
      this.$store.dispatch("books/fetchTransactions");
    },
    startAirlock(deskname) {
      this.$store.dispatch("ship/openAirlockToAgent", deskname);
    },
    closeAirlocks() {
      this.$store.dispatch("ship/closeAgentAirlocks");
    },
  },
})
</script>


