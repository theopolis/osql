PLATFORM := $(shell uname -s)
BASH_EXISTS := $(shell which bash)
CTAGS_EXISTS := $(shell which ctags)
CSCOPE_EXISTS := $(shell which cscope)
SHELL := $(shell which bash)
SOURCE_DIR := $(shell pwd)

THIRD_PARTY_BASE := $(SOURCE_DIR)/third-party/prefix

ifneq ($(MAKECMDGOALS),deps)
GIT_EXISTS := $(shell which git)
endif

MAKE = make
ifeq ($(PLATFORM),FreeBSD)
	MAKE = gmake
endif

DISTRO := $(shell . ./tools/lib.sh; _platform)
DISTRO_VERSION := $(shell . ./tools/lib.sh; _distro $(DISTRO))
DARWIN_BUILD := 10.13
ifeq ($(DISTRO),darwin)
	BUILD_NAME = darwin$(DISTRO_VERSION)
	DISTRO_FLAGS += -mmacosx-version-min=$(DARWIN_BUILD)
	DISTRO_LDFLAGS += -mmacosx-version-min=$(DARWIN_BUILD)
	THIRD_PARTY_PLATFORM = darwin-x86_64
ifeq ($(CC),cc)
	CC := clang
endif
ifeq ($(CXX),c++)
	CXX := clang++
endif
else ifeq ($(DISTRO),freebsd)
	BUILD_NAME = freebsd$(DISTRO_VERSION)
else
	BUILD_NAME = $(DISTRO_VERSION)
endif

# This is a hack to support Vagrant and VirtualBox shared folder.
# LLVM/LLD will use mmap with MAP_SHARED, which is not supported.
ifeq ($(PLATFORM),Linux)
	THIRD_PARTY_PLATFORM = linux-x86_64
	FS_TYPE = $(shell stat --file-system --format=%T $(SOURCE_DIR) 2>&1)
else
	FS_TYPE = unknown
endif

ifeq ($(FS_TYPE),nfs)
	BUILD_NAME = shared
	SHARED_DIR = $(shell stat -L build/shared 2>/dev/null >/dev/null || echo 0)
ifeq ($(SHARED_DIR),0)
	DIR = $(shell ln -sf $(shell mktemp -d) build/shared)
endif
	DEBUG_SHARED_DIR = $(shell stat -L build/debug_shared 2>/dev/null >/dev/null || echo 0)
ifeq ($(DEBUG_SHARED_DIR),0)
	DEBUG_DIR = $(shell ln -sf $(shell mktemp -d) build/debug_shared)
endif
	BUILD_DIR = $(shell readlink --canonicalize build/$(BUILD_NAME))$(DIR)
	DEBUG_BUILD_DIR = $(shell readlink --canonicalize build/debug_$(BUILD_NAME))$(DEBUG_DIR)
ifneq (build/$(BUILD_NAME),$(BUILD_DIR))
	LINK = " \-\> $(BUILD_DIR), $(DEBUG_BUILD_DIR)"
endif
else
	BUILD_DIR := build/$(BUILD_NAME)
	DEBUG_BUILD_DIR := build/debug_$(BUILD_NAME)
endif
DEPS_BUILD_DIR := build/deps

ifneq ($(VERBOSE_TEST),)
	VERBOSE_TEST = "-V"
endif

CMAKE := cmake $(CMAKE_EXTRA) $(SOURCE_DIR)/
CTEST := ctest $(SOURCE_DIR)/
FORMAT_COMMAND := python tools/formatting/git-clang-format.py \
	"--commit" "master" "-f" "--style=file"
FORMAT_CHECK_COMMAND := python tools/formatting/format-check.py

ANALYSIS := ${SOURCE_DIR}/tools/analysis
DEFINES := CTEST_OUTPUT_ON_FAILURE=1 \
	LSAN_OPTIONS="detect_container_overflow=0 \
	suppressions=${ANALYSIS}/lsan.supp" \
	ASAN_OPTIONS="suppressions=${ANALYSIS}/asan.supp" \
	TSAN_OPTIONS="suppressions=${ANALYSIS}/tsan.supp,second_deadlock_stack=1" \

ifeq ($(CC),)
	CC := clang
endif
ifeq ($(CXX),)
	CXX := clang++
endif

THIRD_PARTY_PREFIX := $(THIRD_PARTY_BASE)/$(THIRD_PARTY_PLATFORM)
DEPS_FLAGS := -fPIC -DNDEBUG -march=x86-64 -Oz
DEPS_DEFINES := \
	CXX="$(CXX)" CC="$(CC)" \
	ACLOCAL_PATH="$(THIRD_PARTY_PREFIX)/share/aclocal:$(ACLOCAL_PATH)" \
	PKG_CONFIG_PATH="$(THIRD_PARTY_PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH)" \
	LDFLAGS="-L$(THIRD_PARTY_PREFIX)/lib $(LDFLAGS) $(DISTRO_LDFLAGS)" \
	CPATH="$(THIRD_PARTY_PREFIX)/include:$(CPATH)" \
	CFLAGS="-I$(THIRD_PARTY_PREFIX)/include $(CFLAGS) $(DISTRO_FLAGS) $(DEPS_FLAGS)" \
	CXXFLAGS="-I$(THIRD_PARTY_PREFIX)/include $(CXXFLAGS) $(DISTRO_FLAGS) $(DEPS_FLAGS)" \
	PREFIX=$(THIRD_PARTY_PREFIX) \
	CONFIG_SITE=

