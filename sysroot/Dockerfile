# Copyright (c) Joby Aviation 2022
# Original authors: Thulio Ferraz Assis (thulio@aspect.dev), Aspect.dev
#
# Copyright (c) Thulio Ferraz Assis 2024
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:22.04 AS base_image

WORKDIR /bin
SHELL ["/bin/bash", "-c"]

WORKDIR /
RUN apt-get update \
        && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install --yes \
                bzip2 \
                curl \
                dpkg-dev \
                file \
                gawk \
                gettext \
                less \
                libz-dev \
                m4 \
                make \
                pkg-config \
                python3 \
                rsync \
                texinfo \
                xsltproc \
                xz-utils \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

####################################################################################################
# Download steps
####################################################################################################

FROM base_image AS kernel_download
WORKDIR /downloads/kernel
RUN curl --fail-early --location https://github.com/torvalds/linux/archive/refs/tags/v4.9.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -

FROM base_image AS glibc_download
WORKDIR /downloads/glibc
RUN curl --fail-early --location https://ftp.gnu.org/gnu/glibc/glibc-2.26.tar.xz \
        | tar --xz --extract --strip-components=1 --file -

FROM base_image AS gcc_download
WORKDIR /downloads/gcc
RUN curl --fail-early --location https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
RUN ./contrib/download_prerequisites

FROM base_image AS util-macros_download
WORKDIR /downloads/util-macros
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/util/util-macros-1.17.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS xproto_download
WORKDIR /downloads/xproto
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/proto/xproto-7.0.23.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS xextproto_download
WORKDIR /downloads/xextproto
RUN curl --fail-early --location https://www.x.org/releases/individual/proto/xextproto-7.3.0.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS kbproto_download
WORKDIR /downloads/kbproto
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/proto/kbproto-1.0.6.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS inputproto_download
WORKDIR /downloads/inputproto
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/proto/inputproto-2.2.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS xcb-proto_download
WORKDIR /downloads/xcb-proto
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/xcb/xcb-proto-1.7.1.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS libXau_download
WORKDIR /downloads/libXau
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/lib/libXau-1.0.7.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS xtrans_download
WORKDIR /downloads/xtrans
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/lib/xtrans-1.2.7.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS libxcb_download
WORKDIR /downloads/libxcb
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/xcb/libxcb-1.8.1.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS libpthread-stubs_download
WORKDIR /downloads/libpthread-stubs
RUN curl --fail-early --location https://www.x.org/releases/individual/xcb/libpthread-stubs-0.4.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS libX11_download
WORKDIR /downloads/libX11
RUN curl --fail-early --location https://www.x.org/releases/X11R7.7/src/lib/libX11-1.5.0.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
FROM base_image AS binutils_download
WORKDIR /downloads/binutils
RUN curl --fail-early --location https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
FROM base_image AS patchelf_download
WORKDIR /downloads/patchelf
RUN curl --fail-early --location https://github.com/NixOS/patchelf/releases/download/0.18.0/patchelf-0.18.0-x86_64.tar.gz \
        | tar --gz --extract --strip-components=1 --file -

FROM base_image AS build_image

WORKDIR /opt/gcc/aarch64
RUN curl --fail-early --location https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2018.11-1.tar.bz2 \
        | tar --bzip --extract --strip-components=1 --file -
WORKDIR /opt/gcc/aarch64/bin
RUN rm pkg-config
WORKDIR /opt/gcc/armv7
RUN curl --fail-early --location https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--glibc--stable-2018.11-1.tar.bz2 \
        | tar --bzip --extract --strip-components=1 --file -
WORKDIR /opt/gcc/armv7/bin
RUN rm pkg-config
RUN --mount=source=create_symlinks.sh,target=/usr/bin/create_symlinks.sh create_symlinks.sh arm-linux- arm-linux-gnueabihf-
WORKDIR /opt/gcc/x86_64
RUN curl --fail-early --location https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64-core-i7/tarballs/x86-64-core-i7--glibc--stable-2018.11-1.tar.bz2 \
        | tar --bzip --extract --strip-components=1 --file -
WORKDIR /opt/gcc/x86_64/bin
RUN rm pkg-config
RUN --mount=source=create_symlinks.sh,target=/usr/bin/create_symlinks.sh create_symlinks.sh x86_64-linux-
WORKDIR /

####################################################################################################
# Setup steps
####################################################################################################

ARG ARCH
ENV ARCH="${ARCH}"
RUN if [ -z "${ARCH}" ]; then >&2 echo "Missing ARCH argument"; exit 1; fi
RUN rm --force /lib/cpp && ln --symbolic "/opt/gcc/${ARCH}/bin/${ARCH}-linux-cpp.br_real" /lib/cpp

ENV PATH="/opt/gcc/x86_64/bin:/opt/gcc/${ARCH}/bin:${PATH}"

####################################################################################################
# Build steps
####################################################################################################

FROM build_image AS kernel
COPY --from=kernel_download /downloads/kernel /build/kernel
WORKDIR /build/kernel
RUN --mount=source=build_kernel.sh,target=/usr/bin/build_kernel.sh build_kernel.sh

