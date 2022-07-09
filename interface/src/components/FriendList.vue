<template>
  <a-table
    bordered
    :columns="columns"
    :data-source="friends"
    :scroll="{ x: 750 }"
    :loading="overallLoading"
  >
    <template #name="{ text, record }">
      <div class="editable-cell">
        <div
          v-if="editableData[record.key]"
          class="editable-cell-input-wrapper"
        >
          "hi"
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
          "low"
          {{ text || ' ' }}
          <edit-outlined class="editable-cell-icon" @click="edit(record.key)" />
        </div>
      </div>
    </template>
    <template #tags="{ record }">
      <template v-for="tag in record.tags">
        <a-tag :closable="!!tag" @close="handleClose(record.key, tag)">
          {{ tag }}
        </a-tag>
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
import { CheckOutlined, EditOutlined } from '@ant-design/icons-vue';
import { cloneDeep } from 'lodash-es';
import { Address } from '@/types';

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mounted-actions
    store.dispatch('books/handleSwitchNav', 3);

    //  mapState and mapGetters replacements
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
    const frenMap = computed(() => {
      return Immutable.Map(myFriends.value);
    });


    // Refs
    const overallLoading = ref(false);
    const formRef = ref();
    const inputRef = ref();

    const editableData = reactive({});

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
        },
      },
    ];

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

    const save = (key) => {
      console.log('on-save');
      Object.assign(
        friends.value.filter((item) => key === item.key)[0],
        editableData[key]
      );

      delete editableData[key];
    };

    const edit = (key) => {
      editableData[key] = cloneDeep(
        friends.data.filter((item) => key === item.key)[0]
      )
    };

    const cancel = (key) => {
      delete editableData[key];
    };


    const onDelete = (key) => {
      overallLoading.value = true;
      pullFriend(key).finally(() => {
        overallLoading.value = false;
      });
    };

    const onSubmit = () => {
      overallLoading.value = true;
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
              overallLoading.value = false;
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
      overallLoading,
      editableData,
      save,
      edit,
      cancel
    };
  },
});
</script>
