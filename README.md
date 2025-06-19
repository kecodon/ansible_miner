🖥️ TRÊN MÁY SERVER (Ansible Controller)
1. Chuẩn bị thư mục làm việc

bash
Sao chép
Chỉnh sửa
cd ~
git clone <link chứa thư mục ansible_miner>  # Hoặc tạo thủ công
cd ansible_miner
2. Cài các gói cần thiết

bash
Sao chép
Chỉnh sửa
apt update && apt install -y python3 python3-pip ansible sshpass git curl
pip3 install flask
3. File cần có trong thư mục /root/ansible_miner/:

less
Sao chép
Chỉnh sửa
├── deploy_miner.yml         # Playbook cài tool đào
├── collect_status.yml       # Playbook thu thập trạng thái
├── mining_vars.yml          # Biến: ví, pool, tool, v.v.
├── hosts                    # Danh sách IP máy client
├── dashboard.py             # Web dashboard hiển thị trạng thái
├── templates/               # Thư mục chứa các template config
├── run.sh                   # File khởi động lại hệ thống đào
├── setup.sh                 # File cài đặt toàn bộ hệ thống
4. Chạy thiết lập hệ thống (tự động):

bash
Sao chép
Chỉnh sửa
chmod +x setup.sh
./setup.sh
🖥️ TRÊN MÁY CLIENT (mỗi máy chạy 1 lần duy nhất)
1. Tạo và chạy file client.sh sau cài Ubuntu:

bash
Sao chép
Chỉnh sửa
#!/bin/bash
set -e
echo "🚀 Đang chuẩn bị máy client..."

apt update && apt install -y openssh-server python3

echo "🔐 Cho phép SSH root login..."
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl enable ssh
systemctl restart ssh

echo "✅ Máy client sẵn sàng nhận lệnh từ server."
Lưu và chạy:

bash
Sao chép
Chỉnh sửa
chmod +x client.sh
./client.sh
🔐 Từ SERVER: Gửi SSH Key sang client
bash
Sao chép
Chỉnh sửa
ssh-copy-id root@192.168.10.201  # Lặp lại với mỗi client
Nếu không dùng key thì cần cài sshpass và sửa lại file hosts để dùng dạng ansible_ssh_pass=...

🛠️ Khi cần cập nhật cấu hình tool hoặc thay đổi ví/pool:
bash
Sao chép
Chỉnh sửa
nano mining_vars.yml  # Cập nhật wallet, pool, tool, threads
./run.sh              # Khởi động lại đúng tool đang chọn
🌐 Dashboard giám sát
Khởi chạy Web dashboard (nếu chưa tự chạy):

bash
Sao chép
Chỉnh sửa
cd /root/ansible_miner
nohup python3 dashboard.py > dashboard.log 2>&1 &
Truy cập:
http://<server-ip>:5050
