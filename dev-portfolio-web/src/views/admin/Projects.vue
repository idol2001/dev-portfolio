<template>
  <div class="max-w-6xl mx-auto">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Projects Management</h1>
      <button @click="showAddProject = true" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
        + Add Project
      </button>
    </div>

    <!-- 添加/编辑项目表单 -->
    <div v-if="showAddProject || editingProject" class="bg-white p-6 rounded-lg shadow mb-6">
      <h3 class="font-medium mb-4">{{ editingProject ? 'Edit Project' : 'New Project' }}</h3>
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium mb-1">Title *</label>
          <input v-model="form.title" type="text" class="w-full px-3 py-2 border rounded-lg" />
        </div>
        
        <div>
          <label class="block text-sm font-medium mb-1">Description</label>
          <textarea v-model="form.description" rows="4" class="w-full px-3 py-2 border rounded-lg"></textarea>
        </div>

        <div>
          <label class="block text-sm font-medium mb-1">Tech Stack (JSON array, e.g. ["Vue", "Go", "MySQL"])</label>
          <input v-model="techStackInput" type="text" placeholder='["Vue", "Go", "MySQL"]' class="w-full px-3 py-2 border rounded-lg" />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium mb-1">Repository URL</label>
            <input v-model="form.repo_url" type="url" placeholder="https://github.com/..." class="w-full px-3 py-2 border rounded-lg" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Demo URL</label>
            <input v-model="form.demo_url" type="url" placeholder="https://..." class="w-full px-3 py-2 border rounded-lg" />
          </div>
        </div>

        <div>
          <label class="block text-sm font-medium mb-1">Cover Image URL</label>
          <input v-model="form.cover_image" type="url" placeholder="https://..." class="w-full px-3 py-2 border rounded-lg" />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium mb-1">Order</label>
            <input v-model.number="form.order_no" type="number" class="w-full px-3 py-2 border rounded-lg" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Status</label>
            <select v-model="form.status" class="w-full px-3 py-2 border rounded-lg">
              <option value="draft">Draft</option>
              <option value="published">Published</option>
            </select>
          </div>
        </div>

        <div class="flex gap-2">
          <button @click="editingProject ? handleUpdateProject() : handleCreateProject()" 
                  class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
            {{ editingProject ? 'Update' : 'Create' }}
          </button>
          <button @click="cancelForm" class="px-4 py-2 border rounded-lg hover:bg-gray-50">Cancel</button>
        </div>
      </div>
    </div>

    <!-- 项目列表 -->
    <div v-if="projects.length === 0" class="text-gray-400">No projects found.</div>
    <div v-else class="space-y-4">
      <div v-for="project in projects" :key="project.id" class="bg-white rounded-lg shadow p-5">
        <div class="flex justify-between items-start mb-3">
          <div>
            <h3 class="text-lg font-semibold">{{ project.title }}</h3>
            <p class="text-gray-500 text-sm">{{ truncate(project.description, 100) }}</p>
          </div>
          <div class="flex gap-2">
            <span class="px-2 py-1 text-xs rounded-full"
                  :class="project.status === 'published' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'">
              {{ project.status }}
            </span>
          </div>
        </div>

        <!-- Tech Stack -->
        <div class="flex flex-wrap gap-2 mb-3">
          <span v-for="tech in parseTechStack(project.tech_stack)" :key="tech" 
                class="px-2 py-1 bg-blue-50 text-blue-600 text-xs rounded">
            {{ tech }}
          </span>
        </div>

        <!-- Links -->
        <div class="flex gap-4 text-sm text-gray-500 mb-3">
          <a v-if="project.repo_url" :href="project.repo_url" target="_blank" class="text-blue-600 hover:underline">
            🔗 Repository
          </a>
          <a v-if="project.demo_url" :href="project.demo_url" target="_blank" class="text-blue-600 hover:underline">
            🌐 Live Demo
          </a>
          <span v-if="project.cover_image" class="text-gray-400">🖼️ Has cover image</span>
        </div>

        <div class="flex justify-between items-center">
          <span class="text-xs text-gray-400">Order: {{ project.order_no }} | Created: {{ formatDate(project.created_at) }}</span>
          <div class="flex gap-2">
            <button @click="startEditProject(project)" class="text-blue-600 text-sm hover:underline">Edit</button>
            <button @click="handleDeleteProject(project.id)" class="text-red-600 text-sm hover:underline">Delete</button>
          </div>
        </div>
      </div>
    </div>

    <p v-if="message" class="fixed bottom-4 right-4 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg">
      {{ message }}
    </p>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { getProjects, createProject, updateProject, deleteProject } from '../../api'

const projects = ref([])
const showAddProject = ref(false)
const editingProject = ref(null)
const message = ref('')

const defaultForm = () => ({
  title: '',
  description: '',
  tech_stack: '[]',
  repo_url: '',
  demo_url: '',
  cover_image: '',
  order_no: 0,
  status: 'published'
})

const form = ref(defaultForm())

const techStackInput = computed({
  get() {
    try {
      const stack = JSON.parse(form.value.tech_stack)
      return Array.isArray(stack) ? stack.join(', ') : ''
    } catch {
      return form.value.tech_stack
    }
  },
  set(val) {
    try {
      const items = val.split(',').map(s => s.trim()).filter(Boolean)
      form.value.tech_stack = JSON.stringify(items)
    } catch {
      form.value.tech_stack = '[]'
    }
  }
})

onMounted(async () => {
  await loadProjects()
})

async function loadProjects() {
  try {
    const res = await getProjects(false) // 获取所有项目（包括草稿）
    projects.value = res.data.data
  } catch (error) {
    console.error('Failed to load projects:', error)
  }
}

async function handleCreateProject() {
  if (!form.value.title.trim()) return
  try {
    await createProject(form.value)
    resetForm()
    showMessage('Project created')
    await loadProjects()
  } catch (error) {
    console.error('Failed to create project:', error)
  }
}

function startEditProject(project) {
  editingProject.value = project.id
  form.value = {
    id: project.id,
    title: project.title,
    description: project.description || '',
    tech_stack: project.tech_stack || '[]',
    repo_url: project.repo_url || '',
    demo_url: project.demo_url || '',
    cover_image: project.cover_image || '',
    order_no: project.order_no,
    status: project.status
  }
}

async function handleUpdateProject() {
  if (!form.value.title.trim()) return
  try {
    await updateProject(editingProject.value, form.value)
    resetForm()
    showMessage('Project updated')
    await loadProjects()
  } catch (error) {
    console.error('Failed to update project:', error)
  }
}

async function handleDeleteProject(id) {
  if (!confirm('Delete this project?')) return
  try {
    await deleteProject(id)
    showMessage('Project deleted')
    await loadProjects()
  } catch (error) {
    console.error('Failed to delete project:', error)
  }
}

function cancelForm() {
  resetForm()
}

function resetForm() {
  form.value = defaultForm()
  showAddProject.value = false
  editingProject.value = null
}

function parseTechStack(jsonStr) {
  try {
    const parsed = JSON.parse(jsonStr)
    return Array.isArray(parsed) ? parsed : []
  } catch {
    return []
  }
}

function truncate(str, len) {
  if (!str) return ''
  return str.length > len ? str.substring(0, len) + '...' : str
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString()
}

function showMessage(msg) {
  message.value = msg
  setTimeout(() => message.value = '', 2000)
}
</script>
