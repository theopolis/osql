set(LIBNAME librpm)
set(DEPS libopenssl libpopt libberkeley-db libmagic)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

if(APPLE)
  set(XTRA_LIBS "-lz -liconv")
endif()

ExternalProject_Add(third-party-${LIBNAME}
  URL http://ftp.rpm.org/releases/rpm-4.14.x/rpm-4.14.1.tar.bz2
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND} &&
    patch -p1 < ${PATCH_DIR}/librpm-4.14.1-1.patch
  CONFIGURE_COMMAND
    export LIBS=${XTRA_LIBS} &&
    ./configure
      --prefix=<INSTALL_DIR>
      --with-external-db
      --without-selinux
      --without-lua
      --without-cap
      --without-archive
      --disable-nls
      --disable-rpath
      --disable-plugins
      --disable-python
      --enable-zstd=no
      --with-crypto=openssl
      --disable-shared
      --enable-static
  BUILD_COMMAND
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install
  EXCLUDE_FROM_ALL ON
)

if(APPLE)
  ExternalProject_Add_Step(third-party-${LIBNAME} darwin_patch
    COMMAND
      cd <BINARY_DIR> &&
      patch -p1 < ${PATCH_DIR}/librpm-4.14.1-1-darwin.patch
    DEPENDEES patch
    DEPENDERS configure
  )
endif()
