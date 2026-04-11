# 项目执行计划 — Jacob Lee Developer Portfolio

> **版本**: v1.3  
> **创建日期**: 2026-04-10  
> **更新日期**: 2026-04-10  
> **作者**: Hermes  
> **项目路径**: `/Users/jacob/Projects/JacobLee/dev-portfolio/`  
> **数据源**: `docs/dev-portfolio.sql`（真实库表结构）

---

## 1. 项目状态总览

### 1.1 整体完成度：约 55%

```
[██████████████████████░░░░░░░░░░░░] 55%

✅ 已完成     ██████████████████████░░░░░░░░░░  55%
📋 待开发    ██████████████████████████████████  45%
```

### 1.2 模块完成度

| 模块 | 完成度 | 说明 |
|------|--------|------|
| 基础架构 | ✅ 100% | Docker Compose、MySQL、API 框架、前端框架 |
| 数据库 | ✅ 100% | 9 张表全部就绪（7 张已有 + 2 张 AutoMigrate 创建） |
| **Phase 0 后端对齐** | ✅ 100% | **Model/Handler/Service/Router 全部对齐，编译通过，本地测试全通过** |
| 认证系统 | ✅ 100% | JWT 登录正常，用户表字段对齐 |
| 前台页面 | ❌ 20% | 骨架存在，需对齐新 API |
| 后台管理 | ❌ 10% | 仅 Dashboard + Profile 布局 |
| 文件上传 (OSS) | ❌ 0% | 未实现 |
| Markdown 编辑器/渲染器 | ❌ 0% | 未实现 |

---

## 2. 执行计划

按优先级排序，分为三个阶段：

### Phase 0：后端代码对齐实际数据库（基础对齐）

> **目标**：让现有 Go 代码能正确操作 `dev-portfolio.sql` 中的实际表  
> **预估工作量**：2-3 天

#### 2.0.1 GORM Model 重写

- [ ] `models/profile_info.go` — 新建，对齐 `profile_infos` 表
- [ ] `models/profile_social.go` — 新建，对齐 `profile_socials` 表
- [ ] `models/profile_nav_bar.go` — 新建，对齐 `profile_nav_bars` 表
- [ ] `models/user.go` — 修改，对齐实际 `users` 表（添加 nickname 字段等）
- [ ] `models/blog.go` — 修改：`excerpt`→`summary`，`published`(bool)→`status`(string)，`published_at`(datetime)→`published_at`(*int64 Unix时间戳)，添加 `author_id`
- [ ] `models/profile/profile.go` — 确认字段类型与 `profile_skill_groups` / `profile_skills` 对齐
- [ ] **保留 AutoMigrate**（项目一直通过 AutoMigrate 管理表结构，确保新项目 model 对齐后能正确创建 `profile_projects` 和 `blog_attachments` 表）

#### 2.0.2 Handler / Service 重写

- [ ] `profile_handler.go` — 改为读写 `profile_infos`
- [ ] `profile_service.go` — 新增 `profile_socials` 和 `profile_nav_bars` 的 CRUD
- [ ] `blog_handler.go` — 对齐新字段（status 过滤、author_id 注入、Unix 时间戳处理）
- [ ] `blog_service.go` — 对齐新字段
- [ ] 删除或注释旧 `profiles` 表相关代码
- [ ] 新增路由：`GET /profile/socials`、`GET /profile/navbar`
- [ ] 受保护路由：`profile/socials` CRUD、`profile/navbar` CRUD

#### 2.0.3 创建 Projects 和 Attachments 表

- [ ] 对齐 `models/project.go`：表名改为 `profile_projects`，字段改为 `OrderNo`(int64), `Status`(string: draft/published)，移除旧的 `Order`(int), `Published`(bool)
- [ ] 新建 `models/blog_attachment.go`：对应 `blog_attachments` 表（post_id, oss_key, oss_url, file_name, file_size, file_type）
- [ ] 通过 AutoMigrate 自动创建两张表
- [ ] 确保 handler/service 与新的 `status` 字段对齐

