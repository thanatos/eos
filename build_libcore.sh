#!/bin/bash

set -eu


ROOT="$(pwd)"

mkdir -p target
cd target

mkdir -p build


if [[ ! -d rust.git ]]; then
	git clone \
		--depth 1 \
		--branch 1.10.0 \
		https://github.com/rust-lang/rust.git rust.git
fi

cd rust.git
git reset --hard 1.10.0
git clean -f

cd src/libcore

patch -p1 <"$ROOT/libcore_nofp.patch"

EXPECTED_RUST_VERSION="rustc 1.10.0-nightly (dd6e8d45e 2016-05-23)"
if [[ "$(rustc --version)" != "$EXPECTED_RUST_VERSION" ]]; then
	printf '\x1b[1;33mWarning:\x1b[0m You don'\''t seem to be running rust nightly-2016-05-23; it is recommended to install using this version.\n'
	printf 'If you have rustup, you can:\n'
	printf '  rustup install nightly-2016-05-23\n'
	printf '  rustup override set nightly-2016-05-23\n'
fi

#cargo build --release --target "$ROOT/x86_64-unknown-none-gnu.json"
ln -s "$ROOT/x86_64-unknown-none-gnu.json" .
rustc \
	--target "x86_64-unknown-none-gnu" \
	-Z no-landing-pads \
	--cfg disable_float \
	--out-dir "$ROOT/target/build" \
	lib.rs
