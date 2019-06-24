set(LIBNAME libelfin)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/aclements/libelfin/archive/v0.3.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND true
  BUILD_COMMAND
    # Error about -pie not used
    export CXXFLAGS=-Wno-unused-command-line-argument\ $ENV{CXXFLAGS} &&
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
