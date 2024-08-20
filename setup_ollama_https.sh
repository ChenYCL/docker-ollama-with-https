#!/bin/bash

# 检查操作系统
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
    OS="Windows"
else
    echo "Unsupported operating system"
    exit 1
fi

echo "Detected OS: $OS"

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

# 检查Docker Compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

# 提示用户输入模型名称
read -p "Enter the Ollama model names (comma-separated, e.g., qwen:4b,llama2:7b): " MODEL_NAMES

# 将输入的模型名称转换为数组
IFS=',' read -ra MODELS <<< "$MODEL_NAMES"

# 创建工作目录
WORK_DIR="ollama_https_setup"
mkdir -p $WORK_DIR
cd $WORK_DIR

# 生成自签名证书
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/CN=localhost"

# 创建Nginx配置文件
cat > nginx.conf << EOL
events {
    worker_connections 1024;
}

http {
    server {
        listen 443 ssl;
        server_name localhost;

        ssl_certificate /etc/nginx/ssl/server.crt;
        ssl_certificate_key /etc/nginx/ssl/server.key;

        location / {
            proxy_pass http://ollama:11434;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
    }
}
EOL

# 创建Docker Compose文件
cat > docker-compose.yml << EOL
version: '3'
services:
  ollama:
    image: ollama/ollama
    container_name: ollama
    volumes:
      - ./ollama:/root/.ollama
    ports:
      - "11434:11434"

  nginx:
    image: nginx:alpine
    container_name: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./server.crt:/etc/nginx/ssl/server.crt
      - ./server.key:/etc/nginx/ssl/server.key
    ports:
      - "443:443"
    depends_on:
      - ollama
EOL

# 启动Docker容器
docker-compose up -d

echo "Ollama service with HTTPS is now running."
echo "You can access it at https://localhost"
echo "Note: You may see a security warning because of the self-signed certificate."

# 拉取并运行指定的模型
for MODEL in "${MODELS[@]}"; do
    echo "Pulling model: $MODEL"
    docker exec ollama ollama pull $MODEL
done

echo "All specified models have been pulled."

# 提供测试说明
echo ""
echo "To test the models, you can use curl commands like:"
for MODEL in "${MODELS[@]}"; do
    echo "curl -k -X POST https://localhost/api/generate -d '{\"model\":\"$MODEL\",\"prompt\":\"Hello\"}'"
done

# 提供清理说明
echo ""
echo "To stop and remove the containers, run:"
echo "cd $PWD && docker-compose down"
echo ""
echo "To remove all generated files, run:"
echo "cd .. && rm -rf $PWD"
