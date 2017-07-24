#!/bin/bash
# Copyright (C) 2015-2016 UBERTC
# This file is free software; UBER TOOLCHAINS
# gives unlimited permission to copy and/or distribute it,
# with or without modifications, as long as this notice is preserved.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, to the extent permitted by law; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.

# Colorize build warnings, errors, and scripted prints
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
red=$(tput setaf 1) # red
grn=$(tput setaf 2) # green
blu=$(tput setaf 4) # blue
txtbld=$(tput bold) # Bold
bldred=${txtbld}$(tput setaf 1) # red
bldgrn=${txtbld}$(tput setaf 2) # green
bldblu=${txtbld}$(tput setaf 4) # blue
txtrst=$(tput sgr0) # Reset

echo ""
echo "${bldblu}Your system is preparing to build ....                          ${txtrst}"
echo ""
echo "${bldblu} ______________________________________________________________ ${txtrst}"
echo "${bldblu}|                                                              |${txtrst}"
echo "${bldblu}| _|    _|  _|_|_|    _|_|_|_|  _|_|_|    _|_|_|_|_|    _|_|_| |${txtrst}"
echo "${bldblu}| _|    _|  _|    _|  _|        _|    _|      _|      _|       |${txtrst}"
echo "${bldblu}| _|    _|  _|_|_|    _|_|_|    _|_|_|        _|      _|       |${txtrst}"
echo "${bldblu}| _|    _|  _|    _|  _|        _|    _|      _|      _|       |${txtrst}"
echo "${bldblu}| _|    _|  _|    _|  _|        _|    _|      _|      _|       |${txtrst}"
echo "${bldblu}|   _|_|    _|_|_|    _|_|_|_|  _|    _|      _|        _|_|_| |${txtrst}"
echo "${bldblu}|______________________________________________________________|${txtrst}"
echo ""
echo ""

cd ../gcc/gcc-UBER && rm -rf * && git reset --hard && git fetch uu uber-7.0 && git checkout FETCH_HEAD;
cd ../../binutils/binutils-uber && rm -rf * && git reset --hard && git fetch uu 2.27 && git checkout FETCH_HEAD;
cd ../../
export DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
export NUM_JOBS="$(cat /proc/cpuinfo | grep -c processor)";
MAKE_FLAGS=-j"$NUM_JOBS";

echo ""
echo "${bldblu}Cleaning up files from previous compile!${txtrst}"
echo ""
cd build;
if [ -e Makefile ];
then
    make $MAKE_FLAGS clean &> /dev/null;
    make $MAKE_FLAGS distclean &> /dev/null;
fi;
export UBER_PATH=$DIR/out/aarch64-linux-android-7.x;
export PREFIX=--prefix=$UBER_PATH;
if [ -d "$UBER_PATH" ];
then
    rm -rf $UBER_PATH;
    mkdir -p $UBER_PATH;
else
    mkdir -p $UBER_PATH;
fi;

# UBERROOT
cd ../sysroot && rm -rf * && git reset --hard && git fetch uu gcc-6.x && git checkout FETCH_HEAD && cd ../build;
export UBERROOT_SRC_PATH=../sysroot/arch-arm64;
export UBERROOT_DEST_PATH=$UBER_PATH;
cp -R $UBERROOT_SRC_PATH -f $UBERROOT_DEST_PATH;
export UBERROOT=--with-sysroot=$UBERROOT_DEST_PATH/arch-arm64;

# Build Configuration
./configure $PREFIX $UBERROOT --host=x86_64-linux-gnu --build=x86_64-linux-gnu --target=aarch64-linux-android --program-transform-name='s&^&aarch64-linux-android-&' --with-gcc-version=UBER --with-pkgversion='UBERTC-7.x.x' --with-binutils-version=uber --with-gmp-version=uber --with-mpfr-version=uber --with-mpc-version=uber --with-cloog-version=uber --with-isl-version=uber --enable-threads --enable-ld=default --enable-fix-cortex-a53-835769 --enable-plugins --enable-gold --disable-option-checking --disable-libsanitizer --enable-libatomic-ifuncs=no --enable-initfini-array --disable-softfloat --disable-docs --disable-nls --with-host-libstdcxx='-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm' --disable-bootstrap --quiet --with-gxx-include-dir=$UBERROOT_DEST_PATH/c++ --disable-werror --disable-shared --disable-gdb;

echo ""
echo "${bldblu}Building your UBER aarch64-7.x Toolchain!!!${txtrst}"
echo ""
all1=$(date +%s.%N)
script -q $DIR/out/UBER-AARCH64-7.x.log -c "make 1>/dev/null $MAKE_FLAGS";

echo ""
echo "${bldblu}Installing Toolchain to:${txtrst}${blu} $UBER_PATH ${txtrst}"
echo ""
make install &> /dev/null;

GCC_INSTALLED=$UBER_PATH/bin/aarch64-linux-android-gcc;
strip -s $UBER_PATH/bin/*
strip -s $UBER_PATH/aarch64-linux-android/bin/*
strip -s $UBER_PATH/libexec/gcc/aarch64-linux-android/*/*
if [ -e $GCC_INSTALLED ];
then
    rm -rf $UBERROOT_DEST_PATH/arch-arm64;
    echo ""
    echo "${bldgrn}  _|_|_|  _|    _|    _|_|_|    _|_|_|  _|_|_|_|    _|_|_|    _|_|_|  _|${txtrst}"
    echo "${bldgrn}_|        _|    _|  _|        _|        _|        _|        _|        _|${txtrst}"
    echo "${bldgrn}  _|_|    _|    _|  _|        _|        _|_|_|      _|_|      _|_|    _|${txtrst}"
    echo "${bldgrn}      _|  _|    _|  _|        _|        _|              _|        _|    ${txtrst}"
    echo "${bldgrn}_|_|_|      _|_|      _|_|_|    _|_|_|  _|_|_|_|  _|_|_|    _|_|_|    _|${txtrst}"
    echo ""
    echo "${bldgrn}Your UBER 6.x aarch64 Toolchain has completed successfully!!! ${txtrst}"
    echo "${bldgrn}Toolchain is located at:${txtrst}${grn} $UBER_PATH ${txtrst}"
    echo ""
    all2=$(date +%s.%N)
    echo "${bldgrn}Total elapsed time: ${txtrst}${grn}$(echo "($all2 - $all1) / 60"|bc ) minutes ($(echo "$all2 - $all1"|bc ) seconds) ${txtrst}"
    sleep 5
else
    echo ""
    echo "${bldred}_|_|_|_|  _|_|_|    _|_|_|      _|_|    _|_|_|  ${txtrst}"
    echo "${bldred}_|        _|    _|  _|    _|  _|    _|  _|    _|${txtrst}"
    echo "${bldred}_|_|_|    _|_|_|    _|_|_|    _|    _|  _|_|_|  ${txtrst}"
    echo "${bldred}_|        _|    _|  _|    _|  _|    _|  _|    _|${txtrst}"
    echo "${bldred}_|_|_|_|  _|    _|  _|    _|    _|_|    _|    _|${txtrst}"
    echo ""
    echo "${bldred}Error Log is found at:${txtrst}${red} $DIR/out/UBER-AARCH64-6.x.log ${txtrst}"
    echo ""
    read -p "Press ENTER to Exit"
fi;
