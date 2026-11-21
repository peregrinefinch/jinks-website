---
layout = "guide"
title = "A page with the window open"
---

Build, watch, and serve a local site:

```sh
jinks serve /path/to/my-site
```

The default address is `http://127.0.0.1:4000`. Ctrl-C stops the command. The
listener is a development tool and accepts loopback addresses only. It is not a
production HTTP server.

## Configuration

Site settings belong in `config.toml` (or a file selected with `--config`):

```toml
[server]
host = "127.0.0.1"
port = 4000
live-reload = true
```

`localhost` is normalised to `127.0.0.1`; `::1` is supported for IPv6 loopback.
Port zero asks the OS for a free port. The command prints the chosen address, including any deployment path from `base-url`. A site with `base-url = "https://example.org/blog/"` is previewed at `http://127.0.0.1:4000/blog/`. Source paths stay relative to the site root.

Command-line options override these defaults:

```sh
jinks serve /path/to/my-site --port 8080
jinks serve /path/to/my-site --host ::1 --port 8080
jinks serve /path/to/my-site --no-reload
jinks serve --help
```

`--no-reload` disables the browser client, not file watching. Pages still rebuild.
Host, port, and browser-reload options are applied at startup; restart the command
to change them. Content, theme, and ordinary site configuration edits are watched.
Changing `output-dir` or the path in `base-url` retargets the running server after a successful build. When changing the deployment path, open the new path in your browser.

## Saving a template

Jinks watches the selected configuration file, content, themes, site layouts, data, and static files. Build choices such as `--output`, `--base-url`, `--drafts`, and `--future` are retained across rebuilds. See [command options](../commands/).
Output, publication manifests, locks, staging directories, and caches are not
inputs, so writing a build does not start another build.

The current portable watcher polls every 250ms. Two matching observations of a
changed input set debounce a save. SHA-256 fingerprints detect edits even when
file size and timestamps do not change. Rebuilds run one at a time; edits made
during a build are noticed on the next observation. Each rebuild is currently a
full build; native filesystem notifications and incremental compilation are not
implemented. Large asset trees therefore add polling I/O and hashing work.

Successful rebuilds publish the next output and send a server-sent event to open
pages. Edits to existing static CSS files replace same-origin stylesheet links in place, keeping the old styles until the replacements load. Other changes reload the page. Reconnects use the
browser's EventSource behaviour. Served HTML carries its current build revision, so an edit between the page request and the first event connection still triggers a reload. A failed stylesheet load, missing stylesheet links, added/removed files or missed event revisions falls back to a full reload.

A failed rebuild keeps the last successful output available. Jinks reports the
error in the terminal and in a browser overlay. Diagnostics enter the overlay
as text, never HTML. An unchanged broken template keeps its error visible; a
successful repair clears the error and reloads the page.

The client script is injected into served HTML responses. Generated files on
disk stay suitable for static hosting and contain no development client.

## Static responses

The server supports GET and HEAD, directory index pages, common MIME types, and
binary assets. A missing page uses `404.html` if present, otherwise a plain-text
404. Other methods receive 405 with an Allow header. Responses disable caching
for predictable previews.

Request paths are percent-decoded once and checked before filesystem access.
Dot segments, hidden files, backslashes, control characters, and symbolic links
are rejected. The ownership manifest is never served. Working trees are assumed
to be trusted local files; this is not protection against an adversarial process
replacing filesystem paths concurrently.

Live previews reserve `/__jinks/client.js`, `/__jinks/events`, and
`/__jinks/status`. The status endpoint returns the current revision and rebuild
diagnostic as JSON. These endpoints are disabled by `--no-reload`.
