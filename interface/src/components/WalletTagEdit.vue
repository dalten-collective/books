<template>
  <div>
    <a-tag
      v-for="tag in record.tags"
      :key="tag"
      :closable="!!tag"
      @close="handleClose(tag)"
      color="#475668"
    >
      {{ tag }}
    </a-tag>
    <a-input
      v-model:value="newTag"
      type="text"
      size="small"
      :style="{ width: '78px' }"
      @pressEnter="handleInput"
    />
  </div>
</template>

<script lang="ts">
import Immutable from 'immutable';
import { mapState, useStore } from 'vuex';
import { computed, defineComponent, reactive, ref, toRaw, PropType } from 'vue';
import { pushTags } from '@/api/books.ts';

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
    const handleInput = () => {
      const tNew = props.record.tags.slice().concat(newTag.value.split(' '));
      pushTags(props.record.key, tNew)
        .then((r) => {
          console.log('res: ', r);
          newTag.value = '';
        })
        .catch((e) => {
          console.log('err: ', e);
        });
    };
    const handleClose = (tag) => {
      pushTags(
        props.record.key,
        props.record.tags.filter((tOld) => tOld !== tag)
      )
        .then((r) => {
          console.log('res: ', r);
        })
        .catch((e) => {
          console.log('err: ', e);
        });
    };
    return {
      handleInput,
      handleClose,
      newTag,
    };
  },
});
</script>
