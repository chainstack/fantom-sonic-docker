# Build stage
FROM golang:1.22 AS builder

# Set necessary environment variables
ENV CGO_ENABLED=1
ENV GOOS=linux
ENV GOARCH=amd64

WORKDIR /tmp

RUN apt-get update && apt-get install -y --no-install-recommends make gcc g++ musl-dev git && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch v2.0.1 https://github.com/Fantom-foundation/Sonic.git && \
    cd Sonic && \
    make all

# Final stage

FROM ubuntu:22.04

WORKDIR /root/.sonic

# Install runtime dependencies, including glibc
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl jq && rm -rf /var/lib/apt/lists/*

# Copy binaries from builder stage
COPY --from=builder /tmp/Sonic/build/ /usr/local/bin

# Expose Sonic's default ports (change if necessary)
EXPOSE 18545 18546

ENTRYPOINT ["sonicd"]