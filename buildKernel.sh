#!/bin/bash

# Written by Hakalle (Velosh) <hakalle@proton.me>.
# Modified for SukiSU-Ultra integration.

# Clone GCC & Proton Clang.
[[ -d "$(pwd)/gcc/" ]] || git clone https://github.com/VH-Devices/toolchains -b gcc-10.3.0 gcc --depth 1 >> /dev/null 2> /dev/null
[[ -d "$(pwd)/clang/" ]] || git clone https://github.com/kdrag0n/proton-clang clang --depth 1 >> /dev/null 2> /dev/null

# Backport set_memory.h from MTK 4.19 for SukiSU on 4.14
curl -LSs "https://raw.githubusercontent.com/MediaTek-Labs/common-kernel-4.19/master/include/linux/set_memory.h" -o include/linux/set_memory.h.mtk
cp include/linux/set_memory.h.mtk include/linux/set_memory.h
rm include/linux/set_memory.h.mtk
echo "Backported MTK 4.19 set_memory.h"

# Clone SukiSU-Ultra setup (non-GKI for A31)
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s nongki

# Export KBUILD_BUILD_{USER,HOST} flags.
export KBUILD_BUILD_USER="zyzoh"
export KBUILD_BUILD_HOST="zyzoh"

# Export ARCH/SUBARCH flags.
export ARCH="arm64"
export SUBARCH="arm64"

# Export CCACHE
export CCACHE_EXEC="$(which ccache)"
export CCACHE="${CCACHE_EXEC}"
export CCACHE_COMPRESS="1"
export USE_CCACHE="1"
$CCACHE -M 50G

# Export toolchain/clang/llvm flags
export CROSS_COMPILE="$(pwd)/gcc/bin/aarch64-buildroot-linux-gnu-"
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CC="$(pwd)/clang/bin/clang"

# Export if/else outdir var
export WITH_OUTDIR=true

# Clear the console
clear

# Remove out dir folder and clean the source
if [ "${WITH_OUTDIR}" == true ]; then
   if [ -d "$(pwd)/a31" ]; then
      rm -rf a31
   fi
fi

# Build time
if [ "${WITH_OUTDIR}" == true ]; then
   if [ ! -d "$(pwd)/a31" ]; then
      mkdir a31
   fi
fi

if [ "${WITH_OUTDIR}" == true ]; then
   "${CCACHE}" make O="$(pwd)/a31" a31_sukisu_defconfig  # Update to your new defconfig name
   "${CCACHE}" make -j`nproc` O="$(pwd)/a31"
fi
