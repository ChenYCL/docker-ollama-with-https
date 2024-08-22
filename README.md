
# Docker Ollama with HTTPS

[![GitHub stars](https://img.shields.io/github/stars/ChenYCL/docker-ollama-with-https.svg?style=social&label=Star&maxAge=2592000)](https://github.com/ChenYCL/docker-ollama-with-https/stargazers/)
[![GitHub forks](https://img.shields.io/github/forks/ChenYCL/docker-ollama-with-https.svg?style=social&label=Fork&maxAge=2592000)](https://github.com/ChenYCL/docker-ollama-with-https/network/)
[![GitHub issues](https://img.shields.io/github/issues/ChenYCL/docker-ollama-with-https.svg)](https://github.com/ChenYCL/docker-ollama-with-https/issues/)
[![GitHub license](https://img.shields.io/github/license/ChenYCL/docker-ollama-with-https.svg)](https://github.com/ChenYCL/docker-ollama-with-https/blob/main/LICENSE)
[![GitHub release](https://img.shields.io/github/release/ChenYCL/docker-ollama-with-https.svg)](https://github.com/ChenYCL/docker-ollama-with-https/releases/)

This project sets up Ollama with HTTPS support using Docker and Nginx.

## Prerequisites

- Docker
- Docker Compose
- OpenSSL (version 1.1.1 or higher)
- curl
- OrbStack(optional for MacOs)

## Using Ollama with OrbStack on macOS

### Prerequisites
- macOS
- OrbStack installed on your system

### Steps

1. Install OrbStack
   Ensure you have OrbStack installed on your macOS. If not, download and install it from the official OrbStack website.

2. Run Ollama Container
   Open a terminal and execute the following command:
   ```
   docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama
   ```
   This command runs the Ollama container in detached mode, maps the necessary volume and port.

3. Pull and Run a Model
   Replace `<modelname>` with your desired model (e.g., llama2, codellama, etc.):
   ```
   docker exec -it ollama ollama run <modelname>
   ```
   This command pulls the specified model and runs it within the Ollama container.

4. Test the Setup
   Use the following curl command to test the Ollama API:
   ```
   curl https://ollama.orb.local/v1/chat/completions \
       -H "Content-Type: application/json" \
       -d '{
           "model": "your_model_name",
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
   Replace `your_model_name` with the model you pulled in step 3.

### Notes
- OrbStack automatically manages the HTTPS connection, so you can use `https://ollama.orb.local` without additional setup.
- Ensure you have sufficient disk space for the Ollama images and models.
- The Ollama API will be accessible at `https://ollama.orb.local:11434`.

This setup provides a straightforward way to run Ollama with HTTPS support on macOS using OrbStack, simplifying the process compared to traditional Docker setups.

## Manual SetUp

1. Clone this repository:
   ```bash
   git clone https://github.com/ChenYCL/docker-ollama-with-https.git
   cd docker-ollama-with-https
   ```
Or just download directly and extract file.
 
 <img width="424" alt="image" src="https://github.com/user-attachments/assets/37de4c85-6f6c-43c6-8bbb-a32b9253836f">

2. Run the setup script:
   ```bash
   chmod +x setup_ollama_https.sh
   ./setup_ollama_https.sh
   ```

3. When prompted, enter the Ollama model names you want to use (comma-separated, e.g., qwen:4b,llama2:7b).

4. The script will create necessary files, start Docker containers, and pull the specified models.

5. To trust the self-signed certificate on your system, run:
   ```bash
   chmod +x install_cert.sh
   sudo ./install_cert.sh
   ```

6. Access Ollama at `https://localhost:11434`.

## Testing

You can test the setup using curl:

```bash
curl  https://localhost:11434/v1/chat/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "your_model_name",
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

Replace `your_model_name` with one of the models you specified during setup.

## Cleanup

To stop and remove the containers:
```bash
cd ollama_https_setup && docker-compose down
```

To remove all generated files:
```bash
cd .. && rm -rf ollama_https_setup
```

## Notes and Considerations

1. This setup uses a self-signed certificate, suitable for development and testing only.
2. You may need to restart your browser or system after running `install_cert.sh`.
3. Some applications may require additional steps to trust the certificate.
4. The `-k` option in curl bypasses certificate verification (not recommended for production).
5. For production, always use valid SSL certificates and proper verification.
6. Regularly update your Ollama images and models.
7. This setup is designed for local use. Additional security measures are needed for internet exposure.
8. The default port is 11434. Modify `nginx.conf` and `docker-compose.yml` to change it.

## Troubleshooting

- If certificate trust issues occur, ensure you've run `install_cert.sh` and restarted your browser.
- For Docker-related issues, check if Docker and Docker Compose are properly installed and running.
- If models fail to pull, check your internet connection and ensure sufficient disk space.

## Contributing

Contributions are welcome! Please submit issues and pull requests on the GitHub repository.

## License

This project is licensed under the [MIT License](LICENSE).

---

[![Star History Chart](https://api.star-history.com/svg?repos=ChenYCL/docker-ollama-with-https&type=Date)](https://star-history.com/#ChenYCL/docker-ollama-with-https&Date)

