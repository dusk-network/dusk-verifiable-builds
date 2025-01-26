FROM ubuntu:24.04

RUN apt-get update && apt-get install -y unzip curl build-essential && rm -rf /var/lib/apt/lists/* && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain=1.82.0 -y

ARG TARGETPLATFORM
ARG TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}

COPY setup-compiler.sh compile.sh /dusk/
ENV PATH="$PATH:/root/.cargo/bin" CARGO_TARGET_DIR=/target

RUN cd /dusk && chmod +x ./setup-compiler.sh && ./setup-compiler.sh

VOLUME ["/source", "/target"]

WORKDIR /source

ENTRYPOINT ["bash", "/dusk/compile.sh"]

CMD ["--target", "wasm32-unknown-unknown"]
