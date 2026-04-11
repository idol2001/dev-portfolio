# JacobLee Portfolio - 后端 API 接口文档

**版本**: v1.0  
**基础路径**: `/dev-portfolio/v1`  
**技术栈**: Go + Gin + GORM + MySQL 8.0  
**文档更新日期**: 2026-04-09

---

## 📋 目录

1. [认证模块](#认证模块)
2. [个人信息模块](#个人信息模块)
3. [技能管理模块](#技能管理模块)
4. [项目管理模块](#项目管理模块)
5. [博客管理模块](#博客管理模块)
6. [统一响应格式](#统一响应格式)

---

## 🔐 认证模块

### 1.1 用户登录

**接口**: `POST /dev-portfolio/v1/auth/login`

**认证**: ❌ 不需要

**请求参数**:

```json
{
  "username": "admin",
  "password": "admin123"
}
```

**响应示例**:

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "code": 0,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "username": "admin",
      "email": "admin@example.com",
      "role": "admin",
      "avatar": ""
    }
  },
  "msg": "操作成功",
  "total": 0
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| token | string | JWT 令牌，有效期 24 小时 |
| user.id | integer | 用户 ID |
| user.username | string | 用户名 |
| user.email | string | 邮箱 |
| user.role | string | 角色 (admin/user) |
| user.avatar | string | 头像 URL |

---

### 1.2 用户注册

**接口**: `POST /dev-portfolio/v1/auth/register`

**认证**: ❌ 不需要

**请求参数**:

```json
{
  "username": "newuser",
  "password": "password123"
}
```

**响应示例**:

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440001",
  "code": 0,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 2,
      "username": "newuser",
      "email": "",
      "role": "user",
      "avatar": ""
    }
  },
  "msg": "操作成功",
  "total": 0
}
```

---

### 1.3 获取当前用户信息

**接口**: `GET /dev-portfolio/v1/user/me`

**认证**: ✅ 需要 JWT Token

**请求头**:

```
Authorization: Bearer <token>
```

**响应示例**:

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440002",
  "code": 0,
  "data": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "avatar": "https://example.com/avatar.jpg",
    "role": "admin"
  },
  "msg": "操作成功",
  "total": 0
}
```

---

## 👤 个人信息模块

### 2.1 获取个人资料

**接口**: `GET /dev-portfolio/v1/profile/info`

**认证**: ❌ 不需要 (公开访问)

**响应示例**:

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440003",
  "code": 0,
  "data": {
    "id": 1,
    "user_id": 1,
    "full_name": "Jacob Lee",
    "slogan": "Full-Stack Developer",
    "about": "热爱编程，专注 Web 开发...",
    "avatar_url": "https://example.com/avatar.jpg",
    "location": "Shanghai, China",
    "website": "https://jacoblee.info",
    "github": "jacoblee",
    "linkedin": "jacob-lee",
    "twitter": "jacoblee_dev"
  },
  "msg": "操作成功",
  "total": 0
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 资料 ID |
| user_id | integer | 关联用户 ID |
| full_name | string | 全名 |
| slogan | string | 个人标语 |
| about | string | 关于我 (支持 Markdown) |
| avatar_url | string | 头像 URL |
| location | string | 位置 |
| website | string | 个人网站 |
| github | string | GitHub 用户名 |
| linkedin | string | LinkedIn 用户名 |
| twitter | string | Twitter 用户名 |

---

### 2.2 更新个人资料

**接口**: `PUT /dev-portfolio/v1/profile/info`

**认证**: ✅ 需要 JWT Token

**请求头**:

```
Authorization: Bearer <token>
```

**请求参数**:

```json
{
  "full_name": "Jacob Lee",
  "slogan": "Senior Full-Stack Developer",
  "about": "更新后的关于我内容...",
  "avatar_url": "https://example.com/new-avatar.jpg",
  "location": "Beijing, China",
  "website": "https://newwebsite.com",
  "github": "newgithub",
  "linkedin": "newlinkedin",
  "twitter": "newtwitter"
}
```

**响应示例**:

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440004",
  "code": 0,
  "data": {},
  "msg": "更新成功",
  "total": 0
}
```

---

## 🛠️ 技能管理模块

### 3.1 获取技能列表

**接口**: `GET /dev-portfolio/v1/profile/skills`

**认证**: ❌ 不需要 (公开访问)

**响应示例**:

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440005",
  "code": 0,
  "data": [
    {
      "id": 1,
      "skill_group_title": "前端开发",
      "skill_group_items": [
        {
          "id": 1,
          "skill_icon": "https://cdn.example.com/icons/vue.svg",
          "skill_title": "Vue.js"
        },
        {
          "id": 2,
          "skill_icon": "https://cdn.example.com/icons/react.svg",
          "skill_title": "React"
        },
        {
          "id": 3,
          "skill_icon": "https://cdn.example.com/icons/typescript.svg",
          "skill_title": "TypeScript"
        }
      ]
    },
    {
      "id": 2,
      "skill_group_title": "后端开发",
      "skill_group_items": [
        {
          "id": 4,
          "skill_icon": "https://cdn.example.com/icons/go.svg",
          "skill_title": "Go"
        },
        {
          "id": 5,
          "skill_icon": "https://cdn.example.com/icons/nodejs.svg",
          "skill_title": "Node.js"
        }
      ]
    }
  ],
  "msg": "操作成功",
  "total": 0
}
```

