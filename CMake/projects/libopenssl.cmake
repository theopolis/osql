set(LIBNAME libopenssl)

ADD_OSQUERY_NEWDEP(${LIBNAME})

if(APPLE)
  set(OPENSSL_TARGETS darwin64-x86_64-cc enable-ec_nistp_64_gcc_128)
else()
  set(OPENSSL_TARGETS linux-x86_64)
endif()

ExternalProject_Add(third-party-${LIBNAME}
  URL https://www.openssl.org/source/openssl-1.0.2o.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    perl ./Configure --prefix=<INSTALL_DIR>
      --openssldir=<INSTALL_DIR>/etc/openssl
      no-ssl2
      no-ssl3
      no-asm
      no-shared
      no-weak-ssl-ciphers
      zlib-dynamic
      enable-cms
      "$ENV{CFLAGS}"
      ${OPENSSL_TARGETS}
  BUILD_COMMAND
    mkdir -p <INSTALL_DIR>/etc/openssl
  COMMAND
    $(MAKE) depend
  COMMAND
    $(MAKE)
  COMMAND
    $(MAKE) test
  INSTALL_COMMAND
    $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
