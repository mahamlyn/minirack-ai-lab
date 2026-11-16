# MiniRack AI Lab - Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying the MiniRack AI Lab environment across three hosts using Ansible automation.

## Pre-Deployment Requirements

### 1. Accept SSH Host Keys

Before running the playbook, you must pre-approve SSH host keys from all three target servers. This enables SSH host key verification for security (prevents man-in-the-middle attacks).

```bash
ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.160
ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.161
ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.162
```

**What to expect:**
- You'll be prompted for the SSH password
- Host keys will be automatically added to `~/.ssh/known_hosts`
- Each command should return successfully without errors

**Troubleshooting:**
- If you get "Connection refused": Check that SSH is running on the target servers
- If you get "Connection timed out": Check network connectivity to the hosts
- If you get "Permission denied": Verify the username and password are correct

### 2. Configure Hermes Installer Checksum

The Hermes agent installer must be verified before execution (security requirement). Use the provided helper script to obtain the checksum:

```bash
./scripts/verify-hermes-checksum.sh
```

This script will:
1. Download the official Hermes installer from https://hermes-agent.nousresearch.com/install.sh
2. Calculate its SHA256 checksum
3. Display the checksum and show how to configure it

**Update the configuration:**
1. Edit `config-files/config.yaml`
2. Find the line: `hermes_install_checksum: "sha256:PLACEHOLDER_CHECKSUM_VALUE"`
3. Replace with the actual checksum, for example: `hermes_install_checksum: "sha256:abc123def456xyz"`

**Verify the change:**
```bash
grep hermes_install_checksum config-files/config.yaml
# Should output: hermes_install_checksum: "sha256:abc123def456xyz"
```

### 3. Review Security Considerations

Before deployment, review [SECURITY.md](./SECURITY.md) for:
- SSH hardening details
- Hermes installation security
- Network security recommendations
- Incident response procedures

## Deployment Steps

### Step 1: Run the Deployment Script

From the repository root, run the helper script:

```bash
./scripts/ansible-execute.bash
```

This script will:
1. Change to the repository root directory
2. Run the Ansible playbook with the correct inventory and credentials
3. Prompt for SSH password for `localadmin`
4. Prompt for sudo password for privilege escalation

**Expected output:**
- Initial system discovery on all hosts
- Package updates and system configuration
- Ollama installation and model download (this takes time)
- Docker installation on application hosts
- Open WebUI deployment
- Hermes agent installation

**Expected duration:**
- Initial run: 45-90 minutes (depending on network speed and system resources)
- Subsequent runs: 5-15 minutes (if only configuration changes)
- Note: Ollama model download (llama3.2 ~7GB) can take 30+ minutes on slower connections

### Step 2: Monitor Deployment

The playbook provides output for each step. Key things to monitor:

- ✅ All `ok` or `changed` statuses indicate success
- ⚠️ `warning` messages are informational and usually safe to continue
- ❌ `failed` or `error` statuses indicate a problem (see Troubleshooting)

**Example successful task:**
```
TASK [Ollama Installation | Pull configured AI model] ****
ok: [192.168.1.160] => {
    "changed": false,
    "msg": "File already exists"
}
```

### Step 3: Wait for Completion

The deployment will show a summary at the end:

```
PLAY RECAP ****
192.168.1.160 : ok=XX  changed=X  unreachable=0  failed=0
192.168.1.161 : ok=XX  changed=X  unreachable=0  failed=0
192.168.1.162 : ok=XX  changed=X  unreachable=0  failed=0
```

If all hosts show `failed=0`, the deployment was successful!

## Post-Deployment Verification

After successful deployment, verify that all services are running:

### 1. Test Ollama Service

```bash
ssh localadmin@192.168.1.160 "ollama list"
```

Expected output: Shows installed models (should include llama3.2)

### 2. Test Open WebUI

**From your workstation:**
```bash
curl -s http://192.168.1.162:3000 | head -20
```

Then open your browser: http://192.168.1.162:3000

Expected: Open WebUI login page (or main interface if authentication is disabled)

### 3. Test Hermes Agent

```bash
ssh localadmin@192.168.1.162 "hermes-agent --version"
```

Expected output: Version information for Hermes

### 4. Check Docker Services

```bash
ssh localadmin@192.168.1.162 "docker ps"
```

Expected output: Running containers including `open-webui`

### 5. Review System Logs

Check for any warnings or errors:

```bash
# Ollama logs
ssh localadmin@192.168.1.160 "journalctl -u ollama -n 50"

# Docker Open WebUI logs
ssh localadmin@192.168.1.162 "docker logs open-webui"

# System logs
ssh localadmin@192.168.1.160 "tail -100 /var/log/syslog"
```

## Troubleshooting

### "Host key verification failed"

**Cause:** SSH host keys not pre-approved before deployment