**字段说明**:

| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 技能组 ID |
| skill_group_title | string | 技能分类名称 |
| skill_group_items | array | 技能列表 |
| skill_group_items[].id | integer | 技能 ID |
| skill_group_items[].skill_icon | string | **技能图标 URL** (PNG/SVG) |
| skill_group_items[].skill_title | string | 技能名称 |

**⚠️ 技能图标说明**:
- 图标在后台技能管理页面上传
- 支持格式：PNG 或 SVG
- SVG 优先推荐（可缩放，更清晰）
- 图标 URL 由后端返回完整路径

---

## 📁 项目管理模块

### 4.1 获取项目列表

**接口**: `GET /dev-portfolio/v1/projects`

**认证**: ❌ 不需要 (公开访问)

**查询参数**:
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| published | string | true | 是否只返回已发布项目 |

**请求示例**:
```
GET /dev-portfolio/v1/projects?published=true
```

**响应示例**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440006",
  "code": 0,
  "data": [
    {
      "id": 1,
      "title": "电商平台",
      "description": "基于 Vue3 + Go 的全栈电商平台",
      "tech_stack": "[\"Vue3\", \"Go\", \"MySQL\", \"Redis\"]",
      "repo_url": "https://github.com/jacob/ecommerce",
      "demo_url": "https://ecommerce.example.com",
      "cover_image": "https://cdn.example.com/projects/ecommerce.jpg",
      "order": 1,
      "published": true,
      "created_at": "2026-04-08T10:00:00Z",
      "updated_at": "2026-04-08T10:00:00Z"
    }
  ],
  "msg": "操作成功",
  "total": 0
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 项目 ID |
| title | string | 项目标题 |
| description | string | 项目描述 |
| tech_stack | string | 技术栈 (JSON 数组字符串) |
| repo_url | string | 代码仓库 URL |
| demo_url | string | 在线演示 URL |
| cover_image | string | 封面图片 URL |
| order | integer | 排序值 (越小越前) |
| published | boolean | 是否发布 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

---

### 4.2 获取单个项目

**接口**: `GET /dev-portfolio/v1/projects/:id`

**认证**: ✅ 需要 JWT Token

**请求示例**:
```
GET /dev-portfolio/v1/projects/1
```

**响应示例**: 同项目列表中的单个项目对象

---

### 4.3 创建项目

