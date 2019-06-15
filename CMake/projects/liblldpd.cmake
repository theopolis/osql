set(LIBNAME liblldpd)
set(DEPS libxml2 libz libbzip2)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://media.luffy.cx/files/lldpd/lldpd-0.9.6.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./autogen.sh
  COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --with-systemdsystemunitdir=<INSTALL_DIR>/share
      --with-sysusersdir=<INSTALL_DIR>/share
      --with-privsep-chroot=/var/empty
      --with-privsep-user=nobody
      --with-privsep-group=nogroup
      --with-launchddaemonsdir=no
      --disable-shared
      --enable-static
  BUILD_COMMAND
    make -j10
  INSTALL_COMMAND
    make install
  EXCLUDE_FROM_ALL ON
)
