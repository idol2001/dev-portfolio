<template>
  <div class="max-w-6xl mx-auto">
    <h1 class="text-2xl font-bold mb-6">Skills Management</h1>

    <!-- Skill Groups -->
    <div class="space-y-6">
      <div class="flex justify-between items-center">
        <h2 class="text-lg font-semibold">Skill Groups</h2>
        <button @click="showAddGroup = true" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
          + Add Group
        </button>
      </div>

      <!-- Add Group Modal -->
      <div v-if="showAddGroup" class="bg-white p-4 rounded-lg shadow">
        <h3 class="font-medium mb-3">New Skill Group</h3>
        <div class="flex gap-3">
          <input v-model="newGroupTitle" type="text" placeholder="Group name (e.g., Languages & Databases)" 
                 class="flex-1 px-3 py-2 border rounded-lg" @keyup.enter="handleCreateGroup" />
          <button @click="handleCreateGroup" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
            Save
          </button>
          <button @click="showAddGroup = false" class="px-4 py-2 border rounded-lg hover:bg-gray-50">Cancel</button>
        </div>
      </div>

      <!-- Group Cards -->
      <div v-for="group in groups" :key="group.id" class="bg-white rounded-lg shadow p-5">
        <div class="flex justify-between items-center mb-4">
          <div class="flex items-center gap-3">
            <input v-if="editingGroupId === group.id" v-model="editingGroupTitle" type="text" 
                   class="px-3 py-1 border rounded-lg text-lg font-semibold" @keyup.enter="handleUpdateGroup(group.id)" />
            <h3 v-else class="text-lg font-semibold">{{ group.skill_group_title }}</h3>
            <div v-if="editingGroupId === group.id" class="flex gap-2">
              <button @click="handleUpdateGroup(group.id)" class="text-green-600 text-sm hover:underline">Save</button>
              <button @click="editingGroupId = null" class="text-gray-500 text-sm hover:underline">Cancel</button>
            </div>
            <div v-else class="flex gap-2">
              <button @click="startEditGroup(group)" class="text-blue-600 text-sm hover:underline">Edit</button>
              <button @click="handleDeleteGroup(group.id)" class="text-red-600 text-sm hover:underline">Delete</button>
            </div>
          </div>
          <button @click="showAddItemFor = group.id" class="text-blue-600 text-sm hover:underline">+ Add Skill</button>
        </div>

        <!-- Add Item Form -->
        <div v-if="showAddItemFor === group.id" class="mb-4 p-3 bg-gray-50 rounded-lg">
          <div class="flex gap-3">
            <input v-model="newItemTitle" type="text" placeholder="Skill name" class="flex-1 px-3 py-2 border rounded-lg" />
            <button @click="handleCreateItem(group.id)" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
              Add
            </button>
            <button @click="showAddItemFor = null" class="px-4 py-2 border rounded-lg hover:bg-gray-50">Cancel</button>
          </div>
        </div>

        <!-- Skill Items Grid -->
        <div class="grid grid-cols-4 sm:grid-cols-6 md:grid-cols-8 gap-3">
          <div v-for="item in group.skill_group_items" :key="item.id" class="flex flex-col items-center p-3 bg-gray-50 rounded-lg group relative">
            <img v-if="item.skill_icon" :src="item.skill_icon" :alt="item.skill_title" 
                 class="w-12 h-12 object-contain mb-1" />
            <div v-else class="w-12 h-12 bg-gray-200 rounded-lg flex items-center justify-center mb-1 text-gray-400 text-xs">
              No Icon
            </div>
            <span class="text-xs text-center truncate w-full">{{ item.skill_title }}</span>
            <!-- Action buttons -->
            <div class="absolute top-1 right-1 flex gap-1 opacity-0 group-hover:opacity-100 transition">
              <button @click="startEditItem(item)" class="text-blue-500 text-xs hover:underline">✎</button>
              <button @click="handleDeleteItem(item.id)" class="text-red-500 text-xs hover:underline">✕</button>
            </div>
          </div>
        </div>

        <!-- Edit Item Inline Form -->
        <div v-if="editingItemId" class="mt-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
          <h4 class="text-sm font-medium text-blue-800 mb-2">Edit Skill</h4>
          <div class="flex flex-col gap-3">
            <div class="flex gap-3 items-start">
              <div class="flex-1">
                <input v-model="editingItemTitle" type="text" placeholder="Skill name" class="w-full px-3 py-2 border rounded-lg text-sm" />
              </div>
              <div class="flex items-center gap-2">
                <label class="cursor-pointer bg-blue-600 text-white px-3 py-2 rounded-lg text-sm hover:bg-blue-700">
                  📁 Upload Icon
                  <input type="file" accept="image/png,image/svg+xml,image/jpeg,image/webp" class="hidden" @change="handleItemIconUpload" />
                </label>
                <button v-if="editingItemIcon" @click="editingItemIcon = ''" class="text-red-500 text-xs hover:underline">Remove</button>
              </div>
            </div>
            <div class="flex items-center gap-2">
              <span class="text-xs text-gray-500">Preview:</span>
              <img v-if="editingItemIcon" :src="editingItemIcon" class="w-8 h-8 object-contain" />
              <span v-else class="text-xs text-gray-400">No icon selected</span>
            </div>
            <div class="flex gap-2">
              <button @click="handleUpdateItem" class="bg-green-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-green-700">Save</button>
              <button @click="editingItemId = null" class="px-4 py-2 border rounded-lg text-sm hover:bg-gray-50">Cancel</button>
            </div>
          </div>
        </div>

        <p v-if="!group.skill_group_items || group.skill_group_items.length === 0" class="text-gray-400 text-sm mt-2">
          No skills in this group yet.
        </p>
      </div>
    </div>

    <!-- Message -->
    <p v-if="message" class="fixed bottom-4 right-4 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg">
      {{ message }}
    </p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getSkillGroups, createSkillGroup, updateSkillGroup, deleteSkillGroup, createSkillItem, updateSkillItem, deleteSkillItem, uploadFile } from '../../api'

