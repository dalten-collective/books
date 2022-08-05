<template>
  <div style="line-height: 2em">
    <a-tag
      v-for="tag in record.tags"
      :key="tag"
      :closable="!!tag"
      @close="handleClose(tag)"
      color="#475668"
    >
      {{ tag }}
    </a-tag>
    <a-form
      ref="formRef"
      :rules="rules"
      :model="formState"
      :label-col="labelCol"
    >
      <div v-if="tagsPending">
        <a-spin />
      </div>
      <div v-else>
        <a-form-item name="newTag" v-bind="validateInfos.newTag">
          <a-input
            placeholder="abc, one-two, three four"
            v-model:value="formState.newTag"
            type="text"
            size="small"
            @pressEnter="handleInput"
          />
        </a-form-item>
      </div>
    </a-form>
  </div>
</template>

<script lang="ts">
import { computed, defineComponent, reactive, ref, PropType } from "vue";
import { pushTags } from "@/api/books";
import { Address } from "@/types";

import { Form } from "ant-design-vue";
import { concatOldTagsNewTagString } from "@/api/books";

//  Types
type UIWallet = {
  key: Address;
  address: Address;
  name: string;
  tags: Array<string>;
};

export default defineComponent({
  props: {
    record: Object as PropType<UIWallet>,
  },

  setup(props) {
    const newTag = ref("");
    const formRef = ref();
    const tagsPending = ref(false);

    const rules = reactive({
      newTag: [
        {
          required: false,
          trigger: "blur",
          pattern: /^[a-zA-Z0-9\-\s\,]*$/,
          message: "a-z, 0-9, '-' and spaces only, separated by commas",
        },
      ],
    });

    const formState = reactive({
      newTag: "",
    });

    const useForm = Form.useForm;
    const { validate, validateInfos } = useForm(formState, rules, {
      onValidate: (...args) => console.log(...args),
    });

    const handleInput = () => {
      tagsPending.value = true;
      validate()
        .then(() => {
          const tNew = concatOldTagsNewTagString(
            props.record.tags,
            formState.newTag
          );
          pushTags(props.record.key, tNew)
            .then(() => {
              formState.newTag = "";
            })
            .catch((e) => {
              console.log("err: ", e);
            });
        })
        .catch((err) => {
          console.log(err);
          // Validation failed
        })
        .finally(() => {
          tagsPending.value = false;
        });
    };

    const handleClose = (tag) => {
      tagsPending.value = true;
      pushTags(
        props.record.key,
        props.record.tags.filter((tOld) => tOld !== tag)
      )
        .then(() => {})
        .catch((e) => {
          console.log("err: ", e);
        })
        .finally(() => {
          tagsPending.value = false;
        });
    };

    return {
      handleInput,
      handleClose,
      newTag,
      rules,
      formRef,
      formState,
      validateInfos,
      tagsPending,
    };
  },
});
</script>
