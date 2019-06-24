set(LIBNAME libthrift)
set(DEPS libopenssl libboost)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/apache/thrift/archive/0.11.0.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND} &&
    patch -p1 < ${PATCH_DIR}/libthrift-0.11.0-1.patch
  CONFIGURE_COMMAND
    # ENV["PY_PREFIX"] = prefix
    # ENV.prepend_path "PATH", Formula["bison"].bin
    # ENV["LIBS"] = "/usr/lib/x86_64-linux-gnu/libfl.a" if OS.linux?
    export CXXFLAGS=-Wno-error\ $ENV{CXXFLAGS} &&
    export CPPFLAGS=-DOPENSSL_NO_SSL3\ $ENV{CPPFLAGS} &&
    ./bootstrap.sh &&
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-shared
      --enable-static
      --disable-tests
      --without-ruby
      --without-php_extension
      --without-haskell
      --without-java
      --without-perl
      --without-php
      --without-erlang
      --without-go
      --without-qt
      --without-qt4
      --without-qt5
      --without-d
      --without-lua
      --without-dart
      --without-nodejs
      --without-rs
      --without-python
      --with-cpp
      --with-libevent=no
      --enable-tutorial=no
      --with-openssl=<INSTALL_DIR>
      --with-boost=<INSTALL_DIR>
  BUILD_COMMAND
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
