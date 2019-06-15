set(LIBNAME libgoogle-benchmark)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/google/benchmark/archive/v1.3.0.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  CONFIGURE_COMMAND
    cmake
      -DCMAKE_C_FLAGS_RELEASE=-DNDEBUG
      -DCMAKE_CXX_FLAGS_RELEASE=-DNDEBUG
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DCMAKE_BUILD_TYPE=Release
      -DCMAKE_LIBRARY_PATH=<INSTALL_DIR>/lib
      -DBUILD_SHARED_LIBS=OFF
      <SOURCE_DIR>
  BUILD_COMMAND
    make -j10
  INSTALL_COMMAND
    make install

  EXCLUDE_FROM_ALL ON
)
