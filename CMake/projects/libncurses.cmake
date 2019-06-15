set(LIBNAME libncurses)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL http://ftpmirror.gnu.org/ncurses/ncurses-6.0.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure
      --prefix=<INSTALL_DIR>
      --enable-symlinks
      --without-shared
      --without-manpages
      --with-gmp=no
      --with-static
  BUILD_COMMAND
    make -j10
  INSTALL_COMMAND
    make install
    # cp misc/ncurses.pc ${THIRD_PARTY_PREFIX}/lib/pkgconfig &&
  COMMAND
    ln -sf ncurses/curses.h ${THIRD_PARTY_PREFIX}/include/curses.h
  COMMAND
    ln -sf ncurses/term.h ${THIRD_PARTY_PREFIX}/include/term.h
  EXCLUDE_FROM_ALL ON
)
