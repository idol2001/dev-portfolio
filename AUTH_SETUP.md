# 认证系统设置指南

## 🔐 认证系统已实现

### 后端功能

#### API 端点
```
POST /dev-portfolio/v1/auth/login      - 用户登录
POST /dev-portfolio/v1/auth/register   - 用户注册
GET  /dev-portfolio/v1/user/me         - 获取当前用户信息
```

#### JWT 认证
- Token 有效期：24 小时
- 使用 Bearer Token 格式
- 自动刷新机制（前端实现）

#### 受保护的 API
以下 API 需要登录后才能访问：
- `PUT /profile/info` - 更新个人资料
- `POST /projects` - 创建项目
- `PUT /projects/:id` - 更新项目
- `DELETE /projects/:id` - 删除项目
- `POST /blogs` - 创建博客
- `PUT /blogs/:id` - 更新博客
- `DELETE /blogs/:id` - 删除博客

#### 公开的 API
以下 API 无需登录即可访问（前台展示用）：
- `GET /profile/info` - 获取个人资料
- `GET /profile/skills` - 获取技能列表
- `GET /projects` - 获取项目列表
- `GET /blogs` - 获取博客列表
- `GET /blogs/slug/:slug` - 获取博客详情

---

### 前端功能

#### 登录页面
- 路径：`/login`
- 功能：用户名密码登录
- Token 自动存储到 localStorage

#### 认证状态管理
- Pinia Store 管理用户状态
- 自动检查 Token 有效性
- Token 过期自动跳转登录

#### 路由守卫
- 管理后台路由需要认证
- 未登录自动跳转到登录页

---

## 🚀 使用指南

### 1. 创建初始管理员用户

#### 方式 1：使用 SQL 脚本
```bash
# 连接到 MySQL
mysql -u root -p dev-portfolio

# 执行脚本
source /Users/jacob/Projects/JacobLee/dev-portfolio/add-admin-user.sql
```

**默认凭据：**
- 用户名：`admin`
- 密码：`admin123`

⚠️ **重要**：首次登录后请立即修改密码！

#### 方式 2：使用注册 API
```bash
curl -X POST http://localhost:8080/dev-portfolio/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "your-password"
  }'
```

### 2. 登录管理后台

1. 访问：http://localhost:3000/login
2. 输入用户名和密码
3. 登录成功后自动跳转到：http://localhost:3000/admin/profile

---

## 🔧 配置说明

### 修改 JWT 密钥

编辑文件：`dev-portfolio-api/middleware/jwt.go`

```go
var jwtKey = []byte("your-secret-key-change-this-in-production")
```

⚠️ **生产环境务必修改为随机字符串！**

### 修改 Token 有效期

编辑文件：`dev-portfolio-api/middleware/jwt.go`

```go
ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
```

可以修改为任意时长，例如：
- `time.Hour` - 1 小时
- `7 * 24 * time.Hour` - 7 天
- `30 * 24 * time.Hour` - 30 天

---

## 📝 后续开发建议

### 1. 密码重置功能
- [ ] 忘记密码页面
- [ ] 邮箱验证
- [ ] 重置密码 API

### 2. 用户管理
- [ ] 修改密码
- [ ] 修改邮箱
- [ ] 头像上传

### 3. 安全性增强
- [ ] 登录失败次数限制
- [ ] IP 白名单
- [ ] 双因素认证 (2FA)

### 4. 权限管理
- [ ] 角色系统（admin, editor, viewer）
- [ ] 基于角色的访问控制 (RBAC)
- [ ] 操作日志记录

---

## 🐛 故障排查

### Token 无效或过期
- 检查浏览器控制台是否有 401 错误
- 清除 localStorage 重新登录
- 检查服务器时间是否同步

### 无法登录
- 确认用户名密码正确
- 检查后端日志
- 确认数据库连接正常

### CORS 错误
- 检查后端 CORS 配置
- 确认前端请求地址正确

---

## 📞 技术支持

如有问题，请查看：
- 后端日志：`dev-portfolio-api/logs/`
- 浏览器控制台错误
- Docker 日志：`docker-compose logs -f api`
