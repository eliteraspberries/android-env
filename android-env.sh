#!/bin/sh
set -x
if test -z "${API}"; then API="19"; fi
if test -z "${ARCH}"; then ARCH="arm"; fi
FLOATABI="softfp"
if test -z "${FPU}"; then FPU="vfpv4"; fi
if test -z "${MARCH}"; then MARCH="armv7-a"; fi
if test -z "${ANDROIDHOME}"; then
    ANDROIDHOME="${HOME}/Library/Android"
fi
ANDROIDSDK="${ANDROIDHOME}/sdk"
ANDROIDNDK="${ANDROIDSDK}/ndk-bundle"
SYSROOT="${ANDROIDNDK}/sysroot"
if ! test -d android-toolchain; then
    ${ANDROIDNDK}/build/tools/make_standalone_toolchain.py \
        --arch ${ARCH} \
        --api ${API} \
        --install-dir=android-toolchain
fi
TARGET="${ARCH}-linux-androideabi"
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
LDFLAGS=""
LDFLAGS="--sysroot=${ANDROIDNDK}/platforms/android-${API}/arch-${ARCH} ${LDFLAGS}"
PATH="$(pwd)/android-toolchain/bin:${PATH}"
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
