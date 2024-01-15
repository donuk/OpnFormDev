#!/bin/bash

cd /app/nuxt/server/

. /app/.nuxt.env
[ "x$NUXT_API_SECRET" != "x" ] || generate-api-secret.sh

sed 's/^/export /' < /app/.nuxt.env > env.sh

. env.sh

node index.mjs