const groups = ref([])
const showAddGroup = ref(false)
const newGroupTitle = ref('')
const editingGroupId = ref(null)
const editingGroupTitle = ref('')
const showAddItemFor = ref(null)
const newItemTitle = ref('')
const editingItemId = ref(null)
const editingItemTitle = ref('')
const editingItemIcon = ref('')
const message = ref('')

onMounted(async () => {
  await loadGroups()
})

async function loadGroups() {
  try {
    const res = await getSkillGroups()
    groups.value = res.data.data
  } catch (error) {
    console.error('Failed to load skills:', error)
  }
}

async function handleCreateGroup() {
  if (!newGroupTitle.value.trim()) return
  try {
    await createSkillGroup({ title: newGroupTitle.value })
    newGroupTitle.value = ''
    showAddGroup.value = false
    showMessage('Group created')
    await loadGroups()
  } catch (error) {
    console.error('Failed to create group:', error)
  }
}

function startEditGroup(group) {
  editingGroupId.value = group.id
  editingGroupTitle.value = group.skill_group_title
}

async function handleUpdateGroup(id) {
  if (!editingGroupTitle.value.trim()) return
  try {
    await updateSkillGroup(id, { title: editingGroupTitle.value })
    editingGroupId.value = null
    showMessage('Group updated')
    await loadGroups()
  } catch (error) {
    console.error('Failed to update group:', error)
  }
}

async function handleDeleteGroup(id) {
  if (!confirm('Delete this group and all its skills?')) return
  try {
    await deleteSkillGroup(id)
    showMessage('Group deleted')
    await loadGroups()
  } catch (error) {
    console.error('Failed to delete group:', error)
  }
}

async function handleCreateItem(groupId) {
  if (!newItemTitle.value.trim()) return
  try {
    await createSkillItem(groupId, { title: newItemTitle.value })
    newItemTitle.value = ''
    showAddItemFor.value = null
    showMessage('Skill added')
    await loadGroups()
  } catch (error) {
    console.error('Failed to create item:', error)
  }
}

async function handleDeleteItem(id) {
  try {
    await deleteSkillItem(id)
    showMessage('Skill deleted')
    await loadGroups()
  } catch (error) {
    console.error('Failed to delete item:', error)
  }
}

function startEditItem(item) {
  editingItemId.value = item.id
  editingItemTitle.value = item.skill_title
  editingItemIcon.value = item.skill_icon || ''
}

async function handleItemIconUpload(event) {
  const file = event.target.files[0]
  if (!file) return
  try {
    const res = await uploadFile('skill-icons', file)
    editingItemIcon.value = res.data.data.url
    event.target.value = '' // reset file input
  } catch (error) {
    console.error('Failed to upload icon:', error)
    alert('图标上传失败')
  }
}

async function handleUpdateItem() {
  if (!editingItemTitle.value.trim()) return
  try {
    await updateSkillItem(editingItemId.value, {
      title: editingItemTitle.value,
      icon: editingItemIcon.value
    })
    editingItemId.value = null
    showMessage('Skill updated')
    await loadGroups()
  } catch (error) {
    console.error('Failed to update item:', error)
  }
}

function showMessage(msg) {
  message.value = msg
  setTimeout(() => message.value = '', 2000)
}
</script>
