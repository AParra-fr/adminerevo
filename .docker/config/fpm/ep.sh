#!/bin/sh

PREFIX_RUN_CMD="source"

# Preparation PHP ... + whatever the app adds
for S in /ep.d/*.sh
do
    ${PREFIX_RUN_CMD} "$S"
done

# Lancement du processus d'avant plan
exec "$@"
