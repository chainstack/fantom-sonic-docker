# Build stage
FROM golang:1.22 as builder

# Set working directory
WORKDIR /tmp

# Install dependencies
#RUN apk add --no-cache make gcc musl-dev linux-headers git
RUN apt-get update && apt-get install -y git musl-dev make

# Clean the Go module cache
RUN go clean -modcache

# Clone the specific branch of the Sonic repository and build the application
RUN git clone --depth 1 --branch v1.2.1-f https://github.com/Fantom-foundation/Sonic.git && \
    cd Sonic && \
    make all

# Final stage
FROM alpine:latest

# Set working directory
WORKDIR /root/.sonic

# Install ca-certificates for HTTPS
RUN apk add --no-cache ca-certificates curl jq

# Copy binaries from builder stage
COPY --from=builder /tmp/Sonic/build/sonicd /usr/local/bin/
COPY --from=builder /tmp/Sonic/build/sonictool /usr/local/bin/

# Create a non-root user
RUN adduser -D -u 1000 sonic

# Switch to non-root user
USER sonic

# Expose necessary ports
EXPOSE 5050 5050/udp 80 18546 18545

# Set the entrypoint (default to running sonicd, but can be overridden)
ENTRYPOINT ["sonicd"]
