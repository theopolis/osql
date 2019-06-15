set(LIBNAME libdpkg)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://launchpad.net/debian/+archive/primary/+sourcefiles/dpkg/1.19.0.5/dpkg_1.19.0.5.tar.xz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-dselect
      --disable-start-stop-daemon
  BUILD_COMMAND
    cd lib && make -j10
  INSTALL_COMMAND
    cd lib && make install
  EXCLUDE_FROM_ALL ON
)
