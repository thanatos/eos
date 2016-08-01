PROFILE ?= debug

.PHONY: all kernel
all: kernel


target/build/libcore.rlib: build_libcore.sh
	./build_libcore.sh

target/build/librlibc.rlib: build_rlibc.sh target/build/libcore.rlib
	./build_rlibc.sh

target/${PROFILE}/libeos.a: $(shell find src -type f -and -iname '*.rs') target/build/libcore.rlib target/build/librlibc.rlib
	mkdir -p target
	mkdir -p target/${PROFILE}
	rustc \
		--target x86_64-unknown-none-gnu \
		-L crate=target/build \
		--crate-name eos \
		--out-dir target/${PROFILE} \
		src/lib.rs

TARGET_DIR=$(abspath target)

kernel: | target/${PROFILE}/libeos.a target/build/libcore.rlib target/build/librlibc.rlib
	cd amd64 && TARGET_DIR=${TARGET_DIR} $(MAKE)
