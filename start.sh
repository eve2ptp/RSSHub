#!/bin/bash

# rm -rf node_modules
# pnpm store prune
pm2 del rsshub
pnpm install
NODE_OPTIONS="--max-old-space-size=512" pnpm run build
pm2 start 'pnpm run start' --name "rsshub"
pm2 logs -f rsshub