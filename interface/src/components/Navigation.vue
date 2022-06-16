<template>
  <ul class="list-reset flex flex-row md:flex-col text-center md:text-left">
    <li class="mr-3 flex-1">
      <router-link :to="{ name: 'home'}">
        <div class="block py-1 md:py-3 pl-1 align-left text-neutral-900 no-underline hover:text-pink border-b-2 border-grey-darkest md:border-black hover:border-pink">
          <div class="flex items-center justify-start mx-2 mt-10">
              <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 20 22" width="24px" fill="#000000">
                <path d="M0 0h24v24H0V0z" fill="none"/>
                <path d="M18 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zM9 4h2v5l-1-.75L9 9V4zm9 16H6V4h1v9l3-2.25L13 13V4h5v16z" fill="#1C1917"/>
              </svg>
              <span class="ml-4 text-2xl font-bold">
                  Books
              </span>
          </div>
        </div>
      </router-link>
    </li>
    <li class="mr-3 flex-1">
      <router-link :to="{ name: 'wallets' }">
        <div class="hover:text-gray-800 hover:bg-gray-100 flex items-center
                  p-2 my-6 transition-colors dark:hover:text-white
                  dark:hover:bg-gray-600 duration-200 "
                  v-bind:class="[nav === 1 ? 'text-gray-800 dark:text-gray-100 rounded-lg bg-gray-100 dark:bg-gray-600' : 'text-gray-600 dark:text-gray-400 rounded-lg' ]">
          <svg xmlns="http://www.w3.org/2000/svg" height="24px"
               viewBox="0 0 24 24" width="24px" fill="#000000">
            <path d="M0 0h24v24H0V0z" fill="none"/>
            <path d="M21 7.28V5c0-1.1-.9-2-2-2H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-2.28c.59-.35 1-.98 1-1.72V9c0-.74-.41-1.37-1-1.72zM20 9v6h-7V9h7zM5 19V5h14v2h-6c-1.1 0-2 .9-2 2v6c0 1.1.9 2 2 2h6v2H5z"/>
            <circle cx="16" cy="12" r="1.5"/>
          </svg>
          <span class="mx-4 text-lg font-normal">
              Wallets
          </span>
          <span class="flex-grow text-right">
          </span>
        </div>
      </router-link>
    </li>
    <li class="mr-3 flex-1">
      <router-link :to="{ name: 'transactions' }">
        <div class="hover:text-gray-800 hover:bg-gray-100 flex items-center
                  p-2 my-6 transition-colors dark:hover:text-white
                  dark:hover:bg-gray-600 duration-200"
                  v-bind:class="[nav === 2 ? 'text-gray-800 dark:text-gray-100 rounded-lg bg-gray-100 dark:bg-gray-600' : 'text-gray-600 dark:text-gray-400 rounded-lg']">
          <svg xmlns="http://www.w3.org/2000/svg" height="24px" 
               viewBox="0 0 24 24" width="24px" fill="#000000">
            <path d="M0 0h24v24H0V0z" fill="none"/>
            <path d="M6.5 10h-2v7h2v-7zm6 0h-2v7h2v-7zm8.5 9H2v2h19v-2zm-2.5-9h-2v7h2v-7zm-7-6.74L16.71 6H6.29l5.21-2.74m0-2.26L2 6v2h19V6l-9.5-5z"/>
          </svg>
          <span class="mx-4 text-lg font-normal">
              Ledger
          </span>
          <span class="flex-grow text-right">
          </span>
        </div>
      </router-link>
    </li>
    <li class="mr-3 flex-1">
      <a class="hover:text-gray-800 hover:bg-gray-100 flex items-center
                p-2 my-6 transition-colors dark:hover:text-white
                dark:hover:bg-gray-600 duration-200"
                v-bind:class="[nav === 3 ? 'text-gray-800 dark:text-gray-100 rounded-lg bg-gray-100 dark:bg-gray-600' : 'text-gray-600 dark:text-gray-400 rounded-lg']"
                href="#">
        <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="#000000">
          <path d="M0 0h24v24H0V0z" fill="none"/>
          <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 14H4V6h16v12zM4 0h16v2H4zm0 22h16v2H4zm8-10c1.38 0 2.5-1.12 2.5-2.5S13.38 7 12 7 9.5 8.12 9.5 9.5 10.62 12 12 12zm0-3.5c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm5 7.49C17 13.9 13.69 13 12 13s-5 .9-5 2.99V17h10v-1.01zm-8.19-.49c.61-.52 2.03-1 3.19-1 1.17 0 2.59.48 3.2 1H8.81z"/>
        </svg>
        <span class="mx-4 text-lg font-normal">
            Rolodex
        </span>
        <span class="flex-grow text-right">
        </span>
      </a>
    </li>
    <li class="mr-3 flex-1">
      <a class="text-gray-600 dark:text-gray-300 hover:text-gray-800 dark:hover:text-gray-100 transition-colors duration-200 flex items-center py-2 px-8" href="#">
          <svg width="20" fill="currentColor" height="20" class="h-5 w-5" viewBox="0 0 1792 1792" xmlns="http://www.w3.org/2000/svg">
              <path d="M1088 1256v240q0 16-12 28t-28 12h-240q-16 0-28-12t-12-28v-240q0-16 12-28t28-12h240q16 0 28 12t12 28zm316-600q0 54-15.5 101t-35 76.5-55 59.5-57.5 43.5-61 35.5q-41 23-68.5 65t-27.5 67q0 17-12 32.5t-28 15.5h-240q-15 0-25.5-18.5t-10.5-37.5v-45q0-83 65-156.5t143-108.5q59-27 84-56t25-76q0-42-46.5-74t-107.5-32q-65 0-108 29-35 25-107 115-13 16-31 16-12 0-25-8l-164-125q-13-10-15.5-25t5.5-28q160-266 464-266 80 0 161 31t146 83 106 127.5 41 158.5z">
              </path>
          </svg>
          <span class="font-medium">
              Support
          </span>
      </a>
    </li>
  </ul>
</template>

<script lang="ts">
import { defineComponent } from 'vue'
import Start from "@/components/Start.vue";
import WalletList from "@/components/WalletList.vue";
import TransactionList from "@/components/TransactionList.vue";
import AddressLookup from "@/components/AddressLookup.vue";
import { BigNumber } from "ethers";
import { mapState } from "vuex";

export default defineComponent({
  mounted() {

  },
  unmounted() {

  },
  components: {

  },
  computed: {
    ...mapState('books', ['nav'])
  },
  methods: {

  },
})
</script>