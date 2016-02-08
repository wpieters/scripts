#!/bin/bash -e
WORKING_DIR=$(pwd)

echo "Checking for HomeBrew and installing if needed ..."
if [ ! $(which brew) ]; then
    echo "No HomeBrew found, installing..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    echo "Done!"
fi
echo "Updating brew..."
brew update && brew doctor

echo "Checking for Python 2.7 and installing if needed..."
if [ ! $(which python) ]; then
    echo "Need to install Python 2.7..."
    brew install readline gdbm
    brew install python --universal --framework
    echo "Done!"
fi
echo $(python --version)
  
echo "Checking for Pip and installing if needed..."
if [ ! $(which pip) ]; then
    echo "Need to install Pip from bootstrap.pypa.io..."
    curl https://bootstrap.pypa.io/get-pip.py > get-pip.py && python get-pip.py     
    echo "Done!"
fi
echo $(pip --version)

echo "Checking for Ansible 1.9.4 and installing if needed ..."
if [[ ! $(which ansible) ]]; then
    sudo -H pip install --upgrade ansible==1.9.4 pyyaml virtualenv battleschool
fi
echo "Done! Doing some config to run local ..."
echo "127.0.0.1" > ~/ansible_hosts
export ANSIBLE_HOSTS=./hosts

echo "Done! Installing BattelSchool for OS X provisioning ..."
ansible-playbook --ask-become-pass ansible/playbook.yml
echo "Done! Provisioning some tools..."
battle --ask-sudo-pass --config-file $WORKING_DIR/ansible/battleschool/config.yml

echo "Done! Checking Bash version..."
BASH_VERSION=$($SHELL --version)
if [[ ${BASH_VERSION:18:6} == 3.* ]]; then
    echo "Upgrading to Bash 4..."
    brew install bash
    sudo bash -c 'echo /usr/local/bin/bash >> /etc/shells'
    chsh -s /usr/local/bin/bash 
fi