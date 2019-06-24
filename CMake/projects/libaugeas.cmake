set(LIBNAME libaugeas)
set(DEPS libxml2)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL http://download.augeas.net/augeas-1.12.0.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND} &&
    patch -p1 < ${PATCH_DIR}/libaugeas-1.12.0-1.patch
  CONFIGURE_COMMAND
    autoreconf
  COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --enable-shared=no
      --without-selinux
  BUILD_COMMAND
    cd gnulib/lib && $(MAKE)
  COMMAND
    cd src &&
      $(MAKE) datadir.h &&
      $(MAKE) install-libLTLIBRARIES &&
      $(MAKE) install-data-am
  INSTALL_COMMAND
    $(MAKE) install-data-am
  EXCLUDE_FROM_ALL ON
)
