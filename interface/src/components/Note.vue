<template>
  <a-form :model="formState">
    <a-form-item label="Annotated: ">
      <a-switch
        v-model:checked="formState.annotated"
        :style="[formState.annotated ? 'background-color: #788AAC' : '']"
      />
    </a-form-item>

    <a-form-item
      label="Basis: "
      :style="[formState.annotated ? '' : 'display: none']"
    >
      <a-input-number
        v-model:value="formState.basis"
        :formatter="(value) => `${value}`.replace(/(\d)(?=(\d{3})+\.)/g, '$1,')"
      />
    </a-form-item>
    <a-form-item
      label="To: "
      :style="[formState.annotated ? '' : 'display: none']"
    >
      <div class="flex flex-row" v-if="formState.to === null">
        <svg
          class="basis-1/12"
          xmlns="http://www.w3.org/2000/svg"
          height="24px"
          width="24px"
          viewBox="0 0 48 48"
        >
          <path
            d="M29.4 22.9 19.75 13.25Q20.6 12.55 21.675 12.175Q22.75 11.8 24 11.8Q26.9 11.8 28.875 13.775Q30.85 15.75 30.85 18.65Q30.85 19.9 30.475 20.975Q30.1 22.05 29.4 22.9ZM11.1 35.25Q14.25 33.05 17.275 31.875Q20.3 30.7 24 30.7Q25.85 30.7 27.275 30.975Q28.7 31.25 29.85 31.65L23.7 25.5Q21 25.4 19.225 23.675Q17.45 21.95 17.2 19.25L10.9 12.95Q9.05 15.2 8.025 17.925Q7 20.65 7 24Q7 27.05 7.95 29.8Q8.9 32.55 11.1 35.25ZM37.15 34.95Q38.9 32.85 39.95 30.075Q41 27.3 41 24Q41 16.75 36.125 11.875Q31.25 7 24 7Q20.5 7 17.8 8.05Q15.1 9.1 13 10.8ZM24 44Q19.9 44 16.25 42.425Q12.6 40.85 9.875 38.125Q7.15 35.4 5.575 31.75Q4 28.1 4 24Q4 19.85 5.575 16.225Q7.15 12.6 9.875 9.875Q12.6 7.15 16.25 5.575Q19.9 4 24 4Q28.15 4 31.775 5.575Q35.4 7.15 38.125 9.875Q40.85 12.6 42.425 16.225Q44 19.85 44 24Q44 28.1 42.425 31.75Q40.85 35.4 38.125 38.125Q35.4 40.85 31.775 42.425Q28.15 44 24 44ZM24 41Q26.95 41 29.475 40.15Q32 39.3 34.55 37.4Q32 35.6 29.35 34.65Q26.7 33.7 24 33.7Q21.3 33.7 18.65 34.65Q16 35.6 13.45 37.4Q16 39.3 18.55 40.15Q21.1 41 24 41ZM24 37.35Q24 37.35 24 37.35Q24 37.35 24 37.35Q24 37.35 24 37.35Q24 37.35 24 37.35Q24 37.35 24 37.35Q24 37.35 24 37.35Q24 37.35 24 37.35Q24 37.35 24 37.35Z"
          />
        </svg>
        <a-form-item class="basis-11/12">
          <a-select
            v-model:value="formState.to"
            show-search
            placeholder="Select a Destination/Counterparty"
            style="width: 300px"
            :options="people"
            :filterOption="
              (input, option) => {
                return (
                  option.value.toLowerCase().indexOf(input.toLowerCase()) >=
                    0 ||
                  option.nick.toLowerCase().indexOf(input.toLowerCase()) >= 0
                );
              }
            "
            @focus="handleFocus"
            @blur="handleBlur"
            @change="handleChange"
          >
          </a-select>
        </a-form-item>
      </div>
      <div v-else></div>
    </a-form-item>
  </a-form>
</template>

<script lang="ts">
import { defineComponent, reactive, computed } from 'vue';
import { useStore } from 'vuex';
import type { PropType } from 'vue';
import { TxHash } from '@/types';
import Immutable, { OrderedMap, Map } from 'immutable';
import { Decimal } from 'decimal.js';

export default defineComponent({
  setup(props) {
    //  boiler
    const store = useStore();

    //  mapState and mapGetters replacements
    const notes = computed(() => store.state.books.notes);
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);

    const annotations = computed(() => {
      return Immutable.Map(notes);
    });
    
    const people = computed(() => {
      const friends = (() => {
        return myFriends.value.map((item) => {
          return {
            value: item[0],
            label: (() => {
              if (!item[1].nick) {
                return truncateAddress(item[0]);
              } else {
                return item[1].nick;
              }
            })(),
            nick: item[1].nick,
            tags: item[1].tags,
          };
        });
      })() as Array<{
        value: string;
        label: string;
        nick: string;
        tags: Array<string>;
      }>;
      const wallets = (() => {
        return myWallets.value.map((item) => {
          return {
            value: item[0],
            label: (() => {
              console.log(item);
              if (!item[1].nick) {
                return truncateAddress(item[0]);
              } else {
                return item[1].nick;
              }
            })(),
            nick: item[1].nick,
            tags: item[1].tags,
          };
        });
      })() as Array<{
        value: string;
        label: string;
        nick: string;
        tags: Array<string>;
      }>;
      return wallets.concat(friends) as Array<{
        value: string;
        label: string;
        nick: string;
        tags: Array<string>;
      }>;
    });

    //  form stuff
    const formState = reactive({
      annotated: (() => {
        return Immutable.has(annotations, props.hash) as boolean;
      })(),
      basis: (() => {
        if (Immutable.has(annotations, props.hash)) {
          return Immutable.get(annotations, props.hash).basis as Decimal;
        } else {
          return 0x0 as Decimal;
        }
      })(),
      to: (() => {
        if (Immutable.has(annotations, props.hash)) {
          return Immutable.get(annotations, props.hash)
            .to as Address | null;
        } else {
          return null as Address | null;
        }
      })(),
      annnotation: '' as string,
      tags: [] as Array<[string]>,
    })

    return {
      notes,
      myWallets,
      myFriends,
      annotations,
      people,
      formState
    }
  },

  methods: {
    hasNote(hash) {
      return Immutable.has(annotations, hash) as boolean;
    },
    getBasis(hash) {
      if (Immutable.has(annotations, hash)) {
        return Immutable.get(annotations, hash).basis as Decimal;
      } else {
        return 0x0 as Decimal;
      }
    },
    getTo(hash) {
      if (Immutable.has(annotation, hash)) {
        return Immutable.get(annotations, hash).to as Address | null;
      } else {
        return null as Address | null;
      }
    },
    truncateAddress(address) {
      try {
        const truncateRegex =
          /^(0x[a-zA-Z0-9]{4})[a-zA-Z0-9]+([a-zA-Z0-9]{4})$/;
        const match = address.match(truncateRegex);
        if (match) {
          return `${match[1]}…${match[2]}`;
        }
      } catch (e) {
        return address;
      }
    },
    handleChange(value) {
      console.log('selected', value);
    },
    handleBlur() {
      console.log('blur on select');
    },
    handleFocus() {
      console.log('focus');
    },
  },

  props: {
    hash: {
      type: String as PropType<TxHash>,
      default: '0x0',
    },
  },
});
</script>
