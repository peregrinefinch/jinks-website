---
layout = "guide"
title = "Deploying a Jinks site"
---

Build from the Pooka project that provides the Jinks command. For a site with
its own entry point and providers, run these commands from the site project.

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

For pooka.run, keep the current custom domain and build in GitHub Actions.
Install pinned Erlang and Pooka versions in the build job, run the production
commands above, then upload the generated directory using
`actions/upload-pages-artifact`. Use a separate deploy job with
`actions/deploy-pages`, the `github-pages` environment, and
`pages: write` and `id-token: write`. Keep the existing deploy workflow
recoverable until the Jinks build has been reviewed.

[GitHub Pages workflow documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages)

## Netlify

For pinchof.me, keep the existing Netlify site and domain. Set the publish
directory relative to the Netlify base directory. A repository build needs
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

[Netlify build configuration](https://docs.netlify.com/build/configure-builds/file-based-configuration/)
