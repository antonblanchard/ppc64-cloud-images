#!/bin/bash -e

ARCH="ppc64el"

IMAGE_SIZE="16G"

DEBIAN_BASE_URL="http://d-i.debian.org/daily-images/${ARCH}/daily/netboot/debian-installer/${ARCH}"
IMAGE="debian_${ARCH}.qcow2"

VMLINUX="$DEBIAN_BASE_URL/vmlinux"
INITRD="$DEBIAN_BASE_URL/initrd.gz"

PRESEED="preseed.cfg"

TMP_IMAGE="$$.qcow2"
TMP_INITRD="$$.initrd"

if [ "$(uname -m)" = "ppc64" -o "$(uname -m)" = "ppc64le" ]; then
	KVM_OPTS="-enable-kvm -smp cores=4,threads=4"
fi
QEMU_OPTS="-m 4G -M pseries -nographic -vga none -net user -net nic"

if [ -n "$http_proxy" ]; then
	PROXY="mirror/http/proxy=$http_proxy"
else
	PROXY="mirror/http/proxy="
fi

wget -N $VMLINUX
wget -N $INITRD

VMLINUX=$(basename $VMLINUX)
INITRD=$(basename $INITRD)

function atexit {
	rm -f $TMP_IMAGE
	rm -f $TMP_INITRD
}
trap atexit EXIT

# Add preseed file to the initrd, we can just append another cpio to it
cp $INITRD $TMP_INITRD
echo $PRESEED | cpio -ovH newc >> $TMP_INITRD

qemu-img create -f qcow2 $TMP_IMAGE $IMAGE_SIZE
qemu-system-ppc64 $KVM_OPTS $QEMU_OPTS -drive file=$TMP_IMAGE -kernel $VMLINUX -initrd $TMP_INITRD -append "$PROXY"
qemu-img convert -c -f qcow2 -O qcow2 $TMP_IMAGE $IMAGE
