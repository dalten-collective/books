<template>
  <div class="container mx-auto leading-normal tracking-normal">
    <div class="flex flex-wrap">
      <div class="md:w-1/6">
        <div>
          <div class="mx-auto lg:px-6">
            <Navigation />
          </div>
        </div>
      </div>
      <div class="md:w-5/6 md:mt-24">
        <router-view />
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import Navigation from '@/components/Navigation.vue';
import { BookOutlined } from "@ant-design/icons-vue";

export default defineComponent({
  mounted() {
    this.startAirlock();
  },
  unmounted() {
    this.closeAirlock();
  },

  components: {
    Navigation,
    BookOutlined,
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
