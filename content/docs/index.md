---
layout = "guide"
title = "Getting started"
---

From a Jinks source checkout, with Pooka and Erlang installed:

```sh
pooka deps download
pooka run -- init my-site
pooka run -- serve my-site
```

Open the address printed by the server. Edit `my-site/content/` and the
minimal theme in `my-site/themes/minimal/` to see the preview update.

```sh
pooka run -- check my-site
pooka run -- build my-site --environment production
```

The production output is in `my-site/public/`. See [deployment](deployment/)
for publishing it with GitHub Pages or Netlify.
