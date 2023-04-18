#!/bin/sh

echo 'Initializing prisma!'
npx prisma generate && npx prisma migrate deploy

exec "$@"