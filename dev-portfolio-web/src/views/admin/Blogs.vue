<template>
  <div class="max-w-6xl mx-auto">
    <div class="flex justify-between items-center mb-6">
      <h1 class="text-2xl font-bold">Blogs Management</h1>
      <button @click="showAddBlog = true" class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
        + Add Blog Post
      </button>
    </div>

    <!-- 添加/编辑博客表单 -->
    <div v-show="showAddBlog || editingBlog" class="bg-white p-6 rounded-lg shadow mb-6">
      <h3 class="font-medium mb-4">{{ editingBlog ? 'Edit Blog Post' : 'New Blog Post' }}</h3>
      <div class="space-y-4">
        <div class="grid grid-cols-2 gap-4">
          <div>
            <label class="block text-sm font-medium mb-1">Title *</label>
            <input v-model="form.title" type="text" class="w-full px-3 py-2 border rounded-lg" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Slug *</label>
            <input v-model="form.slug" type="text" placeholder="my-awesome-post" class="w-full px-3 py-2 border rounded-lg" />
            <p class="text-xs text-gray-400 mt-1">URL-friendly identifier (auto-generated if empty)</p>
          </div>
        </div>

        <div>
          <label class="block text-sm font-medium mb-1">Summary</label>
          <textarea v-model="form.summary" rows="2" class="w-full px-3 py-2 border rounded-lg"></textarea>
        </div>

        <div class="grid grid-cols-3 gap-4">
          <div>
            <label class="block text-sm font-medium mb-1">Status</label>
            <select v-model="form.status" class="w-full px-3 py-2 border rounded-lg">
              <option value="draft">Draft</option>
              <option value="published">Published</option>
            </select>
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Cover Image</label>
            <div class="flex gap-3 items-start">
              <input v-model="form.cover_image" type="url" placeholder="https://..." class="flex-1 px-3 py-2 border rounded-lg text-sm" />
              <label class="cursor-pointer bg-blue-600 text-white px-3 py-2 rounded-lg text-sm hover:bg-blue-700 whitespace-nowrap">
                📁 Upload
                <input type="file" accept="image/jpeg,image/png,image/webp,image/gif" class="hidden" @change="handleCoverUpload" />
              </label>
            </div>
            <img v-if="form.cover_image" :src="form.cover_image" class="mt-2 w-32 h-20 object-cover rounded border" />
          </div>
          <div>
            <label class="block text-sm font-medium mb-1">Tags (comma separated)</label>
            <input v-model="form.tags" type="text" placeholder="Vue, Go, Tutorial" class="w-full px-3 py-2 border rounded-lg" />
          </div>
        </div>

        <div>
          <label class="block text-sm font-medium mb-1">Content (Markdown)</label>
          <div class="border rounded-lg overflow-hidden">
            <MdEditor
              :key="editingBlog || 'new'"
              v-model="form.content"
              :toolbars="[
                'bold', 'underline', 'italic', 'strikeThrough', '-',
                'title', 'sub', 'sup', 'quote', 'unorderedList', 'orderedList', '-',
                'codeRow', 'code', 'link', 'image', 'table', '-',
                'revoke', 'next', 'save', '=',
                'pageFullscreen', 'fullscreen', 'preview', 'htmlPreview', 'catalog'
              ]"
              :on-upload-img="handleEditorImageUpload"
              theme="light"
              :editor-id="'blog-editor'"
              code-theme="stackoverflow"
              style="height: 500px;"
              placeholder="# Write your blog post in Markdown..."
            />
          </div>
        </div>

        <div class="flex gap-2">
          <button @click="editingBlog ? handleUpdateBlog() : handleCreateBlog()" 
                  class="bg-green-600 text-white px-4 py-2 rounded-lg hover:bg-green-700">
            {{ editingBlog ? 'Update' : 'Create' }}
          </button>
          <button @click="cancelForm" class="px-4 py-2 border rounded-lg hover:bg-gray-50">Cancel</button>
        </div>
      </div>
    </div>

    <!-- 博客列表 -->
    <div v-if="blogs.length === 0" class="text-gray-400">No blog posts found.</div>
    <div v-else class="space-y-4">
      <div v-for="blog in blogs" :key="blog.id" class="bg-white rounded-lg shadow p-5">
        <div class="flex justify-between items-start mb-2">
          <div>
            <h3 class="text-lg font-semibold">{{ blog.title }}</h3>
            <p class="text-gray-500 text-sm">/{{ blog.slug }}</p>
          </div>
          <span class="px-2 py-1 text-xs rounded-full"
                :class="blog.status === 'published' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-700'">
            {{ blog.status }}
          </span>
        </div>

        <p class="text-gray-600 text-sm mb-3">{{ truncate(blog.summary || blog.content, 120) }}</p>

        <!-- Tags -->
        <div v-if="blog.tags" class="flex flex-wrap gap-2 mb-3">
          <span v-for="tag in blog.tags.split(',')" :key="tag.trim()" 
                class="px-2 py-1 bg-purple-50 text-purple-600 text-xs rounded">
            {{ tag.trim() }}
          </span>
        </div>

        <div class="flex justify-between items-center">
          <div class="text-xs text-gray-400">
            <span>👁️ {{ blog.view_count || 0 }} views</span>
            <span class="ml-3">📅 {{ formatDate(blog.created_at) }}</span>
            <span v-if="blog.published_at" class="ml-3">🚀 {{ formatTimestamp(blog.published_at) }}</span>
          </div>
          <div class="flex gap-2">
            <button @click="startEditBlog(blog)" class="text-blue-600 text-sm hover:underline">Edit</button>
            <button @click="handleDeleteBlog(blog.id)" class="text-red-600 text-sm hover:underline">Delete</button>
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
import { ref, onMounted } from 'vue'
import { getBlogPosts, createBlogPost, updateBlogPost, deleteBlogPost, uploadFile } from '../../api'
import { MdEditor, config } from 'md-editor-v3'
import mermaid from 'mermaid'
import 'md-editor-v3/lib/style.css'

