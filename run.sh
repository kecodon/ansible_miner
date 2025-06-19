#!/bin/bash

cd /root/ansible_miner
source venv/bin/activate
ansible-playbook -i hosts deploy_miner.yml
