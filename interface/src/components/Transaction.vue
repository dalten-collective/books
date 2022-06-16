<template>
  <tr @click="toggleDetails"
      v-bind:class="[showingDetails ? 'bg-gray-100 dark:bg-gray-400' : '']">
    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
      <AddressLookup :addy="trans.primaryWallet"/>
    </td>
    <td class="text-sm text-gray-900 font-light px-6 py-4 whitespace-nowrap">
      <div v-if="trans.address === null">
        <AddressLookup :addy="trans.from"/>
      </div>
      <div v-else-if="trans.name == 'Exchange'">
        Exchange
      </div>
      <div v-else-if="trans.name == 'Receive'">
        Contract Interaction {{ truncateAddress(trans.address) }}
      </div>
      <div v-else-if="trans.name == 'Send'">
        <AddressLookup :addy="trans.primaryWallet"/>
      </div>
    </td>
    <td class="text-sm text-gray-900 font-light px-6 py-4 whitespace-nowrap">
      <div v-if="trans.address === null">
        <AddressLookup :addy="trans.destination"/>
      </div>
      <div v-else-if="trans.name == 'Exchange'">
        <AddressLookup :addy="trans.primaryWallet"/>
      </div>
      <div v-else-if="trans.name == 'Send'">
        Contract Interaction  {{ truncateAddress(trans.address) }}
      </div>
      <div v-else-if="trans.name == 'Receive'">
        <AddressLookup :addy="trans.primaryWallet"/>
      </div>
    </td>
    <td class="text-sm text-gray-900 font-light px-6 py-4 whitespace-nowrap">
      @mdo
    </td>
  </tr>
  <tr v-if="showingDetails">
    <td colspan="4">
      <div class="grid grid-cols-2 gap-4">
        <div>
          <div v-if="trans.address === null">
            <div v-if="trans.name === 'Receive'">
              <div>Received {{ trans.amount }} Ethereum from {{ truncateAddress(trans.from) }}</div>
            </div>
            <div v-else>
              <div>Sent {{ trans.amount }} Ethereum from {{ truncateAddress(trans.primaryWallet) }}</div>
              <div v-if="!trans.to">
                To {{ truncateAddress(trans.contract) }} {{ trans.hash }}
              </div>
              <div v-else>
                {{ truncateAddress(trans.to) }}
              </div>
            </div>
          </div>
          <div v-else-if="trans.name == 'Exchange'">
            <div class="step" v-for="step in trans.subTransactions" props="{{trans}}">
              <div v-if="step.type == 'incoming'">
                Received {{ step.amount.toSignificantDigits(5) }} {{ step.symbol }}
              </div>
              <div v-if="step.type == 'outgoing'">
                For {{ step.amount.toSignificantDigits(5) }} {{ step.symbol }}
              </div>
            </div>
          </div>
          <div v-else-if="trans.name == 'Receive' || trans.name == 'Send'">
            <div class="step" v-for="step in trans.subTransactions" props="{{trans}}">
              <div v-if="step.type == 'outgoing'">
                Sent {{ step.amount.toSignificantDigits(5) }} {{ step.symbol }} {{ trans.hash }}
              </div>
              <div v-if="step.type == 'incoming'">
                Received {{ step.amount.toSignificantDigits(5) }} {{ step.symbol }}
              </div>
            </div>
          </div>
          <div v-else>
            {{ trans }}
          </div>
        </div>
        <!-- ... -->
        <div>02</div>
      </div>
    </td>
  </tr>
</template>

<script lang="ts">
import AddressLookup from "@/components/AddressLookup.vue";
import { defineComponent } from 'vue'
import { BigNumber } from "ethers";
import { mapState } from "vuex";
import type { PropType } from 'vue';
import { Address } from "@/types";

export default defineComponent({
  data() {
    return {
      showingDetails: false,
    }
  },

  mounted() {
    console.log("mounted");

  },
  unmounted() {

  },
  components: {
    AddressLookup,
  },
  computed: {
    ...mapState("books", ["myWallets"]),
  },
  methods: {
    switchNav() {

    },

    toggleDetails() {
      this.showingDetails = !this.showingDetails;
    },

      truncateAddress(address) {
        try {
          const truncateRegex = /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;
          const match = address.match(truncateRegex);
          if (match) {
            return `${match[1]}…${match[2]}`
          }
        }
        catch(e) {
          console.log(address)
          return address;
        }

      },
  },
  props: [ 'trans' ]
})
</script>

