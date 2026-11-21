---
layout = "guide"
title = "A page that knows its way around a template"
---

Markdown is deliberately not evaluated as Tuck. To write a content page that
uses template expressions, put a `.tuck` file in `content/` instead.

## A standalone page

`content/about.html.tuck`:

```html
---
title = "About the workshop"
---
<!doctype html>
<title>{{ page.title }} · {{ site.title }}</title>
<h1>{{ page.title }}</h1>
<p>{{ data.profile.description }}</p>
```

It produces `about.html`. An extensionless `content/about.tuck` instead produces
`about/index.html`. `content/index.tuck` produces `index.html`. Content suffixes
are recognised without case sensitivity.

Standalone pages receive the same site, page, params, data, and collections as
Markdown layouts. Their TOML front matter has the same collection defaults,
publication dates, visibility rules, and alias handling.

## Inheritance or an optional wrapper

A standalone page has no implicit layout. It may extend a theme template and
fill its blocks:

```html
{% extends "base.html.tuck" %}
{% block body %}
<h1>{{ page.title }}</h1>
{% include "partials/card.html.tuck" %}
{% endblock %}
```

Includes, explicit include arguments, scopes, blocks, and `super()` use Tuck's
normal semantics. Theme templates and site overrides share the same library.

Alternatively, specify `layout = "frame"` in front matter. Jinks first renders
the body and then renders `frame.html.tuck`, where `content` and `page.content`
hold the rendered result. Insert trusted markup deliberately with `safe`:

```html
<main>{{ content | safe }}</main>
```

Collection defaults may provide a layout. An explicit `layout = ""` disables
wrapping, including an inherited default. This works for Markdown too. Choose
inheritance or wrapping deliberately; using both can wrap the page twice.

Inside a standalone body, `content` and `page.content` are empty. Collection and
neighbour summaries also leave standalone template content empty. They never
expose raw Tuck source or recursively render other template pages. Markdown
summaries continue to contain their rendered Markdown.

## Other text formats

The output extension is retained: `feed.xml.tuck` produces `feed.xml`, and
`search.json.tuck` produces `search.json`. Explicit slugs preserve an existing
output extension. Permalinks override the output path.

The effective output path chooses escaping. HTML, HTM, XML, and SVG outputs use
Tuck's markup escaping; other formats use plain text. A permalink that changes
a JSON source page into an HTML output also changes its escaping policy.

For JSON, serialize values rather than putting unchecked strings between quotes.
For example, `content/search.json.tuck` may contain:

```text
{"title": {{ page.title | json }}, "profile": {{ data.profile | json }}}
```

The `json` filter includes the required JSON quotes/escaping. Plain-text output
does not mean that arbitrary interpolation produces valid JSON. XML likewise
needs an appropriate authored document structure.

Standalone pages and Markdown pages share one output namespace. A template
`owl.tuck` and Markdown page `owl.md` therefore collide instead of overwriting
one another.

## Diagnostics

Body syntax and rendering errors point to the content file and its original
line after front matter. Errors in theme includes retain the include's own
filename and line. Private template registration names are removed from those
diagnostics.

## Aliases

An alias retains an old address after a page moves:

```toml
aliases = ["/old-note/", "/an-older-note.html"]
```

Put it in front matter before any `[params]` table. Alias URLs must be
site-relative HTML pages. External destinations, traversal, non-HTML alias
files, and self redirects are rejected.

Each alias generates a small HTML file with a canonical link, immediate meta
refresh, and a visible fallback link. It is suitable for ordinary static hosts;
it does not promise an HTTP 301 response. Targets include the deployment path from `base-url`, so a site mounted at
`https://example.org/blog/` redirects an alias to `/blog/current-page/`.

Aliases participate in page/static collision checks and the ownership manifest.
Removing an alias removes its generated file on the next successful build.
Excluded draft/future pages generate no aliases. Duplicate spellings that resolve
to the same alias output within one page are deduplicated.

Computed `page.aliases` contains normalized public alias URLs, `page.layout` is
the effective layout filename (or empty), `page.draft` is Boolean, and `page.kind`
is `markdown` or `template`.
