# Get the source code
FROM docker.io/alpine:latest AS source
RUN apk add --no-cache git
RUN git clone https://github.com/radicle-dev/radicle-bins.git
RUN rm -rf /radicle-bins/.git/

# Build the ui
FROM docker.io/node:lts AS ui
COPY --from=source /radicle-bins /radicle-bins

WORKDIR /radicle-bins/seed/ui
RUN yarn && yarn build

#Build the rust binaries
FROM docker.io/rust:slim AS binaryies

WORKDIR /radicle-bins/
COPY --from=source /radicle-bins ./
RUN cargo install --path seed/
RUN cargo install --path keyutil/

# Final image
FROM docker.io/debian:buster-slim
COPY --from=binaryies /usr/local/cargo/bin/radicle-keyutil /usr/local/bin
COPY --from=binaryies /usr/local/cargo/bin/radicle-seed-node /usr/local/bin
COPY --from=ui /radicle-bins/seed/ui/public /radicle-ui

RUN mkdir /radicle-seed
RUN printf "#!/bin/sh \n radicle-keyutil --filename /radicle-seed/secret.key \n echo 'Generated key inside /radicle-seed/'" > /usr/local/bin/keygen && chmod +x /usr/local/bin/keygen
RUN printf "#!/bin/sh \n \
	radicle-seed-node --root /radicle-seed --assets-path /radicle-ui --peer-listen 0.0.0.0:12345 --http-listen 0.0.0.0:80 $@ < /radicle-seed/secret.key" > /usr/local/bin/seed \
	&& chmod +x /usr/local/bin/seed
RUN printf "#!/bin/sh \n radicle-seed-node --help" > /usr/local/bin/seed-help && chmod +x /usr/local/bin/seed-help


CMD ["echo", "Start the server with 'seed [OPTIONS]' use 'keygen' to generate the peer key. Mount a volume to '/radicle-seed' to persist the data. For help run 'seed-help'"]

EXPOSE 12345
EXPOSE 80
