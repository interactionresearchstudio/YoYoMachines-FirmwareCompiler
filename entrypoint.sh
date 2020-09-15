#!/bin/sh -l
# Checkout repo
echo "Checking out repository"
git clone https://github.com/interactionresearchstudio/$1

echo "*******LS"
ls
echo "*******PWD"
pwd

echo "INSTALLED LIBRARIES:"
arduino-cli lib list

# Compile
echo "Compiling"
mkdir build
arduino-cli compile -v -b esp32:esp32:esp32 --output-dir build $1


# Build spiffs file
echo "Building spiffs from data folder"
git clone https://github.com/igrr/mkspiffs
cd mkspiffs && git submodule update --init && make dist
cd .. && mkspiffs/./mkspiffs --version
mkspiffs/./mkspiffs -c $1/data -b 4096 -p 256 -s 0x100000 build/spiffs.bin

echo "Listing directory"
ls

# Merge bin files
echo "Merging bin files"
git clone https://github.com/vtunr/esp32_binary_merger
python esp32_binary_merger/merge_bin_esp.py \
  --output_name app-combined.bin \
  --bin_path bootloader_qio_80m.bin build/$1.ino.partitions.bin build/$1.ino.bin build/spiffs.bin \
  --bin_address 0x1000 0x8000 0x10000 0x290000

echo "Moving files to build directory"
mv output/app-combined.bin build/app-combined.bin
mv build/$1.ino.bin build/app.bin
