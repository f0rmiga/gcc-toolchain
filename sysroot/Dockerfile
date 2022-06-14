FROM ubuntu:22.04 AS base_image

WORKDIR /bin
SHELL ["/bin/bash", "-c"]

WORKDIR /
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
        bzip2 \
        curl \
        file \
        gawk \
        gettext \
        less \
        libz-dev \
        m4 \
        make \
        python3 \
        rsync \
        texinfo \
        xz-utils

####################################################################################################
# Download steps
####################################################################################################

FROM base_image AS kernel_download
WORKDIR /downloads/kernel
RUN curl --location https://github.com/torvalds/linux/archive/refs/tags/v4.9.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -

FROM base_image AS glibc_download
WORKDIR /downloads/glibc
RUN curl --location https://ftp.gnu.org/gnu/glibc/glibc-2.26.tar.xz \
        | tar --xz --extract --strip-components=1 --file -

FROM base_image AS gcc_download
WORKDIR /downloads/gcc
RUN curl --location https://ftp.gnu.org/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
RUN ./contrib/download_prerequisites

FROM base_image AS build_image

WORKDIR /opt/gcc/aarch64
RUN curl --location https://toolchains.bootlin.com/downloads/releases/toolchains/aarch64/tarballs/aarch64--glibc--stable-2018.11-1.tar.bz2 \
        | tar --bzip --extract --strip-components=1 --file -
WORKDIR /opt/gcc/aarch64/bin
WORKDIR /opt/gcc/armv7
RUN curl --location https://toolchains.bootlin.com/downloads/releases/toolchains/armv7-eabihf/tarballs/armv7-eabihf--glibc--stable-2018.11-1.tar.bz2 \
        | tar --bzip --extract --strip-components=1 --file -
WORKDIR /opt/gcc/armv7/bin
RUN --mount=source=create_symlinks.sh,target=/usr/bin/create_symlinks.sh create_symlinks.sh arm-linux- arm-linux-gnueabihf-
WORKDIR /opt/gcc/x86_64
RUN curl --location https://toolchains.bootlin.com/downloads/releases/toolchains/x86-64-core-i7/tarballs/x86-64-core-i7--glibc--stable-2018.11-1.tar.bz2 \
        | tar --bzip --extract --strip-components=1 --file -
WORKDIR /opt/gcc/x86_64/bin
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
        --disable-multilib \
        --enable-languages=c,c++,fortran \
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

FROM build_image
COPY --from=kernel /var/buildlibs/kernel /var/builds/sysroot
COPY --from=glibc /var/buildlibs/glibc /var/builds/sysroot
COPY --from=gcc /var/buildlibs/gcc /var/builds/sysroot
