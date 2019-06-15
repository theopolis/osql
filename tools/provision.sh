#!/usr/bin/env bash

#  Copyright (c) 2014-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under both the Apache 2.0 license (found in the
#  LICENSE file in the root directory of this source tree) and the GPLv2 (found
#  in the COPYING file in the root directory of this source tree).
#  You may select, at your option, one of the above-listed licenses.

set -e

# Helpful defines for the provisioning process.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUILD_DIR="$SCRIPT_DIR/../build"

# This might not be defined in docker containers, lets use a value we can always obtain
USER=`id -u -n`

source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/provision/lib.sh"

function platform_linux_main() {
  #brew_tool osquery/osquery-local/patchelf
  #brew_tool osquery/osquery-local/zlib
  #brew_tool osquery/osquery-local/linux-headers
  #brew_tool osquery/osquery-local/sqlite

  #brew_tool osquery/osquery-local/glibc-legacy
  #brew_tool osquery/osquery-local/zlib-legacy


  #if [ ! -d "$DEPS_DIR/Cellar/xz" ]; then
#    log "Installing temporary xz..."
#    mkdir -p "$DEPS_DIR/opt/xz/bin"
#    ln -sf `which xz` "$DEPS_DIR/opt/xz/bin"
#  fi

#  brew_tool osquery/osquery-local/gcc
#  brew_tool osquery/osquery-local/llvm
#  brew_dependency osquery/osquery-local/libcpp

#  if [ ! -d "$DEPS_DIR/Cellar/xz" ]; then
#    rm -rf "$DEPS_DIR/opt/xz"
#  fi


  # Need LZMA for final builds.
  brew_dependency osquery/osquery-local/xz
  brew_dependency osquery/osquery-local/ncurses
  brew_dependency osquery/osquery-local/bzip2
  brew_dependency osquery/osquery-local/libudev
  brew_dependency osquery/osquery-local/util-linux

  # OpenSSL is needed for the final build.
  brew_dependency osquery/osquery-local/libxml2
  brew_dependency osquery/osquery-local/openssl

  # Curl and Python are needed for LLVM mostly.
  brew_dependency osquery/osquery-local/python
  brew_dependency osquery/osquery-local/cmake

  platform_posix_main

  # General Linux dependencies and custom formulas for table implementations.
  brew_dependency osquery/osquery-local/libgpg-error
  brew_dependency osquery/osquery-local/libdevmapper
  brew_dependency osquery/osquery-local/libiptables
  brew_dependency osquery/osquery-local/libgcrypt
  brew_dependency osquery/osquery-local/libcryptsetup
  brew_dependency osquery/osquery-local/libudev
  brew_dependency osquery/osquery-local/libaudit
  brew_dependency osquery/osquery-local/libdpkg
  brew_dependency osquery/osquery-local/libelfin
  brew_dependency osquery/osquery-local/libsmartctl
}

function platform_darwin_main() {
  brew_tool osquery/osquery-local/readline
  brew_tool osquery/osquery-local/sqlite
  brew_tool osquery/osquery-local/pkg-config
  brew_tool osquery/osquery-local/makedepend
  brew_tool osquery/osquery-local/clang-format
  brew_tool osquery/osquery-local/autoconf
  brew_tool osquery/osquery-local/automake
  brew_tool osquery/osquery-local/libtool

  brew_dependency osquery/osquery-local/xz
  brew_dependency osquery/osquery-local/cmake
  brew_dependency osquery/osquery-local/libxml2
  brew_dependency osquery/osquery-local/openssl

  brew_dependency osquery/osquery-local/python
  brew_dependency osquery/osquery-local/bison
  brew_dependency osquery/osquery-local/libsmartctl

  platform_posix_main
}

 function platform_posix_main() {
  # Library secondary dependencies.
  brew_dependency osquery/osquery-local/popt
  brew_dependency osquery/osquery-local/berkeley-db
  brew_dependency osquery/osquery-local/ssdeep-cpp

  # libarchive for file carving
  brew_dependency osquery/osquery-local/libarchive
  brew_dependency osquery/osquery-local/rapidjson
  brew_dependency osquery/osquery-local/zstd

  # List of LLVM-compiled dependencies.
  brew_dependency osquery/osquery-local/libmagic
  brew_dependency osquery/osquery-local/pcre
  brew_dependency osquery/osquery-local/boost
  brew_dependency osquery/osquery-local/google-benchmark
  brew_dependency osquery/osquery-local/sleuthkit
  brew_dependency osquery/osquery-local/thrift
  brew_dependency osquery/osquery-local/rocksdb
  brew_dependency osquery/osquery-local/gflags
  brew_dependency osquery/osquery-local/aws-sdk-cpp
  brew_dependency osquery/osquery-local/yara
  brew_dependency osquery/osquery-local/glog
  brew_dependency osquery/osquery-local/augeas
  brew_dependency osquery/osquery-local/lldpd
  brew_dependency osquery/osquery-local/librdkafka
  brew_dependency osquery/osquery-local/librpm

  # POSIX-shared locally-managed tools.
  brew_dependency osquery/osquery-local/zzuf
  brew_dependency osquery/osquery-local/cppcheck
  brew_dependency osquery/osquery-local/ccache
}

function sysprep() {
  RUN_SYSPREP=false
  if [[ ! -z "$SKIP_DISTRO_MAIN" ]]; then
    if [[ "$SKIP_DISTRO_MAIN" = "False" || "$SKIP_DISTRO_MAIN" = "0" ]]; then
      RUN_SYSPREP=true
    fi
  fi

  if [[ ! "$RUN_SYSPREP" = "true" ]]; then
    return
  fi

  # Each OS/Distro may have specific provisioning needs.
  # These scripts are optional and should installed the needed packages for:
  # 1. A basic ruby interpreter to run brew
  # 2. A GCC compiler to compile a modern glibc/GCC and legacy glibc.
  # 3. Curl, git, autotools, autopoint, and gawk.
  OS_SCRIPT="$SCRIPT_DIR/provision/$OS.sh"
  if [[ -f "$OS_SCRIPT" ]]; then
    log "found $OS provision script: $OS_SCRIPT"
    source "$OS_SCRIPT"
    if [[ "$1" = "build" ]]; then
      distro_main
    fi
  else
    log "your $OS does not use a provision script"
  fi
}

function main() {
  ACTION=$1

  platform OS
  distro $OS DISTRO
  threads THREADS

  if ! hash sudo 2>/dev/null; then
    echo "Please install sudo in this machine"
    exit 1
  fi

  # Setup the local ./build/DISTRO cmake build directory.
  if [[ ! -z "$SUDO_USER" ]]; then
    echo "chown -h $SUDO_USER $BUILD_DIR/*"
    chown -h $SUDO_USER:$SUDO_GID "$BUILD_DIR" || true
    if [[ $OS = "linux" ]]; then
      chown -h $SUDO_USER:$SUDO_GID "$BUILD_DIR/linux" || true
    fi
    chown $SUDO_USER:$SUDO_GID "$WORKING_DIR" > /dev/null 2>&1 || true
  fi

  sysprep $ACTION

  # Save the directory we're executing from and change to the deps directory.
  # Other imported scripts may need to reference the repository directory.
  export CURRENT_DIR=$(pwd)

  initialize $OS
}

check $1 "$2"
main $1 "$2"
