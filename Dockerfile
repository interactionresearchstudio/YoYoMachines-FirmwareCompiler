FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y python3.7 python curl unzip git clang make gcc build-essential

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python get-pip.py
RUN pip install pyserial

# Install mkspiffs
RUN git clone https://github.com/igrr/mkspiffs
RUN cd mkspiffs && git submodule update --init && make dist
RUN cd / && mkspiffs/./mkspiffs --version

RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh

RUN arduino-cli core update-index

# Install esp32
RUN echo "Installing esp32"
RUN arduino-cli core update-index --additional-urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
RUN arduino-cli core search esp32 --additional-urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
RUN arduino-cli core install esp32:esp32 --additional-urls https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

# Install libraries from manager
RUN echo "Installing libraries"
RUN arduino-cli lib install FastLED
RUN arduino-cli lib install WebSockets
RUN arduino-cli lib install ArduinoJson
RUN arduino-cli lib install AceButton

# Install GitHub libraries
RUN curl -L -O https://github.com/me-no-dev/ESPAsyncWebServer/archive/master.zip
RUN unzip master.zip
RUN mv ESPAsyncWebServer-master /root/Arduino/libraries/ESPAsyncWebServer
RUN rm master.zip

RUN curl -L -O https://github.com/me-no-dev/AsyncTCP/archive/master.zip
RUN unzip master.zip
RUN mv AsyncTCP-master /root/Arduino/libraries/AsyncTCP
RUN rm master.zip

RUN curl -L -O https://github.com/timum-viw/socket.io-client/archive/master.zip
RUN unzip master.zip
RUN mv socket.io-client-master /root/Arduino/libraries/SocketIoClient
RUN rm master.zip

# List libraries
RUN arduino-cli lib list

COPY . .

RUN chmod +x entrypoint.sh

WORKDIR /

ENTRYPOINT ["/entrypoint.sh"]
