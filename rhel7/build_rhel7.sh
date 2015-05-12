#!/bin/bash -e

ARCH="ppc64"
#ARCH="ppc64le"

IMAGE_SIZE="16G"

IMAGE="rhel7.0_${ARCH}.qcow2"

ISO="RHEL-7.0-20140507.0-Server-ppc64-dvd1.iso"
VMLINUX="vmlinuz"
INITRD="initrd.img"

KICKSTART="rhel7.ks"

TMP_IMAGE="$$.qcow2"
TMP_INITRD="$$.initrd"

if [ "$(uname -m)" = "ppc64" -o "$(uname -m)" = "ppc64le" ]; then
	KVM_OPTS="-enable-kvm -smp cores=4,threads=4"
fi
QEMU_OPTS="-m 4G -M pseries -nographic -vga none -net user -net nic"

function atexit {
	rm -f $TMP_IMAGE
	rm -f $TMP_INITRD
}
trap atexit EXIT

# Add kickstart file to the initrd, we can just append another cpio to it
cp $INITRD $TMP_INITRD

# align to 4B
SIZE=$(stat --printf=%s $TMP_INITRD)
MOD=$((SIZE % 4))
if [ $MOD -ne 0 ]; then
	EXTRA=$((4 - MOD))
	dd if=/dev/zero of=$TMP_INITRD bs=1 count=$EXTRA conv=notrunc oflag=append
fi

echo $KICKSTART | cpio -ovH newc >> $TMP_INITRD

qemu-img create -f qcow2 $TMP_IMAGE $IMAGE_SIZE
qemu-system-ppc64 $KVM_OPTS $QEMU_OPTS -drive file=$ISO,media=cdrom -drive file=$TMP_IMAGE -kernel $VMLINUX -initrd $TMP_INITRD -append "ks=file://$KICKSTART"
qemu-img convert -c -f qcow2 -O qcow2 $TMP_IMAGE $IMAGE
