PROFILE ?= debug

.PHONY: all kernel
all: kernel


ifeq (${PROFILE}, debug)
RUST_FLAGS := -g
endif


TARGET_TRIPLE=x86_64-unknown-none-gnu
TARGET_ROOT=target/${TARGET_TRIPLE}
${TARGET_ROOT}/${PROFILE}/libeos.a: $(shell find src -type f -and -iname '*.rs')
	RUST_TARGET_PATH=$$(pwd) xargo build --target x86_64-eos

TARGET_ABSPATH=$(abspath ${TARGET_ROOT})

# ── the kernel

kernel: | ${TARGET_ROOT}/${PROFILE}/libeos.a binutils
	cd amd64 && TARGET_DIR=${TARGET_ABSPATH} $(MAKE)

# ── shortcuts

image: | kernel
	cd amd64 && ./mkimage.sh

run: | image
	qemu-system-x86_64 -cdrom ./amd64/os.iso

run_debug: | image
	qemu-system-x86_64 -cdrom ./amd64/os.iso -s -S

run_gdb:
	gdb -x gdb-init

# ── binutils

binutils: | ${TARGET_ROOT}/binutils/bin/x86_64-elf-as

BINUTILS_ROOT=${TARGET_ROOT}/binutils

${BINUTILS_ROOT}/bin/x86_64-elf-as: build_binutils.py
	./build_binutils.py
