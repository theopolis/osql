set(LIBNAME liblinux-headers)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://gitlab.com/cryptsetup/cryptsetup/repository/v1_7_5/archive.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND true
  BUILD_COMMAND true
  INSTALL_COMMAND
    $(MAKE) headers_install INSTALL_HDR_PATH=<INSTALL_DIR>
  EXCLUDE_FROM_ALL ON
)
