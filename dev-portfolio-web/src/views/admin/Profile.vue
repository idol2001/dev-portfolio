<template>
  <div>
    <h1 class="text-2xl font-bold mb-6">Profile Management</h1>
    
    <!-- 基本信息 -->
    <div class="bg-white rounded-lg shadow p-6 mb-6">
      <h2 class="text-lg font-semibold mb-4">Basic Information</h2>
      <form @submit.prevent="saveProfile" class="space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1">Name</label>
          <input v-model="profileForm.name" type="text" class="w-full px-3 py-2 border rounded-lg" />
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-1">Roles / Slogan</label>
          <input v-model="profileForm.roles" type="text" class="w-full px-3 py-2 border rounded-lg" />
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-1">About</label>
          <textarea v-model="profileForm.about" rows="6" class="w-full px-3 py-2 border rounded-lg"></textarea>
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-1">ICP 备案号</label>
          <input v-model="profileForm.icp_filing" type="text" placeholder="例如：京ICP备12345678号" class="w-full px-3 py-2 border rounded-lg" />
        </div>
        
        <div class="flex gap-4">
          <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg hover:bg-blue-700">
            Save Profile
          </button>
          <span v-if="profileMessage" class="text-green-600 self-center">{{ profileMessage }}</span>
        </div>
      </form>
    </div>

    <!-- 社交链接管理 -->
    <div class="bg-white rounded-lg shadow p-6 mb-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-lg font-semibold">Social Links</h2>
        <button @click="showAddSocial = true" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 text-sm">
          + Add Social
        </button>
      </div>

      <!-- 添加社交链接表单 -->
      <div v-if="showAddSocial" class="mb-4 p-4 bg-gray-50 rounded-lg">
        <div class="grid grid-cols-3 gap-3 mb-3">
          <input v-model="newSocial.network" type="text" placeholder="Network (e.g., GitHub, Twitter)" class="px-3 py-2 border rounded-lg" />
          <input v-model="newSocial.href" type="text" placeholder="URL (https://...)" class="px-3 py-2 border rounded-lg" />
          <input v-model.number="newSocial.order_no" type="number" placeholder="Order" class="px-3 py-2 border rounded-lg" />
        </div>
        <div class="flex gap-2">
          <button @click="handleCreateSocial" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 text-sm">Save</button>
          <button @click="showAddSocial = false" class="px-4 py-2 border rounded-lg hover:bg-gray-50 text-sm">Cancel</button>
        </div>
      </div>

      <!-- 社交链接列表 -->
      <div v-if="socials.length === 0" class="text-gray-400 text-sm mb-4">No social links yet.</div>
      <div v-else class="space-y-2">
        <div v-for="social in socials" :key="social.id" class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
          <div class="flex-1">
            <span class="font-medium">{{ social.network }}</span>
            <span class="text-gray-500 text-sm ml-2">{{ social.href }}</span>
          </div>
          <div class="text-gray-400 text-sm mr-4">Order: {{ social.order_no }}</div>
          <div class="flex gap-2">
            <button @click="startEditSocial(social)" class="text-blue-600 text-sm hover:underline">Edit</button>
            <button @click="handleDeleteSocial(social.id)" class="text-red-600 text-sm hover:underline">Delete</button>
          </div>
        </div>
      </div>

      <!-- 编辑社交链接 -->
      <div v-if="editingSocial" class="mt-4 p-4 bg-yellow-50 rounded-lg">
        <div class="grid grid-cols-3 gap-3 mb-3">
          <input v-model="editingSocial.network" type="text" placeholder="Network" class="px-3 py-2 border rounded-lg" />
          <input v-model="editingSocial.href" type="text" placeholder="URL" class="px-3 py-2 border rounded-lg" />
          <input v-model.number="editingSocial.order_no" type="number" placeholder="Order" class="px-3 py-2 border rounded-lg" />
        </div>
        <div class="flex gap-2">
          <button @click="handleUpdateSocial" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 text-sm">Update</button>
          <button @click="editingSocial = null" class="px-4 py-2 border rounded-lg hover:bg-gray-50 text-sm">Cancel</button>
        </div>
      </div>
    </div>

    <!-- 导航菜单管理 -->
    <div class="bg-white rounded-lg shadow p-6 mb-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-lg font-semibold">Navigation Menu</h2>
        <button @click="showAddNavBar = true" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 text-sm">
          + Add Menu Item
        </button>
      </div>

      <!-- 添加导航菜单表单 -->
      <div v-if="showAddNavBar" class="mb-4 p-4 bg-gray-50 rounded-lg">
        <div class="grid grid-cols-3 gap-3 mb-3">
          <input v-model="newNavBar.title" type="text" placeholder="Title (e.g., About)" class="px-3 py-2 border rounded-lg" />
          <input v-model="newNavBar.href" type="text" placeholder="Link (e.g., /about)" class="px-3 py-2 border rounded-lg" />
          <input v-model.number="newNavBar.order_no" type="number" placeholder="Order" class="px-3 py-2 border rounded-lg" />
        </div>
        <div class="flex gap-2">
          <button @click="handleCreateNavBar" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 text-sm">Save</button>
          <button @click="showAddNavBar = false" class="px-4 py-2 border rounded-lg hover:bg-gray-50 text-sm">Cancel</button>
        </div>
      </div>

      <!-- 导航菜单列表 -->
      <div v-if="navBars.length === 0" class="text-gray-400 text-sm mb-4">No navigation items yet.</div>
      <div v-else class="space-y-2">
        <div v-for="item in navBars" :key="item.id" class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
          <div class="flex-1">
            <span class="font-medium">{{ item.title }}</span>
            <span class="text-gray-500 text-sm ml-2">{{ item.href }}</span>
          </div>
          <div class="text-gray-400 text-sm mr-4">Order: {{ item.order_no }}</div>
          <div class="flex gap-2">
            <button @click="startEditNavBar(item)" class="text-blue-600 text-sm hover:underline">Edit</button>
            <button @click="handleDeleteNavBar(item.id)" class="text-red-600 text-sm hover:underline">Delete</button>
          </div>
        </div>
      </div>

      <!-- 编辑导航菜单 -->
      <div v-if="editingNavBar" class="mt-4 p-4 bg-yellow-50 rounded-lg">
        <div class="grid grid-cols-3 gap-3 mb-3">
          <input v-model="editingNavBar.title" type="text" placeholder="Title" class="px-3 py-2 border rounded-lg" />
          <input v-model="editingNavBar.href" type="text" placeholder="Link" class="px-3 py-2 border rounded-lg" />
          <input v-model.number="editingNavBar.order_no" type="number" placeholder="Order" class="px-3 py-2 border rounded-lg" />
        </div>
        <div class="flex gap-2">
          <button @click="handleUpdateNavBar" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 text-sm">Update</button>
          <button @click="editingNavBar = null" class="px-4 py-2 border rounded-lg hover:bg-gray-50 text-sm">Cancel</button>
        </div>
      </div>
    </div>

    <!-- 全局提示 -->
    <p v-if="message" class="fixed bottom-4 right-4 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg">
      {{ message }}
    </p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { 
  getProfile, updateProfile,
  getSocials, createSocial, updateSocial, deleteSocial,
  getNavBars, createNavBar, updateNavBar, deleteNavBar
} from '../../api'

