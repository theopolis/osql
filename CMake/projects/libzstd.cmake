set(LIBNAME libzstd)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/facebook/zstd/archive/v1.2.0.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND true
  BUILD_COMMAND
    make lib-release
  INSTALL_COMMAND
    make install PREFIX=<INSTALL_DIR>
  EXCLUDE_FROM_ALL ON
)
