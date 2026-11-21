---
layout = "guide"
title = "Deploying a Jinks site"
---

From a site directory, use the [Jinks escript](../#install):

```sh
jinks check --environment production
jinks build --environment production
```

If your site has a Pooka entry point with custom data providers, run the
following from that project instead:

```sh
pooka deps download
pooka run -- check --environment production
pooka run -- build --environment production
```

Publish the generated `public/` directory, or the directory selected by
`output-dir` in `config.toml`. Set `base-url` to the public HTTPS URL, including
the path if the site lives below the domain root. Use
`--base-url https://preview.example.org/` for a separate preview build. Authored
root-relative links need to account for the prefix when a site uses one.

## GitHub Pages

Build the site in GitHub Actions.
Install pinned Erlang and Pooka versions in the build job, run the production
commands above, then upload the generated directory using
`actions/upload-pages-artifact`. Use a separate deploy job with
`actions/deploy-pages`, the `github-pages` environment, and
`pages: write` and `id-token: write`. Keep the existing deploy workflow
recoverable until the Jinks build has been reviewed.


## Netlify

Set the publish directory relative to the Netlify base directory. A repository build needs
Erlang and Pooka provisioned before these commands run.

```toml
[build]
command = "pooka deps download && pooka run -- check --environment production && pooka run -- build --environment production"
publish = "public"
```

If the Netlify build image cannot supply the required runtime, build the same
artifact in CI and upload it to the existing Netlify site. For preview builds,
use the development environment when production analytics should be omitted.
Carry over existing headers and redirects during the migration.
