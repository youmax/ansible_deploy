# Ansible Deploy for windows custom service

## Linux Control Node Installation

Setup Linux control node with commands below

```cmd
sudo apt install python3
sudo apt install python3-pip
pip3 install ansible
pip3 install "pywinrm>=0.3.0"
```

## Windows Managed Node Installation

To run ansible scripts on Windows managed nodes, you need to install **windows-OpenSSH**

- copy files/openssh folder into your Windows machine

- cd /path/to/openssh_folder

- replace content of administrators_authorized_keys with your public key stored in Linux Control Node

- run ./install-service.ps1 in Powershell as Administrator

The script will automatically install sshd service , setup public_key authorization, and allow tcp 22 input on Firewall.

Once you have done the instruction properly, connect to Windows Node from Linux Control Node via SSH, then input the password on prompt and then you can use ansible with Windows!

## How to run script

You could easily run script with ansible playboook command.

```cmd
# run command with predefined vars file
ansible-playbook xinbao.yml --extra-vars "@group_vars/xinbao/api.yml"

```
