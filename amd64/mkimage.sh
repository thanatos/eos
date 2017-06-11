#!/bin/bash

set -e

if [[ -d isofiles ]]; then
	rm -rf isofiles
fi

# Stage the data we want in our image:
mkdir -p isofiles/boot/grub
cp grub.cfg isofiles/boot/grub/.
cp ../target/x86_64-unknown-none-gnu/debug/kernel.bin isofiles/boot/.

# Make the image:
grub-mkrescue -o os.iso isofiles

# Clean up:
rm -rf isofiles
