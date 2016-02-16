https://github.com/the-grid/gom

v1.2:
- Callbacks won't be called with `$` as context anymore. It's a pattern emerging from a chosen architect but it's ... weird. Refer to `$` in a closure and you'll be fine (can probably just replace `@` with `$` in most cases).
- `$.addClass` now always returns a `GomNode`, was able to return a list of classes in some cases.
- Fixed `$.removeClass`, would add a class name rather than remove it if you supplied a single name (not a list).
- `$.removeClass` now always returns a `GomNode`, was able to return a list of classes in some cases.

v1.1.6:

Base version (no change log available of and before this version)
