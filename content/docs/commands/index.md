---
layout = "guide"
title = "One configuration, a few temporary choices"
---

Run these commands from the Jinks source project with `pooka run --`. Each command
also has its own `--help` or `-h`; `help build` is another way to find the build
instructions. Help does not require an existing site.

## New content

```sh
pooka run -- new posts/the-small-hours /path/to/site --title "The small hours"
pooka run -- new guides/first-steps.md /path/to/site --date 2024-02-29
pooka run -- new about /path/to/site --layout page --config config.preview.toml
```

The path is relative to `content/`; a missing `.md` extension is added. The
optional second positional argument selects the site directory (default `.`).
`--config` / `-c` follows the same anchoring rules as build. Jinks creates missing
content subdirectories but refuses existing files, case/Unicode filename aliases,
linked paths, unsafe names, and other extensions. There is no overwrite flag.

A new page starts with TOML front matter containing a title, publication day, and
`draft = true`, followed by a Markdown heading and a short placeholder. The date
defaults to the current UTC day; `--date` requires a valid `YYYY-MM-DD` day. The
default title replaces filename hyphens/underscores with spaces; `--title`
provides an explicit single-line title. Quotes, backslashes, and Unicode are
preserved in the TOML value.

`--layout` writes an explicit layout; otherwise collection defaults apply as
usual. Creating a page does not build or deploy the site. A running preview
observes its creation, but the new draft remains hidden unless the preview uses
`--drafts`. Set `draft = false` in its front matter when ready.

## Build and check

```sh
pooka run -- build /path/to/site
pooka run -- check /path/to/site
pooka run -- build /path/to/site --config config.preview.toml
pooka run -- build /path/to/site --output preview --base-url https://example.org/
pooka run -- build /path/to/site --drafts --future
```

Build publishes through the owned-file manifest. Check uses the same rendering,
visibility, and collision rules without writing output. Include `--drafts` and
`--future` when checking those pages too.

`--config` / `-c` selects a TOML file, defaulting to `config.toml`. A relative
selection is resolved against the optional site directory; an absolute file
selection anchors the site independently of that positional directory.

All content, theme, layout, data, static, and output paths are relative to the
selected file's directory. For example, selecting `nested/site.toml` reads
`nested/content/` and writes `nested/public/`, not the directories next to the
command's working directory. Paths and configuration filenames may contain
spaces; quote them in the shell.

`--output` / `-o` temporarily replaces `output-dir`. It must remain a safe,
contained output directory and cannot overlap source directories. `--base-url`
replaces `site.base_url` for templates. Full URL/base-path helpers are still
planned; this flag does not rewrite arbitrary authored links.

`--drafts` and `--future` include pages otherwise excluded by default. They are
positive flags: omitting them preserves the configuration's own visibility
settings. No command rewrites the TOML file with these temporary choices.

Unknown flags, missing values, extra positional arguments, unsafe destinations,
and missing configuration files produce errors with a failing exit status.

## Serve

```sh
pooka run -- serve /path/to/site --config config.preview.toml --output preview
pooka run -- serve /path/to/site --drafts --future --port 8080
pooka run -- serve /path/to/site --no-reload
```

Serve accepts the build options alongside `--host`, `--port` / `-p`, and
`--no-reload`. It watches the selected configuration filename. Command-line
choices are retained for every rebuild; for example, a CLI output override keeps
winning if the configuration's `output-dir` changes.

Host, port, and browser-reload settings are applied at startup and require a
restart to change. Content and ordinary site configuration edits rebuild in
place. See [serving and live reload](../serve/) for the watcher and browser client.

## Clean

```sh
pooka run -- clean /path/to/site --config config.preview.toml --output preview
```

Clean accepts only configuration/output options and help. It removes only
manifest-owned generated files in the selected output, preserving unowned files
and all source/configuration files. It cannot clean an arbitrary outside path.
See [output ownership](../output/) for interrupted-build and lock handling.