---

### Phase 1：管理后台完整实现

> **目标**：后台可管理所有内容  
> **预估工作量**：4-6 天

#### 2.1.1 后端新增接口

- [ ] `POST /upload/:type` — 文件上传（阿里云 OSS，支持 avatar/cover/skill-icon/blog-image）
- [ ] `GET/POST/PUT/DELETE /users[/:id]` — 用户管理
- [ ] `PUT /users/:id/password` — 修改密码
- [ ] `GET/POST/PUT/DELETE /profile/socials[/:id]` — 社交链接管理
- [ ] `GET/POST/PUT/DELETE /profile/navbar[/:id]` — 导航菜单管理

#### 2.1.2 Skills 管理页面

- [ ] 技能分类 CRUD（`profile_skill_groups`）
- [ ] 技能项 CRUD（`profile_skills`：图标上传 + 名称）
- [ ] 网格预览效果

#### 2.1.3 Profile 管理页面（重写）

- [ ] `profile_infos` 编辑：name, roles（多行/JSON 输入）, about（Markdown）, image_source, logo, logo_width, logo_height
- [ ] `profile_socials` 管理：network, href, order_no（增删改查）
- [ ] `profile_nav_bars` 管理：title, href, order_no（增删改查）

#### 2.1.4 Projects 管理页面

- [ ] `profile_projects` 表管理
- [ ] 项目列表表格（标题、排序号、状态、操作）
- 新增/编辑表单：标题、描述、技术栈标签（JSON 数组）、Repo URL、Demo URL
- 封面图上传（阿里云 OSS）
- 排序值设置（`order_no`）
- 发布/下架切换（`status`: draft / published）
- 删除确认

#### 2.1.5 Blogs 管理页面

- [ ] `blog_posts` 表管理
- [ ] 博客列表（status: draft/published）
- [ ] Markdown 编辑器（md-editor-v3），`content` 存 Markdown
- [ ] 编辑器内上传图片自动上传至阿里云 OSS，并写入 `blog_attachments` 表
- [ ] 封面图上传（OSS）、摘要、标签、slug
- [ ] 创建时自动注入 `author_id`（当前登录用户）
- [ ] `published_at` 发布时自动设为当前 Unix 时间戳
- [ ] 删除文章时级联删除关联的 OSS 附件

#### 2.1.6 Users 管理页面

- [ ] 用户列表、新增、编辑、删除
- [ ] 修改密码功能

---

### Phase 2：前台页面完善

> **目标**：前台从新 API 加载真实数据  
> **预估工作量**：3-4 天

#### 2.2.1 首页 (Home) 改造

- [ ] 从 `/profile/info` 读取 `name` 和 `roles`
- [ ] **TypingEffect 组件**：终端风格循环播放 `roles`
- [ ] 从 `/profile/socials` 读取社交链接，SocialLinks 组件渲染
- [ ] 导航栏从 `/profile/navbar` 动态读取

#### 2.2.2 关于我 (About) 改造

- [ ] 从 `/profile/info` 读取 `about`（Markdown 渲染）
- [ ] `image_source` 配图展示
- [ ] `logo` 展示

#### 2.2.3 技能展示 (Skills) 改造

- [ ] 从 `/profile/skills` 加载
- [ ] 响应式网格（图标 75x75）

#### 2.2.4 博客详情 (BlogDetail) — Markdown 渲染

- [ ] MarkdownRenderer 组件（markdown-it + highlight.js + KaTeX + mermaid + DOMPurify）
- [ ] `published_at` Unix 时间戳格式化
- [ ] `view_count` 自动 +1

#### 2.2.5 博客列表 (Blogs) 完善

- [ ] 从 API 加载（status='published'）
- [ ] `summary` 展示
- [ ] 分页

---

### Phase 3：安全加固与生产就绪

> **目标**：系统安全、可部署到生产  
> **预估工作量**：2-3 天

#### 2.3.1 安全加固

