#!/bin/bash
# Redis Docker 一键部署脚本
# 适用于 WSL 环境

set -e

echo "🚀 开始部署 Redis 服务..."

# 进入项目目录
cd /home/docker-compose/redis

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker Desktop"
    exit 1
fi

# 启动服务
echo "📦 启动 Redis 服务..."
docker-compose -f docker-compose.redis.yml up -d

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 5

# 检查服务状态
echo "🔍 检查服务状态..."
docker-compose -f docker-compose.redis.yml ps

# 验证 Redis 连接
echo "🧪 验证 Redis 连接..."
if docker-compose -f docker-compose.redis.yml exec -T redis redis-cli ping | grep -q "PONG"; then
    echo "✅ Redis 服务正常运行"
else
    echo "❌ Redis 服务异常"
    exit 1
fi

# 验证 Redis Exporter
echo "📊 验证 Redis Exporter..."
if curl -s http://localhost:9121/metrics | grep -q "redis_up"; then
    echo "✅ Redis Exporter 正常运行"
else
    echo "❌ Redis Exporter 异常"
    exit 1
fi

echo "🎉 Redis 服务部署完成！"
echo "📋 服务信息："
echo "  - Redis 地址: localhost:6379"
echo "  - Redis Exporter 地址: http://localhost:9121/metrics"
echo "📖 使用说明："
echo "  - 查看日志: docker-compose -f docker-compose.redis.yml logs -f"
echo "  - 进入 CLI: docker-compose -f docker-compose.redis.yml exec redis redis-cli"
echo "  - 停止服务: docker-compose -f docker-compose.redis.yml down"