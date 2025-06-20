# 🛠️ Ansible Miner - Quản lý Máy Đào CPU Qua Mạng LAN

Tự động cài đặt, cấu hình và quản lý các máy đào CPU (XMRig / SRBMiner / DeroLuna) qua Ansible — gọn nhẹ, không cần NAS, chỉ cần SSH LAN.

---

## 🚀 Tính năng chính

- ✅ Tự động cài miner: xmrig / srbminer / dero
- ✅ Đẩy file cấu hình cá nhân hoá theo hostname
- ✅ Tự tạo `systemd` service để chạy nền
- ✅ Tự khởi động lại mỗi khi máy bật lên
- ✅ Không sinh log lỗi, không cần ổ NAS
- ✅ Triển khai hàng loạt máy đào CPU chỉ với 1 lệnh

---

## 📦 Cài đặt trên Server

Trên máy chủ Ubuntu/Debian (dùng làm Ansible controller), cài đặt:

sudo apt update
sudo apt install -y python3 python3-pip git sshpass
pip3 install --break-system-packages ansible==2.13.13

#pip download ansible==2.13.13

#pip download ansible-core==2.13.13

#pip3 install --break-system-packages ansible

pip3 install --break-system-packages ansible==2.13.13

git clone https://github.com/kecodon/ansible_miner

cd ansible_miner

💡 Chuẩn bị máy Client (máy đào)
Máy client cần chạy Ubuntu/Debian và:

1. Cài đặt Python 3 (nếu chưa có)

sudo apt install -y python3

2. Bật SSH root + mật khẩu
   
Chạy các lệnh sau:

sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart ssh

sudo systemctl restart ssh

Nếu chưa đặt mật khẩu cho root:

sudo passwd root

🗂️ Cấu trúc thư mục

ansible_miner/
├── deploy_miner.yml               # Playbook chính
├── inventory/
│   └── hosts                      # Danh sách máy client
├── mining_vars.yml               # Biến cấu hình chính
└── templates/                    # Các template config cho miner
    ├── xmrig_config_template.json
    ├── srbminer_config_template.txt
    └── dero_config_template.txt
    
⚙️ Cấu hình

🔹 1. inventory/hosts

[miners]
192.168.10.201 ansible_user=root ansible_ssh_pass=password ansible_python_interpreter=/usr/bin/python3

Thêm nhiều dòng nếu có nhiều máy đào.

🔹 2. mining_vars.yml

mining_tool: "xmrig"  # hoặc: srbminer / dero

wallet: "NHbSHmqm1ojuTRtdwkURwhamQ1pNC9SkJU9T"

pool: "randomxmonero.auto.nicehash.com:9200"

threads: 24

algo: "rx/0"

dashboard_server: 192.168.10.150  # (tuỳ chọn, chưa dùng)

🔹 3. Các file cấu hình miner

templates/xmrig_config_template.json

{
  "autosave": true,
  "cpu": true,
  "opencl": false,
  "cuda": false,
  "pools": [
    {
      "url": "{{ pool }}",
      "user": "{{ wallet }}.{{ ansible_hostname }}",
      "pass": "x",
      "keepalive": true,
      "tls": false,
      "algo": "{{ algo }}"
    }
  ],
  "threads": {{ threads }},
  "donate-level": 0,
  "randomx": {
    "1gb-pages": true
  }
}
templates/srbminer_config_template.txt

--algorithm {{ algo }}
--pool {{ pool }}
--wallet {{ wallet }}.{{ ansible_hostname }}
--password x
--cpu-threads {{ threads }}
templates/dero_config_template.txt

--rpc
--wallet-address {{ wallet }}
--daemon-address {{ pool }}
--threads {{ threads }}
▶️ Triển khai
Chạy lệnh sau từ thư mục ansible_miner:

ansible-playbook -i inventory/hosts deploy_miner.yml
Cài đặt miner tương ứng

Tạo cấu hình cá nhân hoá

Cài đặt systemd service (miner.service)

Tự động bật khi khởi động máy

♻️ Cập nhật cấu hình mới
Chỉ cần sửa mining_vars.yml, sau đó chạy lại:

ansible-playbook -i inventory/hosts deploy_miner.yml
🧯 Khắc phục lỗi thường gặp
Lỗi	Giải pháp
Permission denied	Đảm bảo SSH root mở + đúng password
python not found	Cài python3: apt install python3
Could not find config template	Kiểm tra lại thư mục templates/
