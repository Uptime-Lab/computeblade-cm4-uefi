#!/bin/bash

set -e

# This script is used to build the UEFI firmware for the Raspberry Pi 4.

# Setup default secure boot keys
mkdir -p keys
openssl req -new -x509 -newkey rsa:2048 -subj "/CN=Raspberry Pi Platform Key/" -keyout /dev/null -outform DER -out keys/pk.cer -days 7300 -nodes -sha256
curl -L https://go.microsoft.com/fwlink/?LinkId=321185 -o keys/ms_kek.cer
curl -L https://go.microsoft.com/fwlink/?linkid=321192 -o keys/ms_db1.cer
curl -L https://go.microsoft.com/fwlink/?linkid=321194 -o keys/ms_db2.cer
curl -L https://uefi.org/sites/default/files/resources/dbxupdate_arm64.bin -o keys/arm64_dbx.bin

# Apply patches


BUILD_FLAGS="-D SECURE_BOOT_ENABLE=TRUE -D INCLUDE_TFTP_COMMAND=TRUE -D NETWORK_ISCSI_ENABLE=TRUE -D SMC_PCI_SUPPORT=1"

DEFAULT_KEYS="-D DEFAULT_KEYS=TRUE -D PK_DEFAULT_FILE=$WORKSPACE/keys/pk.cer -D KEK_DEFAULT_FILE1=$WORKSPACE/keys/ms_kek.cer -D DB_DEFAULT_FILE1=$WORKSPACE/keys/ms_db1.cer -D DB_DEFAULT_FILE2=$WORKSPACE/keys/ms_db2.cer -D DBX_DEFAULT_FILE1=$WORKSPACE/keys/arm64_dbx.bin"

# EDK2's 'build' command doesn't play nice with spaces in environmnent variables, so we can't move the PCDs there...
source ./edk2/edksetup.sh

make -C edk2/BaseTools

build -a AARCH64 -t GCC5 -b RELEASE \
    -p edk2-platforms/Platform/RaspberryPi/RPi4/RPi4.dsc \
    --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVendor=L"${PROJECT_URL}" \
    --pcd gEfiMdeModulePkgTokenSpaceGuid.PcdFirmwareVersionString=L"UEFI Firmware ${VERSION}" \
    ${BUILD_FLAGS} ${DEFAULT_KEYS}
