#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
set -eu

cd "$(dirname "$0")/.."
site_root=$(pwd)
revision=$(python3 -c 'import tomllib; print(tomllib.load(open("pooka.toml", "rb"))["dependencies"]["jinks"]["rev"])')
workspace=$(mktemp -d)
trap 'rm -rf "$workspace"' EXIT

git clone --quiet --no-checkout https://github.com/peregrinefinch/jinks.git "$workspace/source"
git -C "$workspace/source" checkout --quiet --detach "$revision"
(
  cd "$workspace/source"
  pooka export escript
)
binary="$workspace/source/build/jinks"
escript "$binary" --help
escript "$binary" init "$workspace/smoke"
escript "$binary" check "$workspace/smoke"
escript "$binary" build "$workspace/smoke" --environment production
test -s "$workspace/smoke/public/index.html"

mkdir -p "$site_root/static/downloads"
install -m 755 "$binary" "$site_root/static/downloads/jinks"
