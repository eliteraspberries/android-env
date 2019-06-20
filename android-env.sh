#!/bin/sh
set -x
if test -z "$API"; then API="19"; fi
if test -z "$ARCH"; then ARCH="arm"; fi
FLOATABI="softfp"
if test -z "$FPU"; then FPU="vfpv4"; fi
if test -z "$MARCH"; then MARCH="armv7-a"; fi
if test -z "$ANDROIDHOME"; then ANDROIDHOME="$HOME/Library/Android"; fi
ANDROIDSDK="$ANDROIDHOME/sdk"
ANDROIDNDK="$ANDROIDSDK/ndk-bundle"
SYSROOT="$ANDROIDNDK/sysroot"
if ! test -d android-toolchain; then
    $ANDROIDNDK/build/tools/make_standalone_toolchain.py \
        --arch $ARCH \
        --api $API \
        --install-dir=android-toolchain
fi
export TARGET="$ARCH-linux-androideabi"
export AR="$TARGET-ar"
export AS="$TARGET-clang"
export CC="$TARGET-clang"
export CPP="$CC -E"
export LD="$TARGET-ld"
export RANLIB="$TARGET-ranlib"
export CFLAGS="--sysroot=$SYSROOT $CFLAGS"
export CFLAGS="-fpic $CFLAGS"
export CFLAGS="-march=$MARCH $CFLAGS"
export CFLAGS="-mfloat-abi=$FLOATABI $CFLAGS"
export CFLAGS="-mfpu=$FPU $CFLAGS"
export CPPFLAGS="-D__ANDROID_API__=$API $CPPFLAGS"
export CPPFLAGS="-isysroot $SYSROOT $CPPFLAGS"
export CPPFLAGS="-isystem $SYSROOT/usr/include/$TARGET $CPPFLAGS"
export LDFLAGS="--sysroot=$ANDROIDNDK/platforms/android-$API/arch-$ARCH $LDFLAGS"
export PATH="$(pwd)/android-toolchain/bin:$PATH"
exec $@
