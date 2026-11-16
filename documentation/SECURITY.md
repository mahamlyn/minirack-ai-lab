# MiniRack AI Lab Security Guide

This document outlines security configurations and practices for the MiniRack AI Lab deployment.

## SSH Host Key Verification

**Current Configuration:** `host_key_checking = True` (enabled in `ansible.cfg`)

Host key verification is **enabled by default**. This prevents man-in-the-middle (MITM) attacks during SSH connections to target hosts.

### Initial Setup
When connecting to hosts for the first time, Ansible will verify SSH host keys. Ensure you:

1. Have accepted SSH host keys for all target hosts beforehand:
   ```bash
   ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.160
   ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.161
   ssh -o StrictHostKeyChecking=accept-new localadmin@192.168.1.162
   ```

2. Store host keys in `~/.ssh/known_hosts` for Ansible to verify against

### Disabling Host Key Checking (Not Recommended)
If you absolutely must disable host key checking for a specific run, use:
```bash
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory/servers.ini main.yml -u localadmin -k -K
```

**Warning:** Only do this in isolated lab environments. This introduces MITM vulnerability.

---

## Hermes Agent Installation

**Current Configuration:** Checksum verification enabled in `tasks/app-hermes.yaml`

The Hermes agent installer is downloaded from an external source and must be verified before execution.

### Obtaining the Current Checksum

The Hermes installer checksum must be obtained from an official source and configured in `config-files/config.yaml`.

#### Method 1: Download and Verify Directly
```bash
# Download the installer
curl -sL https://hermes-agent.nousresearch.com/install.sh -o /tmp/hermes-install.sh

# Calculate SHA256 checksum
sha256sum /tmp/hermes-install.sh
# Output: abc123def456... /tmp/hermes-install.sh
```

#### Method 2: Use curl with built-in checksum verification
```bash
curl -sL https://hermes-agent.nousresearch.com/install.sh | sha256sum
# Output: abc123def456... -
```

#### Method 3: Check Official Nous Research Sources
- Visit: https://hermes-agent.nousresearch.com/
- Look for official checksums or release notes

### Configuring the Checksum

1. Obtain the official SHA256 checksum from one of the methods above
2. Update `config-files/config.yaml`:
   ```yaml
   hermes_install_checksum: "sha256:YOUR_CHECKSUM_HERE"
   ```
   Replace `YOUR_CHECKSUM_HERE` with the actual checksum (without the filename)

3. Verify the value is correct before running the playbook:
   ```bash
   grep hermes_install_checksum config-files/config.yaml
   ```

### Deployment Behavior

- If the checksum verification **passes**, Hermes is installed
- If the checksum verification **fails**, deployment stops with an error (safe failure)
- If Hermes is already installed, the installation task is skipped

### Verifying Installation

After deployment, verify Hermes was installed correctly:
```bash
ssh localadmin@192.168.1.162 "hermes-agent --version"
```

---

## Network Security Recommendations

### 1. Ollama Service Exposure (Critical)
**Current:** `ollama_host: 0.0.0.0:11434`

This binds Ollama to all network interfaces. Consider:

- **Option A (Recommended):** Bind to localhost only
  ```yaml
  ollama_host: 127.0.0.1:11434
  ```
  Then access via SSH tunnel or restrict via firewall.

- **Option B:** Use firewall rules to restrict access
  ```bash
  sudo ufw allow from 192.168.1.162 to 192.168.1.160 port 11434
  sudo ufw deny from any to 192.168.1.160 port 11434
  ```

### 2. Open WebUI Authentication (Critical)
**Current:** `WEBUI_AUTH: False`

Authentication is currently **disabled**. This must be enabled in production:

```yaml
WEBUI_AUTH: "True"
```

After enabling, set up initial credentials through the web interface.

### 3. HTTPS/TLS for Web Interface
Consider deploying a reverse proxy (nginx/caddy) with SSL termination to encrypt web traffic.

---

## SSH Hardening

SSH has been hardened with the following settings applied in `tasks/system-config.yaml`:

- ✅ Root login disabled
- ✅ Empty passwords disabled
- ✅ TCP port forwarding disabled
- ✅ X11 forwarding disabled
- ✅ DNS lookups disabled
- ✅ Max auth retries limited to 4
- ✅ Login grace time set to 60 minutes

Review these settings in `/etc/ssh/sshd_config` on each host if adjustments are needed.

---

## File Integrity

Sensitive configuration files:
- `config-files/config.yaml` — Contains deployment configuration
- `config-files/open-webui/docker-compose.yaml` — Web UI configuration
- `inventory/servers.ini` — Host inventory

Protect these files in version control or add to `.gitignore` if containing sensitive data.

---

## Audit Recommendations

1. **Enable audit logging** on target hosts:
   ```bash
   sudo apt install auditd
   ```

2. **Monitor Docker activity**:
   ```bash
   docker logs open-webui --follow
   ```

3. **Monitor Ollama access logs**:
   ```bash
   journalctl -u ollama -f
   ```

4. **Review SSH logs**:
   ```bash
   sudo tail -f /var/log/auth.log
   ```

---

## Incident Response

If you suspect a security breach:

1. **Revoke SSH access** to affected hosts
2. **Review logs** for unauthorized access
3. **Re-deploy** clean hosts using the playbook
4. **Update checksums** if external sources are compromised
5. **Rotate credentials** (if any are exposed)

---

## References

- Ansible Security Best Practices: https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_best_practices.html
- Ubuntu SSH Hardening: https://wiki.ubuntu.com/Security/Features#SSH
- Ollama Documentation: https://github.com/ollama/ollama
- Open WebUI Documentation: https://docs.openwebui.com/

---

**Last Updated:** 2026-11-16

For security issues or concerns, review this document and the main `README.md` before deployment.
