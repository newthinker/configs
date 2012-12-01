#!/bin/bash

################################################################################
# input arguments and consts
################################################################################
FAILD_EXIT=-1
CONFIG_DIRS="/etc/libvirt/qemu/"

ORI_KVM_CONFIG=$1
SS_CAPACITY=$2
SS_NAME=$3
BLOCK_NAME=$4

################################################################################
# help information
################################################################################
if [ $# -lt 3 ]; then
	echo "Input args error!"
	echo "Usage: $0 OriKVMConfig SnapShotCapacity SnapShotName BlockDeviceName" 
	echo "Example: $0 WinServer2008.xml 50G testSS /dev/VG/testLV"
	exit $FAILD_EXIT
fi	

################################################################################
# modify config file of the orignal kvm
################################################################################
cd $CONFIG_DIRS   # goto the config's directory

echo $CONFIG_DIRS

NEW_KVM_CONFIG=`echo ${ORI_KVM_CONFIG}.xml | sed 's/\.xml/\_ss/'`    # modify the new config filename

cp $ORI_KVM_CONFIG  $NEW_KVM_CONFIG

echo $ORI_KVM_CONFIG   $NEW_KVM_CONFIG 

#modify the name tag
KVM_NAME=$(basename $NEW_KVM_CONFIG)

KVM_NAME=${KVM_NAME%.*}	

echo $KVM_NAME

sed -i "s/<name>.*<\/name>/<name>$KVM_NAME<\/name>/" $NEW_KVM_CONFIG

#modify the uuid tag
UUID=$(cat /proc/sys/kernel/random/uuid)

echo $UUID

sed -i "s/<uuid>.*<\/uuid>/<uuid>$UUID<\/uuid>/"  $NEW_KVM_CONFIG

#modify the disk type tag
echo $BLOCK_NAME

SS_BLOCK_NAME=$(dirname $BLOCK_NAME)

SS_BLOCK_NAME=${SS_BLOCK_NAME}/${SS_NAME}

sed -i "s:<source dev='.*'/>:<source dev='$SS_BLOCK_NAME'/>:"   $NEW_KVM_CONFIG

#modify the mac address tag
MACADDR="$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\)\(..\).*$/\1:\2:\3:\4:\5:\6/')"

sed -i "s/<mac address='.*'\/>/<mac address='$MACADDR'\/>/" $NEW_KVM_CONFIG

#############################################################################
# create the lvm snapshot
#############################################################################
# create lvm snapshot
#input arguments format
# lvcreate -L <SS_CAPACITY> -s -n <SS_NAME> <BLOCK_NAME>
#SS_CAPACITY:snapshot's capacity
#SS_NAME:snapshot's name
#BLOCK_NAME:kvm's block driver name
lvcreate -L $SS_CAPACITY -s -n $SS_NAME $BLOCK_NAME

# define the new KVM 
virsh define $NEW_KVM_CONFIG

# open the new KVM
virsh start $KVM_NAME
