#!/bin/bash
set -o errexit -o nounset -o pipefail

# Remove any previous artifacts
(rm -f /target/**/*.wasm || true) &> /dev/null

export RUSTFLAGS=${RUSTFLAGS:-"-C link-args=-zstack-size=65536"}

echo "Building with arguments --locked --color=always --release $@ and RUSTFLAGS="$RUSTFLAGS""

cargo build --locked --color=always --release $@

# Strip the wasm output

WASM_TOOLS_DIR=/wasm-tools/extracted
echo "Stripping the wasm binary"

if [ -d /target/wasm64-unknown-unknown/release ]
then
mkdir -p /target/final-output/wasm64
find /target/wasm64-unknown-unknown/release -maxdepth 1 -name "*.wasm" \
    | xargs -I % basename % \
    | xargs -I % "$WASM_TOOLS_DIR/wasm-tools" strip \
                -a /target/wasm64-unknown-unknown/release/% \
                -o /target/final-output/wasm64/%
echo "Final wasm64 binary is in <your output directory>/final-output/wasm64"
fi

if [ -d /target/wasm32-unknown-unknown/release ]
then
mkdir -p /target/final-output/wasm32
find /target/wasm32-unknown-unknown/release -maxdepth 1 -name "*.wasm" \
    | xargs -I % basename % \
    | xargs -I % "$WASM_TOOLS_DIR/wasm-tools" strip \
                -a /target/wasm32-unknown-unknown/release/% \
                -o /target/final-output/wasm32/%
echo "Final wasm32 binary is in <your output directory>/final-output/wasm32"
fi

echo "Done"
