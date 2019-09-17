#!/bin/sh
set -e
set -x
if test -z "${ABI}"; then ABI="armeabi-v7a"; fi
if test "${ABI}" = "armeabi-v7a"; then
    if test -z "${API}"; then API="19"; fi
    ARCH="arm"
    FPU="vfpv4"
    MARCH="armv7-a"
    TRIPLET="arm-linux-androideabi"
elif test "${ABI}" = "arm64-v8a"; then
    if test -z "${API}"; then API="21"; fi
    ARCH="arm64"
    FPU="neon"
    MARCH="armv8-a"
    TRIPLET="aarch64-linux-android"
else
    exit 1
fi
FLOATABI="softfp"
if test -z "${ANDROIDHOME}"; then
    if test -n "${ANDROID_HOME}"; then
        ANDROIDHOME="${ANDROID_HOME}"
    fi
fi
if ! test -d "${ANDROIDHOME}"; then exit 1; fi
if test -z "${ANDROIDSDK}"; then
    ANDROIDSDK="${ANDROIDHOME}/sdk"
fi
if ! test -d "${ANDROIDSDK}"; then exit 1; fi
if test -z "${ANDROIDNDK}"; then
    ANDROIDNDK="${ANDROIDSDK}/ndk-bundle"
fi
if ! test -d "${ANDROIDNDK}"; then exit 1; fi
CFLAGS=""
CPPFLAGS=""
LDFLAGS=""
NDKVERSION="$( \
    awk -F'[= ]' '{if ($1 == "Pkg.Revision") print $NF}' \
    < ${ANDROIDNDK}/source.properties \
)"
if test ${NDKVERSION%%.*} -lt 19; then
    SYSROOT="${ANDROIDNDK}/sysroot"
    TARGET="${TRIPLET}"
    TOOLCHAIN="${TARGET}-${API}-toolchain"
    if ! test -d ${TOOLCHAIN}; then
        ${ANDROIDNDK}/build/tools/make_standalone_toolchain.py \
            --arch ${ARCH} \
            --api ${API} \
            --install-dir=${TOOLCHAIN}
    fi
    TOOLCHAIN="$(cd ${TOOLCHAIN} && pwd)"
    AR="${TARGET}-ar"
    AS="${TARGET}-clang"
    LD="${TARGET}-ld"
    RANLIB="${TARGET}-ranlib"
else
    HOST="$(echo $(uname -s)-$(uname -m) | tr '[A-Z]' '[a-z]')"
    TOOLCHAIN="${ANDROIDNDK}/toolchains/llvm/prebuilt/${HOST}"
    SYSROOT="${TOOLCHAIN}/sysroot"
    case "${ABI}" in
        "armeabi-v7a")
            TARGET="armv7a-linux-androideabi${API}"
            ;;
        "arm64-v8a")
            TARGET="aarch64-linux-android${API}"
            ;;
        *)
            ;;
    esac
    AR="llvm-ar"
    AS="llvm-as"
    LD="ld.lld"
    RANLIB="llvm-ranlib"
    LDFLAGS="-L${SYSROOT}/usr/lib/${TRIPLET} ${LDFLAGS}"
    LDFLAGS="-L${SYSROOT}/usr/lib/${TRIPLET}/${API} ${LDFLAGS}"
fi
CC="${TARGET}-clang"
CPP="${CC} -E"
CXX="${TARGET}-clang++"
CFLAGS="--sysroot=${SYSROOT} ${CFLAGS}"
CFLAGS="--target=${TARGET} ${CFLAGS}"
CFLAGS="-fpic ${CFLAGS}"
CFLAGS="-march=${MARCH} ${CFLAGS}"
CFLAGS="-mfloat-abi=${FLOATABI} ${CFLAGS}"
CFLAGS="-mfpu=${FPU} ${CFLAGS}"
CPPFLAGS="-D__ANDROID_API__=${API} ${CPPFLAGS}"
CPPFLAGS="-isysroot ${SYSROOT} ${CPPFLAGS}"
CPPFLAGS="-isystem ${SYSROOT}/usr/include/${TRIPLET} ${CPPFLAGS}"
CXXFLAGS="${CFLAGS}"
ANDROIDLDSYSROOT="${ANDROIDNDK}/platforms/android-${API}/arch-${ARCH}"
LDFLAGS="--sysroot=${ANDROIDLDSYSROOT} ${LDFLAGS}"
PATH="${TOOLCHAIN}/bin:${PATH}"
PATH="${TOOLCHAIN}/${TRIPLET}/bin:${PATH}"
export ABI
export ANDROIDLDSYSROOT
export ANDROIDSYSROOT="${SYSROOT}"
export TARGET
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
