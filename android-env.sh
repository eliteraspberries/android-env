#!/bin/sh
set -e
set -x
if test -z "${ABI}"; then ABI="armeabi-v7a"; fi
if test "${ABI}" = "armeabi-v7a"; then
    if test -z "${API}"; then API="19"; fi
    ARCH="arm"
    FPU="vfpv4"
    MARCH="armv7-a"
    TARGET="arm-linux-androideabi"
elif test "${ABI}" = "arm64-v8a"; then
    if test -z "${API}"; then API="21"; fi
    ARCH="arm64"
    FPU="neon"
    MARCH="armv8-a"
    TARGET="aarch64-linux-android"
else
    exit 1
fi
FLOATABI="softfp"
if test -z "${ANDROIDHOME}"; then
    ANDROIDHOME="${HOME}/Library/Android"
fi
ANDROIDSDK="${ANDROIDHOME}/sdk"
ANDROIDNDK="${ANDROIDSDK}/ndk-bundle"
SYSROOT="${ANDROIDNDK}/sysroot"
PREFIX="${TARGET}-${API}-toolchain"
if ! test -d ${PREFIX}; then
    ${ANDROIDNDK}/build/tools/make_standalone_toolchain.py \
        --arch ${ARCH} \
        --api ${API} \
        --install-dir=${PREFIX}
fi
AR="${TARGET}-ar"
AS="${TARGET}-clang"
CC="${TARGET}-clang"
CPP="${CC} -E"
CXX="${TARGET}-clang++"
LD="${TARGET}-ld"
RANLIB="${TARGET}-ranlib"
CFLAGS=""
CFLAGS="--sysroot=${SYSROOT} ${CFLAGS}"
CFLAGS="-fpic ${CFLAGS}"
CFLAGS="-march=${MARCH} ${CFLAGS}"
CFLAGS="-mfloat-abi=${FLOATABI} ${CFLAGS}"
CFLAGS="-mfpu=${FPU} ${CFLAGS}"
CPPFLAGS=""
CPPFLAGS="-D__ANDROID_API__=${API} ${CPPFLAGS}"
CPPFLAGS="-isysroot ${SYSROOT} ${CPPFLAGS}"
CPPFLAGS="-isystem ${SYSROOT}/usr/include/${TARGET} ${CPPFLAGS}"
CXXFLAGS="${CFLAGS}"
ANDROIDLDSYSROOT="${ANDROIDNDK}/platforms/android-${API}/arch-${ARCH}"
LDFLAGS=""
LDFLAGS="--sysroot=${ANDROIDLDSYSROOT} ${LDFLAGS}"
PATH="$(pwd)/${PREFIX}/bin:${PATH}"
export ANDROIDABI="${ABI}"
export ANDROIDLDSYSROOT
export ANDROIDSYSROOT="${SYSROOT}"
export AR
export AS
export CC
export CPP
export CXX
export LD
export RANLIB
export CFLAGS
export CPPFLAGS
export CXXFLAGS
export LDFLAGS
export PATH
exec $@
