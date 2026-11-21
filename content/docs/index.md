---
layout = "guide"
title = "Getting started"
---

## Install

[Download the Jinks escript](../downloads/jinks). It requires Erlang/OTP 29
and runs without a Pooka compiler installation.

On macOS or Linux, put the downloaded file in a directory on your `PATH`:

```sh
mkdir -p "$HOME/.local/bin"
install -m 755 ./jinks "$HOME/.local/bin/jinks"
export PATH="$HOME/.local/bin:$PATH"
jinks --help
```

Run those commands from the folder containing the download. Add the
`export PATH` line to your shell startup file if that directory is new to
your `PATH`.

On Windows, run `escript .\jinks --help` from the download directory. Use
`escript .\jinks` in place of `jinks` in the examples below.

## Create a site

```sh
jinks init my-site
jinks serve my-site
```

Open the address printed by the server. Edit `my-site/content/` and the
minimal theme in `my-site/themes/minimal/` to see the preview update.

```sh
jinks check my-site
jinks build my-site --environment production
```

The production output is in `my-site/public/`. See [deployment](deployment/)
for publishing it with GitHub Pages or Netlify.

## Build from source

With Pooka and Erlang installed, run `pooka export escript` from a Jinks
source checkout. The executable is written to `build/jinks`.
