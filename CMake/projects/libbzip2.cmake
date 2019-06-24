set(LIBNAME libbzip2)
set(DEPS libz)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL http://http.debian.net/debian/pool/main/b/bzip2/bzip2_1.0.6.orig.tar.bz2
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  DEPENDS ${PROJECT_DEPS}
  CONFIGURE_COMMAND
    ${CLEAR_COMMAND} &&
    ${REPLACE_CMD} "CFLAGS=" "CFLAGS=$ENV{CFLAGS} " Makefile &&
    ${REPLACE_CMD} "CC=gcc" "CC=$ENV{CC}" Makefile
  BUILD_COMMAND true
  INSTALL_COMMAND
    $(MAKE) install PREFIX=<INSTALL_DIR>
  EXCLUDE_FROM_ALL ON
)
