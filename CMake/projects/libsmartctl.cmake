set(LIBNAME libsmartctl)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/allanliu/smartmontools/archive/v0.3.1.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND} &&
    ${REPLACE_CMD} "1.15 1.14" "1.16 1.15 1.14" "autogen.sh"
  CONFIGURE_COMMAND
    ./autogen.sh
  COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-shared
      --enable-static
  BUILD_COMMAND
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
