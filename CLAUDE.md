# Bug Bounty Automation Stack

Zero-to-finding automation pipeline for bug bounty hunting. Combines reconnaissance, vulnerability scanning, and real-time secret monitoring.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Bug Bounty Stack                           │
├─────────────────────────────────────────────────────────────┤
│  Phase 1: Asset Discovery                                    │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐            │
│  │ amass  │  │uncover │  │subfinder│  │  assetfinder│       │
│  └───┬────┘  └───┬────┘  └───┬────┘  └───┬────┘            │
│      └───────────┴───────────┴───────────┘                  │
│                          ▼                                  │
├─────────────────────────────────────────────────────────────┤
│  Phase 2: Recursive Recon                                    │
│  ┌─────────────────────────────────────────────┐            │
│  │              reconftw / bbot                 │            │
│  │  (orchestrates httpx, nuclei, ffuf, etc.)   │            │
│  └─────────────────────┬───────────────────────┘            │
│                        ▼                                    │
├─────────────────────────────────────────────────────────────┤
│  Phase 3: Vulnerability Detection                            │
│  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐            │
│  │scan4all│  │ nuclei │  │ nikto  │  │ dalfox │            │
│  │(15K PoC)│  │        │  │        │  │ (XSS)  │            │
│  └───┬────┘  └───┬────┘  └───┬────┘  └───┬────┘            │
│      └───────────┴───────────┴───────────┘                  │
│                          ▼                                  │
├─────────────────────────────────────────────────────────────┤
│  Phase 4: Secret Monitoring (Continuous)                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  gitGraber  │  │   shhgit    │  │ trufflehog  │         │
│  │ (real-time) │  │             │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│  Stealth Layer                                               │
│  ┌─────────────────────────────────────────────┐            │
│  │            CloakBrowser                      │            │
│  │  (bot detection bypass for manual testing)  │            │
│  └─────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Full pipeline on single target
/bounty example.com

# Subdomain-only recon
/bounty-recon example.com

# Scan known subdomains
/bounty-scan subdomains.txt

# Monitor for secrets
/bounty-monitor "target-org"
```

## Tools Integration

### Asset Discovery

| Tool | Purpose | Install |
|------|---------|---------|
| [amass](https://github.com/owasp-amass/amass) | Attack surface mapping | `go install github.com/owasp-amass/amass/v4/...@master` |
| [uncover](https://github.com/projectdiscovery/uncover) | Multi-engine search | `go install github.com/projectdiscovery/uncover/cmd/uncover@latest` |
| [subfinder](https://github.com/projectdiscovery/subfinder) | Subdomain enum | `go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest` |

### Recursive Recon

| Tool | Purpose | Install |
|------|---------|---------|
| [reconftw](https://github.com/six2dez/reconftw) | Automated recon | `git clone` + dependencies |
| [bbot](https://github.com/blacklanternsecurity/bbot) | Recursive scanner | `pip install bbot` |

### Fuzzing

| Tool | Purpose | Install |
|------|---------|---------|
| [ffuf](https://github.com/ffuf/ffuf) | Web fuzzer | `go install github.com/ffuf/ffuf/v2@latest` |
| [dirsearch](https://github.com/maurosoria/dirsearch) | Path scanner | `pip install dirsearch` |
| [gobuster](https://github.com/OJ/gobuster) | Dir/DNS busting | `go install github.com/OJ/gobuster/v3@latest` |

### Vulnerability Scanning

| Tool | Purpose | Install |
|------|---------|---------|
| [scan4all](https://github.com/GhostTroops/scan4all) | 15K+ PoCs | Go binary |
| [nuclei](https://github.com/projectdiscovery/nuclei) | Template scanner | `go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest` |
| [nikto](https://github.com/sullo/nikto) | Web scanner | `apt install nikto` |
| [dalfox](https://github.com/hahwul/dalfox) | XSS scanner | `go install github.com/hahwul/dalfox/v2@latest` |

### Secret Monitoring

| Tool | Purpose | Install |
|------|---------|---------|
| [gitGraber](https://github.com/hisxo/gitGraber) | Real-time GitHub | Python |
| [shhgit](https://github.com/eth0izzle/shhgit) | GitHub secrets | Go binary |
| [trufflehog](https://github.com/trufflesecurity/trufflehog) | Credential detection | Go binary |

### Stealth

| Tool | Purpose | Install |
|------|---------|---------|
| [CloakBrowser](https://github.com/CloakHQ/CloakBrowser) | Bot detection bypass | Playwright replacement |

### CVE Database

| Tool | Purpose | Install |
|------|---------|---------|
| [trickest/cve](https://github.com/trickest/cve) | Latest PoCs | Git clone |

## Workflow

### 1. Scope Definition
```bash
# Single domain
/bounty example.com

# Wildcard scope
/bounty "*.example.com"

# Multiple targets
/bounty --scope scope.txt
```

### 2. Asset Discovery
```bash
# Runs in parallel:
amass enum -passive -d example.com
subfinder -d example.com
uncover -q "ssl.cert.subject.CN:example.com"
```

### 3. Live Host Detection
```bash
cat all_subdomains.txt | httpx -silent -status-code -title -tech-detect
```

### 4. Recursive Recon
reconftw orchestrates:
- Screenshot capture
- Technology fingerprinting
- JavaScript analysis
- Parameter discovery
- Wayback URLs

### 5. Vulnerability Scanning
```bash
# scan4all for comprehensive coverage
scan4all -l live_hosts.txt

# nuclei for template-based scanning
nuclei -l live_hosts.txt -t nuclei-templates/

# dalfox for XSS
cat params.txt | dalfox pipe
```

### 6. Secret Monitoring
```bash
# Continuous monitoring
gitGraber.py -k "example.com,EXAMPLE_API" -s

# One-time scan
trufflehog github --org=example-org
```

## Output Structure

```
bounty-session/
├── scope.txt           # Target scope
├── subdomains.txt      # All discovered subdomains
├── live_hosts.txt      # Responding hosts
├── screenshots/        # Visual recon
├── js-analysis/        # JavaScript findings
├── nuclei-results/     # Vulnerability findings
├── secrets/            # Discovered credentials
└── report.md           # Final report
```

## Configuration

### API Keys
```yaml
# config/api-keys.yaml
shodan: <key>
censys_id: <id>
censys_secret: <secret>
github: <token>
virustotal: <key>
securitytrails: <key>
chaos: <key>
```

### Wordlists
```
wordlists/
├── subdomains.txt      # Subdomain bruteforce
├── directories.txt     # Common paths
├── parameters.txt      # Parameter fuzzing
├── api-endpoints.txt   # API paths
└── secrets-patterns.txt # Regex for secrets
```

## Skills

| Skill | Description |
|-------|-------------|
| /bounty | Full pipeline |
| /bounty-recon | Asset discovery only |
| /bounty-scan | Vulnerability scanning |
| /bounty-fuzz | Directory/parameter fuzzing |
| /bounty-secrets | Secret hunting |
| /bounty-monitor | Continuous monitoring |
| /bounty-report | Generate report |

## Tips

1. **Start narrow**: Begin with main domain, expand scope gradually
2. **Monitor continuously**: Run gitGraber 24/7 for real-time alerts
3. **Check CVE updates**: `trickest/cve` updates daily with new PoCs
4. **Use CloakBrowser**: When manual testing triggers bot detection
5. **Correlate findings**: One low finding + another = high impact chain
