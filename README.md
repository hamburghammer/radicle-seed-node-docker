# radicle-seed-node-image

A small and simple Dockerfile to build a image to run a radicle-seed-node.

Installation steps used from [docs.radicle.xyz](https://docs.radicle.xyz/docs/using-radicle/running-a-seed-node).

## Building
Clone this repository with `git clone https://github.com/hamburghammer/radicle-seed-node-docker` and move with `cd radicle-seed-node-docker`
into the directory.
This image can be build with Docker or with Podman (tested with Podman): `podman build -t hamburghammer/radicle-seed-node .`
To use Docker simply replace `podman` with `docker`.

## Usage
The image is quite simple but here are some options that you have to know:

You want to crate a volume to mount it to `/radicle-seed` inside the container (repalce `pathToMount` from the examples with your path).

On the first run start the container with a volume mounted `podman run -v pathToMount:/radicle-seed hamburghammer/radicle-seed-node keygen`.
This will generate your key to run the node.

After generating the key you can start the node with: `podman run --rm -d --name radicle-seed-node -v pathToMount:/radicle-seed -p 8080:80 -p 12345:12345 hamburghammer/radicle-seed-node seed`

For more options to run the node run: `podman run --rm hamburghammer/radicle-seed-node help`

To use Docker simply replace `podman` with `docker`.
