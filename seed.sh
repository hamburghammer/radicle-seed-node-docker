#!/bin/sh 
radicle-seed-node --root /radicle-seedi \
	--assets-path /radicle-ui \
	--peer-listen 0.0.0.0:12345 \
	--http-listen 0.0.0.0:80 \
	--name $SEED_NAME \
	--description $SEED_DESCRIPTION \
	--public-addr $SEED_PUBLIC_ADDR \
	$SEED_PARAMS \
	< /radicle-seed/secret.key
