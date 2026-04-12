<template>
  <div class="min-h-screen transition-colors duration-300"
       :class="isDark ? 'bg-gradient-to-br from-gray-900 to-gray-800 text-white' : 'bg-gradient-to-br from-gray-50 to-white text-gray-900'">
    <AppNav />

    <!-- Hero Section -->
    <section class="flex items-center justify-center min-h-screen px-4">
      <div class="text-center">
        <h1 class="text-5xl md:text-7xl font-bold mb-4">{{ profile.name || 'Jacob Lee' }}</h1>
        <p class="text-xl md:text-2xl mb-8 min-h-[2rem]" :class="isDark ? 'text-gray-300' : 'text-gray-600'">
          <span class="typing-text">{{ typedText }}</span><span class="typing-cursor" :class="{ 'typing-blink': showCursor }">|</span>
        </p>

        <!-- Social Links -->
        <div class="flex justify-center gap-4 mb-6">
          <a v-for="s in socials" :key="s.id"
             :href="s.href" target="_blank"
             class="transition text-2xl"
             :class="isDark ? 'text-gray-400 hover:text-white' : 'text-gray-500 hover:text-gray-900'"
             :title="s.network">
            <!-- Icon based on network name -->
            <svg v-if="isNetwork(s.network, 'github')" class="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>
            <svg v-else-if="isNetwork(s.network, 'linkedin')" class="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/></svg>
            <svg v-else-if="isNetwork(s.network, 'email')" class="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/></svg>
            <svg v-else class="w-8 h-8" fill="currentColor" viewBox="0 0 24 24"><path d="M3.9 12c0-1.71 1.39-3.1 3.1-3.1h4V7H7c-2.76 0-5 2.24-5 5s2.24 5 5 5h4v-1.9H7c-1.71 0-3.1-1.39-3.1-3.1zM8 13h8v-2H8v2zm9-6h-4v1.9h4c1.71 0 3.1 1.39 3.1 3.1s-1.39 3.1-3.1 3.1h-4V17h4c2.76 0 5-2.24 5-5s-2.24-5-5-5z"/></svg>
          </a>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, inject } from 'vue'
import AppNav from '../components/AppNav.vue'
import { getProfile, getSocials } from '../api'

const { isDark } = inject('theme', { isDark: ref(true) })

const profile = ref({ name: '', roles: '' })
const socials = ref([])

// Typing effect state
const roles = ref([])
const typedText = ref('')
const showCursor = ref(true)

const isNetwork = (network, keyword) => {
  return network && network.toLowerCase().includes(keyword.toLowerCase())
}

// Typing animation loop
let typingTimer = null
const TYPING_SPEED = 80     // ms per character
const DELETING_SPEED = 40   // ms per character
const PAUSE_AFTER_TYPE = 2000  // pause after typing complete
const PAUSE_AFTER_DELETE = 500 // pause after deleting

function startTyping() {
  if (!roles.value.length) return
  let roleIndex = 0
  let charIndex = 0
  let isDeleting = false

  function tick() {
    const current = roles.value[roleIndex]
    if (!current) return

    if (!isDeleting) {
      typedText.value = current.substring(0, charIndex + 1)
      charIndex++
      if (charIndex === current.length) {
        // Done typing, pause then start deleting
        typingTimer = setTimeout(() => { isDeleting = true; tick() }, PAUSE_AFTER_TYPE)
        return
      }
      typingTimer = setTimeout(tick, TYPING_SPEED)
    } else {
      typedText.value = current.substring(0, charIndex - 1)
      charIndex--
      if (charIndex === 0) {
        isDeleting = false
        roleIndex = (roleIndex + 1) % roles.value.length
        // Pause before typing next role
        typingTimer = setTimeout(() => { tick() }, PAUSE_AFTER_DELETE)
        return
      }
      typingTimer = setTimeout(tick, DELETING_SPEED)
    }
  }

  tick()
}

onMounted(async () => {
  try {
    const res = await getProfile()
    const data = res.data.data || {}
    profile.value = data
    // Parse roles from JSON array string
    try {
      roles.value = typeof data.roles === 'string' ? JSON.parse(data.roles) : (data.roles || [])
    } catch {
      // If not valid JSON, treat as single string
      roles.value = data.roles ? [data.roles] : []
    }
    // Start typing animation once roles are loaded
    startTyping()
  } catch (error) {
    console.error('Failed to load profile:', error)
  }
  try {
    const res = await getSocials()
    socials.value = res.data.data || []
  } catch (error) {
    console.error('Failed to load socials:', error)
  }
})

onUnmounted(() => {
  if (typingTimer) clearTimeout(typingTimer)
})
</script>

<style scoped>
.typing-cursor {
  color: #60a5fa;
  font-weight: 300;
}
.typing-blink {
  animation: blink 1s step-end infinite;
}
@keyframes blink {
  0%, 100% { opacity: 1; }
  50% { opacity: 0; }
}
</style>
