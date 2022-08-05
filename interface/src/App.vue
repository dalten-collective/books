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
      <div class="md:mt-12 md:w-5/6">
        <div
          class="float-right flex hidden flex-row-reverse text-right md:inline-block md:h-12"
        >
          <a-tooltip
            title="Built by Quartus"
            placement="left"
            :align="{ offset: [0, -100] }"
          >
            <a
              href="https://urbit.org/ids/~dalten"
              class="text-right"
              target="_blank"
            >
              <QuartusLogo
                height="100"
                width="100"
                style="position: relative; top: -50px"
              />
            </a>
          </a-tooltip>
        </div>
        <router-view v-slot="{ Component }">
          <transition name="slide-fade">
            <component :is="Component" />
          </transition>
        </router-view>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent } from "vue";
import Navigation from "@/components/Navigation.vue";
import QuartusLogo from "@/components/QuartusLogo.vue";
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
      this.$store.dispatch("ship/openAirlockToAgent", "books");
    },
    closeAirlock() {
      this.$store.dispatch("ship/closeAgentAirlocks");
    },
  },
});
</script>

<style scoped>
.slide-fade-enter-active {
  transition: all 0.15s ease-out;
}

.slide-fade-leave-active {
  /* transition: all 0.0s cubic-bezier(1, 0.5, 0.8, 1); no transition out - feels laggy */
}

.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateY(20px);
  opacity: 0;
}
</style>
