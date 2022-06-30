<template>
  <a-table
    bordered
    :columns="columns"
    :data-source="friends"
    :scroll="{ x: 750 }"
    :loading="overallLoading"
  >
    <template #tags="{ record }">
      <template v-for="tag in record.tags">
        <a-tag :closable="!!tag" @close="handleClose(record.key, tag)">{{
          tag
        }}</a-tag>
      </template>
      <a-input
        ref="inputRef"
        type="text"
        size="small"
        :style="{ width: '78px' }"
        @keyup.enter="handleInput(record.key, $event)"
      />
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
    <a-form-item label="Address: " ref="address" name="address">
      <a-input
        v-model:value="formState.address"
        placeholder="0xeeee111122223333444455556666777788889999"
      />
    </a-form-item>
    <a-form-item label="Who (@p - optional): " ref="who" name="who">
      <a-input v-model:value="formState.who" placeholder="~dalten-dalten" />
    </a-form-item>
    <a-form-item label="Tags: " ref="tags" name="tags">
      <a-input v-model:value="formState.tags" placeholder="abc one-two three" />
    </a-form-item>
    <a-button type="primary" class="bg-slate-600" @click="onSubmit">
      Add Friend (Untracked)
    </a-button>
  </a-form>
</template>

<script lang="ts">
import { computed, defineComponent, reactive, ref, toRaw } from 'vue';
import { mapState, useStore } from 'vuex';
import { pushFriend, pullFriend } from '@/api/books.ts';
import Immutable from 'immutable';
import { Address } from '@/types';

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mounted-actions
    store.dispatch('books/handleSwitchNav', 3);

    // Refs
    const overallLoading = ref(false);
    const formRef = ref();
    const inputRef = ref();

    //  table columns, data
    const columns = [
      {
        title: 'Name',
        dataIndex: 'name',
        width: '20%',
        sorter: (a, b) => a.name.localCompare(b.name),
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
        title: 'Urbit ID (@p)',
        dataIndex: 'patP',
        width: '15%',
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
        dataIndex: 'actions',
        width: '10%',
        slots: {
          customRender: 'actions',
        }
      },
    ];
    const myFriends = computed(() => store.state.books.myFriends);
    const friends = computed(() => {
      return myFriends.value.map((item) => {
        return {
          key: item[0],
          name: item[1].nick,
          address: item[0],
          tags: item[1].tags,
          patP: [!item[1].who ? '' : item[1].who],
        };
      });
    });

    //  form
    const formState = reactive({
      layout: 'inline',
      nick: '',
      address: '',
      who: '',
      tags: '',
    });
    const rules = {
      nick: [
        {
          required: true,
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
        },
      ],
      who: [
        {
          required: false,
          pattern: /^~[a-z\-]+$/,
          message: "Are you sure that's a @p?",
          trigger: 'blur',
        },
      ],
      tags: [
        {
          required: false,
          pattern: /^[a-zA-Z0-9\-\_\s]+$/,
          trigger: 'blur',
          message: "a-z, 0-9, '-' and '_' only, separated by spaces",
        },
      ],
    };

    //  methods
    const onDelete = (key) => {
      overallLoading.value = true;
      pullFriend(key).finally(() => {
        overallLoading.value = false;
      });
    };

    const onSubmit = () => {
      overallLoading = true;
      formRef.value
        .validate()
        .then(() => {
          console.log(formRef.value);
          console.log('values', formState, toRaw(formState));
          pushFriend(
            toRaw(formState).address,
            toRaw(formState).nick,
            toRaw(formState).who,
            toRaw(formState).tags
          )
            .then((r) => {
              console.log('res: ', r);
            })
            .catch((e) => {
              console.log('err: ', e);
            })
            .finally(() => {
              overallLoading = false;
              formRef.value.resetFields();
            });
        })
        .catch((error) => {
          console.log('error', error);
        });
    };

    return {
      columns,
      friends,
      formRef,
      formState,
      rules,
      onSubmit,
      onDelete,
      overallLoading
    };
  },
});
</script>
