FROM docker.io/node:lts AS ui
RUN git clone https://github.com/radicle-dev/radicle-bins.git
WORKDIR /radicle-bins/seed/ui
RUN yarn && yarn build
RUN rm -rf .git/

FROM docker.io/rust:latest
COPY --from=ui /radicle-bins /radicle-bins
WORKDIR /radicle-bins

RUN cargo install --path keyutil
RUN cargo install --path seed 

RUN mkdir /radicle-seed
RUN echo "#!/bin/sh \nradicle-keyutil --filename /radicle-seed/secret.key\necho 'Generated key inside /radicle-seed/'" > /keygen.sh
RUN echo "#!/bin/sh \nradicle-seed-node --root /radicle-seed --assets-path /radicle-bins/seed/ui/public --peer-listen 0.0.0.0:12345 --http-listen 0.0.0.0:80 $@ < /radicle-seed/secret.key" > /seed.sh
RUN echo "#!/bin/sh \nradicle-seed-node --help" > /help.sh

WORKDIR /
RUN chmod +x *.sh

RUN rm -rf /radicle-bin/

CMD ["echo", "Start the server with '/seed.sh [OPTIONS]' use '/keygen.sh' to generate the peer key. Mount a volume to '/radicle-seed' to persist the data. For help run '/help.sh'"]

EXPOSE 12345
EXPOSE 80
