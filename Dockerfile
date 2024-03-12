FROM ubuntu:22.04 AS builder


RUN apt-get update && apt-get install -y \
        build-essential \
        acpica-tools \
        gcc-aarch64-linux-gnu \
        curl \
        git \
        uuid-dev \
        python3

WORKDIR /build

# Setup sourcecode
COPY . .

RUN patch --binary -d edk2-platforms -p1 -i ../0002-Check-for-Boot-Discovery-Policy-change.patch
RUN patch --binary -d edk2-platforms -p1 -i ../0003-No3GbMemLimit.patch
RUN patch --binary -d edk2-platforms -p1 -i ../0004-systemtable-devicetree.patch

ARG VERSION=dev
ENV VERSION=${VERSION}
ENV WORKSPACE=/build
ENV PACKAGES_PATH=$WORKSPACE/edk2:$WORKSPACE/edk2-platforms:$WORKSPACE/edk2-non-osi
ENV GCC5_AARCH64_PREFIX=aarch64-linux-gnu-
RUN bash build.sh


# Final artifact output
FROM scratch as dist
WORKDIR /
COPY --from=builder /build/Build/RPi4/RELEASE_GCC5/FV/RPI_EFI.fd .
COPY --from=builder /build/rpi-firmware/boot/fixup4.dat .
COPY --from=builder /build/rpi-firmware/boot/start4.elf .
COPY --from=builder /build/rpi-firmware/boot/bcm2711-rpi-4-b.dtb .
COPY --from=builder /build/rpi-firmware/boot/bcm2711-rpi-cm4.dtb .
COPY --from=builder /build/rpi-firmware/boot/bcm2711-rpi-400.dtb .
COPY --from=builder /build/rpi-firmware/boot/overlays overlays
COPY --from=builder /build/firmware firmware
COPY  config.txt .


FROM ubuntu:22.04 AS image-build
RUN apt-get update && apt-get install -y \
    dosfstools \
    mtools \
    zip

WORKDIR /sdcard/files
COPY --from=dist / /sdcard/files

WORKDIR /sdcard

RUN fallocate -l 64M sdcard.img && \
    mkfs.vfat -F 32 sdcard.img && \
    mcopy -i sdcard.img files/* :: && \
    mdir -i sdcard.img ::

RUN zip -r uefi.zip files/*

FROM scratch as image
COPY --from=image-build /sdcard/sdcard.img .
COPY --from=image-build /sdcard/uefi.zip .
