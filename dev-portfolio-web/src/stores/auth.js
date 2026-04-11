import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as apiLogin, getCurrentUser } from '../api'

export const useAuthStore = defineStore('auth', () => {
  const token = ref(localStorage.getItem('token') || '')
  const user = ref(null)
  
  const isAuthenticated = computed(() => !!token.value)
  
  async function login(username, password) {
    try {
      const res = await apiLogin(username, password)
      token.value = res.data.data.token
      user.value = res.data.data.user
      localStorage.setItem('token', token.value)
      return { success: true }
    } catch (error) {
      return { 
        success: false, 
        message: error.response?.data?.msg || '登录失败' 
      }
    }
  }
  
  async function logout() {
    token.value = ''
    user.value = null
    localStorage.removeItem('token')
  }
  
  async function checkAuth() {
    if (!token.value) return
    
    try {
      const res = await getCurrentUser()
      user.value = res.data.data
    } catch (error) {
      // Token 无效，清除
      await logout()
    }
  }
  
  // 初始化时检查认证状态
  if (token.value) {
    checkAuth()
  }
  
  return {
    token,
    user,
    isAuthenticated,
    login,
    logout,
    checkAuth
  }
})