**Solution:**
```bash
# Run the pre-approval commands
ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.160
ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.161
ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.162

# Then re-run deployment
./scripts/ansible-execute.bash
```

### "Checksum mismatch" error during Hermes installation

**Cause:** Downloaded installer doesn't match configured checksum

**Possible reasons:**
- Official installer was updated
- Network corruption during download
- Incorrect or outdated checksum in config

**Solution:**
1. Recalculate the checksum:
   ```bash
   ./scripts/verify-hermes-checksum.sh
   ```

2. Update `config-files/config.yaml` with the new checksum

3. Re-run deployment:
   ```bash
   ./scripts/ansible-execute.bash
   ```

### Ollama model download is very slow or times out

**Expected behavior:** 
- llama3.2 model is 7+ GB
- Download can take 30+ minutes on slower connections
- Initial pull is a one-time operation

**Solution:**
1. Let the deployment complete; don't interrupt it
2. If it times out, SSH to the Ollama host and monitor manually:
   ```bash
   ssh localadmin@192.168.1.160
   journalctl -u ollama -f
   ```

3. If you need to restart: Re-run the playbook, it will resume where it left off

### Open WebUI doesn't respond on port 3000

**Check status:**
```bash
ssh localadmin@192.168.1.162
docker compose -f /data/projects/open-webui/docker-compose.yaml ps
docker compose -f /data/projects/open-webui/docker-compose.yaml logs open-webui -n 50
```

**Common issues:**
- Docker service not started: `docker start open-webui`
- Port conflict: Check if another service is using port 3000
- Container failed: Review logs for startup errors

**Recovery:**
```bash
# Restart the service
ssh localadmin@192.168.1.162
docker compose -f /data/projects/open-webui/docker-compose.yaml restart

# Wait for health checks
sleep 30
docker compose -f /data/projects/open-webui/docker-compose.yaml ps
```

### SSH connection hangs or times out

**Cause:** SSH configuration changes or service issues

**Solution:**
1. Check if SSH service is running:
   ```bash
   ssh -v localadmin@192.168.1.160  # verbose mode
   ```

2. SSH keys should be pre-approved, but if issues persist:
   ```bash
   # Reset known_hosts for a specific host
   ssh-keygen -R 192.168.1.160
   # Then re-approve
   ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.160
   ```

### Deployment fails with "insufficient disk space" error

**Cause:** One of the hosts doesn't have enough free space

**Check available space:**
```bash
# On each host
ssh localadmin@192.168.1.160 "df -h"
ssh localadmin@192.168.1.161 "df -h"
ssh localadmin@192.168.1.162 "df -h"
```

**Minimum requirements:**
- Each host: 50+ GB free space (for Docker images and Ollama models)
- Ollama host (192.168.1.160): 100+ GB recommended (for model storage)

**Solution:**
1. Free up space on affected hosts
2. Re-run deployment:
   ```bash
   ./scripts/ansible-execute.bash
   ```

### Task fails with "permission denied"

**Cause:** Sudo issues or file permissions

**Solution:**
1. Verify sudo is working:
   ```bash
   ssh localadmin@192.168.1.160 "sudo whoami"
   # Should output: root
   ```

2. If that works, try deployment again (sometimes sudo takes time)

3. If it still fails, check sudo configuration on the host

## Re-running Deployment

The playbook is idempotent, meaning you can run it multiple times safely:

```bash
./scripts/ansible-execute.bash
```

**Behavior:**
- Tasks that have already completed will show `ok` (no changes)
- Only tasks with configuration changes will show `changed`
- This allows you to:
  - Verify everything is still working
  - Apply configuration updates
  - Recover from temporary failures

## Customization

### Changing the AI Model

Edit `config-files/config.yaml`:

```yaml
ollama_model: mistral  # Change from llama3.2 to mistral (or any Ollama model)
```

Then re-run deployment to pull the new model.

### Changing Network Addresses

Edit `inventory/servers.ini`:

```ini
[all]
<your-server-ip-1>  # Replace 192.168.1.160
<your-server-ip-2>  # Replace 192.168.1.161
<your-server-ip-3>  # Replace 192.168.1.162

[ai-core]
<your-server-ip-1>

[ai-web]
<your-server-ip-3>

[ai-utility]
<your-server-ip-2>
```

### Enabling Open WebUI Authentication

Edit `config-files/open-webui/docker-compose.yaml`:

```yaml
WEBUI_AUTH: "True"  # Change from "False" to "True"
```

Then re-run deployment.

## Support

For detailed security information, see [SECURITY.md](./SECURITY.md).

For project overview, see the main [README.md](../README.md).

For official documentation:
- Ansible: https://docs.ansible.com/
- Ollama: https://github.com/ollama/ollama
- Open WebUI: https://docs.openwebui.com/
- Hermes: https://hermes-agent.nousresearch.com/

---

**Version:** 1.0  
**Last Updated:** 2026-11-16  
**Status:** Ready for deployment
