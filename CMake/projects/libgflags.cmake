set(LIBNAME libgflags)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/gflags/gflags/archive/v2.2.1.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  CONFIGURE_COMMAND
    cmake
      -DCMAKE_CXX_FLAGS_RELEASE=-DNDEBUG
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DCMAKE_BUILD_TYPE=Release
      -DBUILD_SHARED_LIBS=OFF
      <SOURCE_DIR>
  BUILD_COMMAND
    make -j10
  INSTALL_COMMAND
    make install

  EXCLUDE_FROM_ALL ON
)
