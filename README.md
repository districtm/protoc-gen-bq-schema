# protoc-gen-bq-schema

> This is the fork of [GoogleCloudPlatform/protoc-gen-bq-schema](https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema) repository with merged PRs:
> * #12 [Use comments as field description](https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema/pull/12)
> * #14 [Add support for message-level extra_fields](https://github.com/GoogleCloudPlatform/protoc-gen-bq-schema/pull/14)

protoc-gen-bq-schema is a plugin for [ProtocolBuffer compiler](https://github.com/google/protobuf).

It converts messages written in `.proto` format into schema files in JSON for BigQuery.

So you can reuse existing data definitions in `.proto` for BigQuery with this plugin.

## Installation

```
go get github.com/GoogleCloudPlatform/protoc-gen-bq-schema
```

## Usage

```
protoc --bq-schema\_out=path/to/outdir foo.proto
```

`protoc` and `protoc-gen-bq-schema` commands must be found in $PATH.

The generated JSON schema files are suffixed with `.schema` and their base names are named
after their package names and `bq_table_name` options.

If you do not already have the standard Google Protobuf libraries in your `proto_path`, you'll need to specify them directly on the command line (and potentially need to copy `bq_schema.proto` into a proto_path directory as well), like this:

```sh
protoc --bq-schema_out=path/to/out/dir foo.proto --proto_path=. --proto_path=<path_to_google_proto_folder>/src
```

### Example
Suppose that we have the following `foo.proto`.

```protobuf
syntax = "proto3";
package foo;
import "bq_table.proto";
import "bq_field.proto";

message Bar {
  option (gen_bq_schema.bigquery_opts).table_name = "bar_table";
  option (gen_bq_schema.bigquery_opts).extra_fields = "f:INTEGER";
  option (gen_bq_schema.bigquery_opts).extra_fields = "g:RECORD:Nested";

  message Nested {
    repeated int32 a = 1;
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
}

message Baz {
  int32 a = 1;
}
```

`protoc --bq-schema_out=. foo.proto` will generate a file named `foo/bar_table.schema`.

The message `foo.Baz` is ignored because it doesn't have option `gen_bq_schema.bigquery_opts`.

## License

protoc-gen-bq-schema is licensed under the Apache License version 2.0.

This is not an official Google product.
