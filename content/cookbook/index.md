---
layout = "guide"
title = "Cookbook"
---

## Add a post

Run `pooka run -- new posts/hello my-site --title "Hello"`. This creates a
draft in `my-site/content/posts/`. Preview it with
`pooka run -- serve my-site --drafts` and set `draft = false` to publish it.

## Move a page without breaking its old address

Put the new route and the old address in the page’s TOML front matter.

```toml
permalink = "/notes/hello/"
aliases = ["/hello/"]
```

Run `pooka run -- check my-site` before building. Jinks writes a redirect at
the old address. See [templates and aliases](../docs/templates/) for details.

## Serve a project below a URL prefix

Set `base-url = "https://example.org/my-site/"` in `config.toml`. Use
`relative_url` for site links inside templates so they include the prefix.

```html
<a href="{{ '/notes/' | relative_url }}">Notes</a>
```

The development server prints the corresponding local preview address.
