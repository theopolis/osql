set(LIBNAME libiptables)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://www.netfilter.org/projects/iptables/files/iptables-1.8.3.tar.bz2
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-nftables
      --disable-shared
  BUILD_COMMAND
    cd libiptc && make -j10
  INSTALL_COMMAND
    cd libiptc && make install
  COMMAND
    cd include && make install
  EXCLUDE_FROM_ALL ON
)
