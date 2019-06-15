#!/usr/bin/env bash

#  Copyright (c) 2014-present, Facebook, Inc.
#  All rights reserved.
#
#  This source code is licensed under both the Apache 2.0 license (found in the
#  LICENSE file in the root directory of this source tree) and the GPLv2 (found
#  in the COPYING file in the root directory of this source tree).
#  You may select, at your option, one of the above-listed licenses.


function clean_thrift() {
  TEST_FILE="$DEPS/lib/python2.7/site-packages/thrift"
  if [ ! -L "$TEST_FILE/__init__.py" ]; then
    rm -rf "${TEST_FILE}"*
  fi
}

function package() {
  if [[ $FAMILY = "debian" ]]; then
    INSTALLED=`dpkg-query -W -f='${Status} ${Version}\n' $1 || true`
    if [[ -n "$INSTALLED" && ! "$INSTALLED" = *"unknown ok not-installed"* ]]; then
      log "$1 is already installed. skipping."
    else
      log "installing $1"
      sudo DEBIAN_FRONTEND=noninteractive apt-get install $1 -y -q --no-install-recommends
    fi
  elif [[ $FAMILY = "redhat" ]]; then
    if [[ ! -n "$(rpm -V $1)" ]]; then
      log "$1 is already installed. skipping."
    else
      log "installing $1"
      if [[ $OS = "fedora" ]]; then
        sudo dnf install $1 -y
      else
        sudo yum install $1 -y
      fi
    fi
  elif [[ $OS = "darwin" ]]; then
    if [[ -n "$(brew list | grep $1)" ]]; then
      log "$1 is already installed. skipping."
    else
      log "installing $1"
      unset LIBNAME
      unset HOMEBREW_BUILD_FROM_SOURCE
      export HOMEBREW_MAKE_JOBS=$THREADS
      export HOMEBREW_NO_EMOJI=1
      HOMEBREW_ARGS=""
      if [[ $1 = "rocksdb" ]]; then
        # Build RocksDB from source in brew
        export LIBNAME=librocksdb_lite
        export HOMEBREW_BUILD_FROM_SOURCE=1
        HOMEBREW_ARGS="--build-bottle --with-lite"
      elif [[ $1 = "gflags" ]]; then
        HOMEBREW_ARGS="--build-bottle --with-static"
      elif [[ $1 = "libressl" ]]; then
        HOMEBREW_ARGS="--build-bottle"
      elif [[ $1 = "aws-sdk-cpp" ]]; then
        HOMEBREW_ARGS="--build-bottle --with-static --without-http-client"
      fi
      if [[ "$2" = "devel" ]]; then
        HOMEBREW_ARGS="${HOMEBREW_ARGS} --devel"
      fi
      brew install -v $HOMEBREW_ARGS $1 || brew upgrade -v $HOMEBREW_ARGS $1
    fi
  elif [[ $OS = "freebsd" ]]; then
    if pkg info -q $1; then
      log "$1 is already installed. skipping."
    else
      log "installing $1"
      sudo pkg install -y $1
    fi
  elif [ $OS = "arch" ] || [ $OS="manjaro" ]; then
    if pacman -Qq $1 >/dev/null; then
      log "$1 is already installed. skipping."
    else
      log "installing $1"
      sudo pacman -S --noconfirm $1
    fi
  fi
}

function ports() {
  PKG="$1"
  log "building port $1"
  (cd /usr/ports/$1; do_sudo make deinstall)
  (cd /usr/ports/$1; do_sudo make install clean BATCH=yes)
}

function check() {
  CMD="$1"
  DISTRO_BUILD_DIR="$2"
  platform OS

  if [[ $OS = "darwin" ]]; then
    HASH=`shasum "$0" | awk '{print $1}'`
  elif [[ $OS = "freebsd" ]]; then
    HASH=`sha1 -q "$0"`
  else
    HASH=`sha1sum "$0" | awk '{print $1}'`
  fi

  if [[ "$CMD" = "build" ]]; then
    echo $HASH > "build/$DISTRO_BUILD_DIR/.provision"
    if [[ ! -z "$SUDO_USER" ]]; then
      chown $SUDO_USER "build/$DISTRO_BUILD_DIR/.provision" > /dev/null 2>&1 || true
    fi
    return
  elif [[ ! "$CMD" = "check" ]]; then
    return
  fi

  if [[ "$#" < 2 ]]; then
    echo "Usage: $0 (check|build) BUILD_PATH"
    exit 1
  fi

  CHECKPOINT=`cat $DISTRO_BUILD_DIR/.provision 2>&1 &`
  if [[ ! $HASH = $CHECKPOINT ]]; then
    echo "Requested dependencies may have changed, run: make deps"
    exit 1
  fi
  exit 0
}
