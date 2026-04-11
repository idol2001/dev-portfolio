<template>
  <div class="min-h-screen text-white transition-colors duration-300"
       :class="isDark ? 'bg-gradient-to-br from-gray-900 to-gray-800' : 'bg-gradient-to-br from-gray-50 to-white text-gray-900'">
    <AppNav />

    <div class="pt-24 pb-12 px-4 max-w-4xl mx-auto">
      <h1 class="text-4xl font-bold mb-12">Blog Posts</h1>
      
      <div class="space-y-8">
        <div v-for="post in posts" :key="post.id" 
             class="p-6 rounded-lg transition cursor-pointer"
             :class="isDark ? 'bg-gray-800 hover:bg-gray-750' : 'bg-white shadow-md hover:shadow-lg'"
             @click="$router.push(`/blog/${post.slug}`)">
          <h2 class="text-2xl font-semibold mb-2">{{ post.title }}</h2>
          <p class="mb-4" :class="isDark ? 'text-gray-400' : 'text-gray-600'">{{ post.summary || '' }}</p>

          <!-- Tags -->
          <div v-if="post.tags" class="flex flex-wrap gap-2 mb-4">
            <span v-for="tag in post.tags.split(',')" :key="tag.trim()" 
                  class="px-2 py-0.5 text-xs rounded"
                  :class="isDark ? 'bg-blue-500/20 text-blue-400' : 'bg-blue-100 text-blue-700'">
              {{ tag.trim() }}
            </span>
          </div>

          <div class="flex items-center gap-4 text-sm"
               :class="isDark ? 'text-gray-500' : 'text-gray-400'">
            <span>{{ formatDate(post.created_at) }}</span>
            <span>👁 {{ post.view_count }} views</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import AppNav from '../components/AppNav.vue'
import { getBlogPosts } from '../api'

const { isDark } = inject('theme', { isDark: ref(true) })

const posts = ref([])

const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

onMounted(async () => {
  try {
    const res = await getBlogPosts()
    posts.value = res.data.data?.list || []
  } catch (error) {
    console.error('Failed to load blog posts:', error)
  }
})
</script>
