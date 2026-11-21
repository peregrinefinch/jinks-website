---
layout = "cookbook"
title = "Cookbook"
---

## Start here

[Build a basic blog](basic-blog/) from a fresh Jinks site. Set up a home page,
a posts archive, an About page, and an RSS feed, then build the finished site.

## Move a page without breaking its old address

Put the new route and the old address in the page’s TOML front matter.

```toml
permalink = "/notes/hello/"
aliases = ["/hello/"]
```

Run `jinks check my-site` before building. Jinks writes a redirect at
the old address. See [templates and aliases](../docs/templates/) for details.

## Serve a project below a URL prefix

Set `base-url = "https://example.org/my-site/"` in `config.toml`. Use
`relative_url` for site links inside templates so they include the prefix.

```html
<a href="{{ '/notes/' | relative_url }}">Notes</a>
```

The development server prints the corresponding local preview address.
