FROM alpine:3.10.3 as alpine 

# Install protoc v3.6.1-r1
# and get Google Protobuf files
RUN apk add --no-cache protobuf curl && \
        mkdir -p /protobuf/google/protobuf && \
        mkdir -p /protobuf/google/type && \
        for f in any api descriptor duration empty struct timestamp wrappers; do \
        curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
        done && \
        for f in calendar_period color date datetime dayofweek expr fraction latlng money month postal_address quaternion timeofday type; do \
        curl -L -o /protobuf/google/type/${f}.proto https://raw.githubusercontent.com/googleapis/googleapis/master/google/type/${f}.proto; \
        done && \
        apk del curl

COPY bin/protoc-gen-go bin/protoc-gen-bq-schema /usr/bin/

ENTRYPOINT ["/usr/bin/protoc", "-I/protobuf"]
