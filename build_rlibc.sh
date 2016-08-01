#!/bin/bash

# Would love to use cargo for this, but can't figure out how to pass stuff
# through to the compiler.

set -eu

ROOT="$(pwd)"

mkdir -p target
cd target

mkdir -p build


if [[ ! -d rlibc.git ]]; then
	git clone \
		https://github.com/alexcrichton/rlibc.git rlibc.git
fi

cd rlibc.git
# This commit hash is "1.0".
git reset --hard 5fdc9822c7d47f1a791cd05ffad35a37540e7004 
git clean -f


ln -s "$ROOT/x86_64-unknown-none-gnu.json" .
rustc \
	--target "x86_64-unknown-none-gnu" \
	--out-dir "$ROOT/target/build" \
	--crate-type rlib \
	--crate-name rlibc \
	-L crate="$ROOT/target/build" \
	src/lib.rs
