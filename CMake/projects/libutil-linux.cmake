set(LIBNAME libutil-linux)
set(DEPS libncurses)

ADD_OSQUERY_NEWDEP(${LIBNAME})
GET_NEWDEPS(PROJECT_DEPS ${DEPS})

ExternalProject_Add(third-party-${LIBNAME}
  URL https://www.kernel.org/pub/linux/utils/util-linux/v2.27/util-linux-2.27.1.tar.xz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  DEPENDS ${PROJECT_DEPS}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    export NCURSES_CFLAGS=-I${THIRD_PARTY_PREFIX}/include/ncurses &&
    ./autogen.sh &&
    ./configure
      --prefix=<INSTALL_DIR>
      --disable-all-programs
      --disable-bash-completion
      --without-ncurses
      --enable-libuuid
      --enable-libblkid
      --disable-use-tty-group
      --disable-kill
      --disable-shared
      --without-readline
      --enable-static
  BUILD_COMMAND
    make -j10
  INSTALL_COMMAND
    make install
  EXCLUDE_FROM_ALL ON
)
