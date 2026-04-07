#!/bin/bash

pnpm build
docker build -t rsshub:local .