#!/usr/bin/env bash
# ============================================================
# Dev Portfolio — SQLite 数据库备份脚本
#
# 用法：
#   ./scripts/backup.sh                    # 备份到默认目录
#   ./scripts/backup.sh --restore backup.db # 从备份恢复
#   ./backup.sh --cleanup --days 7         # 清理 7 天前的备份
# ============================================================

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/opt/portfolio}"
BACKUP_DIR="${INSTALL_DIR}/backups"
DB_FILE="${INSTALL_DIR}/data/portfolio.db"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/portfolio_${DATE}.db"

# ============== 颜色输出 ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# ============== 备份 ==============
backup() {
    if [ ! -f "${DB_FILE}" ]; then
        error "数据库文件不存在: ${DB_FILE}"
    fi

    mkdir -p "${BACKUP_DIR}"

    # WAL checkpoint 确保数据完整
    info "执行 WAL checkpoint..."
    if command -v sqlite3 &> /dev/null; then
        sqlite3 "${DB_FILE}" "PRAGMA wal_checkpoint(TRUNCATE);"
    fi

    # 复制数据库（如果是 Docker，先用 docker cp）
    info "备份数据库到 ${BACKUP_FILE}..."
    cp "${DB_FILE}" "${BACKUP_FILE}"
    cp "${DB_FILE}-shm" "${BACKUP_FILE}.shm" 2>/dev/null || true
    cp "${DB_FILE}-wal" "${BACKUP_FILE}.wal" 2>/dev/null || true

    # 压缩
    if command -v gzip &> /dev/null; then
        gzip "${BACKUP_FILE}"
        success "备份完成: ${BACKUP_FILE}.gz ($(du -h "${BACKUP_FILE}.gz" | cut -f1))"
    else
        success "备份完成: ${BACKUP_FILE} ($(du -h "${BACKUP_FILE}" | cut -f1))"
    fi

    # 自动清理 30 天前的备份
    cleanup --days 30 --silent
}

# ============== 恢复 ==============
restore() {
    local backup_file="$1"

    if [ ! -f "${backup_file}" ]; then
        error "备份文件不存在: ${backup_file}"
    fi

    info "停止服务..."
    sudo systemctl stop dev-portfolio 2>/dev/null || true

    info "恢复数据库..."
    mkdir -p "$(dirname "${DB_FILE}")"

    if [[ "${backup_file}" == *.gz ]]; then
        gunzip -c "${backup_file}" > "${DB_FILE}"
    else
        cp "${backup_file}" "${DB_FILE}"
    fi

    # 确保权限正确
    sudo chown www-data:www-data "${DB_FILE}" 2>/dev/null || true

    info "启动服务..."
    sudo systemctl start dev-portfolio 2>/dev/null || true

    success "恢复完成: ${backup_file}"
}

# ============== 清理旧备份 ==============
cleanup() {
    local days=30
    local silent=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --days)  days="$2"; shift 2 ;;
            --silent) silent=true; shift ;;
            *) shift ;;
        esac
    done

    if [ -d "${BACKUP_DIR}" ]; then
        local count=$(find "${BACKUP_DIR}" -name "portfolio_*.db*" -mtime +${days} 2>/dev/null | wc -l)
        if [ "${count}" -gt 0 ]; then
            find "${BACKUP_DIR}" -name "portfolio_*.db*" -mtime +${days} -delete
            [ "${silent}" = false ] && info "已清理 ${count} 个 ${days} 天前的备份"
        else
            [ "${silent}" = false ] && info "没有 ${days} 天前的备份需要清理"
        fi
    fi
}

# ============== 列表 ==============
list_backups() {
    if [ ! -d "${BACKUP_DIR}" ]; then
        info "备份目录为空"
        return
    fi
    echo "备份列表:"
    ls -lht "${BACKUP_DIR}/" 2>/dev/null | head -20
}

# ============== 主入口 ==============
COMMAND="${1:-backup}"
shift || true

case "${COMMAND}" in
    backup)     backup ;;
    restore)    restore "$1" ;;
    cleanup)    cleanup "$@" ;;
    list)       list_backups ;;
    *)
        echo "用法: $0 {backup|restore <file>|cleanup [--days N]|list}"
        exit 1
        ;;
esac
