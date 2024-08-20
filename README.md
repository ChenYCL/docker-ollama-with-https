## 1. Set permission
```bash
chmod +x setup_ollama_https.sh
```
## 2. Run shell script
```bash
./setup_ollama_https.sh
```

## 3. Setup configuration
Enter the Ollama model names (comma-separated, e.g., qwen:4b,llama2:7b): qwen:4b,llama2:7b

## 4. Test it works
```bash
curl http://localhost:11434/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "qwen:4b",
        "messages": [
            {
                "role": "system",
                "content": "You are a helpful assistant."
            },
            {
                "role": "user",
                "content": "Hello!"
            }
        ]
    }'
```

## Notes:
For Windows users, make sure to use WSL (Windows Subsystem for Linux) or Git Bash to run this script. Make sure you have Docker and Docker Compose installed on your system. On macOS and Linux, you may need to use `sudo` to run scripts to ensure you have sufficient permissions to create files and start Docker containers. The script uses a self-signed certificate, so the browser may display a security warning when accessing `https://localhost`. This is normal for local test environments. Cleanup instructions are provided at the end of the script so that you can stop the service and delete the resulting files if needed.
