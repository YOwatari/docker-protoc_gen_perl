FROM buildpack-deps:stretch AS perl-source
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        perl \
        cpanminus \
    && cpanm Devel::PatchPerl \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/* \
    && rm -rf .cpanm /root/.cpanm
ARG PERL_VERSION=5.28.0
RUN set -x  \
    && cd /tmp \
    && curl -sSL -O https://www.cpan.org/src/5.0/perl-${PERL_VERSION}.tar.gz \
    && tar xf perl-${PERL_VERSION}.tar.gz \
    && rm -rf perl-${PERL_VERSION}.tar.gz \
    && perl -MDevel::PatchPerl -e "Devel::PatchPerl->patch_source(\"${PERL_VERSION}\", \"./perl-${PERL_VERSION}\");" \
    && mv perl-${PERL_VERSION} perl


FROM buildpack-deps:stretch AS protobuf
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        libtool \
        curl \
        make \
        g++ \
        unzip \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*
ARG PROTOBUF_VERSION=3.5.1
RUN set -x \
    && cd /tmp \
    && curl -sSL -o protobuf-cpp.zip https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.zip \
    && unzip -q protobuf-cpp.zip \
    && cd protobuf-${PROTOBUF_VERSION} \
    && ./configure --prefix=/usr \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && make clean \
    && cd /root \
    && rm -rf /tmp/*


FROM debian:stretch-slim
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dpkg-dev \
        gcc \
        libc6-dev \
        make \
        netbase
COPY --from=perl-source /tmp/perl /tmp/perl
RUN set -x \
    && cd /tmp/perl \
    && ./Configure -Darchname=x86_64-linux-gnu -Duse64bitall -Duseshrplib -Dvendorprefix=/usr/local -A ccflags=-fwrapv -des \
    && make -j$(nproc) \
    && make install \
    && cd /root \
    && rm -rf /tmp/* \
    && curl -sSL https://cpanmin.us | perl - App::cpanminus
COPY --from=protobuf /usr/bin/protoc* /usr/bin/
COPY --from=protobuf /usr/lib/libprotobuf*.so /usr/lib/
COPY --from=protobuf /usr/lib/libprotoc*.so /usr/lib/
COPY --from=protobuf /usr/lib/pkgconfig/protobuf*.pc /usr/lib/pkgconfig/
COPY --from=protobuf /usr/include/google /usr/include/google
RUN ldconfig
RUN apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        g++ \
        gcc \
        libc6-dev \
        zlib1g-dev \
        libssl-dev

RUN set -x \
    && cpanm IO::Socket::SSL \
    && cpanm Google::ProtocolBuffers::Dynamic \
    && rm -rf .cpanm /root/.cpanm

RUN set -x \
    && apt-mark auto '.*' >/dev/null \
    && apt-mark manual make \
    && apt-mark manual netbase \
    && apt-get -y purge --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

ENTRYPOINT ["protoc"]
CMD ["--help"]

