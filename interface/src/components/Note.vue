<template>
  <div v-if="!editing">
    <a-descriptions :bordered="ourAnnotations.exist" column="24" class="ml-2">
      <template #title>
        <span v-if="ourAnnotations.exist"> Annotations </span>
        <span v-else> No annotations yet </span>
      </template>
      <template #extra>
        <div class="flex">
          <a-button @click="editing = true" type="primary" class="bg-slate-600">
            <span v-if="ourAnnotations.exist"> Edit </span>
            <span v-else> Add annotation </span>
          </a-button>
        </div>
      </template>

      <a-descriptions-item v-if="ourAnnotations.basis" span="12" label="Basis">
        {{ ourAnnotations.basis }}
      </a-descriptions-item>

      <a-descriptions-item
        v-if="ourAnnotations.counterparties.length > 0"
        span="12"
        label="Counterparty"
      >
        <AddressLookup
          v-for="cp in ourAnnotations.counterparties"
          :key="cp"
          :addy="cp"
        />
      </a-descriptions-item>

      <a-descriptions-item
        v-if="ourAnnotations.note"
        span="12"
        label="Annotation"
      >
        {{ ourAnnotations.note }}
      </a-descriptions-item>

      <a-descriptions-item
        v-if="ourAnnotations.tags.length > 0"
        span="12"
        label="Tags"
      >
        <a-tag v-for="tag in ourAnnotations.tags" :key="tag" color="#475668">
          {{ tag }}
        </a-tag>
      </a-descriptions-item>
    </a-descriptions>
  </div>

  <div v-else>
    <a-form
      ref="formRef"
      :rules="rules"
      :model="formState"
      :label-col="labelCol"
    >
      <a-form-item label="Basis: " name="basis" v-bind="validateInfos.basis">
        <a-input-number
          v-model:value="formState.basis"
          :formatter="
            (value) => `${value}`.replace(/(\d)(?=(\d{3})+\.)/g, '$1,')
          "
        />
      </a-form-item>

      <a-form-item name="to" v-bind="validateInfos.to">
        <template #label>
          <div class="flex flex-row align-middle">
            <div class="mr-2">To</div>
            <div>
              <user-outlined />
            </div>
          </div>
        </template>
        <a-select
          v-model:value="formState.to"
          allowClear
          show-search
          placeholder="Select a Destination/Counterparty"
          style="width: 300px"
          :options="people"
          :filterOption="
            (input, option) => {
              return (
                option.value.toLowerCase().indexOf(input.toLowerCase()) >= 0 ||
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

      <a-form-item
        label="Annotation: "
        name="annotation"
        v-bind="validateInfos.annotation"
      >
        <a-textarea v-model:value="formState.annotation" />
      </a-form-item>
      <a-form-item label="Tags: " name="newTag" v-bind="validateInfos.newTag">
        <div class="mb-2" v-if="formState.tags.length > 0">
          <a-tag
            v-for="tag in formState.tags"
            :key="tag"
            closable
            @close="handleCloseTag(tag)"
            color="#475668"
          >
            {{ tag }}
          </a-tag>
        </div>

        <a-input
          v-model:value="formState.newTag"
          type="text"
          size="small"
          @pressEnter="onSubmit"
          placeholder="abc, one-two, three four"
        />
      </a-form-item>
      <div class="flex">
        <a-button
          type="primary"
          class="bg-slate-600"
          @click.prevent="onSubmit"
          :loading="annotationPending"
          :disabled="annotationPending"
        >
          Save
        </a-button>
        <a-button class="ml-2" @click="editing = false">Cancel</a-button>
      </div>
    </a-form>
  </div>
</template>

<script lang="ts">
import { UserOutlined } from "@ant-design/icons-vue";
import { defineComponent, reactive, computed, ref, toRaw } from "vue";
import { useStore } from "vuex";
import type { PropType } from "vue";
import { pushAnnotation } from "@/api/books";
import { TxHash } from "@/types";
import Immutable from "immutable";
import { Decimal } from "decimal.js";

import { concatOldTagsNewTagString } from "@/api/books";

import AddressLookup from "@/components/AddressLookup.vue";

import { Form } from "ant-design-vue";
const useForm = Form.useForm;

export default defineComponent({
  setup(props) {
    //  boiler
    const store = useStore();

    //  mapState and mapGetters replacements
    const notes = computed(() => store.state.books.notes);
    const myWallets = computed(() => store.state.books.myWallets);
    const myFriends = computed(() => store.state.books.myFriends);

    const annotations = computed(() => {
      return Immutable.Map(notes.value);
    });

    const ourAnnotations = computed(() => {
      let note: string;
      let basis: string;
      let counterparties: Array<string>;
      let tags: Array<[string]>;

      if (Immutable.has(annotations.value, props.hash)) {
        note = Immutable.get(annotations.value, props.hash)
          .annotation as string;
      } else {
        note = "";
      }

      if (Immutable.has(annotations.value, props.hash)) {
        basis = Immutable.get(annotations.value, props.hash)
          .basis.toSignificantDigits(5)
          .toString() as string;
      } else {
        basis = "" as string;
      }

      if (Immutable.has(annotations.value, props.hash)) {
        counterparties = Immutable.get(annotations.value, props.hash)
          .to as Array<string>;
      } else {
        counterparties = [] as Array<string>;
      }
      counterparties = counterparties.filter((c) => c !== null);

      if (Immutable.has(annotations.value, props.hash)) {
        tags = Immutable.get(annotations.value, props.hash).tags as Array<
          [string]
        >;
      } else {
        tags = [] as Array<[string]>;
      }

      const exist = Immutable.has(annotations.value, props.hash) as boolean;

      return {
        exist,
        note,
        basis,
        counterparties,
        tags,
      };
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

    //  Refs
    const annotationPending = ref(false);

    const formRef = ref();
    const editing = ref(false);

    const newTag = ref("");

    console.log("notes", notes.value);
    console.log("props", props.hash);
    console.log("has", Immutable.has(Immutable.Map(notes.value), props.hash));
    console.log("has-alt", Immutable.has(annotations.value, props.hash));

    //  form stuff
    const formState = reactive({
      annotated: (() => {
        return Immutable.has(annotations.value, props.hash) as boolean;
      })(),
      basis: (() => {
        if (Immutable.has(annotations.value, props.hash)) {
          return Immutable.get(annotations.value, props.hash)
            .basis.toSignificantDigits(5)
            .toString() as string;
        } else {
          return "0" as string;
        }
      })(),
      to: (() => {
        if (Immutable.has(annotations.value, props.hash)) {
          return Immutable.get(annotations.value, props.hash)
            .to as Array<string>;
        } else {
          return [] as Array<string>;
        }
      })() as Array<string> | null,
      annotation: (() => {
        if (Immutable.has(annotations.value, props.hash)) {
          return Immutable.get(annotations.value, props.hash)
            .annotation as string;
        } else {
          return "" as string;
        }
      })(),
      tags: (() => {
        if (Immutable.has(annotations.value, props.hash)) {
          return Immutable.get(annotations.value, props.hash).tags as Array<
            [string]
          >;
        } else {
          return [] as Array<[string]>;
        }
      })() as Array<[string]>,
      newTag: (() => {
        return "";
      })(),
    });

    const rules = reactive({
      basis: [
        {
          required: true,
          message: "Leave basis as 0 if unknown",
        },
      ],
      annotation: [
        {
          required: false,
        },
      ],
      to: [
        {
          required: false,
        },
      ],
      newTag: [
        {
          required: false,
          pattern: /^[a-zA-Z0-9\-\s\,]*$/,
          message: "a-z, 0-9, '-' and spaces only, separated by commas",
        },
      ],
    });

    //  methods
    const truncateAddress = (address) => {
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
    };

    const toForUpdate = () => {
      let counterparty: string | null = "";

      if (Array.isArray(formState.to)) {
        counterparty = formState.to[0];
      } else {
        counterparty = formState.to;
      }

      if (counterparty === null || counterparty === undefined) {
        return "";
      } else {
        return counterparty;
      }
    };

    const saveAnnotation = () => {
      annotationPending.value = true;
      const safeTags = concatOldTagsNewTagString(
        formState.tags,
        formState.newTag
      );
      pushAnnotation(props.hash, {
        basis: new Decimal(toRaw(formState.basis)).toSignificantDigits(5),
        to: toForUpdate(),
        annotation: toRaw(formState.annotation),
        tags: safeTags,
      }).finally(() => {
        annotationPending.value = false;
        editing.value = false;
      });
    };

    const handleCloseTag = (killedTag) => {
      // remove from formState.tags
      const newTags = formState.tags.filter((t) => t !== killedTag);
      formState.tags = newTags;
      saveAnnotation();
    };

    const { resetFields, validate, validateInfos } = useForm(formState, rules, {
      onValidate: (...args) => console.log(...args),
    });

    const onSubmit = () => {
      annotationPending.value = true;

      validate()
        .then(() => {
          saveAnnotation();
        })
        .catch((err) => {
          // Validation failed
        })
        .finally(() => {
          annotationPending.value = false;
        });
    };

    return {
      notes,
      myWallets,
      myFriends,
      annotations,
      people,
      formState,
      truncateAddress,
      onSubmit,
      validateInfos,
      resetFields,
      formRef,
      annotationPending,
      rules,
      newTag,
      handleCloseTag,
      ourAnnotations,
      editing,
      labelCol: { span: 4 },
      wrapperCol: { span: 8 },
    };
  },

  methods: {
    handleChange(value) {
      console.log("selected", value);
    },
    handleBlur() {
      console.log("blur on select");
    },
    handleFocus() {
      console.log("focus");
    },
  },

  props: {
    hash: {
      type: String as PropType<TxHash>,
      default: "0x0",
    },
  },

  components: {
    UserOutlined,
    AddressLookup,
  },
});
</script>
