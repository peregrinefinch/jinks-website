---
layout = "guide"
title = "Sending pages into the world"
---

Jinks can publish a feed, sitemap, search index and robots file beside the HTML.
They enter the same collision check, staging directory and ownership manifest.
A malformed page, provider failure or colliding static file leaves the previous
published site intact.

## Machine-readable output

```toml
base-url = "https://example.org/"

[collections.posts]
path = "posts"
sort = "date"
direction = "descending"

[publishing]
feed = true
feed-format = "atom" # or "rss"
feed-limit = 20
feed-title = "Notes from the workshop"
feed-description = "Small stories, published occasionally."
collection = "posts"
sitemap = true
search = true
robots = true
```

Outputs are `feed.xml`, `sitemap.xml`, `search.json` and `robots.txt`.
Each switch defaults to false, so existing authored files retain their place.
`feed-format` defaults to `atom`; `feed-limit` must be between 1 and 1000.
A feed needs a configured collection. It orders dated posts newest first and
excludes undated entries. Draft/future filtering follows the selected build.
RSS publication dates and Atom timestamps use the page's UTC publication day.
A page may set an absolute `feed_id` to preserve an identifier from an older
generator. This becomes its Atom ID or RSS GUID; resource links stay canonical.
The Atom feed ID is the absolute feed URL. Titles/descriptions default to site
metadata when the publishing overrides are omitted.

Sitemaps contain canonical HTML pages and generated listings, excluding aliases
and the root `404.html`. Search is a JSON array of `title`, `url` and plain-text
`content`; standalone pages use rendered text. Its URLs are site-relative.
The robots file points to the sitemap when that output is enabled.

Canonical roots must be absolute HTTP(S) URLs without credentials, query or
fragment. XML is escaped, including rendered HTML inside feed content. Invalid
XML control characters are omitted. Turning an export off removes the old owned
file on the next successful build; unowned conflicting files remain protected.

## Build context

```toml
[build]
environment = "production"
```

The default is `development`. `build` and `check` accept
`--environment production` or `--environment development`. `serve` always uses
development, even when its config selects production. Themes can use:

```html
{% if build.production %}
  <!-- production-only analytics belongs here -->
{% endif %}
```

`{{ time.now() }}` returns one UTC timestamp throughout a build. The library's
`build.prepare_request(request, "2026-11-19")` injects a UTC publication day and a
midnight clock for deterministic tests; `build.prepare_timed` accepts a complete
UTC timestamp. Ordinary builds capture the clock once before provider execution.

## Markdown and trusted HTML

Jinks enables tables, task lists and strikethrough, adds unique heading IDs and
exposes `page.outline` entries with `id`, `text` and `level`. Code fences are
highlighted at build time. Unknown language names and source characters remain
escaped. `snapshot` and `terminal` fences retain coloured terminal/diff output.

```toml
[markdown]
raw-html = true
```

Raw author HTML is escaped by default. Enabling this option trusts author HTML;
it is not sanitisation. Themes are also trusted. Do not use either as a boundary
for untrusted user submissions. Metadata and ordinary Tuck values remain escaped.

## Template helpers

| Helper | Use |
| --- | --- |
| `relative_url` | Prefix a `/site/path/` with the deployment path in `base-url`. |
| `absolute_url` | Construct an absolute URL beneath `base-url`. |
| `asset` | Look up a selected static asset and append a SHA-256 fingerprint. |
| `long_date`, `short_date` | Format a validated day, such as `19 November 2026`. |
| `reading_time` | Estimate minutes at 200 words/minute, rounding up. |
| `strip_tags` | Export rendered HTML as plain text. |
| `where(key, value)` | Select collection entries whose field matches. |
| `distinct(key)` | Collect field values in first-seen order. |
| `concat(array)` | Combine arrays explicitly. |
| `sort_by(key)` | Sort by a field; missing values come last. |
| `group_by(key)` | Return groups with `name` and `entries`. |
| `split(separator)`, `starts_with(prefix)` | Small string operations for themes. |
| `inline_code` | Escape a string and render balanced backtick spans as code. |
| `terminal` | Render a string as coloured terminal markup. |

