set(LIBNAME librapidjson)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://github.com/miloyip/rapidjson/archive/v1.1.0.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    patch -p1 < ${PATCH_DIR}/librapidjson-1.1.0-1.patch
  CONFIGURE_COMMAND
    export CXXFLAGS=-Wno-extra-semi-stmt\ -Wno-zero-as-null-pointer-constant\ -Wno-shadow\ $ENV{CXXFLAGS} &&
    cmake
      -DCMAKE_CXX_FLAGS_RELEASE=$ENV{CXXFLAGS}
      -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
      -DRAPIDJSON_BUILD_DOC=OFF
      -DCMAKE_BUILD_TYPE=Release
      <SOURCE_DIR>
  BUILD_COMMAND
    $(MAKE)
  INSTALL_COMMAND
    $(MAKE) install
  EXCLUDE_FROM_ALL ON
)
