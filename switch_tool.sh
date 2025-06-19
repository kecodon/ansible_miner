#!/bin/bash

# ======= Cấu hình ==========
PLAYBOOK="deploy_miner.yml"
INVENTORY="hosts"
TOOLS=("xmrig" "srbminer" "dero")
# ============================

if [ $# -ne 1 ]; then
  echo "⚠️  Cách dùng: $0 [xmrig|srbminer|dero]"
  exit 1
fi

SELECTED="$1"

# Kiểm tra hợp lệ
if [[ ! " ${TOOLS[@]} " =~ " ${SELECTED} " ]]; then
  echo "❌ Tool không hợp lệ: $SELECTED"
  echo "✅ Chỉ được chọn: ${TOOLS[*]}"
  exit 2
fi

echo "🔁 Đang chuyển sang tool: $SELECTED"

# Bước 1: Cập nhật biến mining_tool trong playbook
sed -i "s/^ *mining_tool: .*/  mining_tool: ${SELECTED}/" "$PLAYBOOK"
echo "✅ Đã cập nhật mining_tool trong $PLAYBOOK"

# Bước 2: Dừng toàn bộ các service đào đang chạy
echo "⛔ Dừng các tool khác..."
for tool in "${TOOLS[@]}"; do
  if [ "$tool" != "$SELECTED" ]; then
    ansible -i "$INVENTORY" miners -m systemd -a "name=${tool} state=stopped enabled=no" || true
  fi
done

# Bước 3: Chạy lại playbook với tool mới
echo "🚀 Đang chạy lại Ansible với tool: $SELECTED"
ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
