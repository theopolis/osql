set(LIBNAME librdkafka)
set(DEPS libz libbzip2)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/edenhill/librdkafka/archive/v1.0.1.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND} &&
    patch -p1 < ${PATCH_DIR}/librdkafka-1.0.1-1.patch
  CONFIGURE_COMMAND
    export LDFLAGS=-L<INSTALL_DIR>/lib &&
    export LIBS=-lcrypto &&
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-sasl
      --disable-gssapi
      --disable-lz4-ext
      --enable-static
  BUILD_COMMAND
    cd src && make -j10
  INSTALL_COMMAND
    cd src && make install
  EXCLUDE_FROM_ALL ON
)
