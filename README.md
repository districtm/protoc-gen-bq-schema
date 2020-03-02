# protoc-gen-bq-schema

[![Build Status](https://ci.chuhlomin.com/api/badges/chuhlomin/protoc-gen-bq-schema/status.svg)](https://ci.chuhlomin.com/chuhlomin/protoc-gen-bq-schema) [![Docker Hub](https://img.shields.io/badge/duckerhub-1.5-lightgrey)](https://hub.docker.com/repository/docker/chuhlomin/protoc-gen-bq-schema)

> This is the fork of [GoogleCloudPlatform/protoc-gen-bq-schema](https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema) repository addressing these PRs:
> * #12 [Use comments as field description](https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema/pull/12) (from [`master`](https://github.com/chuhlomin/protoc-gen-bq-schema/tree/master) branch in this repository)
> * #14 [Add support for message-level extra_fields](https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema/pull/14)
> * #17 [Added enumsasints plugin parameter](https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema/pull/17) – since v1.5
> 
> Default branch of this repository is [`develop`](https://github.com/chuhlomin/protoc-gen-bq-schema/tree/develop).
> 
> Two satellite repositories:
> * [protoc-gen-bq-schema-example-proto](https://github.com/chuhlomin/protoc-gen-bq-schema-example-proto) – example of input Protobuf files
> * [protoc-gen-bq-schema-example-bq](https://github.com/chuhlomin/protoc-gen-bq-schema-example-bq) – example of generated Big Schema JSON files

protoc-gen-bq-schema is a plugin for [ProtocolBuffer compiler](https://github.com/google/protobuf).

It converts messages written in `.proto` format into schema files in JSON for BigQuery.

So you can reuse existing data definitions in `.proto` for BigQuery with this plugin.

## Installation

```
go get github.com/jeremiepiotte-districtm/protoc-gen-bq-schema
```

## Usage

```
protoc --bq-schema_out=path/to/outdir foo.proto
```

`protoc` and `protoc-gen-bq-schema` commands must be found in $PATH.

The generated JSON schema files are suffixed with `.schema` and their base names are named
after their package names and `bq_table_name` options.

If you do not already have the standard Google Protobuf libraries in your `proto_path`, you'll need to specify them directly on the command line (and potentially need to copy `bq_schema.proto` into a proto_path directory as well), like this:

```sh
protoc --bq-schema_out=path/to/out/dir foo.proto --proto_path=. --proto_path=<path_to_google_proto_folder>/src
```

### Example
Suppose that we have the following [`foo.proto`](https://github.com/chuhlomin/protoc-gen-bq-schema-example-proto/blob/master/foo/foo.proto).

```protobuf
syntax = "proto3";

package foo;

import "google/type/date.proto";
import "bq/bq_table.proto";
import "bq/bq_field.proto";

message Bar {
  option (gen_bq_schema.bigquery_opts).table_name = "bar_table";
  option (gen_bq_schema.bigquery_opts).extra_fields = "f:INTEGER";
  option (gen_bq_schema.bigquery_opts).extra_fields = "g:RECORD:Baz";

  message Nested {
    repeated int32 a = 1;
  }

  enum EnumAllowingAlias {
    option allow_alias = true;
    UNKNOWN = 0;
    STARTED = 1;
    RUNNING = 1;
  }

  int32 a = 1; // field comment
  Nested b = 2;
  string c = 3;

  bool d = 4 [(gen_bq_schema.bigquery).ignore = true];
  uint64 e = 5 [
    (gen_bq_schema.bigquery) = {
      require: true
      type_override: 'TIMESTAMP'
    }
  ];

  google.type.Date date = 6 [(gen_bq_schema.bigquery).type_override = "DATE"];

  EnumAllowingAlias status = 8;
}

message Baz {
  int32 a = 1;
}
```

`protoc --bq-schema_out=. foo.proto` will generate a file named [`foo/bar_table.schema`](https://github.com/chuhlomin/protoc-gen-bq-schema-example-bq/blob/master/foo/bar_table.schema).

The message `foo.Baz` is ignored because it doesn't have option `gen_bq_schema.bigquery_opts`.

Plugin parameter `enumsasints=true` will marshal all enums into integers instead of strings: `protoc --bq-schema_out=enumsasints=true:. foo.proto`.

## Docker Hub

You can use [chuhlomin/protoc-gen-bq-schema image](https://hub.docker.com/repository/docker/chuhlomin/protoc-gen-bq-schema) on Docker Hub.

Example [Docker](https://www.docker.com) run:

```bash
mkdir bq_schema
docker run -i -t -v $(pwd):/workdir \
  chuhlomin/protoc-gen-bq-schema:1.5 \
  -I/workdir \
  -I/workdir/bq \
  --bq-schema_out=/workdir/bq_schema \
  /workdir/foo.proto
```

Example [Drone](https://drone.io) step: [`.drone.yml`](https://github.com/chuhlomin/protoc-gen-bq-schema-example-proto/blob/master/.drone.yml#L7-L11)

```
  - name: build
    image: chuhlomin/protoc-gen-bq-schema:1.5
    commands:
      - mkdir bq_schema
      - protoc -I/protobuf/ -I. -Ibq --bq-schema_out=bq_schema foo.proto
```

## Local Development

To test and build the plugin binary on your machine run the following commands:

```bash
make clean
make test
make install

# optionally to build a Docker image
docker build -t protoc-gen-bq-schema:local .
```

To build binaries inside an isolated Docker container:

```bash
docker run -i -t -v $(pwd):/workdir golang:1.12.14-alpine3.10 /bin/sh

apk add --no-cache make git gcc libc-dev protobuf
make clean
make test
make install

exit
```

## License

protoc-gen-bq-schema is licensed under the Apache License version 2.0.

**This is not an official Google product.**
