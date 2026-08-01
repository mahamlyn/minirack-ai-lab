<p align="center">
  <img src="images/github-banner-ai-lab.png" alt="MiniRack AI Lab Header" width="100%">
</p>

# Overview

This repository contains the Ansible playbooks used to deploy the MiniRack AI Lab environment.

The environment is organised into three host groups:

- `ai-core` — hosts the Ollama runtime and core AI workloads
- `ai-web` — hosts the web interface and AI harness services
- `ai-utility` — hosts supporting monitoring and management tooling

# Deployment Flow

The playbook is structured in two phases:

1. General system preparation
   - package patching and updates
   - base system configuration
   - SSH hardening

2. Targeted application deployment
   - Docker installation on the web and utility hosts
   - additional service deployment tasks for the selected host groups

# Manual Deployment

From the repository root, run:

```bash
ansible-playbook -i inventory/servers.ini main.yml -u localadmin -k -K
```

This will prompt for:

- the SSH password for `localadmin`
- the sudo password for privilege escalation

# Notes

- The playbook is intended to be run from the repository root.
- Inventory and host-group targeting are defined in `inventory/servers.ini`.
- The main orchestration entrypoint is `main.yml`.