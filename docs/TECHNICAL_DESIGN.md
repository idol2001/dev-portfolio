# 技术设计方案 — Jacob Lee Developer Portfolio

> **版本**: v1.3  
> **创建日期**: 2026-04-10  
> **更新日期**: 2026-04-10  
> **作者**: Hermes  
> **项目路径**: `/Users/jacob/Projects/JacobLee/dev-portfolio/`  
> **数据源**: `docs/dev-portfolio.sql`（真实库表结构）

---

## 1. 整体架构

### 1.1 架构模式

**前后端分离 + 容器化部署**

```
┌──────────────┐    HTTP/REST     ┌──────────────┐    TCP     ┌───────────────┐
│  Frontend    │ ───────────────▶ │   Backend    │ ────────▶  │    MySQL      │
│  Vue 3       │                  │   Go + Gin   │           │    8.4.6      │
│  Vite + Nginx│ ◀─────────────── │   GORM       │ ◀──────── │ dev-portfolio │
│  :3000       │                  │   :8080      │           │   :3306       │
└──────────────┘                  └──────────────┘           └───────────────┘
```

### 1.2 服务间通信

| 方向 | 协议 | 说明 |
|------|------|------|
| 前端 → 后端 | HTTP/REST | Axios，baseURL `/dev-portfolio/v1` |
| 后端 → MySQL | TCP | GORM，连接配置来自 `configs/config.se.yml` |
| 前端 ↔ 用户 | HTTPS（生产） | Nginx 静态服务 + SSL |

---

## 2. 数据库设计（以实际 SQL 为准）

> **重要**：严格沿用 `docs/dev-portfolio.sql` 导出的 7 张表结构。GORM Model 必须与这些表对齐。

### 2.1 表清单

| 表名 | 说明 | GORM Model 路径 | 状态 |
|------|------|-----------------|------|
| `users` | 用户表（管理员） | `models/user.go` | ✅ 存在 |
| `profile_infos` | 个人资料（姓名/roles/about/logo等） | `models/profile_info.go` | ⭐ 需对齐 |
| `profile_socials` | 社交链接 | `models/profile_social.go` | ⭐ 需对齐 |
| `profile_nav_bars` | 导航菜单 | `models/profile_nav_bar.go` | ⭐ 需对齐 |
| `profile_skill_groups` | 技能分类 | `models/profile/profile.go` | ⚠️ 需微调字段 |
| `profile_skills` | 技能项 | `models/profile/profile.go` | ⚠️ 需微调字段 |
| `blog_posts` | 博客文章 | `models/blog.go` | ⚠️ 需对齐字段 |
| `blog_attachments` | 博客附件 | `models/blog_attachment.go` | ⭐ 需新建 |
| `profile_projects` | 项目作品 | `models/project.go` | ⭐ 需创建（表名改为 profile_projects） |

> 表 `profile_projects` 和 `blog_attachments` 的建表 SQL 需通过 AutoMigrate 创建。

### 2.2 关键字段变化对照

| 旧设计 (GORM 代码) | 新实际表结构 (`dev-portfolio.sql`) | 影响 |
|-------------------|-----------------------------------|------|
| `profiles` 表 | `profile_infos` 表，字段改为 `name`, `roles`（JSON数组）, `about`, `image_source`, `logo` 等 | Profile Handler 需重写 |
| 社交链接硬编码在 profile 中 | `profile_socials` 独立表（network/href/order_no） | 需新增 CRUD |
| 导航硬编码在前端 | `profile_nav_bars` 独立表（title/href/order_no） | 需新增 API + 前端动态读取 |
| `blog_posts.excerpt` | `blog_posts.summary` | 字段名变更 |
| `blog_posts.published` (bool) | `blog_posts.status` (varchar: 'draft'/'published') | 查询条件需改 |
| `blog_posts.published_at` (datetime) | `blog_posts.published_at` (bigint Unix 时间戳) | 类型变更，序列化需处理 |
| 无作者关联 | `blog_posts.author_id` (bigint, NOT NULL) | 创建博客需关联当前用户 |
| 原 Go 代码有 projects 表 | `projects` 表需通过 AutoMigrate 创建 | Model/Handler/Service 对齐新字段 |

