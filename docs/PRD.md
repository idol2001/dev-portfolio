# 产品需求文档 (PRD) — Jacob Lee Developer Portfolio

> **版本**: v1.3  
> **创建日期**: 2026-04-10  
> **更新日期**: 2026-04-10  
> **作者**: Hermes  
> **项目路径**: `/Users/jacob/Projects/JacobLee/dev-portfolio/`  
> **数据源**: `docs/dev-portfolio.sql`（真实库表结构）

---

## 1. 项目概述

### 1.1 项目定位

Jacob Lee 的个人开发者作品集网站，用于在线展示技术能力、项目经验和博客文章。包含前台展示网站和后台管理系统两部分。

### 1.2 目标用户

| 用户类型 | 说明 |
|---------|------|
| 访客 | 潜在雇主、技术同行、合作伙伴，浏览作品和能力展示 |
| 管理员（Jacob） | 维护个人信息、更新技能、管理项目和博客、管理后台用户 |

### 1.3 核心价值

- **个人品牌展示**：通过专业设计和动效展示个人技术身份
- **项目作品集**：结构化展示已完成项目，附 GitHub 仓库和在线 Demo 链接
- **技术博客**：用 Markdown 写作，支持代码高亮、图表、公式，体现技术深度
- **可维护性**：后台管理系统支持快速更新内容

---

## 2. 功能需求

### 2.1 前台展示（公开访问，无需登录）

#### 2.1.1 首页 (Home)

- 全屏 Hero 区域：展示姓名（来自 `profile_infos.name`）
- **多条 Roles 动效滚动**：从 `profile_infos.roles` 读取，以符合 Coder 人设的方式（如终端打字机效果、命令行风格）逐条滚动展示多个身份标签
- **社交链接图标**：从 `profile_socials` 表读取，按 `order_no` 排序展示（GitHub、LinkedIn、Twitter、个人网站等），放在 Hero 区域醒目位置
- 导航栏：固定顶部，从 `profile_nav_bars` 读取菜单项
- ~~行动按钮：View Projects、About Me~~（已移除）

#### 2.1.2 关于我 (About)

- **长文字自我介绍**：从 `profile_infos.about` 读取，支持 Markdown 渲染
- **配图**：从 `profile_infos.image_source` 读取，展示在介绍旁边
- Logo/头像：从 `profile_infos.logo` 读取，按 `logo_width`/`logo_height` 渲染
- ~~社交链接（已移至首页）~~

#### 2.1.3 技能展示 (Skills)

- **网格布局展示**：从 `profile_skill_groups` + `profile_skills` 读取
- 按分类分组
- 每个技能卡片：**图标（`skill_icon`）+ 名称（`skill_title`）**
- 响应式网格：不限制列数，以网页内容 container 区域能放下为准
- 图标尺寸：75x75，设计合适的间隔

#### 2.1.4 项目展示 (Projects)

- 项目卡片列表（封面图、标题、描述、技术栈标签）
- 从 `profile_projects` 查询 `status = 'published'` 的项目
- 每个项目显示 GitHub 仓库链接和在线 Demo 链接
- 按 `order_no` 排序
- 支持点击展开查看详情

#### 2.1.5 博客列表 (Blogs)

- 博客文章卡片列表（封面图、标题、摘要、发布时间、标签）
- 从 `blog_posts` 查询 `status = 'published'` 的文章
- 分页浏览（默认每页 10 条）
- 点击标题跳转至博客详情

#### 2.1.6 博客详情 (Blog Detail)

- 按 `slug` 访问文章
- 展示标题、发布时间、标签、阅读次数
- **Markdown 渲染**（`content` 字段为 longtext Markdown 格式），支持：
  - ✅ **代码块语法高亮**
  - ✅ **Mermaid 图表**
  - ✅ **LaTeX 数学公式**（行内 `$...$` / 块级 `$$...$$`）
  - ✅ 标准 Markdown 语法
- 阅读数（`view_count`）自动 +1

### 2.2 认证系统

#### 2.2.1 登录

- 用户名 + 密码登录
- JWT Token 认证（有效期 24 小时）
- Token 存储于 localStorage
- 登录成功跳转后台管理

#### 2.2.2 ~~注册~~（已移除/受限）

- ❌ **不对外开放注册功能**
- 管理员用户仅通过后台管理创建或通过 SQL 脚本初始化
- 注册 API（`POST /auth/register`）在生产环境应仅允许本地访问，作为忘记密码的备用方案

#### 2.2.3 认证保护

