#!/bin/sh -l

# Install esp32
echo "Installing esp32"
arduino-cli core update-index --additional-urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
arduino-cli core search esp32 --additional-urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
arduino-cli core install esp32:esp32 --additional-urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

# Install libraries from manager
echo "Installing libraries"
arduino-cli lib install FastLED
arduino-cli lib install WebSockets
arduino-cli lib install ArduinoJson
arduino-cli lib install AceButton

# Install GitHub libraries
curl -L -O https://github.com/me-no-dev/ESPAsyncWebServer/archive/master.zip
unzip master.zip
mv ESPAsyncWebServer-master /root/Arduino/libraries/ESPAsyncWebServer
rm master.zip

curl -L -O https://github.com/me-no-dev/AsyncTCP/archive/master.zip
unzip master.zip
mv AsyncTCP-master /root/Arduino/libraries/AsyncTCP
rm master.zip

curl -L -O https://github.com/timum-viw/socket.io-client/archive/master.zip
unzip master.zip
mv socket.io-client-master /root/Arduino/libraries/SocketIoClient
rm master.zip

# List libraries
arduino-cli lib list

# Checkout repo
echo "Checking out repository"
git clone https://github.com/interactionresearchstudio/$1

# Compile
echo "Compiling"
mkdir build
arduino-cli compile -v -b esp32:esp32:esp32 --output-dir build $1

# Build spiffs file
echo "Building spiffs from data folder"
git clone https://github.com/igrr/mkspiffs
cd mkspiffs && git submodule update --init && make dist
cd / && mkspiffs/./mkspiffs --version
mkspiffs/./mkspiffs -c $1/data -b 4096 -p 256 -s 0x100000 build/spiffs.bin

# Merge bin files
echo "Merging bin files"
python esp32_binary_merger/merge_bin_esp.py \
  --output_name app-combined.bin \
  --bin_path bootloader_qio_80m.bin build/$1.ino.partitions.bin build/$1.ino.bin build/spiffs.bin \
  --bin_address 0x1000 0x8000 0x10000 0x290000

echo "Moving files to build directory"
mv output/app-combined.bin build/app-combined.bin
mv build/$1.ino.bin build/app.bin