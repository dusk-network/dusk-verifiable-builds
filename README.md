# Dusk Verifiable Builds

This repository provides Dockerized environments to produce reproducible and
verifiable builds of Dusk smart contracts. Each version corresponds to a
specific, locked build environment. This ensures identical outputs and allows
for auditability.

## Why Verifiable Builds?

Verifiable builds ensure that the same source code always produces the same
output and that developers and auditors can verify that a smart contract
corresponds to a specific build artifact.

This Dockerized approach locks down the build environment, including the Rust
toolchain and dependencies, ensuring deterministic outputs for `wasm32` and
`wasm64` targets.

## Building the Docker Image (Optional)

To build the image for a specific version:

```bash
cd docker/0.1.0
docker build --platform linux/amd64 . -t dusknode/dusk-verifiable-builds:0.1.0
```

## Pulling the Prebuilt Image

You can pull the prebuilt Docker image for a specific version from the container
registry:

```bash
docker pull dusknode/dusk-verifiable-builds:0.1.0
```

## Usage

To use the Docker image for building your smart contracts:

```bash
docker run --rm \
    -v <path-to-contract-code>:/source \
    -v <path-to-output-folder>:/target \
    --mount type=volume,source=dusk_registry_cache,target=/root/.cargo/registry \
    dusknode/dusk-verifiable-builds:0.1.0
```

### Arguments Explanation

- `<path-to-contract-code>`: Path to your smart contract's project.
- `<path-to-output-folder>`: Path where you want to build artifacts.

After running the container, all builds artifacts will be in
`<path-to-output-folder>`. Final reproducible outputs will be in
`<path-to-output-folder>/final-output/wasm32` and
`<path-to-output-folder>/final-output/wasm64`, depending on the specified
target.

### Customizing the Build

By default, the container runs `cargo build` with the following arguments:

- `--locked --color=always --release --target wasm32-unknown-unknown`
- `RUSTFLAGS` set to `-C link-args=-zstack-size=65536`.

To override the default `--target` argument, you can specify a different target:

```bash
docker run --rm \
    -v <path-to-contract-code>:/source \
    -v <path-to-output-folder>:/target \
    --mount type=volume,source=dusk_registry_cache,target=/root/.cargo/registry \
    dusknode/dusk-verifiable-builds:0.1.0
    --target wasm64-unknown-unknown
```

To provide additional custom arguments, simply append them. For example:

```bash
docker run --rm \
    -v <path-to-contract-code>:/source \
    -v <path-to-output-folder>:/target \
    --mount type=volume,source=dusk_registry_cache,target=/root/.cargo/registry \
    dusknode/dusk-verifiable-builds:0.1.0
    --manifest-path contracts/charlie/Cargo.toml
```

This will run:

```bash
`cargo build --locked --color=always --release --manifest-path contracts/charlie/Cargo.toml`
```

## Adding New Versions

Each version of the Docker image corresponds to a reproducible build
environment. To add a new version:

1. Create a new directory. Copy the existing version directory to a new one:

```bash
cp -r docker/0.1.0 docker/0.2.0
```

2. Update Dependencies. If the Rust toolchain, dependencies or other components
   are updated, modify the `setup-compiler.sh` and `Dockerfile` where
   applicable.

3. Test the build environment. Run the container and verify that it produces
   deterministic outputs for sample contracts.

4. Update the README by adding the necessary documentation.

5. Push the image to the registry:

```bash
docker build --platform linux/amd64 -t dusknode/dusk-verifiable-builds:0.2.0 ./docker/0.2.0
docker push dusknode/dusk-verifiable-builds:0.2.0
```

### Versioning Philosophy

Each version is immutable. Once released, it should NOT be modified. For
example, version `0.1.0` will always correspond to the chosen Rust toolchain. If
an update is required, create a new version.
