set(LIBNAME libpopt)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://fossies.org/linux/misc/popt-1.16.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-debug
      --disable-shared
      --enable-static
  BUILD_COMMAND
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
