# MiniRack AI Lab - Documentation Index

## Overview

All project documentation is organized in the `documentation/` folder for easy access and maintenance.

## Available Documentation

### 1. [SECURITY.md](./SECURITY.md)
**Audience:** Everyone deploying the project  
**Length:** ~6 KB  
**Topics covered:**
- SSH Host Key Verification procedures
- Hermes Agent installation security
- Obtaining and verifying installer checksums
- Network security recommendations
- SSH hardening details
- Audit and monitoring guidance
- Incident response procedures

**Key sections:**
- SSH Host Key Verification
- Hermes Agent Installation
- Network Security Recommendations
- SSH Hardening
- Audit Recommendations
- Incident Response

---

### 2. [DEPLOYMENT.md](./DEPLOYMENT.md)
**Audience:** Anyone deploying the MiniRack AI Lab  
**Length:** ~10 KB  
**Topics covered:**
- Pre-deployment requirements and checklist
- Step-by-step deployment instructions
- Monitoring deployment progress
- Post-deployment verification
- Comprehensive troubleshooting guide
- Re-running and customizing deployment
- Support resources

**Key sections:**
- Pre-Deployment Requirements (SSH keys, Hermes checksum)
- Deployment Steps (running the playbook, monitoring, verification)
- Post-Deployment Verification (testing each service)
- Troubleshooting (common issues and solutions)
- Customization (changing models, network addresses, authentication)

---

## Quick Start

### First Time Deploying?

1. Read: [DEPLOYMENT.md](./DEPLOYMENT.md) - **Pre-Deployment Requirements** section
2. Read: [SECURITY.md](./SECURITY.md) - **SSH Host Key Verification** section
3. Follow: [DEPLOYMENT.md](./DEPLOYMENT.md) - **Deployment Steps** section

### Need Help with Deployment?

Check [DEPLOYMENT.md](./DEPLOYMENT.md) - **Troubleshooting** section

### Want to Understand Security?

Read [SECURITY.md](./SECURITY.md) for comprehensive security information

---

## Documentation Structure

```
minirack-ai-lab/
├── documentation/
│   ├── INDEX.md (this file)
│   ├── SECURITY.md
│   └── DEPLOYMENT.md
├── README.md (links to documentation)
├── main.yml
├── inventory/
├── config-files/
├── scripts/
└── tasks/
```

---

## Adding New Documentation

When adding new documentation to the project:

1. Create the file in the `documentation/` folder
2. Add a link to it in this INDEX.md file
3. Link to it from the main [README.md](../README.md) if it's commonly needed

---

## Related Files

**Configuration files:**
- `config-files/config.yaml` - Project configuration variables
- `ansible.cfg` - Ansible configuration (SSH verification enabled)

**Scripts:**
- `scripts/verify-hermes-checksum.sh` - Helper to verify Hermes installer
- `scripts/ansible-execute.bash` - Main deployment script

**Automation:**
- `main.yml` - Main Ansible playbook
- `tasks/` - Individual task files
- `inventory/servers.ini` - Host inventory

---

## Support & References

**Official documentation:**
- Ansible: https://docs.ansible.com/
- Ollama: https://github.com/ollama/ollama
- Open WebUI: https://docs.openwebui.com/
- Hermes: https://hermes-agent.nousresearch.com/

---

**Version:** 1.0  
**Last Updated:** 2026-11-16
