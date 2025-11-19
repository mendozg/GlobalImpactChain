FROM golang:stretch as build-env

# Install minimum necessary dependencies
ENV PACKAGES curl make git libc-dev bash gcc
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y $PACKAGES

# Set working directory for the build
WORKDIR /go/src/github.com/mendozg/impactchain

# Add source files
COPY . .

# build Impactchain
RUN make build-impactchain-linux

# Final image
FROM golang:1.14 as final

WORKDIR /

RUN apt-get update

# Copy over binaries from the build-env
COPY --from=build-env /go/src/github.com/mendozg/impactchain/build/impactchaind /usr/bin/impactchaind
COPY --from=build-env /go/src/github.com/mendozg/impactchain/build/impactchaincli /usr/bin/impactchaincli
COPY --from=build-env /go/src/github.com/mendozg/impactchain/scripts/start.sh /

EXPOSE 26656 26657 1317 8545 8546

# Run impactchaind by default, omit entrypoint to ease using container with impactchaincli
ENTRYPOINT ["/bin/bash", "-c"]