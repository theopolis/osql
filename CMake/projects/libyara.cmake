set(LIBNAME libyara)
set(DEPS libopenssl)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/VirusTotal/yara/archive/v3.7.1.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    # ENV.append "LDFLAGS", "-L#{Formula["osquery/osquery-local/pcre"].opt_lib} -lpcre"
    # Need PCRE?
    ./bootstrap.sh
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
