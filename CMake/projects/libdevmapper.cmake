set(LIBNAME libdevmapper)
set(DEPS libutil-linux)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://www.mirrorservice.org/sites/sourceware.org/pub/lvm2/old/LVM2.2.02.173.tgz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    # This is a hack
    export VALGRIND_CFLAGS=-fPIC\ -I/usr/include/valgrind &&
    ./configure
      --prefix=<INSTALL_DIR>
      --with-lvm1=none
      --disable-selinux
      --disable-readline
      --enable-static_link
  BUILD_COMMAND
    make -j10 libdm.device-mapper
  COMMAND
    cd libdm && make -j10 install
  COMMAND
    cd lib && make -j10
  COMMAND
    cd libdaemon && make -j10
  COMMAND
    cd liblvm && make -j10 install
  INSTALL_COMMAND
    cp lib/liblvm-internal.a <INSTALL_DIR>/lib
  COMMAND
    cp libdaemon/client/libdaemonclient.a <INSTALL_DIR>/lib
  EXCLUDE_FROM_ALL ON
)
