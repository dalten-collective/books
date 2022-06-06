<template>
  <pre>ADDDREESSSSSSSSS {{ nonReservedWord }}</pre>
</template>

<script lang="ts">
import { defineComponent } from 'vue';
import type { PropType } from 'vue';
import { Address } from "@/types";

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
            type: String as PropType<Address>,
            default: "0x0 (or THERE IS NO ADDRESS HERE)",
        },
    }
})
</script>
