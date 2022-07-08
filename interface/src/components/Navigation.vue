<template>
  <ul class="flex flex-row text-center md:flex-col">
    <li class="h-24 mr-3">
      <router-link :to="{ name: 'home' }">
        <div
          class="block py-1 pl-1 no-underline border-b-2 md:py-3 align-left transition ease-in-out hover:scale-110 hover:border-yellow-400 hover:text-yellow-400"
          v-bind:class="[
            nav === 0
              ? 'text-yellow-500 md:border-yellow-500'
              : 'text-neutral-900 md:border-neutral-900',
          ]"
        >
          <div class="flex items-center justify-start mx-2 mt-6 md:mt-10">
            <book-outlined :style="nav === 0 ? { color: '#EAB308' } : { color: '#171717' }" />
            <span class="ml-4 text-2xl font-bold">Books</span>
          </div>
        </div>
      </router-link>
    </li>
    <li class="flex-1 mr-3">
      <router-link :to="{ name: 'transactions' }" class="text-black">
        <div
          class="flex items-center p-2 my-6 rounded-lg transition ease-in-out hover:scale-110 hover:text-yellow-400"
          v-bind:class="[nav === 2 ? 'bg-gray-600 dark:bg-gray-800' : '']"
        >
          <bank-outlined :style="nav === 2 ? { color: '#EAB308' } : { color: '#171717' }" />
          <span
            class="mx-4 text-lg font-normal"
            v-bind:class="[nav === 2 ? 'text-yellow-500' : '']"
          >
            Ledger
          </span>
          <span class="flex-grow text-right"> </span>
        </div>
      </router-link>
    </li>
    <li class="flex-1 mr-3">
      <router-link :to="{ name: 'wallets' }" class="text-black">
        <div
          class="flex items-center p-2 my-6 rounded-lg transition ease-in-out hover:scale-110 hover:text-yellow-400"
          v-bind:class="[nav === 1 ? 'bg-gray-600 dark:bg-gray-800' : '']"
        >
          <wallet-outlined :style="nav === 1 ? { color: '#EAB308' } : { color: '#171717' }" />
          <span
            class="mx-4 text-lg font-normal"
            v-bind:class="[nav === 1 ? 'text-yellow-500' : '']"
          >
            Wallets
          </span>
          <span class="flex-grow text-right"> </span>
        </div>
      </router-link>
    </li>
    <li class="flex-1 mr-3">
      <router-link :to="{ name: 'rolodex' }" class="text-black">
        <div
          class="flex items-center p-2 my-6 rounded-lg transition ease-in-out hover:scale-110 hover:text-yellow-400"
          v-bind:class="[nav === 3 ? 'bg-gray-600 dark:bg-gray-800' : '']"
        >
          <contacts-outlined :style="nav === 3 ? { color: '#EAB308' } : { color: '#171717' }" />
          <span
            class="mx-4 text-lg font-normal"
            v-bind:class="[nav === 3 ? 'text-yellow-500' : '']"
            >Rolodex</span
          >
          <span class="flex-grow text-right"> </span>
        </div>
      </router-link>
    </li>
    <li>
      <div class="md:hidden">
        <div class="flex flex-row-reverse float-right text-right md:inline-block md:h-12">
          <a-tooltip title="Built by Quartus" placement="left">
            <a href="https://urbit.org/ids/~dalten" class="text-right" target="_blank">
              <QuartusLogo
                height="100"
                width="100"
              />
            </a>
          </a-tooltip>
        </div>
      </div>
    </li>
  </ul>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue';
import { useStore } from 'vuex';
import QuartusLogo from '@/components/QuartusLogo.vue';

import {
  BookOutlined,
  BankOutlined,
  WalletOutlined,
  ContactsOutlined
} from "@ant-design/icons-vue";

export default defineComponent({
  components: {
    BookOutlined,
    BankOutlined,
    WalletOutlined,
    ContactsOutlined,
    QuartusLogo,
  },
  setup() {
    //  boiler
    const store = useStore();

    const nav = computed(() => store.state.books.nav);

    return {
      nav,
    };
  },
});
</script>
