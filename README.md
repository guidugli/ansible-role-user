Ansible Role: User
=========

An Ansible Role that sets login definitions, user policies and also perform security checks related to users and groups.
Target systems: RHEL/CentOS, Fedora, and Debian/Ubuntu.

Requirements
------------

No additional requirements.

Role Variables
--------------

**Available variables are listed below, along with default values (see defaults/main.yml):**

    user_new_password: "{{ vault_admin_password }}"

If the password of the user running ansible changes, this variable needs to have the new password, so ansible_become_pass and ansible_ssh_pass can be updated. Recommended to store the password on another file and encrypt it with vault.

    user_configure_single_user: no

Indicates if single user mode is to be configured (needs to have root password set)

    user_max_days: 365

Number of days before password expire

    user_min_days: 7

Number of days until user is allowed to change password

    user_inactive_days: 30

Number of days before user is considered inactive

    user_warn_age: 7

Number of days before password expire that will generate a warning to the user

    user_umask: '027'

UMASK to be used by all users

    user_shell_timeout: 900

Shell timeout in seconds

    user_fix_existing_accounts: yes

If set to true/yes it will perform security checks on users and groups.

    root_password: ''

Sets the root password.

    user_account_add: []
      #- name: example
      #  comment: This is an example
      #  uid: 1076
      #  groups: ['admin']
      #  shell: /bin/bash
      #  password: encpwd

Add/Change the specified accounts. Default value is empty list. The lines above that are commented show an example on how to specify an entry.

    user_account_remove: []
      #- acc_to_be_removed

List of user names to be removed from the system.

    user_group_add: []
    #  - name: admin
    #    gid: 760

Add the specified groups to the system. Default is empty list. The lines above that are commented show an example on how to specify an entry. The only mandatory parameter for each user entry is the name (username) field. Other available parameters are: comment, uid, group (primary group), groups(other groups), shell, password, linger. 
The linger option can enable user lingering (check loginctl command for more information on user lingering). If linger is not specified, lingering will not be changed. If set to false, lingering will be disabled. If set to true, lingering will be enabled.
NOTE: linger will not work on containers because it needs systemd and dbus.

    user_group_remove: []
    #  - mygroup

Remove the specified groups from the system.

    user_alias: []
    #  - user: example
    #    alias: ll
    #    command: ls -l --color=auto
    #    state: present

Specify aliases to be created/removed from user's bashrc file. Command is not required when state is absent. Default is empty list. The lines above that are commented show an example on how to specify an entry.


Dependencies
------------

No dependencies.

Example Playbook
----------------

    - hosts: servers
      vars:
        user_max_days: 365
        user_min_days: 7
        user_inactive_days: 30
        user_warn_age: 7
        user_umask: '027'
        user_shell_timeout: 900
        user_fix_existing_accounts: yes
        root_password: mypass
        user_account_add:
          - name: example
            comment: This is an example
            uid: 1076
            groups: ['admin']
            shell: /bin/bash
            password: encpwd
            linger: false
        user_account_remove:
          - removeme
        user_group_add:
          - name: admin
            gid: 760
        user_group_remove:
          - mygroup
        user_alias:
          - user: example
            alias: myls
            command: ls -l --color=auto
            state: present

      roles:
         - { role: guidugli.user }

License
-------

MIT / BSD

Author Information
------------------

This role was created in 2020 by Carlos Guidugli.
