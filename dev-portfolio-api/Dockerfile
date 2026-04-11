# ============================================================
# 构建阶段
# ============================================================
FROM golang:1.25-alpine AS builder

WORKDIR /app

# 安装依赖
RUN apk add --no-cache git

# 复制 go.mod 和 go.sum（利用 Docker 缓存层）
COPY go.mod go.sum ./
RUN go mod download

# 复制源代码
COPY . .

# 构建静态二进制
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o main .

# ============================================================
# 运行阶段
# ============================================================
FROM alpine:3.21

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /root/

# 从构建阶段复制二进制和配置文件
COPY --from=builder /app/main .
COPY --from=builder /app/configs ./configs
COPY --from=builder /app/init-sqlite.sql .

# 创建 uploads 和 logs 目录
RUN mkdir -p uploads logs data

# 暴露端口
EXPOSE 8080

# 健康检查
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# 运行（.env 文件通过 docker-compose volumes 或 env_file 注入）
CMD ["./main"]
