<template>
  <div class="max-w-6xl mx-auto">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Users Management</h1>
      <button @click="showAddUser = true" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
        + Add User
      </button>
    </div>

    <!-- 添加用户表单 -->
    <div v-if="showAddUser" class="bg-white p-4 rounded-lg shadow mb-6">
      <h3 class="font-medium mb-3">New User</h3>
      <div class="grid grid-cols-2 gap-3 mb-3">
        <input v-model="newUser.username" type="text" placeholder="Username" class="px-3 py-2 border rounded-lg" />
        <input v-model="newUser.email" type="email" placeholder="Email" class="px-3 py-2 border rounded-lg" />
      </div>
      <div class="grid grid-cols-2 gap-3 mb-3">
        <input v-model="newUser.password" type="password" placeholder="Password" class="px-3 py-2 border rounded-lg" />
        <select v-model="newUser.role" class="px-3 py-2 border rounded-lg">
          <option value="admin">Admin</option>
          <option value="editor">Editor</option>
        </select>
      </div>
      <div class="flex gap-2">
        <button @click="handleCreateUser" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 text-sm">Create</button>
        <button @click="showAddUser = false" class="px-4 py-2 border rounded-lg hover:bg-gray-50 text-sm">Cancel</button>
      </div>
    </div>

    <!-- 用户列表 -->
    <div v-if="users.length === 0" class="text-gray-400">No users found.</div>
    <div v-else class="bg-white rounded-lg shadow overflow-hidden">
      <table class="w-full">
        <thead class="bg-gray-50">
          <tr>
            <th class="px-4 py-3 text-left text-sm font-medium text-gray-500">ID</th>
            <th class="px-4 py-3 text-left text-sm font-medium text-gray-500">Username</th>
            <th class="px-4 py-3 text-left text-sm font-medium text-gray-500">Email</th>
            <th class="px-4 py-3 text-left text-sm font-medium text-gray-500">Role</th>
            <th class="px-4 py-3 text-left text-sm font-medium text-gray-500">Created</th>
            <th class="px-4 py-3 text-right text-sm font-medium text-gray-500">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="user in users" :key="user.id" class="hover:bg-gray-50">
            <td class="px-4 py-3 text-sm text-gray-500">{{ user.id }}</td>
            <td class="px-4 py-3 text-sm font-medium">{{ user.username }}</td>
            <td class="px-4 py-3 text-sm text-gray-500">{{ user.email || '-' }}</td>
            <td class="px-4 py-3">
              <span v-if="editingUser?.id !== user.id" 
                    class="px-2 py-1 text-xs rounded-full"
                    :class="user.role === 'admin' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'">
                {{ user.role }}
              </span>
              <select v-else v-model="editingUser.role" class="px-2 py-1 border rounded text-sm">
                <option value="admin">Admin</option>
                <option value="editor">Editor</option>
              </select>
            </td>
            <td class="px-4 py-3 text-sm text-gray-500">{{ formatDate(user.created_at) }}</td>
            <td class="px-4 py-3 text-right text-sm space-x-2">
              <button v-if="editingUser?.id !== user.id" @click="startEditUser(user)" class="text-blue-600 hover:underline">Edit</button>
              <button v-else @click="handleUpdateUser(user.id)" class="text-green-600 hover:underline">Save</button>
              <button v-if="editingUser?.id === user.id" @click="editingUser = null" class="text-gray-500 hover:underline">Cancel</button>
              <button @click="showChangePassword(user.id)" class="text-yellow-600 hover:underline">Reset PW</button>
              <button @click="handleDeleteUser(user.id)" class="text-red-600 hover:underline">Delete</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- 修改密码模态框 -->
    <div v-if="changingPassword" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div class="bg-white rounded-lg shadow p-6 w-96">
        <h3 class="text-lg font-semibold mb-4">Change Password</h3>
        <div class="space-y-3">
          <input v-model="newPassword" type="password" placeholder="New password" class="w-full px-3 py-2 border rounded-lg" />
          <input v-model="confirmPassword" type="password" placeholder="Confirm password" class="w-full px-3 py-2 border rounded-lg" />
        </div>
        <p v-if="passwordError" class="text-red-500 text-sm mt-2">{{ passwordError }}</p>
        <div class="flex gap-2 mt-4">
          <button @click="handleChangePassword" class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700 text-sm">Update</button>
          <button @click="cancelChangePassword" class="px-4 py-2 border rounded-lg hover:bg-gray-50 text-sm">Cancel</button>
        </div>
      </div>
    </div>

    <p v-if="message" class="fixed bottom-4 right-4 bg-green-600 text-white px-4 py-2 rounded-lg shadow-lg">
      {{ message }}
    </p>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getUsers, createUser, updateUser, changePassword, deleteUser } from '../../api'
import { encryptPassword } from '../../utils/crypto'

const users = ref([])
const showAddUser = ref(false)
const newUser = ref({ username: '', email: '', password: '', role: 'admin' })
const editingUser = ref(null)
const changingPassword = ref(false)
const currentPasswordUserId = ref(null)
const newPassword = ref('')
const confirmPassword = ref('')
const passwordError = ref('')
const message = ref('')

onMounted(async () => {
  await loadUsers()
})

async function loadUsers() {
  try {
    const res = await getUsers()
    users.value = res.data.data
  } catch (error) {
    console.error('Failed to load users:', error)
  }
}

async function handleCreateUser() {
  if (!newUser.value.username.trim() || !newUser.value.password.trim()) return
  try {
    await createUser(newUser.value)
    newUser.value = { username: '', email: '', password: '', role: 'admin' }
    showAddUser.value = false
    showMessage('User created')
    await loadUsers()
  } catch (error) {
    console.error('Failed to create user:', error)
  }
}

function startEditUser(user) {
  editingUser.value = { id: user.id, role: user.role }
}

async function handleUpdateUser(id) {
  try {
    await updateUser(id, { role: editingUser.value.role })
    editingUser.value = null
    showMessage('User updated')
    await loadUsers()
  } catch (error) {
    console.error('Failed to update user:', error)
  }
}

function showChangePassword(userId) {
  currentPasswordUserId.value = userId
  changingPassword.value = true
  newPassword.value = ''
  confirmPassword.value = ''
  passwordError.value = ''
}

async function handleChangePassword() {
  if (!newPassword.value.trim()) {
    passwordError.value = 'Password cannot be empty'
    return
  }
  if (newPassword.value !== confirmPassword.value) {
    passwordError.value = 'Passwords do not match'
    return
  }
  try {
    const encryptedPassword = await encryptPassword(newPassword.value)
    await changePassword(currentPasswordUserId.value, { new_password: encryptedPassword })
    cancelChangePassword()
    showMessage('Password changed')
  } catch (error) {
    console.error('Failed to change password:', error)
  }
}

function cancelChangePassword() {
  changingPassword.value = false
  currentPasswordUserId.value = null
  newPassword.value = ''
  confirmPassword.value = ''
  passwordError.value = ''
}

async function handleDeleteUser(id) {
  if (!confirm('Delete this user? This action cannot be undone.')) return
  try {
    await deleteUser(id)
    showMessage('User deleted')
    await loadUsers()
  } catch (error) {
    console.error('Failed to delete user:', error)
  }
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