**接口**: `POST /dev-portfolio/v1/projects`

**认证**: ✅ 需要 JWT Token

**请求头**:
```
Authorization: Bearer <token>
```

**请求参数**:
```json
{
  "title": "新项目",
  "description": "项目描述内容",
  "tech_stack": "[\"Vue3\", \"Go\"]",
  "repo_url": "https://github.com/jacob/new-project",
  "demo_url": "https://new-project.example.com",
  "cover_image": "https://cdn.example.com/projects/new.jpg",
  "order": 0,
  "published": true
}
```

**响应示例**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440007",
  "code": 0,
  "data": {},
  "msg": "创建成功",
  "total": 0
}
```

---

### 4.4 更新项目

**接口**: `PUT /dev-portfolio/v1/projects/:id`

**认证**: ✅ 需要 JWT Token

**请求示例**:
```
PUT /dev-portfolio/v1/projects/1
```

**请求参数**: 同创建项目

**响应示例**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440008",
  "code": 0,
  "data": {},
  "msg": "更新成功",
  "total": 0
}
```

---

### 4.5 删除项目

**接口**: `DELETE /dev-portfolio/v1/projects/:id`

**认证**: ✅ 需要 JWT Token

**请求示例**:
```
DELETE /dev-portfolio/v1/projects/1
```

**响应示例**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440009",
  "code": 0,
  "data": {},
  "msg": "删除成功",
  "total": 0
}
```

---

## 📝 博客管理模块

### 5.1 获取博客列表

**接口**: `GET /dev-portfolio/v1/blogs`

**认证**: ❌ 不需要 (公开访问)

**查询参数**:
| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| page | integer | 1 | 页码 |
| pageSize | integer | 10 | 每页数量 |
| published | string | true | 是否只返回已发布文章 |

**请求示例**:
```
GET /dev-portfolio/v1/blogs?page=1&pageSize=10&published=true
```

**响应示例**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440010",
  "code": 0,
  "data": {
    "list": [
      {
        "id": 1,
        "title": "Go 语言并发编程指南",
        "slug": "go-concurrency-guide",
        "excerpt": "本文介绍 Go 语言的并发编程特性...",
        "content": "完整文章内容...",
        "cover_image": "https://cdn.example.com/blog/go-concurrency.jpg",
        "tags": "Go,并发，编程",
        "published": true,
        "published_at": "2026-04-08T10:00:00Z",
        "view_count": 128,
        "created_at": "2026-04-08T10:00:00Z",
        "updated_at": "2026-04-08T10:00:00Z"
      }
    ],
    "total": 15,
    "page": 1,
    "pageSize": 10
  },
  "msg": "操作成功",
  "total": 15
}
```

**字段说明**:
| 字段 | 类型 | 说明 |
|------|------|------|
| id | integer | 文章 ID |
| title | string | 文章标题 |
| slug | string | 文章别名 (用于 URL) |
| excerpt | string | 摘要 |
| content | string | 完整内容 (支持 Markdown) |
| cover_image | string | 封面图片 URL |
| tags | string | 标签 (逗号分隔) |
| published | boolean | 是否发布 |
| published_at | datetime | 发布时间 |
| view_count | integer | 阅读数 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

---

### 5.2 根据 Slug 获取文章详情

**接口**: `GET /dev-portfolio/v1/blogs/slug/:slug`

**认证**: ❌ 不需要 (公开访问)

**请求示例**:
```
GET /dev-portfolio/v1/blogs/slug/go-concurrency-guide
```

**响应示例**: 同博客列表中的单个文章对象

---

### 5.3 根据 ID 获取文章详情

**接口**: `GET /dev-portfolio/v1/blogs/:id`

**认证**: ✅ 需要 JWT Token

**请求示例**:
```
GET /dev-portfolio/v1/blogs/1
```

**响应示例**: 同博客列表中的单个文章对象

---

### 5.4 创建文章

