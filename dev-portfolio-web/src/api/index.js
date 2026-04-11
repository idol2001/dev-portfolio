import axios from 'axios'

const api = axios.create({
  baseURL: '/dev-portfolio/v1',
  timeout: 10000
})

// 请求拦截器 - 添加 Token
api.interceptors.request.use(
  config => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器 - 处理 Token 过期
api.interceptors.response.use(
  response => response,
  error => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// 认证
export const login = (username, password) => api.post('/auth/login', { username, password })
export const getCurrentUser = () => api.get('/user/me')

// 个人资料
export const getProfile = () => api.get('/profile/info')
export const updateProfile = (data) => api.put('/profile/info', data)

// 社交链接
export const getSocials = () => api.get('/profile/socials')
export const createSocial = (data) => api.post('/profile/socials', data)
export const updateSocial = (id, data) => api.put(`/profile/socials/${id}`, data)
export const deleteSocial = (id) => api.delete(`/profile/socials/${id}`)

// 导航菜单
export const getNavBars = () => api.get('/profile/navbar')
export const createNavBar = (data) => api.post('/profile/navbar', data)
export const updateNavBar = (id, data) => api.put(`/profile/navbar/${id}`, data)
export const deleteNavBar = (id) => api.delete(`/profile/navbar/${id}`)

// 技能（公开）
export const getSkills = () => api.get('/profile/skills')

// 技能管理
export const getSkillGroups = () => api.get('/skills')
export const createSkillGroup = (data) => api.post('/skills/groups', data)
export const updateSkillGroup = (id, data) => api.put(`/skills/groups/${id}`, data)
export const deleteSkillGroup = (id) => api.delete(`/skills/groups/${id}`)
export const getSkillItems = (groupId) => api.get(`/skills/groups/${groupId}/items`)
export const createSkillItem = (groupId, data) => api.post(`/skills/groups/${groupId}/items`, data)
export const updateSkillItem = (id, data) => api.put(`/skills/items/${id}`, data)
export const deleteSkillItem = (id) => api.delete(`/skills/items/${id}`)

// 项目
export const getProjects = (published = true) => api.get('/projects', { params: { published } })
export const getProject = (id) => api.get(`/projects/${id}`)
export const createProject = (data) => api.post('/projects', data)
export const updateProject = (id, data) => api.put(`/projects/${id}`, data)
export const deleteProject = (id) => api.delete(`/projects/${id}`)

// 博客
export const getBlogPosts = (page = 1, pageSize = 10, published = true) => 
  api.get('/blogs', { params: { page, pageSize, published } })
export const getBlogPostBySlug = (slug) => api.get(`/blogs/slug/${slug}`)
export const getBlogPost = (id) => api.get(`/blogs/${id}`)
export const createBlogPost = (data) => api.post('/blogs', data)
export const updateBlogPost = (id, data) => api.put(`/blogs/${id}`, data)
export const deleteBlogPost = (id) => api.delete(`/blogs/${id}`)

// 用户管理
export const getUsers = () => api.get('/users')
export const createUser = (data) => api.post('/users', data)
export const updateUser = (id, data) => api.put(`/users/${id}`, data)
export const changePassword = (id, data) => api.put(`/users/${id}/password`, data)
export const deleteUser = (id) => api.delete(`/users/${id}`)

// 文件上传
export const uploadFile = (type, file) => {
  const formData = new FormData()
  formData.append('file', file)
  return api.post(`/upload/${type}`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export default api
