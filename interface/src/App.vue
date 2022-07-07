<template>
  <div class="leading-normal tracking-normal">
    <div class="flex flex-wrap md:flex-row">
      <div class="w-full md:w-1/6">
        <div class="container">
          <div class="mx-auto md:relative lg:float-left lg:px-6">
            <Navigation />
          </div>
        </div>
      </div>
      <div class="w-full md:w-5/6 md:mt-24">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import Navigation from '@/components/Navigation.vue';

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
      this.$store.dispatch('ship/openAirlockToAgent', 'books');
    },
    closeAirlock() {
      this.$store.dispatch('ship/closeAgentAirlocks');
    },
  },
});
</script>
