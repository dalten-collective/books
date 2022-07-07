<template>
  <ul class="list-reset flex flex-row text-center md:flex-col md:text-left">
    <li class="mr-3 h-24">
      <router-link :to="{ name: 'home' }">
        <div
          class="md:py-3 align-left block border-b-2 py-1 pl-1 no-underline transition ease-in-out hover:scale-110 hover:border-yellow-400 hover:text-yellow-400"
          v-bind:class="[
            nav === 0
              ? 'text-yellow-500 md:border-yellow-500'
              : 'text-neutral-900 md:border-neutral-900',
          ]"
        >
          <div class="mx-2 mt-6 md:mt-10 flex items-center justify-start">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              height="24px"
              viewBox="0 0 20 22"
              width="24px"
              fill="#000000"
            >
              <path d="M0 0h24v24H0V0z" fill="none" />
              <path
                d="M18 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM9 4h2v5l-1-.75L9 9V4zm9 16H6V4h1v9l3-2.25L13 13V4h5v16z"
                v-bind:fill="[nav === 0 ? '#EAB308' : '#171717']"
              />
            </svg>
            <span class="ml-4 text-2xl font-bold">Books</span>
          </div>
        </div>
      </router-link>
    </li>
    <li class="mr-3 flex-1">
      <router-link :to="{ name: 'transactions' }">
        <div
          class="my-6 flex items-center rounded-lg p-2 transition ease-in-out hover:scale-110 hover:text-yellow-400"
          v-bind:class="[nav === 2 ? 'bg-gray-600 dark:bg-gray-800' : '']"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            height="24px"
            width="24px"
            viewBox="0 0 24 24"
            fill="#000000"
          >
            <path d="M0 0h24v24H0V0z" fill="none" />
            <path
              d="M6.5 10h-2v7h2v-7zm6 0h-2v7h2v-7zm8.5 9H2v2h19v-2zm-2.5-9h-2v7h2v-7zm-7-6.74L16.71 6H6.29l5.21-2.74m0-2.26L2 6v2h19V6l-9.5-5z"
              v-bind:fill="[nav === 2 ? '#EAB308' : '#171717']"
            />
          </svg>
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
    <li class="mr-3 flex-1">
      <router-link :to="{ name: 'wallets' }">
        <div
          class="my-6 flex items-center rounded-lg p-2 transition ease-in-out hover:scale-110 hover:text-yellow-400"
          v-bind:class="[nav === 1 ? 'bg-gray-600 dark:bg-gray-800' : '']"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            height="24px"
            width="24px"
            viewBox="0 0 24 24"
            fill="#000000"
          >
            <path d="M0 0h24v24H0V0z" fill="none" />
            <path
              d="M21 7.28V5c0-1.1-.9-2-2-2H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-2.28c.59-.35 1-.98 1-1.72V9c0-.74-.41-1.37-1-1.72zM20 9v6h-7V9h7zM5 19V5h14v2h-6c-1.1 0-2 .9-2 2v6c0 1.1.9 2 2 2h6v2H5z"
              v-bind:fill="[nav === 1 ? '#EAB308' : '#171717']"
            />
            <circle
              cx="16"
              cy="12"
              r="1.5"
              v-bind:fill="[nav === 1 ? '#EAB308' : '#171717']"
            />
          </svg>
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
    <li class="mr-3 flex-1">
      <router-link :to="{ name: 'rolodex' }">
        <div
          class="my-6 flex items-center rounded-lg p-2 transition ease-in-out hover:scale-110 hover:text-yellow-400"
          v-bind:class="[nav === 3 ? 'bg-gray-600 dark:bg-gray-800' : '']"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            height="24px"
            width="24px"
            viewBox="0 0 24 24"
            fill="#000000"
          >
            <path d="M0 0h24v24H0V0z" fill="none" />
            <path
              d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 14H4V6h16v12zM4 0h16v2H4zm0 22h16v2H4zm8-10c1.38 0 2.5-1.12 2.5-2.5S13.38 7 12 7 9.5 8.12 9.5 9.5 10.62 12 12 12zm0-3.5c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm5 7.49C17 13.9 13.69 13 12 13s-5 .9-5 2.99V17h10v-1.01zm-8.19-.49c.61-.52 2.03-1 3.19-1 1.17 0 2.59.48 3.2 1H8.81z"
              v-bind:fill="[nav === 3 ? '#EAB308' : '#171717']"
            />
          </svg>
          <span
            class="mx-4 text-lg font-normal"
            v-bind:class="[nav === 3 ? 'text-yellow-500' : '']"
            >Rolodex</span
          >
          <span class="flex-grow text-right"> </span>
        </div>
      </router-link>
    </li>
  </ul>
</template>

<script lang="ts">
import { defineComponent, computed } from 'vue';
import WalletList from '@/components/WalletList.vue';
import TransactionList from '@/components/TransactionList.vue';
import AddressLookup from '@/components/AddressLookup.vue';
import { BigNumber } from 'ethers';
import { useStore } from 'vuex';

export default defineComponent({
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
