<template>
  <div>
    <a-table
      bordered
      :columns="columns"
      :data-source="wallets"
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
          <a class="hover:text-yellow-500">Delete</a>
        </a-popconfirm>
      </template>
    </a-table>

    <a-form
      ref="formRef"
      :rules="rules"
      layout="horizontal"
      :model="formState"
      :label-col="{ span: 8 }"
      :wrapper-col="{ span: 16 }"
    >
      <a-row>
        <a-col :span="8">
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
        <a-col :span="8">
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
        <a-col :span="8">
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
            @click.prevent="onSubmit"
            :loading="awaitingNewWallet"
            :disabled="awaitingNewWallet"
          >
            Add Tracked Wallet
          </a-button>
        </a-col>
      </a-row>
    </a-form>
  </div>
</template>

<script lang="ts">
import Immutable from "immutable";
import WalletTagEdit from "@/components/WalletTagEdit.vue";
import { CheckOutlined, EditOutlined } from "@ant-design/icons-vue";
import { cloneDeep } from "lodash-es";
import { pushWallet, pullWallet, pushName } from "@/api/books";
import { computed, defineComponent, reactive, ref, toRaw } from "vue";
import { useStore } from "vuex";
import { WalletDetails } from "@/types";
import { Form } from "ant-design-vue";
import { arrayAndHepTags } from "@/api/books";

export default defineComponent({
  setup() {
    //  boiler
    const store = useStore();

    //  mounted-actions
    store.dispatch("books/handleSwitchNav", 1);

    //  mapState and mapGetters replacements
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);

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

    const walMap = computed(() => {
      return Immutable.Map(myWallets.value);
    });

    const allTags = computed(() => {
      return Array.from(
        new Set(myWallets.value.map((w) => w[1].tags).flat())
      ).map((tag) => {
        return {
          text: tag,
          value: tag,
        };
      });
    });

    const columns = computed(() => {
      return [
        {
          title: "Name",
          dataIndex: "name",
          width: "20%",
          sorter: (a, b) => a.name.localeCompare(b.name),
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
          title: "Tags",
          dataIndex: "tags",
          width: "25%",
          slots: {
            customRender: "tags",
          },
          filters: allTags.value,
          onFilter: (soughtTag: string, wallet: WalletDetails) => {
            return wallet.tags.includes(soughtTag);
          },
        },
        {
          dataIndex: "actions",
          width: "15%",
          slots: {
            customRender: "actions",
          },
        },
      ];
    });

    // Refs
    const overallLoading = ref(false);
    const formRef = ref();
    const awaitingNewWallet = ref(false);

    //  handlers
    const handleInput = (k, t) => {
      const tOld = walMap.value.get(k).tags.slice();
      tOld.push(t.target.value);
      console.log("handlerInput", k, tOld);
      pushTags(k, tOld)
        .then((r) => {
          console.log("res: ", r);
        })
        .catch((e) => {
          console.log("err: ", e);
        });
    };

    const handleClose = (k, t) => {
      pushTags(
        k,
        walMap.value.get(k).tags.filter((tOld) => tOld !== t)
      )
        .then((r) => {
          console.log("res: ", r);
        })
        .catch((e) => {
          console.log("err: ", e);
        });
    };

    const editableData = reactive({});

    const edit = (key) => {
      editableData[key] = cloneDeep(
        wallets.value.filter((item) => key === item.key)[0]
      );
    };

    const save = (key) => {
      console.log("on-save");
      Object.assign(
        wallets.value.filter((item) => key === item.key)[0],
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

    const cancel = (key) => {
      delete editableData[key];
    };

    const onDelete = (key) => {
      overallLoading.value = true;
      pullWallet(key).finally(() => {
        overallLoading.value = false;
      });
    };
    const formState = reactive({
      layout: "inline",
      nick: "",
      address: "",
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
      tags: [
        {
          required: false,
          pattern: /^[a-zA-Z0-9\-\s\,]*$/,
          message: "a-z, 0-9, '-' and spaces only, separated by commas",
        },
      ],
    };

    const useForm = Form.useForm;
    const { resetFields, validate, validateInfos } = useForm(formState, rules, {
      onValidate: (...args) => console.log(...args),
    });

    //  methods
    const onSubmit = () => {
      validate()
        .then(() => {
          console.log("values", formState, toRaw(formState));
          awaitingNewWallet.value = true;
          overallLoading.value = true;
          const safeTags = arrayAndHepTags(toRaw(formState).tags);
          pushWallet(toRaw(formState).address, toRaw(formState).nick, safeTags)
            .then((r) => {
              console.log("res: ", r);
            })
            .catch((e) => {
              console.log("err: ", e);
            })
            .finally(() => {
              overallLoading.value = false;
              awaitingNewWallet.value = false;
              resetFields();
            });
        })
        .catch((error) => {
          // validation failed
          console.log("error", error);
        });
    };

    return {
      myWallets,
      myFriends,
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
      allTags,
      columns,
      overallLoading,
      awaitingNewWallet,
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
