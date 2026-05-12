# 宿主机部署指南

> 适用于低配阿里云 ECS（2CPU，低 IOPS 云盘）场景。
> 相比 Docker 部署，节省 ~200MB 内存，消除 Docker 存储层 I/O 放大。

---

## 目录

1. [前置要求](#1-前置要求)
2. [服务器初始化](#2-服务器初始化)
3. [构建与部署](#3-构建与部署)
4. [服务管理](#4-服务管理)
5. [数据备份](#5-数据备份)
6. [更新升级](#6-更新升级)
7. [故障排查](#7-故障排查)

---

## 1. 前置要求

### 服务器端

- 阿里云 ECS（Ubuntu 22.04/24.04 或 CentOS 7+）
- **不需要安装 Go、Node.js** — Go 二进制是静态编译的，前端产物是纯静态文件
- 系统包依赖（初始化脚本会自动安装）：
  - `nginx` — 静态文件服务 + API 反向代理
  - `sqlite3` — 数据库管理工具（非运行时，仅备份/checkpoint 用）
  - `ca-certificates` — HTTPS 证书（API 访问阿里云 OSS 等外部服务需要）
  - `tzdata` — 时区数据
  - `gzip` — 备份压缩
- 已开放 80/443 端口

### 本地构建环境

- Go 1.23+（用于交叉编译 Linux 二进制，仅构建时需要）
- Node.js 18+（用于构建前端，仅构建时需要）
- bash shell

---

## 2. 服务器初始化

SSH 登录服务器后执行：

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装必要工具
# 说明：
#   - nginx: 静态文件 + 反向代理（必须）
#   - sqlite3: 数据库管理工具，用于 WAL checkpoint（必须）
#   - ca-certificates: HTTPS 证书链，API 访问 OSS 等外部服务需要（必须）
#   - tzdata: 时区数据，日志和数据库时间显示正确（必须）
#   - gzip/curl/wget: 备份和调试工具（推荐）
sudo apt install -y nginx sqlite3 ca-certificates tzdata gzip curl wget

# 创建部署用户（如果没有 www-data）
sudo id www-data 2>/dev/null || sudo useradd -r -s /bin/false www-data

# 创建部署目录
sudo mkdir -p /opt/portfolio/{bin,data,logs,uploads,configs,web,scripts,backups}
sudo chown -R www-data:www-data /opt/portfolio
sudo chmod -R 755 /opt/portfolio

# 开放防火墙
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

### Nginx 配置

```bash
# 移除默认站点
sudo rm -f /etc/nginx/sites-enabled/default

# 复制配置（从构建产物中获取）
sudo cp /opt/portfolio/configs/nginx-host.conf /etc/nginx/sites-available/dev-portfolio
sudo ln -sf /etc/nginx/sites-available/dev-portfolio /etc/nginx/sites-enabled/dev-portfolio

# 编辑 server_name 为你的域名
sudo nano /etc/nginx/sites-available/dev-portfolio
# 修改: server_name jacoblee.info www.jacoblee.info;

# 测试并重载
sudo nginx -t
sudo systemctl reload nginx
```

### SSL 证书（可选但推荐）

```bash
# 使用 Let's Encrypt
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d jacoblee.info -d www.jacoblee.info

# 自动续期
sudo systemctl enable certbot.timer
```

---

## 3. 构建与部署

### 方式 1：一键远程部署（推荐）

```bash
cd /Users/jacob/Projects/JacobLee/dev-portfolio

# 一键构建并部署到远程服务器
./scripts/deploy.sh deploy \
  --host root@your-server-ip \
  --path /opt/portfolio \
  --key ~/.ssh/id_rsa
```

### 方式 2：本地构建 + 手动上传

```bash
# 1. 本地构建
./scripts/deploy.sh build

# 2. 手动上传产物
scp -r build/dist/* root@your-server:/opt/portfolio/

# 3. 服务器上安装服务
ssh root@your-server
  sudo cp /opt/portfolio/configs/dev-portfolio.service /etc/systemd/system/
  sudo systemctl daemon-reload
  sudo systemctl enable dev-portfolio
  sudo systemctl start dev-portfolio
  sudo systemctl status dev-portfolio
```

### 方式 3：本地直接部署（测试用）

```bash
./scripts/deploy.sh local
```

---

## 4. 服务管理

### 常用命令

```bash
# 查看状态
sudo systemctl status dev-portfolio

# 重启
sudo systemctl restart dev-portfolio

# 查看日志
sudo journalctl -u dev-portfolio -f          # 实时
sudo journalctl -u dev-portfolio --since "1 hour ago"  # 最近1小时
sudo journalctl -u dev-portfolio -n 100      # 最近100行

# 停止/启动
sudo systemctl stop dev-portfolio
sudo systemctl start dev-portfolio

# 禁用开机自启
sudo systemctl disable dev-portfolio
```

### 环境变量

在 systemd service 文件中修改：

```bash
sudo nano /etc/systemd/system/dev-portfolio.service

# 添加环境变量
Environment="RunMode=prd"
Environment="GIN_MODE=release"

# 重载
sudo systemctl daemon-reload
sudo systemctl restart dev-portfolio
```

---

## 5. 数据备份

### 自动备份

```bash
# 手动备份
sudo /opt/portfolio/scripts/backup.sh backup

# 定时备份（每天凌晨 2 点）
sudo crontab -e
# 添加: 0 2 * * * /opt/portfolio/scripts/backup.sh backup >> /opt/portfolio/logs/backup.log 2>&1
```

### 备份管理

```bash
# 列出所有备份
/opt/portfolio/scripts/backup.sh list

# 清理 30 天前的备份
/opt/portfolio/scripts/backup.sh cleanup --days 30

# 从备份恢复
sudo /opt/portfolio/scripts/backup.sh restore /opt/portfolio/backups/portfolio_20260512_020000.db.gz
```

---

## 6. 更新升级

```bash
# 一键更新
./scripts/deploy.sh deploy --host root@your-server --path /opt/portfolio

# 更新后检查
ssh root@your-server
  sudo systemctl status dev-portfolio
  curl -s http://127.0.0.1:8080/health
```

---

## 7. 故障排查

### 服务无法启动

```bash
# 查看详细日志
sudo journalctl -u dev-portfolio -xe

# 检查文件权限
ls -la /opt/portfolio/bin/dev-portfolio-api
ls -la /opt/portfolio/configs/config.prd.yml

# 手动运行测试
cd /opt/portfolio
sudo -u www-data ./bin/dev-portfolio-api
```

### Nginx 502 Bad Gateway

```bash
# 检查 API 是否在运行
curl -s http://127.0.0.1:8080/health

# 检查 Nginx 配置
sudo nginx -t
sudo journalctl -u nginx -xe

# 确认 API 监听的地址和端口
sudo ss -tlnp | grep 8080
```

### SQLite 数据库损坏

```bash
# 检查数据库完整性
sqlite3 /opt/portfolio/data/portfolio.db "PRAGMA integrity_check;"

# 从备份恢复
sudo /opt/portfolio/scripts/backup.sh restore /opt/portfolio/backups/latest.db.gz
```

### 磁盘空间不足

```bash
# 查看磁盘使用
df -h
du -sh /opt/portfolio/*

# 清理旧备份
/opt/portfolio/scripts/backup.sh cleanup --days 7

# 清理旧日志
sudo journalctl --vacuum-size=100M
```
