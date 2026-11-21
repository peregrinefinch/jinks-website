---
layout = "guide"
title = "A shelf for every subject"
---

Collections remain ordinary ordered lists until you give them an archive URL.
Tags are disabled until a `[tags]` table is present. Generated pages use the same
site overrides and theme templates as authored pages.

## Collection archives

```toml
[collections.posts]
path = "posts"
sort = "date"
direction = "descending"
archive = "/notes/"
archive-layout = "list"
archive-title = "Notes"
page-size = 30
page-path = "page"
```

The first page is `/notes/`; later pages are `/notes/page/2/`, and so on.
There is no `/notes/page/1/` alias. An empty collection still produces its first
archive page. `archive` is optional; the other listing settings default to
`list.html.tuck`, the collection name, 30 items, and `page` respectively.

Archive and index URLs must begin and end with `/`. An archive at `/` is allowed,
but it conflicts with an authored `content/index.md`. Remove that page or choose
another archive address. Generated pages never overwrite authored pages, aliases,
or static assets: all output routes are checked before rendering.

## Tags

```toml
[tags]
collection = "posts"
path = "tag"
layout = "tag"
index = "/tags/"
index-layout = "tags"
index-title = "Tags"
page-size = 30
page-path = "page"
```

This selects visible posts, preserves their collection order within each tag,
and creates `/tag/pooka/` for a `pooka` label. Later pages use
`/tag/pooka/page/2/`. The optional index lists tags in slug order and is paginated
with the same size. With no tags, the index still has one empty page; individual
empty tag pages are not generated.

Without `collection`, tags include every visible authored page in source-path
order. An explicit selector must name a configured collection. Defaults are
`path = "tag"`, `layout = "tag"`, `index-layout = "tags"`,
`index-title = "Tags"`, `page-size = 30`, and `page-path = "page"`.
There is no index URL by default. Set `enabled = false` to disable all tag output.
Paths are portable relative directories; layouts gain `.html.tuck` when omitted.

Labels are trimmed and normalized to Unicode NFC. Repeated equivalent labels on
one page count once. Slugs retain Unicode letters and numbers, lowercase letters,
and join punctuation-separated words with hyphens. Distinct labels producing the
same slug are an error, rather than silently merging subjects. Control characters,
empty labels, unusable slugs, and portable filename violations are errors too.
Output collision checks also compare Unicode-normalized, case-folded paths.

## Template context

On every authored page, `page.tag_links` contains lightweight objects with
`name`, `slug`, `url`, and `count`. With a collection selector, only selected
members receive these links. `taxonomies.tags` contains the ordered full groups;
each also has `pages`, a list of finite page summaries. Draft/future filtering
happens before groups and counts are built.

Generated pages expose `paginator`, with:

- `items`: this window's page summaries, or tag groups on the tag index.
- `number`, `total_pages`, `total_items`, and `page_size`.
- `url`, `first`, `last`, and nullable `previous` / `next` URLs.
- `first_item` and `last_item`: one-based bounds, both zero for an empty listing.
- `links`: at most seven objects with `number`, `url`, `current`, and `gap`.
  A true `gap` asks the theme to insert an ellipsis before that link.

```html
<h1>{{ page.title }}</h1>
<ul>
{% for entry in paginator.items %}
  <li><a href="{{ entry.url }}">{{ entry.title }}</a></li>
{% else %}
  <li>No notes yet.</li>
{% endfor %}
</ul>
{% if paginator.previous %}<a href="{{ paginator.previous }}">Previous</a>{% endif %}
{% if paginator.next %}<a href="{{ paginator.next }}">Next</a>{% endif %}
```

A tag page also has `tag`, containing the full group; `tag.pages` is the complete
member list while `paginator.items` is only the current window. An archive has
`archive.name`, `archive.url`, and `archive.count`. Those values and `paginator`
are null where they do not apply. Generated `page.kind` is `archive`, `tag`, or
`tag-index`; `page.source` is null and `page.content` is empty.

Generated listings do not enter `collections.all`, named collections, or tag
membership. Neighbor and tag summaries remain finite rather than recursively
including other groups. Tag memberships and collection neighbors are cached once
per build.

## Theme and rebuilds

New sites include `list.html.tuck`, `tag.html.tuck`, and `tags.html.tuck`, plus
shared entry and pagination partials. The minimal theme supplies responsive
navigation, keyboard focus styles, and system light/dark colours. Site files in
`layouts/` override these templates. Existing themes are not rewritten by a build;
add the layouts yourself or choose existing ones in configuration.

The watcher rebuilds listings when content or settings change. Removed tags and
surplus pagination pages disappear through the owned-output manifest. Failed
builds keep the previous output available.
