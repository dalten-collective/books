<template>
  <h1>Books</h1>
  <button @click="fetchTx">Query</button>
  <div class="tx-container">
    <div v-for="[timestamp, details] in webData" :key="timestamp">
      <!--  
      Vinney Notes:

        - routing + getter for pagination
          * Home Page
            * Transactions
              > By Network      /transactions/ethereum
              > By Transaction  /transactions/ethereum/0x0
            * Query Params
              > ?first=@da
              > ?act=?(%send %receive %exchange)
              > ?address=0x0
          ^ Getters Hoop from Vinney
        - startup behaviors
          * subscribe to urbit, to get wallets and maybe the other data
          * mounted & unmounted lifecycle elements
            > create wrapper page
        - to do
          * airlock v-if
          * build out wallet storage, in out, + subscription /website for hoon agent
          * work on main page that subscribes and displays stored wallets + header
          * dynamize axios call based on stored wallets
          * work on poke down of data from axios for first time
          * work on poke up from urbit of display data
          * comparison of two to cause new pokes
            > re-render based on urbit data only
          * Pathing
          * Pending
            > Pending == True (spinner)
              on result of first api, turn off spinner


        - need filtering behavior for stored wallets
          (which could be in to or from position)
            Note: this will come from a different map
        - need filtering for network/chain
        - need filtering for Send/Receive/Exchange
        - need filtering for to/from address
        - need help w/ reformatting axios request for multi-wal
            Note: this must also proc on loading the wallet list
            Note: we need "loading" until urbit send wallet +
                  known data, then display that, then "accessing"
                  new information from zapper, then display that/apps/books/
                  finally, send new data (compare) home to urbit
                  all on load
        - X - need check on timestamp uniqueness, and preferably a failure
          that is replicable so that it can be repeated predictably
      -->

      <div class="timestamp"> {{ makeDate(timestamp) }} </div>
    
      <div class="network"> {{ "Chain: " + details.network }} </div>

      <!--
      Vinney Note:
        This needs to be it's own component with logic:
          - IF a base-currency transaction, then this way
          - IF a contract then:
            - IF an exchange behavior, this way
            - ELSE that way
        I also need a lookup for every address against a
        pair of nickname maps from Urbit
      -->
      <div class="base-transaction" v-if="details.address == null">
        <div class="behavior"> {{ details.name + " Ethereum" }} </div>
        <div class="transaction-stub">
          From: 
          <AddressLookup :non-reserved-word="details.from"/>
          To: 
          <AddressLookup :non-reserved-word="details.destination"/>
        </div>
      </div>

      <div class="sub-transaction" v-else>

        <div v-if="details.name == 'Exchange'">
          <div class="traded">
            <div class="traded-header">Traded</div>

            <div class="send" v-if="chkStep(details.subTransactions, 'outgoing')">
              <div class="step" v-for="step in details.subTransactions" props="{{details}}">
                <div v-if="step.type == 'outgoing'">  <!--step.amount.greaterThanOrEqualTo(0.00001)-->
                  {{ step.amount.toSignificantDigits(5) + " " + step.symbol }}
                </div>
              </div>
            </div>

            <div class="traded-header">For</div>

            <div class="send" v-if="chkStep(details.subTransactions, 'incoming')">
              <div class="step" v-for="step in details.subTransactions" props="{{details}}">
                <div v-if="step.type == 'incoming'">  <!--step.amount.greaterThanOrEqualTo(0.00001)-->
                  {{ step.amount.toSignificantDigits(5) + " " + step.symbol }}
                </div>
              </div>
            </div>         

          </div>
        </div>

        <div v-else>

          <div class="symbol"> {{ details.symbol }} </div>
          <div class="receive" v-if="chkStep(details.subTransactions, 'incoming')">
            <div class="act">Received</div>
            <div class="step" v-for="step in details.subTransactions" props="{{details}}">
              <div v-if="step.type == 'incoming'">
                {{ step.amount.toSignificantDigits(5) + " " + step.symbol + " from " + details.from }}
              </div>
            </div>

          </div>

          <div class="send" v-if="chkStep(details.subTransactions, 'outgoing')">
            <div class="act">Sent</div>
            <div class="step" v-for="step in details.subTransactions" props="{{details}}">
              <div v-if="step.type == 'outgoing'">
                {{ step.amount.toSignificantDigits(5) + " " + step.symbol + " to " + details.destination }}
              </div>
            </div>

          </div>

        </div>

      </div>

    </div>
  </div>

</template>

<script lang="ts">
import { defineComponent } from "vue";
import { BigNumber } from "ethers";
import { mapState } from "vuex";
import AddressLookup from "@/components/AddressLookup.vue";
import dateFormat, { masks } from "dateformat";


export default defineComponent({
  mounted() {

  },
  unmounted() {
    this.closeAirlocks();
  },

  components: {
    AddressLookup
  },

  computed: {
    ...mapState("books", ["arTrans", "webData"]),
  },

  methods: {
    fetchTx() {
      this.$store.dispatch("books/fetchTransactions");
    },
    startAirlock(deskname) {
      this.$store.dispatch("ship/openAirlockToAgent", deskname);
    },
    closeAirlocks() {
      this.$store.dispatch("ship/closeAgentAirlocks");
    },

    chkStep(arr, wat) {
      return arr.some(el => el.type == wat);
    },

    makeDate(secs) {
      let txDate = new Date(secs * 1000);
      let ftxDate = dateFormat(txDate, 'paddedShortDate') + 
                    " " + dateFormat(txDate, 'h:MM:ss TT');
      return ftxDate;

      function leadingZeros(n) {
        if (n <= 9) {
          if (n == 0) {
            return 12;
          } else {
            return "0" + n;
          }
        } else {
          return n;
        }
      }
    },

    onChangePage(pageOfItems) {
      this.pageofItems = pageOfItems;
    },
  },
})
</script>


