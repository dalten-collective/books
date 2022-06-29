<template>
  <div>
    <a-tag v-for="tag in record.tags" :key="tag" :closable="!!tag" @close="handleClose(tag)">{{tag}}</a-tag>
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

type UIWallet = {
  key: Address,
  address: Address,
  name: string,
  tags: Array<string>,
}

export default defineComponent({
  props: {
    record: Object as PropType<UIWallet>
  },
  setup(props) {
    const store = useStore();

    const myWallets = computed(() => store.state.books.myWallets);
    const walMap = computed(() => {
      return Immutable.Map(myWallets.value)
    })

    const newTag = ref('');

    const handleInput = () => {
      const tOld = walMap.value.get(props.record.key).tags.slice();
      tOld.push(newTag.value);
      pushTags(props.record.key, tOld)
        .then((r) => {
          console.log('res: ', r);
          newTag.value = ''
        })
        .catch((e) => {
          console.log('err: ', e);
        });
    };

    const handleClose = (tag) => {
      const tNew = walMap.value.get(props.record.key).tags.filter(tOld => tOld !== tag)
      pushTags(props.record.key, tNew)
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
      newTag
    }
  },
})
</script>
