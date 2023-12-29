#!/bin/bash

# Get the system's architecture
hostarch=$(uname -m)

# Check if the architecture is not x86 or x86-64
if [ "$hostarch" != "x86_64" ] && [ "$hostarch" != "x86" ]; then
  echo "Unsupported architecture: $hostarch"
  exit 1
fi

# Export ARCH/SUBARCH flags.
export ARCH="arm64"
export SUBARCH="arm64"

# Export Android Platform flags
export ANDROID_MAJOR_VERSION=t
export PLATFORM_VERSION=13

# Export toolchain/clang/llvm flags
export CROSS_COMPILE="$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-"
export CLANG_TRIPLE="aarch64-linux-gnu-"
export CC="$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang"
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# Clone GCC & Proton Clang.
if [ -d "$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/" ]; then
  echo "GCC exist"
else
  echo "GCC not exist"
  echo "Downloading GCC Toolchain!"
  wget -q --show-progress https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/+archive/0a0604336d4d1067aa1aaef8d3779b31fcee841d.tar.gz
  mkdir -pv $(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/
  tar xfv 0a0604336d4d1067aa1aaef8d3779b31fcee841d.tar.gz -C $(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/
  rm -v 0a0604336d4d1067aa1aaef8d3779b31fcee841d.tar.gz
fi

if [ -d "$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/" ]; then
  echo "Clang exist"
else
  echo "Clang not exist"
  echo "Downloading Clang Toolchain!"
  wget -q --show-progress https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-11.0.0_r3/clang-r383902.tar.gz
  mkdir -pv $(pwd)/toolchain/clang/host/linux-x86/clang-r383902/
  tar xfv clang-r383902.tar.gz -C $(pwd)/toolchain/clang/host/linux-x86/clang-r383902/
  rm -v clang-r383902.tar.gz
fi

build_command="make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j($nproc --all)"

if [ -e "out/arch/arm64/boot/Image.gz" ]; then
    echo "Build Success!"
    echo "You can check the result in out/arch/arm64/boot/"
fi
