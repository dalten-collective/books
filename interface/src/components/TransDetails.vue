<template>
  <a-tabs v-model:activeKey="activeKey">
    <a-tab-pane key="1" tab="Transaction Details">
      <a-timeline>
        <a-timeline-item>
          <a-statistic :value="timestamp" :value-style="{ fontSize: '15px' }">
          </a-statistic>
        </a-timeline-item>
        <a-timeline-item
          v-for="step in description"
          :key="step[0]"
          class="mb-2"
        >
          <template #dot>
            <svg
              v-if="step[0] === 'outgoing'"
              focusable="false"
              class=""
              data-icon="arrow-up"
              width="15px"
              height="15px"
              fill="red"
              aria-hidden="true"
              viewBox="64 64 896 896"
            >
              <path
                d="M868 545.5L536.1 163a31.96 31.96 0 00-48.3 0L156 545.5a7.97 7.97 0 006 13.2h81c4.6 0 9-2 12.1-5.5L474 300.9V864c0 4.4 3.6 8 8 8h60c4.4 0 8-3.6 8-8V300.9l218.9 252.3c3 3.5 7.4 5.5 12.1 5.5h81c6.8 0 10.5-8 6-13.2z"
              />
            </svg>
            <svg
              v-if="step[0] === 'incoming'"
              focusable="false"
              class=""
              data-icon="arrow-down"
              width="15px"
              height="15px"
              fill="green"
              aria-hidden="true"
              viewBox="64 64 896 896"
            >
              <path
                d="M862 465.3h-81c-4.6 0-9 2-12.1 5.5L550 723.1V160c0-4.4-3.6-8-8-8h-60c-4.4 0-8 3.6-8 8v563.1L255.1 470.8c-3-3.5-7.4-5.5-12.1-5.5h-81c-6.8 0-10.5 8.1-6 13.2L487.9 861a31.96 31.96 0 0048.3 0L868 478.5c4.5-5.2.8-13.2-6-13.2z"
              />
            </svg>
          </template>
          <a-tooltip
            :title="[null === step[3] ? 'Null Address' : step[3]]"
            color="gold"
            placement="topLeft"
          >
            <a-statistic
              :title="[
                step[0] === 'outgoing'
                  ? 'Sent to ' + nameChek(step[3])
                  : 'Received from ' + nameChek(step[3]),
              ]"
              :value="step[1]"
              :precision="2"
              :suffix="step[2]"
              :value-style="{ fontSize: '15px' }"
            >
            </a-statistic>
          </a-tooltip>
        </a-timeline-item>
      </a-timeline>
    </a-tab-pane>
    <a-tab-pane key="2" tab="Other Information">
      <a-descriptions>
        <a-descriptions-item label="Network Fees">
          {{ fee }}
        </a-descriptions-item>
        <a-descriptions-item label="Function Call">
          {{ input }}
        </a-descriptions-item>
        <a-descriptions-item label="Nonce">
          {{ nonce }}
        </a-descriptions-item>
        <a-descriptions-item label="Transaction Hash">
          <a-tooltip :title="hash" color="gold" placement="top">
            <a :href="'https://etherscan.io/tx/' + hash" target="_blank">
              <div class="flex">
                {{ truncateHash(hash) }}
                <svg
                  class="cursor-pointer"
                  height="20"
                  width="20"
                  viewBox="0 0 48 48"
                >
                  <path
                    d="M24 44q-4.15 0-7.8-1.575-3.65-1.575-6.35-4.275-2.7-2.7-4.275-6.35Q4 28.15 4 24t1.575-7.8Q7.15 12.55 9.85 9.85q2.7-2.7 6.35-4.275Q19.85 4 24 4t7.8 1.575q3.65 1.575 6.35 4.275 2.7 2.7 4.275 6.35Q44 19.85 44 24t-1.575 7.8q-1.575 3.65-4.275 6.35-2.7 2.7-6.35 4.275Q28.15 44 24 44Zm-2.15-3.05v-4.1q-1.75 0-2.95-1.3-1.2-1.3-1.2-3.05v-2.2L7.45 20.05q-.25 1-.35 1.975Q7 23 7 24q0 6.5 4.225 11.35t10.625 5.6Zm14.7-5.4q2.2-2.4 3.325-5.375T41 24q0-5.3-2.9-9.625T30.35 8.05v.9q0 1.75-1.2 3.05-1.2 1.3-2.95 1.3h-4.35v4.35q0 .85-.675 1.4-.675.55-1.525.55H15.5V24h12.9q.85 0 1.4.65.55.65.55 1.5v6.35h2.15q1.45 0 2.55.85 1.1.85 1.5 2.2Z"
                    fill="#EAB308"
                  />
                </svg>
              </div>
            </a>
          </a-tooltip>
        </a-descriptions-item>
      </a-descriptions>
    </a-tab-pane>
  </a-tabs>
</template>

<script lang="ts">
import { defineComponent, computed, ref } from 'vue';
import { useStore } from 'vuex';
import { Address } from '@/types';
import { Decimal } from 'decimal.js';
import Immutable from 'immutable';

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mapState and mapGetters replacements
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);

    //  Tabs
    const activeKey = ref('1');

    //  Methods
    const truncateHash = (hash) => {
      try {
        const truncateRegex =
          /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;
        const match = hash.match(truncateRegex);
        if (match) {
          return `${match[1]}…${match[2]}`;
        }
      } catch (e) {
        return hash;
      }
    };

    const nameChek = (addy) => {
      //  First, get arrays of addy, name for utility
      const myne = myWallets.value
        .slice()
        .map((item) => [item[0], item[1].nick]);
      const yurs = myFriends.value
        .slice()
        .map((item) => [item[0], item[1].nick]);
      const mapp = Immutable.Map(myne.concat(yurs));

      if (null === addy) {
        return 'Unknown';
      } else if (mapp.has(addy)) {
        return Immutable.get(mapp, addy);
      } else {
        try {
          const truncateRegex =
            /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;
          const match = addy.match(truncateRegex);
          if (match) {
            return `${match[1]}…${match[2]}`;
          }
        } catch (e) {
          return addy;
        }
      }
    };

    return {
      nameChek,
      activeKey,
      truncateHash,
    };
  },

  props: {
    timestamp: String,
    description: {
      type: Array<[string, string, string, Address]>,
    },
    nonce: {
      type: Number,
    },
    input: {
      type: String,
    },
    fee: {
      type: String,
    },
    hash: {
      type: String,
    },
  },
});
</script>
