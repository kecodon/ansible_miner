#!/bin/bash

set -e
echo "🚀 Bắt đầu thiết lập hệ thống đào coin..."

echo "📦 Cập nhật hệ thống và cài đặt gói cần thiết"
apt update && apt install -y python3 python3-pip ansible sshpass git curl jq

echo "🐍 Cài Flask cho dashboard"
pip3 install flask

echo "🔐 Phân quyền các file cần thiết"
chmod +x /root/ansible_miner/run.sh
chmod +x /root/ansible_miner/dashboard.py

echo "📄 Cấu hình cronjob tự động:"
# Xoá cron cũ nếu có
crontab -l 2>/dev/null | grep -v "collect_status.yml" | grep -v "dashboard.py" > /tmp/cron.tmp || true

# Gửi trạng thái miner mỗi phút
echo "* * * * * cd /root/ansible_miner && ansible-playbook -i hosts collect_status.yml" >> /tmp/cron.tmp

# Chạy dashboard sau khi reboot
echo "@reboot sleep 30 && cd /root/ansible_miner && nohup python3 dashboard.py > /root/ansible_miner/dashboard.log 2>&1 &" >> /tmp/cron.tmp

crontab /tmp/cron.tmp
rm /tmp/cron.tmp
echo "✅ Đã cập nhật crontab"

echo "🔧 Tạo service miner khởi động cùng hệ thống"
cp /root/ansible_miner/templates/miner.service /etc/systemd/system/miner.service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable miner.service
systemctl restart miner.service

echo "🚀 Chạy playbook deploy_miner.yml"
cd /root/ansible_miner
ansible-playbook -i hosts deploy_miner.yml

echo "🎉 Hoàn tất thiết lập!"
