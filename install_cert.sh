#!/bin/bash

CERT_FILE="ollama_https_setup/certs/localhost.crt"

if [ ! -f "$CERT_FILE" ]; then
    echo "Certificate file not found: $CERT_FILE"
    exit 1
fi

case "$(uname -s)" in
    Darwin*)
        # macOS
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERT_FILE"
        echo "Certificate added to macOS Keychain. You may need to restart your browser."
        ;;
    Linux*)
        # Linux
        sudo cp "$CERT_FILE" /usr/local/share/ca-certificates/localhost.crt
        sudo update-ca-certificates
        echo "Certificate added to Linux trust store. You may need to restart your browser."
        ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*)
        # Windows
        certutil -addstore -f "ROOT" "$CERT_FILE"
        echo "Certificate added to Windows trust store. You may need to restart your browser."
        ;;
    *)
        echo "Unknown operating system"
        exit 1
        ;;
esac

echo "Certificate has been added to the trust store."
