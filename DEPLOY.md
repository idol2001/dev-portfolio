# 部署指南

## 快速部署

### 1. 准备环境文件

```bash
# 根目录：Docker Compose 配置（端口、MySQL 连接等）
cp .env.example .env

# API 目录：应用级配置（数据库密码、OSS 密钥等）
cp dev-portfolio-api/.env.example dev-portfolio-api/.env
```

编辑这两个 `.env` 文件，填入实际值。

### 2. 启动所有服务

```bash
docker compose up -d --build
```

启动顺序：MySQL（等待 healthcheck）→ API → 前端

### 3. 创建管理员账号

首次启动后，数据库表已由 GORM AutoMigrate 自动创建，但还没有管理员账号。执行：

```bash
# 方式 1：使用 SQL 脚本创建默认管理员（admin / admin123）
docker compose exec -T mysql mysql -u root -p${MYSQL_ROOT_PASSWORD:-rootpass123} ${MYSQL_DATABASE:-dev-portfolio} < add-admin-user.sql
```

### 4. 访问

| 服务 | 地址 |
|------|------|
| 前端 | http://localhost:3000 |
| 后端 API | http://localhost:8080 |
| 后台管理 | http://localhost:3000/admin |

默认管理员账号：**admin** / **admin123**

## 常用命令

```bash
# 停止所有服务
docker compose down

# 重新构建并启动
docker compose up -d --build

# 查看服务状态
docker compose ps

# 查看日志
docker compose logs -f api
docker compose logs -f mysql

# 进入容器
docker compose exec api sh
docker compose exec mysql mysql -u dev-portfolio -p dev-portfolio
```

## 启用阿里云 OSS

编辑 `dev-portfolio-api/.env`:

```bash
ALIYUNOSS_ENABLE=true
ALIYUNOSS_ENDPOINT=oss-cn-hangzhou.aliyuncs.com
ALIYUNOSS_ACCESS_KEY_ID=你的AccessKey ID
ALIYUNOSS_ACCESS_KEY_SECRET=你的AccessKey Secret
ALIYUNOSS_BUCKET_NAME=你的Bucket名称
ALIYUNOSS_BUCKET_DOMAIN=https://cdn.example.com  # 可选，CDN域名
```

然后重建 API:

```bash
docker compose up -d --build api
```

## 生产环境部署

### 使用自定义域名

编辑根目录 `.env`:

```bash
WEB_PORT=80
API_PORT=8080
VITE_API_BASE_URL=https://your-domain.com/dev-portfolio
```

### SSL 证书

建议在外部加一层反向代理（Nginx / Caddy / Cloudflare）处理 HTTPS。本项目的 nginx 只处理 HTTP。

### 数据安全

- **不要将 `.env` 提交到 Git**（已在 .gitignore 中排除）
- 使用强密码替换默认值
- 定期备份 MySQL 数据

## 备份与恢复

```bash
# 备份数据库
docker compose exec mysql mysqldump -u dev-portfolio -p dev-portfolio > backup.sql

# 恢复数据库
cat backup.sql | docker compose exec -T mysql mysql -u dev-portfolio -p dev-portfolio
```

## 故障排查

### API 启动失败

```bash
docker compose logs api
# 常见原因：
# 1. MySQL 未就绪 → 等待 healthcheck 通过（约 10-30 秒）
# 2. 数据库连接信息错误 → 检查 dev-portfolio-api/.env
# 3. 端口冲突 → 修改根目录 .env 中的 API_PORT
```

### 前端 404

```bash
# 检查 nginx 代理配置
docker compose exec web cat /etc/nginx/conf.d/default.conf
```

### 修改配置后不生效

```bash
# 修改 config.se.yml 后：API 支持热加载，无需重启
# 修改 .env 后：需要重建容器
docker compose up -d --build api
```
