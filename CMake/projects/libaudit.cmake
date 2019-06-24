set(LIBNAME libaudit)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/Distrotech/libaudit/archive/audit-2.4.2.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND} &&
    touch INSTALL.tmp
  CONFIGURE_COMMAND
    ./autogen.sh
  COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-shared
      --enable-static
  BUILD_COMMAND
    cd lib && $(MAKE)
  INSTALL_COMMAND
    cd lib && $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
