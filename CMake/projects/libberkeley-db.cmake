set(LIBNAME libberkeley-db)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL http://pkgs.fedoraproject.org/repo/pkgs/libdb/db-5.3.28.tar.gz/b99454564d5b4479750567031d66fe24/db-5.3.28.tar.gz
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  STEP_TARGETS build install
  PATCH_COMMAND
    ${CLEAR_COMMAND} &&
    ${REPLACE_CMD} "__atomic_compare_exchange" "__atomic_compare_exchange_db" "src/dbinc/atomic.h" &&
    ${REPLACE_CMD} "atomic_init" "atomic_init_db" "src/dbinc/atomic.h" &&
    ${REPLACE_CMD} "atomic_init" "atomic_init_db" "src/mutex/mut_tas.c" &&
    ${REPLACE_CMD} "atomic_init" "atomic_init_db" "src/mp/mp_fget.c" &&
    ${REPLACE_CMD} "atomic_init" "atomic_init_db" "src/mp/mp_mvcc.c" &&
    ${REPLACE_CMD} "atomic_init" "atomic_init_db" "src/mp/mp_region.c"
  CONFIGURE_COMMAND
    cd build_unix && ../dist/configure
      --disable-debug
      --prefix=<INSTALL_DIR>
      --enable-cxx
      --enable-compat185
      --disable-shared
      --enable-static
  BUILD_COMMAND
    cd build_unix && make -j10
  INSTALL_COMMAND
    cd build_unix && make install
  EXCLUDE_FROM_ALL ON
)
