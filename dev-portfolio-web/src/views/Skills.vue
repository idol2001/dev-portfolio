<template>
  <div class="min-h-screen transition-colors duration-300"
       :class="isDark ? 'bg-gradient-to-br from-gray-900 to-gray-800 text-white' : 'bg-gradient-to-br from-gray-50 to-white text-gray-900'">
    <AppNav />

    <div class="pt-24 pb-12 px-4 max-w-6xl mx-auto">
      <h1 class="text-4xl font-bold mb-4 text-center">Skills</h1>
      <p class="mb-12 text-center max-w-3xl mx-auto whitespace-pre-line"
         :class="isDark ? 'text-gray-300' : 'text-gray-600'">{{ skills.intro }}</p>
      
      <!-- Skills by Category -->
      <div class="space-y-8">
        <div v-for="group in skills.skills" :key="group.title">
          <h2 class="text-xl font-semibold mb-4 text-center" :class="isDark ? 'text-blue-400' : 'text-blue-600'">{{ group.title }}</h2>
          <div class="flex flex-wrap justify-center gap-x-6 gap-y-4">
            <div v-for="item in group.items" :key="item.title" 
                 class="flex flex-col items-center w-24">
              <div v-if="item.icon" class="w-[75px] h-[75px] mb-2">
                <img :src="item.icon" :alt="item.title" class="w-full h-full object-contain" />
              </div>
              <div v-else class="w-[75px] h-[75px] mb-2 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center text-xl font-bold">
                {{ getIcon(item.title) }}
              </div>
              <h3 class="text-xs text-center leading-tight" :class="isDark ? 'text-gray-300' : 'text-gray-600'">{{ item.title }}</h3>
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
import { getSkills } from '../api'

const { isDark } = inject('theme', { isDark: ref(true) })

const skills = ref({ intro: '', skills: [] })

// 技能图标映射（首字母或缩写）
const iconMap = {
  'Java': 'J',
  'C#': '#',
  'JavaScript': 'JS',
  'Python': 'Py',
  'Objective-C': 'OC',
  'MySQL': 'DB',
  'Android': 'An',
  'Django': 'Dj',
  'Flask': 'Fl',
  'SpringBoot': 'SB',
  'Dubbo': 'Db',
  'Nacos': 'Na',
  'Flutter': 'Ft',
  'Android Studio': 'AS',
  'XCode': 'XC',
  'Git': 'Git',
  'Docker': 'Dk',
  'Sketch': 'Sk',
  'Axure': 'Ax'
}

const getIcon = (title) => {
  return iconMap[title] || title.substring(0, 2)
}

onMounted(async () => {
  try {
    const res = await getSkills()
    skills.value = res.data.data
  } catch (error) {
    console.error('Failed to load skills:', error)
  }
})
</script>
