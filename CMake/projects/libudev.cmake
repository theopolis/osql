set(LIBNAME libudev)

ADD_OSQUERY_NEWDEP(${LIBNAME})

ExternalProject_Add(third-party-${LIBNAME}
  URL http://pkgs.fedoraproject.org/repo/pkgs/udev/udev-173.tar.bz2/91a88a359b60bbd074b024883cc0dbde/udev-173.tar.bz2
  INSTALL_DIR ${THIRD_PARTY_PREFIX}
  PATCH_COMMAND
    ${CLEAR_COMMAND}
  CONFIGURE_COMMAND
    ./configure --prefix=<INSTALL_DIR>
      --disable-logging
      --disable-rule_generator
      --disable-introspection
      --disable-gudev
      --disable-keymap
      --disable-mtd-probe
      --disable-hwdb
      --disable-shared
      --enable-static
      --enable-gtk-doc-html=no
      --with-systemdsystemunitdir=<INSTALL_DIR>/share
  BUILD_COMMAND
    $(MAKE) libudev/libudev.la
  INSTALL_COMMAND
    $(MAKE) install-exec &&
    $(MAKE) install-includeHEADERS
  EXCLUDE_FROM_ALL ON
)
