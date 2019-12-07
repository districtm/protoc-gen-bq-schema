FROM alpine:3.10.3 as alpine 

# Install protoc v3.6.1-r1
# and get Google Protobuf files
RUN apk add --no-cache protobuf curl && \
        mkdir -p /protobuf/google/protobuf && \
        for f in any duration descriptor empty struct timestamp wrappers; do \
        curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
        done && \
        apk del curl

COPY bin/protoc-gen-go bin/protoc-gen-bq-schema /usr/bin/

ENTRYPOINT ["/usr/bin/protoc", "-I/protobuf"]
