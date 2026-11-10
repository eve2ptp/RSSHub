#!/bin/sh

ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"

export PNPM_HOME="$ROOT/.runtime/pnpm"
export PATH="$ROOT/.runtime/node/bin:$PNPM_HOME/bin:$PATH"

exec "$@"