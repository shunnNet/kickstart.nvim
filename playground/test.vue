<script setup lang="ts">

const a = 123

const message = ref('')
</script>

<template>
    <input v-model="message" @click="">123 {{ a }}
</template>
