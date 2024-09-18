# Configure a WSL2 Instance using Automation

- [Configure a WSL2 Instance using Automation](#configure-a-wsl2-instance-using-automation)
  - [Purpose](#purpose)
  - [Run as a GitHub Actions Workflow](#run-as-a-github-actions-workflow)
  - [Start a Dev Container](#start-a-dev-container)
  - [Inside the Dev Container](#inside-the-dev-container)
  - [Ansible](#ansible)
    - [Inventory](#inventory)
    - [Playbook](#playbook)
      - [Example Run](#example-run)
  - [Pre-Reqs](#pre-reqs)
    - [Install WSL and a default distribution](#install-wsl-and-a-default-distribution)
    - [Windows Terminal](#windows-terminal)
    - [VSCode](#vscode)
    - [SSH](#ssh)
    - [sudoers](#sudoers)
    - [Core packages](#core-packages)
    - [Git configuration](#git-configuration)
    - [Docker Desktop for Windows](#docker-desktop-for-windows)
    - [wsl.conf](#wslconf)
    - [.wslconfig](#wslconfig)
    - [public and private ssh keys](#public-and-private-ssh-keys)


## Purpose

1. Automate the configuration of a Windows Sub-system for Linux (WSL2) distro to use as a ***independant software development platform*** (IDP). The primary automation software used is **Ansible**.

2. To provide a simpler and more reproducble configuration, Ansible, and its dependencies will **NOT** be **installed** directly into the WSL instance, but instead will be run from a ***Dev Container***.

[Goto Top](#configure-a-wsl2-instance-using-automation)

## Run as a GitHub Actions Workflow

TODO

## Start a Dev Container

**IMPORTANT**

Ensure that you have met all of the [**pre-reqs**](#pre-reqs) described below in the WSL instance that you want to configure, **before running the automation**.

1. Open a WSL Terminal

2. Create a directory for the source code for THIS repository (you **could** just map to a folder in the Windows file syatem, but using WSL is significantly faster and consistent with the target OS environment).

Example:

```
mkdir homelab
cd homelab
```

3. Clone THIS repository

```
git clone https://github.com/goffinf/wsl2.git

Cloning into 'wsl2'...
remote: Enumerating objects: 45, done.
remote: Counting objects: 100% (45/45), done.
remote: Compressing objects: 100% (27/27), done.
remote: Total 45 (delta 16), reused 37 (delta 11), pack-reused 0 (from 0)
Receiving objects: 100% (45/45), 12.18 KiB | 1.74 MiB/s, done.
Resolving deltas: 100% (16/16), done.

cd wsl2
```
[Goto Top](#configure-a-wsl2-instance-using-automation)

4. Open VSCode

```
code .
```

5. If this is the first time you have run the WSL2 Ansible dev container you will need to [re]build all docker images with a declared build section in the docker-compose-xxx.yml file and pull any dependent images that don't exist in the WSL distro:

```
Press F1
Dev Containers: Rebuild Without Cache and Reopen in Container
```

You may also need to pull the **infra_ssh_files** image:

```
docker image pull goffinf/infra_ssh_files:000002
```

If you alreday have all images and do NOT need to recuild, you can just:

```
Press F1
Dev Containers: Reopen in Container
```

You should now have a running container with associated volumes:

```
docker container ls

CONTAINER ID   IMAGE                                 COMMAND                  CREATED      STATUS          PORTS     NAMES
3a853ef5cc93   goffinf/ansible:nossh-locale-000001   "/bin/sh -c 'echo Co…"   2 days ago   Up 56 seconds             ansible-nossh-locale

docker volume ls

DRIVER    VOLUME NAME
local     ansible_ssh_keys_ansible_locale
local     ansible_ssh_keys_root_locale
local     vscode
```

You will have a shell terminal (within VSCode) that is **within the running container** (at the configured location), e.g.

```
3a853ef5cc93:/workspaces/wsl2/ansible#
```

To **STOP** the dev container (it is not removed):

```
<LEFT-CLICK> on lower left corner : Dev Container

Reopen folder in WSL
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

## Inside the Dev Container

The terminal within VSCode is open in the **ansible** source code directory that is mapped to the dev container workspace:

```
3a853ef5cc93:/workspaces/wsl2/ansible#

```

When the dev container starts, the terminal within VSCode is at the file system location specified in the **devcontainer.json**.

E.g.

```
...
"workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}/ansible"
```

Which will resolve to:

```
/workspaces/wsl2/ansible
```

Breaking this down:

***/workspaces/wsl2*** relates to ***/workspaces/${localWorkspaceFolderBasename}*** which is the **git parent folder** (in this case **wsl2**).

***/ansible*** is ***relative*** to ***/workspaces/wsl2*** (i.e. an immediate child directory) 

The docker compose file also declares a corresponding volume mount (a relative path to the ***homelab*** directory parent of ***wsl2***)

```
volumes:
  - ../..:/workspaces:cached
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

## Ansible

You can confirm that Ansible is available by checking the version:

```
ansible --version

ansible [core 2.13.13]
  config file = /workspaces/wsl2/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.10.14 (main, Mar 23 2024, 12:43:01) [GCC 11.2.1 20220219]
  jinja version = 3.1.4
  libyaml = True
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

### Inventory

The Ansible inventory declares the [remote] hosts that are targets for the playbook(s). It is structured similarly to a ***.ini*** file and allows groups of hosts to be defined using either a valid **hostname** or **IP address**. Hostnames must be registered in the ***/etc/hosts** file. If you check this file in the container (and the WSL instance) you may not see any entires that correspond the the Windows hosts file (C:\Windows\System32\drivers\etc\hosts) however, they will still be accessible in both contexts when using the **default network settings**:

```
[network]
generateHosts = true
generateResolvConf = true
```

For example, if the Windows hosts file looked like this:

```
172.30.242.162 wsl2.local
192.168.0.16   diskstation
192.168.0.201  proxmox-001
192.168.0.210  proxmox-002
192.168.0.226  pi-hole
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

From **within** the **dev container** I could reach any of the hostnames:

```
3a853ef5cc93:/workspaces/wsl2/ansible# ping wsl2.local
PING wsl2.local (172.30.242.162): 56 data bytes
64 bytes from 172.30.242.162: seq=0 ttl=63 time=0.774 ms
64 bytes from 172.30.242.162: seq=1 ttl=63 time=3.099 ms
...

3a853ef5cc93:/workspaces/wsl2/ansible# ping diskstation
PING diskstation (192.168.0.16): 56 data bytes
64 bytes from 192.168.0.16: seq=0 ttl=63 time=1.606 ms
64 bytes from 192.168.0.16: seq=1 ttl=63 time=3.323 ms
...
```
For this playbook we need to reach the WSL instance which in this case is declared as the hostname **wsl2.local**

[Goto Top](#configure-a-wsl2-instance-using-automation)

In the **inventory.ini** we can specify wsl2.local as a target like this:

```
[wsl2]
wsl2.local

[all_hosts:children]
wsl2
...
```

The **all_hosts:children** section allows us to select which groups to include as targets without declaring each explicity. In this case only the **wsl2 group** will be used.

However, if we hadn't yet created the hostname target(s) we can just include the WSL instance IP addrerss (remember this is shared by ALL instances for a given distribution) like this:

```
[wsl2]
172.30.242.162

[all_hosts:children]
wsl2
...
```

**IMPORTANT**

**172.30.242.162** is the **IP address of the WSL instance NOT the dev container**

You can find the WSL instance IP address by opening a WSL terminal and using the **ip command**:

```
ip a show eth0

...
    inet 172.30.242.162/20 brd 172.30.255.255 scope global eth0
...
```

Now that the inventory is correct, its time to run the Ansible playbook.

[Goto Top](#configure-a-wsl2-instance-using-automation)

### Playbook

The Ansible playbook is declared within the ***main.yml** file.

To run the playbook use either of the following commands:

```
# DRY RUN
ansible-playbook main.yml --check --diff

# EXECUTE CHANGES
ansible-playbook main.yml
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

#### Example Run

```
3a853ef5cc93:/workspaces/wsl2/ansible# ansible-playbook main.yml

PLAY [Configure a WSL2 distro to be used as an Ansible installer base image] *****************************************************************************************************************************************************

TASK [Gathering Facts] ***********************************************************************************************************************************************************************************************************
ok: [wsl2.local]

TASK [Update apt cache] **********************************************************************************************************************************************************************************************************
changed: [wsl2.local]

TASK [Include OS-specific variables.] ********************************************************************************************************************************************************************************************
ok: [wsl2.local]

TASK [Install system packages] ***************************************************************************************************************************************************************************************************
changed: [wsl2.local]

TASK [Ensure ssh folder has correct permissions] *********************************************************************************************************************************************************************************
ok: [wsl2.local]

TASK [Remove existing known_hosts file from the ssh folder] **********************************************************************************************************************************************************************
ok: [wsl2.local]

TASK [Register all ssh folder files] *********************************************************************************************************************************************************************************************
ok: [wsl2.local]

TASK [Ensure ssh folder files have correct permissions] **************************************************************************************************************************************************************************
ok: [wsl2.local] => (item={'path': '/home/goffinf/.ssh/id_rsa', 'mode': '0600', 'isdir': False, 'ischr': False, 'isblk': False, 'isreg': True, 'isfifo': False, 'islnk': False, 'issock': False, 'uid': 1000, 'gid': 1000, 'size': 1675, 'inode': 11651, 'dev': 2112, 'nlink': 1, 'atime': 1724180195.6920447, 'mtime': 1724179877.116127, 'ctime': 1724179877.116127, 'gr_name': 'goffinf', 'pw_name': 'goffinf', 'wusr': True, 'rusr': True, 'xusr': False, 'wgrp': False, 'rgrp': False, 'xgrp': False, 'woth': False, 'roth': False, 'xoth': False, 'isuid': False, 'isgid': False})
...

TASK [Add wsl.conf] **************************************************************************************************************************************************************************************************************
ok: [wsl2.local]

TASK [git global config] *********************************************************************************************************************************************************************************************************
ok: [wsl2.local] => (item={'name': 'user.name', 'value': 'goffinf'})
ok: [wsl2.local] => (item={'name': 'user.email', 'value': 'goffinf@gmail.com'})
ok: [wsl2.local] => (item={'name': 'credential.helper', 'value': '/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe'})

TASK [Configure sudoers to enable the ansible user (ansible) to execute commands with escalated privileges and no password] ******************************************************************************************************
ok: [wsl2.local]

PLAY RECAP ***********************************************************************************************************************************************************************************************************************
wsl2.local                 : ok=14   changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

## Pre-Reqs

### Install WSL and a default distribution

Ensure you have installed ***WSL2*** and (at least) configured a default Ubuntu distribution following these [instructions](https://learn.microsoft.com/en-gb/windows/wsl/install).

### Windows Terminal

Install ***Windows Terminal*** (you can use git bash or Powershell, but Terminal is much easier) using these [instructions](https://learn.microsoft.com/en-us/windows/terminal/install)

[Goto Top](#configure-a-wsl2-instance-using-automation)

### VSCode

Install VSCode using these instructions [VSCode Installation for WIndows](#https://code.visualstudio.com/docs/setup/windows#_installation).

You will need to install the following VSCode extensions in order to integrate with WSL2 and use dev containers:

**Local**

- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Jinja](https://marketplace.visualstudio.com/items?itemName=wholroyd.jinja) (optional)
- [Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
- [Remote - SSH: Editing Configuration Files](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit)
- [Remote - Tunnels](https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-server)
- [Remote - Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
- [Remote Explorer](https://marketplace.visualstudio.com/items?itemName=ms-vscode.remote-explorer)
- [WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)

**WSL Distro (Ubuntu)**

- [Docker for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)

Optional:

- [GitHub Actions](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-github-actions)
- [GitHub Pull Requests](https://marketplace.visualstudio.com/items?itemName=GitHub.vscode-pull-request-github)
- [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)

### SSH

Generate an SSH public/private key-pair (or import an existing) and ensure you have SSH access to the distribution.

You can generate a key-pair (or more than one) from within a WSL terminal:

```
ssh-keygen
```
Then copy the public key to the ***authorised_key*** file using:

```
ssh-copy-id -i ~/.ssh/id_rsa.pub goffinf@localhost
```
Check:

```
cat .ssh/authorized_keys

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABg... goffinf@SURFACE4
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABA... goffinf@DESKTOP-LH5LG1V
...
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

You MAY need to update the default **SSHD config**.

First to enable ***Public Key Auth***:

```
...
# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

PubkeyAuthentication yes
...
# To disable tunneled clear text passwords, MWchange to no here!
#PasswordAuthentication yes
...
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

**NOTES:**

- You MAY need to restart the SSH servr or WSL itself (the WSL instance user MUST be in the **sudoers** group or you need to log into the instance as **root**).
  

In a WSL terminal for the instance:

```
systemctl restart ssh
```
 
Or to shutdown WSL (in a Windows command prompt)

```
wsl --shutdown
```

To log into WSL as the root user. From a Windows command prompt:

```

C:\Windows\System32>wsl -l -v

NAME                   STATE           VERSION
* Ubuntu                 Running         2
docker-desktop         Running         2
docker-desktop-data    Running         2

C:\Windows\System32>wsl -d Ubuntu -u root
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 5.15.153.1-microsoft-standard-WSL2 x86_64)

...

root@SURFACE4:/c/Windows/System32# whoami
root
```


- You MAY find that the SSH server will fail to start and requires the **host keys** to be regenerated using:

```
sudo ssh-keygen -A
```
[Goto Top](#configure-a-wsl2-instance-using-automation)

### sudoers

The default user created for the WSL instance needs to be added to the sudo group and you will want to configure passwordless sudo (to avoid prompting when running any sudo command and/or an Ansible playbook). This will be reconfigured later using Ansible and the lines below will be commented out or removed.

```
sudo visudo
```

Ensure this line appears in the file (typically at the bottom). This will ensure that group or user specific SSH configuration will be loaded (included) from the location (e.g. /etc/sudoers.d/goffinf_sudo)

```
@includedir /etc/sudoers.d
```

Example line to add:
```
goffinf ALL=(ALL) NOPASSWD: ALL
```

Or, to allow members of group sudo to execute any command

```
%sudo ALL=(ALL:ALL) NOPASSWD: ALL
```

[Goto Top](#configure-a-wsl2-instance-using-automation)

### Core packages

```
sudo apt update && sudo apt upgrade

sudo apt install wget ca-certificates git
```
[Goto Top](#configure-a-wsl2-instance-using-automation)

### Git configuration

```
git config --global user.name "Fraser Goffin"
git config --global user.email "goffinf@gmail.com"
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
```
[Goto Top](#configure-a-wsl2-instance-using-automation)

### Docker Desktop for Windows

Follow the instructions for your default WSL instance as described here [Install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/#install-docker-desktop-on-windows)

Check (in a WSL Terminal)

```
docker info

Client:
Version:    27.2.0
Context:    default
Debug Mode: false
Plugins:
buildx: Docker Buildx (Docker Inc.)
    Version:  v0.16.2-desktop.1
    Path:     /usr/local/lib/docker/cli-plugins/docker-buildx
compose: Docker Compose (Docker Inc.)
    Version:  v2.29.2-desktop.2
    Path:     /usr/local/lib/docker/cli-plugins/docker-compose
...

Server:
Containers: 1
Running: 0
Paused: 0
Stopped: 1

Images: 4

Server Version: 27.2.0
Storage Driver: overlay2
Backing Filesystem: extfs
...
```
[Goto Top](#configure-a-wsl2-instance-using-automation)

### wsl.conf

Open a Terminal session in your WSL distro.

```
nano /etc/wsl.conf
```
Use these settings as a starting point:

```
[boot]
systemd=true

[automount]
enabled = true
root = /
options = "metadata"

[network]
generateHosts = true
generateResolvConf = true

[interop]
appendWindowsPath = true
```
[Goto Top](#configure-a-wsl2-instance-using-automation)

### .wslconfig

In your Windows user home directory, add/update the ***.wslconfig*** file

Example: ***C:\Users\goffinf\.wslconfig***

```
[wsl2]
memory=16GB
localhostForwarding=true
```
[Goto Top](#configure-a-wsl2-instance-using-automation)

### public and private ssh keys

Ensure you have the public and private SSH keys you will use to connect to the WSL instance copied into you default user ***.ssh*** directory,

Example: ***C:\Users\goffinf\.ssh***

```
dir C:\Users\goffinf\.ssh

...

 Directory of C:\Users\goffinf\.ssh

28/04/2024  15:21    <DIR>          .
11/09/2024  18:37    <DIR>          ..
28/04/2024  15:10             2,602 id_rsa
28/04/2024  15:10               570 id_rsa.pub
```
[Goto Top](#configure-a-wsl2-instance-using-automation)