FROM build_image AS glibc
COPY --from=kernel /var/install/kernel /var/install/kernel
COPY --from=glibc_download /downloads/glibc /build/glibc
WORKDIR /build/glibc/build
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --enable-kernel=4.9 \
        --disable-werror \
        --prefix=/usr \
        --with-headers=/var/install/kernel/usr/include \
        --with-tls \
        libc_cv_slibdir=/usr/lib \
        || (cat config.log && exit 1)
RUN make all --jobs $(nproc)
RUN make DESTDIR=/var/install/glibc install

FROM build_image AS gcc
COPY --from=gcc_download /downloads/gcc /build/gcc
WORKDIR /build/gcc/build
COPY --from=kernel /var/install/kernel /var/install/gcc/sysroot
COPY --from=glibc /var/install/glibc /var/install/gcc/sysroot
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        --enable-default-pie \
        --enable-languages=c,c++,fortran,lto \
        --disable-multilib \
        --prefix=/var/install/gcc \
        --enable-libstdcxx-threads \
        --with-build-sysroot=/var/install/gcc/sysroot \
        --with-sysroot=/RELOCATABLE_SYSROOT \
        || (cat config.log && exit 1)
RUN grep -rl '/RELOCATABLE_SYSROOT' . | xargs sed -i 's|/RELOCATABLE_SYSROOT|$(exec_prefix)/sysroot|g'
RUN make --jobs $(nproc) all-gcc
RUN make install-gcc
RUN rm -v "/opt/gcc/${ARCH}/bin/"*{gcc,g++,cpp}
ENV PATH="/var/install/gcc/bin:${PATH}"
RUN make --jobs $(nproc)
RUN make install

FROM build_image AS binutils
COPY --from=binutils_download /downloads/binutils /build/binutils
WORKDIR /build/binutils/build
COPY --from=kernel /var/install/kernel /var/install/gcc/sysroot
COPY --from=glibc /var/install/glibc /var/install/gcc/sysroot
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        --enable-64-bit-bfd \
        --enable-default-pie \
        --enable-gold \
        --enable-plugins \
        --disable-shared \
        --enable-static \
        --with-static-standard-libraries \
        --enable-threads \
        --prefix=/var/install/binutils \
        --with-build-sysroot=/var/install/gcc/sysroot \
        --with-lib-path=/var/install/glibc/usr/lib \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install

####################################################################################################
# Extra libs
####################################################################################################

FROM build_image AS libX11
COPY --from=gcc /var/install/gcc /var/install/gcc
ENV PATH="/var/install/gcc/bin:${PATH}"

WORKDIR /build/util-macros/build
COPY --from=util-macros_download /downloads/util-macros /build/util-macros
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/xproto/build
COPY --from=xproto_download /downloads/xproto /build/xproto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/xextproto/build
COPY --from=xextproto_download /downloads/xextproto /build/xextproto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/kbproto/build
COPY --from=kbproto_download /downloads/kbproto /build/kbproto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/inputproto/build
COPY --from=inputproto_download /downloads/inputproto /build/inputproto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/xcb-proto/build
COPY --from=xcb-proto_download /downloads/xcb-proto /build/xcb-proto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/libXau/build
COPY --from=libXau_download /downloads/libXau /build/libXau
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/xtrans/build
COPY --from=xtrans_download /downloads/xtrans /build/xtrans
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/libpthread-stubs/build
COPY --from=libpthread-stubs_download /downloads/libpthread-stubs /build/libpthread-stubs
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/libxcb/build
COPY --from=libxcb_download /downloads/libxcb /build/libxcb
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

WORKDIR /build/libX11/build
COPY --from=libX11_download /downloads/libX11 /build/libX11
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
RUN make DESTDIR=/var/install/libX11 install

# Rename /var/install/libX11/usr/local to /var/install/libX11/usr, i.e. remove the "local" segment.
# We do this instead of setting the prefix to /usr to make the whole dependency resolution of the
# libX11 build simpler. We do not want to have /usr/local in the include and lib paths, as it is not
# part of the default include and lib paths of GCC.
RUN mv /var/install/libX11/usr/local /var/install/libX11/usr.tmp
RUN rm --recursive /var/install/libX11/usr
RUN mv /var/install/libX11/usr.tmp /var/install/libX11/usr

####################################################################################################
# Assemble final toolchain
####################################################################################################

FROM build_image AS toolchain

COPY --from=gcc /var/install/gcc /var/install/gcc
COPY --from=binutils /var/install/binutils /var/install/binutils
COPY --from=libX11 /var/install/libX11 /var/install/libX11
RUN mkdir --parents /var/builds/toolchain \
        && rsync --archive /var/install/gcc/ /var/builds/toolchain/ \
        && rsync --archive /var/install/binutils/* /var/builds/toolchain/ \
        && rsync --archive /var/install/libX11/* /var/builds/toolchain/sysroot/
RUN --mount=source=dedup,target=/usr/bin/dedup dedup /var/builds/toolchain

# We patch the shared libraries to set the rpath to $ORIGIN, so that during runtime the
# libraries are found in the same directory as the executable.
COPY --from=patchelf_download /downloads/patchelf /var/install/patchelf
RUN find /var \
        -name '*.so*' \
        -exec /var/install/patchelf/bin/patchelf --set-rpath '$ORIGIN/' {} \;
