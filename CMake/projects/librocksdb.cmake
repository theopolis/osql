set(LIBNAME librocksdb)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/facebook/rocksdb/archive/v6.1.2.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    cmake
      -DCMAKE_CXX_FLAGS_RELEASE=-DNDEBUG
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DCMAKE_BUILD_TYPE=Release
      -DROCKSDB_LITE=ON
      -DWITH_GFLAGS=OFF
      -DWITH_TESTS=OFF
      -DUSE_RTTI=ON
      -DPORTABLE=ON
      -DFAIL_ON_WARNINGS=OFF
  BUILD_COMMAND
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install &&
    mv ${THIRD_PARTY_PREFIX}/lib/librocksdb.a ${THIRD_PARTY_PREFIX}/lib/librocksdb_lite.a
  EXCLUDE_FROM_ALL ON
)
