#!/bin/bash

set -ex

x86_64-elf-as multiboot-header.S -o multiboot-header.o
x86_64-elf-as entry.S -o entry.o
x86_64-elf-as text-ops.S -o text-ops.o

x86_64-elf-ld \
	--nmagic \
	-o kernel.bin \
	-T eos.ld \
	multiboot-header.o entry.o text-ops.o
