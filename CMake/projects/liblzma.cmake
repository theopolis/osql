set(LIBNAME liblzma)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://tukaani.org/xz/xz-5.2.4.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./autogen.sh &&
    ./configure --prefix=<INSTALL_DIR>
      --disable-shared
      --enable-static
  BUILD_COMMAND
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
