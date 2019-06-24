set(LIBNAME libboost)
set(DEPS libz libbzip2)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

if(APPLE)
  set(BOOST_TOOLCHAIN darwin)
else()
  set(BOOST_TOOLCHAIN clang)
endif()

ExternalProject_Add(third-party-${LIBNAME}
  URL https://downloads.sourceforge.net/project/boost/boost/1.66.0/boost_1_66_0.tar.bz2
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    CC=clang ./bootstrap.sh
      --prefix=<INSTALL_DIR>
      --libdir=<INSTALL_DIR>/lib
      --with-toolset=cc
  COMMAND
    ${REPLACE_CMD} "cc ;" "${BOOST_TOOLCHAIN} ;" project-config.jam
  BUILD_COMMAND true
  INSTALL_COMMAND
    ./b2 install
      --prefix=<INSTALL_DIR>
      --libdir=<INSTALL_DIR>/lib
      -d2
      -j10
      --layout=tagged
      --ignore-site-config
      --disable-icu
      --with-filesystem
      --with-regex
      --with-system
      --with-thread
      --with-coroutine
      --with-context
      threading=multi
      link=static
      optimization=space
      variant=release
      toolset=clang
      "cxxflags=-std=c++11 $ENV{CXXFLAGS}"
      include=<INSTALL_DIR>/include
      "linkflags=$ENV{LDFLAGS}"
  EXCLUDE_FROM_ALL ON
)