// Profile
const profileForm = ref({ name: '', roles: '', about: '' })
const profileMessage = ref('')

// Socials
const socials = ref([])
const showAddSocial = ref(false)
const newSocial = ref({ network: '', href: '', order_no: 0 })
const editingSocial = ref(null)

// NavBars
const navBars = ref([])
const showAddNavBar = ref(false)
const newNavBar = ref({ title: '', href: '', order_no: 0 })
const editingNavBar = ref(null)

// Global message
const message = ref('')

onMounted(async () => {
  await loadProfile()
  await loadSocials()
  await loadNavBars()
})

async function loadProfile() {
  try {
    const res = await getProfile()
    profileForm.value = res.data.data
  } catch (error) {
    console.error('Failed to load profile:', error)
  }
}

async function saveProfile() {
  try {
    await updateProfile(profileForm.value)
    profileMessage.value = 'Profile saved!'
    setTimeout(() => profileMessage.value = '', 3000)
  } catch (error) {
    console.error('Failed to save profile:', error)
  }
}

async function loadSocials() {
  try {
    const res = await getSocials()
    socials.value = res.data.data
  } catch (error) {
    console.error('Failed to load socials:', error)
  }
}

async function handleCreateSocial() {
  if (!newSocial.value.network.trim() || !newSocial.value.href.trim()) return
  try {
    await createSocial(newSocial.value)
    newSocial.value = { network: '', href: '', order_no: 0 }
    showAddSocial.value = false
    showMessage('Social link added')
    await loadSocials()
  } catch (error) {
    console.error('Failed to create social:', error)
  }
}

function startEditSocial(social) {
  editingSocial.value = { ...social }
}

async function handleUpdateSocial() {
  if (!editingSocial.value.network.trim() || !editingSocial.value.href.trim()) return
  try {
    await updateSocial(editingSocial.value.id, editingSocial.value)
    editingSocial.value = null
    showMessage('Social link updated')
    await loadSocials()
  } catch (error) {
    console.error('Failed to update social:', error)
  }
}

async function handleDeleteSocial(id) {
  if (!confirm('Delete this social link?')) return
  try {
    await deleteSocial(id)
    showMessage('Social link deleted')
    await loadSocials()
  } catch (error) {
    console.error('Failed to delete social:', error)
  }
}

async function loadNavBars() {
  try {
    const res = await getNavBars()
    navBars.value = res.data.data
  } catch (error) {
    console.error('Failed to load navBars:', error)
  }
}

async function handleCreateNavBar() {
  if (!newNavBar.value.title.trim() || !newNavBar.value.href.trim()) return
  try {
    await createNavBar(newNavBar.value)
    newNavBar.value = { title: '', href: '', order_no: 0 }
    showAddNavBar.value = false
    showMessage('Menu item added')
    await loadNavBars()
  } catch (error) {
    console.error('Failed to create navbar:', error)
  }
}

function startEditNavBar(item) {
  editingNavBar.value = { ...item }
}

async function handleUpdateNavBar() {
  if (!editingNavBar.value.title.trim() || !editingNavBar.value.href.trim()) return
  try {
    await updateNavBar(editingNavBar.value.id, editingNavBar.value)
    editingNavBar.value = null
    showMessage('Menu item updated')
    await loadNavBars()
  } catch (error) {
    console.error('Failed to update navbar:', error)
  }
}

async function handleDeleteNavBar(id) {
  if (!confirm('Delete this menu item?')) return
  try {
    await deleteNavBar(id)
    showMessage('Menu item deleted')
    await loadNavBars()
  } catch (error) {
    console.error('Failed to delete navbar:', error)
  }
}

function showMessage(msg) {
  message.value = msg
  setTimeout(() => message.value = '', 2000)
}
</script>