**接口**: `POST /dev-portfolio/v1/blogs`

**认证**: ✅ 需要 JWT Token

**请求头**:
```
Authorization: Bearer <token>
```

**请求参数**:
```json
{
  "title": "新文章标题",
  "slug": "new-article-slug",
  "excerpt": "文章摘要",
  "content": "文章完整内容...",
  "cover_image": "https://cdn.example.com/blog/new.jpg",
  "tags": "标签 1，标签 2",
  "published": false,
  "published_at": null
}
```

**响应示例**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440011",
  "code": 0,
  "data": {},
  "msg": "创建成功",
  "total": 0
}
```

---

### 5.5 更新文章

**接口**: `PUT /dev-portfolio/v1/blogs/:id`

**认证**: ✅ 需要 JWT Token

**请求示例**:
```
PUT /dev-portfolio/v1/blogs/1
```

**请求参数**: 同创建文章

**响应示例**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440012",
  "code": 0,
  "data": {},
  "msg": "更新成功",
  "total": 0
}
```

---

### 5.6 删除文章

**接口**: `DELETE /dev-portfolio/v1/blogs/:id`

**认证**: ✅ 需要 JWT Token

**请求示例**:
```
DELETE /dev-portfolio/v1/blogs/1
```

**响应示例**:
```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440013",
  "code": 0,
  "data": {},
  "msg": "删除成功",
  "total": 0
}
```

---

## 📦 统一响应格式

### 成功响应

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "code": 0,
  "data": { ... },
  "msg": "操作成功",
  "total": 0
}
```

### 错误响应

```json
{
  "request_id": "550e8400-e29b-41d4-a716-446655440000",
  "code": -1,
  "data": {},
  "msg": "错误信息",
  "total": 0
}
```

### 响应字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| request_id | string | 请求唯一 ID，用于日志追踪 |
| code | integer | 响应码 (0=成功，-1=失败) |
| data | object/array | 响应数据 |
| msg | string | 消息提示 |
| total | integer | 数据总数 (仅列表接口) |

### 常见错误码

| Code | 说明 |
|------|------|
| 0 | 成功 |
| -1 | 失败 |
| 401 | 未授权 (Token 无效或过期) |
| 403 | 禁止访问 |
| 500 | 服务器内部错误 |

---

## 🔑 认证说明

### JWT Token 使用

1. **获取 Token**: 通过登录接口获取
2. **携带 Token**: 在请求头中添加 `Authorization: Bearer <token>`
3. **Token 有效期**: 24 小时
4. **Token 过期**: 返回 401 错误，需重新登录

### 公开接口 vs 受保护接口

| 接口类型 | 认证要求 | 用途 |
|---------|---------|------|
| 公开接口 | ❌ 不需要 | 前台展示页面数据 |
| 受保护接口 | ✅ 需要 | 后台管理操作 |

**公开接口列表**:
- `GET /profile/info` - 获取个人资料
- `GET /profile/skills` - 获取技能列表
- `GET /projects` - 获取项目列表
- `GET /blogs` - 获取博客列表
- `GET /blogs/slug/:slug` - 获取文章详情

**受保护接口**: 其他所有接口

---

## 📝 附录

### 数据库表结构

详见项目 `models/` 目录下的模型文件。

### 技能图标上传

技能图标通过后台技能管理页面上传，支持格式：
- **PNG**: 位图格式，适合复杂图标
- **SVG**: 矢量格式，推荐用于简单图标（可缩放不失真）

图标存储路径由后端配置，返回完整 URL 给前端。

### 技术栈字段格式

`tech_stack` 字段存储为 JSON 数组字符串：
```json
"[\"Vue3\", \"Go\", \"MySQL\", \"Redis\"]"
```

前端解析时需使用 `JSON.parse()`.

---

**文档维护**: 请根据代码更新及时同步此文档  
**最后更新**: 2026-04-09
