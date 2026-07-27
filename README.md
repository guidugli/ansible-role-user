[![CI](https://github.com/guidugli/ansible-role-user/actions/workflows/CI.yml/badge.svg)](https://github.com/guidugli/ansible-role-user/actions/workflows/CI.yml)
[![Release](https://img.shields.io/github/v/tag/guidugli/ansible-role-user?sort=semver)](https://github.com/guidugli/ansible-role-user/tags)
[![Galaxy](https://img.shields.io/badge/galaxy-guidugli.user-blue.svg)](https://galaxy.ansible.com/ui/standalone/roles/guidugli/user/)
[![License](https://img.shields.io/github/license/guidugli/ansible-role-user)](LICENSE)

# Ansible Role: user

Manage local Linux users, groups, password-aging defaults, shell timeout, default umask, and CIS-aligned user account checks.
The role is intentionally privilege-neutral: it never sets `become`, `become_user`, or `become_method` inside role tasks. Callers decide whether privilege escalation is required.

## Requirements

- Ansible Core 2.14 or newer according to role metadata.
- Linux target with local account files such as `/etc/passwd`, `/etc/group`, `/etc/shadow`, and `/etc/login.defs`.
- Root-level permissions are required for most configuration and remediation tasks. Supply privilege externally in your playbook or automation platform.
- The `containers.podman` collection is required for Molecule container scenarios and is pinned in `requirements.yml` with a minimum version.

## Variables

| Variable | Type | Default | Description |
|---|---:|---:|---|
| `user_skip_config` | bool | `false` | Skip login definition and account-hardening configuration. User and group management still runs. |
| `user_new_password` | string | `""` | Optional value used to refresh `ansible_become_pass` after a controlled password rotation. Store sensitive values in Ansible Vault. |
| `user_configure_single_user` | bool | `false` | Configure systemd rescue/emergency units to use `systemd-sulogin-shell`. Applies only on systemd hosts. |
| `user_max_days` | int | `365` | Sets `PASS_MAX_DAYS`. CIS RHEL 10 guidance expects a value greater than 0 and not more than 365. |
| `user_min_days` | int | `7` | Sets `PASS_MIN_DAYS`. CIS guidance expects a value greater than 0. |
| `user_inactive_days` | int | `30` | Sets the default inactive account lock period with `useradd -D -f`. CIS RHEL 10 allows no more than 45 days. |
| `user_warn_age` | int | `7` | Sets `PASS_WARN_AGE`. CIS guidance expects 7 or more days. |
| `user_umask` | string | `"027"` | Sets `UMASK` and a profile drop-in. CIS guidance expects `027` or more restrictive. |
| `user_shell_timeout` | int | `900` | Sets `TMOUT` through `/etc/profile.d/50-user-tmout.sh`. CIS guidance expects no more than 900 seconds. |
| `user_fix_existing_accounts` | bool | `true` | Remediate existing local user aging settings where deterministic, and fail with a clear report when manual remediation is required. |
| `user_encrypt_method` | string | `"YESCRYPT"` | Sets `ENCRYPT_METHOD`. CIS RHEL 10 accepts `SHA512` or `YESCRYPT`; this role defaults to `YESCRYPT`. |
| `user_sha_crypt_max_rounds` | raw | `null` | Optional `SHA_CRYPT_MAX_ROUNDS` entry in `/etc/login.defs`. |
| `user_bcrypt_min_rounds` | raw | `null` | Optional `BCRYPT_MIN_ROUNDS` entry in `/etc/login.defs`. |
| `user_bcrypt_max_rounds` | raw | `null` | Optional `BCRYPT_MAX_ROUNDS` entry in `/etc/login.defs`. |
| `user_yescrypt_cost_factor` | raw | `null` | Optional `YESCRYPT_COST_FACTOR` entry in `/etc/login.defs`. |
| `root_password` | string | `""` | Optional root password hash. Leave empty to avoid changing the root password. |
| `user_account_add` | list(dict) | `[]` | Users to create/update. Supports common `ansible.builtin.user` options plus `linger` for systemd lingering. |
| `user_account_remove` | list(string) | `[]` | User names to remove. |
| `user_group_add` | list(dict) | `[]` | Groups to create/update. Each item requires `name`; `gid` is optional. |
| `user_group_remove` | list(string) | `[]` | Group names to remove. |
| `user_alias` | list(dict) | `[]` | Bash aliases to add/remove. Each item uses `user`, `alias`, `state`, and `command` when `state: present`. |

## Example Playbook

```yaml
---
- name: Configure local user security policy
  hosts: servers
  become: true
  vars:
    user_max_days: 365
    user_min_days: 7
    user_inactive_days: 30
    user_warn_age: 7
    user_umask: "027"
    user_shell_timeout: 900
    user_encrypt_method: YESCRYPT
    user_account_add:
      - name: example
        comment: Example account
        uid: 1076
        groups:
          - admin
        shell: /bin/bash
        password: "$6$example-hash"
        linger: false
    user_group_add:
      - name: admin
        gid: 760
    user_alias:
      - user: example
        alias: ll
        command: ls -l --color=auto
        state: present
  roles:
    - role: guidugli.user
```

## Molecule Testing

The role uses shared Molecule converge and verify playbooks under `molecule/shared/` with default and systemd scenarios. The scenario inventories are generator-managed and should not be edited directly.

Typical local validation commands:

```bash
ansible-galaxy collection install -r requirements.yml
molecule test -s default
molecule test -s systemd
```

The shared verify playbook checks password-aging entries, hashing method, `UMASK`, and profile drop-ins for `TMOUT` and umask.

## Execution Notes

- **Privilege model:** the role never declares `become`. Use `become: true` at the play, inventory, or automation-controller level for real hosts where `/etc`, `/usr`, `/var`, account management, or password-aging changes require elevated privileges.
- **Container behavior:** Molecule containers generally execute as root and use `become: false` in scenario playbooks. Role tasks do not assume privilege escalation.
- **Systemd behavior:** systemd-specific tasks are guarded with `ansible_facts['service_mgr'] == 'systemd'`. User lingering is attempted only when `loginctl` is available. Rescue/emergency unit edits are skipped on non-systemd hosts.
- **CIS alignment:** defaults are selected to align with the included RHEL 10 CIS user-account guidance for password aging, inactive lock, hashing method, root/system account checks, shell timeout, and umask. Debian 13 benchmark content was not text-extractable in the provided attachment, so Debian-specific claims are limited to generic Linux-account behavior.