### 2.3 数据库配置

配置来源：`dev-portfolio-api/configs/config.se.yml`

```yaml
mysql:
  username: dev-portfolio
  password: WpwWjBwiT7jsMM6f
  database: dev-portfolio
  host: 192.168.0.31
  port: 3306
  query: charset=utf8mb4&parseTime=True&loc=Local&timeout=10000ms
```

---

## 3. 后端架构设计

### 3.1 目录结构（调整后）

```
dev-portfolio-api/
├── main.go
├── configs/config.se.yml
├── initialize/
│   ├── config.go
│   ├── logger.go
│   ├── mysql.go
│   └── router.go
├── api/
│   ├── handlers/
│   │   ├── auth_handler.go        # Login（注册保留为本地备用）
│   │   ├── profile_handler.go     # profile_infos / socials / nav_bars / skills
│   │   ├── blog_handler.go        # Blogs CRUD（status 过滤, author_id 自动填充）
│   │   └── user_handler.go        # ⭐ 新增：Users 管理
│   └── routes/
│       └── profile.go             # 路由注册
├── internal/
│   └── services/
│       ├── auth_service.go
│       ├── profile_service.go     # 对齐 profile_infos / socials / nav_bars
│       ├── blog_service.go        # 对齐 status 枚举 + published_at Unix 时间戳
│       └── user_service.go        # ⭐ 新增
├── models/
│   ├── model.go                   # BaseModel (ID/CreatedAt/UpdatedAt/DeletedAt)
│   ├── user.go                    # 对齐实际 users 表
│   ├── profile_info.go            # ⭐ 新增：对应 profile_infos
│   ├── profile_social.go          # ⭐ 新增：对应 profile_socials
│   ├── profile_nav_bar.go         # ⭐ 新增：对应 profile_nav_bars
│   ├── profile/
│   │   └── profile.go             # ProfileSkillGroup + ProfileSkill
│   ├── project.go                 # profile_projects 表
│   ├── blog.go                    # 对齐 blog_posts（status string, published_at int64）
│   ├── blog_attachment.go         # ⭐ 新增：blog_attachments 表（OSS 附件关联）
│   └── resp.go                    # 统一响应
├── middleware/
│   ├── jwt.go
│   ├── access_log.go
│   └── exception.go
└── pkg/global/
```

### 3.2 GORM Model 对齐要点

#### 3.2.1 ProfileInfo

```go
type ProfileInfo struct {
    Model // ID, CreatedAt, UpdatedAt, DeletedAt
    Name        string `gorm:"size:256" json:"name"`
    Roles       string `gorm:"size:256" json:"roles"`           // 多条标语，JSON 数组格式，如 ["Full-Stack Dev","Mobile Engineer"]
    About       string `gorm:"size:4096" json:"about"`
    ImageSource string `gorm:"size:1024" json:"image_source"`
    Logo        string `gorm:"size:1024" json:"logo"`
    LogoHeight  int64  `json:"logo_height"`
    LogoWidth   int64  `json:"logo_width"`
}
func (ProfileInfo) TableName() string { return "profile_infos" }
```

#### 3.2.2 ProfileSocial

```go
type ProfileSocial struct {
    Model
    Network string `gorm:"size:256" json:"network"`
    Href    string `gorm:"size:1024" json:"href"`
    OrderNo int64  `json:"order_no"`
}
func (ProfileSocial) TableName() string { return "profile_socials" }
```

#### 3.2.3 BlogPost

```go
type BlogPost struct {
    Model
    Title       string `gorm:"size:256;not null" json:"title"`
    Slug        string `gorm:"size:256;uniqueIndex;not null" json:"slug"`
    Summary     string `gorm:"size:512" json:"summary"`
    Content     string `gorm:"type:longtext" json:"content"`              // Markdown
    CoverImage  string `gorm:"size:512" json:"cover_image"`
    AuthorID    uint64 `gorm:"not null" json:"author_id"`
    Status      string `gorm:"size:32;default:draft" json:"status"`       // draft / published
    Tags        string `gorm:"size:512" json:"tags"`
    PublishedAt *int64 `json:"published_at"`                              // Unix 时间戳
    ViewCount   int64  `gorm:"default:0" json:"view_count"`
}
func (BlogPost) TableName() string { return "blog_posts" }
```

