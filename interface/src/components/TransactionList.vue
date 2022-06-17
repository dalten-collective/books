<template>
  <div class="flex">
    <div class="grow">
      <PagePolice />
    </div>
    <div class="flex-none basis-1/2" />
    <div class="grow">
      <SelectedWallet />
    </div>
  </div>
  <NewTransactions />
  <div class="flex flex-col">
    <div class="overflow-x-auto sm:-mx-6 lg:-mx-8">
      <div class="inline-block min-w-full py-2 sm:px-6 lg:px-8">
        <div class="overflow-hidden">
          <table class="min-w-full">
            <thead class="border-b bg-white">
              <tr>
                <th
                  scope="col"
                  class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                >
                  Timestamp
                </th>
                <th
                  scope="col"
                  class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                >
                  Primary Wallet
                </th>
                <th
                  scope="col"
                  class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                >
                  From
                </th>
                <th
                  scope="col"
                  class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                >
                  To
                </th>
                <th
                  scope="col"
                  class="px-6 py-4 text-left text-sm font-medium text-gray-900"
                >
                  Action
                </th>
              </tr>
            </thead>
            <tbody
              v-for="[kex, details] in paginateTransactions"
              :key="details.hash"
              class="border-b bg-white transition duration-300 ease-in-out hover:bg-gray-100"
            >
              <TransUnit :trans="details" />
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>

  <div class="transactions">
    <div v-for="[kex, details] in paginateTransactions" :key="details.hash">
      <div class="timestamp">{{ makeDate(details.timeStamp) }}</div>
      <div class="network">{{ 'Chain: ' + details.network }}</div>
      <div class="base-transaction" v-if="details.address === null">
        <div class="behavior">{{ details.name + ' Ethereum' }}</div>
        <div class="transaction-stub">
          From:
          <AddressLookup :addy="details.from" />
          To:
          <AddressLookup :addy="details.destination" />
        </div>
      </div>

      <div class="sub-transaction" v-else>
        <div v-if="details.name == 'Exchange'">
          <div class="traded">
            <div class="traded-header">Traded</div>
            <div
              class="send"
              v-if="chkStep(details.subTransactions, 'outgoing')"
            >
              <div
                class="step"
                v-for="step in details.subTransactions"
                props="{{details}}"
              >
                <div v-if="step.type == 'outgoing'">
                  <!--step.amount.greaterThanOrEqualTo(0.00001)-->
                  {{ step.amount.toSignificantDigits(5) + ' ' + step.symbol }}
                </div>
              </div>
            </div>

            <div class="traded-header">For</div>
            <div
              class="send"
              v-if="chkStep(details.subTransactions, 'incoming')"
            >
              <div
                class="step"
                v-for="step in details.subTransactions"
                props="{{details}}"
              >
                <div v-if="step.type == 'incoming'">
                  <!--step.amount.greaterThanOrEqualTo(0.00001)-->
                  {{ step.amount.toSignificantDigits(5) + ' ' + step.symbol }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-else>
          <div class="symbol">{{ details.symbol }}</div>
          <div
            class="receive"
            v-if="chkStep(details.subTransactions, 'incoming')"
          >
            <div class="act">Received</div>
            <div
              class="step"
              v-for="step in details.subTransactions"
              props="{{details}}"
            >
              <div v-if="step.type == 'incoming'">
                {{
                  step.amount.toSignificantDigits(5) +
                  ' ' +
                  step.symbol +
                  ' from '
                }}
              </div>
              <pre>{{ details.from }}</pre>
            </div>
          </div>

          <div class="send" v-if="chkStep(details.subTransactions, 'outgoing')">
            <div class="act">Sent</div>
            <div
              class="step"
              v-for="step in details.subTransactions"
              props="{{details}}"
            >
              <div v-if="step.type == 'outgoing'">
                {{
                  step.amount.toSignificantDigits(5) +
                  ' ' +
                  step.symbol +
                  ' to '
                }}
              </div>
              <pre>{{ details.destination }}</pre>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
import AddressLookup from '@/components/AddressLookup.vue';
import PagePolice from '@/components/PagePolice.vue';
import SelectedWallet from '@/components/SelectedWallet.vue';
import NewTransactions from '@/components/NewTransactions.vue';
import TransUnit from '@/components/Transaction.vue';
import { defineComponent } from 'vue';
import { mapState, mapGetters } from 'vuex';
import type { PropType } from 'vue';
import dateFormat, { masks } from 'dateformat';
import Immutable from 'immutable';
import { TxHash, Transaction } from '@/types';

export default defineComponent({
  mounted() {
    this.switchNav();
  },
  unmounted() {},
  components: {
    AddressLookup,
    PagePolice,
    SelectedWallet,
    TransUnit,
    NewTransactions,
  },
  computed: {
    ...mapState('books', ['urbitData']),
    ...mapGetters('books', ['orderedTransactions']),
    ...mapGetters('books', ['paginateTransactions']),
  },
  methods: {
    chkStep(arr, wat) {
      return arr.some((el) => el.type == wat);
    },

    makeDate(secs) {
      let txDate = new Date(secs * 1000);
      let ftxDate =
        dateFormat(txDate, 'paddedShortDate') +
        ' ' +
        dateFormat(txDate, 'h:MM:ss TT');
      return ftxDate;
    },

    switchNav() {
      this.$store.dispatch('books/handleSwitchNav', 2);
    },
  },
});
</script>
