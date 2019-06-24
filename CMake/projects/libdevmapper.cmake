set(LIBNAME libdevmapper)
set(DEPS libutil-linux)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://www.mirrorservice.org/sites/sourceware.org/pub/lvm2/old/LVM2.2.02.173.tgz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
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
    $(MAKE) libdm.device-mapper
  COMMAND
    cd libdm && $(MAKE) install
  COMMAND
    cd lib && $(MAKE)
  COMMAND
    cd libdaemon && $(MAKE)
  COMMAND
    cd liblvm && $(MAKE) install
  INSTALL_COMMAND
    cp lib/liblvm-internal.a <INSTALL_DIR>/lib
  COMMAND
    cp libdaemon/client/libdaemonclient.a <INSTALL_DIR>/lib
  EXCLUDE_FROM_ALL ON
)
