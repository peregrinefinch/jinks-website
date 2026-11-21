---
layout = "guide"
title = "A few shelves for your pages"
---

Jinks reads Markdown from `content/`, TOML or JSON from `data/`, and a local theme
from `themes/<name>/`. Configuration belongs in `config.toml`; a theme's own
settings belong in `theme.toml`.

## Theme defaults and site parameters

A theme can supply nested defaults:

```toml
# themes/minimal/theme.toml
name = "minimal"
version = "1.0.0"

[params.palette]
paper = "cream"
ink = "brown"
```

The site may replace just one value:

```toml
# config.toml
[params.palette]
ink = "purple"
```

Templates receive `site.params.palette.paper` as `cream` and
`site.params.palette.ink` as `purple`. Object fields merge recursively. Arrays,
scalars, and explicit replacements replace their default value rather than
being appended. Page parameters are separate from site parameters:
`page.params` and `params` refer to the page; `site.params` refers to the site.

## Collections

```toml
# config.toml
[collections.posts]
path = "posts"
sort = "date"
direction = "descending"
permalink = "/:year/:month/:day/:slug/"

[collections.posts.defaults]
layout = "post"

[collections.posts.defaults.params]
kind = "note"

[collections.guides]
path = "guides"
sort = "order"
direction = "ascending"
```

`path` is relative to `content/`. A page in `content/posts/owl.md` belongs to
`posts`; `content/posts-extra/owl.md` does not. If configured paths are nested,
the nearest matching directory wins. A path may be empty to select the content
root. Duplicate paths are rejected, including case-folded duplicates.

Collections support sorting by `path`, `title`, `date`, or `order`. Direction is
`ascending` or `descending`. Equal keys always use ascending source paths as a
tie breaker. Date-sorted collections require a publication date on every visible
member. Missing `order` is zero.

Templates receive `collections.posts`, `collections.guides`, and
`collections.all` (every visible page, ordered by source path). `all` is reserved.
Configured collections exist as empty arrays when they contain no visible pages.
Archives and pagination are opt-in; see [listing pages](../listings/). A Markdown
page at `content/posts.md` can also provide a manual listing without becoming a
member of `posts/`.

For example, this is a Tuck listing fragment:

```html
<ul>
{% for post in collections.posts %}
  <li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% else %}
  <li>No notes yet.</li>
{% endfor %}
</ul>
```

## Front matter

```markdown
---
title = "An owl in the workshop"
date = 2020-02-29
tags = ["pooka", "notes"]
slug = "workshop-owl"

[params]
kind = "article"
---

# Hello

The page starts here.
```

Collection defaults are applied first, then explicit page metadata overrides
them, recursively for nested tables. In this example the page's `kind` replaces
`note`, while unrelated default parameters remain. `layout = "post"` selects
`post.html.tuck`; an explicit `.tuck` filename is also accepted.

Publication dates are validated `YYYY-MM-DD` days, written as TOML dates or
strings. Leap days are checked. Timestamps and non-UTC timezone configuration
are not supported yet and are not silently converted into days.

Known page fields include title, date, tags, slug, order, layout, draft, permalink,
and params. Other metadata remains available on `page` and collection summaries
as JSON-compatible values. Core computed fields such as `url`, `source`, and
`collection` take precedence over similarly named metadata.

## URLs

Without a permalink, `notes/owl.md` produces `notes/owl/index.html`; `index.md`
keeps the directory index position. An explicit slug changes the final name.

Page `permalink` overrides the collection rule. Rules support `:slug`, `:section`
(the collection name), `:year`, `:month`, and `:day`. Date placeholders require a
date. Unresolved placeholders are errors.

A permalink is site-relative: `/about/` produces `about/index.html`, and
`/404.html` produces a file named `404.html`. Recognised text formats (`.html`, `.xml`, `.svg`, `.json`, `.txt`, `.css`, `.js`, `.webmanifest`) retain their file extension; other paths use directory indexes. Query strings, fragments, traversal, hidden paths, and development
endpoint paths are rejected. Windows device names and trailing-dot/space aliases are rejected on every platform. Public URLs encode spaces and Unicode characters;
filesystem paths retain their decoded names. Aliases are described in [standalone pages and aliases](../templates/); configurable trailing-slash rules remain planned.

## Neighbouring pages

`page.previous` and `page.next` follow the configured collection order. They are
null at the boundaries or for pages outside a collection. Each is a summary,
without another pair of neighbours inside it, so the context stays finite.

```html
<nav>
{% if page.previous %}<a href="{{ page.previous.url }}">{{ page.previous.title }}</a>{% endif %}
{% if page.next %}<a href="{{ page.next.url }}">{{ page.next.title }}</a>{% endif %}
</nav>
```

Collection summaries include title, URL, source path, collection name, publication
date (or null), order, slug, unique tags, params, computed layout/draft/aliases/kind, and rendered Markdown content. Standalone template summaries have empty content.
Rendered content is still a string at the Tuck boundary: use `safe` deliberately
when inserting trusted rendered Markdown. Ordinary metadata is escaped.

## Draft and future pages

By default, draft pages and pages after the build's current UTC publication day
are absent from both generated files and collection lists. They can be included
explicitly:

```toml
[build]
drafts = true
future = true
```

`build.prepare_at(root, "2020-01-01")` supplies a deterministic publication day
for tests; ordinary builds capture the UTC day once. The watcher rebuilds on
input changes. A publication day arriving at midnight alone does not currently
trigger a rebuild; rebuild or restart the command when needed. `--drafts` and `--future` are also available on build, check, and serve.

## Local data

```toml
# data/navigation.toml
title = "Workshop"
links = ["/", "/notes/"]
```

```json
{"name":"Finch","active":true}
```

Put that JSON document at `data/people/finch.json`. Templates can then read
`data.navigation.title` and `data.people.finch.active`. Numbers, Booleans, arrays,
objects, and null retain their JSON types. TOML dates retain their written text;
non-finite TOML numbers are rejected.

Both extensions are recognised without case sensitivity. Filenames define the
data keys and subdirectories define nested objects. Conflicts such as
`team.toml` plus `team.json`, or `team.toml` plus `team/person.json`, are errors.
An absent data directory is empty; a regular file named `data` is a structural
error. Data remains source input and cannot be chosen as output.

The loader reads each data file once per build. The watcher observes data and
theme-default changes. Templates do not execute data files or fetch network
resources; executable providers are a separate planned feature.