.setup:
ifneq ($(MAKECMDGOALS),deps)
ifeq ($(GIT_EXISTS),)
	@echo "Problem: cannot find 'git'"
	@false
endif
endif
ifeq ($(BASH_EXISTS),)
	@echo "Problem: cannot find 'bash'"
	@false
endif

ifeq ($(DISTRO),darwin)
ifneq ($(DISTRO_VERSION),$(DARWIN_BUILD))
	@echo "-- Warning! The only Apple OS supported for building is $(DARWIN_BUILD)"
	@echo "-- Note: Installing and running osquery is supported on versions 10.9+"
endif
endif

ifeq ($(FS_TYPE),nfs)
	@echo "-- Requested build on shared (NFS) folder [Issue #3414]: using a temporary build directory"
	@echo "-- Build directories: $(SOURCE_DIR)/build/{debug_}$(BUILD_NAME)$(LINK)"
else
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(DEBUG_BUILD_DIR)
endif

	@mkdir -p build/docs
ifeq ($(PLATFORM),Linux)
	@ln -snf $(BUILD_NAME) build/linux
	@ln -snf debug_$(BUILD_NAME) build/debug_linux
endif
ifeq ($(PLATFORM),Darwin)
	@ln -sfn $(BUILD_NAME) build/darwin
	@ln -sfn debug_$(BUILD_NAME) build/debug_darwin
endif

	@ln -snf "$(SOURCE_DIR)/tools/tests" $(BUILD_DIR)/test_data
	@ln -snf "$(SOURCE_DIR)/tools/tests" $(DEBUG_BUILD_DIR)/test_data

all: .setup
	@if [ ! -d $(BUILD_DIR) ]; then \
		echo "The build directory cannot be used: $(BUILD_DIR)"; \
		echo "Consider: make distclean; make"; \
		false; \
	fi

	@cd $(BUILD_DIR) && $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

setup: .setup

docs: .setup
	@mkdir -p docs
	@cd build/docs && DOCS=True $(CMAKE) && \
		$(DEFINES) $(MAKE) docs --no-print-directory $(MAKEFLAGS)

format_check:
	@echo "[+] clang-format (`which clang-format`) version: `clang-format --version`"
	@$(FORMAT_CHECK_COMMAND)

format_master:
	@echo "[+] clang-format (`which clang-format`) version: `clang-format --version`"
	@$(FORMAT_COMMAND)

debug: .setup
	@cd $(DEBUG_BUILD_DIR) && DEBUG=True $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

test_debug: .setup
	@cd $(DEBUG_BUILD_DIR) && DEBUG=True $(CMAKE) && \
		$(DEFINES) $(MAKE) test --no-print-directory $(MAKEFLAGS)

analyze: .setup
	@cd $(BUILD_DIR) && ANALYZE=True $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

tidy: .setup
	@cd $(BUILD_DIR) && TIDY=True $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

sanitize: .setup
	@cd $(BUILD_DIR) && SANITIZE=True $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

fuzz: .setup
	@echo "[+] zzuf (`which zzuf`) version: `zzuf -V | head -n 1`"
	@python tools/analysis/fuzz.py

libfuzz: .setup
	@cd $(BUILD_DIR) && SKIP_TESTS=True SANITIZE=True FUZZ=True $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)
	@echo "[+] Now run the osqueryf target"

sdk: .setup
	@cd $(BUILD_DIR) && SDK=True $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

test_sdk: .setup
	@cd $(BUILD_DIR) && SDK=True $(CMAKE) && \
		$(DEFINES) $(MAKE) test --no-print-directory $(MAKEFLAGS)

debug_sdk: .setup
	@cd $(DEBUG_BUILD_DIR) && SDK=True DEBUG=True $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

test_debug_sdk: .setup
	@cd $(DEBUG_BUILD_DIR) && SDK=True DEBUG=True $(CMAKE) && \
		$(DEFINES) $(MAKE) test --no-print-directory $(MAKEFLAGS)

check:
	@echo "[+] cppcheck (`which cppcheck`) version: `\cppcheck --version`"
	@cppcheck --quiet --enable=all --error-exitcode=0 -I ./include ./osquery
	@# We want check to produce an error if there are critical issues.
	@echo ""
	@cppcheck --quiet --enable=warning --error-exitcode=1 -I ./include ./osquery

audit: .setup
	@tools/audit.sh

debug_build:
	cd $(DEBUG_BUILD_DIR) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS)

