#!/usr/bin/env bash
# ============================================================
# Dev Portfolio — 宿主机一键部署脚本
#
# 用途：在本地构建前后端产物，打包后部署到远程服务器（或直接本地部署）
#
# 用法：
#   # 方式1：本地构建 + scp 上传到远程服务器
#   ./scripts/deploy.sh deploy --host user@your-server --remote-path /opt/portfolio
#
#   # 方式2：仅构建产物（手动上传）
#   ./scripts/deploy.sh build
#
#   # 方式3：本地直接部署（测试用）
#   ./scripts/deploy.sh local
# ============================================================

set -euo pipefail

# ============== 配置 ==============
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
API_DIR="${PROJECT_ROOT}/dev-portfolio-api"
WEB_DIR="${PROJECT_ROOT}/dev-portfolio-web"
BUILD_DIR="${PROJECT_ROOT}/build"
DIST_DIR="${BUILD_DIR}/dist"
CONFIGS_DIR="${PROJECT_ROOT}/scripts/configs"

# Go 交叉编译目标（默认 Linux amd64）
GOOS="${GOOS:-linux}"
GOARCH="${GOARCH:-amd64}"

# 远程部署参数（可通过命令行覆盖）
REMOTE_HOST="${REMOTE_HOST:-}"
REMOTE_PATH="${REMOTE_PATH:-/opt/portfolio}"
SSH_KEY="${SSH_KEY:-}"

# ============== 颜色输出 ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ============== 构建函数 ==============
build_api() {
    info "构建 Go API 二进制..."
    cd "${API_DIR}"

    # 确保模块依赖正确
    go mod tidy

    # 交叉编译
    CGO_ENABLED=0 GOOS="${GOOS}" GOARCH="${GOARCH}" \
        go build -ldflags="-s -w -X main.version=$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')" \
        -o "${DIST_DIR}/dev-portfolio-api" .

    success "API 二进制构建完成: ${DIST_DIR}/dev-portfolio-api"
    ls -lh "${DIST_DIR}/dev-portfolio-api"
}

build_web() {
    info "构建 Vue 前端..."
    cd "${WEB_DIR}"

    # 设置生产环境 API 地址（通过 Nginx 反向代理）
    export VITE_API_BASE_URL="${VITE_API_BASE_URL:-/dev-portfolio}"

    npm install
    npm run build

    # 复制构建产物
    mkdir -p "${DIST_DIR}/web"
    cp -r "${WEB_DIR}/dist/"* "${DIST_DIR}/web/"

    success "前端构建完成: ${DIST_DIR}/web/"
}

build() {
    info "========== 开始构建 =========="
    mkdir -p "${DIST_DIR}"

    build_api
    build_web

    # 复制配置文件和脚本
    cp "${CONFIGS_DIR}/dev-portfolio.service" "${DIST_DIR}/" 2>/dev/null || true
    cp "${CONFIGS_DIR}/nginx-host.conf" "${DIST_DIR}/" 2>/dev/null || true
    cp "${PROJECT_ROOT}/scripts/backup.sh" "${DIST_DIR}/" 2>/dev/null || true

    success "========== 构建完成 =========="
    info "产物目录: ${DIST_DIR}"
    ls -R "${DIST_DIR}/" | head -20
}

