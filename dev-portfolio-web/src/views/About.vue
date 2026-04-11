<template>
  <div class="min-h-screen text-white transition-colors duration-300"
       :class="isDark ? 'bg-gradient-to-br from-gray-900 to-gray-800' : 'bg-gradient-to-br from-gray-50 to-white text-gray-900'">
    <AppNav />

    <div class="pt-24 pb-12 px-4 max-w-4xl mx-auto">
      <h1 class="text-4xl font-bold mb-8">About Me</h1>

      <!-- Profile Image -->
      <img v-if="profile.image_source" :src="profile.image_source" :alt="profile.name"
           class="w-64 h-64 object-cover rounded-full mx-auto mb-8 border-4 border-blue-500/30" />

      <div class="prose max-w-none whitespace-pre-wrap"
           :class="isDark ? 'prose-invert' : 'prose-gray'">{{ profile.about }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import AppNav from '../components/AppNav.vue'
import { getProfile } from '../api'

const { isDark } = inject('theme', { isDark: ref(true) })

const profile = ref({ about: '', name: '', image_source: '' })

onMounted(async () => {
  try {
    const res = await getProfile()
    profile.value = res.data.data || {}
  } catch (error) {
    console.error('Failed to load profile:', error)
  }
})
</script>