#### 3.2.4 Project

```go
type Project struct {
    Model
    Title       string `gorm:"size:256;not null" json:"title"`
    Description string `gorm:"type:longtext" json:"description"`
    TechStack   string `gorm:"type:text" json:"tech_stack"`         // JSON 数组
    RepoURL     string `gorm:"size:512" json:"repo_url"`
    DemoURL     string `gorm:"size:512" json:"demo_url"`
    CoverImage  string `gorm:"size:512" json:"cover_image"`         // OSS URL
    OrderNo     int64  `gorm:"default:0;index" json:"order_no"`
    Status      string `gorm:"size:32;default:published" json:"status"`  // draft / published
}
func (Project) TableName() string { return "profile_projects" }
```

#### 3.2.5 BlogAttachment

```go
type BlogAttachment struct {
    Model
    PostID   uint64 `gorm:"index" json:"post_id"`                  // 所属文章 ID
    OSSKey   string `gorm:"size:512;not null" json:"oss_key"`      // OSS 对象 Key
    OSSURL   string `gorm:"size:512;not null" json:"oss_url"`      // OSS 访问 URL
    FileName string `gorm:"size:256" json:"file_name"`             // 原始文件名
    FileSize int64  `gorm:"default:0" json:"file_size"`            // 文件大小（字节）
    FileType string `gorm:"size:64" json:"file_type"`              // MIME 类型
}
func (BlogAttachment) TableName() string { return "blog_attachments" }
```

### 3.3 路由设计

```
/dev-portfolio/v1/
├── auth/
│   └── POST /login
│
├── [Public] 公开路由
│   ├── GET  /profile/info          → profile_infos
│   ├── GET  /profile/socials       → profile_socials
│   ├── GET  /profile/navbar        → profile_nav_bars
│   ├── GET  /profile/skills        → profile_skill_groups + profile_skills
│   ├── GET  /projects              → profile_projects (status='published')
│   ├── GET  /blogs                 → blog_posts (status='published', 分页)
│   └── GET  /blogs/slug/:slug      → blog_posts (by slug, view_count++)
│
└── [Protected] JWTAuth()
    ├── GET  /user/me
    ├── profile/info        PUT     # 更新 profile_infos
    ├── profile/socials     CRUD    # 社交链接管理
    ├── profile/navbar      CRUD    # 导航菜单管理
    ├── projects            CRUD    # profile_projects 表, status 管理, order_no 排序
    ├── blogs               CRUD    # status 管理, author_id 自动注入
    └── users               CRUD    # 用户管理 + 改密码
```

### 3.4 关键依赖

| 依赖 | 用途 |
|------|------|
| github.com/gin-gonic/gin | HTTP 框架 |
| gorm.io/gorm | ORM（严格对齐现有表） |
| github.com/golang-jwt/jwt/v5 | JWT 认证 |
| golang.org/x/crypto/bcrypt | 密码加密 |
| github.com/spf13/viper | 配置加载 |
| github.com/samber/slog-gin | 日志 |
| github.com/gin-contrib/cors | 跨域 |

---

## 4. 前端架构设计

### 4.1 目录结构

