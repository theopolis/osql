set(LIBNAME libsleuthkit)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/sleuthkit/sleuthkit/archive/sleuthkit-4.6.1.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./bootstrap
  COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-java
      --disable-shared
      --enable-static
  BUILD_COMMAND
    make -j10
  INSTALL_COMMAND
    make install
  EXCLUDE_FROM_ALL ON
)
