---
name: bounty
description: Full bug bounty automation pipeline - recon to findings
version: "1.0"
author: anthonyonazure
---

# /bounty - Bug Bounty Pipeline

## Usage

```
/bounty <target>
/bounty example.com
/bounty "*.example.com" --scope-file scope.txt
/bounty --resume <session_id>
```

## Procedure

### 1. Scope Definition

Parse target:
- Single domain: `example.com`
- Wildcard: `*.example.com`
- Scope file: one target per line

```json
{
  "session_id": "<uuid>",
  "targets": ["example.com"],
  "scope": ["*.example.com"],
  "out_of_scope": ["blog.example.com"],
  "started_at": "<ISO8601>",
  "phase": "recon"
}
```

### 2. Asset Discovery

Run in parallel:
```bash
# amass - comprehensive
amass enum -passive -d <domain> -o amass.txt

# subfinder - fast
subfinder -d <domain> -silent -o subfinder.txt

# uncover - multi-engine
uncover -q "ssl.cert.subject.CN:<domain>" -o uncover.txt

# Merge and dedupe
cat amass.txt subfinder.txt uncover.txt | sort -u > all_subs.txt
```

### 3. Live Host Detection

```bash
# httpx with tech detection
cat all_subs.txt | httpx -silent -status-code -title -tech-detect -json -o live.json

# Extract live hosts
cat live.json | jq -r '.url' > live_hosts.txt
```

### 4. Recursive Recon

Choose one:

**Option A: reconftw (comprehensive)**
```bash
reconftw -d <domain> -a --deep -o reconftw_output/
```

**Option B: bbot (recursive)**
```bash
bbot -t <domain> -f safe -o bbot_output/
```

Both will run:
- Screenshot capture
- JavaScript analysis
- Parameter discovery
- Wayback mining
- Technology fingerprinting

### 5. Directory Fuzzing

```bash
# ffuf on live hosts
for url in $(cat live_hosts.txt); do
  ffuf -u "$url/FUZZ" -w wordlists/directories.txt \
    -mc 200,301,302,403 -o "fuzz_$(echo $url | md5sum | cut -d' ' -f1).json"
done
```

### 6. Vulnerability Scanning

```bash
# scan4all - 15K+ PoCs
scan4all -l live_hosts.txt -o scan4all_results/

# nuclei - template-based
nuclei -l live_hosts.txt -t nuclei-templates/ -o nuclei.txt

# XSS with dalfox
cat params.txt | dalfox pipe -o xss_results.txt
```

### 7. Secret Monitoring

```bash
# Start continuous monitor
gitGraber.py -k "<domain>,<org_name>" -s &

# One-time GitHub scan
trufflehog github --org=<org> --json > secrets.json
```

### 8. Finding Validation

For each potential finding:
1. Reproduce manually
2. Capture HTTP evidence
3. Assess impact
4. Check if in scope

```json
{
  "id": "BOUNTY-001",
  "type": "xss_reflected",
  "endpoint": "https://example.com/search?q=",
  "severity": "medium",
  "evidence": {
    "request": "...",
    "response": "...",
    "poc": "<script>alert(document.domain)</script>"
  }
}
```

### 9. Report Generation

```markdown
# Bug Bounty Report

## Target: example.com
## Researcher: <name>

### Summary
Found <n> vulnerabilities across <m> endpoints.

### Vulnerability: XSS in Search

**Severity**: Medium
**Endpoint**: https://example.com/search
**Parameter**: q

#### Description
The search parameter is reflected in the response without sanitization...

#### Proof of Concept
\`\`\`
https://example.com/search?q=<script>alert(document.domain)</script>
\`\`\`

#### Impact
- Session hijacking
- Credential theft
- Defacement

#### Remediation
Encode user input before reflection...
```

### 10. Output

```
[Bounty Stack] Pipeline complete
Target: <domain>

Recon:
  Subdomains: <n>
  Live hosts: <m>
  Endpoints: <p>

Findings:
  Critical: <n>
  High: <n>
  Medium: <n>
  Low: <n>

Secret monitoring: ACTIVE (gitGraber)

Reports: ./reports/
Next: Submit to program
```
