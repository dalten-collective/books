<template>
  <a-form ref="formRef" :rules="rules" :model="formState" :label-col="labelCol">
    <a-form-item label="Annotated: ">
      <a-switch
        v-model:checked="formState.annotated"
        :style="[formState.annotated ? 'background-color: #EAB304' : '']"
      />
    </a-form-item>

    <a-form-item
      label="Basis: "
      :style="[formState.annotated ? '' : 'display: none']"
    >
      <a-input-number
        v-model:value="formState.basis"
        :formatter="(value) => `${value}`.replace(/(\d)(?=(\d{3})+\.)/g, '$1,')"
      />
    </a-form-item>

    <a-form-item
      :style="[formState.annotated ? '' : 'display: none']"
      name="to"
      v-bind="validateInfos.to"
    >
      <template #label>
        <div class="flex flex-row align-middle">
          <div class="mr-2">
            To
          </div>
          <div>
            <user-outlined />
          </div>
        </div>
      </template>
      <a-select
        v-model:value="formState.to"
        show-search
        placeholder="Select a Destination/Counterparty"
        style="width: 300px"
        :options="people"
        :filterOption="
          (input, option) => {
            return (
              option.value.toLowerCase().indexOf(input.toLowerCase()) >=
                0 ||
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
      :style="[formState.annotated ? '' : 'display: none']"
    >
      <a-textarea v-model:value="formState.annotation" />
    </a-form-item>
    <a-form-item
      label="Tags: "
      :style="[formState.annotated ? '' : 'display: none']"
      name="newTag"
      v-bind="validateInfos.newTag"
    >
      <template v-for="tag in formState.tags" :key="tag">
        <a-tag
          closable
          @close="handleCloseTag(tag)"
          color="#475668"
        >
          {{ tag }}
        </a-tag>
      </template>
      <a-input v-model:value="formState.newTag" type="text" size="small" :style="{ width: '78px' }" @pressEnter="onSubmit" />
    </a-form-item>
    <a-button
      type="primary"
      class="bg-slate-600"
      @click.prevent="onSubmit"
      :style="[formState.annotated ? '' : 'display: none']"
      :loading="annotationPending"
      :disabled="annotationPending"

    >
      Save
    </a-button>
  </a-form>
</template>

<script lang="ts">
import { UserOutlined } from '@ant-design/icons-vue';
import { defineComponent, reactive, computed, ref, toRaw } from 'vue';
import { useStore } from 'vuex';
import type { PropType } from 'vue';
import { pushAnnotation } from '@/api/books.ts';
import { TxHash } from '@/types';
import Immutable, { OrderedMap, Map } from 'immutable';
import { Decimal } from 'decimal.js';

import { Form } from 'ant-design-vue';
const useForm = Form.useForm

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

    const hoonedNewTags = computed(() => {
      if (formState.newTag === '') {
        return []
      } else {
        return formState.newTag.split(" ")
      }
    })

    const noChanges = computed(() => {
      // TODO: remove function
      return
      // // if no annotations
      // if (Immutable.get(annotations.value, props.hash) === undefined) {
      //   return false
      // }

      // const prevBasis = parseInt(
      //   Immutable.get(annotations.value, props.hash)
      //     .basis.toSignificantDigits(5)
      // )
      // const newBasis = parseInt(formState.basis)

      // const prevCounterparties = Immutable.get(annotations.value, props.hash).to
      // const newCounterparties = formState.to
      // const counterpartiesUnchanged = newCounterparties === prevCounterparties

      // const prevAnnotation = Immutable.get(annotations.value, props.hash).annotation
      // const newAnnotation = formState.annotation

      // const basisUnchanged = newBasis === prevBasis
      // const annotationUnchanged = newAnnotation === prevAnnotation

      // return basisUnchanged && counterpartiesUnchanged && annotationUnchanged
    })

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

    const newTag = ref('');
    const thing = ref('hello');

    console.log('notes', notes.value);
    console.log('props', props.hash);
    console.log('has', Immutable.has(Immutable.Map(notes.value), props.hash));
    console.log('has-alt', Immutable.has(annotations.value, props.hash));

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
          return '0' as string;
        }
      })(),
      to: (() => {
        if (Immutable.has(annotations.value, props.hash)) {
          return Immutable.get(annotations.value, props.hash).to as Array<string>;
        } else {
          return [] as Array<string>;
        }
      })() as Array<string> | null,
      annotation: (() => {
        if (Immutable.has(annotations.value, props.hash)) {
          return Immutable.get(annotations.value, props.hash)
            .annotation as string;
        } else {
          return '' as string;
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
        return ''
      })(),
    });

    const rules = reactive({
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
          pattern: /^[a-zA-Z0-9\-\_\s]*$/,
          message: "a-z, 0-9, '-' and '_' only, separated by spaces",
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
      if (Array.isArray(formState.to)) {
        return formState.to[0]
      } else {
        return formState.to
      }
    }

    const handleCloseTag = (killedTag) => {
      // remove from formState.tags
      const newTags = formState.tags.filter(t => t !== killedTag)
      formState.tags = newTags
      annotationPending.value = true;
      pushAnnotation(props.hash, {
        basis: new Decimal(toRaw(formState.basis)).toSignificantDigits(5),
        to: toForUpdate(),
        annotation: toRaw(formState.annotation),
        tags: tagsForUpdate(),
      }).finally((r) => {
        annotationPending.value = false;
      });
    }

    const tagsForUpdate = () => {
      // not making changes - keep whatever tags already exist
      if (hoonedNewTags.value.length === 0) {
        return formState.tags
      } else {
        // otherwise, concat in our new tags to existing.
        return formState.tags.concat(hoonedNewTags.value).flat()
      }
    }

    const { resetFields, validate, validateInfos } = useForm(formState, rules, {
      onValidate: (...args) => console.log(...args),
    });

    const onSubmit = () => {
      annotationPending.value = true;

      validate().then(() => {
        pushAnnotation(props.hash, {
          basis: new Decimal(toRaw(formState.basis)).toSignificantDigits(5),
          to: toForUpdate(),
          annotation: toRaw(formState.annotation),
          tags: tagsForUpdate(),
        }).finally((r) => {
          annotationPending.value = false;
        });
      }).catch(err => {
        // Validation failed
        console.log('validate error ', err);
      }).finally(() => {
        annotationPending.value = false;
      })

      //formRef.value
      //  .validate()
      //  .then(() => {
      //    console.log('values', formState, toRaw(formState));
      //  })
      //  .catch((error) => {
      //    console.log('error', error);
      //  });
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
      formState,
      formRef,
      annotationPending,
      rules,
      newTag,
      handleCloseTag,
      hoonedNewTags,
      noChanges,
      labelCol: { span: 4 },
      wrapperCol: { span: 8 },
    };
  },

  methods: {
    hasNote(hash) {
      return Immutable.has(annotations, hash) as boolean;
    },
    getBasis(hash) {
      if (Immutable.has(annotations, hash)) {
        return Immutable.get(annotations, hash).basis as Decimal;
      } else {
        return 0x0 as Decimal;
      }
    },
    getTo(hash) {
      if (Immutable.has(annotation, hash)) {
        return Immutable.get(annotations, hash).to as Address | null;
      } else {
        return null as Address | null;
      }
    },

    handleChange(value) {
      console.log('selected', value);
    },
    handleBlur() {
      console.log('blur on select');
    },
    handleFocus() {
      console.log('focus');
    },
  },

  props: {
    hash: {
      type: String as PropType<TxHash>,
      default: '0x0',
    },
  },

  components: {
    UserOutlined,
  },
});
</script>
