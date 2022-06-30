<template>
  <a-table
    bordered
    :columns="columns"
    :data-source="wallets"
    :scroll="{ x: 750 }"
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
    <template #operation="{ record }">
      <a-popconfirm
        v-if="wallets.length"
        title="Sure to delete?"
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
    <a-form-item label="Address: " ref="address" name="address">
      <a-input
        v-model:value="formState.address"
        placeholder="0xeeee.1111.2222.3333.4444.5555.6666.7777.8888.9999"
      />
    </a-form-item>
    <a-form-item label="Tags: " ref="tags" name="tags">
      <a-input v-model:value="formState.tags" placeholder="abc one-two three" />
    </a-form-item>
    <a-button type="primary" class="bg-slate-600" @click="onSubmit">
      Add Tracked Wallet
    </a-button>
  </a-form>

</template>

<script lang="ts">
import Immutable from 'immutable';
import WalletTagEdit from '@/components/WalletTagEdit.vue';
import { CheckOutlined, EditOutlined } from '@ant-design/icons-vue';
import { cloneDeep } from 'lodash-es';
import { pushWallet, pushTags, pushName } from '@/api/books.ts';
import { computed, defineComponent, reactive, ref, toRaw } from 'vue';
import { mapState, useStore } from 'vuex';
import type { PropType } from 'vue';
import { Address } from '@/types';

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mounted-actions
    store.dispatch('books/handleSwitchNav', 1);

    //  mapState and mapGetters replacements
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);
    const namesInUse = computed(() => {
      const myNames = this.myWallets.map((item) => item[1].nick);
      const urNames = this.myFriends.map((item) => item[1].nick);
      return myNames.concat(urNames);
    });

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

    const  walMap = computed(() => {
      return Immutable.Map(myWallets.value)
    })

    // Refs
    const formRef = ref();
    const inputRef = ref();

    //  handlers
    const handleInput = ((k, t) => {
      const tOld = walMap.value.get(k).tags.slice();
      tOld.push(t.target.value);
      console.log("handlerInput", k, tOld);
      pushTags(k, tOld)
        .then((r) => {
          console.log('res: ', r);
        })
        .catch((e) => {
          console.log('err: ', e);
        });
      
    });

    const handleClose = ((k, t) => {
      pushTags(k, walMap.value.get(k).tags.filter(tOld => tOld !== t))
        .then((r) => {
          console.log('res: ', r);
        })
        .catch((e) => {
          console.log('err: ', e);
        });
    });

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
      wallets.value = wallets.value.filter((item) => item.key !== key);
    };
    const columns = [
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
        width: '30%',
      },
      {
        title: 'Tags',
        dataIndex: 'tags',
        width: '25%',
        slots: {
          customRender: 'tags',
        },
      },
      {
        title: 'Delete',
        dataIndex: 'Delete',
        width: '15%',
      },
    ];
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
      address: [
        {
          required: true,
          message: 'Address Required',
          trigger: 'blur',
        },
        {
          min: 42,
          max: 42,
          pattern: /^0x[a-fA-F0-9]{40}$/,
          message: 'Provide Wallet Address',
          trigger: 'blur',
        }
      ],
      tags: [
        {
          required: false,
          pattern: /^[a-zA-Z0-9\-\_\s]+$/,
          trigger: 'blur',
          message: "a-z, 0-9, '-' and '_' only, separated by spaces"
        }
      ]
    };

    //  methods
    const validAddress = () => {
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
    };

    const handleAddWallet = () => {
      if (!this.validAddress) {
        return;
      }
      this.pushWalletPending = true;
      pushWallet(this.newAddress, this.newNick).then((r) => {
        console.log('res: ', r);
        this.pushWalletPending = false;
        this.newAddress = '';
        this.newNick = '';
      });
    };

    const onSubmit = () => {
      formRef.value
        .validate()
        .then(() => {
          console.log(formRef.value);
          console.log('values', formState, toRaw(formState));
          pushWallet(toRaw(formState).address, toRaw(formState).nick, toRaw(formState).tags)
            .then((r) => {
              console.log('res: ', r);
            })
            .catch((e) => {
              console.log('err: ', e);
            });
        })
        .catch((error) => {
          console.log('error', error);
        });
    };

    return {
      myWallets,
      myFriends,
      columns,
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
      handleClose,
      handleInput,
      namesInUse,
      validAddress,
      handleAddWallet
    };
  },

  data() {
    return {
      newAddress: '',
      newNick: '',
      pushWalletPending: false,
    };
  },

  components: {
    CheckOutlined,
    EditOutlined,
    WalletTagEdit,
  },

});
</script>
