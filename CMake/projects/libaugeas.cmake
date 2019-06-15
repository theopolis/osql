set(LIBNAME libaugeas)
set(DEPS libxml2)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL http://download.augeas.net/augeas-1.12.0.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND} &&
    patch -p1 < ${PATCH_DIR}/libaugeas-1.12.0-1.patch
  CONFIGURE_COMMAND
    # ENV.append_to_cflags "-I/usr/include/libxml2" if OS.mac?
    autoreconf
  COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --enable-shared=no
      --without-selinux
  BUILD_COMMAND
    cd gnulib/lib && make -j10
  COMMAND
    cd src &&
      make datadir.h &&
      make install-libLTLIBRARIES &&
      make install-data-am
  INSTALL_COMMAND
    make install-data-am
  EXCLUDE_FROM_ALL ON
)
