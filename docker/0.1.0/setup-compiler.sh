#!/bin/sh
# From rusk/scripts/setup-compiler.sh

echo "Setting up dusk toolchain"

ARCH="$(echo $TARGETPLATFORM | sed 's/linux\///')"
case "$ARCH" in
    "amd64") RUST_ARCH="x86_64";;
    "arm64") RUST_ARCH="aarch64";;
    "arm/v7") RUST_ARCH="armv7";;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac
ARTIFACT_NAME="duskc-$RUST_ARCH-unknown-linux-gnu.zip"
ARTIFACT_URL="https://github.com/dusk-network/rust/releases/download/v0.2.0/$ARTIFACT_NAME"
ARTIFACT_DIR="/dusk/compiler"
ARTIFACT_PATH="$ARTIFACT_DIR/$ARTIFACT_NAME"
UNZIPPED_DIR="$ARTIFACT_DIR/unzipped"
EXTRACTED_DIR="$ARTIFACT_DIR/extracted"

# Get the toolchain and extract it
mkdir -p "$ARTIFACT_DIR"
echo "Downloading dusk compiler toolchain"
curl -L "$ARTIFACT_URL" -o "$ARTIFACT_PATH"
unzip "$ARTIFACT_PATH" -d "$UNZIPPED_DIR" >> /dev/null

echo "Extracting dusk toolchain"
# Extract needed items
mkdir -p "$EXTRACTED_DIR"
tar -xzf $UNZIPPED_DIR/rust-nightly-$RUST_ARCH-unknown-linux-gnu.tar.gz -C "$EXTRACTED_DIR" --strip-components=2
tar -xzf $UNZIPPED_DIR/rust-std-nightly-wasm32-unknown-unknown.tar.gz -C "$EXTRACTED_DIR" --strip-components=2
tar -xzf $UNZIPPED_DIR/rust-std-nightly-wasm64-unknown-unknown.tar.gz -C "$EXTRACTED_DIR" --strip-components=2
tar -xzf $UNZIPPED_DIR/rust-src-nightly.tar.gz -C "$EXTRACTED_DIR" --strip-components=2

# Now unneeded
rm -r "$UNZIPPED_DIR" "$ARTIFACT_PATH"

# Allow toolchain to be the default system-wide and install wasm target
rustup toolchain link dusk "$EXTRACTED_DIR"
rustup default dusk
rustup toolchain remove 1.82.0

echo "dusk toolchain successfully setup"

# Install wasm-tools
# From piecrust scripts/strip.sh

TRIPLE=$(rustc -vV | sed -n 's|host: ||p')
ARCH=$(echo "$TRIPLE" | cut -f 1 -d'-')

# This is a bit of a mess because target triples are pretty inconsistent
OS=$(echo "$TRIPLE" | cut -f 2 -d'-')
# If OS is not currently linux, or apple, then we get it again
if [ "$OS" != "linux" ] && [ "$OS" != "apple" ]; then
    OS=$(echo "$TRIPLE" | cut -f 3 -d'-')
fi
if [ "$OS" != "linux" ] && [ "$OS" != "apple" ]; then
    echo "OS not supported: $OS"
    exit 1
fi
# If OS is apple, change it to macos
if [ "$OS" = "apple" ]; then
    OS="macos"
fi

RELEASES_URL=https://github.com/bytecodealliance/wasm-tools/releases/download

PROGRAM_VERSION=1.0.54

ARTIFACT_NAME=wasm-tools-$PROGRAM_VERSION-$ARCH-$OS.tar.gz
ARTIFACT_URL=$RELEASES_URL/wasm-tools-$PROGRAM_VERSION/$ARTIFACT_NAME

ARTIFACT_DIR=/wasm-tools
ARTIFACT_PATH=$ARTIFACT_DIR/$ARTIFACT_NAME

# If the artifact doesn't already exist in the target directory, download it,
# otherwise skip.
if [ ! -f "$ARTIFACT_PATH" ]; then
    echo "Downloading wasm-tools version $PROGRAM_VERSION"
    mkdir -p "$ARTIFACT_DIR"
    curl -L "$ARTIFACT_URL" -o "$ARTIFACT_PATH"
fi

# Extract the tarball, if they aren't already extracted
EXTRACTED_DIR=$ARTIFACT_DIR/extracted

if [ ! -d "$EXTRACTED_DIR" ]; then
    echo "Extracting wasm-tools"
    mkdir -p "$EXTRACTED_DIR"
    tar -xzf "$ARTIFACT_PATH" -C "$EXTRACTED_DIR" --strip-components=1
fi
