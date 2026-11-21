---
layout = "cookbook"
title = "Build a basic blog"
---

Start with the theme Jinks gives you. By the end, you’ll have a home page,
an About page, a newest-first archive, and an RSS feed. Start with
[Jinks installed](../../docs/#install).

## 1. Create the site

```sh
jinks init field-notes
cd field-notes
```

Jinks creates a page, an example post, a minimal theme, and navigation.
Run the remaining commands from inside `field-notes`.

## 2. Configure the archive and feed

Replace `config.toml`:

```toml
title = "Field Notes"
base-url = "http://localhost:4000"
theme = "minimal"
output-dir = "public"

[collections.posts]
path = "posts"
sort = "date"
direction = "descending"
archive = "/posts/"
archive-title = "Posts"
page-size = 10

[publishing]
feed = true
feed-format = "rss"
collection = "posts"
sitemap = true
```

Jinks collects Markdown under `content/posts/` into an archive at `/posts/`
and adds another archive page when you have more than ten posts. The feed
uses the same collection.

## 3. Add pages and navigation

Replace `content/index.md`:

```markdown
---
title = "Field Notes"
---

# Field Notes

A notebook about what I’m learning and making.

Browse the [posts](/posts/) or follow the [RSS feed](/feed.xml).
```

Create `content/about.md`:

```markdown
---
title = "About"
---

# About

Field Notes is where I keep things I want to remember.
```

Replace `data/navigation.toml`. The generated theme reads these links on
every page:

```toml
[[links]]
title = "Home"
url = "/"

[[links]]
title = "Posts"
url = "/posts/"

[[links]]
title = "About"
url = "/about/"

[[links]]
title = "RSS"
url = "/feed.xml"
```

## 4. Write and preview a post

Create a draft:

```sh
jinks new posts/first-note --title "First note"
jinks serve --drafts
```

Open the address printed by Jinks and choose **Posts**. Edit
`content/posts/first-note.md`. Keep the generated date and write your post
below the closing `---`. For example:

```markdown
# First note

I made a place to keep my notes today. This is the first one.
```

The browser reloads as you save. Set `draft = false` when the post is ready.
You can also remove the starter post at `content/posts/hello.md` now that
your home page and navigation link to the archive.

## 5. Build the public site

Stop the preview server. Set `base-url` in `config.toml` to the HTTPS address
where the blog will live. This example uses the root of its own domain.

```sh
jinks check --environment production
jinks build --environment production
```

The finished site is in `public/`:

```tree
public/
  index.html
  about/index.html
  posts/index.html
  posts/first-note/index.html
  feed.xml
  sitemap.xml
  css/style.css
```

Upload `public/` to a static host. Use the
[deployment guide](../../docs/deployment/) for GitHub Pages and Netlify.
