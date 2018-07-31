#!/bin/bash
#
# A shell script to build the VPP VM image using diskinage-builder
#
# The following packages must be installed prior to using this script:
# sudo apt-get -y install python-virtualenv qemu-utils kpartx

set -e

__version__=0.7
image_name=nfvbenchvm-$__version__

# install diskimage-builder
if [ -d dib-venv ]; then
    . dib-venv/bin/activate
else
    virtualenv dib-venv
    . dib-venv/bin/activate
    pip install diskimage-builder
fi

# Add nfvbenchvm_centos elements directory to the DIB elements path
export ELEMENTS_PATH=`pwd`/elements

# canned user/password for direct login
export DIB_DEV_USER_USERNAME=nfvbench
export DIB_DEV_USER_PASSWORD=nfvbench
export DIB_DEV_USER_PWDLESS_SUDO=Y

# Set the data sources to have ConfigDrive only
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"

# Configure VPP REPO
export DIB_YUM_REPO_CONF=$ELEMENTS_PATH/nfvbenchvm/fdio-release.repo

# Use ELRepo to have latest kernel
export DIB_USE_ELREPO_KERNEL=false
export DIB_LOCAL_IMAGE=/root/nfvbench/nfvbenchvm/dib/rhel-server-7.4-x86_64-kvm.qcow2
export DIB_DEBUG_TRACE=1

echo "Building $image_name.qcow2..."
time disk-image-create -o $image_name rhel7 rhelvm
if [ -d /root/nfvbench_ws ]; then
   mv -f $image_name.qcow2 /root/nfvbench_ws/
fi

