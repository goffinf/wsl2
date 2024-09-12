# Configure a WSL2 Instance using Automation

- [Configure a WSL2 Instance using Automation](#configure-a-wsl2-instance-using-automation)
  - [Purpose](#purpose)
  - [Pre-Reqs](#pre-reqs)
    - [Install WSL and a default distribution](#install-wsl-and-a-default-distribution)
    - [Windows Terminal](#windows-terminal)
    - [SSH](#ssh)
    - [sudoers](#sudoers)
    - [Core packages](#core-packages)
    - [Git configuration](#git-configuration)
    - [Docker Desktop for Windows](#docker-desktop-for-windows)
    - [wsl.conf](#wslconf)
    - [.wslconfig](#wslconfig)
    - [public and private ssh keys](#public-and-private-ssh-keys)


## Purpose

1. Configure a base Ubuntu WSL2 distro to use as a ***independant software development environment*** (IDP). The primary automation software used is **Ansible**.

1. To provide a simpler and more reproducble configuration, Ansible, and its dependencies will **NOT** be **installed** directly into the WSL instance, but instead will be run from a ***Dev Container***.

[Goto Top](#configure-a-wsl2-instance-using-automation)

## Pre-Reqs

### Install WSL and a default distribution

Ensure you have installed ***WSL2*** and (at least) configured a default Ubuntu distribution following these [instructions](https://learn.microsoft.com/en-gb/windows/wsl/install).

### Windows Terminal

Install ***Windows Terminal*** (you can use git bash or Powershell, but Terminal is much easier) using these [instructions](https://learn.microsoft.com/en-us/windows/terminal/install)

[Goto Top](#configure-a-wsl2-instance-using-automation)

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