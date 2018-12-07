#!/bin/sh

SRC_DIR=$(pwd)

mkdir -p $SRC_DIR/go
# todo - this will obviously not work on a non-linux system or where protobuf isn't system installed
protoc -I/usr/include/ -I$SRC_DIR --go_out=$SRC_DIR/go $SRC_DIR/reference.proto
