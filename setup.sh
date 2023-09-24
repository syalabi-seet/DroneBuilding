#!bin/bash

# https://github.com/mathklk/realsense_raspberry_pi4
sudo apt -y update && sudo apt -y dist-upgrade
sudo apt install -y automake libtool cmake libusb-1.0-0-dev libx11-dev xorg-dev libglu1-mesa-dev libssl-dev clang llvm libatlas-base-dev python3-opencv

sudo raspi-config nonint do_expand_rootfs

sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/g' /etc/dphys-swapfile
sudo /etc/init.d/dphys-swapfile restart swapon -s

cd ~
git clone https://github.com/IntelRealSense/librealsense.git
cd librealsense
sudo cp config/99-realsense-libusb.rules /etc/udev/rules.d/ 

sudo su
udevadm control --reload-rules && udevadm trigger
exit

echo 'export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH' >> ~/.bashrc
echo 'export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=cpp' >> ~/.bashrc
echo 'export PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION_VERSION=2' >> ~/.bashrc
echo 'export PYTHONPATH=\$PYTHONPATH:/usr/local/lib:/home/pi/librealsense/build/wrappers/python' >> ~/.bashrc
echo 'export DISPLAY=:0.0' >> ~/.bashrc
source ~/.bashrc

cd ~
git clone --depth=1 -b v3.10.0 https://github.com/google/protobuf.git
cd protobuf
./autogen.sh
./configure
make -j4
sudo make install
cd python
export LD_LIBRARY_PATH=../src/.libs
python3 setup.py build --cpp_implementation 
python3 setup.py test --cpp_implementation
sudo python3 setup.py install --cpp_implementation
sudo ldconfig
protoc --version

cd ~
wget https://github.com/PINTO0309/TBBonARMv7/raw/master/libtbb-dev_2018U2_armhf.deb
sudo dpkg -i ~/libtbb-dev_2018U2_armhf.deb
sudo ldconfig
rm libtbb-dev_2018U2_armhf.deb

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

cd ~/librealsense
mkdir build && cd build
cmake .. -DBUILD_EXAMPLES=true -DCMAKE_BUILD_TYPE=Release -DFORCE_LIBUVC=true
make -j4
sudo make install

cd ~/librealsense/build
cmake .. -DBUILD_PYTHON_BINDINGS=bool:true -DPYTHON_EXECUTABLE=$(which python3)
make -j4
sudo make install

unset CC
unset CXX