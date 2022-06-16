<template>

  <div class="leading-normal tracking-normal">
    <div class="flex md:flex-row flex-wrap">
      <div class="w-full md:w-1/6">
        <div class="container">
          <div class="md:relative mx-auto lg:float-left lg:px-6">
            <Navigation />
          </div>
        </div>
      </div>
      <div class="w-full md:w-5/6">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Navigation from "@/components/Navigation.vue";

export default defineComponent({
  mounted() {
    this.startAirlock();

  },
  unmounted() {
    this.closeAirlock();
  },

  components: {
    Navigation,
  },

  methods: {
    startAirlock() {
      this.$store.dispatch("ship/openAirlockToAgent", "books");
    },
    closeAirlock() {
      this.$store.dispatch("ship/closeAgentAirlocks");
    },
  },

})
</script>

