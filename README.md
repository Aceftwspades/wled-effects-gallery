# WLED Effects Studio gallery

Effects made in the [WLED Effects Studio](https://github.com/Aceftwspades/wled-effects-studio),
shared. Each is a graph you can open in your own project, change and put on
your own lights.

## Browsing it

In the studio: **Library** (Window > Library) > **Gallery**. Every effect
here is a tile with its preview; a click fetches it into your project. The
studio asks first, since an effect is code that runs on your computer when
it is built - open what you trust.

You can also look around here: `previews/` has a turn of each effect on a
cube, `effects/` the graphs themselves.

## Sharing yours

1. In the studio, open the graph and choose **Library > Gallery > Share
   this graph...**: name it, describe it in a sentence, tag it. The studio
   makes a folder in `captures/gallery-share/<id>/` with the graph
   (`effects/<id>.graph.json`), a preview (`previews/<id>.gif`) and its
   entry (`entry.json`).
2. Fork this repository, copy the two files into the same folders, and add
   the object in `entry.json` to the `entries` list of `index.json`.
3. Open a pull request. A check makes sure the files match the entry (the
   sha256 is the graph file's) and are within the sizes below.

What fits: a graph that runs on WLED with the studio's usermod, with no
picture or video file of its own (a gallery bundle carries neither), no
firmware outside a standard WLED tree, a file under 2 MB and a preview
under 6 MB.

## The index

`index.json` lists the effects:

```json
{"gallery": 1, "entries": [
  {"id": "aurora-ribbon", "name": "Aurora Ribbon", "author": "you",
   "description": "One sentence about it.", "tags": ["2-D", "audio"],
   "sha256": "<sha256 of effects/aurora-ribbon.graph.json>", "requires": []}
]}
```

An id is lower case letters, digits and dashes; the studio finds an entry's
files by its id alone.

## Licence

The effects are shared under the EUPL v1.2 or later, the studio's and WLED's
licence ([LICENSE](LICENSE)). By opening a pull request you share yours
under it too.
