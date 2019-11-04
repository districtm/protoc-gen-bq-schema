FROM alpine:3.10.3 as protoc_builder

RUN apk add --no-cache build-base curl automake autoconf libtool git zlib-dev

ENV PROTOBUF_VERSION=3.6.1 \
        OUTDIR=/out

RUN mkdir -p /protobuf && \
        curl -L https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz | tar xvz --strip-components=1 -C /protobuf
RUN cd /protobuf && \
        autoreconf -f -i -Wall,no-obsolete && \
        ./configure --prefix=/usr --enable-static=no && \
        make -j2 && make install
RUN cd /protobuf && \
        make install DESTDIR=${OUTDIR}
RUN find ${OUTDIR} -name "*.a" -delete -or -name "*.la" -delete

RUN apk add --no-cache go 
# installs go version 1.12.12-r0

ENV GOPATH=/go \
        PATH=/go/bin/:$PATH
RUN go get -u -v -ldflags '-w -s' \
        github.com/chuhlomin/protoc-gen-bq-schema
        # ↑ may change to github.com/GoogleCloudPlatform/protoc-gen-bq-schema
        # if this PR merged: https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema/pull/12
        # and this: https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema/pull/14
RUN install -c ${GOPATH}/bin/protoc-gen* ${OUTDIR}/usr/bin/

RUN apk add --no-cache curl && \
        mkdir -p /protobuf/google/protobuf && \
        for f in any duration descriptor empty struct timestamp wrappers; do \
        curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
        done && \
        apk del curl

ENTRYPOINT ["/usr/bin/protoc", "-I/protobuf"]
