<template>
  {{ nonReservedWord }}
</template>

<script>
import { defineComponent } from 'vue';

export default defineComponent ({
    mounted() {

    },
    unmounted() {

    },

    computed: {

    },

    methods: {

    },

    props: {
        nonReservedWord: {
            type: String,
            default: null,
        },
    }
})
</script>