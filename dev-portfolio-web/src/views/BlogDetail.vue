<template>
  <div class="min-h-screen text-white transition-colors duration-300"
       :class="isDark ? 'bg-gradient-to-br from-gray-900 to-gray-800' : 'bg-gradient-to-br from-gray-50 to-white text-gray-900'">
    <AppNav />

    <div class="pt-24 pb-12 px-4 max-w-4xl mx-auto">
      <article v-if="post" class="prose max-w-none"
               :class="isDark ? 'prose-invert' : 'prose-gray'">
        <h1 class="text-4xl font-bold mb-4">{{ post.title }}</h1>
        <div class="flex items-center gap-4 mb-6"
             :class="isDark ? 'text-gray-400' : 'text-gray-500'">
          <span>{{ formatDate(post.created_at) }}</span>
          <span>👁 {{ post.view_count }} views</span>
        </div>

        <!-- Tags -->
        <div v-if="post.tags" class="flex flex-wrap gap-2 mb-8">
          <span v-for="tag in post.tags.split(',')" :key="tag.trim()" 
                class="px-2 py-0.5 text-xs rounded"
                :class="isDark ? 'bg-blue-500/20 text-blue-400' : 'bg-blue-100 text-blue-700'">
            {{ tag.trim() }}
          </span>
        </div>

        <MdPreview
          v-if="post.content"
          :model-value="post.content"
          :theme="isDark ? 'dark' : 'light'"
          :code-foldable="false"
          :code-theme="isDark ? 'stackoverflow' : 'github'"
          class="blog-content prose max-w-none"
          :class="isDark ? 'prose-invert' : 'prose-gray'"
        />
        <p v-else class="italic" :class="isDark ? 'text-gray-500' : 'text-gray-400'">No content yet.</p>
      </article>
      <div v-else class="text-center py-20">
        <p>Loading...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, inject } from 'vue'
import { useRoute } from 'vue-router'
import AppNav from '../components/AppNav.vue'
import { getBlogPostBySlug } from '../api'
import { MdPreview, config } from 'md-editor-v3'
import mermaid from 'mermaid'
import 'md-editor-v3/lib/style.css'

const { isDark } = inject('theme', { isDark: ref(true) })

// Register mermaid instance
config({
  editorExtensions: {
    mermaid: { instance: mermaid }
  }
})

const route = useRoute()
const post = ref(null)

const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

onMounted(async () => {
  try {
    const res = await getBlogPostBySlug(route.params.slug)
    post.value = res.data.data
  } catch (error) {
    console.error('Failed to load blog post:', error)
  }
})
</script>

<style scoped>
/* Container styling for the preview area */
.blog-content {
  padding: 2rem;
  border-radius: 0.75rem;
}
.blog-content {
  background-color: v-bind('isDark ? "rgba(17, 24, 39, 0.6)" : "rgba(255, 255, 255, 0.8)"');
  border: 1px solid v-bind('isDark ? "rgba(255, 255, 255, 0.05)" : "rgba(0, 0, 0, 0.1)"');
}

.blog-content :deep(h1) { @apply text-3xl font-bold mt-8 mb-4; }
.blog-content :deep(h2) { @apply text-2xl font-semibold mt-8 mb-3; }
.blog-content :deep(h3) { @apply text-xl font-semibold mt-6 mb-2; }
.blog-content :deep(p) { @apply leading-relaxed mb-4; }
.blog-content :deep(a) { @apply text-blue-400 hover:underline; }
.blog-content :deep(code) { @apply px-1.5 py-0.5 rounded text-sm; }
.blog-content :deep(pre) { @apply p-4 rounded-lg overflow-x-auto mb-4; }
.blog-content :deep(pre code) { @apply bg-transparent p-0; }
.blog-content :deep(blockquote) { @apply border-l-4 border-blue-500 pl-4 italic my-4; }
.blog-content :deep(img) { @apply rounded-lg max-w-full my-4; }
.blog-content :deep(ul) { @apply list-disc list-inside mb-4; }
.blog-content :deep(ol) { @apply list-decimal list-inside mb-4; }
.blog-content :deep(table) { @apply w-full border-collapse mb-4; }
.blog-content :deep(hr) { @apply my-8; }

/* Dark mode code blocks */
.blog-content :deep(code) {
  background-color: v-bind('isDark ? "#374151" : "#f3f4f6"');
}
.blog-content :deep(pre) {
  background-color: v-bind('isDark ? "#1f2937" : "#f9fafb"');
}
.blog-content :deep(th) {
  @apply px-4 py-2 text-left font-semibold;
  background-color: v-bind('isDark ? "#374151" : "#f3f4f6"');
}
.blog-content :deep(td) {
  @apply px-4 py-2;
  border-color: v-bind('isDark ? "#374151" : "#e5e7eb"');
}
.blog-content :deep(hr) {
  border-color: v-bind('isDark ? "#374151" : "#e5e7eb"');
}
.blog-content :deep(blockquote) {
  color: v-bind('isDark ? "#9ca3af" : "#6b7280"');
}
</style>

<style>
/* Global styles for md-editor-v3 code blocks (non-scoped to ensure they apply) */
.md-editor-code .md-editor-code-flag {
  display: none !important;
}
.md-editor-code-block {
  max-height: none !important;
  overflow-y: visible !important;
}
.md-editor-code pre {
  overflow-x: auto !important;
  overflow-y: hidden !important;
  margin: 0 !important;
}
</style>
