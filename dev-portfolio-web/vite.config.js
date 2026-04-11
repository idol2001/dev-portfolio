import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: true,
    port: 3000,
    proxy: {
      '/dev-portfolio': {
        target: 'http://localhost:8080',
        changeOrigin: true
      },
      // Proxy uploaded files (icons, avatars, etc.) to backend
      '/uploads': {
        target: 'http://localhost:8080/dev-portfolio/v1',
        changeOrigin: true
      }
    }
  }
})
