set(LIBNAME libgcrypt)
set(DEPS libgpg-error)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.1.tar.bz2
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-shared
      --enable-static
      --disable-avx-support
      --disable-avx2-support
      --disable-drng-support
      --disable-pclmul-support
      --disable-sse41-support
      --disable-optimization
      --disable-asm
      --disable-jent-support
      --with-libgpg-error-prefix=<INSTALL_DIR>
      --with-gpg-error-prefix=<INSTALL_DIR>
  COMMAND
    ed -s - config.h < ${PATCH_DIR}/libgcrypt-1.8.1-1-config.h.ed
  BUILD_COMMAND
    cd cipher && $(MAKE)
  COMMAND
    cd random && $(MAKE)
  COMMAND
    cd mpi && $(MAKE)
  COMMAND
    cd compat && $(MAKE)
  COMMAND
    cd src && $(MAKE)
  INSTALL_COMMAND
    cd src && $(MAKE) install
  EXCLUDE_FROM_ALL ON
)