test_build:
	cd $(BUILD_DIR) && \
		$(DEFINES) $(MAKE) test --no-print-directory $(MAKEFLAGS)

test_debug_build:
	cd $(DEBUG_BUILD_DIR) && \
		$(DEFINES) $(MAKE) test --no-print-directory $(MAKEFLAGS)

#deps: .setup
#	./tools/provision.sh build $(BUILD_NAME)

newdeps: .setup
	@mkdir -p $(DEPS_BUILD_DIR)
	@cd $(DEPS_BUILD_DIR) && $(DEPS_DEFINES) $(CMAKE) -DBUILD_TARGET=$(TARGET) -DBUILD_EXTERNAL=ON && \
		$(DEFINES) $(DEPS_DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS) newdeps_target

sysprep: .setup
	@SKIP_DISTRO_MAIN=0 ./tools/provision.sh build $(BUILD_NAME)

#build_deps: .setup
#	@OSQUERY_BUILD_DEPS=1 SKIP_DISTRO_MAIN=1 make deps

tags:
ifeq ($(CTAGS_EXISTS),)
	@echo "problem: cannot find 'ctags'"
	@false
endif
	@ctags -R ./external ./include ./osquery ./third-party
.PHONY: tags

ctags: .setup tags

cscope.files:
	@find \
		-E \
		./external ./include ./osquery ./third-party \
		-type f \
		-iregex '.*\.(c|cc|h|hh|cpp|hpp)' > $@
.PHONY: cscope.files

cscope.out: cscope.files
ifeq ($(CSCOPE_EXISTS),)
	@echo "problem: cannot find 'cscope'"
	@false
endif
	@cscope -b -i cscope.files > $@
.PHONY: cscope.out

cscope: .setup cscope.out

clean: .setup
	@cd $(BUILD_DIR) && $(CMAKE) && \
		$(DEFINES) $(MAKE) clean --no-print-directory $(MAKEFLAGS)

debug_clean: .setup
	@cd $(DEBUG_BUILD_DIR) && DEBUG=True $(CMAKE) && \
		$(DEFINES) $(MAKE) clean --no-print-directory $(MAKEFLAGS)

strip: .setup
	cd $(BUILD_DIR) && find ./osquery -executable -type f | xargs strip

distclean:
	rm -rf .sources $(BUILD_DIR) $(DEBUG_BUILD_DIR) build/docs build/wiki
	rm -f tags cscope.files cscope.out
ifeq ($(PLATFORM),Linux)
	rm -rf build/linux build/debug_linux
endif
ifeq ($(PLATFORM),Darwin)
	rm -rf build/darwin build/debug_darwin
endif
ifeq ($(FS_TYPE),nfs)
	rm -rf build/shared build/debug_shared
endif

#depsclean:
#	./tools/provision.sh clean $(BUILD_NAME)

package: .setup
	# Alias for packages (do not use CPack)
	@cd $(BUILD_DIR) && PACKAGE=True $(CMAKE) && \
		$(DEFINES) $(MAKE) packages/fast --no-print-directory $(MAKEFLAGS)

debug_package: .setup
	@cd $(DEBUG_BUILD_DIR) && DEBUG=True PACKAGE=True $(CMAKE) && \
		$(DEFINES) $(MAKE) packages --no-print-directory $(MAKEFLAGS)

packages: .setup
	@cd $(BUILD_DIR) && PACKAGE=True $(CMAKE) && \
		$(DEFINES) $(MAKE) packages/fast --no-print-directory $(MAKEFLAGS)

debug_packages: .setup
	@cd $(DEBUG_BUILD_DIR) && DEBUG=True PACKAGE=True $(CMAKE) && \
		$(DEFINES) $(MAKE) packages --no-print-directory $(MAKEFLAGS)

sync: .setup
	@cd $(BUILD_DIR) && PACKAGE=True $(CMAKE) && \
		$(DEFINES) $(MAKE) sync --no-print-directory $(MAKEFLAGS)

git_hooks:
	@mkdir -p ./.git/hooks/
	@ln -s ../../tools/hooks/pre-commit.py ./.git/hooks/pre-commit

test: .setup
	@cd build/$(BUILD_NAME) && $(DEFINES) $(CTEST) $(VERBOSE_TEST)

.DEFAULT: .setup
	@$(MAKE) --no-print-directory $(MAKEFLAGS) setup
	@if [ ! -d $(BUILD_DIR) ]; then \
		echo "The build directory cannot be used: $(BUILD_DIR)"; \
		echo "Consider: make distclean; make"; \
		false; \
	fi
	@cd $(BUILD_DIR) && $(CMAKE) && \
		$(DEFINES) $(MAKE) --no-print-directory $(MAKEFLAGS) $(MAKECMDGOALS)

xcode:
	@# Use _xcode suffix to avoid conflict with regular "make"
	@# so both "make" and "make xcode" can be used at the same time
	@./tools/generate_xcode_project.sh ${BUILD_DIR}_xcode '${CMAKE}'
