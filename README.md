Role Name
=========

Arch linux install from ansible

Install steps
------------

pacman --noconfirm -Sy ansible unzip
wget https://github.com/Inonut/ansible/archive/master.zip
unzip master.zip
cd ansible-master
ansible-playbook install_arch.yml
