#!/bin/bash
# Bug Bounty Stack Setup Script

echo "=== Bug Bounty Stack Setup ==="

# Asset discovery
echo "[1/6] Installing asset discovery tools..."
go install github.com/owasp-amass/amass/v4/...@master 2>/dev/null
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null
go install github.com/projectdiscovery/uncover/cmd/uncover@latest 2>/dev/null

# Live detection
echo "[2/6] Installing live detection..."
go install github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null

# Fuzzing
echo "[3/6] Installing fuzzing tools..."
go install github.com/ffuf/ffuf/v2@latest 2>/dev/null
pip install dirsearch 2>/dev/null

# Vulnerability scanning
echo "[4/6] Installing vulnerability scanners..."
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest 2>/dev/null
go install github.com/hahwul/dalfox/v2@latest 2>/dev/null

# Update nuclei templates
echo "[5/6] Updating nuclei templates..."
nuclei -update-templates 2>/dev/null

# Secret monitoring
echo "[6/6] Installing secret monitors..."
brew install trufflehog 2>/dev/null || go install github.com/trufflesecurity/trufflehog/v3@latest 2>/dev/null
git clone https://github.com/hisxo/gitGraber.git ~/.local/share/gitGraber 2>/dev/null

# Download wordlists
echo "[+] Downloading wordlists..."
mkdir -p wordlists
curl -sL https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt -o wordlists/subdomains.txt 2>/dev/null
curl -sL https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt -o wordlists/directories.txt 2>/dev/null

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Optional: Install reconftw for full automation"
echo "  git clone https://github.com/six2dez/reconftw"
echo "  cd reconftw && ./install.sh"
echo ""
echo "Configure API keys in config/api-keys.yaml"
echo ""
echo "Start with: /bounty <target>"
