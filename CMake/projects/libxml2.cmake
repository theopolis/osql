set(LIBNAME libxml2)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL http://xmlsoft.org/sources/libxml2-2.9.7.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --without-python
      --without-lzma
      --with-zlib=<INSTALL_DIR>
      --disable-shared
      --enable-static
  BUILD_COMMAND
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install
  COMMAND
    ln -sf libxml2/libxml <INSTALL_DIR>/include/libxml
  EXCLUDE_FROM_ALL ON
)