✅ 1. CẤU TRÚC THƯ MỤC

Sao chép
Chỉnh sửa
/root/ansible_miner/
├── deploy_miner.yml             # Cài tool & chạy tool theo biến
├── collect_status.yml           # Thu thập trạng thái và gửi về Dashboard
├── mining_vars.yml              # Biến cấu hình (tool, coin, pool, ví...)
├── dashboard.py                 # Web Dashboard
├── hosts                        # Danh sách máy client (IP)
├── templates/                   # Thư mục chứa các file config mẫu
│   ├── xmrig_config.json.j2
│   ├── srbminer_config.txt.j2
│   └── dero_start.txt.j2

✅ 2. CÁC FILE CẦN TẠO/ĐIỀU CHỈNH
File	Mô tả	Cần sửa gì?
hosts	Danh sách IP client	Thêm IP và user/pass
mining_vars.yml	Khai báo cấu hình đào	Chọn tool, ví, pool, worker...
deploy_miner.yml	Playbook cài tool & khởi động miner	Đã đầy đủ
collect_status.yml	Gửi trạng thái về dashboard	Đã fix bug ansible_date_time
dashboard.py	Web dashboard Flask	Không cần sửa nếu port 5050
templates/*.j2	Config miner theo từng tool	Có thể sửa thêm nếu pool yêu cầu định dạng khác

✅ 3. LỆNH CẦN CHẠY

🔹 Bước 1: Cài Ansible và thư viện cần thiết
bash
Sao chép
Chỉnh sửa
sudo apt update && sudo apt install -y ansible python3-pip
pip3 install flask
🔹 Bước 2: Kiểm tra SSH tới client
bash
Sao chép
Chỉnh sửa
ansible -i hosts all -m ping
⚠️ Nếu lỗi, cần kiểm tra: SSH key, mật khẩu, sshpass, firewall.

🔹 Bước 3: Cài miner và khởi động tool
bash
Sao chép
Chỉnh sửa
ansible-playbook -i hosts deploy_miner.yml
🔹 Bước 4: Kiểm tra trạng thái đào
bash
Sao chép
Chỉnh sửa
ansible-playbook -i hosts collect_status.yml
🔹 Bước 5: Chạy Dashboard Web
bash
Sao chép
Chỉnh sửa
cd /root/ansible_miner
nohup python3 dashboard.py > dashboard.log 2>&1 &
→ Mở trình duyệt: http://<server>:5050

🔹 Bước 6: Tự động gửi trạng thái mỗi phút
bash
Sao chép
Chỉnh sửa
crontab -e
Thêm:

cron
Sao chép
Chỉnh sửa
* * * * * cd /root/ansible_miner && ansible-playbook -i hosts collect_status.yml

✅ 4. ĐỔI TOOL, POOL, VÍ, WORKER

Chỉ cần sửa trong mining_vars.yml, ví dụ:

yaml
Sao chép
Chỉnh sửa
mining_tool: "xmrig"  # hoặc srbminer / deroluna
wallet: "..."
pool: "..."
threads: 24
Sau đó chạy lại:

bash
Sao chép
Chỉnh sửa
ansible-playbook -i hosts deploy_miner.yml
