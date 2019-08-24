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

echo "  Building Protura toolchain..."
echo "Protura target:         $PROTURA_TARGET"
echo "Host target:            $HOST_TARGET"
echo "Protura root directory: $PROTURA_ROOT"
echo "Protura install prefix: $PROTURA_PREFIX"
echo "Toolchain directory:    $TOOLCHAIN_DIR"
echo "Make flags:             $MAKE_FLAGS"

rm -fr ./binutils-build ./gcc-build ./newlib-build

mkdir ./binutils-build
cd ./binutils-build

../binutils/configure \
    --host=$HOST_TARGET \
    --build=$HOST_TARGET \
    --target=$PROTURA_TARGET \
    --prefix="$TOOLCHAIN_DIR" \
    --with-sysroot="$PROTURA_ROOT" \
    --disable-maintainer-mode \
    --disable-werror \
    --disable-gdb \
    || exit 1

make $MAKE_FLAGS \
    || exit 1

make install \
    || exit 1

ln -s "$TOOLCHAIN_DIR/bin/$PROTURA_TARGET-gcc" "$TOOLCHAIN_DIR/bin/$PROTURA_TARGET-cc"
cd ..

PATH="$PATH:$TOOLCHAIN_DIR/bin"

mkdir ./gcc-build
cd ./gcc-build

../gcc/configure \
    --host=$HOST_TARGET \
    --build=$HOST_TARGET \
    --target=$PROTURA_TARGET \
    --prefix="$TOOLCHAIN_DIR" \
    --with-sysroot="$PROTURA_ROOT" \
    --disable-maintainer-mode \
    --disable-werror \
    --disable-nls \
    --with-newlib \
    --enable-languages=c,c++ \
    || exit 1

make all-gcc $MAKE_FLAGS \
    || exit 1

make install-gcc \
    || exit 1

cd ..

./build_newlib.sh "$PROTURA_TARGET" "$PROTURA_ROOT" "$PROTURA_PREFIX" "$TOOLCHAIN_DIR" \
    || (echo "Error building newlib"; exit 1)

cd ./gcc-build
make all-target-libgcc $MAKE_FLAGS \
    || exit 1

make install-target-libgcc \
    || exit 1

make all-target-libstdc++-v3 $MAKE_FLAGS \
    || exit 1

make install-target-libstdc++-v3 $MAKE_FLAGS \
    || exit 1

cd ..

