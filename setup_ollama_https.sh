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

# 检查必要的命令是否存在
for cmd in docker docker-compose openssl curl; do
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd is not installed. Please install it and try again."
        exit 1
    fi
done

# 检查 OpenSSL 版本
OPENSSL_VERSION=$(openssl version | awk '{print $2}')
if [[ "$(printf '%s\n' "1.1.1" "$OPENSSL_VERSION" | sort -V | head -n1)" == "1.1.1" ]]; then
    echo "OpenSSL version is $OPENSSL_VERSION, which is sufficient."
else
    echo "OpenSSL version is $OPENSSL_VERSION. Please upgrade to at least version 1.1.1."
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

# 创建自签名证书
mkdir -p certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/localhost.key -out certs/localhost.crt -subj "/CN=localhost"

# 创建Nginx配置文件
cat > nginx.conf << EOL
events {
    worker_connections 1024;
}

http {
    server {
        listen 11434 ssl;
        server_name localhost;

        ssl_certificate /etc/nginx/certs/localhost.crt;
        ssl_certificate_key /etc/nginx/certs/localhost.key;

        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers HIGH:!aNULL:!MD5;

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

  nginx:
    image: nginx:alpine
    container_name: nginx
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    ports:
      - "11434:11434"
    depends_on:
      - ollama
EOL

# 启动Docker容器
docker-compose up -d

echo "Ollama service with HTTPS is now running."
echo "You can access it at https://localhost:11434"

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
    echo "curl -k -X POST https://localhost:11434/api/generate -d '{\"model\":\"$MODEL\",\"prompt\":\"Hello\"}'"
done

# 提供清理说明
echo ""
echo "To stop and remove the containers, run:"
echo "cd $PWD && docker-compose down"
echo ""
echo "To remove all generated files, run:"
echo "cd .. && rm -rf $PWD"

# 提供测试 HTTPS 的 curl 命令
echo ""
echo "To test HTTPS connection, run:"
echo "curl -k https://localhost:11434/v1/chat/completions \
    -H \"Content-Type: application/json\" \
    -d '{
        \"model\": \"${MODELS[0]}\",
        \"messages\": [
            {
                \"role\": \"system\",
                \"content\": \"You are a helpful assistant.\"
            },
            {
                \"role\": \"user\",
                \"content\": \"Hello!\"
            }
        ]
    }'"
