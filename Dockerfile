# Get the source code
FROM docker.io/alpine:latest AS source
RUN apk add --no-cache git
RUN git clone https://github.com/radicle-dev/radicle-bins.git
WORKDIR radicle-bins
RUN git checkout f1462b92a06ef65ec4b65201e9801473a41b4ee3
RUN rm -rf /radicle-bins/.git/

# Build the ui
FROM docker.io/node:lts AS ui
COPY --from=source /radicle-bins/seed/ui/package.json /ui/
COPY --from=source /radicle-bins/seed/ui/yarn.lock /ui/
COPY --from=source /radicle-bins/seed/ui/public/twemoji /ui/public/twemoji
WORKDIR /ui
RUN yarn
COPY --from=source /radicle-bins/seed/ui /ui
RUN yarn build

#Build the rust seed binary
FROM docker.io/rust:slim AS seed

WORKDIR /radicle-bins/
COPY --from=source /radicle-bins ./
RUN cargo install --path seed/

#Build the rust keyutil binary
FROM docker.io/rust:slim AS keyutil

WORKDIR /radicle-keygen/
COPY --from=source /radicle-bins ./
RUN cargo install --path keyutil/


# Final image
FROM docker.io/debian:buster-slim AS final
COPY --from=seed /usr/local/cargo/bin/radicle-seed-node /usr/local/bin
COPY --from=keyutil /usr/local/cargo/bin/radicle-keyutil /usr/local/bin
COPY --from=ui /ui/public /radicle-ui

RUN mkdir /radicle-seed
RUN printf "#!/bin/sh \n radicle-keyutil --filename /radicle-seed/secret.key \n echo 'Generated key inside /radicle-seed/'" > /usr/local/bin/keygen && chmod +x /usr/local/bin/keygen
RUN printf "#!/bin/sh \n radicle-seed-node --help" > /usr/local/bin/seed-help && chmod +x /usr/local/bin/seed-help

ARG SEED_NAME="seedling"
ARG SEED_DESCRIPTION="A selfhosted seedling"
ARG SEED_PUBLIC_ADDR="example.com:12345"

ENV SEED_NAME $SEED_NAME
ENV SEED_DESCRIPTION $SEED_DESCRIPTION
ENV SEED_PUBLIC_ADDR $SEED_PUBLIC_ADDR
ENV SEED_PARAMS ""

COPY ./seed.sh /usr/local/bin/seed
RUN chmod +x /usr/local/bin/seed

CMD ["echo", "Start the server with 'seed [OPTIONS]' use 'keygen' to generate the peer key. Mount a volume to '/radicle-seed' to persist the data. For help run 'seed-help'"]

EXPOSE 12345
EXPOSE 80
