<template>
  <div>
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
            {{ text || " " }}
            <edit-outlined
              class="editable-cell-icon"
              @click="edit(record.key)"
            />
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
      :model="formState"
      layout="horizontal"
      :label-col="{ span: 8 }"
      :wrapper-col="{ span: 16 }"
    >
      <a-row>
        <a-col :span="12">
          <a-form-item
            label="Nickname: "
            ref="nick"
            name="nick"
            v-bind="validateInfos.nick"
          >
            <a-input
              v-model:value="formState.nick"
              placeholder="UnBankedKing"
            />
          </a-form-item>
        </a-col>
        <a-col :span="12">
          <a-form-item
            label="Address: "
            ref="address"
            name="address"
            v-bind="validateInfos.address"
          >
            <a-input
              v-model:value="formState.address"
              placeholder="0xeeee111122223333444455556666777788889999"
            />
          </a-form-item>
        </a-col>
      </a-row>

      <a-row>
        <a-col :span="12">
          <a-form-item label="Who (@p - optional): " ref="who" name="who">
            <a-input
              v-model:value="formState.who"
              placeholder="~dalten-dalten"
            />
          </a-form-item>
        </a-col>
        <a-col :span="12">
          <a-form-item
            label="Tags: "
            ref="tags"
            name="tags"
            v-bind="validateInfos.tags"
          >
            <a-input
              v-model:value="formState.tags"
              placeholder="abc, one-two, three four"
            />
          </a-form-item>
        </a-col>
      </a-row>

      <a-row>
        <a-col :span="24" style="text-align: right">
          <a-button
            type="primary"
            class="bg-slate-600"
            @click="onSubmit"
            :loading="awaitingNewFriend"
            :disabled="awaitingNewFriend"
          >
            Add Friend (Untracked)
          </a-button>
        </a-col>
      </a-row>
    </a-form>
  </div>
</template>

<script lang="ts">
import Immutable from "immutable";
import WalletTagEdit from "@/components/WalletTagEdit.vue";
import { computed, defineComponent, reactive, ref, toRaw } from "vue";
import { mapState, useStore } from "vuex";
import { pushFriend, pullFriend, pushName } from "@/api/books";
import { CheckOutlined, EditOutlined } from "@ant-design/icons-vue";
import { cloneDeep } from "lodash-es";
import { Form } from "ant-design-vue";
import { arrayAndHepTags } from "@/api/books";

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mounted-actions
    store.dispatch("books/handleSwitchNav", 3);

    //  mapState and mapGetters replacements
    const myFriends = computed(() => store.state.books.myFriends);
    const friends = computed(() => {
      return myFriends.value.map((item) => {
        return {
          key: item[0],
          name: item[1].nick,
          address: item[0],
          tags: item[1].tags,
          patP: [!item[1].who ? "" : item[1].who],
        };
      });
    });

    // Refs
    const overallLoading = ref(false);
    const formRef = ref();
    const awaitingNewFriend = ref(false);

    const editableData = reactive({});

    //  table columns, data
    const columns = [
      {
        title: "Name",
        dataIndex: "name",
        width: "20%",
        sorter: (a, b) => a.name.localCompare(b.name),
        slots: {
          customRender: "name",
        },
      },
      {
        title: "Address",
        dataIndex: "address",
        width: "30%",
      },
      {
        title: "Urbit ID (@p)",
        dataIndex: "patP",
        width: "15%",
      },
      {
        title: "Tags",
        dataIndex: "tags",
        width: "25%",
        slots: {
          customRender: "tags",
        },
      },
      {
        dataIndex: "actions",
        width: "10%",
        slots: {
          customRender: "actions",
        },
      },
    ];

    //  form
    const formState = reactive({
      layout: "inline",
      nick: "",
      address: "",
      who: "",
      tags: "",
    });
    const rules = {
      nick: [
        {
          required: true,
          message: "Nickname required",
        },
        {
          min: 2,
          message: "Nickname must be longer",
        },
      ],
      address: [
        {
          required: true,
          message: "Address required",
        },
        {
          min: 42,
          max: 42,
          pattern: /^0x[a-fA-F0-9]{40}$/,
          message: "Provide valid wallet address",
        },
      ],
      who: [
        {
          required: false,
          pattern: /^~[a-z\-]+$/,
          message: "Are you sure that's a @p?",
        },
      ],
      tags: [
        {
          required: false,
          pattern: /^[a-zA-Z0-9\-\s\,]*$/,
          message: "a-z, 0-9, '-' and spaces only, separated by commas",
        },
      ],
    };

    //  methods

    const save = (key) => {
      console.log("on-save");
      Object.assign(
        friends.value.filter((item) => key === item.key)[0],
        editableData[key]
      );
      pushName(key, editableData[key].name)
        .then((r) => {
          console.log("res: ", r);
        })
        .catch((e) => {
          console.log("err: ", e);
        });
      delete editableData[key];
    };

    const edit = (key) => {
      editableData[key] = cloneDeep(
        friends.value.filter((item) => key === item.key)[0]
      );
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

    const useForm = Form.useForm;
    const { resetFields, validate, validateInfos } = useForm(formState, rules, {
      onValidate: (...args) => console.log(...args),
    });

    const onSubmit = () => {
      validate()
        .then(() => {
          console.log("values", formState, toRaw(formState));
          overallLoading.value = true;
          awaitingNewFriend.value = true;
          const safeTags = arrayAndHepTags(toRaw(formState).tags);
          pushFriend(
            toRaw(formState).address,
            toRaw(formState).nick,
            toRaw(formState).who,
            safeTags
          )
            .then((r) => {
              console.log("res: ", r);
            })
            .catch((e) => {
              console.log("err: ", e);
            })
            .finally(() => {
              overallLoading.value = false;
              awaitingNewFriend.value = false;
              resetFields();
            });
        })
        .catch((error) => {
          // validation failed
          console.log("error", error);
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
      cancel,
      awaitingNewFriend,
      validateInfos,
    };
  },
  components: {
    CheckOutlined,
    EditOutlined,
    WalletTagEdit,
  },
});
</script>
