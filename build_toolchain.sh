#!/bin/bash

echo "$0 <protura-target> <protura-root> <protura-prefix> <toolchain-dir>"

if [ "$#" -ne 4 ]; then
    echo "Error: Please supply correct arguments"
    exit 1
fi

PROTURA_TARGET=$1
PROTURA_ROOT="`readlink -f "$2"`"
PROTURA_PREFIX="`readlink -f "$3"`"
TOOLCHAIN_DIR="`readlink -f "$4"`"

echo "  Building Protura toolchain..."
echo "Protura target:         $PROTURA_TARGET"
echo "Protura root directory: $PROTURA_ROOT"
echo "Protura install prefix: $PROTURA_PREFIX"
echo "Toolchain directory:    $TOOLCHAIN_DIR"

rm -fr ./binutils-build ./gcc-build ./newlib-build

mkdir ./binutils-build
cd ./binutils-build

../binutils/configure --target=$PROTURA_TARGET --prefix="$TOOLCHAIN_DIR" --with-sysroot="$PROTURA_ROOT" --disable-werror \
    || exit 1

make \
    || exit 1

make install \
    || exit 1

ln -s "$TOOLCHAIN_DIR/bin/$PROTURA_TARGET-gcc" "$TOOLCHAIN_DIR/bin/$PROTURA_TARGET-cc"
cd ..

PATH="$PATH:$TOOLCHAIN_DIR/bin"

mkdir ./gcc-build
cd ./gcc-build

../gcc/configure \
    --target=$PROTURA_TARGET \
    --prefix="$TOOLCHAIN_DIR" \
    --with-sysroot="$PROTURA_ROOT" \
    --disable-werror \
    --disable-nls \
    --with-newlib \
    --enable-languages=c,c++ \
    || exit 1

make all-gcc \
    || exit 1

make install-gcc \
    || exit 1

cd ..

./build_newlib.sh "$PROTURA_TARGET" "$PROTURA_ROOT" "$PROTURA_PREFIX" "$TOOLCHAIN_DIR" \
    || (echo "Error building newlib"; exit 1)

cd ./gcc-build
make all-target-libgcc \
    || exit 1

make install-target-libgcc \
    || exit 1

cd ..

