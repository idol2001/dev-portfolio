<template>
  <nav class="fixed top-0 w-full bg-gray-900/80 dark:bg-gray-900/80 backdrop-blur-sm z-50" :class="isDark ? 'bg-gray-900/80' : 'bg-white/80'">
    <div class="max-w-6xl mx-auto px-4 py-4 flex justify-between items-center">
      <router-link to="/" class="text-xl font-bold" :class="isDark ? 'text-white' : 'text-gray-900'">{{ siteName }}</router-link>

      <!-- Right side group -->
      <div class="flex items-center gap-4">
        <!-- Desktop nav -->
        <div class="hidden md:flex space-x-6" :class="isDark ? 'text-gray-300' : 'text-gray-600'">
          <template v-for="item in navItems" :key="item.id">
            <router-link :to="item.href" class="hover:text-blue-400 transition">{{ item.title }}</router-link>
          </template>
        </div>

        <!-- Theme toggle -->
        <button @click="toggleTheme" class="p-1.5 rounded-lg transition"
                :class="isDark ? 'text-yellow-400 hover:bg-gray-700/50' : 'text-gray-600 hover:bg-gray-200/50'"
                :title="isDark ? 'Switch to light mode' : 'Switch to dark mode'">
          <svg v-if="!isDark" class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z"/>
          </svg>
          <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z"/>
          </svg>
        </button>

        <!-- Mobile hamburger -->
        <button @click="menuOpen = !menuOpen" class="md:hidden p-1 transition"
                :class="isDark ? 'text-gray-300 hover:text-white' : 'text-gray-600 hover:text-gray-900'"
                aria-label="Menu">
          <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
            <path v-if="!menuOpen" stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"/>
            <path v-else stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/>
          </svg>
        </button>
      </div>
    </div>

    <!-- Mobile menu dropdown -->
    <transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0 -translate-y-2"
      enter-to-class="opacity-100 translate-y-0"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100 translate-y-0"
      leave-to-class="opacity-0 -translate-y-2"
    >
      <div v-if="menuOpen" class="md:hidden border-t border-gray-700/50" :class="isDark ? 'bg-gray-900/95' : 'bg-white/95'">
        <div class="px-4 py-3 space-y-1">
          <template v-for="item in navItems" :key="item.id">
            <router-link
              :to="item.href"
              class="block px-3 py-2 rounded-md text-base transition"
              :class="isDark ? 'hover:bg-gray-700/50 hover:text-blue-400' : 'hover:bg-gray-100 hover:text-blue-600'"
              @click="menuOpen = false"
            >
              {{ item.title }}
            </router-link>
          </template>
        </div>
      </div>
    </transition>
  </nav>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import { getNavBars, getProfile } from '../api'

const theme = inject('theme', { isDark: ref(true), toggleTheme: () => {} })
const { isDark, toggleTheme } = theme

const siteName = ref('Jacob Lee')
const navItems = ref([])
const menuOpen = ref(false)

onMounted(async () => {
  try {
    const res = await getNavBars()
    navItems.value = res.data.data || []
  } catch (error) {
    console.error('Failed to load nav bars:', error)
  }
  try {
    const res = await getProfile()
    if (res.data.data && res.data.data.name) {
      siteName.value = res.data.data.name
    }
  } catch (error) {
    // fallback to default
  }
})
</script>
