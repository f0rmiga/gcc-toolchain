FROM ubuntu:16.04 AS build_image

WORKDIR /bin
RUN rm sh && ln -s bash sh

WORKDIR /
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get install -y \
        build-essential \
        bzip2 \
        curl \
        gawk \
        gettext \
        m4 \
        make \
        python3 \
        texinfo \
        xz-utils

WORKDIR /build/bison
RUN curl --location https://ftp.gnu.org/gnu/bison/bison-3.8.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
WORKDIR /build/bison/build
RUN ../configure
RUN make all --jobs $(nproc)
RUN make install
WORKDIR /

ARG ARCH
ENV ARCH="${ARCH}"
RUN if [ -z "${ARCH}" ]; then >&2 echo "Missing ARCH argument"; exit 1; fi
ARG GCC_TARGET_SUFFIX=""
ENV GCC_TARGET_SUFFIX="${GCC_TARGET_SUFFIX}"

FROM build_image AS kernel_4_9
WORKDIR /build/kernel
RUN curl --location https://github.com/torvalds/linux/archive/refs/tags/v4.9.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
RUN apt-get install -y rsync
RUN --mount=source=build_kernel.sh,target=/usr/bin/build_kernel.sh build_kernel.sh

FROM build_image AS glibc
COPY --from=kernel_4_9 /var/buildlibs/kernel /var/buildlibs/kernel
WORKDIR /build/glibc
RUN curl --location https://ftp.gnu.org/gnu/glibc/glibc-2.26.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
WORKDIR /build/glibc/build
RUN ../configure \
        --disable-werror \
        --prefix=/usr \
        --with-headers=/var/buildlibs/kernel/usr/include \
        --with-tls
RUN make all --jobs $(nproc)
RUN make DESTDIR=/var/buildlibs/glibc install

FROM build_image AS gmp_6_2_1
WORKDIR /build/gmp
RUN curl --location https://ftp.gnu.org/gnu/gmp/gmp-6.2.1.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
WORKDIR /build/gmp/build
RUN ../configure \
        --disable-shared \
        --enable-static \
        --prefix=/var/buildlibs/gmp
RUN make all --jobs $(nproc)
RUN make install

FROM build_image AS mpfr_4_1_0
WORKDIR /build/mpfr
RUN curl --location https://ftp.gnu.org/gnu/mpfr/mpfr-4.1.0.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
WORKDIR /build/mpfr/build
COPY --from=gmp_6_2_1 /var/buildlibs/gmp /var/buildlibs/gmp
RUN ../configure \
        --disable-shared \
        --enable-static \
        --prefix=/var/buildlibs/mpfr \
        --with-gmp=/var/buildlibs/gmp
RUN make all --jobs $(nproc)
RUN make install

FROM build_image AS mpc_1_2_1
WORKDIR /build/mpc
RUN curl --location https://ftp.gnu.org/gnu/mpc/mpc-1.2.1.tar.gz \
        | tar --gzip --extract --strip-components=1 --file -
WORKDIR /build/mpc/build
COPY --from=gmp_6_2_1 /var/buildlibs/gmp /var/buildlibs/gmp
COPY --from=mpfr_4_1_0 /var/buildlibs/mpfr /var/buildlibs/mpfr
RUN ../configure \
        --disable-shared \
        --enable-static \
        --prefix=/var/buildlibs/mpc \
        --with-gmp=/var/buildlibs/gmp \
        --with-mpfr=/var/buildlibs/mpfr
RUN make all --jobs $(nproc)
RUN make install

FROM build_image AS isl_0_24
WORKDIR /build/isl
RUN curl --location https://libisl.sourceforge.io/isl-0.24.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
WORKDIR /build/isl/build
COPY --from=gmp_6_2_1 /var/buildlibs/gmp /var/buildlibs/gmp
RUN ../configure \
        --disable-shared \
        --enable-static \
        --prefix=/var/buildlibs/isl \
        --with-gmp-prefix=/var/buildlibs/gmp
RUN make all --jobs $(nproc)
RUN make install

FROM build_image AS zlib_1_2_12
WORKDIR /build/zlib
RUN curl --location https://zlib.net/zlib-1.2.12.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
WORKDIR /build/zlib/build
RUN ../configure --prefix=/var/buildlibs/zlib
RUN make --jobs $(nproc)
RUN make install

FROM build_image AS gcc_10_3
WORKDIR /build/gcc
RUN curl --location https://ftp.gnu.org/gnu/gcc/gcc-10.3.0/gcc-10.3.0.tar.xz \
        | tar --xz --extract --strip-components=1 --file -
WORKDIR /build/gcc/build
COPY --from=kernel_4_9 /var/buildlibs/kernel /var/builds/sysroot
COPY --from=glibc /var/buildlibs/glibc /var/builds/sysroot
COPY --from=gmp_6_2_1 /var/buildlibs/gmp /var/builds/sysroot
COPY --from=mpfr_4_1_0 /var/buildlibs/mpfr /var/builds/sysroot
COPY --from=mpc_1_2_1 /var/buildlibs/mpc /var/builds/sysroot
COPY --from=isl_0_24 /var/buildlibs/isl /var/builds/sysroot
COPY --from=zlib_1_2_12 /var/buildlibs/zlib /var/builds/sysroot
ENV LIBRARY_PATH="/var/builds/sysroot/usr/lib64"
RUN --mount=source=configure_gcc.sh,target=/usr/bin/configure_gcc.sh configure_gcc.sh
RUN make --jobs $(nproc)
RUN make install

FROM build_image
COPY --from=kernel_4_9 /var/buildlibs/kernel /var/builds/sysroot
COPY --from=glibc /var/buildlibs/glibc /var/builds/sysroot
COPY --from=gcc_10_3 /var/buildlibs/gcc /var/builds/sysroot
WORKDIR /var/builds/sysroot
RUN mkdir -p lib usr/lib