- 后台管理路由（/admin/**）需登录访问
- 未登录自动跳转登录页
- Token 过期（401）自动清除并跳转登录
- 已登录访问 /login 自动跳转后台

### 2.3 后台管理（需登录）

#### 2.3.1 管理面板布局

- 左侧导航栏（Dashboard / Users / Profile / Skills / Blogs / Projects）
- 显示当前登录用户信息
- 支持登出和返回前台

#### 2.3.2 个人资料管理 (Profile)

- 编辑 `profile_infos`：
  - `name`（姓名）
  - `roles`（多条身份标语，用于首页打字机效果，支持换行或 JSON 数组格式输入）
  - `about`（自我介绍，支持 Markdown）
  - `image_source`（About 页配图 URL）
  - `logo`（Logo/头像 URL）
  - `logo_width` / `logo_height`（Logo 尺寸）
- 社交链接管理（`profile_socials` 表 CRUD：network、href、order_no）
- 导航菜单管理（`profile_nav_bars` 表 CRUD：title、href、order_no）
- 保存按钮，成功提示

#### 2.3.3 用户管理 (Users)

- `users` 表管理
- 新增用户：用户名、密码、角色、昵称、头像、邮箱
- 修改密码
- 删除用户（保留至少一个管理员）
- ❌ 不提供注册入口，仅后台管理

#### 2.3.4 技能管理 (Skills)

- 技能分类 CRUD（`profile_skill_groups`）
- 技能项 CRUD（`profile_skills`：图标上传 + 名称）
- 网格预览效果

#### 2.3.5 项目管理 (Projects)

- `profile_projects` 表管理
- 项目列表表格（标题、排序号、发布状态、操作）
- 新增/编辑项目表单：标题、描述、技术栈标签（JSON 数组）、Repo URL、Demo URL
- **封面图上传（阿里云 OSS）**
- 排序值设置（`order_no`）
- 发布/下架切换（`status`: draft / published）
- 删除确认

#### 2.3.6 博客管理 (Blogs)

- `blog_posts` 表管理
- 博客列表：标题、状态（draft/published）、发布时间（Unix 时间戳）、阅读数
- 新增/编辑：
  - 标题、Slug
  - 摘要（`summary`）
  - **Markdown 编辑器**（`content` 字段，支持实时预览、粘贴 Markdown）
  - 编辑器内上传图片自动上传至阿里云 OSS，并记录到 `blog_attachments` 表
  - 封面图上传（OSS）
  - 标签（`tags`，逗号分隔）
  - 状态切换（`status`: draft / published）
  - 作者 ID（`author_id`，默认当前登录用户）
- 删除文章时级联删除关联的 OSS 附件
- 删除确认

---

## 3. 数据模型

> **重要**：严格以 `docs/dev-portfolio.sql` 导出的实际表结构为准。不再沿用旧版 GORM Model 定义。

### 3.1 用户表 (users)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |
| deleted_at | datetime | 软删除时间 |
| username | varchar(64) | 用户名（唯一，NOT NULL） |
| password | varchar(256) | 密码（bcrypt，NOT NULL） |
| nickname | varchar(128) | 昵称 |
| avatar | varchar(512) | 头像 URL |
| email | varchar(128) | 邮箱 |
| role | varchar(32) | 角色（默认 'admin'） |

### 3.2 个人资料表 (profile_infos)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at / updated_at / deleted_at | datetime | GORM 时间字段 |
| name | varchar(256) | 姓名（首页 Hero 展示） |
| **roles** | varchar(256) | 多条身份标签，**JSON 数组格式**（如 `["Full-Stack Developer","Mobile Engineer"]`），首页打字机动效循环播放 |
| about | varchar(4096) | 自我介绍（About 页，支持 Markdown） |
| **image_source** | varchar(1024) | About 页配图 URL |
| logo | varchar(1024) | Logo/头像 URL |
| logo_height | bigint | Logo 高度 |
| logo_width | bigint | Logo 宽度 |

### 3.3 社交链接表 (profile_socials) ⭐

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at / updated_at / deleted_at | datetime | 时间字段 |
| network | varchar(256) | 平台名称（GitHub/LinkedIn/Twitter等） |
| href | varchar(1024) | 跳转链接 |
| order_no | bigint | 排序号 |

### 3.4 导航菜单表 (profile_nav_bars) ⭐

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at / updated_at / deleted_at | datetime | 时间字段 |
| title | varchar(256) | 菜单显示文本 |
| href | varchar(256) | 跳转链接 |
| order_no | bigint | 排序号 |

### 3.5 技能分类表 (profile_skill_groups)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at / updated_at / deleted_at | datetime | 时间字段 |
| skill_group_title | varchar(256) | 分类名称 |

### 3.6 技能项表 (profile_skills)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at / updated_at / deleted_at | datetime | 时间字段 |
| skill_group_id | bigint unsigned | 外键关联 `profile_skill_groups.id` |
| skill_icon | varchar(256) | 图标 URL/路径 |
| skill_title | varchar(256) | 技能名称 |

### 3.7 项目表 (profile_projects)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at / updated_at / deleted_at | datetime | GORM 时间字段 |
| title | varchar(256) | 项目标题（NOT NULL） |
| description | longtext | 项目描述 |
| tech_stack | text | 技术栈（JSON 数组字符串） |
| repo_url | varchar(512) | 仓库 URL |
| demo_url | varchar(512) | 在线 Demo URL |
| cover_image | varchar(512) | 封面图 URL（OSS） |
| order_no | bigint | 排序号（默认 0） |
| status | varchar(32) | 状态（`'draft'` / `'published'`，默认 published） |

### 3.8 博客文章表 (blog_posts)

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at / updated_at / deleted_at | datetime | 时间字段 |
| title | varchar(256) | 文章标题（NOT NULL） |
| slug | varchar(256) | URL 标识（唯一，NOT NULL） |
| summary | varchar(512) | 文章摘要 |
| content | longtext | 文章内容（**Markdown 格式**） |
| cover_image | varchar(512) | 封面图 URL（OSS） |
| author_id | bigint unsigned | 作者 ID（NOT NULL） |
| **status** | varchar(32) | 状态（`'draft'` / `'published'`，默认 draft） |
| tags | varchar(512) | 标签（逗号分隔） |
| published_at | bigint | 发布时间（Unix 时间戳） |
| view_count | bigint | 浏览次数（默认 0） |

### 3.9 博客附件表 (blog_attachments) ⭐

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint unsigned | 自增主键 |
| created_at / updated_at / deleted_at | datetime | 时间字段 |
| post_id | bigint unsigned | 所属文章 ID（外键关联 `blog_posts.id`） |
| oss_key | varchar(512) | OSS 对象 Key |
| oss_url | varchar(512) | OSS 访问 URL |
| file_name | varchar(256) | 原始文件名 |
| file_size | bigint | 文件大小（字节，默认 0） |
| file_type | varchar(64) | MIME 类型（image/png, image/jpeg 等） |

> **设计说明**：Markdown 编辑器上传图片时，后端上传至阿里云 OSS 并同时写入此表建立文章 ↔ 附件关联。删除文章时可级联清理 OSS 文件，避免孤儿文件。

---

## 4. API 接口清单

> 基础路径：`/dev-portfolio/v1/`

### 4.1 公开接口（无需认证）

| 方法 | 路径 | 说明 | 数据源 |
|------|------|------|--------|
| GET | `/profile/info` | 获取个人资料 | `profile_infos` |
| GET | `/profile/socials` | 获取社交链接 | `profile_socials` |
| GET | `/profile/navbar` | 获取导航菜单 | `profile_nav_bars` |
| GET | `/profile/skills` | 获取技能列表（含分类） | `profile_skill_groups` + `profile_skills` |
| GET | `/projects` | 获取项目列表（status='published'） | `profile_projects` |
| GET | `/blogs` | 获取博客列表（status='published'，分页） | `blog_posts` |
| GET | `/blogs/slug/:slug` | 根据 slug 获取博客详情 | `blog_posts` |

### 4.2 受保护接口（需 JWT 认证）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/auth/login` | 用户登录 |
| GET | `/user/me` | 获取当前用户信息 |
| PUT | `/profile/info` | 更新个人资料 |
| GET/POST/PUT/DELETE | `/profile/socials[/:id]` | 社交链接管理 |
| GET/POST/PUT/DELETE | `/profile/navbar[/:id]` | 导航菜单管理 |
| GET/POST/PUT/DELETE | `/projects[/:id]` | 项目管理 | `profile_projects` |
| GET/POST/PUT/DELETE | `/blogs[/:id]` | 博客管理 |
| GET/POST/PUT/DELETE | `/users[/:id]` | 用户管理 |
| POST | `/upload/:type` | 文件上传（阿里云 OSS） |

### 4.3 ~~已废弃接口~~

| 方法 | 路径 | 说明 |
|------|------|------|
| ~~POST~~ | ~~`/auth/register`~~ | 生产环境仅允许本地访问（备用恢复密码） |

### 4.4 统一响应格式

```json
{
  "request_id": "uuid",
  "code": 0,
  "data": {},
  "msg": "操作成功",
  "total": 100
}
```

---

## 5. 非功能需求

| 类别 | 要求 |
|------|------|
| 部署 | Docker Compose 一键启动（MySQL + API + Web） |
| 响应式 | 前台支持桌面和移动端访问 |
| 安全 | 密码 bcrypt 加密、JWT 认证、CORS 配置、**不对外开放注册** |
| 日志 | 结构化日志（slog），支持文件轮转 |
| 性能 | Gzip 压缩、博客分页加载、Markdown 渲染缓存 |
| 可用性 | 服务自动重启（restart: always） |
| Markdown 渲染 | 支持代码高亮、Mermaid 图表、LaTeX 数学公式 |

---

## 6. 初始数据

系统通过 `init.sql` 预置以下初始数据（需对齐新表结构）：

- **1 条个人资料**：`profile_infos`（name, roles 数组/多行, about, logo 等）
- **社交链接**：`profile_socials`（GitHub/LinkedIn/Twitter 等）
- **导航菜单**：`profile_nav_bars`（Home/About/Skills/Projects/Blogs）
- **3 个技能分类** + **18 个技能项**
- **1 个管理员用户**：admin / admin123
- **示例博客**：`blog_posts`（status='published', content 为 Markdown）
- **示例项目**：`projects`（status='published'，tech_stack 为 JSON 数组）
