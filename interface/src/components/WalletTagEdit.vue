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
    <a-form ref="formRef" :rules="rules" :model="formState" :label-col="labelCol">
      <div v-if="tagsPending">
        <a-spin />
      </div>
      <div v-else>
        <a-form-item
          name="newTag"
          v-bind="validateInfos.newTag"
        >
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
import Immutable from 'immutable';
import { mapState, useStore } from 'vuex';
import { computed, defineComponent, reactive, ref, toRaw, PropType } from 'vue';
import { pushTags } from '@/api/books.ts';

import { Form } from 'ant-design-vue';

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
    const newTag = ref('');
    const formRef = ref();
    const tagsPending = ref(false);

    const rules = reactive({
      newTag: [
        {
          required: false,
          trigger: 'blur',
          pattern: /^[a-zA-Z0-9\-\_\s\,]*$/,
          message: "a-z, 0-9, '-', ' ' and '_' only, separated by commas",
        },
      ],
    });

    const formState = reactive({
      newTag: ''
    });

    const useForm = Form.useForm
    const { resetFields, validate, validateInfos } = useForm(formState, rules, {
      onValidate: (...args) => console.log(...args),
    });

    const handleInput = () => {
      tagsPending.value = true;
      validate().then(() => {
        // TODO: handle concatting with arrayAndHep helper
        const regex = /\s+/g;
        const tNew = props.record.tags.slice().concat(
          formState.newTag
            .split(',')
            .slice()
            .map((nt) => nt.trim().replace(regex, '-').toLowerCase())
        );
        pushTags(props.record.key, tNew)
          .then((r) => {
            formState.newTag = '';
          })
          .catch((e) => {
            console.log('err: ', e);
          });
      }).catch(err => {
        // Validation failed
      }).finally(() => {
        tagsPending.value = false;
      })
    };

    const handleClose = (tag) => {
      tagsPending.value = true;
      pushTags(
        props.record.key,
        props.record.tags.filter((tOld) => tOld !== tag)
      )
        .then((r) => {
          console.log('res: ', r);
        })
        .catch((e) => {
          console.log('err: ', e);
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