// 注册 mermaid 实例
config({
  editorExtensions: {
    mermaid: { instance: mermaid }
  }
})

const blogs = ref([])
const showAddBlog = ref(false)
const editingBlog = ref(null)
const message = ref('')

const defaultForm = () => ({
  title: '',
  slug: '',
  summary: '',
  content: '',
  cover_image: '',
  status: 'draft',
  tags: ''
})

const form = ref(defaultForm())

onMounted(async () => {
  await loadBlogs()
})

async function loadBlogs() {
  try {
    const res = await getBlogPosts(1, 100, false)
    // API 返回 { list: [...], total: N }，正确提取 list 数组
    blogs.value = res.data.data?.list || []
  } catch (error) {
    console.error('Failed to load blogs:', error)
    blogs.value = []
  }
}

async function handleCreateBlog() {
  if (!form.value.title.trim()) return
  
  // Auto-generate slug if empty
  if (!form.value.slug.trim()) {
    form.value.slug = form.value.title
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '')
  }
  
  try {
    await createBlogPost(form.value)
    resetForm()
    showMessage('Blog post created')
    await loadBlogs()
  } catch (error) {
    console.error('Failed to create blog:', error)
  }
}

function startEditBlog(blog) {
  editingBlog.value = blog.id
  form.value = {
    id: blog.id,
    title: blog.title,
    slug: blog.slug,
    summary: blog.summary || '',
    content: blog.content || '',
    cover_image: blog.cover_image || '',
    status: blog.status,
    tags: blog.tags || ''
  }
}

async function handleUpdateBlog() {
  if (!form.value.title.trim()) return
  try {
    await updateBlogPost(editingBlog.value, form.value)
    resetForm()
    showMessage('Blog post updated')
    await loadBlogs()
  } catch (error) {
    console.error('Failed to update blog:', error)
  }
}

async function handleEditorImageUpload(files, callback) {
  const uploadedUrls = []
  for (const file of files) {
    try {
      const res = await uploadFile('blog-images', file)
      uploadedUrls.push(res.data.data.url)
    } catch (error) {
      console.error('Failed to upload image:', error)
      uploadedUrls.push('')
    }
  }
  callback(uploadedUrls)
}

async function handleCoverUpload(event) {
  const file = event.target.files[0]
  if (!file) return
  try {
    const res = await uploadFile('blog-images', file)
    form.value.cover_image = res.data.data.url
  } catch (error) {
    console.error('Failed to upload cover image:', error)
    alert('封面图上传失败')
  }
  event.target.value = ''
}

async function handleDeleteBlog(id) {
  if (!confirm('Delete this blog post?')) return
  try {
    await deleteBlogPost(id)
    showMessage('Blog post deleted')
    await loadBlogs()
  } catch (error) {
    console.error('Failed to delete blog:', error)
  }
}

function cancelForm() {
  resetForm()
}

function resetForm() {
  form.value = defaultForm()
  showAddBlog.value = false
  editingBlog.value = null
}

function truncate(str, len) {
  if (!str) return ''
  return str.length > len ? str.substring(0, len) + '...' : str
}

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString()
}

function formatTimestamp(ts) {
  if (!ts) return '-'
  return new Date(ts).toLocaleDateString()
}

function showMessage(msg) {
  message.value = msg
  setTimeout(() => message.value = '', 2000)
}
</script>
