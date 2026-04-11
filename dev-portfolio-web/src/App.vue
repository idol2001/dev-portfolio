<template>
  <div class="flex flex-col min-h-screen">
    <main class="flex-1">
      <router-view />
    </main>
    <AppFooter />
  </div>
</template>

<script setup>
import { ref, provide, onMounted } from 'vue'
import AppFooter from './components/AppFooter.vue'

const isDark = ref(true)

const toggleTheme = () => {
  isDark.value = !isDark.value
  document.documentElement.classList.toggle('dark', isDark.value)
  localStorage.setItem('theme', isDark.value ? 'dark' : 'light')
}

provide('theme', { isDark, toggleTheme })

onMounted(() => {
  const saved = localStorage.getItem('theme')
  if (saved === 'light') {
    isDark.value = false
    document.documentElement.classList.remove('dark')
  } else {
    document.documentElement.classList.add('dark')
  }
})
</script>
