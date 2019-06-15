set(LIBNAME libgpg-error)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.27.tar.bz2
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-shared
      --enable-statci
  BUILD_COMMAND
    make -j10
  INSTALL_COMMAND
    make install
  EXCLUDE_FROM_ALL ON
)
