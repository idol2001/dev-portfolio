<template>
  <div class="min-h-screen text-white transition-colors duration-300"
       :class="isDark ? 'bg-gradient-to-br from-gray-900 to-gray-800' : 'bg-gradient-to-br from-gray-50 to-white text-gray-900'">
    <AppNav />

    <div class="pt-24 pb-12 px-4 max-w-6xl mx-auto">
      <h1 class="text-4xl font-bold mb-12">Projects</h1>
      
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
        <div v-for="project in projects" :key="project.Id" 
             class="rounded-lg overflow-hidden hover:transform hover:scale-105 transition"
             :class="isDark ? 'bg-gray-800' : 'bg-white shadow-md'">
          <div class="p-6">
            <h3 class="text-xl font-semibold mb-2">{{ project.title }}</h3>
            <p class="text-sm mb-4" :class="isDark ? 'text-gray-400' : 'text-gray-600'">{{ project.description }}</p>
            <div class="flex flex-wrap gap-2 mb-4">
              <span v-for="tech in parseTechStack(project.tech_stack)" :key="tech" 
                    class="px-2 py-1 rounded text-xs"
                    :class="isDark ? 'bg-blue-600/30 text-blue-400' : 'bg-blue-100 text-blue-700'">
                {{ tech }}
              </span>
            </div>
            <div class="flex gap-4">
              <a v-if="project.repo_url" :href="project.repo_url" target="_blank" 
                 class="transition"
                 :class="isDark ? 'text-gray-400 hover:text-white' : 'text-gray-500 hover:text-gray-900'">
                <span>📦 Code</span>
              </a>
              <a v-if="project.demo_url" :href="project.demo_url" target="_blank" 
                 class="transition"
                 :class="isDark ? 'text-gray-400 hover:text-white' : 'text-gray-500 hover:text-gray-900'">
                <span>🌐 Demo</span>
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import AppNav from '../components/AppNav.vue'
import { getProjects } from '../api'

const { isDark } = inject('theme', { isDark: ref(true) })

const projects = ref([])

const parseTechStack = (techStack) => {
  try {
    return JSON.parse(techStack)
  } catch {
    return techStack.split(',').map(t => t.trim())
  }
}

onMounted(async () => {
  try {
    const res = await getProjects()
    projects.value = res.data.data
  } catch (error) {
    console.error('Failed to load projects:', error)
  }
})
</script>
