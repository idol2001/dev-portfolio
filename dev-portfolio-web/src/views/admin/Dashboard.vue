<template>
  <div class="min-h-screen bg-gray-100">
    <div class="flex">
      <!-- Sidebar -->
      <aside class="w-64 bg-gray-900 text-white min-h-screen">
        <div class="p-4">
          <h1 class="text-xl font-bold">Admin Panel</h1>
          <div v-if="authStore.user" class="mt-2 text-sm text-gray-400">
            {{ authStore.user.username }}
          </div>
        </div>
        <nav class="mt-4">
          <router-link to="/admin/profile" 
                       class="block px-4 py-2 hover:bg-gray-800 transition">
            Profile
          </router-link>
          <router-link to="/admin/skills" 
                       class="block px-4 py-2 hover:bg-gray-800 transition">
            Skills
          </router-link>
          <router-link to="/admin/projects" 
                       class="block px-4 py-2 hover:bg-gray-800 transition">
            Projects
          </router-link>
          <router-link to="/admin/blogs" 
                       class="block px-4 py-2 hover:bg-gray-800 transition">
            Blogs
          </router-link>
          <router-link to="/admin/users" 
                       class="block px-4 py-2 hover:bg-gray-800 transition">
            Users
          </router-link>
          <div class="border-t border-gray-800 mt-4 pt-4">
            <router-link to="/" 
                         class="block px-4 py-2 hover:bg-gray-800 transition">
              ← Back to Site
            </router-link>
            <button @click="handleLogout" 
                    class="w-full text-left px-4 py-2 hover:bg-gray-800 transition text-red-400">
              Logout
            </button>
          </div>
        </nav>
      </aside>

      <!-- Main Content -->
      <main class="flex-1 p-8">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '../../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const handleLogout = () => {
  authStore.logout()
  router.push('/login')
}
</script>
