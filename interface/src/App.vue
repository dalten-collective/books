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
      <div class="md:w-5/6 md:mt-12">
        <div class="flex flex-row-reverse hidden float-right text-right md:inline-block md:h-12">
          <a-tooltip title="Built by Quartus" placement="left">
            <a href="https://urbit.org/ids/~dalten" class="text-right" target="_blank">
              <QuartusLogo
                height="100"
                width="100"
                style="position: relative; top: -50px"
              />
            </a>
          </a-tooltip>
        </div>
        <router-view class=""/>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import Navigation from '@/components/Navigation.vue';
import QuartusLogo from '@/components/QuartusLogo.vue';
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
    QuartusLogo,
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
