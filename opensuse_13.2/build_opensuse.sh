#!/bin/bash -e

#ARCH="ppc64"
ARCH="ppc64le"

IMAGE_SIZE="16G"

# mirrorbrain makes it next to impossible to proxy cache, so use
# a specific mirror for release installs
#BASE_URL="http://suse.mirrors.tds.net/pub/opensuse/ports/ppc/distribution/13.2/repo/oss"
#IMAGE="opensuse_13.2_${ARCH}.qcow2"
#
# Go straight to download.o.o if installing factory, the chances
# of having an inconsistent tree is too likely
BASE_URL="http://download.opensuse.org/ports/ppc/factory/repo/oss"
IMAGE="opensuse_factory_${ARCH}.qcow2"

VMLINUX="${BASE_URL}/boot/${ARCH}/linux"
INITRD="${BASE_URL}/boot/${ARCH}/initrd"

AUTOYAST="autoinst.xml"

TMP_IMAGE="$$.qcow2"
TMP_INITRD="$$.initrd"

if [ "$(uname -m)" = "ppc64" ]; then
	KVM_OPTS="-enable-kvm -smp cores=4,threads=4"
fi
QEMU_OPTS="-m 4G -M pseries -nographic -vga none -net user -net nic"

if [ -n "$http_proxy" ]; then
	PROXY="proxy=$http_proxy"
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

# Add autoyast file to the initrd, we can just append another cpio to it
cp $INITRD $TMP_INITRD
echo $AUTOYAST | cpio -ovH newc >> $$.initrd

qemu-img create -f qcow2 $TMP_IMAGE $IMAGE_SIZE
# Got this when I had an empty command line:
# Internal error. Please report a bug report with logs.
# Details: undefined method `grep' for nil:NilClass
# Caller:  /mounts/mp_0001/usr/share/YaST2/modules/Packages.rb:973:in `kernelCmdLinePackages'
#
# Also need to work out why yast is screwed on console vs ssh
qemu-system-ppc64 $KVM_OPTS $QEMU_OPTS -drive file=$TMP_IMAGE -kernel $VMLINUX -initrd $TMP_INITRD -append "autoyast=default install=$BASE_URL $PROXY"
# Need to restart to complete second stage install
qemu-system-ppc64 $KVM_OPTS $QEMU_OPTS -drive file=$TMP_IMAGE
qemu-img convert -c -f qcow2 -O qcow2 $TMP_IMAGE $IMAGE
