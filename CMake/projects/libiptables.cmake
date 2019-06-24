set(LIBNAME libiptables)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://www.netfilter.org/projects/iptables/files/iptables-1.8.3.tar.bz2
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-nftables
      --disable-shared
  BUILD_COMMAND
    cd libiptc && $(MAKE)
  INSTALL_COMMAND
    cd libiptc && $(MAKE) install
  COMMAND
    cd include && $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
