#!/bin/bash

# Combine the build, run, and start scripts.

# Create a new image:
# qemu-img create -f raw dev.img 512M

# Boot freedos.img with the Live CD, and src directory mounted to D:\.

#QEMU="/mnt/c/Program Files/qemu/qemu-system-x86_64.exe"
QEMU="./qemu/qemu-system-i386.exe"
NAME=FreeDOS
MACHINE=pc-i440fx-7.0,usb=off
RAM_MB=512
BASE_IMAGE=freedos-dev.img
LIVECD_IMAGE=FD13LIVE.iso
SOURCE_DIR=./src

# Note: If you want to use the Linux version of QEMU on WSL, you gotta get GTK working.  Which means updating Windows 10.  I didn't.
#sudo apt-get update
#sudo apt-get upgrade -y
sudo apt-get install -y p7zip-full qemu-utils qemu-kvm qemu qemu-system-i386 wget

if [ ! -f $LIVECD_IMAGE ]; then
	if [ ! -f FD13-LiveCD.zip ]; then
		wget https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.3/official/FD13-LiveCD.zip
	fi
	7z x FD13-LiveCD.zip
fi

if [ ! -f $QEMU ]; then
	if [ ! -f ./qemu.7z ]; then
		wget https://github.com/treytomes/freedos_bootstrap/releases/download/qemu/qemu.7z
	fi
	7z x qemu.7z
fi

if [ ! -f $BASE_IMAGE ]; then
	if [ ! -f freedos-dev.7z ]; then
		wget https://github.com/treytomes/freedos_bootstrap/releases/download/freedos-dev/freedos-dev.7z
	fi
	7z x freedos-dev.7z
fi

"${QEMU}" -name $NAME -m $RAM_MB -overcommit mem-lock=off -no-user-config -nodefaults -rtc base=utc,driftfix=slew -no-hpet -boot menu=off,strict=on \
	-machine $MACHINE \
	-msg timestamp=on \
	-drive file=$BASE_IMAGE,format=raw,index=0,media=disk,cache=none \
	-drive file=fat:rw:$SOURCE_DIR,format=raw,index=1,media=disk,cache=none \
	-cdrom $LIVECD_IMAGE \
	-device sb16 -device adlib -soundhw pcspk \
	-vga cirrus -display sdl \
	-net nic,model=pcnet -net user \
	-usbdevice mouse -boot c
	#-full-screen \
