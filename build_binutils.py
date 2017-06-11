#!/usr/bin/env python3

import os
from os import path
import subprocess
import shutil
import sys
import tempfile


def main():
    build_dir = tempfile.mkdtemp(prefix='eos-binutils-')
    install_dir = path.join('target', 'x86_64-unknown-none-gnu', 'binutils')
    try:
        download_binutils(build_dir)
        build_binutils(build_dir, install_dir)
    finally:
        shutil.rmtree(build_dir)


def download_binutils(build_dir):
    message('Downloading binutils…')
    expect_process(
        (
            'curl', 'https://ftp.gnu.org/gnu/binutils/binutils-2.28.tar.gz',
            '-o', 'binutils-2.28.tar.gz',
        ),
        cwd=build_dir,
        failure_message='Failed to download binutils: curl exited with error.',
    )


def build_binutils(build_dir, install_dir):
    install_dir = path.abspath(install_dir)
    src_dir = path.join(build_dir, 'binutils-2.28')

    message('Extracting binutils…')
    expect_process(
        ('tar', '-xzf', 'binutils-2.28.tar.gz'),
        cwd=build_dir,
        failure_message='Failed to extract binutils: tar exited with error.',
    )

    message('Configuring binutils…')
    expect_process(
        (
            './configure',
            '--target=x86_64-elf',
            f'--prefix={install_dir}',
            '--disable-nls', '--disable-werror',
            '--disable-gdb' '--disable-libdecnumber',
            '--disable-readline' '--disable-sim',
        ),
        cwd=src_dir,
        failure_message=(
            'Failed to configure binutils: configure exited with error.'
        ),
    )

    cpu_count = os.cpu_count()
    message('Building binutils…')
    expect_process(
        ('make', '-j', str(cpu_count)),
        cwd=src_dir,
        failure_message='Failed to build binutils: make exited with error.',
    )
    message('Installing binutils…')
    expect_process(
        ('make', '-j', str(cpu_count * 2), 'install'),
        cwd=src_dir,
        failure_message='Failed to install binutils: make exited with error.',
    )


def expect_process(cmd, failure_message, **kwargs):
    try:
        subprocess.check_call(cmd, **kwargs)
    except subprocess.CalledProcessError:
        print(failure_message, file=sys.stderr)
        sys.exit(1)


def message(msg):
    if os.isatty(sys.stderr.fileno()):
        print(f'\x1b[1m{msg}\x1b[0m', file=sys.stderr)
    else:
        print(msg, file=sys.stderr)


if __name__ == '__main__':
    main()
