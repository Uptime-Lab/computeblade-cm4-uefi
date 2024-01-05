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

RUN patch --binary -d edk2 -p1 -i ../0001-MdeModulePkg-UefiBootManagerLib-Signal-ReadyToBoot-o.patch
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
FROM scratch
COPY --from=builder /build/Build/RPi4/RELEASE_GCC5/FV/RPI_EFI.fd /RPI_EFI.fd
