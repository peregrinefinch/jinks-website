# Jinks website

The Jinks homepage, guides, and cookbook are built with [Jinks](https://github.com/peregrinefinch/jinks).
The dependency is pinned in `pooka.toml`.

```sh
pooka deps download
./scripts/build-escript.sh
pooka run -- check
pooka run -- serve
```

The local preview listens at http://127.0.0.1:4190. GitHub Actions builds and
deploys the production site to [GitHub Pages](https://peregrinefinch.github.io/jinks-website/).
