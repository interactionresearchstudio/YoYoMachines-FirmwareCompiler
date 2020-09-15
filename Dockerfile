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

COPY . .

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh", "ESP32-SOCKETIO"]
