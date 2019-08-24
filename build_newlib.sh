#!/bin/bash

echo "$0 <protura-target> <protura-root> <protura-prefix> <toolchain-dir> <make flags>"

if [ "$#" -lt 4 ]; then
    echo "Error: Please supply correct arguments"
    exit 1
fi

PROTURA_TARGET=$1
PROTURA_ROOT="`readlink -f "$2"`"
PROTURA_PREFIX="`readlink -f "$3"`"
TOOLCHAIN_DIR="`readlink -f "$4"`"
MAKE_FLAGS="$5"
HOST_TARGET=`gcc -dumpmachine`

echo "  Building Protura newlib..."
echo "Protura target:         $PROTURA_TARGET"
echo "Host target:            $HOST_TARGET"
echo "Protura root directory: $PROTURA_ROOT"
echo "Protura install prefix: $PROTURA_PREFIX"
echo "Toolchain directory:    $TOOLCHAIN_DIR"
echo "Make flags:             $MAKE_FLAGS"

rm -fr ./newlib-build
mkdir -p ./newlib-build
cd ./newlib-build

../newlib/configure \
    --host=$HOST_TARGET \
    --build=$HOST_TARGET \
    --target=$PROTURA_TARGET \
    --prefix="$PROTURA_PREFIX" \
    --with-sysroot="$PROTURA_ROOT" \
    --enable-newlib-elix-level=4 \
    --disable-werror \
    --disable-newlib-io-float \
    --disable-libgloss \
    || exit 1

make --quiet $MAKE_FLAGS \
    || exit 1

make --quiet DESTDIR="$PROTURA_ROOT" install \
    || exit 1

cd ..

