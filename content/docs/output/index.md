---
layout = "guide"
title = "Building without losing the previous page"
---

Jinks renders and checks the site before publishing it. Generated pages and
assets go into a fresh sibling directory. When that directory is ready, Jinks
moves the previous output aside, installs the new directory, and removes the
backup. If installation fails, it attempts to restore the previous output.

This is staged replacement with rollback, not a crash-durable atomic directory
exchange. Other processes may briefly observe the output path missing between
renames. A sudden OS/process failure may leave staging or backup directories.
An error that prevents restoration reports where the previous output remains.
Do not remove a backup until its contents have been inspected.

## Ownership

`.jinks-manifest.json` inside the output directory records the version and relative
names of generated files. It is reserved for Jinks and must not be supplied by
content or static assets.

On the next build:

- Files listed by the previous manifest are replaced or removed as needed.
- Unowned files are carried forward unchanged, including binary files.
- A generated path that would overwrite an unowned file stops the build.
- Invalid or unsupported manifests stop the build rather than granting
  permission to remove files.

For example, deleting `content/owl.md` removes `public/owl/index.html` after a
successful rebuild. A manually added `public/notes.txt` survives. Files that you
edit inside generated output are still owned if the manifest lists them; keep
source edits in content, layouts, or static assets instead.

An output directory created by an earlier Jinks build without a manifest is
unowned. Use a fresh dedicated output directory, or inspect and move the old
files before rebuilding. Jinks does not silently adopt them.

## Clean

```sh
jinks clean /path/to/my-site
jinks clean /path/to/my-site --config site.toml --output preview
```

Clean removes manifest-owned generated files. It preserves unowned output,
source files, and an empty manifest. Cleaning a never-built site creates no
output directory. Rebuilding after clean works normally.

## Links and concurrent builds

Jinks rejects symbolic links and special files in its input and output trees.
Existing components beneath the selected site root are checked before writing;
output cannot overlap the standard source directories. These checks assume a
trusted local working tree, not an adversarial process changing paths during
filesystem operations.

An exclusive `.jinks-build.lock` in the site root serialises publication and clean
across BEAM processes. Its contents record the owner's OS PID. Ordinary errors
and callback exceptions release the lock and clean staging. A forcefully
terminated process may leave the lock behind. Check that its process is no
longer building before removing it; Jinks never steals an existing lock.

The small Erlang boundary supplies link-aware inspection, exclusive file
creation, directory renames, and rollback. Ownership policy, manifest parsing,
file selection, and command behaviour remain in Pooka. Directory rename behaviour depends on the underlying platform.
