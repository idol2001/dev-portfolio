<template>
  <footer class="w-full backdrop-blur-sm border-t transition-colors duration-300"
          :class="isDark ? 'bg-gray-900/80 border-gray-700/50' : 'bg-white/80 border-gray-200'">
    <div class="max-w-6xl mx-auto px-4 py-6 text-center">
      <p class="text-sm" :class="isDark ? 'text-gray-400' : 'text-gray-500'">
        &copy; {{ new Date().getFullYear() }} {{ siteName }}. All rights reserved.
      </p>
      <a
        v-if="icpFiling"
        href="https://beian.miit.gov.cn/"
        target="_blank"
        rel="noopener noreferrer"
        class="text-xs hover:text-blue-400 transition mt-1 inline-block"
        :class="isDark ? 'text-gray-500' : 'text-gray-400'"
      >
        {{ icpFiling }}
      </a>
    </div>
  </footer>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import { getProfile } from '../api'

const { isDark } = inject('theme', { isDark: ref(true) })

const siteName = ref('Jacob Lee')
const icpFiling = ref('')

onMounted(async () => {
  try {
    const res = await getProfile()
    if (res.data.data) {
      if (res.data.data.name) siteName.value = res.data.data.name
      if (res.data.data.icp_filing) icpFiling.value = res.data.data.icp_filing
    }
  } catch (error) {
    console.error('Failed to load profile for footer:', error)
  }
})
</script>