# ============== 部署函数 ==============
deploy_remote() {
    if [ -z "${REMOTE_HOST}" ]; then
        error "请指定远程服务器: --host user@your-server"
    fi

    if [ -z "${DIST_DIR}/dev-portfolio-api" ] || [ ! -f "${DIST_DIR}/dev-portfolio-api" ]; then
        info "产物不存在，先执行构建..."
        build
    fi

    info "========== 开始远程部署 =========="
    info "目标: ${REMOTE_HOST} -> ${REMOTE_PATH}"

    # SSH 参数
    SSH_OPTS="-o StrictHostKeyChecking=no -o ConnectTimeout=10"
    [ -n "${SSH_KEY}" ] && SSH_OPTS="${SSH_OPTS} -i ${SSH_KEY}"

    # 创建远程目录
    ssh ${SSH_OPTS} "${REMOTE_HOST}" "sudo mkdir -p ${REMOTE_PATH}/{bin,data,logs,uploads,configs,web} ${REMOTE_PATH}/scripts"

    # 上传 API 二进制
    info "上传 API 二进制..."
    scp ${SSH_OPTS} "${DIST_DIR}/dev-portfolio-api" "${REMOTE_HOST}:${REMOTE_PATH}/bin/"

    # 上传前端静态文件
    info "上传前端静态文件..."
    scp ${SSH_OPTS} -r "${DIST_DIR}/web/"* "${REMOTE_HOST}:${REMOTE_PATH}/web/"

    # 上传配置文件
    info "上传配置文件..."
    scp ${SSH_OPTS} "${CONFIGS_DIR}/dev-portfolio.service" "${REMOTE_HOST}:${REMOTE_PATH}/configs/"
    scp ${SSH_OPTS} "${CONFIGS_DIR}/nginx-host.conf" "${REMOTE_HOST}:${REMOTE_PATH}/configs/"
    scp ${SSH_OPTS} "${PROJECT_ROOT}/scripts/backup.sh" "${REMOTE_HOST}:${REMOTE_PATH}/scripts/"

    # 上传生产环境配置
    if [ -f "${API_DIR}/configs/config.prd.yml" ]; then
        scp ${SSH_OPTS} "${API_DIR}/configs/config.prd.yml" "${REMOTE_HOST}:${REMOTE_PATH}/configs/"
    fi

    # 远程执行部署后操作
    info "执行远程部署后操作..."
    ssh ${SSH_OPTS} "${REMOTE_HOST}" "bash -s" << 'REMOTE_SCRIPT'
set -euo pipefail

INSTALL_DIR="${REMOTE_PATH}"

# 设置权限
sudo chown -R www-data:www-data "${INSTALL_DIR}" 2>/dev/null || sudo chown -R nobody:nogroup "${INSTALL_DIR}" 2>/dev/null || true

# 安装 systemd 服务
if command -v systemctl &> /dev/null; then
    sudo cp "${INSTALL_DIR}/configs/dev-portfolio.service" /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable dev-portfolio
    sudo systemctl restart dev-portfolio
    echo "systemd 服务已重启"
else
    echo "未检测到 systemd，跳过服务安装"
fi

# 安装 Nginx 配置
if command -v nginx &> /dev/null; then
    sudo cp "${INSTALL_DIR}/configs/nginx-host.conf" /etc/nginx/sites-available/dev-portfolio
    sudo ln -sf /etc/nginx/sites-available/dev-portfolio /etc/nginx/sites-enabled/dev-portfolio
    sudo nginx -t && sudo systemctl reload nginx
    echo "Nginx 配置已更新"
else
    echo "未检测到 Nginx，请手动配置反向代理"
fi

# 检查服务状态
if command -v systemctl &> /dev/null; then
    sleep 2
    sudo systemctl status dev-portfolio --no-pager | head -5
fi
REMOTE_SCRIPT

    success "========== 远程部署完成 =========="
    info "访问地址: http://${REMOTE_HOST}"
}

deploy_local() {
    info "========== 开始本地部署（测试用）=========="

    INSTALL_DIR="/opt/portfolio"

    # 需要 sudo
    sudo mkdir -p "${INSTALL_DIR}"/{bin,data,logs,uploads,configs,web,scripts}

    # 复制文件
    sudo cp "${DIST_DIR}/dev-portfolio-api" "${INSTALL_DIR}/bin/"
    sudo cp -r "${DIST_DIR}/web/"* "${INSTALL_DIR}/web/"
    sudo cp "${CONFIGS_DIR}/dev-portfolio.service" "${INSTALL_DIR}/configs/"
    sudo cp "${CONFIGS_DIR}/nginx-host.conf" "${INSTALL_DIR}/configs/"
    sudo cp "${PROJECT_ROOT}/scripts/backup.sh" "${INSTALL_DIR}/scripts/"
    if [ -f "${API_DIR}/configs/config.prd.yml" ]; then
        sudo cp "${API_DIR}/configs/config.prd.yml" "${INSTALL_DIR}/configs/"
    fi

    # 设置权限
    sudo chown -R "$(whoami):$(id -gn)" "${INSTALL_DIR}"

    # 安装 systemd
    if command -v systemctl &> /dev/null; then
        sudo cp "${INSTALL_DIR}/configs/dev-portfolio.service" /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable dev-portfolio
        sudo systemctl restart dev-portfolio
        echo "systemd 服务已启动"
    fi

    success "========== 本地部署完成 =========="
}

# ============== 清理 ==============
clean() {
    info "清理构建目录..."
    rm -rf "${BUILD_DIR}"
    success "清理完成"
}

# ============== 帮助 ==============
show_help() {
    cat << EOF
用法: $0 <command> [options]

命令:
  build           构建前后端产物到 build/dist 目录
  deploy          部署到远程服务器
  local           本地直接部署（测试用）
  clean           清理构建产物
  help            显示帮助

部署选项:
  --host <addr>   远程服务器地址（user@host）
  --path <path>   远程部署路径（默认: /opt/portfolio）
  --key <path>    SSH 私钥路径
  --goos <os>     目标操作系统（默认: linux）
  --goarch <arch>  目标架构（默认: amd64）

示例:
  $0 build
  $0 deploy --host root@123.45.67.89 --path /opt/portfolio
  $0 deploy --host root@123.45.67.89 --key ~/.ssh/id_rsa
  $0 local
EOF
}

# ============== 主入口 ==============
COMMAND="${1:-help}"
shift || true

# 解析选项
while [ $# -gt 0 ]; do
    case "$1" in
        --host)   REMOTE_HOST="$2"; shift 2 ;;
        --path)   REMOTE_PATH="$2"; shift 2 ;;
        --key)    SSH_KEY="$2"; shift 2 ;;
        --goos)   GOOS="$2"; shift 2 ;;
        --goarch) GOARCH="$2"; shift 2 ;;
        *)        warn "未知参数: $1"; shift ;;
    esac
done

case "${COMMAND}" in
    build)   build ;;
    deploy)  deploy_remote ;;
    local)   build && deploy_local ;;
    clean)   clean ;;
    help|*)  show_help ;;
esac
