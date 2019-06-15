set(LIBNAME libcryptosetup)
set(DEPS libutil-linux libdevmapper libpopt libgcrypt)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://gitlab.com/cryptsetup/cryptsetup/repository/v1_7_5/archive.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./autogen.sh
      --prefix=<INSTALL_DIR>
      --with-libgcrypt-prefix=<INSTALL_DIR>
      --disable-selinux
      --disable-udev
      --disable-veritysetup
      --disable-nls
      --disable-kernel_crypto
      --disable-shared
      --enable-static
  BUILD_COMMAND
    cd lib && make -j10
  INSTALL_COMMAND
    cd lib && make install
  EXCLUDE_FROM_ALL ON
)
