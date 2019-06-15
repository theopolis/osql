set(LIBNAME libarchive)
set(DEPS liblzma libbzip2)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL http://www.libarchive.org/downloads/libarchive-3.3.2.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure --prefix=<INSTALL_DIR>
      --without-lzo2
      --without-nettle
      --without-xml2
      --without-openssl
      --with-expat
      --disable-shared
      --enable-static
  BUILD_COMMAND
    make -j10
  INSTALL_COMMAND
    make install
  EXCLUDE_FROM_ALL ON
)
