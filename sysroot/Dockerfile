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
RUN apt-get update && DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
        bzip2 \
        curl \
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
        xz-utils

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
RUN curl --fail-early --location https://ftp.gnu.org/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.xz \
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
RUN ln -s "/opt/gcc/${ARCH}/bin/${ARCH}-linux-cpp.br_real" /lib/cpp

ENV PATH="/opt/gcc/x86_64/bin:/opt/gcc/${ARCH}/bin:${PATH}"

####################################################################################################
# Build steps
####################################################################################################

FROM build_image AS kernel
COPY --from=kernel_download /downloads/kernel /build/kernel
WORKDIR /build/kernel
RUN --mount=source=build_kernel.sh,target=/usr/bin/build_kernel.sh build_kernel.sh

FROM build_image AS glibc
COPY --from=kernel /var/buildlibs/kernel /var/buildlibs/kernel
COPY --from=glibc_download /downloads/glibc /build/glibc
WORKDIR /build/glibc/build
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --enable-kernel=4.9 \
        --disable-werror \
        --prefix=/usr \
        --with-headers=/var/buildlibs/kernel/usr/include \
        --with-tls \
        libc_cv_slibdir=/usr/lib \
        || (cat config.log && exit 1)
RUN make all --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/glibc install

FROM build_image AS gcc
COPY --from=gcc_download /downloads/gcc /build/gcc
WORKDIR /build/gcc/build
COPY --from=kernel /var/buildlibs/kernel /var/builds/sysroot
COPY --from=glibc /var/buildlibs/glibc /var/builds/sysroot
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh IS_GCC_BUILD=1 configure.sh \
        --enable-default-pie \
        --enable-languages=c,c++,fortran \
        --disable-multilib \
        --prefix=/var/buildlibs/gcc \
        --enable-libstdcxx-threads \
        --with-build-sysroot=/var/builds/sysroot \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc) all-gcc
RUN make install-gcc
RUN rm -v "/opt/gcc/${ARCH}/bin/"*{gcc,g++,cpp}
ENV PATH="/var/buildlibs/gcc/bin:${PATH}"
RUN make --jobs $(nproc)
RUN make uninstall
RUN make install all-target-libgcc
RUN make install all-target-libgfortran
RUN make install all-target-libstdc++-v3
RUN rm -rf /var/buildlibs/gcc/bin
RUN rm -rf /var/buildlibs/gcc/usr/bin

####################################################################################################
# Extra libs
####################################################################################################

FROM build_image AS libX11
COPY --from=kernel /var/buildlibs/kernel /var/builds/sysroot
COPY --from=glibc /var/buildlibs/glibc /var/builds/sysroot
ENV PKG_CONFIG_PATH="/var/buildlibs/libX11/usr/share/pkgconfig:/var/buildlibs/libX11/usr/lib/pkgconfig"
ENV CPPFLAGS="-I/var/buildlibs/libX11/usr/include"
ENV LDFLAGS="-L/var/buildlibs/libX11/usr/lib"
WORKDIR /build/util-macros/build
COPY --from=util-macros_download /downloads/util-macros /build/util-macros
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install
WORKDIR /build/xproto/build
COPY --from=xproto_download /downloads/xproto /build/xproto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/var/buildlibs/libX11/usr \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
WORKDIR /build/xextproto/build
COPY --from=xextproto_download /downloads/xextproto /build/xextproto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install
WORKDIR /build/kbproto/build
COPY --from=kbproto_download /downloads/kbproto /build/kbproto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install
WORKDIR /build/inputproto/build
COPY --from=inputproto_download /downloads/inputproto /build/inputproto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install
WORKDIR /build/xcb-proto/build
COPY --from=xcb-proto_download /downloads/xcb-proto /build/xcb-proto
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/var/buildlibs/libX11/usr \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make install
WORKDIR /build/libXau/build
COPY --from=libXau_download /downloads/libXau /build/libXau
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install
RUN make DESTDIR=/var/builds/sysroot install
WORKDIR /build/xtrans/build
COPY --from=xtrans_download /downloads/xtrans /build/xtrans
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install
WORKDIR /build/libpthread-stubs/build
COPY --from=libpthread-stubs_download /downloads/libpthread-stubs /build/libpthread-stubs
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot \
        || (cat config.log && exit 1)
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install
WORKDIR /build/libxcb/build
COPY --from=libxcb_download /downloads/libxcb /build/libxcb
ENV PYTHONPATH="/var/builds/sysroot/lib/python3.1/site-packages"
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install
WORKDIR /build/libX11/build
COPY --from=libX11_download /downloads/libX11 /build/libX11
RUN --mount=source=configure.sh,target=/usr/bin/configure.sh configure.sh \
        --prefix=/usr \
        --with-sysroot=/var/builds/sysroot
RUN ln -s /var/builds/sysroot/usr/lib/libc.so.6 /usr/lib/libc.so.6
RUN ln -s /var/builds/sysroot/usr/lib/ld-linux-x86-64.so.2 /usr/lib/ld-linux-x86-64.so.2
RUN make --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/libX11 install

####################################################################################################
# Assemble final sysroots
####################################################################################################

FROM build_image AS sysroot_base
COPY --from=kernel /var/buildlibs/kernel /var/builds/sysroot
COPY --from=glibc /var/buildlibs/glibc /var/builds/sysroot
COPY --from=gcc /var/buildlibs/gcc /var/builds/sysroot

FROM build_image AS sysroot_X11
COPY --from=sysroot_base /var/builds/sysroot /var/builds/sysroot
COPY --from=libX11 /var/buildlibs/libX11 /var/builds/sysroot
