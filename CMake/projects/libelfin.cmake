set(LIBNAME libelfin)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/aclements/libelfin/archive/v0.3.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND true
  BUILD_COMMAND
    # Error about -pie not used
    export CXXFLAGS=-Wno-unused-command-line-argument\ $ENV{CXXFLAGS} &&
    make -j10
  INSTALL_COMMAND
    make install
  EXCLUDE_FROM_ALL ON
)
