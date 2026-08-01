<p align="center">
  <img src="images/github-banner-ai-lab.png" alt="MiniRack AI Lab Header" width="100%">
</p>

# MiniRack AI Lab

This repository contains the Ansible automation used to prepare and deploy the MiniRack AI Lab environment.

## Host Groups

The current inventory defines the following groups:

- `all` — all managed hosts
- `ai-core` — hosts the Ollama runtime and core AI workloads
- `ai-web` — hosts the web interface and AI harness services
- `ai-utility` — hosts supporting monitoring and management tooling

## Deployment Flow

The playbook is structured in three phases:

1. System preparation on all hosts
   - package patching and updates
   - base system configuration
   - SSH hardening

2. Ollama deployment on the `ai-core` group
   - the playbook imports the Ollama task file for the `ai-core` hosts

3. Docker deployment on the `ai-web` and `ai-utility` groups
   - Docker repository trust setup
   - Docker Engine and Compose install
   - Docker service enablement and startup

## Execution

From the repository root, run either of the following:

```bash
ansible-playbook -i inventory/servers.ini main.yml -u localadmin -k -K
```

or the repository helper script:

```bash
./scripts/ansible-execute.bash
```

Both flows prompt for:

- the SSH password for `localadmin`
- the sudo password for privilege escalation

## Repository Layout

- `main.yml` — orchestration entrypoint
- `inventory/servers.ini` — host inventory and group mapping
- `tasks/system-updates.yaml` — package patching and reboot-related actions
- `tasks/system-config.yaml` — base system settings and SSH hardening
- `tasks/app-ollama.yaml` — Ollama deployment task file
- `tasks/app-docker.yaml` — Docker repository, install, and service setup

## Notes

- The playbook should be run from the repository root.
- The repository currently uses password-based SSH and sudo prompts, so the `-k` and `-K` options are required.
- The `ai-core` Ollama task file is included in the orchestration flow and should be populated with the final install logic when that deployment is ready.