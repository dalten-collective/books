<template>
  <a-input v-model:value="textSearch" placeholder="Search addresses, nicknames and tags"/>
  <a-table
    bordered
    :columns="columns"
    :data-source="filteredWallets"
    :scroll="{ x: 750 }"
    :loading="overallLoading"
  >
    <template #name="{ text, record }">
      <div class="editable-cell">
        <div
          v-if="editableData[record.key]"
          class="editable-cell-input-wrapper"
        >
          <a-input
            v-model:value="editableData[record.key].name"
            @pressEnter="save(record.key)"
          />
          <check-outlined
            class="editable-cell-icon-check"
            @click="save(record.key)"
          />
        </div>
        <div v-else class="editable-cell-text-wrapper">
          {{ text || ' ' }}
          <edit-outlined class="editable-cell-icon" @click="edit(record.key)" />
        </div>
      </div>
    </template>
    <template #tags="{ record }">
      <WalletTagEdit :record="record" />
    </template>
    <template #actions="{ record }">
      <a-popconfirm
        title="Are you sure you want to remove this wallet?"
        @confirm="onDelete(record.key)"
      >
        <a>Delete</a>
      </a-popconfirm>
    </template>
  </a-table>

  <a-form
    ref="formRef"
    :rules="rules"
    :layout="formState.layout"
    :model="formState"
  >
    <a-form-item label="Nickname: " ref="nick" name="nick">
      <a-input v-model:value="formState.nick" placeholder="UnBankedKing" />
    </a-form-item>
    <a-form-item label="Address: ">
      <a-input
        v-model:value="formState.address"
        placeholder="0xeeee.1111.2222.3333.4444.5555.6666.7777.8888.9999"
      />
    </a-form-item>
    <a-form-item label="Tags: ">
      <a-input v-model:value="formState.tags" placeholder="abc one-two three" />
    </a-form-item>
    <a-button type="primary" class="bg-slate-600" @click="onSubmit"
      >Add Tracked Wallet</a-button
    >
  </a-form>
  <div name="entry" class="flex flex-row">
    <div :class="[pushWalletPending ? 'bg-gray-100 dark:bg-gray-400' : '']">
      <input
        class="w-11/12 grow"
        type="text"
        placeholder="0xeeee.1111.2222.3333.4444.5555.6666.7777.8888.9999"
        v-model="newAddress"
      />
      <input type="text" placeholder="my-new-wallet" v-model="newNick" />
      <button
        @click="handleAddWallet"
        :disabled="!validAddress || pushWalletPending"
      >
        Add Wallet
      </button>
    </div>
  </div>
</template>

<script lang="ts">
import Immutable from 'immutable';
import Wallet from '@/components/Wallet.vue';
import WalletTagEdit from '@/components/WalletTagEdit.vue';
import { CheckOutlined, EditOutlined } from '@ant-design/icons-vue';
import { cloneDeep } from 'lodash-es';
import { pushWallet, pullWallet, pushName } from '@/api/books.ts';
import { computed, defineComponent, reactive, ref, toRaw } from 'vue';
import { mapState, useStore } from 'vuex';
import type { PropType } from 'vue';
import { Address, WalletDetails } from '@/types';

type UIWallet = {
  key: Address,
  address: Address,
  name: string,
  tags: Array<string>,
}

