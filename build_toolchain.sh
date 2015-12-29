#!/bin/bash

echo "$0 <protura-root> <protura-prefix> <toolchain-dir>"

if [ "$#" -ne 4 ]; then
    echo "Error: Please supply correct arguments"
    exit 1
fi

PROTURA_ROOT="`readlink -f "$1"`"
PROTURA_PREFIX="`readlink -f "$2"`"
TOOLCHAIN_DIR="`readlink -f "$3"`"

echo "  Building Protura toolchain..."
echo "Protura root directory: $PROTURA_ROOT"
echo "Protura install prefix: $PROTURA_PREFIX"
echo "Toolchain directory:    $TOOLCHAIN_DIR"

rm -fr ./binutils-build ./gcc-build ./newlib-build

mkdir ./binutils-build
cd ./binutils-build
../binutils/configure --target=i686-protura --prefix="$TOOLCHAIN_DIR" --with-sysroot="$PROTURA_ROOT" --disable-werror
make
make install
cd ..

PATH="$PATH:$TOOLCHAIN_DIR/bin"

mkdir ./gcc-build
cd ./gcc-build
../gcc/configure \
    --target=i686-protura \
    --prefix="$TOOLCHAIN_DIR" \
    --with-sysroot="$PROTURA_ROOT" \
    --disable-werror \
    --disable-nls \
    --with-newlib \
    --enable-languages=c
make all-gcc
make install-gcc
cd ..

./build_newlib.sh "$PROTURA_ROOT" "$PROTURA_PREFIX" "$TOOLCHAIN_DIR"

cd ./gcc-build
make all-target-libgcc
make install-target-libgcc
cd ..

