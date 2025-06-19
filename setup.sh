#!/bin/bash

set -e
echo "🚀 Bắt đầu thiết lập hệ thống đào coin..."

echo "📦 Cập nhật hệ thống và cài đặt gói cần thiết"
apt update && apt install -y python3 python3-pip python3-venv sshpass git curl

# 🐍 Tạo môi trường ảo nếu chưa có
cd /root/ansible_miner
if [ ! -d "venv" ]; then
  echo "📦 Tạo virtualenv Python..."
  python3 -m venv venv
fi

# 🐍 Kích hoạt môi trường ảo
source venv/bin/activate

echo "📦 Cài Flask, Ansible, Jinja2 mới"
pip install --upgrade pip
pip install flask ansible "jinja2>=3.1.2"

echo "🔐 Phân quyền file"
chmod +x /root/ansible_miner/run.sh
chmod +x /root/ansible_miner/dashboard.py

echo "📄 Cấu hình cronjob tự động:"
# Gỡ bỏ cron cũ nếu có
crontab -l 2>/dev/null | grep -v "collect_status.yml" | grep -v "dashboard.py" > /tmp/cron.tmp || true

# Gửi trạng thái miner mỗi phút
echo "* * * * * cd /root/ansible_miner && source venv/bin/activate && ansible-playbook -i hosts collect_status.yml" >> /tmp/cron.tmp

# Chạy dashboard sau reboot (✔️ ĐÃ THÊM ĐÚNG NHƯ YÊU CẦU)
echo "@reboot sleep 30 && cd /root/ansible_miner && source venv/bin/activate && nohup python3 dashboard.py > /root/ansible_miner/dashboard.log 2>&1 &" >> /tmp/cron.tmp

crontab /tmp/cron.tmp
rm /tmp/cron.tmp
echo "✅ Đã cập nhật crontab"

echo "🚀 Chạy playbook deploy_miner.yml"
./run.sh

echo "🎉 Hoàn tất thiết lập!"
