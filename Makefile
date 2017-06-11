PROFILE ?= debug

.PHONY: all kernel
all: kernel


ifeq (${PROFILE}, debug)
RUST_FLAGS := -g
endif


TARGET_TRIPLE=x86_64-unknown-none-gnu
TARGET_ROOT=target/${TARGET_TRIPLE}
${TARGET_ROOT}/${PROFILE}/libeos.a: $(shell find src -type f -and -iname '*.rs')
	xargo build --target x86_64-unknown-none-gnu

TARGET_ABSPATH=$(abspath ${TARGET_ROOT})

kernel: | ${TARGET_ROOT}/${PROFILE}/libeos.a binutils
	cd amd64 && TARGET_DIR=${TARGET_ABSPATH} $(MAKE)


binutils: | ${TARGET_ROOT}/binutils/bin/x86_64-elf-as

BINUTILS_ROOT=${TARGET_ROOT}/binutils

${BINUTILS_ROOT}/bin/x86_64-elf-as: build_binutils.py
	./build_binutils.py