`asset` reads from the prepared asset index, not from an arbitrary path supplied
by a template. Asset names use their unprefixed site URL, such as `/css/site.css`.

```html
<link rel="stylesheet" href="{{ '/css/site.css' | asset }}">
<a href="{{ '/articles/' | relative_url }}">Articles</a>
{% for heading in page.outline %}
  <a href="#{{ heading.id }}">{{ heading.text }}</a>
{% endfor %}
```

The explicit `sample` host function reads only below the site's `samples/` root:

```html
<pre><code>{{ sample('hello') | safe }}</code></pre>
<pre><code>{{ sample('library', 'src/main.pooka') | safe }}</code></pre>
```

The first reads `samples/hello.pooka`; the second reads a file inside the named
sample directory. Traversal and symlinks are rejected. Changed samples participate
in watching. Their source is escaped and highlighted before `safe` is applied.
Markdown bodies never run Tuck expressions; put these calls in Tuck templates.

## Page head metadata

`seo.title`, `seo.description`, `seo.canonical` and `seo.article` are available to
the theme. Description comes from page `description`, then `summary`, then site
`params.description`. Canonical URLs include the configured deployment prefix.
`seo.structured_data` is a JSON-LD value for an Article or WebPage:

```html
<link rel="canonical" href="{{ seo.canonical }}">
<meta name="description" content="{{ seo.description }}">
<script type="application/ld+json">{{ seo.structured_data | json_script | safe }}</script>
```

`json_script` escapes HTML-significant characters so data cannot close the script
element. Use it instead of an unescaped JSON filter in an HTML script. Themes
still choose Open Graph fields, images and the actual head markup. `date(format)`
supports the explicit `%Y`, `%m-%d-%Y` and `%Y-%m-%d` formats used by these sites;
other formats produce a helpful error rather than pretend to be strftime.

## Explicit data providers

A site can register ordinary Pooka callbacks in a small build-driver project:

```pooka
module main

import jinks
import jinks/provider.{Provider}
import catalogue

main() {
  jinks.main_with([Provider("packages", catalogue.load)])
}
```

`catalogue.load` receives `provider.Context(root, timestamp)` and returns
`Result(Json, String)`. Its result becomes `data.packages`. Providers run before
rendering and remain registered during watched rebuilds. Duplicate names and
collisions with authored data are errors. Without registration, the standard
Jinks CLI runs no provider code. Templates cannot import or execute providers.

`jinks/fetch.json(url, timeout_ms, max_bytes)` provides certificate-verified,
non-redirecting HTTP(S) fetching, transport-level response/header limits, and JSON
depth limits. No credential-bearing URL is accepted. Tests can replace fetching
with recorded data and callbacks; provider code decides cache/fallback policy.

`jinks/cache` offers versioned JSON entries under `.jinks/cache/`:
`get(root, key, now_ms)` and `put(root, key, now_ms, ttl_ms, value)`.
The supplied clock makes expiry tests deterministic. Expired/malformed entries
are misses; writes replace a temporary file. Cache files are excluded from
publication and watching. `jinks clean --cache` also clears this reserved cache
directory while preserving neighbouring `.jinks` files.

## Validation and command output

`jinks check` renders without publishing, then checks local `href`, `src` and
`action` targets and HTML anchors. It handles deployment prefixes, relative
paths, percent-encoded Unicode and query strings. It skips script/style content,
comments and external URLs. It is an attribute scanner, not a complete browser
HTML validator; use browser testing for DOM behaviour, CSS URLs and `srcset`.

Command summaries use Pooka's orange on terminals and readable durations.
`--no-color` or `NO_COLOR` disables ANSI escapes. Redirected output stays plain
unless `FORCE_COLOR` explicitly requests colour. Each command still has its own
help and meaningful exit status.