export default defineComponent({
  setup() {
    const store = useStore();

    // Computed
    const myWallets = computed(() => store.state.books.myWallets);

    const count = computed(() => wallets.value.length + 1);

    const wallets = computed(() => {
      return myWallets.value.map((item) => {
        return {
          key: item[0],
          address: item[0],
          name: item[1].nick,
          tags: item[1].tags,
        };
      });
    });

    const textSearch = ref('');
    const filteredWallets = computed(() => {
      if (textSearch.value === '') {
        return wallets.value
      } else {
        return wallets.value.filter((wallet: UIWallet) => {
          return wallet.address.toString().toLowerCase().includes(textSearch.value.toLowerCase())
        }).concat(
          wallets.value.filter((wallet: UIWallet) => {
            return wallet.name.toString().toLowerCase().includes(textSearch.value.toLowerCase())
          })
        ).concat(
          wallets.value.filter((wallet: UIWallet) => {
            return wallet.tags.join(', ').includes(textSearch.value.toLowerCase())
          })
        )
      }
    })

    const allTags = computed(() => {
      return myWallets.value.map((w) => w[1].tags).flat().map((tag) => {
        return {
          text: tag,
          value: tag
        }
      })
    });

    const  walMap = computed(() => {
      return Immutable.Map(myWallets.value)
    })

    // Refs
    const formRef = ref();
    const overallLoading = ref(false);

    //  handlers
    const editableData = reactive({});

    const edit = (key) => {
      editableData[key] = cloneDeep(
        wallets.value.filter((item) => key === item.key)[0]
      );
    };

    const save = (key) => {
      console.log('on-save');
      Object.assign(
        wallets.value.filter((item) => key === item.key)[0],
        editableData[key]
      );
      pushName(key, editableData[key].name)
        .then((r) => {
          console.log('res: ', r);
        })
        .catch((e) => {
          console.log('err: ', e);
        });
      delete editableData[key];
    };

    const cancel = (key) => {
      delete editableData[key];
    };

    const onDelete = (key) => {
      overallLoading.value = true;
      pullWallet(key).finally(() => { overallLoading.value = false; })
    };

    const formState = reactive({
      layout: 'inline',
      nick: '',
      address: '',
      tags: '',
    });
    const rules = {
      nick: [
        {
          required: true,
          message: 'Nickname Required',
          trigger: 'blur',
        },
        {
          min: 2,
          message: 'Nickname Required',
          trigger: 'blur',
        },
      ],
    };
    const onSubmit = () => {
      formRef.value
        .validate()
        .then(() => {
          console.log(formRef.value);
          console.log('values', formState, toRaw(formState));
        })
        .catch((error) => {
          console.log('error', error);
        });
    };

    const columns = computed(() => {
      return [
        {
          title: 'Name',
          dataIndex: 'name',
          width: '20%',
          sorter: (a, b) => a.name.localeCompare(b.name),
          slots: {
            customRender: 'name',
          },
        },
        {
          title: 'Address',
          dataIndex: 'address',
          width: '40%',
        },
        {
          title: 'Tags',
          dataIndex: 'tags',
          width: '25%',
          slots: {
            customRender: 'tags',
          },
          filters: allTags.value,
          onFilter: (soughtTag: string, wallet: UIWallet) => {
            return wallet.tags.includes(soughtTag)
          }
        },
        {
          title: 'Actions',
          dataIndex: 'actions',
          width: '15%',
          slots: {
            customRender: 'actions',
          },
        },
      ];
    });

    return {
      textSearch,
      allTags,
      columns,
      filteredWallets,
      formRef,
      formState,
      rules,
      onSubmit,
      onDelete,
      editableData,
      count,
      edit,
      save,
      wallets,
      overallLoading,
    };
  },

  data() {
    return {
      newAddress: '',
      newNick: '',
      pushWalletPending: false,
    };
  },
  mounted() {
    this.switchNav();
  },
  unmounted() {},
  components: {
    Wallet,
    WalletTagEdit,
    CheckOutlined,
    EditOutlined,
  },
  computed: {
    ...mapState('books', ['myWallets', 'myFriends']),
    namesInUse() {
      const myNames = this.myWallets.map((item) => item[1].nick);
      const urNames = this.myFriends.map((item) => item[1].nick);
      return myNames.concat(urNames);
    },

    validAddress() {
      if (this.newAddress === '') {
        return false;
      }
      if (this.newNick === '') {
        return false;
      }
      if (!/^0x[a-fA-F0-9]{40}$/.test(this.newAddress)) {
        return false;
      }
      return true;
    },
  },
  methods: {
    switchNav() {
      this.$store.dispatch('books/handleSwitchNav', 1);
    },

    handleAddWallet() {
      if (!this.validAddress) {
        return;
      }
      this.pushWalletPending = true; // TODO: deprecated?
      this.overallLoading = true;
      pushWallet(this.newAddress, this.newNick).then((r) => {
        console.log('res: ', r);
        this.pushWalletPending = false;
        this.newAddress = '';
        this.newNick = '';
      })
      .finally(() => { this.overallLoading = false; })
    },
  },
});
</script>
