# Redis Docker 部署指南

## 环境要求

- Windows 11 操作系统
- WSL (Windows Subsystem for Linux) 已安装并配置
- Docker Desktop 在 WSL 中运行
- 项目文件已同步到 WSL 的 `/home/docker-compose/redis` 目录

## 项目结构

```
redis/
├── docker-compose.redis.yml     # Redis 服务配置
├── scripts.txt                 # 部署脚本（Windows PowerShell格式）
├── data/                       # Redis数据目录
├── logs/                       # 日志目录
└── README.md                  # 部署指南
```

## 快速开始

### 1. 准备工作

确保项目文件已同步到 WSL 目录：
```powershell
# 在 Windows PowerShell 中执行
wsl -e bash -cl "ls -la /home/docker-compose/redis"
```

### 2. 创建必要目录

```powershell
# 创建数据目录
wsl -e bash -cl "mkdir -p /home/docker-compose/redis/data"
wsl -e bash -cl "mkdir -p /home/docker-compose/redis/logs"
```

### 3. 启动 Redis 服务

```powershell
# 进入项目目录
wsl -e bash -cl "cd /home/docker-compose/redis && pwd"

# 启动 Redis 服务
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml up -d"

# 等待服务启动（5秒）
timeout /t 5 /nobreak

# 检查服务状态
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml ps"
```

### 4. 验证服务

```powershell
# 验证 Redis 连接
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml exec redis redis-cli ping"

# 验证 Redis Exporter 指标
curl -s http://localhost:9121/metrics | head -20
```

## 服务说明

### Redis 服务
- **端口**: 6379
- **配置**: 启用持久化，内存限制256MB
- **数据目录**: `/data` (容器内) -> `./data` (宿主机)
- **网络**: 自定义网络 `redis-network`

### Redis Exporter 服务
- **端口**: 9121
- **用途**: 为 Prometheus 提供 Redis 监控指标
- **访问地址**: http://localhost:9121/metrics

## 常用命令

```powershell
# 查看实时日志
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml logs -f"

# 重启服务
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml down && docker-compose -f docker-compose.redis.yml up -d"

# 停止服务
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml down"

# 进入 Redis CLI
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml exec redis redis-cli"

# 查看 Redis 信息
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml exec redis redis-cli info"
```

## 监控集成

Redis Exporter 提供以下监控指标：
- 内存使用情况
- 连接数
- 命令统计
- 键空间统计
- 性能指标

Prometheus 配置示例：
```yaml
scrape_configs:
  - job_name: 'redis'
    static_configs:
      - targets: ['localhost:9121']
```

## 故障排查

### 服务无法启动
```powershell
# 查看详细日志
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml logs redis"
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml logs redis-exporter"
```

### 连接问题
```powershell
# 检查网络连接
wsl -e bash -cl "cd /home/docker-compose/redis && docker network ls"
wsl -e bash -cl "cd /home/docker-compose/redis && docker network inspect redis-network"

# 测试容器间连接
wsl -e bash -cl "cd /home/docker-compose/redis && docker-compose -f docker-compose.redis.yml exec redis-exporter wget -qO- redis:6379"
```

## 性能调优

### 内存配置
当前配置：
- 最大内存：256MB
- 内存策略：allkeys-lru

根据实际需求调整 `docker-compose.redis.yml` 中的 `--maxmemory` 参数。

### 持久化配置
当前配置：
- AOF 持久化：开启
- 数据目录：挂载到宿主机 `./data`

## 安全建议

1. **网络访问**: Redis 默认监听所有接口，建议在生产环境中设置密码
2. **密码认证**: 可在 `docker-compose.redis.yml` 中添加 `REDIS_PASSWORD` 环境变量
3. **网络安全**: 使用防火墙限制对 Redis 端口的访问

## 版本信息

- Redis: 7-alpine
- Redis Exporter: latest
- Docker Compose: 3.8