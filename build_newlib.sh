#!/bin/bash

echo "$0 <protura-root> <protura-prefix> <toolchain-dir>"

if [ "$#" -ne 3 ]; then
    echo "Error: Please supply correct arguments"
    exit 1
fi

PROTURA_ROOT="`readlink -f "$1"`"
PROTURA_PREFIX="`readlink -f "$2"`"
TOOLCHAIN_DIR="`readlink -f "$3"`"

echo "  Building Protura newlib..."
echo "Protura root directory: $PROTURA_ROOT"
echo "Protura install prefix: $PROTURA_PREFIX"
echo "Toolchain directory:    $TOOLCHAIN_DIR"

rm -fr ./newlib-build
mkdir -p ./newlib-build
cd ./newlib-build
../newlib/configure \
    --target=i686-protura \
    --prefix="$PROTURA_PREFIX" \
    --with-sysroot="$PROTURA_ROOT" \
    --enable-newlib-elix-level=4 \
    --disable-werror
make
make DESTDIR="$PROTURA_ROOT" install
cd ..

