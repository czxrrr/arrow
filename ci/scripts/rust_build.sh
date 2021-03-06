#!/usr/bin/env bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -ex

source_dir=${1}/rust
build_dir=${2}/rust

export ARROW_TEST_DATA=${arrow_dir}/testing/data
export PARQUET_TEST_DATA=${arrow_dir}/cpp/submodules/parquet-testing/data
export CARGO_TARGET_DIR=${build_dir}

# show activated toolchain
rustup show

# ensure that the build directory exists
mkdir -p ${build_dir}

pushd ${source_dir}

# flatbuffer codegen
echo "Generating IPC"
flatc --rust -o arrow/src/ipc/gen/ ../format/*.fbs

# work around some bugs in flatbuffers
find arrow/src/ipc/gen/ -name "*_generated.rs" -exec sed -i 's/type__type/type_type/g' {} \;

# build entire project
RUSTFLAGS="-D warnings" cargo build --all-targets

# make sure we can build Arrow sub-crate without default features
pushd arrow
cargo build --all-targets --no-default-features
popd

popd
