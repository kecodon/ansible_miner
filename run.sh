#!/bin/bash
cd /root/ansible_miner

echo "▶️  Triển khai tool đào CPU..."
ansible-playbook -i hosts deploy_miner.yml

echo "✅ Đã khởi động miner"

echo "▶️  Gửi trạng thái lần đầu về Dashboard..."
ansible-playbook -i hosts collect_status.yml
