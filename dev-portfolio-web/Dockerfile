# ============================================================
# 构建参数（构建时通过 --build-arg 注入）
# ============================================================
ARG VITE_API_BASE_URL=http://localhost:8080/dev-portfolio

# ============================================================
# 构建阶段
# ============================================================
FROM node:20-alpine AS builder

ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=$VITE_API_BASE_URL

WORKDIR /app

# Copy package.json
COPY package*.json ./

# Install dependencies (using install instead of ci for robustness in Docker builds)
RUN npm install

# Copy source code
COPY . .

# Build production version
RUN npm run build

# ============================================================
# 运行阶段（Nginx 提供静态文件 + 反向代理 API）
# ============================================================
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