```
dev-portfolio-web/
├── src/
│   ├── api/index.js           # Axios 实例 + API 函数
│   ├── stores/auth.js         # Pinia 认证 Store
│   ├── components/
│   │   ├── TypingEffect.vue   # 首页 Roles 打字机动效
│   │   ├── SocialLinks.vue    # 首页社交链接（从 API 读取）
│   │   ├── SkillGrid.vue      # 技能网格（75x75 图标）
│   │   ├── MarkdownRenderer.vue  # Markdown 渲染（高亮+Mermaid+KaTeX）
│   │   └── MarkdownEditor.vue    # 后台 Markdown 编辑器（md-editor-v3）
│   └── views/
│       ├── Home.vue           # Hero + TypingEffect + SocialLinks
│       ├── About.vue          # About (Markdown) + image_source 配图
│       ├── Skills.vue         # 技能网格展示
│       ├── Projects.vue       # 项目展示
│       ├── Blogs.vue          # 博客列表
│       ├── BlogDetail.vue     # Markdown 渲染详情
│       ├── Login.vue
│       └── admin/
│           ├── Dashboard.vue
│           ├── Profile.vue    # profile_infos + socials + nav_bars 管理
│           ├── Users.vue      # 用户管理
│           ├── Skills.vue     # 技能管理
│           ├── Projects.vue   # 项目管理
│           └── Blogs.vue      # 博客管理（Markdown 编辑器）
```

### 4.2 前端关键改动

| 模块 | 旧设计 | 新设计（对齐 DB） |
|------|--------|------------------|
| 首页标语 | 硬编码或单条 slogan | 从 `/profile/info` 读取 `roles`，TypingEffect 组件循环播放 |
| 社交链接 | profile 表中的字段 | `/profile/socials` API，按 `order_no` 排序渲染 |
| 导航菜单 | 前端硬编码 | `/profile/navbar` API，动态渲染 |
| About 页 | 固定内容 | 从 `/profile/info` 读取 `about` + `image_source` |
| 博客状态 | `published: true/false` | `status: 'draft' \| 'published'` |
| 博客时间 | datetime 字符串 | Unix 时间戳（bigint），前端需格式化 |
| 博客作者 | 无 | `author_id`，创建时自动取当前登录用户 ID |

### 4.3 Markdown 方案（开源免费）

| 场景 | 方案 | 说明 |
|------|------|------|
| 后台编辑 | **md-editor-v3** | Vue 3 原生，内置 Mermaid/KaTeX/代码高亮，MIT 协议 |
| 图片上传 | md-editor-v3 `@uploadImage` 事件 → 后端上传至阿里云 OSS → 写入 `blog_attachments` 表 → 返回 OSS URL 给编辑器 |
| 前台渲染 | **markdown-it** + 插件 | `markdown-it` + `markdown-it-katex` + `highlight.js` + `mermaid` |
| 安全防护 | **DOMPurify** | 渲染后 HTML 过滤，防止 XSS |

---

## 5. 部署架构

### 5.1 Docker Compose

```yaml
services:
  mysql:
    image: mysql:8.4  # 与 SQL 导出版本对齐
    environment: MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD
    volumes: mysql-data, ./init.sql

  api:
    build: ./dev-portfolio-api
    ports: 8080:8080
    depends_on: mysql

  web:
    build: ./dev-portfolio-web
    ports: 3000:80
    depends_on: api
```

---

## 6. 安全注意事项

| 风险 | 现状 | 建议 |
|------|------|------|
| JWT 密钥硬编码 | ⚠️ 默认密钥 | 生产环境用环境变量 `JWT_SECRET` |
| 注册接口 | 可公开访问 | 限制为仅本地 IP 访问（备用恢复密码） |
| 密码加密 | ✅ bcrypt | 已达标 |
| SQL 注入 | ✅ GORM 参数化 | 已防护 |
| Markdown XSS | ⚠️ `v-html` 直接渲染 | 必须用 DOMPurify 过滤 |
| 文件上传 | ❌ 未实现 | 白名单 + 大小限制 + 随机文件名 |
| `published_at` 类型 | Unix 时间戳 (bigint) | 后端序列化时转为 ISO 8601 字符串返回给前端 |
| OSS 配置泄露 | ⚠️ AccessKey/Secret 硬编码 | 使用环境变量 `ALIYUN_OSS_ACCESS_KEY` / `ALIYUN_OSS_SECRET_KEY` |
| 孤儿 OSS 文件 | 删除文章后附件残留 | 通过 `blog_attachments` 表级联删除，或定期扫描清理 |