- [ ] 禁用公开注册（`POST /auth/register` 仅本地访问）
- [ ] JWT 密钥环境变量化
- [ ] 登录限流
- [ ] Markdown 渲染 DOMPurify 过滤

#### 2.3.2 文件上传安全

- [ ] 文件类型白名单（图片：jpg/jpeg/png/svg/webp）
- [ ] 文件大小限制（头像 2MB，封面 5MB，博客插图 5MB）
- [ ] 文件名随机化（OSS 自动处理 Key）
- [ ] OSS Bucket 权限配置（私有读写 + CDN 签名 URL 或公共读）
- [ ] 删除文章时级联删除 OSS 附件（通过 `blog_attachments` 表）

#### 2.3.3 生产部署

- [ ] 域名 + SSL（Let's Encrypt）
- [ ] Nginx HTTPS
- [ ] API Release 模式

---

## 3. 技术选型确认

| 需求 | 方案 | 协议 | 说明 |
|------|------|------|------|
| Markdown 编辑器（后台） | **md-editor-v3** | MIT | Vue 3 原生，支持 Mermaid/KaTeX/代码高亮 |
| 图片上传 | md-editor-v3 `@uploadImage` → 后端 → 阿里云 OSS → 返回 URL | — | 上传时记录到 `blog_attachments` 表 |
| Markdown 渲染（前台） | **markdown-it** + 插件 | MIT | 核心 + katex + highlightjs |
| Mermaid 图表 | **mermaid** | Apache 2.0 | 流程图/时序图 |
| LaTeX 公式 | **KaTeX** | MIT | 比 MathJax 快 |
| 代码高亮 | **highlight.js** | BSD-3 | 190+ 语言 |
| XSS 防护 | **DOMPurify** | Apache 2.0 | HTML 过滤 |
| 打字机动效 | 自定义 Vue 组件 | — | 终端风格 |
| 文件存储 | **阿里云 OSS** | — | 生产环境部署在阿里云，Bucket 公共读或 CDN 加速 |

---

## 4. 待确认事项

| # | 问题 | 状态 | 说明 |
|---|------|------|------|
| 1 | `profile_infos.roles` 格式 | ✅ 已确认 | 使用 JSON 数组格式（如 `["Full-Stack Dev","Mobile Engineer"]`） |
| 2 | AutoMigrate | ✅ 已确认 | 继续保留，用于创建 `profile_projects` 和 `blog_attachments` 表 |
| 3 | `blog_posts.published_at` 为 Unix 时间戳 | 需处理 | 后端序列化时转为 ISO 8601 字符串返回给前端 |
| 4 | `projects` 表名 | ✅ 已确认 | 改为 `profile_projects`，与 `profile_*` 命名风格一致 |
| 5 | 文件存储方案 | ✅ 已确认 | 阿里云 OSS，删除文章时级联清理附件 |

---

## 5. 验收标准

### Phase 0 验收

- [ ] Go 代码能正确读写 `profile_infos`、`profile_socials`、`profile_nav_bars`、`blog_posts`（新字段）
- [ ] 旧 `profiles` 表代码完全移除
- [ ] API 接口返回数据与新表字段一致

### Phase 1 验收

- [ ] 后台可管理 Profile/Socials/Navbar/Skills/Projects/Blogs/Users
- [ ] 博客使用 Markdown 编辑器，数据库存 Markdown
- [ ] 图片上传至阿里云 OSS，`blog_attachments` 表正确记录关联
- [ ] 文件上传可用（头像/封面/技能图标/博客插图）
- [ ] 所有管理操作有成功/失败反馈

### Phase 2 验收

- [ ] 首页打字机动效 + 动态社交链接
- [ ] About 页渲染 Markdown + 配图
- [ ] 技能网格 75x75 图标
- [ ] 博客详情支持 Mermaid/LaTeX/代码高亮

### Phase 3 验收

- [ ] 注册接口受限
- [ ] JWT 密钥环境变量
- [ ] HTTPS 部署
